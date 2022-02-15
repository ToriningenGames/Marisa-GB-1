;Narumi Character file
;She just kinda... sits there.
;And spits danmaku. Lots of it.

.include "ActorData.asm"

.SECTION "Narumi" FREE

NarumiActorData:
 .dw 0
 .dw NarumiHitboxes
 .dw NarumiFrame
 .dw _HatValues
 .dw _Animations

NarumiFrame:
  XOR A
  RET

_Animations:
 .dw NarumiLeft
 .dw NarumiDown
 .dw NarumiRight
 .dw NarumiUp

_HatValues:
 .db 3
 .db 19
 .db 35
 .db 51

.ENDS
