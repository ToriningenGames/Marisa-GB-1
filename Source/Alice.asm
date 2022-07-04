;Alice character file

.include "ActorData.asm"

.SECTION "Alice" FREE

AliceActorData:
 .dw $0100
 .db %011
 .db $01
 .dw AliceFrame
 .dw _HatValues
 .dw _Animations

AliceFrame:
  XOR A
  RET

_Animations:
 .dw AliceLeft
 .dw AliceDown
 .dw AliceRight
 .dw AliceUp

_HatValues:
 .db 4
 .db 20
 .db 36
 .db 52

.ENDS
