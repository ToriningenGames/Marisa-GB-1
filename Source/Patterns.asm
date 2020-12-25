;Patterns
;Fires danmaku repeatedly and prettily



;THIS WILL ALL CHANGE PRETTY SOON!!!
;IT IS WRITTEN LIKE THIS JUST FOR THE CUTSCENE! ALL SIGNATURES WILL CHANGE!!



.SECTION "Danmaku Patterns" FREE

;A: Pattern to fire
;DE: Position to fire at
PatternFire:
  RLCA
  ADD <_Patterns
  LD L,A
  LD A,>_Patterns
  ADC 0
  LD H,A
  LDI A,(HL)
  LD B,(HL)
  LD C,A
--
  LD A,(BC)   ;Wait period
  INC BC
-
  OR A
  JR z,+
  DEC A
  CALL HaltTask
  JR -
+   ;Wait over
  LD A,(BC)   ;Danmaku
  INC BC
  INC A ;End flag?
  JP z,EndTask
  DEC A
  PUSH BC
    LD BC,Danmaku_Entry
    CALL NewTask
  POP BC
  JR nc,--
  RET

_Patterns:
 .dw _Pat_Test
 .dw _Pat_Rei_Opts
 .dw _Pat_Test
 .dw _Pat_Test
 .dw _Pat_Ali_DollMyst

;Pattern format:
    ;for each entry:
        ;1 byte: wait
        ;1 byte: danmaku ID ($FF for end of data)
_Pat_Test:
 .db 0,0
 .db 0,$FF

_Pat_Rei_Opts:
 .db 0,1
 .db 0,$FF

_Pat_Ali_DollMyst:
 .db 0,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 21,4
 .db 0,$FF

.ENDS
