// This is part of the Obo Component Library
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// This software is distributed without any warranty.
//
// @author Domenico Mammola (mimmo71@gmail.com - www.mammola.net)
unit Biru;

{$ifdef fpc}
  {$mode delphi}
{$endif}
interface

uses
  {$ifdef windows}Windows,{$endif}
  {$ifdef fpc}LCLIntf, LCLType,{$endif}
  SysUtils, Classes, Graphics, Controls, ExtCtrls, contnrs;

type

  TBiruAnimationType = (tatBouncing, tatSizing, tatScrolling);

  { TBiru }

  TBiru = class abstract(TGraphicControl)
//  strict private
//    const SQUARE_LENGTH = 120;
  strict private
    DefImage: TBitmap;
    FAnimateTimer: TTimer;
    FSpeed: integer;
    XPos: integer;
    YPos: integer;
    ShiftX: integer;
    ShiftY: integer;
    RollingX: integer;
    BiruDefaultX: integer;
    BiruDefaultY: integer;
    FStretchingDirection: integer;
    StretchingX: integer;
    StretchingY: integer;
    FPlayingAnimation: boolean;
    FAnimation: TBiruAnimationType;
    procedure SetAnimation(Value: TBiruAnimationType);
    procedure FAnimateTimerTimer(Sender: TObject);
    procedure SetSpeed(AValue: integer);
  protected
    FFixedBackground: TBitmap;
    FScrollingBackground: TBitmap;

    FImages : TObjectList;
    FMasks : TObjectList;

    FBiruShape: TBitmap;
    FBiruImage: TBitmap;

    procedure Paint; override;
    procedure Init;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PlayAnimation;
    procedure StopAnimation;
  published
    property Animation: TBiruAnimationType read FAnimation write SetAnimation default tatBouncing;
    property Speed: integer read FSpeed write SetSpeed;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Visible;
    property OnClick;
    property OnDblClick;
  end;


implementation

{$R biru.res}

procedure TBiru.Paint;
var
  Temp: TBitmap;
begin
  Temp := TBitmap.Create;
  try
    if (not FPlayingAnimation) then
    begin
      Temp.Width := FFixedBackground.Width;
      Temp.Height := FFixedBackground.Height;
      BitBlt(Temp.Canvas.Handle, 0, 0, FFixedBackground.Width, FFixedBackground.Height,
        FFixedBackground.Canvas.Handle, 0, 0, SRCCOPY);
      BitBlt(Temp.Canvas.Handle, BiruDefaultX,
        BiruDefaultY, FBiruImage.Width, FBiruImage.Height, FBiruShape.Canvas.Handle, 0, 0, SRCAND);
      BitBlt(Temp.Canvas.Handle, BiruDefaultX,
        BiruDefaultY, FBiruImage.Width, FBiruImage.Height, FBiruImage.Canvas.Handle, 0, 0, SRCPAINT);
      BitBlt(DefImage.Canvas.Handle, 0, 0, FBiruImage.Width,
        FBiruImage.Height, Temp.Canvas.Handle, 0, 0, SRCCOPY);
      Canvas.Draw(0, 0, Temp);
    end;
  finally
    Temp.Free;
  end;
end;

procedure TBiru.Init;
var
  R: TRect;
begin
  Self.Height:= FFixedBackground.Height;
  Self.Width:= FFixedBackground.Width;

  FBiruImage := FImages.Items[0] as TBitmap;
  FBiruShape := FMasks.Items[0] as TBitmap;
  StretchingX := FBiruImage.Width;
  StretchingY := FBiruImage.Height;
  BiruDefaultX := (FFixedBackground.Width - FBiruImage.Width) div 2;
  BiruDefaultY := (FFixedBackground.Height - FBiruImage.Height) div 2;
  XPos := (FFixedBackground.Width - FBiruImage.Width) div 2;
  DefImage.Width := FFixedBackground.Width;
  DefImage.Height := FFixedBackground.Height;
  R := Rect(0, 0, FFixedBackground.Width, FFixedBackground.Height);
  DefImage.Canvas.Brush.Color := clWhite;
  DefImage.Canvas.FillRect(R);

end;

procedure TBiru.SetAnimation(Value: TBiruAnimationType);
begin
  if (Value <> FAnimation) and (not FPlayingAnimation) then
  begin
    FAnimation := Value;
    Invalidate;
  end;
end;

procedure TBiru.FAnimateTimerTimer(Sender: TObject);
var
  R: TRect;
  StrX, StrY: integer;
  StretchBiru: TBitmap;
  StretchShape: TBitmap;
