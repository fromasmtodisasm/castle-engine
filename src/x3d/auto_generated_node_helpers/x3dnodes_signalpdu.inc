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
    function GetDataLength: Integer;
    procedure SetDataLength(const Value: Integer);
    function GetEncodingScheme: Integer;
    procedure SetEncodingScheme(const Value: Integer);
    function GetEntityID: Integer;
    procedure SetEntityID(const Value: Integer);
    function GetMulticastRelayHost: string;
    procedure SetMulticastRelayHost(const Value: string);
    function GetMulticastRelayPort: Integer;
    procedure SetMulticastRelayPort(const Value: Integer);
    function GetPort: Integer;
    procedure SetPort(const Value: Integer);
    function GetRadioID: Integer;
    procedure SetRadioID(const Value: Integer);
    function GetReadInterval: Single;
    procedure SetReadInterval(const Value: Single);
    function GetRtpHeaderExpected: boolean;
    procedure SetRtpHeaderExpected(const Value: boolean);
    function GetSampleRate: Integer;
    procedure SetSampleRate(const Value: Integer);
    function GetSamples: Integer;
    procedure SetSamples(const Value: Integer);
    function GetSiteID: Integer;
    procedure SetSiteID(const Value: Integer);
    function GetTdlType: Integer;
    procedure SetTdlType(const Value: Integer);
    function GetWhichGeometry: Integer;
    procedure SetWhichGeometry(const Value: Integer);
    function GetWriteInterval: Single;
    procedure SetWriteInterval(const Value: Single);
    function GetBboxCenter: TVector3Single;
    procedure SetBboxCenter(const Value: TVector3Single);
    function GetBboxSize: TVector3Single;
    procedure SetBboxSize(const Value: TVector3Single);
  public
    property Address: string read GetAddress write SetAddress;
    property ApplicationID: Integer read GetApplicationID write SetApplicationID;
    property DataLength: Integer read GetDataLength write SetDataLength;
    property EncodingScheme: Integer read GetEncodingScheme write SetEncodingScheme;
    property EntityID: Integer read GetEntityID write SetEntityID;
    property MulticastRelayHost: string read GetMulticastRelayHost write SetMulticastRelayHost;
    property MulticastRelayPort: Integer read GetMulticastRelayPort write SetMulticastRelayPort;
    property Port: Integer read GetPort write SetPort;
    property RadioID: Integer read GetRadioID write SetRadioID;
    property ReadInterval: Single read GetReadInterval write SetReadInterval;
    property RtpHeaderExpected: boolean read GetRtpHeaderExpected write SetRtpHeaderExpected;
    property SampleRate: Integer read GetSampleRate write SetSampleRate;
    property Samples: Integer read GetSamples write SetSamples;
    property SiteID: Integer read GetSiteID write SetSiteID;
    property TdlType: Integer read GetTdlType write SetTdlType;
    property WhichGeometry: Integer read GetWhichGeometry write SetWhichGeometry;
    property WriteInterval: Single read GetWriteInterval write SetWriteInterval;
    property BboxCenter: TVector3Single read GetBboxCenter write SetBboxCenter;
    property BboxSize: TVector3Single read GetBboxSize write SetBboxSize;

{$endif read_interface}

{$ifdef read_implementation}

{ TSignalPduNode ----------------------------------------------- }

function TSignalPduNode.GetAddress: string;
begin
  Result := FdAddress.Value;
end;

procedure TSignalPduNode.SetAddress(const Value: string);
begin
  FdAddress.Send(Value);
end;

function TSignalPduNode.GetApplicationID: Integer;
begin
  Result := FdApplicationID.Value;
end;

procedure TSignalPduNode.SetApplicationID(const Value: Integer);
begin
  FdApplicationID.Send(Value);
end;

function TSignalPduNode.GetDataLength: Integer;
begin
  Result := FdDataLength.Value;
end;

procedure TSignalPduNode.SetDataLength(const Value: Integer);
begin
  FdDataLength.Send(Value);
end;

