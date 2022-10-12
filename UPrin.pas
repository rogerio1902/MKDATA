unit UPrin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.DBCGrids, Vcl.Mask, Vcl.DBCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ComCtrls, Data.DB, xmldom, XMLIntf, msxmldom, XMLDoc, StrUtils;

type
  TFrmCadCli = class(TForm)
    BvlTopo: TBevel;
    SBtnIncluir: TSpeedButton;
    SBtnGravar: TSpeedButton;
    SBtnCancelar: TSpeedButton;
    SBtnExcluir: TSpeedButton;
    LblCliCod: TLabel;
    DBTxtCliId: TDBText;
    LblCliNome: TLabel;
    LblCliRG: TLabel;
    LblCliCPF: TLabel;
    BEdtPesq: TButtonedEdit;
    DBEdtCliNome: TDBEdit;
    DBEdtCliRG: TDBEdit;
    DBEdtCliCPF: TDBEdit;
    LblPesq: TLabel;
    LblFiltrar: TLabel;
    CkBoxAtivo: TCheckBox;
    CkBoxInativo: TCheckBox;
    DBCkBoxAtivo: TDBCheckBox;
    PgCtrlCad: TPageControl;
    TSEnd: TTabSheet;
    TSTel: TTabSheet;
    DBCtrlGrdEnd: TDBCtrlGrid;
    LblEndLogr: TLabel;
    LblEndNum: TLabel;
    LblEndUF: TLabel;
    LblEndCEP: TLabel;
    ImgEndCEP: TImage;
    DBEdtEndLogr: TDBEdit;
    DBEdtNum: TDBEdit;
    DBEdtEndCid: TDBEdit;
    DBEdtEndUF: TDBEdit;
    DBEdtEndCEP: TDBEdit;
    SBtnIncluirEnd: TSpeedButton;
    SBtnInserirEnd: TSpeedButton;
    SBtnConfirmarEnd: TSpeedButton;
    SBtnCancelarEnd: TSpeedButton;
    SBtnExcluirEnd: TSpeedButton;
    LblEndBairro: TLabel;
    DBEdtEndBairro: TDBEdit;
    LblEndPais: TLabel;
    DBEdtEndPais: TDBEdit;
    DBCtrlGrdTel: TDBCtrlGrid;
    LblTelNum: TLabel;
    LblTelObs: TLabel;
    DBEdtTelNum: TDBEdit;
    SBtnIncluirTel: TSpeedButton;
    SBtnInserirTel: TSpeedButton;
    SBtnConfirmarTel: TSpeedButton;
    SBtnCancelarTel: TSpeedButton;
    SBtnExcluirTel: TSpeedButton;
    LblEndCid: TLabel;
    DBRGrpPessoa: TDBRadioGroup;
    XMLDocument: TXMLDocument;
    DBEdtTelObs: TDBEdit;
    PnlInvalido: TPanel;
    ImgAlerta: TImage;
    LblDtCad: TLabel;
    DBTxtCliDtCad: TDBText;
    procedure Habilitar;
    procedure FormCreate(Sender: TObject);
    procedure SBtnIncluirClick(Sender: TObject);
    procedure SBtnGravarClick(Sender: TObject);
    procedure SBtnCancelarClick(Sender: TObject);
    procedure SBtnExcluirClick(Sender: TObject);
    procedure BEdtPesqRightButtonClick(Sender: TObject);
    procedure DBRGrpPessoaChange(Sender: TObject);
    procedure BEdtPesqKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure SBtnIncluirEndClick(Sender: TObject);
    procedure SBtnInserirEndClick(Sender: TObject);
    procedure SBtnConfirmarEndClick(Sender: TObject);
    procedure SBtnCancelarEndClick(Sender: TObject);
    procedure SBtnExcluirEndClick(Sender: TObject);
    procedure ImgEndCEPClick(Sender: TObject);
    procedure SBtnIncluirTelClick(Sender: TObject);
    procedure SBtnInserirTelClick(Sender: TObject);
    procedure SBtnConfirmarTelClick(Sender: TObject);
    procedure SBtnCancelarTelClick(Sender: TObject);
    procedure SBtnExcluirTelClick(Sender: TObject);
    procedure CkBoxAtivoClick(Sender: TObject);
    procedure CkBoxInativoClick(Sender: TObject);
    procedure DBEdtCliCPFChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmCadCli: TFrmCadCli;

implementation

{$R *.dfm}

uses UDM, UPesq;

