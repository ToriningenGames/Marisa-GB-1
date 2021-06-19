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
  LD HL,_ControlState
  ADD HL,DE
  ;Check for doing AI stuffs here
;Narumi specific messages
    ;v: Cutscene control
    ;v: Play animation
    ;v: Destruct
  ;Cutscene detect
  LD HL,_ControlState
  ADD HL,DE
  LD A,(HL)
  INC A
  JP z,Actor_Delete
  DEC A
  AND $7F
  JR z,+    ;Cutscene control
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
 .db 4
 .db -12, -8,$31,%00000000  ;Head left
 .db -12,  0,$32,%00000000  ;Head right
 .db  -4, -8,$39,%00000000  ;Body left
 .db  -4,  0,$3A,%00000000  ;Body right
_Idle:
 .db $F1
 .db $FF
 .dw _Idle

_UpFace:
 .db 4
 .db -12, -8,$33,%00000000  ;Head left
 .db -12,  0,$34,%00000000  ;Head right
 .db  -4, -8,$3B,%00000000  ;Body left
 .db  -4,  0,$39,%00100000  ;Body right
 .db $F1
 .db $FF
 .dw _Idle

_LeftFace:
 .db 4
 .db -12, -8,$37,%00000000  ;Head left
 .db -12,  0,$38,%00000000  ;Head right
 .db  -4, -8,$3E,%00000000  ;Body left
 .db  -4,  0,$3F,%00000000  ;Body right
 .db $F1
 .db $FF
 .dw _Idle

_RightFace:
 .db 4
 .db -12, -8,$35,%00000000  ;Head left
 .db -12,  0,$36,%00000000  ;Head right
 .db  -4, -8,$3C,%00000000  ;Body left
 .db  -4,  0,$3D,%00000000  ;Body right
 .db $F1
 .db $FF
 .dw _Idle

_Animations:
 .dw _LeftFace
 .dw _DownFace
 .dw _RightFace
 .dw _UpFace
 .dw _LeftFace
 .dw _DownFace
 .dw _RightFace
 .dw _UpFace

_HatValues:
 .db 3
 .db 19
 .db 35
 .db 51

.ENDS
