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
    function GetUTessellation: Integer;
    procedure SetUTessellation(const Value: Integer);
    function GetVTessellation: Integer;
    procedure SetVTessellation(const Value: Integer);
    function GetUClosed: boolean;
    procedure SetUClosed(const Value: boolean);
    function GetUDimension: Integer;
    procedure SetUDimension(const Value: Integer);
    function GetUOrder: Integer;
    procedure SetUOrder(const Value: Integer);
    function GetVClosed: boolean;
    procedure SetVClosed(const Value: boolean);
    function GetVDimension: Integer;
    procedure SetVDimension(const Value: Integer);
    function GetVOrder: Integer;
    procedure SetVOrder(const Value: Integer);
  public
    property UTessellation: Integer read GetUTessellation write SetUTessellation;
    property VTessellation: Integer read GetVTessellation write SetVTessellation;
    property UClosed: boolean read GetUClosed write SetUClosed;
    property UDimension: Integer read GetUDimension write SetUDimension;
    property UOrder: Integer read GetUOrder write SetUOrder;
    property VClosed: boolean read GetVClosed write SetVClosed;
    property VDimension: Integer read GetVDimension write SetVDimension;
    property VOrder: Integer read GetVOrder write SetVOrder;

{$endif read_interface}

{$ifdef read_implementation}

{ TAbstractNurbsSurfaceGeometryNode ----------------------------------------------- }

function TAbstractNurbsSurfaceGeometryNode.GetUTessellation: Integer;
begin
  Result := FdUTessellation.Value;
end;

procedure TAbstractNurbsSurfaceGeometryNode.SetUTessellation(const Value: Integer);
begin
  FdUTessellation.Send(Value);
end;

function TAbstractNurbsSurfaceGeometryNode.GetVTessellation: Integer;
begin
  Result := FdVTessellation.Value;
end;

procedure TAbstractNurbsSurfaceGeometryNode.SetVTessellation(const Value: Integer);
begin
  FdVTessellation.Send(Value);
end;

function TAbstractNurbsSurfaceGeometryNode.GetUClosed: boolean;
begin
  Result := FdUClosed.Value;
end;

procedure TAbstractNurbsSurfaceGeometryNode.SetUClosed(const Value: boolean);
begin
  FdUClosed.Send(Value);
end;

function TAbstractNurbsSurfaceGeometryNode.GetUDimension: Integer;
begin
  Result := FdUDimension.Value;
end;

procedure TAbstractNurbsSurfaceGeometryNode.SetUDimension(const Value: Integer);
begin
  FdUDimension.Send(Value);
end;

function TAbstractNurbsSurfaceGeometryNode.GetUOrder: Integer;
begin
  Result := FdUOrder.Value;
end;

procedure TAbstractNurbsSurfaceGeometryNode.SetUOrder(const Value: Integer);
begin
  FdUOrder.Send(Value);
end;

function TAbstractNurbsSurfaceGeometryNode.GetVClosed: boolean;
begin
  Result := FdVClosed.Value;
end;

procedure TAbstractNurbsSurfaceGeometryNode.SetVClosed(const Value: boolean);
begin
  FdVClosed.Send(Value);
end;

function TAbstractNurbsSurfaceGeometryNode.GetVDimension: Integer;
begin
  Result := FdVDimension.Value;
end;

procedure TAbstractNurbsSurfaceGeometryNode.SetVDimension(const Value: Integer);
begin
  FdVDimension.Send(Value);
end;

function TAbstractNurbsSurfaceGeometryNode.GetVOrder: Integer;
begin
  Result := FdVOrder.Value;
end;

procedure TAbstractNurbsSurfaceGeometryNode.SetVOrder(const Value: Integer);
begin
  FdVOrder.Send(Value);
end;

{$endif read_implementation}