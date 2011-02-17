{
  Copyright 2010-2011 Michalis Kamburelis.

  This file is part of "Kambi VRML game engine".

  "Kambi VRML game engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Kambi VRML game engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Setting up OpenGL shading (TVRMLShader).

  Internal for VRMLGLRenderer. @exclude }
unit VRMLShader;

interface

uses VectorMath, GLShaders, FGL, VRMLShadowMaps, VRMLTime, VRMLFields,
  VRMLNodes, KambiUtils;

type
  { Uniform value type, for TUniform. }
  TUniformType = (utLongInt, utSingle);

  { Uniform value to set after binding shader. }
  TUniform = class
    Name: string;
    AType: TUniformType;
    Value: record
      case Integer of
        utLongInt: (LongInt: LongInt);
        utSingle: (Single: Single);
    end;
  end;
  TUniformsList = specialize TFPGObjectList<TUniform>;

  TTextureType = (tt2D, tt2DShadow, ttCubeMap, tt3D);

  TTexGenerationComponent = (tgEye, tgObject);
  TTexGenerationComplete = (tgSphere, tgNormal, tgReflection);
  TTexComponent = 0..3;

  { GLSL program integrated with VRML/X3D and TVRMLShader.
    Allows to bind uniform values from VRML/X3D fields,
    and to observe VRML/X3D events and automatically update uniform values.
    Also allows to initialize and check program by TVRMLShader.LinkProgram,
    TVRMLShader.ProgramSettingsEqual. }
  TVRMLShaderProgram = class(TGLSLProgram)
  private
    { State of TVRMLShader when initializing this shader by LinkProgram.
      Used to decide when shader needs to be regenerated.
      Note that our shaders for ComposedShader are not touched by LinkProgram,
      so they don't use these fields (which isn't a problem, since they
      also don't use ProgramSettingsEqual).
      @groupBegin }
    LightsEnabled: Cardinal;
    PercentageCloserFiltering: TPercentageCloserFiltering;
    { @groupEnd }

    { Events where we registered our EventReceive method. }
    EventsObserved: TVRMLEventsList;

    { Set uniform variable from VRML/X3D field value.
      Uniform name is contained in UniformName. UniformValue indicates
      uniform type and new value (UniformValue.Name is not used).

      This ignores SFNode / MFNode fields (these will be set elsewhere). }
    procedure SetUniformFromField(const UniformName: string;
      const UniformValue: TVRMLField; const EnableDisable: boolean);

    procedure EventReceive(Event: TVRMLEvent; Value: TVRMLField;
      const Time: TVRMLTime);

    { Set uniform shader variable from VRML/X3D field (exposed or not).
      We also start observing an exposed field or eventIn,
      and will automatically update uniform value when we receive an event. }
    procedure BindUniform(const FieldOrEvent: TVRMLInterfaceDeclaration;
      const EnableDisable: boolean);
  protected
    { Nodes that have interface declarations with textures for this shader. }
    UniformsNodes: TVRMLNodesList;
  public
    constructor Create;
    destructor Destroy; override;

    { Set and observe uniform variables from given Node.InterfaceDeclarations.

      Non-texture fields are set immediately.
      Non-texture fields are events are then observed by this shader,
      and automatically updated when changed.

      Texture fields have to be updated by descendant (like TVRMLGLSLProgram),
      using the UniformsNodes list. These methods add nodes to this list.
      @groupBegin }
    procedure BindUniforms(const Node: TVRMLNode; const EnableDisable: boolean);
    procedure BindUniforms(const Nodes: TVRMLNodesList; const EnableDisable: boolean);
    { @groupEnd }
  end;

  TLightShader = class
  private
    Code: TDynStringArray;
    Node: TNodeX3DLightNode;
  public
    constructor Create;
    destructor Destroy; override;
  end;
  TLightShaders = class(specialize TFPGObjectList<TLightShader>)
  private
    function Find(const Node: TNodeX3DLightNode; out Shader: TLightShader): boolean;
  end;

  { Create appropriate shader and at the same time set OpenGL parameters
    for fixed-function rendering. Once everything is set up,
    you can create TVRMLShaderProgram instance
    and initialize it by LinkProgram here, then enable it if you want.
    Or you can simply allow the fixed-function pipeline to work.

    This is used internally by TVRMLGLRenderer. It isn't supposed to be used
    directly by other code. }
  TVRMLShader = class
  private
    Uniforms: TUniformsList;
    { If non-nil, the list of effect nodes that determine uniforms of our program. }
    UniformsNodes: TVRMLNodesList;
    TextureApply, TextureColorDeclare, TextureCoordInitialize,
      TextureCoordGen, TextureCoordMatrix, FragmentShaderDeclare,
      ClipPlane, FragmentEnd: string;
    FPercentageCloserFiltering: TPercentageCloserFiltering;
    VertexShaderComplete, FragmentShaderComplete: TDynStringArray;
    PlugIdentifiers: Cardinal;
    LightsEnabled: Cardinal;
    LightShaders: TLightShaders;

    procedure PlugDirectly(Code: TDynStringArray; const PlugName, PlugValue: string);
  public
    constructor Create;
    destructor Destroy; override;

    { Detect defined PLUG_xxx functions within PlugValue,
      insert calls to them into given Code,
      insert the PlugValue (which should be variable and functions declarations)
      into code of final shader (determined by EffectPartType).
      When Code = nil then we insert both calls and PlugValue into
      code of the final shader (determined by EffectPartType).

      Inserts calls right before the magic @code(/* PLUG ...*/) comments,
      this way many Plug calls that defined the same PLUG_xxx function
      will be called in the same order. }
    procedure Plug(const EffectPartType: string; PlugValue: string;
      Code: TDynStringArray = nil);

    procedure ApplyInternalEffects;
    procedure LinkProgram(AProgram: TVRMLShaderProgram);

    { Given one TVRMLShaderProgram, created for the same shape by LinkProgram,
      do these program settings matching current TVRMLShader settings.
      This is used to decide when shape settings (for example,
      lights count or such) change and require regenerating the shader. }
    function ProgramSettingsEqual(AProgram: TVRMLShaderProgram): boolean;

    procedure AddUniform(Uniform: TUniform);

    procedure EnableTexture(const TextureUnit: Cardinal;
      const TextureType: TTextureType; const Node: TNodeX3DTextureNode;
      const ShadowMapSize: Cardinal = 0;
      const ShadowLight: TNodeX3DLightNode = nil;
      const ShadowVisualizeDepth: boolean = false);
    procedure EnableTexGen(const TextureUnit: Cardinal;
      const Generation: TTexGenerationComponent; const Component: TTexComponent);
    procedure EnableTexGen(const TextureUnit: Cardinal;
      const Generation: TTexGenerationComplete);
    procedure DisableTexGen(const TextureUnit: Cardinal);
    procedure EnableClipPlane(const ClipPlaneIndex: Cardinal);
    procedure DisableClipPlane(const ClipPlaneIndex: Cardinal);
    procedure EnableAlphaTest;
    procedure EnableBumpMapping(const NormalMapTextureUnit: Cardinal);
    procedure EnableLight(const Number: Cardinal; Node: TNodeX3DLightNode;
      const MaterialSpecularColor: TVector3Single);

    property PercentageCloserFiltering: TPercentageCloserFiltering
      read FPercentageCloserFiltering write FPercentageCloserFiltering;

    procedure EnableEffects(Effects: TMFNode;
      const Code: TDynStringArray = nil);
  end;