procedure TFrmCadCli.Habilitar;
begin
  // Habilita cadastro
  with DM.SDSCli do
  begin
    BEdtPesq.    Enabled := State = dsBrowse;
    CkBoxAtivo.  Enabled := BEdtPesq.Enabled;
    CkBoxInativo.Enabled := BEdtPesq.Enabled;
    SBtnIncluir. Enabled := BEdtPesq.Enabled;
    SBtnGravar.  Enabled := State in [dsInsert, dsEdit];
    SBtnExcluir. Enabled := (State = dsBrowse) and (RecordCount > 0);
    SBtnCancelar.Enabled := SBtnGravar.Enabled;
  end;
  if Self.Visible then
    with BEdtPesq do
      if Enabled then
      begin
        SetFocus;
        SelectAll;
      end;
  // Habilita endereços
  with DM.CDSEndClientes do
  begin
    SBtnIncluirEnd.  Enabled := State = dsBrowse;
    SBtnInserirEnd.  Enabled := SBtnIncluirEnd.Enabled and (RecordCount > 0);
    SBtnConfirmarEnd.Enabled := State in [dsInsert, dsEdit];
    SBtnExcluirEnd.  Enabled := (State = dsBrowse) and (RecordCount > 0);
    SBtnCancelarEnd. Enabled := SBtnConfirmarEnd.Enabled;
  end;
  // Habilita telefones
  with DM.CDSTelClientes do
  begin
    SBtnIncluirTel.  Enabled := State = dsBrowse;
    SBtnInserirTel.  Enabled := SBtnIncluirTel.Enabled and (RecordCount > 0);
    SBtnConfirmarTel.Enabled := State in [dsInsert, dsEdit];
    SBtnExcluirTel.  Enabled := (State = dsBrowse) and (RecordCount > 0);
    SBtnCancelarTel. Enabled := SBtnConfirmarTel.Enabled;
  end;
end;

procedure TFrmCadCli.ImgEndCEPClick(Sender: TObject);
var
  tempXML: IXMLNode;
begin
  try
    XMLDocument.FileName := 'https://viacep.com.br/ws/' + Trim(DBEdtEndCEP.text) + '/xml/';
    XMLDocument.Active   := True;
    tempXML              := XMLDocument.DocumentElement;
    with DM.CDSEndClientes do
    begin
      if not (State in [dsInsert, dsEdit]) then
        Edit;
      FieldByName('Endereco').AsString := tempXML.ChildNodes.FindNode('logradouro').Text;
      FieldByName('Bairro').  AsString := tempXML.ChildNodes.FindNode('bairro').    Text;
      FieldByName('Cidade').  AsString := tempXML.ChildNodes.FindNode('localidade').Text;
      FieldByName('Estado').  AsString := tempXML.ChildNodes.FindNode('uf').        Text;
      if DBEdtNum.Text = '' then
        DBEdtNum.SetFocus;
    end;
  except
    on E: Exception do
      Application.MessageBox('Não foi possível encontrar este CEP', 'Erro', MB_OK + MB_ICONERROR);
  end;
end;

procedure TFrmCadCli.BEdtPesqKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    BEdtPesqRightButtonClick(nil);
  end;
end;

procedure TFrmCadCli.BEdtPesqRightButtonClick(Sender: TObject);
var
  vId: Integer;

  procedure Localizar(pCod: Integer);
  begin
    with DM.SDSCli do
    begin
      Close;
      DataSet.ParamByName('CliCod').AsInteger := pCod;
      Open;
    end;
  end;

begin
  with DM.SDSGen do
  begin
    Close;
    vId := StrToIntDef(BEdtPesq.Text, 0);
    if vId <> 0 then
    begin
      DataSet.CommandText := 'select * from VClientes where "Código" = ' + BEdtPesq.Text;
      Open;
    end;
    if (not Active) or (RecordCount = 0) then
    begin
      DataSet.CommandText := 'select * from VClientes where ("Nome"||''|''||Coalesce("CPF/CNPJ", '''')||''|''||Coalesce("IE/RG", '''') like ''%' + BEdtPesq.Text + '%'') and ("Ativo" in (''''' + IfThen(CkBoxAtivo.Checked, ', ''S''') + IfThen(CkBoxInativo.Checked, ', ''N''') + '))';
      Open;
    end;
    if RecordCount = 0 then
      Application.MessageBox('Não encontrado', 'Atenção', MB_OK + MB_ICONWARNING)
    else
    begin
      if RecordCount > 1 then
        if FrmPesq.ShowModal = mrCancel then
          Exit;
      Localizar(FieldByName('Código').AsInteger);
    end;
  end;
  Habilitar;
