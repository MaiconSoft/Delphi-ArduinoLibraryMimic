unit uEEPROM;

interface

Uses Classes, SysUtils, Windows;

Type
  TAdress = Cardinal;

  TInt64Rec = packed record
    case Integer of
      0:
        (I: Int64);
      1:
        (L, H: LongInt)
  end;

  TEEPROM = class
  private
    Memory: TFileStream;
    FFileName: string;
  public
    constructor Create(MemorySizeBytes: TAdress; FileName: string = '');
    property FileName: string read FFileName write FFileName;
    procedure write(Adress: TAdress; Value: byte);
    procedure update(Adress: TAdress; Value: byte);
    function read(Adress: TAdress): byte;

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
  SetFileSize(FileName,MemorySizeBytes);
end;

function TEEPROM.read(Adress: TAdress): byte;
begin
  with TFileStream.Create(FileName,fmOpenRead) do
  begin
    Seek(Adress,soBeginning);
    Read(Result,1);
    Free;
  end;
end;

procedure TEEPROM.update(Adress: TAdress; Value: byte);
var
 buffer:byte;
begin
  with TFileStream.Create(FileName,fmOpenReadWrite) do
  begin
    Seek(Adress,soBeginning);
    read(buffer,1);
    if buffer <> Value then
      write(value,1);
    Free;
  end;
end;

procedure TEEPROM.write(Adress: TAdress; Value: byte);
begin
  with TFileStream.Create(FileName,fmOpenWrite) do
  begin
    Seek(Adress,soBeginning);
    write(value,1);
    Free;
  end;
end;

end.
