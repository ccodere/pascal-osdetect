{************************************************}
{                                                }
{   Operating System / Memory Specific Routines  }
{   Carl Eric Codere                             }
{   Montreal, Canada                             }
{   VERSION 2.00                                 }
{************************************************}
{   UNIT MAX HEAP USAGE: 000000 BYTES            }
{************************************************}
(* Copyright (C) 1996 Carl Eric Codere                                    *)
(* All rights reserved. (This is not freeware)                            *)
(* - you have the right to modify this source code as long as I it is not *)
(*   re-released in source code form.                                     *)
(* - for commercial use of this code, you must contact me                 *) 
(* - no re-release of this source code can be done without my cosent      *)
(* -> There is no warranty whatsoever that this program will not kill     *)
(* -> your computer, even though it has been tested successfully on three *)
(* -> PC's                                                                *)
(* Contact me at: carl.codere@evening.magicnet.com                        *)
(*  From 1995-1998 you can also contact me at:                            *)
(*      cecodere@andrew.sca.usherb.ca (preferred)                         *)
Unit OSSystem;
(* Operating System / Shell Specific Code. Detects type of Multitasker    *)
(* at startup. Also detects if TAME is loaded at Startup.                 *)
(*                                            .                           *)


(**************************************************************************)
(*  Tested under the following Shells/Operating Systems:                  *)
(*    Novell using Windows 3.11 for Workgroups                            *)
(*    Desqview                                                            *)
(*    Tame                                                                *)
(*    Windows 3.1                                                         *)
(*    DOS and NDOS  / real and protected modes.                           *)
(*    Windows'95 using Novell and Ndos as primary shell                   *)
(**************************************************************************)


{$IFDEF WINDOWS}
 ERROR: This Program must Run Under the DOS Platform.
{$ENDIF}

{$IFNDEF CPU86}
 ERROR: This Program Requires a x86 Machine.
{$ENDIF}

{$IFNDEF VER70}
 ERROR: This program uses TP v7.0 syntax
{$ENDIF}


{$O-} (* Unit Cannot be overlaid *)

Interface

{$IFDEF DPMI}
Uses Objects, WinAPI, DOS;
{$ELSE}
Uses Objects, DOS;
{$ENDIF}

(*************************************************************************)
(*                    TESTSHELL POSSIBLE VALUES                          *)
(*************************************************************************)
Const

 ShellNone    = $00;    (* Running under COMMAND.COM           *)
 ShellNDos    = $01;    (* Running NDOS/4DOS Shell             *)
 ShellNovell  = $02;    (* Running Novell Network under COMMAND*)
 ShellNDosNovell = $03; (* Running Novell + NDOS / 4DOS        *)

(*************************************************************************)
(*                       TESTOS POSSIBLE VALUES                          *)
(*************************************************************************)
(* THESE WILL AFFECT MULTITASKING ABILITIES *)
 OSNone       = $00;    (* Running Under DOS / DOS 5.0+ or true clone *)
 OSOS2        = $01;    (* Running Under OS/2 Version 2.x      *)
 OSWindows    = $02;    (* Running Under Windows/386           *)
 OSDesqview   = $03;    (* Running Desqview / Topview          *)
 OSDoubleDos  = $04;    (* Running DoubleDOS                   *)
 OSCPMDOS     = $05;    (* Running Concurrent DOS MultiUser    *)
 OSDPMI       = $06;    (* Running DPMI Host V1.0+             *)
 OSNT         = $07;    (* Running under Windows NT            *)

(* THESE MUST BE PUT BY HAND IN TESTOS - NOT DETECTED *)
 OSMultiLink  = $20;   (* Not Detect by Detect Shell Routine   *)
 OSOmniview   = $21;   (* Not Detected By Detect Shell Routine *)
 OSMultiDos   = $22;   (* Not Detected By Detect Shell Routine *)
 OSPCMOS386   = $23;   (* Not Detected By Detect Shell Routine *)


(*************************************************************************)
(*                      GLOBAL SYSTEM VARIABLES                          *)
(*************************************************************************)
VAR
 TestDPMI: Word;       { Returns DPMI Version, 0000 if not running DPMI   }
 TestXMS:  Word;       { Returns XMS Version,  0000 if not running XMS    }
 TestEMS:  Word;       { Returns EMS Version,  0000 if not running EMS    }
 TestShell: Byte;      { TYPE OF SHELL RUNNING - See Above                }
 TestOS:    Byte;      { TYPE OF OS RUNNING    - See Above                }
 TestTame:  Boolean;   { TRUE if TAME is Running                          }

(*************************************************************************)
(*                        MultiTasking Objects                           *)
(*************************************************************************)
(* PROCEDURE GiveTimeSlice: Gives The Rest of the Time Slice to the OS.  *)
(* PROCEDURE BeginCritical: Stops Task-Swtiching until EndCritical called*)
(* PROCEDURE EndCritical:   Starts Task-switching again                  *)
(* CONSTRUCTOR Init:        Presently Does Nothing.                      *)
(* DESTRUCTOR Done:         Presently Does Nothing                       *)
(*************************************************************************)
TYPE
(* This Object which is also the base object should be used when   *)
(* the following is detected: OS/2, PC-MOS/386, DOS 5.00 and later *)
(* Can also be called by DOS which is below ver 5.00, but will do  *)
(* nothing.                                                        *)
 PMultiTask = ^TMultiTask;
 TMultiTask = Object
  Universal: Boolean; { Is the universal Give Time slice proc supported }
  Constructor Init;
  Procedure GiveTimeSlice; Virtual;
  Procedure BeginCritical; Virtual;
  Procedure EndCritical; Virtual;
  Destructor Done; Virtual;
 end;

(* Should be called under MultiDOS - WHICH IS NOT DETECTED AT STARTUP *)
 PMultiDos = ^TMultiDOS;
 TMultiDOS = Object(TmultiTask)
  Constructor Init;
  Procedure GiveTimeSlice; Virtual;
  Procedure BeginCritical; Virtual;
  Procedure EndCritical; Virtual;
 end;


(* Should be called under DoubleDOS *)
 PDoubleDos = ^TDoubleDos;
 TDoubleDOS = Object(TMultiTask)
  Constructor Init;
  Procedure GiveTimeSlice; Virtual;
  Procedure BeginCritical; Virtual;
  Procedure EndCritical; Virtual;
 end;

(* Should be called under CSwitch - WHICH IS NOT DETECTED AT START UP  *)
 PCswitch = ^TCSwitch;
 TCSwitch = Object(TMultiTask)
  Constructor Init;
  Procedure GiveTimeSlice; Virtual;
 end;

(* Should be called under Multilink Advanced - NOT DETECTED AT START UP *)
 PMultiLink = ^TMultiLink;
 TMultiLink = Object(TMultiTask)
  Constructor Init;
  Procedure GiveTimeSlice; Virtual;
 end;

(* Should be called by Real Mode applications under Windows Enhanced *)
 Pwindows = ^TWindows;
 TWindows = Object(TMultiTask)
  Constructor Init;
  Procedure GiveTimeSlice; Virtual;
  Procedure BeginCritical; Virtual;
  Procedure EndCritical; Virtual;
 end;


(* Should be called when Running under Concurrent DOS MultiUser     *)
 PMultiUserDos = ^TMultiUserDos;
 TMultiUserDOS = Object(TMultiTask)
  Constructor Init;
  Procedure GiveTimeSlice; Virtual;
 end;

(* Should be called when Running under desqview / Topview / Taskview *)
 PDesqview = ^TDesqview;
 TDesqview = Object(TMultiTask)
  Constructor Init;
  Procedure GiveTimeSlice; Virtual;
  Procedure BeginCritical; Virtual;
  Procedure EndCritical; Virtual;
 end;
(*********************************************************************)
(*                    PROTECTED MODE TYPES                           *)
(*********************************************************************)
     LongRec = record
       Selector, Segment : word;
     end;

     DoubleWord = record
       Lo, Hi : word;
     end;

     QuadrupleByte = record
       Lo, Hi, sLo, sHi : byte;
     end;

     TDPMIRegisters = record
       EDI, ESI, EBP, Reserved, EBX, EDX, ECX, EAX : longint;
       Flags, ES, DS, FS, GS, IP, CS, SP, SS : word;
     end;


(*************************************************************************)
(* FUNCTION VerifyEMSPresent: Returns TRUE if EMS Driver Present in Mem  *)
(* FUNCTION VerifyXMSPresent: Returns TRUE if XMS Driver Present in Mem  *)
(* FUNCTION VerifyDPMIPresent: Returns TRUE if DPMI Driver Present in Mem *)
(* FUNCTION GetXMSVersion:  Returns XMS Driver Version Number            *)
(* FUNCTION GetDPMIVersion: Returns DPMI Driver Version Number           *)
(* FUNCTION GetEMSVersion:  Returns EMS Driver Version Number            *)
(* FUNCTION DetectShell: Returns the Type of OS/ Shell Running           *)
(* FUNCTION TameInstalled: Returns TRUE is Tame is present in memory     *)
(*************************************************************************)

FUNCTION VerifyEMSPresent: Boolean; Far;  { IN DPMI CHECKS IF DPMI EMS SERVER }
FUNCTION VerifyXMSPresent: Boolean; Far;  { IN DPMI CHECKS IF DPMI XMS SERVER }
FUNCTION VerifyDPMIPresent: Boolean; Far; { PROTECTED/REAL MODES }
FUNCTION GetXMSVersion: Word; Far;        { DPMI: GET XMS DPMI SERVER VERSION }
FUNCTION GetEMSVersion: Word; Far;        { DPMI: GET EMS DPMI SERVER VERSION }
FUNCTION GetDPMIVersion: Word; Far;       { PROTECTED/REAL MODES }

FUNCTION GetFreeEMS: Word; Far;
FUNCTION GetFreeXMS: Word; Far;

FUNCTION DetectShell: Word;               { PROTECTED/REAL MODES }
FUNCTION TameInstalled: Boolean;          { PROTECTED/REAL MODES }

(*********************************************************************)
(*  PROTECTED MODE MEMORY MANAGEMENT ROUTINES.                       *)
(*  RealModeInt -> Call a real mode interrupt via DPMI server.       *)
(*     IntNo -> Real mode interrupt to invoke                        *)
(*     Regs -> Registers to use in calling interrupt.                *)
(*             UNUSED REGISTERS SHOULD BE SET TO ZERO!               *)
(*  XGlobalDOSAlloc -> Allocate some DOS memory (Real Seg:Ofs)       *)
(*     Returns word -> Segment of allocated memory block.(Real)      *)
(*     P: Pointer -> Selector:Offset of allocated block (Prot).      *)
(*  XGlobalDOSFree -> Free DOS Memory                                *)
(*     P: Pointer -> Selector:Offset of allocated block to free      *)
(*********************************************************************)

{$IFDEF DPMI}
Procedure RealModeInt(IntNo : word; var Regs : TDPMIRegisters);
function XGlobalDosAlloc(Size : longint; var P : Pointer) : word;
Procedure XGlobalDOSFree(Var P: Pointer);

{$ENDIF}



(* DOS Specific Procedures/Functions *)
Procedure MakeFileBackup(Const BackOn:Boolean;FName:FNameStr;Buf:Pointer;Size:Word);
(* Writes output to disk on FName, if BackOn is true, and if file alredy exists *)
(* then old file is renamed with a .BAK extension before be rewritten.          *)
(* Writes everything from pointer of a size size bytes                          *)
Function GetAltKey:Boolean;       (* Returns true if the Alt-Key is pressed *)
Function VerifyFilePresence(Const FName:FNameStr):Boolean;
(* Verifies if a file is present in a directory *)




Implementation

Const
 API4DOS       = $D44D;
 APINDOS       = $E44D;
 TSRInterrupt  = $2F;
 Dos_Function  = $21;

Function VerifyEMSPresent:Boolean;
 (*********************************************************************)
 (*    FUNCTION VerifyEMSPresent: Boolean                             *)
 (*                                                                   *)
 (*    Returns TRUE if there is an EMS manager present in             *)
 (*    memory. Otherwise returns False.                               *)
 (*  BTW THE Intr SHOULD CRASH ON A DPMI, SO WATCH OUT!!!             *)
 (*********************************************************************)
Var
      Emm_Device_Name       : string[8];
      Int_67_Device_Name    : string[8];
      Position              : integer;
      Regs                  : registers;
      EMSVector             : Pointer;
    Begin
        Int_67_Device_Name := '';
        Emm_Device_Name    := 'EMMXXXX0';
        with Regs do
         Begin
          {------------------------------------------------------}
          {   Get the code segment pointed to by interrupt 67h,  }
          {   the EMM interrupt by using DOS function 35h.       }
          {   (get interrupt vector)                             }
          {------------------------------------------------------}
          GetIntVec($67, EMSVector);
          For Position := 0 to 7 do
           Int_67_Device_Name :=
                    Int_67_Device_Name+Chr(Mem[Seg(EMSVector^):Position+$0A]);
          {------------------------------------------------------}
          {   If the string is the EMM manager signature,        }
          {   'EMMXXXX0', then EMM is installed and ready for    }
          {   use.  If not, then EMM is not present.             }
          {------------------------------------------------------}
          If Int_67_Device_Name = Emm_Device_Name
            then VerifyEMSPresent := True
          Else   VerifyEMSPresent := False
        end; { with Regs do }
    End;


Function VerifyXMSPresent:Boolean;Assembler;
 (*********************************************************************)
 (*   FUNCTION VerifyXMSPresent: Boolean                              *)
 (*                                                                   *)
 (*    Returns TRUE if there is an XMS Driver in memory,              *)
 (*    otherwise returns FALSE.                                       *)
 (*********************************************************************)
ASM
 MOV AX,4300h;         { AX = 4300h to Call Function             }
 INT 2Fh;              { Call Function: XMS Driver Install Check }
 CMP AL,80h;           { If AL = 80h then Driver is Present      }
 JNZ @Nope;            { ZF = 0 so AL <> 80h JMP To Label        }
 MOV AL, TRUE       ;  { Function = TRUE, Driver is Present      }
 RET                  (* No Parameters, Direct Return from PROC *)
@Nope:
 XOR AL,AL;           { Function = FALSE, Driver is Not Present }
 RET                  (* No Parameters, Direct Return From PROC *)
end;


{$IFNDEF DPMI}

Function VerifyDPMIPresent: Boolean; Assembler;
 (*********************************************************************)
 (*  FUNCTION VerifyDPMIPresent: Boolean;                             *)
 (*                                                                   *)
 (*   Returns TRUE if a DPMI server is Present in memory,             *)
 (*   otherwise returns FALSE.                                        *)
 (*********************************************************************)
ASM
 MOV AX, 1687h
 INT 2Fh
 CMP AX, 0000h
 JNE @NoDPMI              ; (* If AX <> 0000 then NO DPMI Server           *)
 MOV AL, TRUE
 RET
@NoDPMI:
 MOV AL, FALSE
 RET
end;

{$ELSE}

 (*********************************************************************)
 (*  FUNCTION VerifyDPMIPresent: Boolean;                             *)
 (*                                                                   *)
 (*   Returns TRUE. IN PROTECTED MODE APPLICATIONS, THERE MUST BE     *)
 (*   A DPMI SERVER, OTHERWISE THE PROGRAM WILL NOT RUN!              *)
 (*********************************************************************)
FUNCTION VerifyDPMIPresent: Boolean; Assembler;
ASM
 MOV AL, 01h
end;
{$ENDIF}

{$IFNDEF DPMI}

(*************************************************************************)
(*  FUNCTION GetDPMIVersion: Word                                        *)
(*    Returns the version of the DPMI Server                             *)
(*                                                                       *)
(*  Returns HIGH BYTE = MAJOR DPMI Version                               *)
(*  Returns LOW BYTE  = MINOR DPMI Version                               *)
(*  Returns 0000 if DPMI not installed.                                  *)
(*************************************************************************)
Function GetDPMIVersion: Word; Assembler;
ASM
 MOV AX, 1687h            ; { Prepare Interrupt service routine   }
 INT 2Fh                  ; { Call MultiPlex Interrupt            }
 CMP AX, 0000h            ; { If AX = 0000h then DPMI installed   }
 JNE @NoDPMI
 { Nil }                  ; { Version stored in DX                }
 MOV AX, DX               ; { Put Result into AX (Function Result }
 RET                      ; { Return from procedure               }
@NoDPMI:                  ; { No DPMI Installed                   }
 MOV AX, 0000h            ; { Result of Function is zero          }
 RET                      ; { Return from procedure               }
end;

{$ELSE}

(*************************************************************************)
(*  FUNCTION GetDPMIVersion: Word                                        *)
(*    Returns the version of the DPMI Server                             *)
(*                                                                       *)
(*  Returns HIGH BYTE = MAJOR DPMI Version                               *)
(*  Returns LOW BYTE  = MINOR DPMI Version                               *)
(*  THIS IS FOR DPMI APPLICATIONS THEREFORE ALWAYS RETURNS VERSION       *)
(*************************************************************************)
Function GetDPMIVersion: Word; Assembler;
ASM
 MOV AX, 0400h            ; { Prepare Interrupt service routine   }
 INT 31h                  ; { Call MultiPlex Interrupt            }
 { Value is directly returned in AX }
end;

{$ENDIF}





(*************************************************************************)
(* FUNCTION GetXMSVersion: Word;                                         *)
(*                                                                       *)
(*  Returns the Version of the XMS Server, 0000 if not installed.        *)
(*                                                                       *)
(*  Returns HIGH BYTE = MAJOR XMS  Version                               *)
(*  Returns LOW BYTE  = MINOR XMS  Version                               *)
(*************************************************************************)
Function GetXMSVersion: Word; Assembler;
Var
 Proc: Pointer;
ASM
 MOV AX, 4300h            ; { Set up interrupt service routine }
 INT 2Fh
 CMP AL, 80h              ; { AL = 80h then XMS driver in mem  }
 JNE @NoXMSDriver         ; { AL <> 80h , then no driver       }
 MOV AX, 4310h            ; { Get entry point of XMS driver    }
 INT 2Fh
 MOV WORD PTR [Proc], BX  ; { ES:BX -> Entry point pointer     }
 MOV WORD PTR [Proc+2], ES
 MOV AH, 00h              ; { Set up Function Call XMS Version }
 CALL [Proc]              ; { Call Entry point driver          }
 { Nil }                  ; { Version number stored in AX      }
 JMP @End
@NoXMSDriver:
 MOV AX, 0000h            ; { Function returns 0000, no driver }
 JMP @End
@End:
end;

(*************************************************************************)
(* FUNCTION GetEMSVersion: Word;                                         *)
(*                                                                       *)
(*  Returns the Version of the EMS Server, 0000 if not installed.        *)
(*                                                                       *)
(*  Returns HIGH BYTE = MAJOR EMS  Version                               *)
(*  Returns LOW BYTE  = MINOR EMS  Version                               *)
(*************************************************************************)
Function GetEMSVersion: Word;
VAR
 Regs: Registers;
 TmpVal:Record
   LLow: Byte;
   LHi: Byte;
 end;
Begin
 If VerifyEMSPresent then
 BEGIN
  Regs.AH := $46;
  Intr($67, Regs);
  IF Regs.AH <> $00 THEN
  BEGIN
   GetEMSVersion := $00;
   Exit;
  END
   ELSE
   BEGIN
      TmpVal.LLow := Regs.AL AND $0F;
      TmpVal.LHi := (Regs.AL AND $F0) SHR 4;
      GetEMSVersion:= Word(TmpVal);
   END;
 END
 ELSE
  GetEMSVersion := $0000;
end;

(*************************************************************************)
(* FUNCTION GetFreeEMS: Word;                                            *)
(*                                                                       *)
(*  Returns the number Kilobytes that is still free in EMS.              *)
(*                                                                       *)
(*************************************************************************)
Function GetFreeEMS: Word;
Var
 Value: Word;
 Regs: Registers;
Begin
 GetFreeEMS := 000;
 Value := GetEMSVersion;  (* This must be called to get EMS Version FIRST  *)
                          (* since DOS 6.0 will CRASH in AUTO MODE if this *)
                          (* is not done.                                  *)
 If Value = $0000 then Exit; (* EMS not installed *)
 ASM
  MOV AH, 42h
  INT 67h
  CMP AH, 00h
  JNE @Error
  SHL BX, 1               ; (* Number of KBytes free: Pages * 16           *)
  SHL BX, 1
  SHL BX, 1
  SHL BX, 1
  MOV @Result, BX
 @Error:
 end;
end;


(*************************************************************************)
(* FUNCTION GetFreeXMS: Word;                                            *)
(*                                                                       *)
(*  Returns the LARGEST XMS Free Block in XMS.                           *)
(*                                                                       *)
(*************************************************************************)
Function GetFreeXMS: Word; Assembler;
Var
 Proc: Pointer;
ASM
 MOV AX, 4300h            ; { Set up interrupt service routine }
 INT 2Fh
 CMP AL, 80h              ; { AL = 80h then XMS driver in mem  }
 JNE @NoXMSDriver         ; { AL <> 80h , then no driver       }
 MOV AX, 4310h            ; { Get entry point of XMS driver    }
 INT 2Fh
 MOV WORD PTR [Proc], BX  ; { ES:BX -> Entry point pointer     }
 MOV WORD PTR [Proc+2], ES
 MOV AH, 08h              ; { Set up Function Call Get Memory  }
 CALL [Proc]              ; { Call Entry point driver          }
 { Nil }                  ; { Largest KByte Free stored in AX  }
 CMP BL, 80h              ; { XMS Function Not implemented ERROR }
 JE @NoXMSDriver
 CMP BL, 81h              ; { VDISK Detected ERROR              }
 JE @NoXMsDriver
 CMP BL, 0A0h             ; { No More XMS Memory ERROR          }
 JE @NoXMSDriver
 JMP @End
@NoXMSDriver:
 MOV AX, 0000h            ; { Function returns 0000, no driver }
 JMP @End
@End:
end;

{$IFDEF DPMI}

(*************************************************************************)
(*  FUNCTION DetectShell: Word;                                          *)
(*                                                                       *)
(*   This function returns the shell type presently running.             *)
(*     PROTECTED MODE VERSION.                                           *)
(*   LOW BYTE = Shell Type                                               *)
(*   HIGH BYTE = Operating System Type                                   *)
(*************************************************************************)
Function DetectShell: Word;
(* Low Byte  = Shell Type *)
(* High Byte = OS Type    *)
Var
 ShellVal: Byte;  { Temporary storage of Shell Value }
 Regs: TDPMIRegisters;
 OS: Byte;
Begin
(***********************************************)
(*      4DOS / NDOS INSTALLATION CHECK         *)
(***********************************************)
 FillChar(Regs, SizeOf(Regs), #0);
 Regs.EAX := Api4DOS;
 Regs.EBX := $0000;
 RealModeInt($2F, Regs);
 If Regs.EAX = $44DD then
  ShellVal := ShellNDos
 else
  ShellVal := ShellNone;
 FillChar(Regs, SizeOf(Regs), #0);
 Regs.EAX := ApiNDOS;
 Regs.EBX := $0000;
 RealModeInt($2F, Regs);
 If Regs.EAX = $44EE then
  ShellVal := ShellNDos;
(***********************************************)
(*      NOVELL NET  INSTALLATION CHECK         *)
(***********************************************)
 FillChar(Regs, SizeOf(Regs), #0);
 Regs.EAX := $7A00;
 RealModeInt($2F, Regs);
 If QuadrupleByte(Regs.EAX).Lo = $FF then
  Inc(ShellVal, ShellNovell);
(* We have to check for the following multitaskers:          *)
(* - OS/2 Version 2.0+                                       *)
(* - Windows Enhanced Mode                          TESTED   *)
(* - Desqview / TopView                             TESTED   *)
(* - DoubleDos                                               *)
(* - Protected Mode Server 1.0+                     TESTED   *)
(* - Concurrent DOS/ MultiUser Version                       *)

(***********************************************)
(*      OS/2 VER 2+ INSTALLATION CHECK         *)
(***********************************************)
 FillChar(Regs, SizeOf(Regs), #0);
 Regs.EAX := $4010;
 RealModeInt($2F, Regs);
 If Regs.EAX <> $4010 then
 Begin
   ASM
    MOV AL, [ShellVal]
    MOV AH, OSOs2
    MOV [@Result], AX
   end;
  Exit;
 end;
(************************************************)
(*      WINDOWS/386 - Windows95/Windows98/WinMe *) 
(*      INSTALLATION CHECK                      *)
(************************************************)
 FillChar(Regs, SizeOf(Regs), #0);
 Regs.EAX := $1600;
 RealModeInt($2F, Regs);
 If NOT (QuadrupleByte(Regs.EAX).Lo in [$00, $80]) then
  (* Neither Windows/386 2.x nor Windows/386 3 Running if IN AL = $00 *)
  (* If AL = 80h then XMS Driver present, no windows if AL = $80      *)
  { Therefore the opposite tells us that Windows is running           }
 Begin
   ASM
    MOV AL, [ShellVal]
    MOV AH, OSWindows
    MOV [@Result], AX
   end;
  Exit;
 end;
(***********************************************)
(*      WINDOWS NT  INSTALLATION CHECK         *)
(***********************************************)
 FillChar(Regs, SizeOf(Regs), #0);
 Regs.EAX := $3306;
 RealModeInt($21, Regs);
 if (QuadrupleByte(Regs.EAX).Lo <> $ff) and (QuadrupleByte(Regs.EBX).Hi < 100) and
   (QuadrupleByte(Regs.EBX).Lo >= 5) then
  begin
    if (QuadrupleByte(Regs.EBX).Hi = 50) and (QuadrupleByte(Regs.EBX).Lo = 5) then
      begin
        DetectShell:=(OSNT shl 8) or ShellVal;   
        exit;
      end;
  end;

(***********************************************)
(*     DESQVIEW/TOPVIEW INSTALLATION CHECK     *)
(***********************************************)
 FillChar(Regs, SizeOf(Regs), #0);
 Regs.EAX := $2B01;
 Regs.ECX := $4445;
 Regs.EDX := $5351;
 RealModeInt($21, Regs);
 If QuadrupleByte(Regs.EAX).Lo <> $FF then
 (* If AL = FFh then Desqview is NOT loaded      *)
 Begin
   ASM
    MOV AL, [ShellVal]
    MOV AH, OSDesqview
    MOV [@Result], AX
   end;
  Exit;
 end;
(* Check For Topview                  *)
 FillChar(Regs, SizeOf(Regs), #0);
 Regs.EAX := $1022;
 Regs.EBX := $0000;
 RealModeInt($15, Regs);
 If Regs.EBX <> $0000 then
 Begin
   ASM
    MOV AL, [ShellVal]
    MOV AH, OSDesqview
    MOV [@Result], AX
   end;
  Exit;
 end;
(***********************************************)
(*      DOUBLEDOS   INSTALLATION CHECK         *)
(***********************************************)
 FillChar(Regs, SizeOf(Regs), #0);
 Regs.EAX := $E400;
 RealModeInt($21, Regs);
 If QuadrupleByte(Regs.EAX).Lo <> 00 then
 Begin
   ASM
    MOV AL, [ShellVal]
    MOV AH, OSDoubleDOS
    MOV [@Result], AX
   end;
  Exit;
 end;
(***********************************************)
(*      DPMI V1.0+  INSTALLATION CHECK         *)
(***********************************************)
 If Hi(GetDPMIVersion) >= 1 then
 Begin
   ASM
    MOV AL, [ShellVal]
    MOV AH, OSDPMI
    MOV [@Result], AX
   end;
  Exit;
 end;
(***********************************************)
(*      Concurrent  INSTALLATION CHECK         *)
(***********************************************)
 FillChar(Regs, SizeOf(Regs), #0);
 Regs.EAX := $4451;
 RealModeInt($21, Regs);
 { Verify if error, and verify is truly a multi user version }
 If ((Regs.Flags AND fCarry) = $00) and (QuadrupleByte(Regs.EAX).Lo = $14) then
 Begin
   ASM
    MOV AL, [ShellVal]
    MOV AH, OSCPMDOS
    MOV [@Result], AX
   end;
  Exit;
 end;
(***********************************************)
(*          NORMAL DOS RUNNING                 *)
(***********************************************)
(* RUNNING NORMAL DOS *)
ASM
 MOV AL, [ShellVal]
 MOV AH, OSNone
 MOV [@Result], AX
end;
end;

{$ELSE}

(*************************************************************************)
(*  FUNCTION DetectShell: Word;                                          *)
(*                                                                       *)
(*   This function returns the shell type presently running.             *)
(*                                                                       *)
(*   LOW BYTE = Shell Type                                               *)
(*   HIGH BYTE = Operating System Type                                   *)
(*************************************************************************)
Function DetectShell: Word; Assembler;
(* Low Byte  = Shell Type *)
(* High Byte = OS Type    *)
Var
 ShellVal: Byte;  { Temporary storage of Shell Value }
ASM
(***********************************************)
(*      4DOS / NDOS INSTALLATION CHECK         *)
(***********************************************)
 MOV AX, Api4DOS          ; (* API Function Call 4DOS - Installation Check *)
 MOV BH, 00h
 INT TSRInterrupt
 CMP AX, 44DDh
 JE @4DOS
 MOV AX, ApiNDos          ; (* API Function Call NDOS - Installation Check *)
 MOV BH, 00h
 INT TSRInterrupt
 CMP AX, 44EEh
 JE @4DOS
 JMP @Not4DOS
@4DOS:                    ;(* Running 4DOS/NDOS - Set Correct Shell Var.   *)
 MOV [ShellVal], ShellNDos
 JMP @NovellCheck
@Not4DOS:                 ; (* Running Standard Shell                      *)
 MOV [ShellVal], ShellNone
 JMP @NovellCheck
(***********************************************)
(*      NOVELL NET  INSTALLATION CHECK         *)
(***********************************************)
@NovellCheck:             ;(* Continue by checking if running Novell Net  *)
 MOV AX, 7A00h
 INT TSRInterrupt
 CMP AL, 0FFh
 JE @NovellPresent
 JMP @Continue
@NovellPresent:
 ADD [ShellVal], ShellNovell      ;(* Add Novell Value and continue                *)
@Continue:
(* We have to check for the following multitaskers:          *)
(* - OS/2 Version 2.0+                                       *)
(* - Windows Enhanced Mode                          TESTED   *)
(* - Desqview / TopView                             TESTED   *)
(* - DoubleDos                                               *)
(* - Protected Mode Server 1.0+                     TESTED   *)
(* - Concurrent DOS/ MultiUser Version                       *)

(***********************************************)
(*      OS/2 VER 2+ INSTALLATION CHECK         *)
(***********************************************)
 MOV AX, 4010h
 INT TSRInterrupt
 CMP AX, 4010h
 JE @NoOS2
 MOV AH, OSOS2            ; (* OS/2 Version 2.0+ Is Running                *)
 MOV AL, [ShellVal]       ; (* Get Type of Shell Running                   *)
 JMP @End                 ; (* Return from Function, we got all info       *)
@NoOS2:
(***********************************************)
(*      WINDOWS/386 INSTALLATION CHECK         *)
(***********************************************)
 MOV AX, 1600h            ; (* Prepare Windows Check                       *)
 INT TSRInterrupt
 CMP AL, 00h        ; (* Neither Windows/386 2.x nor Windows/386 3 Running *)
 JE @NoWindows
 CMP AL, 80h        ; (* If AL = 80h then XMS Driver present, no windows   *)
 JE @NoWindows
 MOV AL, [ShellVal]       ; (* Get Type of Shell Running                   *)
 MOV AH, OSWindows        ; (* Windows enhanced mode is running            *)
 JMP @End                 ; (* Return From Function , we got all info      *)
@NoWindows:
(***********************************************)
(*      WINDOWS NT  INSTALLATION CHECK         *)
(***********************************************)
 MOV AX,3306h
 INT DOS_Function
 CMP AL,0FFh
 JE  @NoNT
 CMP BH,100
 JG  @NoNT
 CMP BL,5
 JNE @NoNT
 CMP BH,50
 JNE @NoNT
 MOV AL, [ShellVal]   
 MOV AH, OSNT        
 JMP @End            
@NoNT:
(***********************************************)
(*     DESQVIEW/TOPVIEW INSTALLATION CHECK     *)
(***********************************************)
 MOV AH, 2Bh
 MOV CX, 4445h
 MOV DX, 5351h
 MOV AL, 01h
 INT Dos_Function
 CMP AL, 0FFh             ; (* If AL = FFh then Desqview is NOT loaded      *)
 JE @NoDV
 MOV AL, [ShellVal]
 MOV AH, OSDesqview
 JMP @End                 ; (* Return from Function, we got all info        *)
@NoDV:
(* Check For Topview                  *)
 MOV AX, 1022h
 MOV BX, 0000h
 INT 15h
 CMP BX, 0000h    ; (* If BX = 0000h then Topview or compatible is NOT loaded *)
 JE @NoTopview
 MOV AL, [ShellVal]
 MOV AH, OSDesqview
 JMP @End
@NoTopview:
(***********************************************)
(*      DOUBLEDOS   INSTALLATION CHECK         *)
(***********************************************)
 MOV AX, 0E400h
 INT DOS_Function
 CMP AL, 00h
 JE @NoDoubleDos
 MOV AL, [ShellVal]
 MOV AH, OsDoubleDos
 JMP @End
@NoDoubleDos:
(***********************************************)
(*      DPMI V1.0+  INSTALLATION CHECK         *)
(***********************************************)
 MOV AX, 1687h
 INT TSRInterrupt
 CMP AX, 0000h
 JNE @NoDPMI              ; (* If AX <> 0000 then NO DPMI Server           *)
 CMP DH, 01               ; (* We need version 1.0+ only                   *)
 JL @NoDPMI               ; (* Less then Version 1.00, we do not need      *)
 MOV AL, [ShellVal]
 MOV AH, OSDPMI           ; (* DOS Protected Mode Server present V1.0+     *)
 JMP @End
@NoDPMI:
(***********************************************)
(*      Concurrent  INSTALLATION CHECK         *)
(***********************************************)
  MOV AX, 4451h
  INT DOS_Function
  JC @NoConcurDOS
  CMP AH, 14h             ; (* Verify if we are truly using Multiuser version *)
  JNE @NoConcurDOS        ; (* This is not a Multi-User version           *)
  MOV AL, [ShellVAl]
  MOV AH, OSCpmDOS        ; (* Return Concurrent DOS MultiUser            *)
  JMP @End
@NoConcurDOS:
(***********************************************)
(*          NORMAL DOS RUNNING                 *)
(***********************************************)
(* RUNNING NORMAL DOS *)
 MOV AL, [ShellVal]
 MOV AH, OSNone
@End:
end;

{$ENDIF}

{$IFDEF DPMI}
(*************************************************************************)
(*  FUNCTION TameInstalled: Boolean;                                     *)
(*                                                                       *)
(*   This function returns TRUE if TAME is installed in memory.          *)
(*   PROTECTED MODE VERSION.                                             *)
(*************************************************************************)
Function TameInstalled: Boolean;
Var
 Regs: TDPMIRegisters;
Begin
 FillChar(Regs, SizeOf(Regs), #0);
 Regs.EAX := $2B01;
 Regs.ECX := $5441;
 Regs.EDX := $4D45;
 RealModeInt($21, Regs);
 If QuadrupleByte(Regs.EAX).Lo = $02 then
  TameInstalled := TRUE
 ELSE
  TameInstalled := FALSE;
end;

{$ELSE}
(*************************************************************************)
(*  FUNCTION TameInstalled: Boolean;                                     *)
(*                                                                       *)
(*   This function returns TRUE if TAME is installed in memory.          *)
(*                                                                       *)
(*************************************************************************)
Function TameInstalled: Boolean; Assembler;
ASM
(* Check for the presence of TAME       *)
(* Multitasker enhancer                 *)
  MOV AX, 2B01h
  MOV CX, 5441h
  MOV DX, 4D45h
  INT DOS_Function
  CMP AL, 02h
  JNE @NoTame             ; (* If AL <> 02 then TAME is NOT Installed     *)
  MOV AL, TRUE
  RET
@NoTame:
  MOV AL, FALSE
end;
{$ENDIF}


(*************************************************************************)
(*                      Object Implementation                            *)
(*************************************************************************)
(* WHEN THERE IS NOTHING -> IT MEANS THAT THE SERVICE IS NOT SUPPORTED   *)
(* BY THAT SHELL OS.                                                     *)

Constructor TMultiTask.Init;
{ THIS INTERRUPT IS CHECKED BOTH IN PROTECTED MODE AND REAL MODE }
Begin
{ Check if universal Give Time slice interrupt is supported }
 ASM
  MOV AX, 1680h                   ; { Set up Service - Give Time Slice }
  INT 2Fh                         ; { Call Multiplex interrupt service }
  CMP AL, 00h                     ; { If AL = 00h service supported    }
  LES DI, [Self]                  ; { Get pointer to this object       }
  JE @Support
  MOV ES:[DI].Universal, FALSE    ; { Service is not supported         }
  JMP @End
 @Support:
  MOV ES:[DI].Universal, TRUE     ; { Service is supported             }
 @End:
 end;
end;


{$IFDEF DPMI}
Procedure TMultiTask.GiveTimeSlice;
Var
 Regs: TDPMIRegisters;
Begin
 { If universal time slice giver is supported use it! }
 IF Universal THEN
 Begin
  ASM
    MOV AX, 1680h
    INT TSRInterrupt
  end;
 end
 else
 Begin
   { If Novell Netware installed use it by calling real mode INT }
   { I do not know , if Novell also works under Protected mode   }
   If TestShell in [ShellNovell, ShellNDOSNovell] then
    Begin
      FillChar(Regs, SizeOf(Regs), #0);
      Regs.EBX := $000A;
      RealModeInt($7A, Regs);
    end;
 end;
end;

{$ELSE}

Procedure TMultiTask.GiveTimeSlice; Assembler;
ASM
 LES DI, [Self]               ; { Get pointer to the current object }
 CMP ES:[DI].Universal, TRUE  ; { Check if Universal Time slice support }
 JE @YesUniverse
 JMP @NovellCheck
@YesUniverse:
 MOV AX, 1680h
 INT TSRInterrupt
 JMP @End
@NovellCheck:
 (* Call Novell Netware idle service *)
 CMP [TestShell], ShellNovell
 JGE @Novell
 CMP [TestShell], ShellNDOSNovell
 JGE @Novell
 JMP @End
@Novell:
 MOV BX, 000Ah
 INT 07Ah
@End:
end;
{$ENDIF}


Procedure TMultiTask.BeginCritical;
Begin
end;

Procedure TMultiTask.EndCritical;
Begin
end;

Destructor TMultiTask.Done;
Begin
end;


Constructor TMultiLink.Init;
Begin
 Inherited Init;
end;

Procedure TMultiLink.GiveTimeSlice; Assembler;
ASM
 MOV AH, 02h
 INT 07Fh
end;


Constructor TCSwitch.Init;
Begin
 Inherited Init;
end;

Procedure TCswitch.GiveTimeSlice; Assembler;
ASM
 MOV AH, 01h
 INT 62h
end;

Constructor TDoubleDOS.Init;
Begin
 Inherited Init;
end;

Procedure TDoubleDOS.BeginCritical; Assembler;
ASM
 MOV AH, 0EAh
 INT DOS_Function
end;

Procedure TDoubleDOS.EndCritical; Assembler;
ASM
 MOV AH, 0EBh
 INT DOS_Function
end;

Procedure TDoubleDOS.GiveTimeSlice; Assembler;
ASM
 MOV AH, 0EEh
 MOV AL, 01h
 INT DOS_Function
end;


Constructor TMultiDOS.Init;
Begin
 Inherited Init;
end;


Procedure TMultiDos.GiveTimeSlice; Assembler;
ASM
 MOV AH, 00h
 INT 15h
end;

Procedure TMultiDOS.BeginCritical; Assembler;
ASM
 MOV AH, 0Dh
 INT 15h
end;

Procedure TMultiDOS.EndCritical; Assembler;
ASM
 MOV AH, 0Eh
 INT 15h
end;






Constructor TMultiUserDOS.Init;
Begin
 Inherited Init;
end;

Procedure TMultiUserDOS.GiveTimeSlice; Assembler;
ASM
 MOV CL, 08Eh
 INT 0E0h
end;

Constructor TWindows.Init;
Begin
 Inherited Init;
end;

Procedure TWindows.BeginCritical; Assembler;
ASM
 MOV AX, 1681h
 INT TSRInterrupt
end;

Procedure TWindows.EndCritical; Assembler;
ASM
 MOV AX, 1682h
 INT TSRInterrupt
end;

Procedure TWindows.GiveTimeSlice; Assembler;
ASM
 MOV AX, 1680h
 INT TSRInterrupt
end;


Constructor TDesqview.Init;
Begin
 Inherited Init;
end;

Procedure TDesqview.GiveTimeSlice; Assembler;
ASM
 MOV AX, 1000h
 INT 15h
end;

Procedure TDesqview.BeginCritical; Assembler;
ASM
 MOV AX, 101Bh
 INT 15h
end;

Procedure TDesqview.EndCritical; Assembler;
ASM
 MOV AX, 101Ch
 INT 15h
end;



Function VerifyFilePresence(Const FName:FNameStr):Boolean;
 (* 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)
 (* *  FUNCTION VerifyFilePresence: Boolean;                   * *)
 (* *   Verifies if the file passed in S is in the current     * *)
 (* *   active directory. If not returns False, otherwise      * *)
 (* *   true.                                                  * *)
 (* *   S: FNameStr -> Full Filename to verify.                * *)
 (* 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)
Var
 AFileRecord: SearchRec;
Begin
  VerifyFilePresence:=False;
  FindFirst(FName,$3F,AFileRecord);
  If DosError = 0 then
    VerifyFilePresence:=True
end;


Procedure MakeFileBackup(Const BackOn:Boolean;FName:FNameStr;Buf:Pointer;Size:Word);
 (* 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)
 (* *  PROCEDURE MakeFileBackup;                               * *)
 (* *   Writes Buf to disk. If BackOn is true, the procedure   * *)
 (* *   verifies if the file exists, if so it renames that     * *)
 (* *   file to a .BAK extension, and then writes the Buf to   * *)
 (* *   disk.                                                  * *)
 (* *     BackOn: Boolean -> If True rename file (on disk)     * *)
 (* *      before writing buf to disk.                         * *)
 (* *     FName: FNameStr -> Name of the file to write to disk * *)
 (* *     Buf: Pointer -> Pointer to the data to be written.   * *)
 (* *     Size: Word   -> Size of the data to be written.      * *)
 (* 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)
Var
 AFile:File;
 F:File;
 ExtString:String[4];
 AFileCopy:FNameStr;
 Position:Byte;
Begin
 If BackOn = False then
 (* Si on ne fait aucun backup du programme alors 괹rire directement *)
 (* le fichier.                                                      *)
 Begin
   Assign(AFile,FName);
   Rewrite(AFile,1);
   BlockWrite(Afile,Buf^,Size);
   Close(Afile);
 end
 else
  Begin
  (* Aller v굍ifier si le fichier Fname + .BAK existe *)
  (* si oui aller l'effacer.                          *)
  { Get the filename extension }
   AFileCopy:=Copy(FName,0,Length(FName));
   Position:=Pos('.',AfileCopy);
   Delete(AFileCopy,Position,Length(AFileCopy));
  { End get the file extension - New File Name WITHOUT Extension is in AFileCopy }
   If VerifyFilePresence(AFileCopy+'.BAK') then
   Begin
   { If AFileCopy.BAK is there, we have to erase it first }
     Assign(F,AFileCopy+'.BAK');
     Erase(F);
   end;
  { Rename the FName file if it exists }
  If VerifyFilePresence(FName) then
  Begin
       Assign(F,FName);
       Rename(F,AFileCopy+'.BAK');
  end;
  { Write the File }
   Assign(AFile,FName);
   Rewrite(AFile,1);
   BlockWrite(Afile,Buf^,Size);
   Close(Afile);
 end;
end;


Function GetAltKey:Boolean;Assembler;
 (* 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)
 (* *  FUNCTION GetAltKey: Boolean;                            * *)
 (* *    Returns true if the Alt key is pressed. Otherwise     * *)
 (* *    the function returns false.                           * *)
 (* 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)
 (* Usage of the BIOS Work area at Seg0040:17h to check if the   *)
 (* Alt key is pressed.                                          *)
 (* Usage of the TP Seg0040 variable to work with DPMI           *)
ASM
 MOV AX,0h;
 MOV ES,[Seg0040];            { SEGMENT Register (ES) = 0  }
 MOV AL,BYTE PTR [ES:17h];    { Go Get the DATA (Byte) at ES:417h i.e 0:417h   }
 AND AL,1000b;                { Isolate BIT 3 (Alt Status) of Byte }
 JZ @NotAlt;                  { Jump if it is Zero                 }
 JMP @Alt;                    { Jump otherwise                     }
@NotAlt:
 MOV AL, FALSE;                   { Function returns False.            }
 RET;
@Alt:
 MOV AL, TRUE;                  { Function Returns True.             }
 RET;
end; { End GetAltKey Routine }


{$IFDEF DPMI}

FUNCTION XGlobalDosAlloc(Size : longint; var P : Pointer) : word;
(*********************************************************************)
(*  FUNCTION XGlobalDOSAlloc(Size: Longint; Var P: Pointer): word    *)
(*   This routine allocates up to size bytes of memory in the        *)
(*   640K low memory area (real mode memory), which can be accessed  *)
(*   with segments:offset pairs.                                     *)
(*      Size: longint -> size in bytes of wanted memory.             *)
(*      P : Pointer -> on return, returns the selector:offset        *)
(*       pair allocated to this memory block.                        *)
(*      returns word -> Segment (REAL MODE!) of allocated memory     *)
(*       block. (real mode offset = 0 in all cases).                 *)
(*********************************************************************)
  var Long : longint;
  begin
    Long := GlobalDosAlloc(Size);
    P := Ptr(LongRec(Long).Selector, 0);
    XGlobalDosAlloc := LongRec(Long).Segment;
  end;


Procedure RealModeInt(IntNo : word; var Regs:TDPMIRegisters); assembler;
(*********************************************************************)
(*  PROCEDURE RealModeInt(IntNo: word; Var Regs: TDPMIRegisters)     *)
(*   Calls the DPMI server to switch to real mode and call the       *)
(*   real mode interrupt. ALL MEMORY REGISTERS (if used) SHOULD      *)
(*   contain REAL MODE ADRESSES!                                     *)
(*       IntNo -> Real mode interrupt to call (0-255)                *)
(*       Regs -> Registers to pass on to interrupt.                  *)
(*        (ALL UNUSED REGISTERS SHOULD BE SET TO 0 ON ENTRY!)        *)
(*********************************************************************)
asm
    PUSH BP                                          { Save BP, just in case }
    MOV BX,IntNo                         { Move the Interrupt number into BX }
    XOR CX,CX                                                     { Clear CX }
    LES DI,Regs                              { Load the registers into ES:DI }
    MOV AX,$300                                { Set function number to 300h }
    INT $31                             { Call Interrupt 31h - DPMI Services }
    JC @Exit                                         { Jump to exit on carry }
    XOR AX,AX                                                     { Clear AX }
    @Exit:                                                      { Exit label }
    POP BP                                                      { Restore BP }
  end;


Procedure XGlobalDOSFree(Var P: Pointer);
(*********************************************************************)
(*  PROCEDURE XGlobalDOSFree(Var P: Pointer)                         *)
(*    Frees up real mode memory allocated with the XGlobalDOSAlloc   *)
(*    routine.                                                       *)
(*    P: Pointer -> SELECTOR:OFFSET Pointer to block of memory to    *)
(*                  free.                                            *)
(*********************************************************************)
Begin
 DoubleWord(P).Hi := GlobalDOSFree(DoubleWord(P).Hi);
end;

{$ENDIF}


(*************************************************************************)
(*                         STARTUP CODE                                  *)
(*************************************************************************)
VAR
 XMSPointer: Pointer;  { Contains Address of API entry point for XMS driver }

Begin
(*************************************************************************)
(*                        PROTECTED MODE CODE                            *)
(*************************************************************************)
{$IFDEF DPMI}
 TestTame := TAMEInstalled;
 { I do not know how to detect the version of these drivers yet }
 TestXMS := 0000;
 TestEMS := 0000;
 TestDPMI := GetDPMIVersion;
 TestShell := Lo(DetectShell);
 TestOS := Hi(DetectShell);
{$ELSE}
(*************************************************************************)
(*                           REAL MODE CODE                              *)
(*************************************************************************)
ASM
(* Check for the presence of TAME       *)
(* Multitasker enhancer                 *)
  MOV AX, 2B01h
  MOV CX, 5441h
  MOV DX, 4D45h
  INT DOS_Function
  CMP AL, 02h
  JNE @NoTame             ; (* If AL <> 02 then TAME is NOT Installed     *)
  MOV [TestTame], 01h
  RET
@NoTame:
  MOV [TestTame], 00h
(* End Check for presence of TAME *)
(***********************************************)
(*      4DOS / NDOS INSTALLATION CHECK         *)
(***********************************************)
 MOV AX, Api4DOS          ; (* API Function Call 4DOS - Installation Check *)
 MOV BH, 00h
 INT TSRInterrupt
 CMP AX, 44DDh
 JE @4DOS
 MOV AX, ApiNDos          ; (* API Function Call NDOS - Installation Check *)
 MOV BH, 00h
 INT TSRInterrupt
 CMP AX, 44EEh
 JE @4DOS
 JMP @Not4DOS
@4DOS:                    ;(* Running 4DOS/NDOS - Set Correct Shell Var.   *)
 MOV [TestShell], ShellNDos
 JMP @NovellCheck
@Not4DOS:                 ; (* Running Standard Shell                      *)
 MOV [TestShell], ShellNone
 JMP @NovellCheck
(***********************************************)
(*      NOVELL NET  INSTALLATION CHECK         *)
(***********************************************)
@NovellCheck:             ;(* Continue by checking if running Novell Net  *)
 MOV AX, 7A00h
 INT TSRInterrupt
 CMP AL, 0FFh
 JE @NovellPresent
 JMP @Continue
@NovellPresent:
 ADD [TestShell], ShellNovell      ;(* Add Novell Value and continue                *)
@Continue:
(***********************************************)
(***********************************************)
(*      OS/2 VER 2+ INSTALLATION CHECK         *)
(***********************************************)
 MOV AX, 4010h
 INT TSRInterrupt
 CMP AX, 4010h
 JE @NoOS2
 MOV [TestOS], OSOS2      ; (* OS/2 Version 2.0+ Is Running                *)
 JMP @End                 ; (* Return from Function, we got all info       *)
@NoOS2:
(***********************************************)
(*      WINDOWS/386 INSTALLATION CHECK         *)
(***********************************************)
 MOV AX, 1600h            ; (* Prepare Windows Check                       *)
 INT TSRInterrupt
 CMP AL, 00h        ; (* Neither Windows/386 2.x nor Windows/386 3 Running *)
 JE @NoWindows
 CMP AL, 80h        ; (* If AL = 80h then XMS Driver present, no windows   *)
 JE @NoWindows
 MOV [TestOS], OSWindows  ; (* Windows enhanced mode is running            *)
 JMP @End                 ; (* Return From Function , we got all info      *)
@NoWindows:
(***********************************************)
(*     DESQVIEW/TOPVIEW INSTALLATION CHECK     *)
(***********************************************)
 MOV AH, 2Bh
 MOV CX, 4445h
 MOV DX, 5351h
 MOV AL, 01h
 INT Dos_Function
 CMP AL, 0FFh             ; (* If AL = FFh then Desqview is NOT loaded      *)
 JE @NoDV
 MOV [TestOS], OSDesqview
 JMP @End                 ; (* Return from Function, we got all info        *)
@NoDV:
(* Check For Topview                  *)
 MOV AX, 1022h
 MOV BX, 0000h
 INT 15h
 CMP BX, 0000h    ; (* If BX = 0000h then Topview or compatible is NOT loaded *)
 JE @NoTopview
 MOV [TestOS], OSDesqview
 JMP @End
@NoTopview:
(***********************************************)
(*      DOUBLEDOS   INSTALLATION CHECK         *)
(***********************************************)
 MOV AX, 0E400h
 INT DOS_Function
 CMP AL, 00h
 JE @NoDoubleDos
 MOV [TestOS], OsDoubleDos
 JMP @End
@NoDoubleDos:
(***********************************************)
(*      DPMI V1.0+  INSTALLATION CHECK         *)
(***********************************************)
 MOV AX, 1687h
 INT TSRInterrupt
 CMP AX, 0000h
 JNE @NoDPMI              ; (* If AX <> 0000 then NO DPMI Server           *)
 CMP DH, 01               ; (* We need version 1.0+ only                   *)
 JL @NoDPMI               ; (* Less then Version 1.00, we do not need      *)
 MOV [TestOS], OSDPMI           ; (* DOS Protected Mode Server present V1.0+     *)
 JMP @End
@NoDPMI:
(***********************************************)
(*      Concurrent  INSTALLATION CHECK         *)
(***********************************************)
  MOV AX, 4451h
  INT DOS_Function
  JC @NoConcurDOS
  CMP AH, 14h             ; (* Verify if we are truly using Multiuser version *)
  JNE @NoConcurDOS        ; (* This is not a Multi-User version           *)
  MOV [TestOS], OSCpmDOS        ; (* Return Concurrent DOS MultiUser            *)
  JMP @End
@NoConcurDOS:
(***********************************************)
(*          NORMAL DOS RUNNING                 *)
(***********************************************)
(* RUNNING NORMAL DOS *)
 MOV [TestOS], OSNone
@Continue2:
@End:
(***********************************************)
(*       DPMI SERVER INSTALLATION CHECK        *)
(***********************************************)
 MOV AX, 1687h            ; { Prepare Interrupt service routine   }
 INT 2Fh                  ; { Call MultiPlex Interrupt            }
 CMP AX, 0000h            ; { If AX = 0000h then DPMI installed   }
 JNE @@NoDPMI
 { Nil }                  ; { Version stored in DX                }
 MOV [TestDPMI], DX               ; { Put Result into AX (Function Result }
 JMP @@Continue2
@@NoDPMI:                  ; { No DPMI Installed                   }
 MOV [TestDPMI], 0000h            ; { Result of Function is zero          }
@@Continue2:
(***********************************************)
(*        EMS SERVER INSTALLATION CHECK        *)
(***********************************************)
end;
 If VerifyEMSPresent then
 BEGIN
  ASM
   MOV AH, 46h
   INT 67h
   CMP AH, 0000h
   JNE @EmsError
   MOV BH, AL                  ; { Make a copy of ther version number    }
   AND BH, $0F                 ; { Calculate minor EMS driver version    }
   MOV BYTE PTR [TestEMS], BH  ; { Put EMS Version # in TestEms          }
   AND AL, $F0                 ; { Calculate Major EMS version           }
   SHR AL, 1                   ; { Position the bits in the correct order }
   SHR AL, 1
   SHR AL, 1
   SHR AL, 1
   MOV BYTE PTR [TestEMS+1], AL
   JMP @End
 @EmsError:
   MOV [TestEMS], 0000h        ; { Returns Version of EMS = 000 on Error }
 @End:
  end;
 END
 ELSE
   TestEMS := $00;
(***********************************************)
(*        XMS SERVER INSTALLATION CHECK        *)
(***********************************************)
ASM
 MOV AX, 4300h            ; { Set up interrupt service routine }
 INT 2Fh
 CMP AL, 80h              ; { AL = 80h then XMS driver in mem  }
 JNE @@NoXMSDriver         ; { AL <> 80h , then no driver       }
 MOV AX, 4310h            ; { Get entry point of XMS driver    }
 INT 2Fh                  ; { ES:BX -> Entry point pointer     }
 MOV AX, ES
 MOV WORD PTR [XMSPointer+2], AX
 MOV WORD PTR [XMSPointer], BX
 MOV AH, 00h              ; { Set up Function Call XMS Version }
 CALL [XMSPointer]        ; { Call Entry point driver          }
 MOV [TestXMS], AX
 JMP @End3
@@NoXMSDriver:
 MOV [TestXMS], 0000h            ; { Function returns 0000, no driver }
 JMP @End3
@End3:
end;
{$ENDIF}
 If Lo(DOSVersion) < 3 then
 Begin
  WriteLn('ERROR: DOS 3.0+ Required.');
  Halt;
 end;
End.


{
  $Log: not supported by cvs2svn $
}