program ProjMKDATA;

uses
  Vcl.Forms,
  UPrin in 'UPrin.pas' {FrmCadCli},
  UDM in 'UDM.pas' {DM: TDataModule},
  UPesq in 'UPesq.pas' {FrmPesq};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmCadCli, FrmCadCli);
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFrmPesq, FrmPesq);
  Application.Run;
end.
