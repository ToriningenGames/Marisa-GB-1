;Narumi Character file
;She just kinda... sits there.
;And spits danmaku. Lots of it.


.SECTION "Narumi" FREE

;Memory format:
.INCLUDE "ActorData.asm"

NarumiFrame:
;Setup
  CALL Actor_New
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
  CALL HaltTask  ;Let rest of world catch up to our existence
  ;Face new direction
  PUSH DE
    SCF
    CALL Actor_Draw
  POP DE
  CALL HaltTask
;Frame actions
  CALL Actor_Message
  JR c,+
  ;Narumi specific messages
    ;x: Cutscene control
    ;x: Play animation
    ;x: Destruct
+
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

.ENDS
