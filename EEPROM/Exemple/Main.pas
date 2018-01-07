unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uEEPROM, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.StdCtrls, System.ImageList, Vcl.ImgList, Vcl.Samples.Spin, System.Actions,
  Vcl.ActnList, Vcl.ExtCtrls;

type
  TfmExemple1 = class(TForm)
    mmMemoryView: TMemo;
    tbMainBar: TToolBar;
    btnRead: TToolButton;
    btnWrite: TToolButton;
    btnUpdate: TToolButton;
    imlImage64: TImageList;
    gbInputs: TGroupBox;
    aclMainActions: TActionList;
    actRead: TAction;
    actWrite: TAction;
    actUpdate: TAction;
    actActivateApp: TAction;
    rdgReadMode: TRadioGroup;
    GroupBox1: TGroupBox;
    speValue: TSpinEdit;
    lbValue: TLabel;
    speAdress: TSpinEdit;
    lbAdress: TLabel;
    rdgWriteMode: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actReadExecute(Sender: TObject);
    procedure actWriteExecute(Sender: TObject);
    procedure actUpdateExecute(Sender: TObject);
    procedure actActivateAppExecute(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateViewer;
    procedure EEPROMChanged(Sender: TObject; const Adress, count: TAdress);
  public
    { Public declarations }
    EEPROM: TEEPROM;
  end;

var
  fmExemple1: TfmExemple1;

implementation

{$R *.dfm}

procedure TfmExemple1.EEPROMChanged(Sender:TObject; const Adress,count:TAdress);
begin
 UpdateViewer;
end;

procedure TfmExemple1.actActivateAppExecute(Sender: TObject);
begin
  UpdateViewer;
  EEPROM.OnChanged:= EEPROMChanged;
end;

procedure TfmExemple1.actReadExecute(Sender: TObject);
var
  Buffer: Byte;
  DbBuffer: Double;
begin
  case rdgReadMode.ItemIndex of
    0:
      speValue.Value := EEPROM.read(speAdress.Value);
    1:
      speValue.Value := EEPROM[speAdress.Value];
    2:
      begin
        EEPROM.get(speAdress.Value, Buffer, 1);
        speValue.Value := Buffer;
      end;
    3:
      begin
        EEPROM.get(speAdress.Value, DbBuffer, SizeOf(DbBuffer));
        speValue.Value := round(DbBuffer);
      end;
  end;
end;

procedure TfmExemple1.actUpdateExecute(Sender: TObject);
begin
  EEPROM.update(speAdress.Value, speValue.Value);
end;

procedure TfmExemple1.actWriteExecute(Sender: TObject);
var
  Buffer: Byte;
  DbBuffer: Double;
begin
  case rdgWriteMode.ItemIndex of
    0:
      EEPROM.write(speAdress.Value, speValue.Value);
    1:
      EEPROM[speAdress.Value] := speValue.Value;
    2:
      begin
        Buffer := speValue.Value;
        EEPROM.put(speAdress.Value, Buffer, 1);
      end;
    3:
      begin
        DbBuffer := speValue.Value;
        EEPROM.put(speAdress.Value, DbBuffer, SizeOf(DbBuffer));
      end;
  end;
end;

procedure TfmExemple1.btnUpdateClick(Sender: TObject);
var
  Buffer: Byte;
  DbBuffer: Double;
begin
  EEPROM.update(speAdress.Value, speValue.Value);
end;

procedure TfmExemple1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  EEPROM.Destroy;
end;

procedure TfmExemple1.FormCreate(Sender: TObject);
begin
  EEPROM := TEEPROM.Create(512);
end;

procedure TfmExemple1.UpdateViewer;
var
  i: Integer;
begin
  with mmMemoryView.Lines do
  begin
    BeginUpdate;
    Clear;
    for i := 0 to EEPROM.length - 1 do
    begin
      Text := Text + EEPROM[i].ToHexString(2) + ' ';
    end;
    EndUpdate;
  end;
end;

end.
