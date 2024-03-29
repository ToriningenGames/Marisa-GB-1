;Mushroom character file
;Mushrooms are basically tiny NPCs

.include "ActorData.asm"

.SECTION "Mushroom" FREE

MushroomActorData:
 .dw 0
 .db %010
 .db $00
 .dw MushroomFrame
 .dw _HatValues
 .dw _Animations

MushroomFrame:
  LD BC,Cs_MushroomCollect
  CALL HitboxInteractAdd
  XOR A
  RET

_Animations:
 .dw MushroomLeft
 .dw MushroomDown
 .dw MushroomRight
 .dw MushroomUp

_HatValues:
.db 6,6,6,6

.ENDS
