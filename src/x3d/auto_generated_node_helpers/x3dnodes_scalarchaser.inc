{ -*- buffer-read-only: t -*-

  Copyright 2015-2017 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Automatically generated X3D node class helpers.
  Do not edit manually, instead regenerate using
  castle_game_engine/src/x3d/doc/generate_x3d_nodes_to_pascal.lpr . }

{$ifdef read_interface}

  private
    function GetInitialDestination: Single;
    procedure SetInitialDestination(const Value: Single);
    function GetInitialValue: Single;
    procedure SetInitialValue(const Value: Single);
  public
    property InitialDestination: Single read GetInitialDestination write SetInitialDestination;
    property InitialValue: Single read GetInitialValue write SetInitialValue;

{$endif read_interface}

{$ifdef read_implementation}

{ TScalarChaserNode ----------------------------------------------- }

function TScalarChaserNode.GetInitialDestination: Single;
begin
  Result := FdInitialDestination.Value;
end;

procedure TScalarChaserNode.SetInitialDestination(const Value: Single);
begin
  FdInitialDestination.Send(Value);
end;

function TScalarChaserNode.GetInitialValue: Single;
begin
  Result := FdInitialValue.Value;
end;

procedure TScalarChaserNode.SetInitialValue(const Value: Single);
begin
  FdInitialValue.Send(Value);
end;

{$endif read_implementation}