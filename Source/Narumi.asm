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

_DownFace:
 .db 4
 .db -12, -8,$31,%00000000  ;Head left
 .db -12,  0,$32,%00000000  ;Head right
 .db  -4, -8,$39,%00000000  ;Body left
 .db  -4,  0,$3A,%00000000  ;Body right
_Idle:
 .db $F1
 .db $FF
 .dw _Idle

_UpFace:
 .db 4
 .db -12, -8,$33,%00000000  ;Head left
 .db -12,  0,$34,%00000000  ;Head right
 .db  -4, -8,$3B,%00000000  ;Body left
 .db  -4,  0,$39,%00100000  ;Body right
 .db $F1
 .db $FF
 .dw _Idle

_LeftFace:
 .db 4
 .db -12, -8,$37,%00000000  ;Head left
 .db -12,  0,$38,%00000000  ;Head right
 .db  -4, -8,$3E,%00000000  ;Body left
 .db  -4,  0,$3F,%00000000  ;Body right
 .db $F1
 .db $FF
 .dw _Idle

_RightFace:
 .db 4
 .db -12, -8,$35,%00000000  ;Head left
 .db -12,  0,$36,%00000000  ;Head right
 .db  -4, -8,$3C,%00000000  ;Body left
 .db  -4,  0,$3D,%00000000  ;Body right
 .db $F1
 .db $FF
 .dw _Idle

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
