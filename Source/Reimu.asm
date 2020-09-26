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
  LD HL,_AnimChange
  ADD HL,DE
  LD (HL),1 ;Face down
  CALL HaltTask
  LD HL,_LandingPad
  ADD HL,DE
  ;Check for doing AI stuffs here
;Reimu specific messages
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
  ;Carry correct b/c CMP against $FF
  JP Actor_Draw

_DownFace:
 .db 4
 .db -16,-4,$20,%00000000  ;Head ribbon
 .db  -8,-4,$23,%00000000  ;Head
 .db  -0,-8,$25,%00000000  ;Waist left
 .db  -0, 0,$25,%00100000  ;Waist right
_IdleLoop:
 .db $F1
 .db $FF
 .dw _IdleLoop

_UpFace:
 .db 4
 .db -16,-4,$1F,%00000000  ;Head ribbon
 .db  -8,-4,$22,%00000000  ;Head
 .db  -0,-8,$2A,%00100000  ;Waist left
 .db  -0, 0,$2A,%00000000  ;Waist right
 .db $F1
 .db $FF
 .dw _IdleLoop

_LeftFace:
 .db 4
 .db -16,-4,$21,%00100000  ;Head ribbon
 .db  -8,-4,$24,%00100000  ;Head
 .db  -0,-8,$2D,%00100000  ;Waist left
 .db  -0, 0,$2D,%00000000  ;Waist right
 .db $F1
 .db $FF
 .dw _IdleLoop

_RightFace:
 .db 4
 .db -16,-4,$21,%00000000  ;Head ribbon
 .db  -8,-4,$24,%00000000  ;Head
 .db  -0,-8,$2D,%00000000  ;Waist left
 .db  -0, 0,$2D,%00100000  ;Waist right
 .db $F1
 .db $FF
 .dw _IdleLoop

_Animations:
 .dw _LeftFace
 .dw _DownFace
 .dw _RightFace
 .dw _UpFace

_HatValues:
 .db 5
 .db 21
 .db 37
 .db 53

.ENDS
