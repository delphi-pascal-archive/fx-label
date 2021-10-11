unit UMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, fxLabels;

type
  Tfrm_Main = class(TForm)
    fxLabel1: TfxLabel;
    fxLabel2: TfxLabel;
    fxLabel3: TfxLabel;
    fxLabel4: TfxLabel;
    fxLabel5: TfxLabel;
    procedure FormCreate(Sender: TObject);
    procedure fxLabel1MouseEnter(Sender: TObject);
    procedure fxLabel1MouseLeave(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_Main: Tfrm_Main;

implementation

{$R *.dfm}

procedure Tfrm_Main.FormCreate(Sender: TObject);
begin
 Doublebuffered:=true;
end;

procedure Tfrm_Main.fxLabel1MouseEnter(Sender: TObject);
begin
 TfxLabel(Sender).ShadowPos:=spBottomRight;
 TfxLabel(Sender).BorderColor:=clBlack;
 TfxLabel(Sender).BorderWidth:=2;
end;

procedure Tfrm_Main.fxLabel1MouseLeave(Sender: TObject);
begin
 TfxLabel(Sender).ShadowPos:=spTopLeft;
 TfxLabel(Sender).BorderColor:=clRed;
 TfxLabel(Sender).BorderWidth:=1;
end;

end.
