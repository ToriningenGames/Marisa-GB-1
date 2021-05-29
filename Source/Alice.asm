;Alice character file

.include "ActorData.asm"

.SECTION "Alice" FREE

AliceFrame:
  CALL Actor_New    ;Null actor (w/visibility)
  ;Hitbox setup
  LD HL,_Hitbox
  ADD HL,DE
  LD (HL),<NPCHitboxes
  INC HL
  LD (HL),>NPCHitboxes
  ;Animation values
  LD HL,_AnimChange
  ADD HL,DE
  LD (HL),1 ;Face down
  CALL HaltTask
  LD HL,_ControlState
  ADD HL,DE
  ;Check for doing AI stuffs here
;Alice specific messages
    ;v: Cutscene control
    ;v: Play animation
    ;v: Destruct
  ;Cutscene detect
  LD HL,_ControlState
  ADD HL,DE
  LD A,(HL)
  OR A
  JR z,+
  INC A
  JP z,Actor_Delete
;AI behavior here
+
  ;Animation check
  LD A,$FF
  LD HL,_AnimChange
  ADD HL,DE
  CP (HL)
  JR z,+
  ;Change animation
  LD C,(HL)
  LD (HL),A
  ;Change HatVal
  LD A,$03
  AND C
  ADD <_HatValues
  LD L,A
  LD A,<_HatValues
  ADC 0
  LD H,A
  LD A,(HL)
  LD HL,_HatVal
  ADD HL,DE
  LD (HL),A
  ;Send new anim pointer
  LD A,C
  RLA
  ADD <_Animations
  LD L,A
  LD A,>_Animations
  ADC 0
  LD H,A
  LDI A,(HL)
  LD B,(HL)
  LD C,A
  SCF   ;New animation
+
  ;Carry correct b/c CMP against $FF always yields no carry
  JP Actor_Draw

_DownFace:
 .db 6
 .db -12,-8,$0B,%00000000  ;Head left
 .db -12, 0,$0C,%00000000  ;Head right
 .db  -8,-8,$10,%00000000  ;Shoulder left
 .db  -8, 0,$11,%00000000  ;Shoulder right
 .db   0,-8,$14,%00000000  ;Leg left
 .db   0, 0,$15,%00000000  ;Leg right
_IdleLoop:
 .db $F1
 .db $FF
 .dw _IdleLoop

_UpFace:
 .db 6
 .db -12,-8,$0D,%00000000  ;Head left
 .db -12, 0,$0E,%00000000  ;Head right
 .db  -8,-8,$12,%00000000  ;Shoulder left
 .db  -8, 0,$12,%00100000  ;Shoulder right
 .db   0,-8,$1A,%00000000  ;Leg left
 .db   0, 0,$1A,%00100000  ;Leg right
 .db $F1
 .db $FF
 .dw _IdleLoop

_RightFace:
 .db 3
 .db -11, 0,$0F,%00000000  ;Head
 .db  -8, 0,$13,%00000000  ;Shoulder
 .db   0, 0,$1D,%00000000  ;Leg
 .db $F1
 .db $FF
 .dw _IdleLoop

_LeftFace:
 .db 3
 .db -11, 0,$0F,%00100000  ;Head
 .db  -8, 0,$13,%00100000  ;Shoulder
 .db   0, 0,$1D,%00100000  ;Leg
 .db $F1
 .db $FF
 .dw _IdleLoop

_DownWalk:
 .db 6
 .db -12,-8,$0B,%00000000  ;Head left
 .db -12, 0,$0C,%00000000  ;Head right
 .db  -8,-8,$10,%00000000  ;Shoulder left
 .db  -8, 0,$11,%00000000  ;Shoulder right
 .db   0,-8,$14,%00000000  ;Leg left
 .db   0, 0,$15,%00000000  ;Leg right
_WalkLoop:
 .db $22
 .db %01010110  ;Left Arm raise
 .db %01011010  ;Right Leg raise
 .db $32
 .db %11010110  ;Left Arm lower
 .db %11011010  ;Right Leg lower
 .db $34
 .db %01010110  ;Left Leg raise
 .db %01010110
 .db %01011010  ;Right Arm raise
 .db %01011010
 .db $35
 .db %10010110  ;Left Leg lower
 .db %10011010  ;Right Arm lower
 .db $11
 .db $FF
 .dw _WalkLoop

_Animations:
 .dw _LeftFace
 .dw _DownFace
 .dw _RightFace
 .dw _UpFace
 .dw _LeftFace
 .dw _DownWalk
 .dw _RightFace
 .dw _UpFace

_HatValues:
 .db 4
 .db 20
 .db 36
 .db 52

.ENDS