implementation

uses SysUtils, GL, GLExt, KambiStringUtils, KambiGLUtils,
  VRMLErrors, KambiLog, StrUtils, Base3D;

{ TODO: a way to turn off using fixed-function pipeline completely
  will be needed some day. Currently, some functions here call
  fixed-function glEnable... stuff.

  TODO: caching shader programs, using the same program if all settings
  are the same, will be needed some day. TShapeCache is not a good place
  for this, as the conditions for two shapes to share arrays/vbos
  are smaller/different (for example, two different geometry nodes
  can definitely share the same shader).

  Maybe caching should be done in this unit, or maybe in TVRMLGLRenderer
  in some TShapeShaderCache or such.

  TODO: a way to turn on/off per-pixel shading should be available.

  TODO: some day, avoid using predefined OpenGL state variables.
  Use only shader uniforms. Right now, we allow some state to be assigned
  using direct normal OpenGL fixed-function functions in VRMLGLRenderer,
  and our shaders just use it.
}

{ TLightShader --------------------------------------------------------------- }

constructor TLightShader.Create;
begin
  inherited;
  Code := TDynStringArray.Create;
end;

destructor TLightShader.Destroy;
begin
  FreeAndNil(Code);
  inherited;
end;

{ TLightShaders -------------------------------------------------------------- }

function TLightShaders.Find(const Node: TNodeX3DLightNode; out Shader: TLightShader): boolean;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Items[I].Node = Node then
    begin
      Shader := Items[I];
      Exit(true);
    end;
  Shader := nil;
  Result := false;
end;

{ TVRMLShaderProgram ------------------------------------------------------- }

constructor TVRMLShaderProgram.Create;
begin
  inherited;
  EventsObserved := TVRMLEventsList.Create;
  UniformsNodes := TVRMLNodesList.Create;
end;

destructor TVRMLShaderProgram.Destroy;
var
  I: Integer;
begin
  if EventsObserved <> nil then
  begin
    for I := 0 to EventsObserved.Count - 1 do
      EventsObserved[I].OnReceive.Remove(@EventReceive);
    FreeAndNil(EventsObserved);
  end;
  FreeAndNil(UniformsNodes);
  inherited;
end;

procedure TVRMLShaderProgram.BindUniform(const FieldOrEvent: TVRMLInterfaceDeclaration;
  const EnableDisable: boolean);
var
  UniformField: TVRMLField;
  UniformEvent, ObservedEvent: TVRMLEvent;
begin
  UniformField := FieldOrEvent.Field;
  UniformEvent := FieldOrEvent.Event;

  { Set initial value for this GLSL uniform variable,
    from VRML field or exposedField }

  if UniformField <> nil then
  begin
    { Ok, we have a field with a value (interface declarations with
      fields inside ComposedShader / Effect always have a value).
      So set GLSL uniform variable from this field. }
    SetUniformFromField(UniformField.Name, UniformField, EnableDisable);
  end;

  { Allow future changing of this GLSL uniform variable,
    from VRML eventIn or exposedField }

  { calculate ObservedEvent }
  ObservedEvent := nil;
  if (UniformField <> nil) and UniformField.Exposed then
    ObservedEvent := UniformField.ExposedEvents[false] else
  if (UniformEvent <> nil) and UniformEvent.InEvent then
    ObservedEvent := UniformEvent;

  if ObservedEvent <> nil then
  begin
    ObservedEvent.OnReceive.Add(@EventReceive);
    EventsObserved.Add(ObservedEvent);
  end;
end;

procedure TVRMLShaderProgram.SetUniformFromField(
  const UniformName: string; const UniformValue: TVRMLField;
  const EnableDisable: boolean);
