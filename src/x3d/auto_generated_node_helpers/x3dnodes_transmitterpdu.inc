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
    function GetAntennaLocation: TVector3Single;
    procedure SetAntennaLocation(const Value: TVector3Single);
    function GetAntennaPatternLength: Integer;
    procedure SetAntennaPatternLength(const Value: Integer);
    function GetAntennaPatternType: Integer;
    procedure SetAntennaPatternType(const Value: Integer);
    function GetApplicationID: Integer;
    procedure SetApplicationID(const Value: Integer);
    function GetCryptoKeyID: Integer;
    procedure SetCryptoKeyID(const Value: Integer);
    function GetCryptoSystem: Integer;
    procedure SetCryptoSystem(const Value: Integer);
    function GetEntityID: Integer;
    procedure SetEntityID(const Value: Integer);
    function GetFrequency: Integer;
    procedure SetFrequency(const Value: Integer);
    function GetInputSource: Integer;
    procedure SetInputSource(const Value: Integer);
    function GetLengthOfModulationParameters: Integer;
    procedure SetLengthOfModulationParameters(const Value: Integer);
    function GetModulationTypeDetail: Integer;
    procedure SetModulationTypeDetail(const Value: Integer);
    function GetModulationTypeMajor: Integer;
    procedure SetModulationTypeMajor(const Value: Integer);
    function GetModulationTypeSpreadSpectrum: Integer;
    procedure SetModulationTypeSpreadSpectrum(const Value: Integer);
    function GetModulationTypeSystem: Integer;
    procedure SetModulationTypeSystem(const Value: Integer);
    function GetMulticastRelayHost: string;
    procedure SetMulticastRelayHost(const Value: string);
    function GetMulticastRelayPort: Integer;
    procedure SetMulticastRelayPort(const Value: Integer);
    function GetPort: Integer;
    procedure SetPort(const Value: Integer);
    function GetPower: Single;
    procedure SetPower(const Value: Single);
    function GetRadioEntityTypeCategory: Integer;
    procedure SetRadioEntityTypeCategory(const Value: Integer);
    function GetRadioEntityTypeCountry: Integer;
    procedure SetRadioEntityTypeCountry(const Value: Integer);
    function GetRadioEntityTypeDomain: Integer;
    procedure SetRadioEntityTypeDomain(const Value: Integer);
    function GetRadioEntityTypeKind: Integer;
    procedure SetRadioEntityTypeKind(const Value: Integer);
    function GetRadioEntityTypeNomenclature: Integer;
    procedure SetRadioEntityTypeNomenclature(const Value: Integer);
    function GetRadioEntityTypeNomenclatureVersion: Integer;
    procedure SetRadioEntityTypeNomenclatureVersion(const Value: Integer);
    function GetRadioID: Integer;
    procedure SetRadioID(const Value: Integer);
    function GetReadInterval: Single;
    procedure SetReadInterval(const Value: Single);
    function GetRelativeAntennaLocation: TVector3Single;
    procedure SetRelativeAntennaLocation(const Value: TVector3Single);
    function GetRtpHeaderExpected: boolean;
    procedure SetRtpHeaderExpected(const Value: boolean);
    function GetSiteID: Integer;
    procedure SetSiteID(const Value: Integer);
    function GetTransmitFrequencyBandwidth: Single;
    procedure SetTransmitFrequencyBandwidth(const Value: Single);
    function GetTransmitState: Integer;
    procedure SetTransmitState(const Value: Integer);
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
    property AntennaLocation: TVector3Single read GetAntennaLocation write SetAntennaLocation;
    property AntennaPatternLength: Integer read GetAntennaPatternLength write SetAntennaPatternLength;
    property AntennaPatternType: Integer read GetAntennaPatternType write SetAntennaPatternType;
    property ApplicationID: Integer read GetApplicationID write SetApplicationID;
    property CryptoKeyID: Integer read GetCryptoKeyID write SetCryptoKeyID;
    property CryptoSystem: Integer read GetCryptoSystem write SetCryptoSystem;
    property EntityID: Integer read GetEntityID write SetEntityID;
    property Frequency: Integer read GetFrequency write SetFrequency;
    property InputSource: Integer read GetInputSource write SetInputSource;
    property LengthOfModulationParameters: Integer read GetLengthOfModulationParameters write SetLengthOfModulationParameters;
    property ModulationTypeDetail: Integer read GetModulationTypeDetail write SetModulationTypeDetail;
    property ModulationTypeMajor: Integer read GetModulationTypeMajor write SetModulationTypeMajor;
    property ModulationTypeSpreadSpectrum: Integer read GetModulationTypeSpreadSpectrum write SetModulationTypeSpreadSpectrum;
    property ModulationTypeSystem: Integer read GetModulationTypeSystem write SetModulationTypeSystem;
    property MulticastRelayHost: string read GetMulticastRelayHost write SetMulticastRelayHost;
    property MulticastRelayPort: Integer read GetMulticastRelayPort write SetMulticastRelayPort;
    property Port: Integer read GetPort write SetPort;
    property Power: Single read GetPower write SetPower;
    property RadioEntityTypeCategory: Integer read GetRadioEntityTypeCategory write SetRadioEntityTypeCategory;
    property RadioEntityTypeCountry: Integer read GetRadioEntityTypeCountry write SetRadioEntityTypeCountry;
    property RadioEntityTypeDomain: Integer read GetRadioEntityTypeDomain write SetRadioEntityTypeDomain;
    property RadioEntityTypeKind: Integer read GetRadioEntityTypeKind write SetRadioEntityTypeKind;
    property RadioEntityTypeNomenclature: Integer read GetRadioEntityTypeNomenclature write SetRadioEntityTypeNomenclature;
    property RadioEntityTypeNomenclatureVersion: Integer read GetRadioEntityTypeNomenclatureVersion write SetRadioEntityTypeNomenclatureVersion;
    property RadioID: Integer read GetRadioID write SetRadioID;
    property ReadInterval: Single read GetReadInterval write SetReadInterval;
    property RelativeAntennaLocation: TVector3Single read GetRelativeAntennaLocation write SetRelativeAntennaLocation;
    property RtpHeaderExpected: boolean read GetRtpHeaderExpected write SetRtpHeaderExpected;
    property SiteID: Integer read GetSiteID write SetSiteID;
    property TransmitFrequencyBandwidth: Single read GetTransmitFrequencyBandwidth write SetTransmitFrequencyBandwidth;
    property TransmitState: Integer read GetTransmitState write SetTransmitState;
    property WhichGeometry: Integer read GetWhichGeometry write SetWhichGeometry;
    property WriteInterval: Single read GetWriteInterval write SetWriteInterval;
    property BboxCenter: TVector3Single read GetBboxCenter write SetBboxCenter;
    property BboxSize: TVector3Single read GetBboxSize write SetBboxSize;

