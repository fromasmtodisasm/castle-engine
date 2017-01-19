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
    function GetAnisotropicDegree: Single;
    procedure SetAnisotropicDegree(const Value: Single);
    function GetBorderColor: TCastleColor;
    procedure SetBorderColor(const Value: TCastleColor);
    function GetBorderWidth: Integer;
    procedure SetBorderWidth(const Value: Integer);
    function GetBoundaryModeS: string;
    procedure SetBoundaryModeS(const Value: string);
    function GetBoundaryModeT: string;
    procedure SetBoundaryModeT(const Value: string);
    function GetBoundaryModeR: string;
    procedure SetBoundaryModeR(const Value: string);
    function GetMagnificationFilter: string;
    procedure SetMagnificationFilter(const Value: string);
    function GetMinificationFilter: string;
    procedure SetMinificationFilter(const Value: string);
    function GetTextureCompression: string;
    procedure SetTextureCompression(const Value: string);
    function GetTexturePriority: Single;
    procedure SetTexturePriority(const Value: Single);
    function GetGenerateMipMaps: boolean;
    procedure SetGenerateMipMaps(const Value: boolean);
  public
    property AnisotropicDegree: Single read GetAnisotropicDegree write SetAnisotropicDegree;
    property BorderColor: TCastleColor read GetBorderColor write SetBorderColor;
    property BorderWidth: Integer read GetBorderWidth write SetBorderWidth;
    property BoundaryModeS: string read GetBoundaryModeS write SetBoundaryModeS;
    property BoundaryModeT: string read GetBoundaryModeT write SetBoundaryModeT;
    property BoundaryModeR: string read GetBoundaryModeR write SetBoundaryModeR;
    property MagnificationFilter: string read GetMagnificationFilter write SetMagnificationFilter;
    property MinificationFilter: string read GetMinificationFilter write SetMinificationFilter;
    property TextureCompression: string read GetTextureCompression write SetTextureCompression;
    property TexturePriority: Single read GetTexturePriority write SetTexturePriority;
    property GenerateMipMaps: boolean read GetGenerateMipMaps write SetGenerateMipMaps;

{$endif read_interface}

{$ifdef read_implementation}

{ TTexturePropertiesNode ----------------------------------------------- }

function TTexturePropertiesNode.GetAnisotropicDegree: Single;
begin
  Result := FdAnisotropicDegree.Value;
end;

procedure TTexturePropertiesNode.SetAnisotropicDegree(const Value: Single);
begin
  FdAnisotropicDegree.Send(Value);
end;

function TTexturePropertiesNode.GetBorderColor: TCastleColor;
begin
  Result := FdBorderColor.Value;
end;

procedure TTexturePropertiesNode.SetBorderColor(const Value: TCastleColor);
begin
  FdBorderColor.Send(Value);
end;

function TTexturePropertiesNode.GetBorderWidth: Integer;
begin
  Result := FdBorderWidth.Value;
end;

procedure TTexturePropertiesNode.SetBorderWidth(const Value: Integer);
begin
  FdBorderWidth.Send(Value);
end;

function TTexturePropertiesNode.GetBoundaryModeS: string;
begin
  Result := FdBoundaryModeS.Value;
end;

procedure TTexturePropertiesNode.SetBoundaryModeS(const Value: string);
begin
  FdBoundaryModeS.Send(Value);
end;

function TTexturePropertiesNode.GetBoundaryModeT: string;
begin
  Result := FdBoundaryModeT.Value;
end;

procedure TTexturePropertiesNode.SetBoundaryModeT(const Value: string);
begin
  FdBoundaryModeT.Send(Value);
end;

function TTexturePropertiesNode.GetBoundaryModeR: string;
begin
  Result := FdBoundaryModeR.Value;
end;

procedure TTexturePropertiesNode.SetBoundaryModeR(const Value: string);
begin
  FdBoundaryModeR.Send(Value);
end;

function TTexturePropertiesNode.GetMagnificationFilter: string;
begin
  Result := FdMagnificationFilter.Value;
end;

procedure TTexturePropertiesNode.SetMagnificationFilter(const Value: string);
begin
  FdMagnificationFilter.Send(Value);
end;

function TTexturePropertiesNode.GetMinificationFilter: string;
begin
  Result := FdMinificationFilter.Value;
end;

procedure TTexturePropertiesNode.SetMinificationFilter(const Value: string);
begin
  FdMinificationFilter.Send(Value);
end;

function TTexturePropertiesNode.GetTextureCompression: string;
begin
  Result := FdTextureCompression.Value;
end;

procedure TTexturePropertiesNode.SetTextureCompression(const Value: string);
begin
  FdTextureCompression.Send(Value);
end;

function TTexturePropertiesNode.GetTexturePriority: Single;
begin
  Result := FdTexturePriority.Value;
end;

procedure TTexturePropertiesNode.SetTexturePriority(const Value: Single);
begin
  FdTexturePriority.Send(Value);
end;

function TTexturePropertiesNode.GetGenerateMipMaps: boolean;
begin
  Result := FdGenerateMipMaps.Value;
end;

procedure TTexturePropertiesNode.SetGenerateMipMaps(const Value: boolean);
begin
  FdGenerateMipMaps.Send(Value);
end;

{$endif read_implementation}