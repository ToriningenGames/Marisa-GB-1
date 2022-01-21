;Mushroom character file
;Mushrooms are basically tiny NPCs

.include "ActorData.asm"

.SECTION "Mushroom" FREE

MushroomActorData:
 .db $10
 .dw $0100
 .dw MushroomHitboxes
 .dw MushroomFrame
 .dw _HatValues
 .dw _Animations

MushroomFrame:
  XOR A
  RET

_LeftFace:
 .db 1
 .db -8,-4,$7D,%00000000  ;Shroom
_IdleLoop:
 .db $F1
 .db $FF
 .dw _IdleLoop

_DownFace:
 .db 1
 .db -8,-4,$7E,%00000000  ;Shroom
 .db $F1
 .db $FF
 .dw _IdleLoop

_RightFace:
 .db 1
 .db -9,-4,$7F,%00000000  ;Shroom
 .db $F1
 .db $FF
 .dw _IdleLoop

_Animations:
 .dw _LeftFace
 .dw _DownFace
 .dw _RightFace

_HatValues:

.ENDS
