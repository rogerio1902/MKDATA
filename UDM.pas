unit UDM;

interface

uses
  System.SysUtils, System.Classes, Data.DBXFirebird, Data.DB, Data.SqlExpr,
  Data.FMTBcd, Vcl.Forms, Winapi.Windows, Datasnap.DBClient, SimpleDS,
  Vcl.ImgList, Vcl.Controls, StrUtils;

type
  TDM = class(TDataModule)
    SQLConnection: TSQLConnection;
    DSCli: TDataSource;
    SDSCli: TSimpleDataSet;
    DSGen: TDataSource;
    ImgLstMenu: TImageList;
    SDSGen: TSimpleDataSet;
    DSEndClientes: TDataSource;
    CDSEndClientes: TClientDataSet;
    CDSEndClientesCEP: TStringField;
    CDSEndClientesNum: TStringField;
    CDSEndClientesCidade: TStringField;
    CDSEndClientesEstado: TStringField;
    CDSEndClientesCompl: TStringField;
    CDSEndClientesBairro: TStringField;
    CDSEndClientesPais: TStringField;
    CDSTelClientes: TClientDataSet;
    DSTelClientes: TDataSource;
    CDSTelClientesNumero: TStringField;
    CDSTelClientesObs: TStringField;
    CDSEndClientesEndereco: TStringField;
    SQLQGen: TSQLQuery;
    procedure CarregarEndTel;
    procedure DataModuleCreate(Sender: TObject);
    procedure SDSCliAfterInsert(DataSet: TDataSet);
    procedure SDSCliAfterPost(DataSet: TDataSet);
    procedure DSCliStateChange(Sender: TObject);
    procedure SDSCliAfterEdit(DataSet: TDataSet);
    procedure SDSCliAfterOpen(DataSet: TDataSet);
    procedure CDSEndClientesAfterEdit(DataSet: TDataSet);
    procedure DSEndClientesStateChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function CPFCNPJValido(Numero: String): Boolean;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses UPrin;

{$R *.dfm}

function CPFCNPJValido(Numero: String): Boolean;
var
  I,
  J,
  K,
  Soma,
  Digito:  Integer;
  CNPJ:    Byte;
  CopyNum: String;
begin
  Numero := Trim(ReplaceStr(ReplaceStr(ReplaceStr(Numero, '.', ''), '/', ''), '-', ''));
  if (Numero <> '') then
  begin
    CopyNum := Copy(Numero, 1, Length(Numero) - 2);
    case Length(CopyNum) of
       9: CNPJ := 0;
      12: CNPJ := 1;
      else
        CNPJ := 2;
    end;
    if (CNPJ < 2) then
      for J := 1 to 2 do
      begin
        K    := 2;
        Soma := 0;
        for I:= Length(CopyNum) downto 1 do
        begin
          Soma := (Soma + (Ord(CopyNum[I]) - Ord('0')) * K);
          Inc(K);
          if ((CNPJ = 1) and (K > 9)) then K := 2;
        end;
        Digito := (11 - Soma mod 11);
        if (Digito > 9) then Digito := 0;
        CopyNum := CopyNum + Chr(Digito + Ord('0'));
      end;
    Result := (Numero = CopyNum);
  end
  else
    Result := True;
end;

procedure TDM.CarregarEndTel;
begin
  // Endereços
  with CDSEndClientes do
  begin
    AfterInsert := nil;
    DisableControls;
    EmptyDataset;
    SDSGen.Close;
    SDSGen.DataSet.CommandText := 'select * from ENDCLI where ENDCLICOD = 0' + SDSCli.FieldByName('CLICOD').AsString;
    SDSGen.Open;
    while not SDSGen.Eof do
    begin
      Append;
      FieldByName('Endereco').AsString := SDSGen.FieldByName('ENDCLIEND').  AsString;
      FieldByName('Num').     AsString := SDSGen.FieldByName('ENDCLINUM').  AsString;
      FieldByName('Compl').   AsString := SDSGen.FieldByName('ENDCLICOMPL').AsString;
      FieldByName('Bairro').  AsString := SDSGen.FieldByName('ENDCLIBAI').  AsString;
      FieldByName('Cidade').  AsString := SDSGen.FieldByName('ENDCLICID').  AsString;
      FieldByName('Estado').  AsString := SDSGen.FieldByName('ENDCLIUF').   AsString;
      FieldByName('Pais').    AsString := SDSGen.FieldByName('ENDCLIPAIS'). AsString;
      FieldByName('CEP').     AsString := SDSGen.FieldByName('ENDCLICEP').  AsString;
      Post;
      SDSGen.Next;
    end;
    First;
    AfterInsert := CDSEndClientesAfterEdit;
    EnableControls;
  end;
  // Telefones
  with CDSTelClientes do
  begin
    AfterInsert := nil;
    DisableControls;
    EmptyDataset;
    SDSGen.Close;
    SDSGen.DataSet.CommandText := 'select * from TELCLI where TELCLICOD = 0' + SDSCli.FieldByName('CLICOD').AsString;
    SDSGen.Open;
    while not SDSGen.Eof do
    begin
      Append;
      FieldByName('Numero').AsString := SDSGen.FieldByName('TELCLINUMERO').AsString;
      FieldByName('Obs').   AsString := SDSGen.FieldByName('TELCLIOBS').   AsString;
      Post;
      SDSGen.Next;
    end;
    First;
    AfterInsert := CDSEndClientesAfterEdit;
    EnableControls;
  end;