var
  TempF: TDynSingleArray;
  TempVec2f: TDynVector2SingleArray;
  TempVec3f: TDynVector3SingleArray;
  TempVec4f: TDynVector4SingleArray;
  TempMat3f: TDynMatrix3SingleArray;
  TempMat4f: TDynMatrix4SingleArray;
begin
  { program must be active to set uniform values. }
  if EnableDisable then
    Enable;

  if UniformValue is TSFBool then
    SetUniform(UniformName, TSFBool(UniformValue).Value) else
  if UniformValue is TSFLong then
    { Handling of SFLong also takes care of SFInt32. }
    SetUniform(UniformName, TSFLong(UniformValue).Value) else
  if UniformValue is TSFVec2f then
    SetUniform(UniformName, TSFVec2f(UniformValue).Value) else
  { Check TSFColor first, otherwise TSFVec3f would also catch and handle
    TSFColor. And we don't want this: for GLSL, color is passed
    as vec4 (so says the spec, I guess that the reason is that for GLSL most
    input/output colors are vec4). }
  if UniformValue is TSFColor then
    SetUniform(UniformName, Vector4Single(TSFColor(UniformValue).Value, 1.0)) else
  if UniformValue is TSFVec3f then
    SetUniform(UniformName, TSFVec3f(UniformValue).Value) else
  if UniformValue is TSFVec4f then
    SetUniform(UniformName, TSFVec4f(UniformValue).Value) else
  if UniformValue is TSFRotation then
    SetUniform(UniformName, TSFRotation(UniformValue).Value) else
  if UniformValue is TSFMatrix3f then
    SetUniform(UniformName, TSFMatrix3f(UniformValue).Value) else
  if UniformValue is TSFMatrix4f then
    SetUniform(UniformName, TSFMatrix4f(UniformValue).Value) else
  if UniformValue is TSFFloat then
    SetUniform(UniformName, TSFFloat(UniformValue).Value) else
  if UniformValue is TSFDouble then
    { SFDouble also takes care of SFTime }
    SetUniform(UniformName, TSFDouble(UniformValue).Value) else

  { Double-precision vector and matrix types.

    Note that X3D spec specifies only mapping for SF/MFVec3d, 4d
    (not specifying any mapping for SF/MFVec2d, and all matrix types).
    And it specifies that they map to types float3, float4 ---
    which are not valid types in GLSL?

    So I simply ignore non-sensible specification, and take
    the reasonable approach: support all double-precision vectors and matrices,
    just like single-precision. }
  if UniformValue is TSFVec2d then
    SetUniform(UniformName, Vector2Single(TSFVec2d(UniformValue).Value)) else
  if UniformValue is TSFVec3d then
    SetUniform(UniformName, Vector3Single(TSFVec3d(UniformValue).Value)) else
  if UniformValue is TSFVec4d then
    SetUniform(UniformName, Vector4Single(TSFVec4d(UniformValue).Value)) else
  if UniformValue is TSFMatrix3d then
    SetUniform(UniformName, Matrix3Single(TSFMatrix3d(UniformValue).Value)) else
  if UniformValue is TSFMatrix4d then
    SetUniform(UniformName, Matrix4Single(TSFMatrix4d(UniformValue).Value)) else

  { Now repeat this for array types }
  if UniformValue is TMFBool then
    SetUniform(UniformName, TMFBool(UniformValue).Items) else
  if UniformValue is TMFLong then
    SetUniform(UniformName, TMFLong(UniformValue).Items) else
  if UniformValue is TMFVec2f then
    SetUniform(UniformName, TMFVec2f(UniformValue).Items) else
  if UniformValue is TMFColor then
  begin
    TempVec4f := TMFColor(UniformValue).Items.ToVector4Single(1.0);
    try
      SetUniform(UniformName, TempVec4f);
    finally FreeAndNil(TempVec4f) end;
  end else
  if UniformValue is TMFVec3f then
    SetUniform(UniformName, TMFVec3f(UniformValue).Items) else
  if UniformValue is TMFVec4f then
    SetUniform(UniformName, TMFVec4f(UniformValue).Items) else
  if UniformValue is TMFRotation then
    SetUniform(UniformName, TMFRotation(UniformValue).Items) else
  if UniformValue is TMFMatrix3f then
    SetUniform(UniformName, TMFMatrix3f(UniformValue).Items) else
  if UniformValue is TMFMatrix4f then
    SetUniform(UniformName, TMFMatrix4f(UniformValue).Items) else
  if UniformValue is TMFFloat then
    SetUniform(UniformName, TMFFloat(UniformValue).Items) else
  if UniformValue is TMFDouble then
  begin
    TempF := TMFDouble(UniformValue).Items.ToSingle;
    try
      SetUniform(UniformName, TempF);
    finally FreeAndNil(TempF) end;
  end else
  if UniformValue is TMFVec2d then
  begin
    TempVec2f := TMFVec2d(UniformValue).Items.ToVector2Single;
    try
      SetUniform(UniformName, TempVec2f);
    finally FreeAndNil(TempVec2f) end;
  end else
  if UniformValue is TMFVec3d then
  begin
    TempVec3f := TMFVec3d(UniformValue).Items.ToVector3Single;
    try
      SetUniform(UniformName, TempVec3f);
    finally FreeAndNil(TempVec3f) end;
  end else
  if UniformValue is TMFVec4d then
  begin
    TempVec4f := TMFVec4d(UniformValue).Items.ToVector4Single;
    try
      SetUniform(UniformName, TempVec4f);
    finally FreeAndNil(TempVec4f) end;
  end else
  if UniformValue is TMFMatrix3d then
  begin
    TempMat3f := TMFMatrix3d(UniformValue).Items.ToMatrix3Single;
    try
      SetUniform(UniformName, TempMat3f);
    finally FreeAndNil(TempMat3f) end;
  end else
  if UniformValue is TMFMatrix4d then
  begin
    TempMat4f := TMFMatrix4d(UniformValue).Items.ToMatrix4Single;
    try
      SetUniform(UniformName, TempMat4f);
    finally FreeAndNil(TempMat4f) end;
  end else
  if (UniformValue is TSFNode) or
     (UniformValue is TMFNode) then
  begin
    { Nothing to do, these will be set by TGLSLRenderer.Enable }
  end else
    { TODO: other field types, full list is in X3D spec in
      "OpenGL shading language (GLSL) binding".
      Remaining:
      SF/MFImage }
    VRMLWarning(vwSerious, 'Setting uniform GLSL variable from X3D field type "' + UniformValue.VRMLTypeName + '" not supported');

  if EnableDisable then
    { TODO: this should restore previously bound program }
    Disable;
