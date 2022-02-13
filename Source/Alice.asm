;Alice character file

.include "ActorData.asm"

.SECTION "Alice" FREE

AliceActorData:
 .dw $0100
 .dw AliceHitboxes
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
_WalkDownLoop:
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
 .db $32
 .db %10010110  ;Left Leg lower
 .db %10011010  ;Right Arm lower
 .db $11
 .db $FF
 .dw _WalkDownLoop

_UpWalk:
 .db 6
 .db -12,-8,$0D,%00000000  ;Head left
 .db -12, 0,$0E,%00000000  ;Head right
 .db  -8,-8,$12,%00000000  ;Shoulder left
 .db  -8, 0,$12,%00100000  ;Shoulder right
 .db   0,-8,$1A,%00000000  ;Leg left
 .db   0, 0,$1A,%00100000  ;Leg right
_WalkUpLoop:
 .db $22
 .db %00110110  ;Left Arm raise
 .db %01011010  ;Right Leg raise
 .db $32
 .db %11110110  ;Left Arm lower
 .db %11011010  ;Right Leg lower
 .db $32
 .db %01010110  ;Left Leg raise
 .db %00111010  ;Right Arm raise
 .db $32
 .db %11010110  ;Left Leg lower
 .db %11111010  ;Right Arm lower
 .db $11
 .db $FF
 .dw _WalkUpLoop

_RightWalk:
 .db 3
 .db -11, 0,$0F,%00000000  ;Head
 .db  -8, 0,$13,%00000000  ;Shoulder
 .db   0, 0,$1D,%00000000  ;Leg
_WalkHortLoop:
 .db $11
 .db %00101110  ;Move legs
 .db $12
 .db %00100100  ;Lower head
 .db %00101000  ;Lower torso
 .db $21
 .db %11101110  ;Move legs
 .db %01001111
 .db $12
 .db %11100100  ;Raise head
 .db %11101000  ;Raise torso
 .db $11
 .db $FF
 .dw _WalkHortLoop

_LeftWalk:
 .db 3
 .db -11, 0,$0F,%00100000  ;Head
 .db  -8, 0,$13,%00100000  ;Shoulder
 .db   0, 0,$1D,%00100000  ;Leg
 .db $11
 .db $FF
 .dw _WalkHortLoop

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
