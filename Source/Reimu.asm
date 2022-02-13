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

_DownFace:
 .db 4
 .db -16,-4,$20,%00000000  ;Head ribbon
 .db  -8,-4,$23,%00000000  ;Head
 .db  -0,-8,$25,%00000000  ;Waist left
 .db  -0, 0,$25,%00100000  ;Waist right
_IdleLoop:
 .db $F1
 .db $FF
 .dw _IdleLoop

_UpFace:
 .db 4
 .db -16,-4,$1F,%00000000  ;Head ribbon
 .db  -8,-4,$22,%00000000  ;Head
 .db  -0,-8,$2A,%00000000  ;Waist left
 .db  -0, 0,$2A,%00100000  ;Waist right
 .db $F1
 .db $FF
 .dw _IdleLoop

_LeftFace:
 .db 4
 .db -16,-4,$21,%00100000  ;Head ribbon
 .db  -8,-4,$24,%00100000  ;Head
 .db  -0,-8,$2D,%00000000  ;Waist left
 .db  -0, 0,$2D,%00100000  ;Waist right
 .db $F1
 .db $FF
 .dw _IdleLoop

_LeftWalk:
 .db 4
 .db -16,-4,$21,%00100000  ;Head ribbon
 .db  -8,-4,$24,%00100000  ;Head
 .db  -0,-8,$2F,%00000000  ;Waist left
 .db  -0, 0,$30,%00000000  ;Waist right
 .db $F1
 .db $FF
 .dw _IdleLoop

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
