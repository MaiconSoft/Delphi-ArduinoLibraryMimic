unit uEEPROM;

interface

Uses Classes, SysUtils, Windows;

Type
  TAdress = Cardinal;
  TNotifyEEPROMChanged = procedure(Sender: TObject;
    const Adress, Count: TAdress) of object;

  TInt64Rec = packed record
    case Integer of
      0:
        (I: Int64);
      1:
        (L, H: LongInt)
  end;

  TEEPROM = class
  private
    FFileName: string;
    FOnChanged: TNotifyEEPROMChanged;
    procedure DoChanged(Adress, Count: TAdress);
  public
    constructor Create(MemorySizeBytes: TAdress; FileName: string = '');
    destructor Destroy(); override;
    procedure write(Adress: TAdress; Value: byte);
    procedure update(Adress: TAdress; Value: byte);
    function read(Adress: TAdress): byte;
    function length: Cardinal;
    function get(Adress: TAdress; var Buffer; const Count: TAdress): TAdress;
    function put(Adress: TAdress; const Buffer; const Count: TAdress): TAdress;
    property FileName: string read FFileName write FFileName;
    property readItem[index: TAdress]: byte read read write write; default;
  published
    property OnChanged: TNotifyEEPROMChanged read FOnChanged write FOnChanged;
  end;

implementation

function SetFileSize(FileName: String; Size: Int64): Boolean;
var
  hFile: THandle;
  sz: TInt64Rec;
begin
  sz.I := Size;

  hFile := CreateFile(PChar(FileName), GENERIC_WRITE, 0, nil, CREATE_NEW,
    FILE_ATTRIBUTE_NORMAL, 0);
  if (hFile <> INVALID_HANDLE_VALUE) then
  begin
    if (SetFilePointer(hFile, sz.L, @sz.H, FILE_BEGIN) = sz.L) then
      result := SetEndOfFile(hFile)
    else
      result := False;
    CloseHandle(hFile);
  end
  else
    result := False;
end;

{ TEEPROM }
constructor TEEPROM.Create(MemorySizeBytes: TAdress; FileName: string);
begin
  if FileName.IsEmpty then
    FileName := ParamStr(0) + '.EEPROM.mem';
  self.FileName := FileName;
  ForceDirectories(ExtractFilePath(FileName));
  SetFileSize(FileName, MemorySizeBytes);
end;

destructor TEEPROM.Destroy;
begin

  inherited;
end;

procedure TEEPROM.DoChanged(Adress, Count: Cardinal);
begin
  if Assigned(FOnChanged) then
    FOnChanged(self, Adress, Count);
end;

function TEEPROM.get(Adress: TAdress; var Buffer; const Count: TAdress)
  : TAdress;
begin
  with TFileStream.Create(FileName, fmOpenRead) do
  begin
    Seek(Adress, soBeginning);
    result := Read(Buffer, Count);
    Free;
  end;
end;

function TEEPROM.length: Cardinal;
begin
  with TFileStream.Create(FileName, fmOpenRead) do
  begin
    Seek(0, soBeginning);
    result := Size;
    Free;
  end;
end;

function TEEPROM.put(Adress: TAdress; const Buffer;
  const Count: TAdress): TAdress;
begin
  with TFileStream.Create(FileName, fmOpenWrite) do
  begin
    Seek(Adress, soBeginning);
    result := Write(Buffer, Count);
    Free;
  end;
  DoChanged(Adress, result);
end;

function TEEPROM.read(Adress: TAdress): byte;
begin
  with TFileStream.Create(FileName, fmOpenRead) do
  begin
    Seek(Adress, soBeginning);
    Read(result, 1);
    Free;
  end;
end;

procedure TEEPROM.update(Adress: TAdress; Value: byte);
var
  Buffer: byte;
  changed: Boolean;
begin
  changed := False;
  with TFileStream.Create(FileName, fmOpenReadWrite) do
  begin
    Seek(Adress, soBeginning);
    read(Buffer, 1);
    if Buffer <> Value then
    begin
      Seek(Adress, soBeginning);
      write(Value, 1);
      changed := True;
    end;
    Free;
  end;
  if changed then
    DoChanged(Adress, 1);
end;

procedure TEEPROM.write(Adress: TAdress; Value: byte);
begin
  with TFileStream.Create(FileName, fmOpenWrite) do
  begin
    Seek(Adress, soBeginning);
    write(Value, 1);
    Free;
  end;
  DoChanged(Adress, 1);
end;

initialization

end.
