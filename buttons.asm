;Button subsystem
;Designed to accomodate reading buttons in a manner that makes menus navigatable (things like repeat delay, repeating at a rate less than 60 times/sec, consistently defined for multiple button presses, etc.)
;Actual button reading for each frame is accomplished in vBlank, to allow stable timing for it.
;This is only intended for things e.g. menus that require reasonable delays between button actions

.IFNDEF BUTTONS
.DEFINE BUTTONS 1

;These defines allow one to change the location of the project for their needs,
;but it is required to have the low byte of BUTTMEMBASE be below $F0.
;BUTTLOC is forced to page $FF
.DEFINE BUTTLOC $FE     ;Page $FF
.DEFINE BUTTMEMBASE $C040
.DEFINE BUTTMEMBASELO (<BUTTMEMBASE)
.DEFINE BUTTMEMBASEHI (>BUTTMEMBASE)


;Memory map:
    ;+$00: Button states
        ;  Down  remaining delay
        ;   Up   remaining delay
        ;  Left  remaining delay
        ; Right  remaining delay
        ; Start  remaining delay
        ; Select remaining delay
        ;   B    remaining delay
        ;   A    remaining delay
    ;+$08: Frame pointer
    ;+$0A: Repeat rate
    ;+$0B: Repeat delay
    ;+$0C: Function list pointer

;Call ButtonDo each frame for update and button signals
;Call ButtonInit to reset state to a button-free fast repeat default
;Output
    ;A = Button signals
        ;DULRSEBA
        ;|||||||+--- A button
        ;||||||+---- B button
        ;|||||+----- Select button
        ;||||+------ Start button
        ;|||+------- Right direction
        ;||+-------- Left direction
        ;|+--------- Up direction
        ;+---------- Down direction

ButtonNew:
    ;Args:
        ;B= Initial delay after first press
        ;C= Future delays
        ;HL=Eight pointers to what to do on each button press
    ;Return: Nothing
    ;Button response functions:
        ;Args:
            ;HL=exit
        ;Return:
            ;HL=preserve
        ;To exit:
            ;Jump to HL
  LD D,H
  LD E,L
  LD HL,BUTTMEMBASE+$0D
  LD (HL),D
  DEC L
  LD (HL),E
  DEC L
  LD (HL),B
  DEC L
  LD (HL),C
  DEC L
  DEC L
  DEC L
  LD A,$0A
  LD B,$08
-
  LDD (HL),A
  DEC B
  JR nz,-
ButtonTest:
  LDH A,($FE)
ButtonDo:
  LD (BUTTMEMBASE+$08),SP
  LD HL,++
  PUSH HL
  LD HL,(BUTTMEMBASE+$0C)
  LDI A,(HL)
  LD H,(HL)
  LD L,A
-
  SLA B
  JR nc,+
  LDI A,(HL)    ;Do this routine
  LD E,A
  LD D,(HL)
  PUSH DE
  DEC HL
+
  INC HL        ;Do not this routine
  INC HL
  JR nz,-
  LD HL,++
  RET   ;Begin the button routines
++
  DI
  LD SP,BUTTMEMBASE+$08
  POP HL    ;Restore the stack
  LD SP,HL
  RETI

.ENDIF

.ENDASM
ButtonInit:
  PUSH BC
  LD HL,BUTTMEMBASE+$09
  XOR A
  INC A
  LD C,$09
-
  LDD (HL),A
  DEC C
  JR nz,-
  INC L
  JR +++
ButtonDo:
  PUSH BC
  LD HL,BUTTMEMBASE
+++
  PUSH DE
  LDH A,(BUTTLOC)
  OR A      ;4      1
-
  RLA       ;4      1
  JR nc,+   ;8/12   2
  INC (HL)  ;12     1
  JR ++     ;12     2
+
  LD (HL),0 ;12     2
++
  INC L     ;4      1
  OR A      ;4      1
  JR nz,-   ;8/12   2
  LD L,BUTTMEMBASELO+$09
  LD B,(HL)
  DEC L
  LD C,(HL)
  DEC L
  LD E,$00
-
  LD A,L
  CP BUTTMEMBASELO-1
  JR z,++
  LDD A,(HL)
  CP $01
  JR nz,+
  SCF
  RL E
  JR -
+
  SUB B
--
  SUB C
  JR nz,+
  SCF
  RL E
  JR -
+
  JR nc,--
  CCF
  RL E
  JR -
++
  LD A,E
  POP DE
  POP BC
  RET
.ASM