end;

procedure TVRMLShaderProgram.EventReceive(
  Event: TVRMLEvent; Value: TVRMLField; const Time: TVRMLTime);
var
  UniformName: string;
  EventsEngine: TVRMLEventsEngine;
begin
  if Event.ParentExposedField = nil then
    UniformName := Event.Name else
    UniformName := Event.ParentExposedField.Name;

  SetUniformFromField(UniformName, Value, true);

  { Although ExposedEvents implementation already sends notification
    about changes to EventsEngine, we can also get here
    by eventIn invocation (which doesn't trigger
    EventsEngine.ChangedField, since it doesn't change a field...).
    So we should explicitly do VisibleChangeHere here, to make sure
    it gets called when uniform changed. }
  if Event.ParentNode <> nil then
  begin
    EventsEngine := (Event.ParentNode as TVRMLNode).EventsEngine;
    if EventsEngine <> nil then
      EventsEngine.VisibleChangeHere([vcVisibleGeometry, vcVisibleNonGeometry]);
  end;
end;

procedure TVRMLShaderProgram.BindUniforms(const Node: TVRMLNode;
  const EnableDisable: boolean);
var
  I: Integer;
begin
  Assert(Node.HasInterfaceDeclarations <> []);
  Assert(Node.InterfaceDeclarations <> nil);
  for I := 0 to Node.InterfaceDeclarations.Count - 1 do
    BindUniform(Node.InterfaceDeclarations[I], EnableDisable);
  UniformsNodes.Add(Node);
end;

procedure TVRMLShaderProgram.BindUniforms(const Nodes: TVRMLNodesList;
  const EnableDisable: boolean);
var
  I: Integer;
begin
  for I := 0 to Nodes.Count - 1 do
    BindUniforms(Nodes[I], EnableDisable);
end;

{ TVRMLShader ---------------------------------------------------------------- }

constructor TVRMLShader.Create;
begin
  inherited;
  VertexShaderComplete := TDynStringArray.Create;
  VertexShaderComplete.Add({$I template.vs.inc});
  FragmentShaderComplete := TDynStringArray.Create;
  FragmentShaderComplete.Add({$I template.fs.inc});
  LightShaders := TLightShaders.Create;
end;

destructor TVRMLShader.Destroy;
begin
  FreeAndNil(Uniforms);
  FreeAndNil(UniformsNodes);
  FreeAndNil(LightShaders);
  FreeAndNil(VertexShaderComplete);
  FreeAndNil(FragmentShaderComplete);
  inherited;
end;

procedure TVRMLShader.Plug(const EffectPartType: string; PlugValue: string;
  Code: TDynStringArray);
const
  PlugPrefix = 'PLUG_';

  { Find PLUG_xxx function inside PlugValue. Returns xxx (the part after
    PLUG_) if found, or '' if not found. }
  function FindPlugName(const PlugValue: string): string;
  const
    IdentifierChars = ['0'..'9', 'a'..'z', 'A'..'Z', '_'];
  var
    P, PBegin: Integer;
  begin
    Result := ''; { assume failure }
    P := Pos(PlugPrefix, PlugValue);
    if P <> 0 then
    begin
      { There must be whitespace before PLUG_ }
      if (P > 1) and (not (PlugValue[P - 1] in WhiteSpaces)) then Exit;
      P += Length(PlugPrefix);
      PBegin := P;
      { There must be at least one identifier char after PLUG_ }
      if (P > Length(PlugValue)) or
         (not (PlugValue[P] in IdentifierChars)) then Exit;
      repeat
        Inc(P);
      until (P > Length(PlugValue)) or (not (PlugValue[P] in IdentifierChars));
      { There must be a whitespace or ( after PLUG_xxx }
      if (P > Length(PlugValue)) or (not (PlugValue[P] in (WhiteSpaces + ['(']))) then
        Exit;

      Result := CopyPos(PlugValue, PBegin, P - 1);
    end;
  end;

  procedure InsertIntoCode(const P: Integer; const S: string);
  begin
    Code[0] := Copy(Code[0], 1, P - 1) + S + SEnding(Code[0], P);
  end;

var
  PBegin, PEnd: Integer;
  Parameter, PlugName, ProcedureName, CommentBegin: string;
  CodeForPlugValue: TDynStringArray;
begin
  if EffectPartType = 'VERTEX' then
    CodeForPlugValue := VertexShaderComplete else
  if EffectPartType = 'FRAGMENT' then
    CodeForPlugValue := FragmentShaderComplete else
  begin
    VRMLWarning(vwIgnorable, Format('EffectPart.type "%s" is not recognized',
      [EffectPartType]));
    Exit;
  end;

  if Code = nil then
    Code := CodeForPlugValue;

  repeat
    PlugName := FindPlugName(PlugValue);
    if PlugName = '' then Break;

    CommentBegin := '/* PLUG: ' + PlugName + ' ';
    PBegin := Pos(CommentBegin, Code[0]); { TODO: only Code[0] processed for now }
    if PBegin <> 0 then
    begin
      PEnd := PosEx('*/', Code[0], PBegin + Length(CommentBegin));
      if PEnd <> 0 then
      begin
        ProcedureName := 'plugged_' + IntToStr(PlugIdentifiers);
        Inc(PlugIdentifiers);

        StringReplaceAllTo1st(PlugValue, 'PLUG_' + PlugName, ProcedureName, false);

        Parameter := Trim(CopyPos(Code[0], PBegin + Length(CommentBegin), PEnd - 1));
        InsertIntoCode(PBegin, ProcedureName + Parameter + ';' + NL);
      end else
        VRMLWarning(vwIgnorable, Format('Plug name "%s" comment not properly closed, treating like not declared', [PlugName]));
    end else
      VRMLWarning(vwIgnorable, Format('Plug name "%s" not declared', [PlugName]));
  until false;

  { regardless if any (and how many) plug points were found,
    always insert PlugValue into CodeForPlugValue }
  PlugDirectly(CodeForPlugValue, '$declare-procedures$', PlugValue);
end;

procedure TVRMLShader.PlugDirectly(Code: TDynStringArray;
  const PlugName, PlugValue: string);
begin
  { TODO: make better. PlugDirectly is always one-time? }
  if Pos('/* PLUG: ' + PlugName, Code[0]) = 0 then
    VRMLWarning(vwIgnorable, Format('Plug point "%s" not found', [PlugName]));

  Code[0] := StringReplace(Code[0],
    '/* PLUG: ' + PlugName, PlugValue + NL +
    '/* PLUG: ' + PlugName, []);
end;

procedure TVRMLShader.ApplyInternalEffects;
const
  PCFDefine: array [TPercentageCloserFiltering] of string =
  ( '', '#define PCF4', '#define PCF4_BILINEAR', '#define PCF16' );
var
  I: Integer;
  LightShaderBack, LightShaderFront: string;
begin
  PlugDirectly(VertexShaderComplete, 'vertex_process',
    TextureCoordInitialize + TextureCoordGen + TextureCoordMatrix + ClipPlane);
  PlugDirectly(FragmentShaderComplete, 'texture_apply',
    TextureColorDeclare + TextureApply);
  PlugDirectly(FragmentShaderComplete, '$declare-variables$',
    FragmentShaderDeclare + PCFDefine[PercentageCloserFiltering]);
  PlugDirectly(FragmentShaderComplete, '$declare-shadow-map-procedures$',
    {$I shadow_map_common.fs.inc});
  PlugDirectly(FragmentShaderComplete, 'fragment_end', FragmentEnd);

  for I := 0 to LightShaders.Count - 1 do
    if LightShaders[I] <> nil then
    begin
      LightShaderBack  := LightShaders[I].Code[0];
      LightShaderFront := LightShaders[I].Code[0];

      LightShaderBack := StringReplace(LightShaderBack,
        'gl_SideLightProduct', 'gl_BackLightProduct' , [rfReplaceAll]);
      LightShaderFront := StringReplace(LightShaderFront,
        'gl_SideLightProduct', 'gl_FrontLightProduct', [rfReplaceAll]);

      LightShaderBack := StringReplace(LightShaderBack,
        'add_light_contribution_side', 'add_light_contribution_back' , [rfReplaceAll]);
      LightShaderFront := StringReplace(LightShaderFront,
        'add_light_contribution_side', 'add_light_contribution_front', [rfReplaceAll]);

      Plug('FRAGMENT', LightShaderBack);
      Plug('FRAGMENT', LightShaderFront);
    end;
end;

procedure TVRMLShader.LinkProgram(AProgram: TVRMLShaderProgram);

  procedure SetupUniformsOnce;
  var
    I: Integer;
  begin
    AProgram.Enable;

    if Uniforms <> nil then
      for I := 0 to Uniforms.Count - 1 do
        case Uniforms[I].AType of
          utLongInt: AProgram.SetUniform(Uniforms[I].Name, Uniforms[I].Value.LongInt);
          utSingle : AProgram.SetUniform(Uniforms[I].Name, Uniforms[I].Value.Single );
          else raise EInternalError.Create('TVRMLShader.SetupUniformsOnce:Uniforms[I].Type?');
        end;

    if UniformsNodes <> nil then
      AProgram.BindUniforms(UniformsNodes, false);

    AProgram.Disable;
  end;

var
  I: Integer;
begin
  if Log then
  begin
    for I := 0 to VertexShaderComplete.Count - 1 do
      WritelnLogMultiline(Format('Generated GLSL vertex shader[%d]', [I]),
        VertexShaderComplete[I]);
    for I := 0 to FragmentShaderComplete.Count - 1 do
      WritelnLogMultiline(Format('Generated GLSL fragment shader[%d]', [I]),
        FragmentShaderComplete[I]);
  end;

  for I := 0 to VertexShaderComplete.Count - 1 do
    AProgram.AttachVertexShader(VertexShaderComplete[I]);
  for I := 0 to FragmentShaderComplete.Count - 1 do
    AProgram.AttachFragmentShader(FragmentShaderComplete[I]);
  AProgram.Link(true);

  AProgram.UniformNotFoundAction := uaWarning;
  AProgram.UniformTypeMismatchAction := utWarning;

  AProgram.LightsEnabled := LightsEnabled;
  AProgram.PercentageCloserFiltering := PercentageCloserFiltering;

  { set uniforms that will not need to be updated at each SetupUniforms call }
  SetupUniformsOnce;
end;

function TVRMLShader.ProgramSettingsEqual(AProgram: TVRMLShaderProgram): boolean;
begin
  Result := (
    (AProgram.LightsEnabled = LightsEnabled) and
    (AProgram.PercentageCloserFiltering = PercentageCloserFiltering)
  );
end;

procedure TVRMLShader.AddUniform(Uniform: TUniform);
begin
  if Uniforms = nil then
    Uniforms := TUniformsList.Create;
  Uniforms.Add(Uniform);
end;

procedure TVRMLShader.EnableTexture(const TextureUnit: Cardinal;
  const TextureType: TTextureType;
  const Node: TNodeX3DTextureNode;
  const ShadowMapSize: Cardinal;
  const ShadowLight: TNodeX3DLightNode;
  const ShadowVisualizeDepth: boolean);

  procedure TextureShaderEffects(var TextureShader: string);
  var
    S: TDynStringArray;
  begin
    { optimize, no need for TStringList creation in case of no effects }
    if Node.FdEffects.Count <> 0 then
    begin
      S := TDynStringArray.Create;
      try
        S.Add(TextureShader);
        EnableEffects(Node.FdEffects, S);
        TextureShader := S[0];
      finally FreeAndNil(S) end;
    end;
  end;

const
  OpenGLTextureType: array [TTextureType] of string =
  ('sampler2D', 'sampler2DShadow', 'samplerCube', 'sampler3D');
var
  Uniform: TUniform;
  TextureSampleCall, TextureShader: string;
  ShadowLightShader: TLightShader;
begin
  { Enable for fixed-function pipeline }
  if GLUseMultiTexturing then
    glActiveTextureARB(GL_TEXTURE0 + TextureUnit);
  case TextureType of
    tt2D, tt2DShadow:
      begin
        glEnable(GL_TEXTURE_2D);
        if GL_ARB_texture_cube_map then glDisable(GL_TEXTURE_CUBE_MAP_ARB);
        if GL_EXT_texture3D        then glDisable(GL_TEXTURE_3D_EXT);
      end;
    ttCubeMap:
      begin
        glDisable(GL_TEXTURE_2D);
        if GL_ARB_texture_cube_map then glEnable(GL_TEXTURE_CUBE_MAP_ARB);
        if GL_EXT_texture3D        then glDisable(GL_TEXTURE_3D_EXT);
      end;
    tt3D:
      begin
        glDisable(GL_TEXTURE_2D);
        if GL_ARB_texture_cube_map then glDisable(GL_TEXTURE_CUBE_MAP_ARB);
        if GL_EXT_texture3D        then glEnable(GL_TEXTURE_3D_EXT);
      end;
    else raise EInternalError.Create('TextureEnableDisable?');
  end;

  { Enable for shader pipeline }

  Uniform := TUniform.Create;
  Uniform.Name := Format('texture_%d', [TextureUnit]);
  Uniform.AType := utLongInt;
  Uniform.Value.LongInt := TextureUnit;

  AddUniform(Uniform);

  TextureCoordInitialize += Format('gl_TexCoord[%d] = gl_MultiTexCoord%0:d;' + NL,
    [TextureUnit]);
  TextureCoordMatrix += Format('gl_TexCoord[%d] = gl_TextureMatrix[%0:d] * gl_TexCoord[%0:d];' + NL,
    [TextureUnit]);

  if (TextureType = tt2DShadow) and ShadowVisualizeDepth then
  begin
    { visualizing depth map requires a little different approach:
      - we use shadow_depth() instead of shadow() function
      - we *set* gl_FragColor, not modulate it, to ignore previous textures
      - we call "return" after, to ignore following textures
      - the sampler is sampler2D, not sampler2DShadow
      - also, we use gl_FragColor (while we should use fragment_color otherwise),
        because we don't care about previous texture operations and
        we want to return immediately. }
    TextureSampleCall := 'vec4(vec3(shadow_depth(%s, %s)), gl_FragColor.a)';
    TextureApply += Format('gl_FragColor = ' + TextureSampleCall + ';' + NL +
      'return;',
      [Uniform.Name, 'gl_TexCoord[' + IntToStr(TextureUnit) + ']']);
    FragmentShaderDeclare += Format('uniform sampler2D %s;' + NL,
      [Uniform.Name]);
  end else
  begin
    if (TextureType = tt2DShadow) and
       (ShadowLight <> nil) and
       LightShaders.Find(ShadowLight, ShadowLightShader) then
    begin
      Plug('FRAGMENT',
        Format('void PLUG_light_scale(inout float scale, const in vec3 normal_eye, const in vec3 light_dir, const in gl_LightSourceParameters light_source, const in gl_LightProducts light_products, const in gl_MaterialParameters material)' +NL+
        '{' +NL+
        '  scale *= shadow(%s, gl_TexCoord[%d], %d.0);' +NL+
        '}',
        [Uniform.Name, TextureUnit, ShadowMapSize]),
        ShadowLightShader.Code);
    end else
    begin
      if TextureColorDeclare = '' then
        TextureColorDeclare := 'vec4 texture_color;' + NL;
      case TextureType of
        tt2D      : TextureSampleCall := 'texture2D(%s, %s.st)';
        tt2DShadow: TextureSampleCall := 'vec4(vec3(shadow(%s, %s, ' +IntToStr(ShadowMapSize) + '.0)), fragment_color.a)';
        ttCubeMap : TextureSampleCall := 'textureCube(%s, %s.xyz)';
        { For 3D textures, remember we may get 4D tex coords
          through TextureCoordinate4D, so we have to use texture3DProj }
        tt3D      : TextureSampleCall := 'texture3DProj(%s, %s)';
        else raise EInternalError.Create('TVRMLShader.EnableTexture:TextureType?');
      end;

      TextureShader := Format('texture_color = ' + TextureSampleCall + ';' +NL+
        '/* PLUG: texture_color (texture_color, %0:s, %1:s) */' +NL,
        [Uniform.Name, 'gl_TexCoord[' + IntToStr(TextureUnit) + ']']);
      TextureShaderEffects(TextureShader);

      { TODO: always modulate mode for now }
      TextureApply += TextureShader + 'fragment_color *= texture_color;' + NL;
    end;
    FragmentShaderDeclare += Format('uniform %s %s;' + NL,
      [OpenGLTextureType[TextureType], Uniform.Name]);
  end;
end;

procedure TVRMLShader.EnableTexGen(const TextureUnit: Cardinal;
  const Generation: TTexGenerationComplete);
begin
  { Enable for fixed-function pipeline }
  if GLUseMultiTexturing then
    glActiveTextureARB(GL_TEXTURE0 + TextureUnit);
  { glEnable(GL_TEXTURE_GEN_*) below }

  { Enable for shader pipeline }
  case Generation of
    tgSphere:
      begin
        glEnable(GL_TEXTURE_GEN_S);
        glEnable(GL_TEXTURE_GEN_T);
        TextureCoordGen += Format(
          { Sphere mapping in GLSL adapted from
            http://www.ozone3d.net/tutorials/glsl_texturing_p04.php#part_41
            by Jerome Guinot aka 'JeGX', many thanks! }
          'vec3 r = reflect( normalize(vec3(vertex_eye)), normal_eye );' + NL +
	  'float m = 2.0 * sqrt( r.x*r.x + r.y*r.y + (r.z+1.0)*(r.z+1.0) );' + NL +
          '/* Using 1.0 / 2.0 instead of 0.5 to workaround fglrx bugs */' + NL +
	  'gl_TexCoord[%d].st = r.xy / m + vec2(1.0, 1.0) / 2.0;',
          [TextureUnit]);
      end;
    tgNormal:
      begin
        glEnable(GL_TEXTURE_GEN_S);
        glEnable(GL_TEXTURE_GEN_T);
        glEnable(GL_TEXTURE_GEN_R);
        TextureCoordGen += Format('gl_TexCoord[%d].xyz = normal_eye;' + NL,
          [TextureUnit]);
      end;
    tgReflection:
      begin
        glEnable(GL_TEXTURE_GEN_S);
        glEnable(GL_TEXTURE_GEN_T);
        glEnable(GL_TEXTURE_GEN_R);
        { Negate reflect result --- just like for kambi_vrml_test_suite/x3d/water_reflections/water_reflections_normalmap.fs }
        TextureCoordGen += Format('gl_TexCoord[%d].xyz = -reflect(-vec3(vertex_eye), normal_eye);' + NL,
          [TextureUnit]);
      end;
    else raise EInternalError.Create('TVRMLShader.EnableTexGen:Generation?');
  end;
end;

procedure TVRMLShader.EnableTexGen(const TextureUnit: Cardinal;
  const Generation: TTexGenerationComponent; const Component: TTexComponent);
const
  PlaneComponentNames: array [TTexComponent] of char = ('S', 'T', 'R', 'Q');
  { Note: R changes to p ! }
  VectorComponentNames: array [TTexComponent] of char = ('s', 't', 'p', 'q');
var
  PlaneName, Source: string;
begin
  { Enable for fixed-function pipeline }
  if GLUseMultiTexturing then
    glActiveTextureARB(GL_TEXTURE0 + TextureUnit);
  case Component of
    0: glEnable(GL_TEXTURE_GEN_S);
    1: glEnable(GL_TEXTURE_GEN_T);
    2: glEnable(GL_TEXTURE_GEN_R);
    3: glEnable(GL_TEXTURE_GEN_Q);
    else raise EInternalError.Create('TVRMLShader.EnableTexGen:Component?');
  end;

  { Enable for shader pipeline.
    See helpful info about simulating glTexGen in GLSL in:
    http://www.mail-archive.com/osg-users@lists.openscenegraph.org/msg14238.html }

  case Generation of
    tgEye   : begin PlaneName := 'gl_EyePlane'   ; Source := 'vertex_eye'; end;
    tgObject: begin PlaneName := 'gl_ObjectPlane'; Source := 'gl_Vertex' ; end;
    else raise EInternalError.Create('TVRMLShader.EnableTexGen:Generation?');
  end;

  TextureCoordGen += Format('gl_TexCoord[%d].%s = dot(%s, %s%s[%0:d]);' + NL,
    [TextureUnit, VectorComponentNames[Component],
     Source, PlaneName, PlaneComponentNames[Component]]);
end;

procedure TVRMLShader.DisableTexGen(const TextureUnit: Cardinal);
begin
  { Disable for fixed-function pipeline }
  if GLUseMultiTexturing then
    glActiveTextureARB(GL_TEXTURE0 + TextureUnit);
  glDisable(GL_TEXTURE_GEN_S);
  glDisable(GL_TEXTURE_GEN_T);
  glDisable(GL_TEXTURE_GEN_R);
  glDisable(GL_TEXTURE_GEN_Q);
end;

procedure TVRMLShader.EnableClipPlane(const ClipPlaneIndex: Cardinal);
begin
  glEnable(GL_CLIP_PLANE0 + ClipPlaneIndex);
  if ClipPlane = '' then
    ClipPlane := 'gl_ClipVertex = vertex_eye;';
end;

procedure TVRMLShader.DisableClipPlane(const ClipPlaneIndex: Cardinal);
begin
  glDisable(GL_CLIP_PLANE0 + ClipPlaneIndex);
end;

procedure TVRMLShader.EnableAlphaTest;
begin
  { Enable for fixed-function pipeline }
  glEnable(GL_ALPHA_TEST);

  { Enable for shader pipeline. We know alpha comparison is always < 0.5 }
  FragmentEnd +=
    '/* Do the trick with 1.0 / 2.0, instead of comparing with 0.5, to avoid fglrx bugs */' + NL +
    'if (2.0 * gl_FragColor.a < 1.0)' + NL +
    '  discard;' + NL;
end;

procedure TVRMLShader.EnableBumpMapping(const NormalMapTextureUnit: Cardinal);
var
  Uniform: TUniform;
begin
  Plug('VERTEX',
    'attribute mat3 tangent_to_object_space;' +NL+
    'varying mat3 tangent_to_eye_space;' +NL+
    NL+
    'void PLUG_vertex_process(const in vec4 vertex_eye, const in vec3 normal_eye)' +NL+
    '{' +NL+
    '  tangent_to_eye_space = gl_NormalMatrix * tangent_to_object_space;' +NL+
    '}');

  Plug('FRAGMENT',
    'varying mat3 tangent_to_eye_space;' +NL+
    'uniform sampler2D tex_normal_map;' +NL+
    NL+
    'void PLUG_fragment_normal_eye(inout vec3 normal_eye_fragment)' +NL+
    '{' +NL+
    '  /* Read normal from the texture, this is the very idea of bump mapping.' +NL+
    '     Unpack normals, they are in texture in [0..1] range and I want in [-1..1].' +NL+
    '     Our normal map is always indexed using gl_TexCoord[0] (this way' +NL+
    '     we depend on already correct gl_TexCoord[0], multiplied by TextureTransform' +NL+
    '     and such). */' +NL+
    '  normal_eye_fragment = normalize(tangent_to_eye_space * (' +NL+
    '    texture2D(tex_normal_map, gl_TexCoord[0].st).xyz * 2.0 - vec3(1.0)));' +NL+
    '}');

  Uniform := TUniform.Create;
  Uniform.Name := 'tex_normal_map';
  Uniform.AType := utLongInt;
  Uniform.Value.LongInt := NormalMapTextureUnit;

  AddUniform(Uniform);
end;

procedure TVRMLShader.EnableLight(const Number: Cardinal; Node: TNodeX3DLightNode;
  const MaterialSpecularColor: TVector3Single);
var
  LightShader: TLightShader;
  Defines, Code: string;
begin
  Defines := '';
  if Node <> nil then
  begin
    Defines += '#define LIGHT_TYPE_KNOWN' + NL;
    if Node is TVRMLPositionalLightNode then
    begin
      Defines += '#define LIGHT_TYPE_POSITIONAL' + NL;
      if (Node is TNodeSpotLight_1) or
         (Node is TNodeSpotLight_2) then
        Defines  += '#define LIGHT_TYPE_SPOT' + NL;
    end;
    if Node.FdAmbientIntensity.Value <> 0 then
      Defines  += '#define LIGHT_HAS_AMBIENT' + NL;
    if not PerfectlyZeroVector(MaterialSpecularColor) then
      Defines  += '#define LIGHT_HAS_SPECULAR' + NL;
  end else
  begin
    Defines  += '#define LIGHT_HAS_AMBIENT' + NL;
    Defines  += '#define LIGHT_HAS_SPECULAR' + NL;
  end;

  LightShader := TLightShader.Create;
  LightShader.Node := Node;

  Code := Defines + {$I template_add_light.glsl.inc};
  Code := StringReplace(Code, 'light_number', IntToStr(Number), [rfReplaceAll]);
  LightShader.Code.Add(Code);

  if Node <> nil then
    EnableEffects(Node.FdEffects, LightShader.Code);

  if Number >= LightShaders.Count then
    LightShaders.Count := Number + 1;
  LightShaders[Number] := LightShader;

  Inc(LightsEnabled);
end;

procedure TVRMLShader.EnableEffects(Effects: TMFNode;
  const Code: TDynStringArray);

  procedure EnableEffect(Effect: TNodeEffect);

    procedure EnableEffectPart(Part: TNodeEffectPart);
    var
      Contents: string;
    begin
      Contents := Part.LoadContents;
      if Contents <> '' then
        Plug(Part.FdType.Value, Contents, Code);
    end;

  var
    I: Integer;
  begin
    if Effect.FdLanguage.Value <> 'GLSL' then
      VRMLWarning(vwIgnorable, Format('Unknown shading language "%s" for Effect node',
        [Effect.FdLanguage.Value]));

    for I := 0 to Effect.FdParts.Count - 1 do
      if Effect.FdParts[I] is TNodeEffectPart then
        EnableEffectPart(TNodeEffectPart(Effect.FdParts[I]));

    if UniformsNodes = nil then
      UniformsNodes := TVRMLNodesList.Create;
    UniformsNodes.Add(Effect);
  end;

var
  I: Integer;
begin
  for I := 0 to Effects.Count - 1 do
    if Effects[I] is TNodeEffect then
      EnableEffect(TNodeEffect(Effects[I]));
end;

end.
