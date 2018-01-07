program Exemple1_EEPROM;

uses
  Vcl.Forms,
  Main in 'Main.pas' {fmExemple1},
  uEEPROM in '..\uEEPROM.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmExemple1, fmExemple1);
  Application.Run;
end.