{$endif read_interface}

{$ifdef read_implementation}

{ TTransmitterPduNode ----------------------------------------------- }

function TTransmitterPduNode.GetAddress: string;
begin
  Result := FdAddress.Value;
end;

procedure TTransmitterPduNode.SetAddress(const Value: string);
begin
  FdAddress.Send(Value);
end;

function TTransmitterPduNode.GetAntennaLocation: TVector3Single;
begin
  Result := FdAntennaLocation.Value;
end;

procedure TTransmitterPduNode.SetAntennaLocation(const Value: TVector3Single);
begin
  FdAntennaLocation.Send(Value);
end;

function TTransmitterPduNode.GetAntennaPatternLength: Integer;
begin
  Result := FdAntennaPatternLength.Value;
end;

procedure TTransmitterPduNode.SetAntennaPatternLength(const Value: Integer);
begin
  FdAntennaPatternLength.Send(Value);
end;

function TTransmitterPduNode.GetAntennaPatternType: Integer;
begin
  Result := FdAntennaPatternType.Value;
end;

procedure TTransmitterPduNode.SetAntennaPatternType(const Value: Integer);
begin
  FdAntennaPatternType.Send(Value);
end;

function TTransmitterPduNode.GetApplicationID: Integer;
begin
  Result := FdApplicationID.Value;
end;

procedure TTransmitterPduNode.SetApplicationID(const Value: Integer);
begin
  FdApplicationID.Send(Value);
end;

function TTransmitterPduNode.GetCryptoKeyID: Integer;
begin
  Result := FdCryptoKeyID.Value;
end;

procedure TTransmitterPduNode.SetCryptoKeyID(const Value: Integer);
begin
  FdCryptoKeyID.Send(Value);
