{.$Define UseGraphUtil}
unit fxLabels;

interface

uses
  Windows, SysUtils, Messages, Classes, Controls, Graphics, {$IfDef UseGraphUtil}GraphUtil,{$EndIf} StdCtrls;

type

  TShadowPos = (spTopLeft, spTopRight, spBottomLeft, spBottomRight);

  TfxLabel = class(TGraphicControl)       
  private
    { Déclarations privées }
    FBorderWidth: Integer;
    FBorderColor: TColor;
    FShadowColor: TColor;
    FShadowOffset: Integer;
    FShadowPos: TShadowPos;
    FBitmap: TBitmap;
    FUseTexture: Boolean;
    FUseDefShadowColor: Boolean;
    FOnMouseLeave: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    procedure SetBorderColor(Value: TColor);
    procedure SetShadowColor(Value: TColor);
    procedure SetBorderWidth(Value: Integer);
    procedure SetShadowPos(Value: TShadowPos);
    procedure SetShadowOffset(Value: Integer);
    procedure SetBitmap(Value: TBitmap);
    procedure SetUseTexture(Value: Boolean);
    procedure SetUseDefShadowColor(Value: Boolean);
    procedure CalcRect;
    Procedure BitmapChanged(Sender: TObject);
    procedure CMFontChanged(Var Message: TMessage); Message CM_FONTCHANGED;
    procedure CMTextCHANGED(Var Message: TMessage); Message CM_TextCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;  protected
    { Déclarations protégées }
    Procedure Paint; Override;
  public
    { Déclarations publiques }
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Déclarations publiées }
    property Bitmap: TBitmap read FBitmap write SetBitmap;
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth;
    Property Caption;
    Property Enabled;
    Property Font;
    Property ParentFont;
    Property ParentShowHint;
    property ShadowColor: TColor read FShadowColor write SetShadowColor;
    property ShadowOffset: Integer read FShadowOffset write SetShadowOffset;
    property ShadowPos: TShadowPos read FShadowPos write SetShadowPos;
    Property ShowHint;
    property UseTexture: Boolean read FUseTexture write SetUseTexture;
    property UseDefShadowColor: Boolean read FUseDefShadowColor
                                        write SetUseDefShadowColor;
    Property Visible;
    property OnClick;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
  end;

  THackedControl = class(TControl)
    public
    property Color;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Cirec', [TfxLabel]);
end;


{

}
{$IfNDef UseGraphUtil}
function Largest(X, Y: Integer): Integer;
begin
   if X > Y then Result := X else Result := Y;
end;

function GetShadowColor(BaseColor: TColor): TColor;
begin
   Result := RGB(
      Largest(GetRValue(ColorToRGB(BaseColor)) - 64, 0),
      Largest(GetGValue(ColorToRGB(BaseColor)) - 64, 0),
      Largest(GetBValue(ColorToRGB(BaseColor)) - 64, 0)
      );
end;

{$EndIf}
{

}


{ TfxLabel }

procedure TfxLabel.BitmapChanged(Sender: TObject);
begin
  FUseTexture := not FBitmap.Empty;
  Invalidate;
end;

procedure TfxLabel.CalcRect;
var aRect: TRect;
begin
  if Parent <> nil then
  begin
    //aRect := BoundsRect;
    aRect := Rect(Left, Top, Left+1, Top+1);
    DrawText(Canvas.Handle, PChar(Caption), -1, aRect, DT_CALCRECT);
    InflateRect(aRect, (FShadowOffset*2)+2, FShadowOffset);
    OffsetRect(aRect, (FShadowOffset*2)+2, FShadowOffset);
    MoveWindowOrg(Canvas.Handle, FShadowOffset+ (FShadowOffset div 2), 0);
    BoundsRect := aRect;
  end;
end;

procedure TfxLabel.CMFontChanged(var Message: TMessage);
begin
  inherited;
  CalcRect;
  Invalidate;
end;

procedure TfxLabel.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure TfxLabel.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TfxLabel.CMTextCHANGED(var Message: TMessage);
begin
  inherited;
  CalcRect;
  Invalidate;
end;

constructor TfxLabel.Create(aOwner: TComponent);
begin
  inherited Create(AOwner);
  FBitmap := TBitmap.Create;
  FBitmap.OnChange := BitmapChanged;
  FBorderColor := clBlack;
  FShadowColor := clGray;
  FBorderWidth := 1;
  FShadowOffset := 2;
  FShadowPos := spBottomRight;
  FUseDefShadowColor := True;
end;

destructor TfxLabel.Destroy;
begin
  FBitmap.Free;
  inherited Destroy;
end;

