{
  Copyright 2009-2019 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Scene manager (TCastleSceneManager) and viewport (TCastleViewport) classes. }
unit CastleSceneManager deprecated 'use CastleViewport';

{$I castleconf.inc}

interface

uses SysUtils,
  CastleViewport, CastleScene;

type
  TCastleViewport             = CastleViewport.TCastleViewport;
  TCastleAbstractViewport     = CastleViewport.TCastleViewport;
  {$warnings off} // only to keep deprecated working
  TCastleSceneManager         = CastleViewport.TCastleSceneManager;
  TCastleAbstractViewportList = CastleViewport.TCastleViewportList;
  {$warnings on}
  TRender3DEvent              = CastleViewport.TRender3DEvent;
  TManagerRenderParams        = CastleViewport.TManagerRenderParams;
  TProjectionEvent            = CastleViewport.TProjectionEvent;
  TUseHeadlight               = CastleScene.TUseHeadlight;

  EViewportSceneManagerMissing = class(Exception)
  end deprecated 'this is never raised anymore';

const
  hlOn        = CastleScene.hlOn;
  hlOff       = CastleScene.hlOff;
  hlMainScene = CastleScene.hlMainScene;

implementation

end.
