
.DEFINE LCDIRQVec $C030
.EXPORT LCDIRQVec

.SECTION "LCD IRQ Help" FREE

LCDIRQSetupTask:
  LD B,H
  LD C,L
;Check for availability
-
  LD HL,LCDIRQVec
  LDI A,(HL)
  OR (HL)
  CALL z,HaltTask
  OR A
  JR z,-
  LD (HL),B
  DEC L
  LD (HL),C
  LD HL,LCDCounter
  LD A,D
  OR (HL)
  LD (HL),A
  LD L,<LY
  LD (HL),E
  

.ENDS
