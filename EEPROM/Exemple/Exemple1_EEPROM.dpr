program Exemple1_EEPROM;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  EEPROM in '..\EEPROM.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.