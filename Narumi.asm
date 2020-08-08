;Narumi Character file
;She just kinda... sits there.
;And spits danmaku. Lots of it.


.SECTION "Narumi" FREE

;Memory format:
.INCLUDE "ActorData.asm"

NarumiFrame:
;Setup
  CALL Actor_New
  LD HL,_Hitbox
  ADD HL,DE
  LD (HL),<DefaultHitboxes
  INC HL
  LD (HL),>DefaultHitboxes
  LD HL,_HatVal
  ADD HL,DE
  LD (HL),3
  CALL HaltTask
;Initial facing
  LD BC,_DownFace
  PUSH DE
  SCF
  CALL Actor_Draw
  POP DE
  CALL HaltTask
  CALL Actor_Draw
  ;Permanent, no action: it's okay to drop this task
  ;But we want to test how well the GB does under this load
  ;Result: Sprite appearances get even worse, since the drawing task
    ;might miss the frame it gets screen time
    ;And, the object manager gets fewer frames, too, increasing base flickering
  ;Minimal load:
    ;Something's fishy with the manager. It doesn't dole out equally.
    ;Fix'd
    ;Removed separate draw task so too many things can go on screen
  RET

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