end;

function TTransmitterPduNode.GetCryptoSystem: Integer;
begin
  Result := FdCryptoSystem.Value;
end;

procedure TTransmitterPduNode.SetCryptoSystem(const Value: Integer);
begin
  FdCryptoSystem.Send(Value);
end;

function TTransmitterPduNode.GetEntityID: Integer;
begin
  Result := FdEntityID.Value;
end;

procedure TTransmitterPduNode.SetEntityID(const Value: Integer);
begin
  FdEntityID.Send(Value);
end;

function TTransmitterPduNode.GetFrequency: Integer;
begin
  Result := FdFrequency.Value;
end;

procedure TTransmitterPduNode.SetFrequency(const Value: Integer);
begin
  FdFrequency.Send(Value);
end;

function TTransmitterPduNode.GetInputSource: Integer;
begin
  Result := FdInputSource.Value;
end;

procedure TTransmitterPduNode.SetInputSource(const Value: Integer);
begin
  FdInputSource.Send(Value);
end;

function TTransmitterPduNode.GetLengthOfModulationParameters: Integer;
begin
  Result := FdLengthOfModulationParameters.Value;
end;

procedure TTransmitterPduNode.SetLengthOfModulationParameters(const Value: Integer);
begin
  FdLengthOfModulationParameters.Send(Value);
end;

function TTransmitterPduNode.GetModulationTypeDetail: Integer;
begin
  Result := FdModulationTypeDetail.Value;
end;

procedure TTransmitterPduNode.SetModulationTypeDetail(const Value: Integer);
begin
  FdModulationTypeDetail.Send(Value);
end;

function TTransmitterPduNode.GetModulationTypeMajor: Integer;
begin
  Result := FdModulationTypeMajor.Value;
end;

procedure TTransmitterPduNode.SetModulationTypeMajor(const Value: Integer);
begin
  FdModulationTypeMajor.Send(Value);
end;

function TTransmitterPduNode.GetModulationTypeSpreadSpectrum: Integer;
begin
  Result := FdModulationTypeSpreadSpectrum.Value;
end;

procedure TTransmitterPduNode.SetModulationTypeSpreadSpectrum(const Value: Integer);
begin
  FdModulationTypeSpreadSpectrum.Send(Value);
end;

function TTransmitterPduNode.GetModulationTypeSystem: Integer;
begin
  Result := FdModulationTypeSystem.Value;
end;

procedure TTransmitterPduNode.SetModulationTypeSystem(const Value: Integer);
begin
  FdModulationTypeSystem.Send(Value);
end;

function TTransmitterPduNode.GetMulticastRelayHost: string;
begin
  Result := FdMulticastRelayHost.Value;
end;

procedure TTransmitterPduNode.SetMulticastRelayHost(const Value: string);
begin
  FdMulticastRelayHost.Send(Value);
end;

function TTransmitterPduNode.GetMulticastRelayPort: Integer;
begin
  Result := FdMulticastRelayPort.Value;
end;

procedure TTransmitterPduNode.SetMulticastRelayPort(const Value: Integer);
begin
  FdMulticastRelayPort.Send(Value);
end;

function TTransmitterPduNode.GetPort: Integer;
begin
  Result := FdPort.Value;
end;

procedure TTransmitterPduNode.SetPort(const Value: Integer);
begin
  FdPort.Send(Value);
end;

function TTransmitterPduNode.GetPower: Single;
begin
  Result := FdPower.Value;
end;

procedure TTransmitterPduNode.SetPower(const Value: Single);
begin
  FdPower.Send(Value);
end;

function TTransmitterPduNode.GetRadioEntityTypeCategory: Integer;
begin
  Result := FdRadioEntityTypeCategory.Value;
end;

procedure TTransmitterPduNode.SetRadioEntityTypeCategory(const Value: Integer);
begin
  FdRadioEntityTypeCategory.Send(Value);
end;

function TTransmitterPduNode.GetRadioEntityTypeCountry: Integer;
begin
  Result := FdRadioEntityTypeCountry.Value;
end;

procedure TTransmitterPduNode.SetRadioEntityTypeCountry(const Value: Integer);
begin
  FdRadioEntityTypeCountry.Send(Value);
end;

function TTransmitterPduNode.GetRadioEntityTypeDomain: Integer;
begin
  Result := FdRadioEntityTypeDomain.Value;
