;Alice character file

.include "ActorData.asm"

.SECTION "Alice" FREE

AliceActorData:
 .db $10
 .dw $0100
 .dw NPCHitboxes
 .dw AliceFrame
 .dw _HatValues
 .dw _Animations

AliceFrame:
  XOR A
  RET

_DownFace:
 .db 6
 .db -12,-8,$0B,%00000000  ;Head left
 .db -12, 0,$0C,%00000000  ;Head right
 .db  -8,-8,$10,%00000000  ;Shoulder left
 .db  -8, 0,$11,%00000000  ;Shoulder right
 .db   0,-8,$14,%00000000  ;Leg left
 .db   0, 0,$15,%00000000  ;Leg right
_IdleLoop:
 .db $F1
 .db $FF
 .dw _IdleLoop

_UpFace:
 .db 6
 .db -12,-8,$0D,%00000000  ;Head left
 .db -12, 0,$0E,%00000000  ;Head right
 .db  -8,-8,$12,%00000000  ;Shoulder left
 .db  -8, 0,$12,%00100000  ;Shoulder right
 .db   0,-8,$1A,%00000000  ;Leg left
 .db   0, 0,$1A,%00100000  ;Leg right
 .db $F1
 .db $FF
 .dw _IdleLoop

_RightFace:
 .db 3
 .db -11, 0,$0F,%00000000  ;Head
 .db  -8, 0,$13,%00000000  ;Shoulder
 .db   0, 0,$1D,%00000000  ;Leg
 .db $F1
 .db $FF
 .dw _IdleLoop

_LeftFace:
 .db 3
 .db -11, 0,$0F,%00100000  ;Head
 .db  -8, 0,$13,%00100000  ;Shoulder
 .db   0, 0,$1D,%00100000  ;Leg
 .db $F1
 .db $FF
 .dw _IdleLoop

_DownWalk:
 .db 6
 .db -12,-8,$0B,%00000000  ;Head left
 .db -12, 0,$0C,%00000000  ;Head right
 .db  -8,-8,$10,%00000000  ;Shoulder left
 .db  -8, 0,$11,%00000000  ;Shoulder right
 .db   0,-8,$14,%00000000  ;Leg left
 .db   0, 0,$15,%00000000  ;Leg right
_WalkLoop:
 .db $22
 .db %01010110  ;Left Arm raise
 .db %01011010  ;Right Leg raise
 .db $32
 .db %11010110  ;Left Arm lower
 .db %11011010  ;Right Leg lower
 .db $34
 .db %01010110  ;Left Leg raise
 .db %01010110
 .db %01011010  ;Right Arm raise
 .db %01011010
 .db $35
 .db %10010110  ;Left Leg lower
 .db %10011010  ;Right Arm lower
 .db $11
 .db $FF
 .dw _WalkLoop

_Animations:
 .dw _LeftFace
 .dw _DownFace
 .dw _RightFace
 .dw _UpFace
 .dw _LeftFace
 .dw _DownWalk
 .dw _RightFace
 .dw _UpFace

_HatValues:
 .db 4
 .db 20
 .db 36
 .db 52

.ENDS
