;Mushroom character file
;Mushrooms are basically tiny NPCs

.include "ActorData.asm"

.SECTION "Mushroom" FREE

MushroomActorData:
 .dw 0
 .dw %010
 .dw MushroomFrame
 .dw _HatValues
 .dw _Animations

MushroomFrame:
  XOR A
  RET

_Animations:
 .dw MushroomLeft
 .dw MushroomDown
 .dw MushroomRight
 .dw MushroomUp

_HatValues:

.ENDS
