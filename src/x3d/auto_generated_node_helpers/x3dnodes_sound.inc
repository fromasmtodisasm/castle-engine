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
    function GetDirection: TVector3Single;
    procedure SetDirection(const Value: TVector3Single);
    function GetIntensity: Single;
    procedure SetIntensity(const Value: Single);
    function GetLocation: TVector3Single;
    procedure SetLocation(const Value: TVector3Single);
    function GetMaxBack: Single;
    procedure SetMaxBack(const Value: Single);
    function GetMaxFront: Single;
    procedure SetMaxFront(const Value: Single);
    function GetMinBack: Single;
    procedure SetMinBack(const Value: Single);
    function GetMinFront: Single;
    procedure SetMinFront(const Value: Single);
    function GetPriority: Single;
    procedure SetPriority(const Value: Single);
    function GetSpatialize: boolean;
    procedure SetSpatialize(const Value: boolean);
  public
    property Direction: TVector3Single read GetDirection write SetDirection;
    property Intensity: Single read GetIntensity write SetIntensity;
    property Location: TVector3Single read GetLocation write SetLocation;
    property MaxBack: Single read GetMaxBack write SetMaxBack;
    property MaxFront: Single read GetMaxFront write SetMaxFront;
    property MinBack: Single read GetMinBack write SetMinBack;
    property MinFront: Single read GetMinFront write SetMinFront;
    property Priority: Single read GetPriority write SetPriority;
    property Spatialize: boolean read GetSpatialize write SetSpatialize;

{$endif read_interface}

{$ifdef read_implementation}

{ TSoundNode ----------------------------------------------- }

function TSoundNode.GetDirection: TVector3Single;
begin
  Result := FdDirection.Value;
end;

procedure TSoundNode.SetDirection(const Value: TVector3Single);
begin
  FdDirection.Send(Value);
end;

function TSoundNode.GetIntensity: Single;
begin
  Result := FdIntensity.Value;
end;

procedure TSoundNode.SetIntensity(const Value: Single);
begin
  FdIntensity.Send(Value);
end;

function TSoundNode.GetLocation: TVector3Single;
begin
  Result := FdLocation.Value;
end;

procedure TSoundNode.SetLocation(const Value: TVector3Single);
begin
  FdLocation.Send(Value);
end;

function TSoundNode.GetMaxBack: Single;
begin
  Result := FdMaxBack.Value;
end;

procedure TSoundNode.SetMaxBack(const Value: Single);
begin
  FdMaxBack.Send(Value);
end;

function TSoundNode.GetMaxFront: Single;
begin
  Result := FdMaxFront.Value;
end;

procedure TSoundNode.SetMaxFront(const Value: Single);
begin
  FdMaxFront.Send(Value);
end;

function TSoundNode.GetMinBack: Single;
begin
  Result := FdMinBack.Value;
end;

procedure TSoundNode.SetMinBack(const Value: Single);
begin
  FdMinBack.Send(Value);
end;

function TSoundNode.GetMinFront: Single;
begin
  Result := FdMinFront.Value;
end;

procedure TSoundNode.SetMinFront(const Value: Single);
begin
  FdMinFront.Send(Value);
end;

function TSoundNode.GetPriority: Single;
begin
  Result := FdPriority.Value;
end;

procedure TSoundNode.SetPriority(const Value: Single);
begin
  FdPriority.Send(Value);
end;

function TSoundNode.GetSpatialize: boolean;
begin
  Result := FdSpatialize.Value;
end;

procedure TSoundNode.SetSpatialize(const Value: boolean);
begin
  FdSpatialize.Send(Value);
end;

{$endif read_implementation}