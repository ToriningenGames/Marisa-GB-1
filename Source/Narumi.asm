;Narumi Character file
;She just kinda... sits there.
;And spits danmaku. Lots of it.

.include "ActorData.asm"

.SECTION "Narumi" FREE

NarumiActorData:
 .dw 0
 .db %011
 .db $03
 .dw NarumiFrame
 .dw _HatValues
 .dw _Animations

_shoot7:
  CP (HL)
  LD A,7
  JR +
_shoot8:
  CP (HL)
  LD A,8
  JR +
_shoot9:
  CP (HL)
  LD A,9
+
  PUSH HL
    CALL z,NewTask
  POP HL
  RET
  
NarumiFrame:
;Init
  LD HL,_ShootTimer
  ADD HL,DE
  LDI A,(HL)
  OR (HL)
  JR nz,+
  LD (HL),2+5+7+3-1
  DEC HL
  LD (HL),60
  ;Narumi should start out disabled
  LD HL,_ControlState
  ADD HL,DE
  XOR A
  LD (HL),A
  RET
+
;Every shot will use Narumi's current position
  PUSH DE
    LD HL,_MasterX+1
    ADD HL,DE
    LDI A,(HL)
    SUB 8
    INC HL
    LD C,(HL)
    LD HL,_ShootTimer
    ADD HL,DE
    LD D,A
    LD A,C
    SUB 8
    LD E,A
    LD BC,NewDanmaku
    DEC (HL)
    JR nz,+
    LD (HL),60
    INC HL
    DEC (HL)
    DEC HL
+
    INC HL
    LD A,2+5
    CP (HL)
    JR nc,+
    ;Stage 1, 2
    ;Fire out A
    ;Rate: 30 frames
    DEC HL
    ;Fire if (HL) is 30 or 0
    LD A,30
    CALL _shoot7
    XOR A
    CALL _shoot7
    INC HL
+
    LD A,2+5+7
    CP (HL)
    JR c,+
    LD A,2
    CP (HL)
    JR nc,+
    ;Stage 2, 3
    ;Fire out B
    ;B Rate: 40 frames
    ;Fire if (HL) is 40, 0, or 20+256
    LD A,1
    AND (HL)
    DEC HL
    JR nz,++
    LD A,40
    CALL _shoot8
    XOR A
    CALL _shoot8
    JR +++
++
    LD A,20
    CALL _shoot8
+++
    INC HL
+
    LD A,2+5
    CP (HL)
    JR c,+
    LD A,2
    CP (HL)
    JR nc,+
    ;Stage 3
    ;Fire out B
    ;Rate: 20 frames, actually
    ;Fire if (HL) is 40, 0, or 20
    LD A,1
    AND (HL)
    DEC HL
    JR z,++
    LD A,40
    CALL _shoot9
    XOR A
    CALL _shoot9
    JR +++
++
    LD A,20
    CALL _shoot9
+++
    INC HL
+
    ;Stage 4
    ;Not much
    XOR A
    CP (HL)
    JR nz,+
    ;One last shot at the end
    CALL NewTask
    LD BC,Cutscene_Task
    LD DE,Cs_NarumiFightEnd
    CALL NewTask
+
  POP DE
  XOR A
  RET

_Animations:
 .dw NarumiLeft
 .dw NarumiDown
 .dw NarumiRight
 .dw NarumiUp

_HatValues:
 .db 3
 .db 19
 .db 35
 .db 51

.ENDS
