;Narumi Character file
;She just kinda... sits there.
;And spits danmaku. Lots of it.


.SECTION "Narumi" FREE

;Memory format:
.INCLUDE "ActorData.asm"

NarumiFrame:
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
;Narumi specific messages
    ;x: Cutscene control
    ;v: Play animation
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
  ADD 3     ;Narumi Hat constant
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
 .db -12, -8,$31,%00000000  ;Head left
 .db -12,  0,$32,%00000000  ;Head right
 .db  -4, -8,$39,%00000000  ;Body left
 .db  -4,  0,$3A,%00000000  ;Body right
 .db -91, 00,$03,%00000000  ;Unused
 .db -99, 20,$03,%00000000  ;Unused
_Idle:
 .db $F1
 .db $FF
 .dw _Idle

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
