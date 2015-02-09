program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, LCLType, Unit1, unit2, uniqueinstance_package, uniqueinstanceraw;

{$R *.res}

begin
  Application.Title:='FileMon';
  RequireDerivedFormResource := True;

  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  if InstanceRunning() then    Application.Terminate;
  Application.Run;

end.

