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
    function GetInitialDestination: TVector2Single;
    procedure SetInitialDestination(const Value: TVector2Single);
    function GetInitialValue: TVector2Single;
    procedure SetInitialValue(const Value: TVector2Single);
  public
    property InitialDestination: TVector2Single read GetInitialDestination write SetInitialDestination;
    property InitialValue: TVector2Single read GetInitialValue write SetInitialValue;

{$endif read_interface}

{$ifdef read_implementation}

{ TPositionChaser2DNode ----------------------------------------------- }

function TPositionChaser2DNode.GetInitialDestination: TVector2Single;
begin
  Result := FdInitialDestination.Value;
end;

procedure TPositionChaser2DNode.SetInitialDestination(const Value: TVector2Single);
begin
  FdInitialDestination.Send(Value);
end;

function TPositionChaser2DNode.GetInitialValue: TVector2Single;
begin
  Result := FdInitialValue.Value;
end;

procedure TPositionChaser2DNode.SetInitialValue(const Value: TVector2Single);
begin
  FdInitialValue.Send(Value);
end;

{$endif read_implementation}