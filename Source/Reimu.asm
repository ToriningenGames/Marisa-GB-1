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
  SWAP A
  ADD 5     ;Reimu Hat constant
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
 .db -10,-9,$69,%00100000  ;Head ribbon
 .db -10,-1,$68,%00100000  ;Head
 .db  -8,-7,$6B,%00000000  ;Waist left
 .db  -8, 0,$6B,%00100000  ;Waist right
 .db -90,-7,$03,%00000000  ;Unused
 .db -99, 0,$03,%00100000  ;Unused
_IdleLoop:
 .db $F1
 .db $FF
 .dw _IdleLoop

_Animations:
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace
 .dw _DownFace
.ENDS