end;

procedure TDM.CDSEndClientesAfterEdit(DataSet: TDataSet);
begin
  if not (SDSCli.State in [dsEdit, dsInsert]) then
    SDSCli.Edit;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  // Abertura do banco
  try
    SQLConnection.Params.LoadFromFile('MKDATA.con');
    SQLConnection.Connected := True;
  except
    on E: Exception do
    begin
      Application.MessageBox(PChar('Não foi possível conectar' + #13#13 + E.Message), 'Erro', MB_OK + MB_ICONERROR);
      Application.Terminate;
    end;
  end;
  // Abertura da tabela
  try
    SDSCli.Active := True;
  except
    on E: Exception do
    begin
      Application.MessageBox(PChar('Não foi possível abrir tabela' + #13#13 + E.Message), 'Erro', MB_OK + MB_ICONERROR);
      Application.Terminate;
    end;
  end;
end;

procedure TDM.DSCliStateChange(Sender: TObject);
var
  Stt: String;
begin
  with SDSCli do
  begin
    case State of
      dsInsert: Stt := 'Incluindo';
      dsEdit:   Stt := 'Alterando';
      dsBrowse: Stt := 'Pesquisando';
    end;
  end;
  FrmCadCli.Caption := 'Cadastro de Clientes - [' + Stt + ']';
  FrmCadCli.Habilitar;
end;

procedure TDM.DSEndClientesStateChange(Sender: TObject);
begin
  FrmCadCli.Habilitar;
end;

procedure TDM.SDSCliAfterEdit(DataSet: TDataSet);
begin
  FrmCadCli.Habilitar;
end;

procedure TDM.SDSCliAfterInsert(DataSet: TDataSet);
begin
  with SDSCli do
  begin
    FieldByName('CLICOD').   AsInteger  := 0;
    FieldByName('CLIATIVO'). AsString   := 'S';
    FieldByName('CLIDTCAD'). AsDateTime := Date;
    FieldByName('CLIPESSOA').AsString   := 'F';
  end;
  CDSEndClientes.EmptyDataSet;
  CDSTelClientes.EmptyDataSet;
end;

procedure TDM.SDSCliAfterOpen(DataSet: TDataSet);
begin
  TDateField(SDSCli.FieldByName('CLIDTCAD')).DisplayFormat := 'ddd dd/mmm/yyyy';
  CarregarEndTel;
end;

procedure TDM.SDSCliAfterPost(DataSet: TDataSet);
begin
  SDSCli.ApplyUpdates(-1);
  // Recupera código
  with SDSGen do
  begin
    Close;
    DataSet.CommandText := 'select CLICOD from CLIENTES where CLINOME = ''' + SDSCli.FieldByName('CLINOME').AsString + '''';
    Open;
  end;
  // Grava endereços
  with SQLQGen, SQL do
  begin
    Close;
    Text := 'delete from ENDCLI where ENDCLICOD = 0' + SDSGen.FieldByName('CLICOD').AsString;
    ExecSQL;
    if (CDSEndClientes.State in [dsInsert, dsEdit]) then
      CDSEndClientes.Post;
    CDSEndClientes.DisableControls;
    CDSEndClientes.First;
    while not CDSEndClientes.Eof do
    begin
      Text := 'insert into ENDCLI values (' +
        '''' + SDSGen.        FieldByName('CLICOD').  AsString + ''', ' +
        '''' + CDSEndClientes.FieldByName('Endereco').AsString + ''', ' +
        '''' + CDSEndClientes.FieldByName('Num').     AsString + ''', ' +
        '''' + CDSEndClientes.FieldByName('Compl').   AsString + ''', ' +
        '''' + CDSEndClientes.FieldByName('Bairro').  AsString + ''', ' +
        '''' + CDSEndClientes.FieldByName('Cidade').  AsString + ''', ' +
        '''' + CDSEndClientes.FieldByName('Estado').  AsString + ''', ' +
        '''' + CDSEndClientes.FieldByName('Pais').    AsString + ''', ' +
        '''' + CDSEndClientes.FieldByName('CEP').     AsString + ''''   +
        ')';
      ExecSQL;
      CDSEndClientes.Next;
    end;
    CDSEndClientes.First;
    CDSEndClientes.EnableControls;
  end;
  // Grava telefones
  with SQLQGen, SQL do
  begin
    Close;
    Text := 'delete from TELCLI where TELCLICOD = 0' + SDSGen.FieldByName('CLICOD').AsString;
    ExecSQL;
    if (CDSTelClientes.State in [dsInsert, dsEdit]) then
      CDSTelClientes.Post;
    CDSTelClientes.DisableControls;
    CDSTelClientes.First;
    while not CDSTelClientes.Eof do
    begin
      Text := 'insert into TELCLI values (' +
        '''' + SDSGen.        FieldByName('CLICOD').AsString + ''', ' +
        '''' + CDSTelClientes.FieldByName('Numero').AsString + ''', ' +
        '''' + CDSTelClientes.FieldByName('Obs').   AsString + ''''   +
        ')';
      ExecSQL;
      CDSTelClientes.Next;
    end;
    CDSTelClientes.First;
    CDSTelClientes.EnableControls;
  end;
  // Recarrega registro
  if SDSCli.FieldByName('CLICOD').AsInteger = 0 then
    with SDSCli do
    begin
      Close;
      DataSet.ParamByName('CliCod').AsInteger := SDSGen.FieldByName('CLICOD').AsInteger;
      Open;
    end;
end;

end.
