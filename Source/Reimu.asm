;Reimu character file

.include "ActorData.asm"

.SECTION "Reimu" FREE

ReimuActorData:
 .dw $0100
 .dw ReimuHitboxes
 .dw ReimuFrame
 .dw _HatValues
 .dw _Animations

ReimuFrame:
  XOR A
  RET

_Animations:
 .dw ReimuLeft
 .dw ReimuDown
 .dw ReimuRight
 .dw ReimuUp

_HatValues:
 .db 5
 .db 21
 .db 37
 .db 53

.ENDS