end;

procedure TTransmitterPduNode.SetRadioEntityTypeDomain(const Value: Integer);
begin
  FdRadioEntityTypeDomain.Send(Value);
end;

function TTransmitterPduNode.GetRadioEntityTypeKind: Integer;
begin
  Result := FdRadioEntityTypeKind.Value;
end;

procedure TTransmitterPduNode.SetRadioEntityTypeKind(const Value: Integer);
begin
  FdRadioEntityTypeKind.Send(Value);
end;

function TTransmitterPduNode.GetRadioEntityTypeNomenclature: Integer;
begin
  Result := FdRadioEntityTypeNomenclature.Value;
end;

procedure TTransmitterPduNode.SetRadioEntityTypeNomenclature(const Value: Integer);
begin
  FdRadioEntityTypeNomenclature.Send(Value);
end;

function TTransmitterPduNode.GetRadioEntityTypeNomenclatureVersion: Integer;
begin
  Result := FdRadioEntityTypeNomenclatureVersion.Value;
end;

procedure TTransmitterPduNode.SetRadioEntityTypeNomenclatureVersion(const Value: Integer);
begin
  FdRadioEntityTypeNomenclatureVersion.Send(Value);
end;

function TTransmitterPduNode.GetRadioID: Integer;
begin
  Result := FdRadioID.Value;
end;

procedure TTransmitterPduNode.SetRadioID(const Value: Integer);
begin
  FdRadioID.Send(Value);
end;

function TTransmitterPduNode.GetReadInterval: Single;
begin
  Result := FdReadInterval.Value;
end;

procedure TTransmitterPduNode.SetReadInterval(const Value: Single);
begin
  FdReadInterval.Send(Value);
end;

function TTransmitterPduNode.GetRelativeAntennaLocation: TVector3Single;
begin
  Result := FdRelativeAntennaLocation.Value;
end;

procedure TTransmitterPduNode.SetRelativeAntennaLocation(const Value: TVector3Single);
begin
  FdRelativeAntennaLocation.Send(Value);
end;

function TTransmitterPduNode.GetRtpHeaderExpected: boolean;
begin
  Result := FdRtpHeaderExpected.Value;
end;

procedure TTransmitterPduNode.SetRtpHeaderExpected(const Value: boolean);
begin
  FdRtpHeaderExpected.Send(Value);
end;

function TTransmitterPduNode.GetSiteID: Integer;
begin
  Result := FdSiteID.Value;
end;

procedure TTransmitterPduNode.SetSiteID(const Value: Integer);
begin
  FdSiteID.Send(Value);
end;

function TTransmitterPduNode.GetTransmitFrequencyBandwidth: Single;
begin
  Result := FdTransmitFrequencyBandwidth.Value;
end;

procedure TTransmitterPduNode.SetTransmitFrequencyBandwidth(const Value: Single);
begin
  FdTransmitFrequencyBandwidth.Send(Value);
end;

function TTransmitterPduNode.GetTransmitState: Integer;
begin
  Result := FdTransmitState.Value;
end;

procedure TTransmitterPduNode.SetTransmitState(const Value: Integer);
begin
  FdTransmitState.Send(Value);
end;

function TTransmitterPduNode.GetWhichGeometry: Integer;
begin
  Result := FdWhichGeometry.Value;
end;

procedure TTransmitterPduNode.SetWhichGeometry(const Value: Integer);
begin
  FdWhichGeometry.Send(Value);
end;

function TTransmitterPduNode.GetWriteInterval: Single;
begin
  Result := FdWriteInterval.Value;
end;

procedure TTransmitterPduNode.SetWriteInterval(const Value: Single);
begin
  FdWriteInterval.Send(Value);
end;

function TTransmitterPduNode.GetBboxCenter: TVector3Single;
begin
  Result := FdBboxCenter.Value;
end;

procedure TTransmitterPduNode.SetBboxCenter(const Value: TVector3Single);
begin
  FdBboxCenter.Send(Value);
end;

function TTransmitterPduNode.GetBboxSize: TVector3Single;
begin
  Result := FdBboxSize.Value;
end;

procedure TTransmitterPduNode.SetBboxSize(const Value: TVector3Single);
begin
  FdBboxSize.Send(Value);
end;

{$endif read_implementation}