begin
  case FAnimation of
    tatBouncing:
    begin
      if ((XPos + FBiruImage.Width) = FFixedBackground.Width) then
        ShiftX := -1
      else
      if (XPos = 0) then
        ShiftX := 1;
      if (YPos = 0) then
        ShiftY := 1
      else
      if ((YPos + FBiruImage.Height) = FFixedBackground.Height) then
        ShiftY := -1;
      XPos := XPos + ShiftX;
      YPos := YPos + ShiftY;
      BitBlt(DefImage.Canvas.Handle, 0, 0, FFixedBackground.Width,
        FFixedBackground.Height, FFixedBackground.Canvas.Handle, 0, 0, SRCCOPY);
      BitBlt(DefImage.Canvas.Handle, XPos, YPos, FBiruImage.Width,
        FBiruImage.Height, FBiruShape.Canvas.Handle, 0, 0, SRCAND);
      BitBlt(DefImage.Canvas.Handle, XPos, YPos, FBiruImage.Width,
        FBiruImage.Height, FBiruImage.Canvas.Handle, 0, 0, SRCPAINT);
      Canvas.Draw(0, 0, DefImage);

    end;
    tatScrolling:
    begin
      BitBlt(DefImage.Canvas.Handle, RollingX, 0,
        (FFixedBackground.Width - RollingX), FFixedBackground.Height, FScrollingBackground.Canvas.Handle, 0, 0, SRCCOPY);
      if (RollingX > 0) then
        BitBlt(DefImage.Canvas.Handle, 0, 0, RollingX,
          FFixedBackground.Height, FScrollingBackground.Canvas.Handle, (FFixedBackground.Width - RollingX), 0, SRCCOPY);
      BitBlt(DefImage.Canvas.Handle, BiruDefaultX,
        BiruDefaultY, FBiruImage.Width, FBiruImage.Height, FBiruShape.Canvas.Handle, 0, 0, SRCAND);
      BitBlt(DefImage.Canvas.Handle, BiruDefaultX,
        BiruDefaultY, FBiruImage.Width, FBiruImage.Height, FBiruImage.Canvas.Handle, 0, 0, SRCPAINT);
      Canvas.Draw(0, 0, DefImage);
      Inc(RollingX);
      if (RollingX > DefImage.Width) then
        RollingX := 0;
    end;
    tatSizing:
    begin
      StretchingX := StretchingX + FStretchingDirection;
      StretchingY := StretchingY + FStretchingDirection;
      R := Rect(0, 0, StretchingX, StretchingY);
      StretchBiru := TBitmap.Create;
      StretchShape := TBitmap.Create;
      try
        StretchBiru.Width := StretchingX;
        StretchBiru.Height := StretchingY;
        StretchShape.Width := StretchingX;
        StretchShape.Height := StretchingY;
        StretchBiru.Canvas.StretchDraw(R, FBiruImage);
        StretchShape.Canvas.StretchDraw(R, FBiruShape);
        StrX := (FFixedBackground.Width - StretchingX) div 2;
        StrY := (FFixedBackground.Height - StretchingY) div 2;

        BitBlt(DefImage.Canvas.Handle, 0, 0, FFixedBackground.Width,
          FFixedBackground.Height, FFixedBackground.Canvas.Handle, 0, 0, SRCCOPY);
        BitBlt(DefImage.Canvas.Handle, StrX, StrY,
          StretchingX, StretchingY, StretchShape.Canvas.Handle, 0, 0, SRCAND);
        BitBlt(DefImage.Canvas.Handle, StrX, StrY,
          StretchingX, StretchingY, StretchBiru.Canvas.Handle, 0, 0, SRCPAINT);
        Canvas.Draw(0, 0, DefImage);
        if ((StretchingX = 2) or (StretchingY = 2)) then
          FStretchingDirection := 1;
        if ((StretchingX = FFixedBackground.Width) or (StretchingY = FFixedBackground.Height)) then
          FStretchingDirection := -1;
      finally
        StretchBiru.Free;
        StretchShape.Free;
      end;
    end;
  end;
end;

procedure TBiru.SetSpeed(AValue: integer);
begin
  if FSpeed=AValue then Exit;
  FSpeed:=AValue;
  FAnimateTimer.Interval:= FSpeed;
end;

constructor TBiru.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FImages:= TObjectList.Create(true);
  FMasks := TObjectList.Create(true);
  { default values }
  XPos := 0;
  YPos := 0;
  ShiftX := 1;
  ShiftY := 1;
  RollingX := 0;
  FAnimation := tatBouncing;
  FStretchingDirection := -1;
  FPlayingAnimation := False;
  DefImage := TBitmap.Create;

  FFixedBackground := TBitmap.Create;
  FScrollingBackground := TBitmap.Create;

  FAnimateTimer := TTimer.Create(self);
  FAnimateTimer.Enabled := False;
  FSpeed := 5;
  FAnimateTimer.Interval := FSpeed;
  FAnimateTimer.OnTimer := Self.FAnimateTimerTimer;
end;

destructor TBiru.Destroy;
begin
  FreeAndNil(DefImage);
  FreeAndNil(FFixedBackground);
  FreeAndNil(FScrollingBackground);
  FImages.Free;
  FMasks.Free;

  inherited Destroy;

end;

procedure TBiru.PlayAnimation;
begin
  FPlayingAnimation := True;
  FAnimateTimer.Enabled := True;
end;

procedure TBiru.StopAnimation;
begin
  FPlayingAnimation := False;
  FAnimateTimer.Enabled := False;
  Refresh;
end;


end.
