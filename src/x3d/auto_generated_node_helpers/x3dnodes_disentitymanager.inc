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
    function GetAddress: string;
    procedure SetAddress(const Value: string);
    function GetApplicationID: Integer;
    procedure SetApplicationID(const Value: Integer);
    function GetPort: Integer;
    procedure SetPort(const Value: Integer);
    function GetSiteID: Integer;
    procedure SetSiteID(const Value: Integer);
  public
    property Address: string read GetAddress write SetAddress;
    property ApplicationID: Integer read GetApplicationID write SetApplicationID;
    property Port: Integer read GetPort write SetPort;
    property SiteID: Integer read GetSiteID write SetSiteID;

{$endif read_interface}

{$ifdef read_implementation}

{ TDISEntityManagerNode ----------------------------------------------- }

function TDISEntityManagerNode.GetAddress: string;
begin
  Result := FdAddress.Value;
end;

procedure TDISEntityManagerNode.SetAddress(const Value: string);
begin
  FdAddress.Send(Value);
end;

function TDISEntityManagerNode.GetApplicationID: Integer;
begin
  Result := FdApplicationID.Value;
end;

procedure TDISEntityManagerNode.SetApplicationID(const Value: Integer);
begin
  FdApplicationID.Send(Value);
end;

function TDISEntityManagerNode.GetPort: Integer;
begin
  Result := FdPort.Value;
end;

procedure TDISEntityManagerNode.SetPort(const Value: Integer);
begin
  FdPort.Send(Value);
end;

function TDISEntityManagerNode.GetSiteID: Integer;
begin
  Result := FdSiteID.Value;
end;

procedure TDISEntityManagerNode.SetSiteID(const Value: Integer);
begin
  FdSiteID.Send(Value);
end;

{$endif read_implementation}