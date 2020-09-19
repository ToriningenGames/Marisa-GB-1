;Alice character file

.include "ActorData.asm"

.SECTION "Alice" FREE

AliceFrame:
  CALL Actor_New    ;Null actor (w/visibility)
  ;Hitbox setup
  LD HL,_Hitbox
  ADD HL,DE
  LD (HL),<DefaultHitboxes
  INC HL
  LD (HL),>DefaultHitboxes
  ;Animation values
  LD HL,_AnimChange
  ADD HL,DE
  LD (HL),1 ;Face down
  CALL HaltTask
  LD HL,_LandingPad
  ADD HL,DE
  ;Check for doing AI stuffs here
;Alice specific messages
    ;x: Cutscene control
    ;t: Play animation
    ;x: Destruct
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
  SWAP A
  ADD 4     ;Alice Hat constant
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
  ;Carry correct b/c CMP against $FF
  JP Actor_Draw

_DownFace:
 .db 6
 .db -11,-8,$0B,%00000000  ;Head left
 .db -11, 0,$0C,%00000000  ;Head right
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
 .db -11,-8,$0D,%00000000  ;Head left
 .db -11, 0,$0E,%00000000  ;Head right
 .db  -8,-8,$12,%00000000  ;Shoulder left
 .db  -8, 0,$12,%00100000  ;Shoulder right
 .db   0,-8,$1A,%00000000  ;Leg left
 .db   0, 0,$1A,%00100000  ;Leg right
 .db $F1
 .db $FF
 .dw _IdleLoop

_RightFace:
 .db 6
 .db -11, 0,$0F,%00000000  ;Head
 .db  -8, 0,$13,%00000000  ;Shoulder
 .db   0, 0,$1D,%00000000  ;Leg
 .db -36, 0,$03,%00000000  ;Unused
 .db -28, 0,$03,%00000000  ;Unused
 .db -20, 0,$03,%00000000  ;Unused
 .db $F1
 .db $FF
 .dw _IdleLoop

_LeftFace:
 .db 6
 .db -11, 0,$0F,%00100000  ;Head
 .db  -8, 0,$13,%00100000  ;Shoulder
 .db   0, 0,$1D,%00100000  ;Leg
 .db -36, 0,$03,%00000000  ;Unused
 .db -28, 0,$03,%00000000  ;Unused
 .db -20, 0,$03,%00000000  ;Unused
 .db $F1
 .db $FF
 .dw _IdleLoop

_Animations:
 .dw _LeftFace
 .dw _DownFace
 .dw _RightFace
 .dw _UpFace
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace

.ENDS