procedure TfxLabel.Paint;
const ShdwPos : array[TShadowPos, 0..1]
                of Integer = ((-1, -1), (1, -1), (-1, 1), (1, 1));

var ShdwPosX, ShdwPosY: Integer;
    Flags: Cardinal;
begin
  Flags := DST_PREFIXTEXT or DSS_MONO;
  if not enabled then
    Flags := Flags or DSS_DISABLED;
  Canvas.Font := Font;
  CalcRect;
  Canvas.Brush.Color := FShadowColor;
    if FShadowOffset > 0 then
    begin
      if FUseDefShadowColor then
        Canvas.Brush.Color := GetShadowColor(THackedControl(Parent).Color);
      ShdwPosX := (FShadowOffset+2) * ShdwPos[FShadowPos, 0];
      ShdwPosY := (FShadowOffset+2) * ShdwPos[FShadowPos, 1];
      DrawState(Canvas.Handle, Canvas.Brush.Handle, Nil,
        LongInt(Caption), 0, ShdwPosX, ShdwPosY, Width, Height,
        Flags);
    end;

  if FBorderWidth > 0 then
  begin
    Canvas.Brush.Color := FBorderColor;
    DrawState(Canvas.Handle, Canvas.Brush.Handle, Nil,
      LongInt(Caption), 0, 0, -FBorderWidth, Width, Height, Flags);
    DrawState(Canvas.Handle, Canvas.Brush.Handle, Nil,
      LongInt(Caption), 0, 0, FBorderWidth, Width, Height, Flags);

    DrawState(Canvas.Handle, Canvas.Brush.Handle, Nil,
      LongInt(Caption), 0, -FBorderWidth, 0, Width, Height, Flags);
    DrawState(Canvas.Handle, Canvas.Brush.Handle, Nil,
      LongInt(Caption), 0, FBorderWidth, 0, Width, Height, Flags);

    DrawState(Canvas.Handle, Canvas.Brush.Handle, Nil,
      LongInt(Caption), 0, -FBorderWidth, -FBorderWidth, Width, Height,
      Flags);
    DrawState(Canvas.Handle, Canvas.Brush.Handle, Nil,
      LongInt(Caption), 0, FBorderWidth, FBorderWidth, Width, Height,
      Flags);

    DrawState(Canvas.Handle, Canvas.Brush.Handle, Nil,
      LongInt(Caption), 0, FBorderWidth, -FBorderWidth, Width, Height,
      Flags);
    DrawState(Canvas.Handle, Canvas.Brush.Handle, Nil,
      LongInt(Caption), 0, -FBorderWidth, FBorderWidth, Width, Height,
      Flags);
  end;
  Canvas.Brush.Color := Canvas.Font.Color;
  if (FUseTexture) and (not FBitmap.Empty) then
    Canvas.Brush.Bitmap := FBitmap;
  DrawState(Canvas.Handle, Canvas.Brush.Handle, nil, LongInt(Caption),
            0, 0, 0, Width, Height, Flags);
end;

procedure TfxLabel.SetBitmap(Value: TBitmap);
begin
  if Value <> FBitmap then
  begin
    FBitmap.Assign(Value);
    if (Value <> nil) and (not FBitmap.Empty) then
      FUseTexture := True;
    Invalidate;
  end;
end;

procedure TfxLabel.SetBorderColor(Value: TColor);
begin
  if Value <> FBorderColor then
  begin
    FBorderColor := Value;
    Invalidate;
  end;
end;

procedure TfxLabel.SetBorderWidth(Value: Integer);
begin
  if Value <> FBorderWidth then
  begin
    FBorderWidth := Value;
    Invalidate;
  end;
end;

procedure TfxLabel.SetShadowColor(Value: TColor);
begin
  if Value <> FShadowColor then
  begin
    FShadowColor := Value;
    Invalidate;
  end;
end;

procedure TfxLabel.SetShadowOffset(Value: Integer);
begin
  if Value <> FShadowOffset then
  begin
    FShadowOffset := Value;
    Invalidate;
  end;
end;

procedure TfxLabel.SetShadowPos(Value: TShadowPos);
begin
  if Value <> FShadowPos then
  begin
    FShadowPos := Value;
    Invalidate;
  end;
end;

procedure TfxLabel.SetUseDefShadowColor(Value: Boolean);
begin
  if Value <> FUseDefShadowColor then
  begin
    FUseDefShadowColor := Value;
    Invalidate;
  end;
end;

procedure TfxLabel.SetUseTexture(Value: Boolean);
begin
  if Value <> FUseTexture then
  begin
    FUseTexture := Value;
    Invalidate;
  end;
end;

end.

