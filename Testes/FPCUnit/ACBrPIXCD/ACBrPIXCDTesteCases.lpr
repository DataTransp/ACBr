program ACBrPIXCDTesteCases;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, sysutils,
  GuiTestRunner,
  ACBrPIXSchemasTeste, ACBrTests.Util;

{$R *.res}

begin
  {$IFDEF DEBUG}
   DeleteFile( 'heaptrclog.trc');
   SetHeapTraceOutput( 'heaptrclog.trc');
  {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