function TSignalPduNode.GetEncodingScheme: Integer;
begin
  Result := FdEncodingScheme.Value;
end;

procedure TSignalPduNode.SetEncodingScheme(const Value: Integer);
begin
  FdEncodingScheme.Send(Value);
end;

function TSignalPduNode.GetEntityID: Integer;
begin
  Result := FdEntityID.Value;
end;

procedure TSignalPduNode.SetEntityID(const Value: Integer);
begin
  FdEntityID.Send(Value);
end;

function TSignalPduNode.GetMulticastRelayHost: string;
begin
  Result := FdMulticastRelayHost.Value;
end;

procedure TSignalPduNode.SetMulticastRelayHost(const Value: string);
begin
  FdMulticastRelayHost.Send(Value);
end;

function TSignalPduNode.GetMulticastRelayPort: Integer;
begin
  Result := FdMulticastRelayPort.Value;
end;

procedure TSignalPduNode.SetMulticastRelayPort(const Value: Integer);
begin
  FdMulticastRelayPort.Send(Value);
end;

function TSignalPduNode.GetPort: Integer;
begin
  Result := FdPort.Value;
end;

procedure TSignalPduNode.SetPort(const Value: Integer);
begin
  FdPort.Send(Value);
end;

function TSignalPduNode.GetRadioID: Integer;
begin
  Result := FdRadioID.Value;
end;

procedure TSignalPduNode.SetRadioID(const Value: Integer);
begin
  FdRadioID.Send(Value);
end;

function TSignalPduNode.GetReadInterval: Single;
begin
  Result := FdReadInterval.Value;
end;

procedure TSignalPduNode.SetReadInterval(const Value: Single);
begin
  FdReadInterval.Send(Value);
end;

function TSignalPduNode.GetRtpHeaderExpected: boolean;
begin
  Result := FdRtpHeaderExpected.Value;
end;

procedure TSignalPduNode.SetRtpHeaderExpected(const Value: boolean);
begin
  FdRtpHeaderExpected.Send(Value);
end;

function TSignalPduNode.GetSampleRate: Integer;
begin
  Result := FdSampleRate.Value;
end;

procedure TSignalPduNode.SetSampleRate(const Value: Integer);
begin
  FdSampleRate.Send(Value);
end;

function TSignalPduNode.GetSamples: Integer;
begin
  Result := FdSamples.Value;
end;

procedure TSignalPduNode.SetSamples(const Value: Integer);
begin
  FdSamples.Send(Value);
end;

function TSignalPduNode.GetSiteID: Integer;
begin
  Result := FdSiteID.Value;
end;

procedure TSignalPduNode.SetSiteID(const Value: Integer);
begin
  FdSiteID.Send(Value);
end;

function TSignalPduNode.GetTdlType: Integer;
begin
  Result := FdTdlType.Value;
end;

procedure TSignalPduNode.SetTdlType(const Value: Integer);
begin
  FdTdlType.Send(Value);
end;

function TSignalPduNode.GetWhichGeometry: Integer;
begin
  Result := FdWhichGeometry.Value;
end;

procedure TSignalPduNode.SetWhichGeometry(const Value: Integer);
begin
  FdWhichGeometry.Send(Value);
end;

function TSignalPduNode.GetWriteInterval: Single;
begin
  Result := FdWriteInterval.Value;
end;

procedure TSignalPduNode.SetWriteInterval(const Value: Single);
begin
  FdWriteInterval.Send(Value);
end;

function TSignalPduNode.GetBboxCenter: TVector3Single;
begin
  Result := FdBboxCenter.Value;
end;

procedure TSignalPduNode.SetBboxCenter(const Value: TVector3Single);
begin
  FdBboxCenter.Send(Value);
end;

function TSignalPduNode.GetBboxSize: TVector3Single;
begin
  Result := FdBboxSize.Value;
end;

procedure TSignalPduNode.SetBboxSize(const Value: TVector3Single);
begin
  FdBboxSize.Send(Value);
end;

{$endif read_implementation}