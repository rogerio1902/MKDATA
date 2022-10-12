unit UPesq;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids,
  Vcl.DBGrids, Vcl.StdCtrls, Vcl.Buttons;

type
  TFrmPesq = class(TForm)
    BBtnOk: TBitBtn;
    BBtnCancelar: TBitBtn;
    DBGrdPesq: TDBGrid;
    procedure DBGrdPesqKeyPress(Sender: TObject; var Key: Char);
    procedure DBGrdPesqDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPesq: TFrmPesq;

implementation

{$R *.dfm}

uses UDM;

procedure TFrmPesq.DBGrdPesqDblClick(Sender: TObject);
begin
  BBtnOk.Click;
end;

procedure TFrmPesq.DBGrdPesqKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    BBtnOk.Click;
  end;
end;

procedure TFrmPesq.FormShow(Sender: TObject);
begin
  DBGrdPesq.SetFocus;
end;

end.
