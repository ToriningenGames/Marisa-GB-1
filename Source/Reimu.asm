;Reimu character file

.include "ActorData.asm"

.SECTION "Reimu" FREE

ReimuFrame:
  CALL Actor_New    ;Null actor (w/visibility)
  ;Hitbox setup
  LD HL,_Hitbox
  ADD HL,DE
  LD (HL),<DefaultHitboxes
  INC HL
  LD (HL),>DefaultHitboxes
  ;Animation values
  LD HL,_HatVal
  ADD HL,DE
  LD (HL),3
  LD BC,_DownFace
  CALL HaltTask
  ;Face new direction
  PUSH DE
    SCF
    CALL Actor_Draw
  POP DE
  CALL HaltTask
  CALL Actor_Message
  JR c,+
;Reimu specific messages
    ;x: Cutscene control
    ;x: Play animation
    ;x: Destruct
+
  OR A  ;Clear carry
  JP Actor_Draw

_DownFace:
 .db -10,-9,$69,%00100000  ;Head left
 .db -10,-1,$68,%00100000  ;Head right
 .db  -8,-7,$6B,%00000000  ;Shoulder left
 .db  -8, 0,$6B,%00100000  ;Shoulder right
 .db   0,-7,$6E,%00000000  ;Leg left
 .db   0, 0,$6E,%00100000  ;Leg right
_IdleLoop:
 .db $F1
 .db $FF
 .dw _IdleLoop

.ENDS