end;

procedure TFrmCadCli.CkBoxAtivoClick(Sender: TObject);
begin
  if not CkBoxAtivo.Checked then
    if not CkBoxInativo.Checked then
      CkBoxInativo.Checked := True;
end;

procedure TFrmCadCli.CkBoxInativoClick(Sender: TObject);
begin
  if not CkBoxInativo.Checked then
    if not CkBoxAtivo.Checked then
      CkBoxAtivo.Checked := True;
end;

procedure TFrmCadCli.DBEdtCliCPFChange(Sender: TObject);
begin
  PnlInvalido.Visible := not CPFCNPJValido(DBEdtCliCPF.Text);
end;

procedure TFrmCadCli.DBRGrpPessoaChange(Sender: TObject);
begin
  if DBRGrpPessoa.ItemIndex = 0 then
  begin
    LblCliRG. Caption := '&RG';
    LblCliCPF.Caption := '&CPF';
  end
  else
  begin
    LblCliRG. Caption := '&IE';
    LblCliCPF.Caption := '&CNPJ';
  end;
end;

procedure TFrmCadCli.FormCreate(Sender: TObject);
begin
  PgCtrlCad.ActivePageIndex := 0;
end;

procedure TFrmCadCli.FormShow(Sender: TObject);
begin
  Habilitar;
end;

procedure TFrmCadCli.SBtnCancelarClick(Sender: TObject);
begin
  if Application.MessageBox('Deseja realmente cancelar?', 'Confirmação', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2) = MRYES then
  begin
    DM.SDSCli.Cancel;
    DM.CarregarEndTel;
    Habilitar;
  end;
end;

procedure TFrmCadCli.SBtnCancelarEndClick(Sender: TObject);
begin
  DM.CDSEndClientes.Cancel;
  Habilitar;
end;

procedure TFrmCadCli.SBtnCancelarTelClick(Sender: TObject);
begin
  DM.CDSTelClientes.Cancel;
  Habilitar;
end;

procedure TFrmCadCli.SBtnConfirmarEndClick(Sender: TObject);
begin
  DM.CDSEndClientes.Post;
  Habilitar;
end;

procedure TFrmCadCli.SBtnConfirmarTelClick(Sender: TObject);
begin
  DM.CDSTelClientes.Post;
  Habilitar;
end;

procedure TFrmCadCli.SBtnExcluirClick(Sender: TObject);
begin
  if Application.MessageBox('Deseja realmente excluir?', 'Confirmação', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2) = MRYES then
    DM.SDSCli.Delete;
  Habilitar;
end;

procedure TFrmCadCli.SBtnExcluirEndClick(Sender: TObject);
begin
  if Application.MessageBox('Deseja realmente excluir endereço?', 'Confirmação', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2) = MRYES then
    DM.CDSEndClientes.Delete;
  Habilitar;
end;

procedure TFrmCadCli.SBtnExcluirTelClick(Sender: TObject);
begin
  if Application.MessageBox('Deseja realmente excluir telefone?', 'Confirmação', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2) = MRYES then
    DM.CDSTelClientes.Delete;
  Habilitar;
end;

procedure TFrmCadCli.SBtnGravarClick(Sender: TObject);
begin
  DM.SDSCli.Post;
  Habilitar;
end;

procedure TFrmCadCli.SBtnIncluirClick(Sender: TObject);
begin
  DM.SDSCli.Insert;
  Habilitar;
  DBEdtCliNome.SetFocus;
end;

procedure TFrmCadCli.SBtnIncluirEndClick(Sender: TObject);
begin
  DM.CDSEndClientes.Append;
  Habilitar;
  DBEdtEndLogr.SetFocus;
end;

procedure TFrmCadCli.SBtnIncluirTelClick(Sender: TObject);
begin
  DM.CDSTelClientes.Append;
  Habilitar;
  DBEdtTelNum.SetFocus;
end;

procedure TFrmCadCli.SBtnInserirEndClick(Sender: TObject);
begin
  DM.CDSEndClientes.Insert;
  Habilitar;
  DBEdtEndLogr.SetFocus;
end;

procedure TFrmCadCli.SBtnInserirTelClick(Sender: TObject);
begin
  DM.CDSTelClientes.Insert;
  Habilitar;
  DBEdtTelNum.SetFocus;
end;

end.
