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
    function GetUDimension: Integer;
    procedure SetUDimension(const Value: Integer);
    function GetUOrder: Integer;
    procedure SetUOrder(const Value: Integer);
    function GetVDimension: Integer;
    procedure SetVDimension(const Value: Integer);
    function GetVOrder: Integer;
    procedure SetVOrder(const Value: Integer);
  public
    property UDimension: Integer read GetUDimension write SetUDimension;
    property UOrder: Integer read GetUOrder write SetUOrder;
    property VDimension: Integer read GetVDimension write SetVDimension;
    property VOrder: Integer read GetVOrder write SetVOrder;

{$endif read_interface}

{$ifdef read_implementation}

{ TNurbsTextureCoordinateNode ----------------------------------------------- }

function TNurbsTextureCoordinateNode.GetUDimension: Integer;
begin
  Result := FdUDimension.Value;
end;

procedure TNurbsTextureCoordinateNode.SetUDimension(const Value: Integer);
begin
  FdUDimension.Send(Value);
end;

function TNurbsTextureCoordinateNode.GetUOrder: Integer;
begin
  Result := FdUOrder.Value;
end;

procedure TNurbsTextureCoordinateNode.SetUOrder(const Value: Integer);
begin
  FdUOrder.Send(Value);
end;

function TNurbsTextureCoordinateNode.GetVDimension: Integer;
begin
  Result := FdVDimension.Value;
end;

procedure TNurbsTextureCoordinateNode.SetVDimension(const Value: Integer);
begin
  FdVDimension.Send(Value);
end;

function TNurbsTextureCoordinateNode.GetVOrder: Integer;
begin
  Result := FdVOrder.Value;
end;

procedure TNurbsTextureCoordinateNode.SetVOrder(const Value: Integer);
begin
  FdVOrder.Send(Value);
end;

{$endif read_implementation}