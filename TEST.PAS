Program Test;

Uses OsSystem;

Begin
 WriteLn('-------------------------------------------');
 Case Test8086 of
 0: WriteLn('8086/8088 CPU Detected');
 1: WriteLn('80286 CPU Detected');
 2: WriteLn('80386 CPU or later Detected');
 { 2 AND LATER DETECTED BY DPMI SERVER AT START }
 3: WriteLn('80486 CPU or later detected');
 end;
 If TestDPMI <> 00 then
  WriteLn('DPMI Server Version: ', Hi(TestDPMI),'.',Lo(TestDPMI))
 else
  WriteLn('No DPMI server found.');
 If TestXMS <> 00 then
  WriteLn('XMS Server Version: ', Hi(TestXMS),'.',Lo(TestXMS))
 else
  WriteLn('No XMS Server found.');
 If TestEMS <> 00 then
  WriteLn('EMS Server Version: ', Hi(TestEMS),'.',Lo(TestEMS))
 else
  WriteLn('No EMS Server found.');
 if (TestShell = ShellNDosNovell) then
  WriteLn('Running under Novell and Ndos/4Dos')
 else if (TestShell = ShellNDos) then
  WriteLn('Running under 4DOS/NDOS')
 else if (TestShell = ShellNovell) then
  WriteLn('Running under Novell');
 Case TestOS of
 OSWindows:WriteLn('Running under Windows.');
 OSNone: WriteLn('Running under DOS.');
 OSOS2: WriteLn('Running under OS/2.');
 OSDesqview: WriteLn('Running under desqview.');
 end;

end.