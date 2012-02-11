{
  Copyright 2010-2012 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Base 3D objects (T3D, T3DList, T3DTransform). }
unit Base3D;

interface

uses Classes, Math, VectorMath, Frustum, Boxes3D, CastleClassUtils, KeysMouse,
  CastleUtils, FGL, GenericStructList;

type
  TRenderFromViewFunction = procedure of object;

  T3D = class;

  { Describe what visible thing changed
    for T3D.VisibleChange. }
  TVisibleChange = (
    { Something visible in the geometry changed.
      "Geometry" means that this is applicable only to actual 3D shape
      changes. (Think about "does depth buffer from some point in space
      changes" --- this is actually why we have separate vcVisibleGeometry
      and vcVisibleNonGeometry for now, as GeneratedShadowMap
      does need to be updated only on geometry changes.) So it's not applicable
      when only light conditions, materials, textures and such change. }
    vcVisibleGeometry,

    { Something visible changed, but not geometry.
      For example, material or texture on visible surface changed. }
    vcVisibleNonGeometry,

    { Camera view (the settings passed to TCastleSceneCore.CameraChanged) changed. }
    vcCamera);
  TVisibleChanges = set of TVisibleChange;

  TVisibleChangeEvent = procedure (Sender: T3D; Changes: TVisibleChanges) of object;

  { Triangle expressed in particular coordinate system, for T3DTriangle. }
  T3DTriangleGeometry = record
    Triangle: TTriangle3Single;

    { Area of the triangle. In other words, just a precalculated for you
      TriangleArea(Triangle). }
    Area: Single;

    case Integer of
      0: ({ This is a calculated TriangleNormPlane(Triangle),
            that is a 3D plane containing our Triangle, with normalized
            direction vector. }
          Plane: TVector4Single;);
      1: (Normal: TVector3Single;);
  end;

  { 3D triangle.

    This object should always be initialized by @link(Init),
    and updated only by it's methods (never modify fields of
    this object directly).

    I use old-style Pascal "object" to define this,
    since this makes it a little more efficient. This doesn't need
    any virtual methods or such, so (at least for now) it's easier
    and more memory-efficient to keep this as an old-style object.
    And memory efficiency is somewhat important here, since large
    scenes may easily have milions of triangles, and each triangle
    results in one TTriangle (descendant of T3DTriangle) instance. }
  T3DTriangle = object
  public
    { Initialize new triangle. Given ATriangle must satisfy IsValidTriangle. }
    constructor Init(const ATriangle: TTriangle3Single);

  public
    { Geometry of this item.
      We need two geometry descriptions:

      @unorderedList(

        @item(Local is based on initial Triangle, given when constructing
          this T3DTriangle. It's constant for this T3DTriangle. It's used
          by octree collision routines, that is things like
          TBaseTrianglesOctree.SphereCollision, TBaseTrianglesOctree.RayCollision
          and such expect parameters in the same coord space.

          This may be local coord space of this shape (this is used
          by TShape.OctreeTriangles) or world coord space
          (this is used by TCastleSceneCore.OctreeTriangles).)

        @item(World is the geometry of Local transformed to be in world
          coordinates. Initially, World is just a copy of Local.

          If Local already contains world-space geometry, then World
          can just remain constant, and so is always Local copy.

          If Local contains local shape-space geometry, then World
          will have to be updated by TTriangle.UpdateWorld whenever some octree item's
          geometry will be needed in world coords. This will have to be
          done e.g. by TBaseTrianglesOctree.XxxCollision for each returned item.)
      ) }
    Local, World: T3DTriangleGeometry;
  end;
  P3DTriangle = ^T3DTriangle;

  { Return for given Triangle do we want to ignore collisions with it.
    For now, Sender is always TTriangleOctree. }
  T3DTriangleIgnoreFunc = function (
    const Sender: TObject;
    const Triangle: P3DTriangle): boolean of object;

  { Various things that T3D.PrepareResources may prepare. }
  TPrepareResourcesOption = (prRender, prBackground, prBoundingBox,
    prTrianglesListShadowCasters,
    prManifoldAndBorderEdges,
    { Prepare octrees (determined by things like TCastleSceneCore.Spatial). }
    prSpatial,
    prScreenEffects);
  TPrepareResourcesOptions = set of TPrepareResourcesOption;

  { Shadow volumes helper, not depending on OpenGL. }
  TBaseShadowVolumeRenderer = class
  end;

  T3DListCore = class;

  { Information about ray collision with a single 3D object.
    Everything (Point, RayOrigin, RayDirection) is expressed in the
    local coordinates of given 3D object (in @link(Item)). }
  TRayCollisionNode = object
  public
    { Colliding 3D object. }
    Item: T3D;

    { Position, in local coordinate system of this 3D object,
      of the picked 3D point.

      If the ray hit empty space, this is undefined.
      Note that only MainScene is informed about pointing device events
      when the ray hit empty space. }
    Point: TVector3Single;

    { Triangle that was hit. This triangle is always a part of @link(Item).

      If the ray hit empty space, this is @nil.
      Note that only MainScene is informed about pointing device events
      when the ray hit empty space.

      May also be @nil if RayCollision for the 3D object simply left it @nil.
      Right now, only TCastleScene sets Triangle at all. }
    Triangle: P3DTriangle;

    { Ray used to cause the collision. }
    RayOrigin, RayDirection: TVector3Single;
  end;
  PRayCollisionNode = ^TRayCollisionNode;

  { Represents a collision with a 3D objects (T3D descendants) tree.

    This list is a path in the 3D objects tree leading from the
    final colliding 3D object to the root of the tree.

    For example, your 3D tree may be a list (like T3DList), and within
    this list is a transformed list (T3DTransform),
    and within is your final colliding object (like TCastleScene).
    We will contain in this case these three items, in reverse order
    (TCastleScene, T3DTransformm, T3DList).
    This allows you to track the containers that contain given collision.

    This is never an empty list when returned by RayCollision. }
  TRayCollision = class(specialize TGenericStructList<TRayCollisionNode>)
  public
    { Distance, in world coordinate system, from the current
      camera to the picked point. The suggested usage is to decide if player
      is close enough to reach the 3D object --- for example, you may not
      want to allow player to open a door by clicking on it from a far distance.

      If the ray hit empty space, the distance is MaxSingle.
      Note that only MainScene is informed about pointing device events
      when the ray hit empty space. }
    Distance: Single;

    { Index of node with given Item.
      TODO: this will be removed once we change castle to use PointingDeviceActivate
      for all. }
    function IndexOfItem(const Item: T3D): Integer;
  end;

  { Statistics about what was rendered during last frame.
    You will usually access this from @link(TCastleSceneManager.Statistics). }
  TRenderStatistics = record
    { How many shapes were rendered (send to OpenGL)
      versus all shapes that were potentially visible.
      Potentially visible shapes are the ones with
      TShape.Visible inside a 3D object with T3D.GetExists.

      When ShapesRendered is much smaller than ShapesVisible,
      it means that the algorithm for removing invisible scene parts
      works good. This includes frustum culling (automatically
      used by TCastleScene), or occlusion culling (see
      TSceneRenderingAttributes.UseOcclusionQuery),
      or any custom algorithm you implement by using TTestShapeVisibility
      callback with @link(TCastleScene.Render). }
    ShapesRendered, ShapesVisible: Cardinal;

    { The number of shapes that were not rendered,
      but their bounding box was rendered to check with occlusion query.
      This is always zero when not using occlusion query (see
      TSceneRenderingAttributes.UseOcclusionQuery).
      Basically, this measures the "invisible overhead" of occlusion query. }
    BoxesOcclusionQueriedCount: Cardinal;
  end;

  { List of lights. Always TLightInstancesList, but we cannot declare it here
    as such. }
  TAbstractLightInstancesList = TFPSList;

  TRenderingPass = 0..1;

  { Information that 3D object needs to render.
    Read-only for T3D.Render (except Statistics, which should be updated
    by T3D.Render). }
  TRenderParams = class
    { Which parts should be rendered: opaque (@false) or transparent (@true). }
    Transparent: boolean;

    { Should we render parts that may receive shadow volumes, or ones that don't.
      During rendering, simply check does it match TCastleScene.ReceiveShadowVolumes. }
    ShadowVolumesReceivers: boolean;

    { If @true, means that we're using multi-pass
      shadowing technique (like shadow volumes),
      and currently doing the "shadowed" pass.

      Which means that most lights (ones with kambiShadows = TRUE)
      should be turned off, see [http://castle-engine.sourceforge.net/x3d_extensions.php#section_ext_shadows].) }
    InShadow: boolean;

    { Value > 0 means we're inside some stencil test (like for
      InShadow = @false pass of shadow volumes). }
    StencilTest: Cardinal;

    { Rendering pass number, for multi-pass rendering, like for shadow volumes. }
    Pass: TRenderingPass;

    { Transformation that should should be applied to the rendered result.
      If RenderTransformIdentity, then RenderTransform is always identity.
      @groupBegin }
    RenderTransform: TMatrix4Single;
    RenderTransformIdentity: boolean;
    { @groupEnd }

    Statistics: TRenderStatistics;

    constructor Create;

    { Lights that shine on given 3D object. }
    function BaseLights(Scene: T3D): TAbstractLightInstancesList; virtual; abstract;
  end;

  TRemoveType = (rtNone, rtRemove, rtRemoveAndFree);

  { Base 3D object, that can be managed by TCastleSceneManager.
    All 3D objects should descend from this, this way we can easily
    insert them into the TCastleSceneManager.

    Default implementations of collision methods in this class work
    with our BoundingBox:

    @unorderedList(
      @item(Wall-sliding MoveAllowed version simply calls
        non-wall-sliding version (without separate ProposedNewPos
        and NewPos).)
      @item(Non-wall-sliding MoveAllowed version uses SegmentCollision,
        SphereCollision and BoxCollision.)
      @item(SegmentCollision, SphereCollision, BoxCollision and RayCollision
        and GetHeightAbove check for collisions with our BoundingBox,
        using TBox3D methods:
        @link(TBox3D.TryRayEntrance),
        @link(TBox3D.SegmentCollision),
        @link(TBox3D.SphereCollision) and
        @link(TBox3D.BoxCollision).)
    )

    The idea is that by default everything simple uses BoundingBox,
    and that is the only method that you really @italic(have) to override.
    You do not have to (in fact, often you should not) call "inherited"
    when overriding collision methods mentioned above. }
  T3D = class(TComponent)
  private
    FCastShadowVolumes: boolean;
    FExists: boolean;
    FCollides: boolean;
    FOnVisibleChangeHere: TVisibleChangeEvent;
    FCursor: TMouseCursor;
    FOnCursorChange: TNotifyEvent;
    FPushable: boolean;
    Disabled: Cardinal;
    procedure SetCursor(const Value: TMouseCursor);
  protected
    { In T3D class, just calls OnCursorChange event. }
    procedure CursorChange; virtual;
    { Return whether item really exists, see @link(Exists) and @link(Enable),
      @link(Disable).
      It T3D class, returns @true if @link(Exists) and not disabled.
      May be modified in subclasses, to return something more complicated. }
    function GetExists: boolean; virtual;
    { Return whether item really exists, see @link(Collides).
      It T3D class, returns @link(Collides) and @link(GetExists).
      May be modified in subclasses, to return something more complicated. }
    function GetCollides: boolean; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Is this object visible and colliding.

      Setting this to @false pretty much turns everything of this 3D object
      to "off". This is useful for objects that disappear completely from
      the level when something happens. You could just as well remove
      this object from TCastleSceneManager.Items tree, but sometimes it's more
      comfortable to simply turn this property to @false.

      Descendants may also override GetExists method.

      @noAutoLinkHere }
    property Exists: boolean read FExists write FExists default true;

    { Items that are at least once disabled are treated like not existing.
      Every @link(Disable) call should always be paired with @link(Enable) call
      (usually using @code(try ... finally .... end) block).
      Internally, we keep a counter of how many times the object is disabled,
      and if this counter is <> 0 then GetExists returns @false.
      Using this is useful for taming collisions, especially to avoid self-collisions
      (when a creature moves, it doesn't want to collide with other creatures,
      but obviously it doesn't collide with it's own bounding volume).
      @groupBegin }
    procedure Disable;
    procedure Enable;
    { @groupEnd }

    { Should this 3D object participate in collision detection.
      You can turn this off, useful to make e.g. "fake" walls
      (to some secret places on level).

      This describes collision resolution with everything --- camera,
      player (in third-person perspective, camera may differ from player),
      other creatures, other level parts. That is because everything
      resolves collisions through our methods MoveAllowed and GetHeightAbove
      (high-level) or SegmentCollision, SphereCollision, BoxCollision
      (low-level). (Note that RayCollision is excluded from this,
      it exceptionally ignores Collides value, as it's primarily used for picking.)

      Note that if not @link(Exists) then this doesn't matter
      (not existing objects never participate in collision detection).

      Descendants may also override GetCollides method. Sometimes it's more
      comfortable than changing the property value.

      @noAutoLinkHere }
    property Collides: boolean read FCollides write FCollides default true;

    { Bounding box of the 3D object.

      Should take into account both collidable and visible objects.
      For examples, invisible walls (not visible) and fake walls (not collidable)
      should all be accounted here.

      As it's a @italic(bounding) volume, it may naturally be slightly too large
      (although, for the same of various optimizations, you should try
      to make it as tight as reasonably possible.) For now, it's also OK
      to make it a little too small (nothing bad will happen).
      Although all currently implemented descendants (TCastleSceneCore, TCastlePrecalculatedAnimationCore,
      more) guarantee it's never too small. }
    function BoundingBox: TBox3D; virtual; abstract;

    { Render given object.
      Should check and immediately exit when @link(Exists) is @false.
      Should render only parts with matching Params.Transparency
      and Params.ShadowVolumesReceivers values (it may be called
      more than once to render frame).

      @param(Frustum May be used to optimize rendering, to not
        render the parts outside the Frustum.)

      @param(Params Other parameters helpful for rendering.)
    }
    procedure Render(const Frustum: TFrustum; const Params: TRenderParams); virtual;

    { Does the 3D object cast shadows by shadow volumes.
      See also TCastleScene.ReceiveShadowVolumes. }
    property CastShadowVolumes: boolean
      read FCastShadowVolumes write FCastShadowVolumes default true;

    { Render shadow quads for all the things rendered by @link(Render).
      This is done only if @link(Exists) and @link(CastShadowVolumes).

      It does shadow volumes culling inside (so ShadowVolumeRenderer should
      have FrustumCullingInit already initialized).

      ParentTransform and ParentTransformIsIdentity describe the transformation
      of this object in the 3D world.
      T3D objects may be organized in a hierarchy when
      parent transforms it's children. When ParentTransformIsIdentity,
      ParentTransform must be IdentityMatrix4Single (it's not guaranteed
      that when ParentTransformIsIdentity = @true, Transform value will be
      ignored !).

      @italic(Implementation note:) In @link(Render), it is usually possible
      to implement ParentTransform* by glPush/PopMatrix and Frustum.Move tricks.
      But RenderShadowVolume needs actual transformation explicitly:
      ShadowMaybeVisible needs actual box position in world coordinates,
      so bounding box has to be transformed by ParentTransform.
      And TCastleScene.RenderShadowVolumeCore needs explicit ParentTransform
      to correctly detect front/back sides (for silhouette edges and
      volume capping). }
    procedure RenderShadowVolume(
      ShadowVolumeRenderer: TBaseShadowVolumeRenderer;
      const ParentTransformIsIdentity: boolean;
      const ParentTransform: TMatrix4Single); virtual;

    { Prepare resources, making various methods (like rendering and such)
      to execute fast.

      This makes sure that appropriate methods execute as fast as possible.
      It's never required to call this method
      --- everything will be prepared "as needed" anyway.
      But if you allow everything to be prepared "as needed",
      then e.g. the first @link(Render) call may take a long time because it may
      have to prepare resources that will be reused in next @link(Render) calls.
      This is bad, as your program will seem very slow at the beginning
      (when rendering resources are prepared, so a first frame,
      or a couple of first frames, if it's something
      like a precalculated animation). To avoid this, call this method,
      showing the user something like "now we're preparing
      the resources --- please wait".

      For OpenGL rendered objects, this method ties this object
      to the current OpenGL context.
      But it doesn't change any OpenGL state or buffers contents
      (at most, it allocates some texture and display list names).

      @param(Options What features should be prepared to execute fast.
        See TPrepareResourcesOption,
        the names should be self-explanatory (they refer to appropriate
        methods of T3D, TCastleSceneCore or TCastleScene).)

      @param(ProgressStep Says that we should make Progress.Step calls
        (exactly PrepareResourcesSteps times) during preparation.
        Useful to show progress bar to the user during long preparation.

        TODO: for now, do not include prSpatial if you use ProgressStep.
        Reason: octree preparations have a separate mechanism
        that may want to show progress.)

      @param(BaseLights Used if Options contains prRender.
        A list of base lights (always TLightInstancesList, although
        cannot be declated as such) used for rendering.
        May be @nil (equivalent to empty).) }
    procedure PrepareResources(
      Options: TPrepareResourcesOptions;
      ProgressStep: boolean;
      BaseLights: TAbstractLightInstancesList); virtual;

    { How many times PrepareResources will call Progress.Step.
      Useful only if you want to pass ProgressStep = @true to PrepareResources.
      In the base class T3D this just returns 0.  }
    function PrepareResourcesSteps: Cardinal; virtual;

    { Key events. Return @true if you handled them.
      See also TUIControl analogous events.
      @groupBegin }
    function KeyDown(Key: TKey; C: char): boolean; virtual;
    function KeyUp(Key: TKey; C: char): boolean; virtual;
    { @groupEnd }

    { Pointing device (usually mouse) events.
      Return @true if you handled the event.

      @unorderedList(
        @item(PointingDeviceActivate signals that the picking button (usually,
          left mouse button) is pressed or released (depending on Active parameter).)

        @item(PointingDeviceMove signals that pointer moves over this 3D object.)
      )

      PointingDeviceMove receives Pick information about what exactly is hit
      by the 3D ray corresponding to the current mouse position.
      It contains the detailed information about 3D point, triangle
      and ray (all in local coordinate system) that are indicated by the mouse.
      PointingDeviceActivate does not receive this information now
      (because it may happen in obscure situations when ray direction is not known;
      this is all related to our "fallback to MainScene" mechanism).

      They also receive Distance to the collision,
      in world coordinates. See TRayCollision.Distance.

      The pointing device event (activation,
      deactivation or move) is send first to the innermost 3D object.
      That is, we first send this event to the first item on
      TRayCollision list corresponding to the current ray.
      This way, the innermost ("most local") 3D object has the chance
      to handle this event first. If the event is not handled, it is passed
      to other 3D objects (we simply iterate over the TRayCollision list).
      If nothing on TRayCollision list
      handled the item, it is eventually passed to main 3D scene
      (TCastleSceneManager.MainScene), if it wasn't already present on
      TRayCollision list.

      Note that when passing this event to TCastleSceneManager.MainScene,
      it is possible that 3D ray simply didn't hit anything (mouse pointer
      is over the background). In this case, TRayCollisionNode.Point
      is undefined, TRayCollisionNode.Triangle is @nil
      and Distance is MaxSingle.

      This event should be handled only if GetExists.
      Usually, 3D objects with GetExists = @false will not be returned
      by RayCollision, so they will not receive this event anyway.
      However, if 3D object may be equal to TCastleSceneManager.MainScene,
      then it should be secured and check for GetExists
      inside PointingDeviceActivate and PointingDeviceMove.

      @groupBegin }
    function PointingDeviceActivate(const Active: boolean;
      const Distance: Single): boolean; virtual;
    function PointingDeviceMove(const Pick: TRayCollisionNode;
      const Distance: Single): boolean; virtual;
    { @groupEnd }

    { Idle event, for various continously repeated tasks.
      @param(RemoveMe Set this to rtRemove or rtRemoveAndFree to remove
        this item from 3D world (parent list) after Idle finished.
        rtRemoveAndFree additionally will free this item.
        Initially it's rtNone when this method is called.) }
    procedure Idle(const CompSpeed: Single; var RemoveMe: TRemoveType); virtual;

    { Something visible changed inside @italic(this) 3D object.
      This is usually called by implementation of this 3D object,
      to notify others that it changed.

      Changes is a set describing what changes occurred.
      It can be [], meaning "something else", we'll
      still make OnVisibleChangeHere then. See TVisibleChange
      docs for possible values. It must specify all things that possibly
      changed.

      The information about visibility changed is usually passed upward,
      to the TCastleSceneManager, that broadcasts this to all 3D objects
      by VisibleChangeNotification. If you want to @italic(react) to visibility
      changes, you usually should override VisibleChangeNotification,
      not this method.

      In this class this simply calls OnVisibleChangeHere (if assigned). }
    procedure VisibleChangeHere(const Changes: TVisibleChanges); virtual;

    { Called when some visible part of this control changes.
      This is usually used by the scene manager
      (to know when we need to redraw the control),
      so don't use it in your own programs directly.

      Be careful when handling this event, various changes may cause this,
      so be prepared to handle OnVisibleChangeHere at every time.

      @seealso VisibleChangeHere }
    property OnVisibleChangeHere: TVisibleChangeEvent
      read FOnVisibleChangeHere write FOnVisibleChangeHere;

    { Something visible changed in the 3D world.
      This is usually called by our container (like TCastleSceneManager),
      to allow this 3D object to react (e.g. by regenerating mirror textures)
      to changes in the 3D world (not necessarily in this 3D object,
      maybe in some other T3D instance).

      If you want to @italic(react) to visibility
      changes, you should override this. }
    procedure VisibleChangeNotification(const Changes: TVisibleChanges); virtual;

    { Mouse cursor over this object. }
    property Cursor: TMouseCursor read FCursor write SetCursor default mcDefault;

    { Called when the @link(Cursor) of this control changes.
      This is usually used by the scene manager
      (to know when we need to redraw the control),
      so don't use it in your own programs directly. }
    property OnCursorChange: TNotifyEvent
      read FOnCursorChange write FOnCursorChange;

    { Called when OpenGL context of the window is destroyed.
      This will be also automatically called from destructor.

      Control should clear here any resources that are tied to the GL context. }
    procedure GLContextClose; virtual;

    { Check height of a point (like a player camera) above the ground.
      This checks ray collision, from Position along the negated GravityUp vector.
      Measures distance to the nearest scene item (called "ground" here).

      @param(IsAbove Says if the 3D scene is hit.
        @false means that player floats above an empty space.
        That is, if you turn gravity on, the player will fall down forever,
        as far as this 3D scene is concerned.)

      @param(AboveHeight Height above the ground.
        @italic(One height unit equals one GravityUp vector).
        Always use normalized GravityUp vector if you expect
        to receive here a normal distance.

        Must be MaxSingle if IsAbove was set to @false
        (this guarantee simplifies some code).)

      @param(AboveGround Pointer to P3DTriangle representing the ground.
        Must be @nil if IsAbove was set to @false.
        @bold(May) be @nil even if IsAbove was set to @true (not all 3D
        objects may be able to generate P3DTriangle information about collision).

        This may be useful for example to make a footsteps sound dependent
        on texture of the ground.
        Or to decrease player life points for walking on hot lava.
        See "castle" for examples.)
    }
    procedure GetHeightAbove(const Position, GravityUp: TVector3Single;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc;
      out IsAbove: boolean; out AboveHeight: Single;
      out AboveGround: P3DTriangle); virtual;

    { Can other 3D object (maybe a player) move without colliding with this object.

      If IsRadius, then you should prefer to perform exact collision with sphere
      of given radius (must be > 0).
      At the very least, this checks that the line segment
      between OldPos and NewPos doesn't collide,
      @bold(and) that sphere with given Radius centered around NewPos
      doesn't collide.

      If not IsRadius, or if checking for collisions with sphere is not possible
      for some reasons, then you can check for collisions with boxes.
      OldBox should usually be ignored (it can be useful when collision-checking
      has to be approximate in some corner cases, see TCreature.MoveAllowed).
      NewBox plays the same role as "sphere centered around NewPos" in paragraph
      above.

      Overloaded version with separate ProposedNewPos and NewPos parameters
      allows you to accept the move, but for NewPos (that should be some slightly
      modified version of ProposedNewPos). This allows to implement wall-sliding:
      when camera tries to walk into the wall, we will change movement
      to move alongside the wall (instead of just completely blocking the move).
      When this version returns @false, it's undefined what is the NewPos.

      @groupBegin }
    function MoveAllowed(
      const OldPos, ProposedNewPos: TVector3Single; out NewPos: TVector3Single;
      const IsRadius: boolean; const Radius: Single;
      const OldBox, NewBox: TBox3D;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean; virtual;
    function MoveAllowed(
      const OldPos, ProposedNewPos: TVector3Single;
      const IsRadius: boolean; const Radius: Single;
      const OldBox, NewBox: TBox3D;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean; virtual;
    { @groupEnd }

    function SegmentCollision(const Pos1, Pos2: TVector3Single;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean; virtual;
    function SphereCollision(const Pos: TVector3Single; const Radius: Single;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean; virtual;
    function BoxCollision(const Box: TBox3D;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean; virtual;

    { Check collision with a ray, building a TRayCollision result.
      Returns a collision as TRayCollision instance, or @nil if no collision.
      Caller is responsible for freeing the returned TRayCollision instance.

      Contrary to other collision routines, this should @italic(ignore
      the @link(Collides) property). The @link(Collides) property
      specifies whether item collides with camera. And this method is used
      for picking (pointing) 3D stuff --- everything visible can be picked,
      collidable or not.

      This always returns the first collision with the 3D world, that is
      the one with smallest TRayCollision.Distance. For example, when
      implemented in T3DList, this checks collisions for all list items,
      and chooses the closest one. }
    function RayCollision(const RayOrigin, RayDirection: TVector3Single;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): TRayCollision; virtual;

    procedure UpdateGeneratedTextures(
      const RenderFunc: TRenderFromViewFunction;
      const ProjectionNear, ProjectionFar: Single;
      const OriginalViewportX, OriginalViewportY: LongInt;
      const OriginalViewportWidth, OriginalViewportHeight: Cardinal); virtual;

    { Are we in the middle of dragging something by moving the mouse.

      This should be set to @true to disable camera navigation
      methods that also use mouse move. In practice, to disable TExamineCamera
      view rotation/movement by moving the mouse, as it makes (comfortable)
      dragging practically impossible (at each mouse move, view changes...).

      In particular, when you operate on active X3D pointing-device sensors
      (like drag sensors, e.g. PlaneSensor, but also TouchSensor may
      use it). }
    function Dragging: boolean; virtual;

    { What happens when other 3D objects try to push this object.
      See @link(Pushable) for when it may happen.
      By default, in T3D class, this does nothing. }
    procedure Translate(const T: TVector3Single); virtual;

    { Can the approximate sphere be used for some collision-detection
      tasks. If UseSphere is @true then @link(Sphere) returns the approximate
      sphere surrounding the 3D object (it does not have to be a perfect
      bounding sphere around the object), and it may be used for some
      collisions instead of BoundingBox.
      See @link(Pushable) for when it may happen.

      UseSphere must be @false when not GetExists (because we can't express
      "empty sphere" by @link(Sphere) method for now, but BoundingBox can express
      EmptyBox3D).

      By default, in T3D class, this always returns @false
      and @link(Sphere) is undefined.

      @groupBegin }
    function UseSphere: boolean; virtual;
    procedure Sphere(out Center: TVector3Single; out Radius: Single); virtual;
    { @groupEnd }

    { Can this object be pushed (or may block movement of) doors, elevators
      and other such features. This specifies how moving level parts
      (T3DMoving instances --- doors, elevators and such) interact with this item.

      Some 3D moving objects may try to not crush this item. Like an automatic
      door that stops it's closing animation to not crush things standing
      in the doorway.

      Some other 3D moving objects may transport this object.
      Like elevators (vertical, or horizontal moving platforms).
      We may use sphere (see @link(T3D.UseSphere), @link(T3D.Sphere)) for checking
      collisions, or bounding box (@link(T3D.BoundingBox)), depending on need.
      The item is moved using @link(T3D.Translate), so make sure it
      actually does something (for example, by descending from T3DTransform,
      that provides natural @link(T3D.Translate) implementation). }
    property Pushable: boolean read FPushable write FPushable default false;
  end;

  T3DList = class;

  { List of base 3D objects (T3D instances).
    This allows you to group many 3D objects, and treat them as one T3D
    descendant.

    This inherits from TCastleObjectList, getting many
    features like TList notification mechanism (useful in some situations).
    Usually you want to use T3DList instead, which is a wrapper around
    this class. }
  T3DListCore = class(TCastleObjectList)
  private
    FOwner: T3DList;

    function GetItem(const I: Integer): T3D;
    procedure SetItem(const I: Integer; const Item: T3D);
  public
    constructor Create(const FreeObjects: boolean; const AOwner: T3DList);
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    property Items[I: Integer]: T3D read GetItem write SetItem; default;

    function First: T3D;
    function Last: T3D;

    { T3DList instance that owns this list.
      May be @nil, for example when this list is used by TRayCollision. }
    property Owner: T3DList read FOwner;
  end;

  { List of base 3D objects (T3D instances).

    This inherits from T3D class, so this list is itself a 3D object:
    it's a sum of all it's children 3D objects. }
  T3DList = class(T3D)
  private
    FList: T3DListCore;
    procedure ListVisibleChange(Sender: T3D; Changes: TVisibleChanges);
    procedure ListCursorChange(Sender: TObject);
    function GetItem(const I: Integer): T3D;
    procedure SetItem(const I: Integer; const Item: T3D);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Operate on 3D objects contained in the list.
      You can also operate directly on @link(List) instance.
      @groupBegin }
    procedure Add(const Item: T3D);
    procedure Remove(const Item: T3D);
    property Items[I: Integer]: T3D read GetItem write SetItem; default;
    function Count: Integer;
    procedure Clear;
    { @groupEnd }

    function BoundingBox: TBox3D; override;
    procedure Render(const Frustum: TFrustum; const Params: TRenderParams); override;
    procedure RenderShadowVolume(
      ShadowVolumeRenderer: TBaseShadowVolumeRenderer;
      const ParentTransformIsIdentity: boolean;
      const ParentTransform: TMatrix4Single); override;
    procedure PrepareResources(
      Options: TPrepareResourcesOptions;
      ProgressStep: boolean;
      BaseLights: TAbstractLightInstancesList); override;
    function PrepareResourcesSteps: Cardinal; override;
    function KeyDown(Key: TKey; C: char): boolean; override;
    function KeyUp(Key: TKey; C: char): boolean; override;
    procedure Idle(const CompSpeed: Single; var RemoveMe: TRemoveType); override;
    procedure GLContextClose; override;
    procedure GetHeightAbove(const Position, GravityUp: TVector3Single;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc;
      out IsAbove: boolean; out AboveHeight: Single;
      out AboveGround: P3DTriangle); override;
    function MoveAllowed(
      const OldPos, ProposedNewPos: TVector3Single; out NewPos: TVector3Single;
      const IsRadius: boolean; const Radius: Single;
      const OldBox, NewBox: TBox3D;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean; override;
    function MoveAllowed(
      const OldPos, NewPos: TVector3Single;
      const IsRadius: boolean; const Radius: Single;
      const OldBox, NewBox: TBox3D;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean; override;
    function SegmentCollision(const Pos1, Pos2: TVector3Single;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean; override;
    function SphereCollision(const Pos: TVector3Single; const Radius: Single;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean; override;
    function BoxCollision(const Box: TBox3D;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean; override;
    function RayCollision(const RayOrigin, RayDirection: TVector3Single;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): TRayCollision; override;
    procedure UpdateGeneratedTextures(
      const RenderFunc: TRenderFromViewFunction;
      const ProjectionNear, ProjectionFar: Single;
      const OriginalViewportX, OriginalViewportY: LongInt;
      const OriginalViewportWidth, OriginalViewportHeight: Cardinal); override;
    procedure VisibleChangeNotification(const Changes: TVisibleChanges); override;
    function Dragging: boolean; override;
  published
    { 3D objects inside.
      Freeing these items automatically removes them from this list. }
    property List: T3DListCore read FList;
  end;

  { Transform (move, rotate, scale) other T3D objects.
    Descends from T3DList, transforming all it's children.

    Actual transformation is defined by virtual methods like GetTranslation,
    GetRotation and such. In this class they return zeros, and in practice
    (at least some of them) have to be overridden for this class to make sense.
    Use T3DTransform to have simple T3DTransform.Translation and such properties. }
  T3DCustomTransform = class(T3DList)
  protected
    function GetTranslation: TVector3Single; virtual;
    function GetCenter: TVector3Single; virtual;
    function GetRotation: TVector4Single; virtual;
    function GetScale: TVector3Single; virtual;
    function GetScaleOrientation: TVector4Single; virtual;
    { Can we use simple GetTranslation instead of full TransformMatricesMult.
       @true, this allows optimization is some cases. }
    function OnlyTranslation: boolean; virtual;
    function Transform: TMatrix4Single;
    function TransformInverse: TMatrix4Single;

    { Transformation matrix.
      You can override this to derive transformation using anything,
      not necessarily GetTranslation / GetCenter etc. methods.

      This method must produce matrices that preserve points as points
      and directions as directions in homegeneous space.
      In other words, using MatrixMultPoint or MatrixMultDirection
      with these matrices must never raise ETransformedResultInvalid.
      For example, a combination of translations, rotations, scaling is Ok. }
    procedure TransformMatricesMult(var M, MInverse: TMatrix4Single); virtual;
    procedure TransformMatrices(out M, MInverse: TMatrix4Single);
    function AverageScale: Single;
  public
    function BoundingBox: TBox3D; override;
    procedure Render(const Frustum: TFrustum; const Params: TRenderParams); override;
    procedure RenderShadowVolume(
      ShadowVolumeRenderer: TBaseShadowVolumeRenderer;
      const ParentTransformIsIdentity: boolean;
      const ParentTransform: TMatrix4Single); override;
    procedure GetHeightAbove(const Position, GravityUp: TVector3Single;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc;
      out IsAbove: boolean; out AboveHeight: Single;
      out AboveGround: P3DTriangle); override;
    function MoveAllowed(
      const OldPos, ProposedNewPos: TVector3Single; out NewPos: TVector3Single;
      const IsRadius: boolean; const Radius: Single;
      const OldBox, NewBox: TBox3D;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean; override;
    function MoveAllowed(
      const OldPos, NewPos: TVector3Single;
      const IsRadius: boolean; const Radius: Single;
      const OldBox, NewBox: TBox3D;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean; override;
    function SegmentCollision(const Pos1, Pos2: TVector3Single;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean; override;
    function SphereCollision(const Pos: TVector3Single; const Radius: Single;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean; override;
    function BoxCollision(const Box: TBox3D;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean; override;
    function RayCollision(const RayOrigin, RayDirection: TVector3Single;
      const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): TRayCollision; override;
  end;

  { Transform (move, rotate, scale) other T3D objects.
    Descends from T3DList, transforming all it's children.
    Defines simple properties like @link(Translation). }
  T3DTransform = class(T3DCustomTransform)
  private
    FCenter: TVector3Single;
    FRotation: TVector4Single;
    FScale: TVector3Single;
    FScaleOrientation: TVector4Single;
    FTranslation: TVector3Single;
    FOnlyTranslation: boolean;
  protected
    procedure SetCenter(const Value: TVector3Single);
    procedure SetRotation(const Value: TVector4Single);
    procedure SetScale(const Value: TVector3Single);
    procedure SetScaleOrientation(const Value: TVector4Single);

    function OnlyTranslation: boolean; override;

    function GetCenter: TVector3Single; override;
    function GetRotation: TVector4Single; override;
    function GetScale: TVector3Single; override;
    function GetScaleOrientation: TVector4Single; override;
    function GetTranslation: TVector3Single; override;
  public
    constructor Create(AOwner: TComponent); override;

    { Transformation is a combined Translation, and Rotation around Center point,
      and Scale around Center and with orientation given by ScaleOrientation.
      For precise order of these operations, see X3D Transform node.

      Default values of these fields indicate no transformation.
      So everything is zero, except Scale which is (1,1,1).
      Scale must always have all components > 0 (some operations depend
      that scale here is invertible and doesn't flip sides).
      Non-uniform scale (e.g. when you scale along X coordinate 2 times,
      but you scale along Y coordinate 3 times) works... to some extent,
      that is collisions with spheres (including camera radius) are not perfect
      in this case. For perfect results, keep your scale uniform.

      @groupBegin }
    property Center: TVector3Single read FCenter write SetCenter;
    property Rotation: TVector4Single read FRotation write SetRotation;
    property Scale: TVector3Single read FScale write SetScale;
    property ScaleOrientation: TVector4Single read FScaleOrientation write SetScaleOrientation;
    property Translation: TVector3Single read FTranslation write FTranslation;
    { @groupEnd }

    procedure Translate(const T: TVector3Single); override;
  end;

  { Deprecated name for T3DCustomTransform. @deprecated @exclude }
  T3DCustomTranslated = T3DCustomTransform;

  { Deprecated name for T3DTransform. @deprecated @exclude }
  T3DTranslated = T3DTransform;

const
  MaxSingle = Math.MaxSingle;

{ Apply transformation to a matrix.
  Calculates at the same time transformation matrix, and it's inverse,
  and multiplies given Transform, TransformInverse appropriately.
  The precise meaning of Center, Translation and such parameters
  follows exactly the X3D Transform node definition. }
procedure TransformMatricesMult(var Transform, TransformInverse: TMatrix4Single;
  const Center: TVector3Single;
  const Rotation: TVector4Single;
  const Scale: TVector3Single;
  const ScaleOrientation: TVector4Single;
  const Translation: TVector3Single);

implementation

uses SysUtils;

{ T3DTriangle  --------------------------------------------------------------- }

constructor T3DTriangle.Init(const ATriangle: TTriangle3Single);
begin
  Local.Triangle := ATriangle;
  Local.Plane := TriangleNormPlane(ATriangle);
  Local.Area := TriangleArea(ATriangle);

  World := Local;
end;

{ TRayCollision --------------------------------------------------------------- }

function TRayCollision.IndexOfItem(const Item: T3D): Integer;
begin
  for Result := 0 to Count - 1 do
    if L[Result].Item = Item then Exit;
  Result := -1;
end;

{ TRenderParams -------------------------------------------------------------- }

constructor TRenderParams.Create;
begin
  inherited;
  RenderTransform := IdentityMatrix4Single;
  RenderTransformIdentity := true;
end;

{ T3D -------------------------------------------------------------------- }

constructor T3D.Create(AOwner: TComponent);
begin
  inherited;
  FCastShadowVolumes := true;
  FExists := true;
  FCollides := true;
  FCursor := mcDefault;
end;

destructor T3D.Destroy;
begin
  GLContextClose;
  inherited;
end;

procedure T3D.Render(const Frustum: TFrustum; const Params: TRenderParams);
begin
end;

procedure T3D.RenderShadowVolume(
  ShadowVolumeRenderer: TBaseShadowVolumeRenderer;
  const ParentTransformIsIdentity: boolean;
  const ParentTransform: TMatrix4Single);
begin
end;

procedure T3D.PrepareResources(Options: TPrepareResourcesOptions;
  ProgressStep: boolean; BaseLights: TAbstractLightInstancesList);
begin
end;

function T3D.PrepareResourcesSteps: Cardinal;
begin
  Result := 0;
end;

function T3D.KeyDown(Key: TKey; C: char): boolean;
begin
  Result := false;
end;

function T3D.KeyUp(Key: TKey; C: char): boolean;
begin
  Result := false;
end;

function T3D.PointingDeviceActivate(const Active: boolean;
  const Distance: Single): boolean;
begin
  Result := false;
end;

function T3D.PointingDeviceMove(const Pick: TRayCollisionNode;
  const Distance: Single): boolean;
begin
  Result := false;
end;

procedure T3D.Idle(const CompSpeed: Single; var RemoveMe: TRemoveType);
begin
end;

procedure T3D.VisibleChangeHere(const Changes: TVisibleChanges);
begin
  if Assigned(OnVisibleChangeHere) then
    OnVisibleChangeHere(Self, Changes);
end;

procedure T3D.VisibleChangeNotification(const Changes: TVisibleChanges);
begin
end;

procedure T3D.SetCursor(const Value: TMouseCursor);
begin
  if FCursor <> Value then
  begin
    FCursor := Value;
    CursorChange;
  end;
end;

procedure T3D.CursorChange;
begin
  if Assigned(OnCursorChange) then OnCursorChange(Self);
end;

procedure T3D.GLContextClose;
begin
end;

procedure T3D.GetHeightAbove(const Position, GravityUp: TVector3Single;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc;
  out IsAbove: boolean; out AboveHeight: Single;
  out AboveGround: P3DTriangle);
var
  Intersection: TVector3Single;
  IntersectionDistance: Single;
begin
  IsAbove := false;
  AboveHeight := MaxSingle;
  AboveGround := nil;

  if GetCollides and
    BoundingBox.TryRayEntrance(Intersection, IntersectionDistance, Position, -GravityUp) then
  begin
    IsAbove := true;
    AboveHeight := IntersectionDistance;
  end;
end;

function T3D.MoveAllowed(
  const OldPos, ProposedNewPos: TVector3Single; out NewPos: TVector3Single;
  const IsRadius: boolean; const Radius: Single;
  const OldBox, NewBox: TBox3D;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean;
begin
  { A simple implementation, just don't do wall-sliding. }
  Result := MoveAllowed(OldPos, ProposedNewPos, IsRadius, Radius, OldBox, NewBox,
    TrianglesToIgnoreFunc);
  if Result then
    NewPos := ProposedNewPos;
end;

function T3D.MoveAllowed(
  const OldPos, ProposedNewPos: TVector3Single;
  const IsRadius: boolean; const Radius: Single;
  const OldBox, NewBox: TBox3D;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean;
begin
  if IsRadius then
    Result := not ( GetCollides and
      ( SegmentCollision(OldPos, ProposedNewPos, TrianglesToIgnoreFunc) or
        SphereCollision(ProposedNewPos, Radius, TrianglesToIgnoreFunc) ) ) else
    Result := not ( GetCollides and
      ( SegmentCollision(OldPos, ProposedNewPos, TrianglesToIgnoreFunc) or
        BoxCollision(NewBox, TrianglesToIgnoreFunc) ) );
end;

function T3D.SegmentCollision(const Pos1, Pos2: TVector3Single;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean;
begin
  Result := GetCollides and BoundingBox.SegmentCollision(Pos1, Pos2);
end;

function T3D.SphereCollision(const Pos: TVector3Single; const Radius: Single;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean;
begin
  Result := GetCollides and BoundingBox.SphereCollision(Pos, Radius);
end;

function T3D.BoxCollision(const Box: TBox3D;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean;
begin
  Result := GetCollides and BoundingBox.Collision(Box);
end;

function T3D.RayCollision(const RayOrigin, RayDirection: TVector3Single;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): TRayCollision;
var
  Intersection: TVector3Single;
  IntersectionDistance: Single;
  NewNode: PRayCollisionNode;
begin
  if GetExists and
    BoundingBox.TryRayEntrance(Intersection, IntersectionDistance, RayOrigin, RayDirection) then
  begin
    Result := TRayCollision.Create;
    Result.Distance := IntersectionDistance;

    NewNode := Result.Add;
    NewNode^.Item := Self;
    NewNode^.Point := Intersection;
    { better T3D implementation could assign here something nice to NewNode^.Triangle,
      to inform T3D.PointingDeviceMove/Activate about the intersected material. }
    NewNode^.Triangle := nil;
    NewNode^.RayOrigin := RayOrigin;
    NewNode^.RayDirection := RayDirection;
  end else
    Result := nil;
end;

procedure T3D.UpdateGeneratedTextures(
  const RenderFunc: TRenderFromViewFunction;
  const ProjectionNear, ProjectionFar: Single;
  const OriginalViewportX, OriginalViewportY: LongInt;
  const OriginalViewportWidth, OriginalViewportHeight: Cardinal);
begin
end;

function T3D.Dragging: boolean;
begin
  Result := false;
end;

function T3D.GetExists: boolean;
begin
  Result := FExists and (Disabled = 0);
end;

function T3D.GetCollides: boolean;
begin
  Result := FCollides and GetExists;
end;

procedure T3D.Translate(const T: TVector3Single);
begin
end;

function T3D.UseSphere: boolean;
begin
  Result := false;
end;

procedure T3D.Sphere(out Center: TVector3Single; out Radius: Single);
begin
  Center := ZeroVector3Single;
  Radius := 0;
end;

procedure T3D.Disable;
begin
  Inc(Disabled);
end;

procedure T3D.Enable;
begin
  Dec(Disabled);
end;

{ T3DListCore ------------------------------------------------------------ }

constructor T3DListCore.Create(const FreeObjects: boolean; const AOwner: T3DList);
begin
  inherited Create(FreeObjects);
  FOwner := AOwner;
end;

procedure T3DListCore.Notify(Ptr: Pointer; Action: TListNotification);
var
  B: T3D;
begin
  inherited;

  if Owner <> nil then
  begin
    B := T3D(Ptr);

    case Action of
      lnAdded:
        begin
          { Make sure Owner.ListVisibleChange will be called
            when an item calls OnVisibleChangeHere. }
          if B.OnVisibleChangeHere = nil then
            B.OnVisibleChangeHere := @Owner.ListVisibleChange;
          if B.OnCursorChange = nil then
            B.OnCursorChange := @Owner.ListCursorChange;

          { Register Owner to be notified of item destruction. }
          B.FreeNotification(Owner);
        end;
      lnExtracted, lnDeleted:
        begin
          if B.OnVisibleChangeHere = @Owner.ListVisibleChange then
            B.OnVisibleChangeHere := nil;
          if B.OnCursorChange = @Owner.ListCursorChange then
            B.OnCursorChange := nil;

          B.RemoveFreeNotification(Owner);
        end;
      else raise EInternalError.Create('T3DListCore.Notify action?');
    end;

    { This notification may get called during FreeAndNil(FList)
      in T3DList.Destroy. Then FList is already nil (as FreeAndNil
      first sets object to nil), and Owner.ListCursorChange
      may not be ready for this. }
    if Owner.FList <> nil then
      Owner.ListCursorChange(nil);
  end;
end;

function T3DListCore.GetItem(const I: Integer): T3D;
begin
  Result := T3D(inherited Items[I]);
end;

procedure T3DListCore.SetItem(const I: Integer; const Item: T3D);
begin
  inherited Items[I] := Item;
end;

function T3DListCore.First: T3D;
begin
  Result := (inherited First) as T3D;
end;

function T3DListCore.Last: T3D;
begin
  Result := (inherited Last) as T3D;
end;

{ T3DList ---------------------------------------------------------------- }

constructor T3DList.Create(AOwner: TComponent);
begin
  inherited;
  FList := T3DListCore.Create(false, Self);
end;

destructor T3DList.Destroy;
begin
  FreeAndNil(FList);
  inherited;
end;

procedure T3DList.Add(const Item: T3D);
begin
  List.Add(Item);
end;

function T3DList.GetItem(const I: Integer): T3D;
begin
  Result := List[I];
end;

procedure T3DList.SetItem(const I: Integer; const Item: T3D);
begin
  List[I] := Item;
end;

function T3DList.Count: Integer;
begin
  Result := List.Count;
end;

procedure T3DList.Remove(const Item: T3D);
begin
  List.Remove(Item);
end;

procedure T3DList.Clear;
begin
  List.Clear;
end;

function T3DList.BoundingBox: TBox3D;
var
  I: Integer;
begin
  Result := EmptyBox3D;
  if GetExists then
    for I := 0 to List.Count - 1 do
      Result.Add(List[I].BoundingBox);
end;

procedure T3DList.Render(const Frustum: TFrustum; const Params: TRenderParams);
var
  I: Integer;
begin
  inherited;
  if GetExists then
    for I := 0 to List.Count - 1 do
      List[I].Render(Frustum, Params);
end;

procedure T3DList.RenderShadowVolume(
  ShadowVolumeRenderer: TBaseShadowVolumeRenderer;
  const ParentTransformIsIdentity: boolean;
  const ParentTransform: TMatrix4Single);
var
  I: Integer;
begin
  inherited;
  if GetExists and CastShadowVolumes then
    for I := 0 to List.Count - 1 do
      List[I].RenderShadowVolume(ShadowVolumeRenderer,
        ParentTransformIsIdentity, ParentTransform);
end;

procedure T3DList.PrepareResources(Options: TPrepareResourcesOptions;
  ProgressStep: boolean; BaseLights: TAbstractLightInstancesList);
var
  I: Integer;
begin
  inherited;
  for I := 0 to List.Count - 1 do
    List[I].PrepareResources(Options, ProgressStep, BaseLights);
end;

function T3DList.PrepareResourcesSteps: Cardinal;
var
  I: Integer;
begin
  Result := inherited;
  for I := 0 to List.Count - 1 do
    Result += List[I].PrepareResourcesSteps;
end;

function T3DList.KeyDown(Key: TKey; C: char): boolean;
var
  I: Integer;
begin
  Result := inherited;
  if Result or (not GetExists) then Exit;

  for I := 0 to List.Count - 1 do
    if List[I].KeyDown(Key, C) then Exit(true);
end;

function T3DList.KeyUp(Key: TKey; C: char): boolean;
var
  I: Integer;
begin
  Result := inherited;
  if Result or (not GetExists) then Exit;

  for I := 0 to List.Count - 1 do
    if List[I].KeyUp(Key, C) then Exit(true);
end;

procedure T3DList.Idle(const CompSpeed: Single; var RemoveMe: TRemoveType);
var
  I: Integer;
  Item: T3D;
  RemoveItem: TRemoveType;
begin
  inherited;
  if GetExists then
  begin
    I := 0;
    while I < List.Count do
    begin
      Item := List[I];
      RemoveItem := rtNone;
      Item.Idle(CompSpeed, RemoveItem);
      if RemoveItem in [rtRemove, rtRemoveAndFree] then
      begin
        List.Delete(I);
        if RemoveItem = rtRemoveAndFree then
          FreeAndNil(Item);
      end else
        Inc(I);
    end;
  end;
end;

procedure T3DList.ListVisibleChange(Sender: T3D; Changes: TVisibleChanges);
begin
  { when an Item calls OnVisibleChangeHere, we'll call our own OnVisibleChangeHere,
    to pass it up the tree (eventually, to the scenemanager, that will
    pass it by TUIControl similar OnVisibleChangeHere mechanism to the container). }
  VisibleChangeHere(Changes);
end;

procedure T3DList.ListCursorChange(Sender: TObject);
begin
  { when an Item calls OnCursorChange, we'll call our own OnCursorChange,
    to pass it up the tree (eventually, to the scenemanager, that will
    pass it by TUIControl similar OnCursorChange mechanism to the container). }

  { Open question: alternatively, instead of directly sending CursorChange,
    we could update our own cursor (thus indirectly (possibly) generating
    OnCursorChange), and let scene manager to take cursor from
    MouseRayHit.Last.Item.Cursor.

    Right now, scene manager takes cursor from MouseRayHit.First.Item.Cursor,
    and pretty much ignores Cursor value of 3d stuff along
    the MouseRayHit list.

    This is undecided yet, I currently don't see any compelling reason
    for one or the other behavior. }

  CursorChange;
end;

procedure T3DList.GLContextClose;
var
  I: Integer;
begin
  { this is called from inherited destructor, so check <> nil carefully }
  if FList <> nil then
  begin
    for I := 0 to List.Count - 1 do
      List[I].GLContextClose;
  end;

  inherited;
end;

procedure T3DList.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;

  { We have to remove a reference to the object from the List.
    This is crucial: T3DListCore.Notify,
    and e.g. GLContextClose call, assume that all objects on
    the List are always valid objects (no invalid references,
    even for a short time). }

  { About List <> nil check:

    How situation with List = nil may happen? When our List is destroyed,
    it calls B.FreeNotification on all it's items, so it (falsely) seems we will
    not get any more notifications.

    It turns out that we may get notifications,
    and they are notifications about our own destruction (AComponent = Self).
    That is because TComponent.Notification passes down the notification to
    all it's FComponents, that is rtl/objpas/classes/compon.inc
    (in FPC sources) contains code

    Procedure TComponent.Notification(AComponent: TComponent; Operation: TOperation);
    begin
      ...
      For Runner:=0 To FComponents.Count-1 do
        TComponent(FComponents.Items[Runner]).Notification(AComponent,Operation);
    end;

    And FComponents contain all components that are owned.
    So we are informed when something is removed from the owner,
    including about our own removal. (And in this case, we are a T3D descendant
    ourselves, just like our children; so check "AComponent is T3D" doesn't
    protect us.)
    Practical situation when it happens is in testcases
    TTestBase3D.TestNotifications and TTestBase3D.TestNotificationsSceneManager. }

  if (Operation = opRemove) and (AComponent is T3D) and (List <> nil) then
    List.DeleteAll(AComponent);
end;

procedure T3DList.GetHeightAbove(const Position, GravityUp: TVector3Single;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc;
  out IsAbove: boolean; out AboveHeight: Single;
  out AboveGround: P3DTriangle);
var
  I: Integer;
  NewIsAbove: boolean;
  NewAboveHeight: Single;
  NewAboveGround: P3DTriangle;
begin
  IsAbove := false;
  AboveHeight := MaxSingle;
  AboveGround := nil;

  if GetCollides then
    for I := 0 to List.Count - 1 do
    begin
      List[I].GetHeightAbove(Position, GravityUp, TrianglesToIgnoreFunc,
        NewIsAbove, NewAboveHeight, NewAboveGround);

      if NewAboveHeight < AboveHeight then
      begin
        IsAbove := NewIsAbove;
        AboveHeight := NewAboveHeight;
        AboveGround := NewAboveGround;
      end;
    end;
end;

function T3DList.MoveAllowed(
  const OldPos, ProposedNewPos: TVector3Single; out NewPos: TVector3Single;
  const IsRadius: boolean; const Radius: Single;
  const OldBox, NewBox: TBox3D;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean;
var
  I: Integer;
begin
  if GetCollides and (List.Count <> 0) then
  begin
    { We call MoveAllowed with separate ProposedNewPos and NewPos
      only on the first scene.
      This means that only first scene collisions provide wall sliding.
      Collisions with other 3D objects will simply block the player.

      Otherwise, various MoveAllowed could modify NewPos
      making it colliding with other items, already checked. This would
      be wrong.

      TODO: this could be improved, to call MoveAllowed
      with separate ProposedNewPos and NewPos
      on the first scene
      where the simple move is not allowed. This would make it more general,
      although also slower. Is there any way to make it as fast and
      more general? }
    Result := List[0].MoveAllowed(OldPos, ProposedNewPos, NewPos,
      IsRadius, Radius, OldBox, NewBox, TrianglesToIgnoreFunc);
    if not Result then Exit;

    for I := 1 to List.Count - 1 do
    begin
      Result := List[I].MoveAllowed(OldPos, NewPos,
        IsRadius, Radius, OldBox, NewBox, TrianglesToIgnoreFunc);
      if not Result then Exit;
    end;
  end else
  begin
    Result := true;
    NewPos := ProposedNewPos;
  end;
end;

function T3DList.MoveAllowed(
  const OldPos, NewPos: TVector3Single;
  const IsRadius: boolean; const Radius: Single;
  const OldBox, NewBox: TBox3D;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean;
var
  I: Integer;
begin
  Result := true;

  if GetCollides then
    for I := 0 to List.Count - 1 do
    begin
      Result := List[I].MoveAllowed(OldPos, NewPos,
        IsRadius, Radius, OldBox, NewBox, TrianglesToIgnoreFunc);
      if not Result then Exit;
    end;
end;

function T3DList.SegmentCollision(const Pos1, Pos2: TVector3Single;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean;
var
  I: Integer;
begin
  Result := false;

  if GetCollides then
    for I := 0 to List.Count - 1 do
    begin
      Result := List[I].SegmentCollision(Pos1, Pos2, TrianglesToIgnoreFunc);
      if Result then Exit;
    end;
end;

function T3DList.SphereCollision(const Pos: TVector3Single; const Radius: Single;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean;
var
  I: Integer;
begin
  Result := false;

  if GetCollides then
    for I := 0 to List.Count - 1 do
    begin
      Result := List[I].SphereCollision(Pos, Radius, TrianglesToIgnoreFunc);
      if Result then Exit;
    end;
end;

function T3DList.BoxCollision(const Box: TBox3D;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean;
var
  I: Integer;
begin
  Result := false;

  if GetCollides then
    for I := 0 to List.Count - 1 do
    begin
      Result := List[I].BoxCollision(Box, TrianglesToIgnoreFunc);
      if Result then Exit;
    end;
end;

function T3DList.RayCollision(const RayOrigin, RayDirection: TVector3Single;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): TRayCollision;
var
  I: Integer;
  NewResult: TRayCollision;
  NewNode, PreviousNode: PRayCollisionNode;
begin
  Result := nil;

  if GetExists then
  begin
    for I := 0 to List.Count - 1 do
    begin
      NewResult := List[I].RayCollision(RayOrigin, RayDirection, TrianglesToIgnoreFunc);
      if NewResult <> nil then
      begin
        if (Result = nil) or (NewResult.Distance < Result.Distance) then
        begin
          SysUtils.FreeAndNil(Result);
          Result := NewResult;
        end else
          FreeAndNil(NewResult);
      end;
    end;

    if Result <> nil then
    begin
      NewNode := Result.Add;
      PreviousNode := @(Result.List^[Result.Count - 2]);
      NewNode^.Item := Self;
      NewNode^.Point := PreviousNode^.Point;
      NewNode^.Triangle := nil;
      NewNode^.RayOrigin := RayOrigin;
      NewNode^.RayDirection := RayDirection;
    end;
  end;
end;

procedure T3DList.UpdateGeneratedTextures(
  const RenderFunc: TRenderFromViewFunction;
  const ProjectionNear, ProjectionFar: Single;
  const OriginalViewportX, OriginalViewportY: LongInt;
  const OriginalViewportWidth, OriginalViewportHeight: Cardinal);
var
  I: Integer;
begin
  inherited;
  for I := 0 to List.Count - 1 do
    List[I].UpdateGeneratedTextures(
      RenderFunc, ProjectionNear, ProjectionFar,
      OriginalViewportX, OriginalViewportY,
      OriginalViewportWidth, OriginalViewportHeight);
end;

procedure T3DList.VisibleChangeNotification(const Changes: TVisibleChanges);
var
  I: Integer;
begin
  inherited;
  for I := 0 to List.Count - 1 do
    List[I].VisibleChangeNotification(Changes);
end;

function T3DList.Dragging: boolean;
var
  I: Integer;
begin
  Result := inherited;
  if Result then Exit;

  for I := 0 to List.Count - 1 do
  begin
    Result := List[I].Dragging;
    if Result then Exit;
  end;
end;

{ TransformMatricesMult ------------------------------------------------------ }

procedure TransformMatricesMult(var Transform, TransformInverse: TMatrix4Single;
  const Center: TVector3Single;
  const Rotation: TVector4Single;
  const Scale: TVector3Single;
  const ScaleOrientation: TVector4Single;
  const Translation: TVector3Single);
var
  M, IM: TMatrix4Single;
  MRotateScaleOrient, IMRotateScaleOrient: TMatrix4Single;
begin
  { To make TransformInverse, we multiply inverted matrices in inverted order
    below. }

  MultMatricesTranslation(Transform, TransformInverse,
    VectorAdd(Translation, Center));

  { We avoid using RotationMatricesRad when angle = 0, since this
    is often the case, and it makes TransformState much faster
    (which is important --- TransformState is important for traversing state). }
  if Rotation[3] <> 0 then
  begin
    { Note that even rotation Axis = zero is OK, both M and IM will be
      identity in this case. }
    RotationMatricesRad(Rotation, M, IM);
    Transform := MatrixMult(Transform, M);
    TransformInverse := MatrixMult(IM, TransformInverse);
  end;

  if (Scale[0] <> 1) or
     (Scale[1] <> 1) or
     (Scale[2] <> 1) then
  begin
    if ScaleOrientation[3] <> 0 then
    begin
      RotationMatricesRad(ScaleOrientation, MRotateScaleOrient, IMRotateScaleOrient);
      Transform := MatrixMult(Transform, MRotateScaleOrient);
      TransformInverse := MatrixMult(IMRotateScaleOrient, TransformInverse);
    end;

    { For scaling, we explicitly request that if ScalingFactor contains
      zero, IM will be forced to be identity (the 2nd param to ScalingMatrices
      is "true"). That's because VRML allows
      scaling factor to have 0 components (we need TransformInverse only
      for special tricks). }

    ScalingMatrices(Scale, true, M, IM);
    Transform := MatrixMult(Transform, M);
    TransformInverse := MatrixMult(IM, TransformInverse);

    if ScaleOrientation[3] <> 0 then
    begin
      { That's right, we reuse MRotateScaleOrient and IMRotateScaleOrient
        matrices below. Since we want to reverse them now, so normal
        Transform is multiplied by IM and TransformInverse is multiplied by M. }
      Transform := MatrixMult(Transform, IMRotateScaleOrient);
      TransformInverse := MatrixMult(MRotateScaleOrient, TransformInverse);
    end;
  end;

  MultMatricesTranslation(Transform, TransformInverse, VectorNegate(Center));
end;

{ T3DCustomTransform -------------------------------------------------------- }

function T3DCustomTransform.GetTranslation: TVector3Single;
begin
  Result := ZeroVector3Single;
end;

function T3DCustomTransform.GetCenter: TVector3Single;
begin
  Result := ZeroVector3Single;
end;

function T3DCustomTransform.GetRotation: TVector4Single;
begin
  Result := ZeroVector4Single;
end;

const
  NoScale: TVector3Single = (1, 1, 1);

function T3DCustomTransform.GetScale: TVector3Single;
begin
  Result := NoScale;
end;

function T3DCustomTransform.GetScaleOrientation: TVector4Single;
begin
  Result := ZeroVector4Single;
end;

function T3DCustomTransform.OnlyTranslation: boolean;
begin
  Result := false; { safer but slower default }
end;

function T3DCustomTransform.Transform: TMatrix4Single;
var
  Dummy: TMatrix4Single;
begin
  TransformMatrices(Result, Dummy); // TODO: optimize, if needed?
end;

function T3DCustomTransform.TransformInverse: TMatrix4Single;
var
  Dummy: TMatrix4Single;
begin
  TransformMatrices(Dummy, Result); // TODO: optimize, if needed?
end;

procedure T3DCustomTransform.TransformMatricesMult(
  var M, MInverse: TMatrix4Single);
begin
  Base3D.TransformMatricesMult(M, MInverse,
    GetCenter, GetRotation, GetScale, GetScaleOrientation, GetTranslation);
end;

procedure T3DCustomTransform.TransformMatrices(
  out M, MInverse: TMatrix4Single);
begin
  M := IdentityMatrix4Single;
  MInverse := IdentityMatrix4Single;
  TransformMatricesMult(M, MInverse); // TODO: optimize, if needed?
end;

function T3DCustomTransform.AverageScale: Single;
var
  S: TVector3Single;
begin
  S := GetScale;
  Result := (S[0] + S[1] + S[2]) / 3;
end;

{ We assume in all methods below that OnlyTranslation is the most common case,
  and then that GetTranslation = 0,0,0 is the most common case.
  This is true for many 3D objects. And for only translation,
  we can calculate result much faster (and for translation = zero,
  we don't have to do anything besides calling inherited).

  For some simplest operations, we do not check for GetTranslation = 0,0,0
  case --- if applying GetTranslation is very fast, then checking for
  zero translation would be a waste of time. }

function T3DCustomTransform.BoundingBox: TBox3D;
begin
  if OnlyTranslation then
    Result := (inherited BoundingBox).Translate(GetTranslation) else
    Result := (inherited BoundingBox).Transform(Transform);
end;

procedure T3DCustomTransform.Render(const Frustum: TFrustum; const Params: TRenderParams);
var
  T: TVector3Single;
  OldRenderTransform, Inverse: TMatrix4Single;
  OldRenderTransformIdentity: boolean;
begin
  T := GetTranslation;
  if OnlyTranslation and ZeroVector(T) then
    inherited Render(Frustum, Params) else
    begin
      { inherited Render expects Frustum in local coordinates (without
        transformation), so we subtract transformation here. }

      OldRenderTransform         := Params.RenderTransform;
      OldRenderTransformIdentity := Params.RenderTransformIdentity;
      Params.RenderTransformIdentity := false;

      if OnlyTranslation then
      begin
        MultMatrixTranslation(Params.RenderTransform, T);
        inherited Render(Frustum.Move(-T), Params);
      end else
      begin
        Inverse := IdentityMatrix4Single;
        TransformMatricesMult(Params.RenderTransform, Inverse);
        inherited Render(Frustum.Transform(Inverse), Params);
      end;

      Params.RenderTransform         := OldRenderTransform;
      Params.RenderTransformIdentity := OldRenderTransformIdentity;
    end;
end;

procedure T3DCustomTransform.RenderShadowVolume(
  ShadowVolumeRenderer: TBaseShadowVolumeRenderer;
  const ParentTransformIsIdentity: boolean;
  const ParentTransform: TMatrix4Single);
var
  T: TVector3Single;
begin
  if OnlyTranslation then
  begin
    T := GetTranslation;
    if ZeroVector(T) then
      inherited RenderShadowVolume(ShadowVolumeRenderer,
        ParentTransformIsIdentity, ParentTransform) else
      inherited RenderShadowVolume(ShadowVolumeRenderer,
        false, MatrixMult(TranslationMatrix(T), ParentTransform));
  end else
    inherited RenderShadowVolume(ShadowVolumeRenderer,
      false, MatrixMult(Transform, ParentTransform));
end;

procedure T3DCustomTransform.GetHeightAbove(const Position, GravityUp: TVector3Single;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc;
  out IsAbove: boolean; out AboveHeight: Single;
  out AboveGround: P3DTriangle);
var
  MInverse: TMatrix4Single;
begin
  { inherited will check these anyway. But by checking them here,
    we can potentially avoid the cost of transforming into local space. }
  if not GetCollides then
  begin
    IsAbove := false;
    AboveHeight := MaxSingle;
    AboveGround := nil;
    Exit;
  end;

  if OnlyTranslation then
    inherited GetHeightAbove(
      Position - GetTranslation, GravityUp, TrianglesToIgnoreFunc,
      IsAbove, AboveHeight, AboveGround) else
  begin
    MInverse := TransformInverse;
    inherited GetHeightAbove(
      MatrixMultPoint(MInverse, Position),
      MatrixMultDirection(MInverse, GravityUp), TrianglesToIgnoreFunc,
        IsAbove, AboveHeight, AboveGround);
    { Note that we should not scale resulting AboveHeight by AverageScale.
      That is because AboveHeight is relative to GravityUp length,
      so it's automatically correct. }
  end;
end;

function T3DCustomTransform.MoveAllowed(
  const OldPos, ProposedNewPos: TVector3Single; out NewPos: TVector3Single;
  const IsRadius: boolean; const Radius: Single;
  const OldBox, NewBox: TBox3D;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean;
var
  T: TVector3Single;
  M, MInverse: TMatrix4Single;
begin
  { inherited will check these anyway. But by checking them here,
    we can potentially avoid the cost of transforming into local space. }
  if not GetCollides then
  begin
    NewPos := ProposedNewPos;
    Exit(true);
  end;

  if OnlyTranslation then
  begin
    T := GetTranslation;
    Result := inherited MoveAllowed(
      OldPos         - T,
      ProposedNewPos - T, NewPos,
      IsRadius, Radius,
      OldBox.AntiTranslate(T),
      NewBox.AntiTranslate(T), TrianglesToIgnoreFunc);
    { translate calculated NewPos back }
    if Result then
      NewPos += T;
  end else
  begin
    TransformMatrices(M, MInverse);
    Result := inherited MoveAllowed(
      MatrixMultPoint(MInverse, OldPos),
      MatrixMultPoint(MInverse, ProposedNewPos), NewPos,
      IsRadius, Radius / AverageScale,
      OldBox.Transform(MInverse),
      NewBox.Transform(MInverse), TrianglesToIgnoreFunc);
    { transform calculated NewPos back }
    if Result then
      NewPos := MatrixMultPoint(M, NewPos);
  end;
end;

function T3DCustomTransform.MoveAllowed(
  const OldPos, NewPos: TVector3Single;
  const IsRadius: boolean; const Radius: Single;
  const OldBox, NewBox: TBox3D;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean;
var
  T: TVector3Single;
  MInverse: TMatrix4Single;
begin
  { inherited will check these anyway. But by checking them here,
    we can potentially avoid the cost of transforming into local space. }
  if not GetCollides then Exit(true);

  if OnlyTranslation then
  begin
    { I have to check collision between
        Items + Translation and (OldPos, NewPos).
      So it's equivalent to checking for collision between
        Items and (OldPos, NewPos) - Translation
      And this way I can use inherited MoveAllowed. }
    T := GetTranslation;
    Result := inherited MoveAllowed(
      OldPos - T,
      NewPos - T,
      IsRadius, Radius,
      OldBox.AntiTranslate(T),
      NewBox.AntiTranslate(T), TrianglesToIgnoreFunc);
  end else
  begin
    MInverse := TransformInverse;
    Result := inherited MoveAllowed(
      MatrixMultPoint(MInverse, OldPos),
      MatrixMultPoint(MInverse, NewPos),
      IsRadius, Radius / AverageScale,
      OldBox.Transform(MInverse),
      NewBox.Transform(MInverse), TrianglesToIgnoreFunc);
  end;
end;

function T3DCustomTransform.SegmentCollision(const Pos1, Pos2: TVector3Single;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean;
var
  T: TVector3Single;
  MInverse: TMatrix4Single;
begin
  { inherited will check these anyway. But by checking them here,
    we can potentially avoid the cost of transforming into local space. }
  if not GetCollides then Exit(false);

  if OnlyTranslation then
  begin
    T := GetTranslation;
    Result := inherited SegmentCollision(Pos1 - T, Pos2 - T, TrianglesToIgnoreFunc);
  end else
  begin
    MInverse := TransformInverse;
    Result := inherited SegmentCollision(
      MatrixMultPoint(MInverse, Pos1),
      MatrixMultPoint(MInverse, Pos2), TrianglesToIgnoreFunc);
  end;
end;

function T3DCustomTransform.SphereCollision(
  const Pos: TVector3Single; const Radius: Single;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean;
begin
  { inherited will check these anyway. But by checking them here,
    we can potentially avoid the cost of transforming into local space. }
  if not GetCollides then Exit(false);

  if OnlyTranslation then
    Result := inherited SphereCollision(
      Pos - GetTranslation, Radius, TrianglesToIgnoreFunc) else
    Result := inherited SphereCollision(
      MatrixMultPoint(TransformInverse, Pos), Radius / AverageScale, TrianglesToIgnoreFunc);
end;

function T3DCustomTransform.BoxCollision(
  const Box: TBox3D;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): boolean;
begin
  { inherited will check these anyway. But by checking them here,
    we can potentially avoid the cost of transforming into local space. }
  if not GetCollides then Exit(false);

  if OnlyTranslation then
    Result := inherited BoxCollision(
      Box.AntiTranslate(GetTranslation), TrianglesToIgnoreFunc) else
    Result := inherited BoxCollision(
      Box.Transform(TransformInverse), TrianglesToIgnoreFunc);
end;

function T3DCustomTransform.RayCollision(const RayOrigin, RayDirection: TVector3Single;
  const TrianglesToIgnoreFunc: T3DTriangleIgnoreFunc): TRayCollision;
var
  T: TVector3Single;
  M, MInverse: TMatrix4Single;
  LastNode: PRayCollisionNode;
begin
  { inherited will check these anyway. But by checking them here,
    we can potentially avoid the cost of transforming into local space. }
  if not GetExists then Exit(nil);

  if OnlyTranslation then
  begin
    T := GetTranslation;
    Result := inherited RayCollision(RayOrigin - T, RayDirection, TrianglesToIgnoreFunc);
    if Result <> nil then
    begin
      LastNode := @(Result.List^[Result.Count - 1]);
      LastNode^.Point += T;
      { untransform the ray }
      LastNode^.RayOrigin := RayOrigin;
      LastNode^.RayDirection := RayDirection;
    end;
  end else
  begin
    TransformMatrices(M, MInverse);
    Result := inherited RayCollision(
      MatrixMultPoint(MInverse, RayOrigin),
      MatrixMultDirection(MInverse, RayDirection), TrianglesToIgnoreFunc);
    if Result <> nil then
    begin
      LastNode := @(Result.List^[Result.Count - 1]);
      LastNode^.Point := MatrixMultPoint(M, LastNode^.Point);
      { untransform the ray }
      LastNode^.RayOrigin := RayOrigin;
      LastNode^.RayDirection := RayDirection;

      { Note that we should not scale Result.Distance by AverageScale.
        That is because Result.Distance is relative to RayDirection length,
        so it's automatically correct. }
    end;
  end;
end;

{ T3DTransform -------------------------------------------------------------- }

constructor T3DTransform.Create(AOwner: TComponent);
begin
  inherited;
  FOnlyTranslation := true;
  FScale := NoScale;
end;

function T3DTransform.GetCenter: TVector3Single;
begin
  Result := FCenter;
end;

function T3DTransform.GetRotation: TVector4Single;
begin
  Result := FRotation;
end;

function T3DTransform.GetScale: TVector3Single;
begin
  Result := FScale;
end;

function T3DTransform.GetScaleOrientation: TVector4Single;
begin
  Result := FScaleOrientation;
end;

function T3DTransform.GetTranslation: TVector3Single;
begin
  Result := FTranslation;
end;

{ We try hard to keep OnlyTranslation return fast, and return with true.
  This will allow T3DCustomTransform to be optimized and accurate
  for often case of pure translation. }

procedure T3DTransform.SetCenter(const Value: TVector3Single);
begin
  FCenter := Value;
  FOnlyTranslation := FOnlyTranslation and
    (Value[0] = 0) and (Value[1] = 0) and (Value[2] = 0);
end;

procedure T3DTransform.SetRotation(const Value: TVector4Single);
begin
  FRotation := Value;
  FOnlyTranslation := FOnlyTranslation and (Value[3] = 0);
end;

procedure T3DTransform.SetScale(const Value: TVector3Single);
begin
  FScale := Value;
  FOnlyTranslation := FOnlyTranslation and
    (Value[0] = 1) and (Value[1] = 1) and (Value[2] = 1);
end;

procedure T3DTransform.SetScaleOrientation(const Value: TVector4Single);
begin
  FScaleOrientation := Value;
  FOnlyTranslation := FOnlyTranslation and (Value[3] = 0);
end;

function T3DTransform.OnlyTranslation: boolean;
begin
  Result := FOnlyTranslation;
end;

procedure T3DTransform.Translate(const T: TVector3Single);
begin
  Translation := Translation + T;
end;

end.
