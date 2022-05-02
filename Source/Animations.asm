.MACRO SpriteHeader ARGS count,start,priority
.DB (priority*8)|(count)|(start*2)
.ENDM
.MACRO SpriteItem ARGS yoffs,xoffs,tileoffs,attr
.IF yoffs == 8 && xoffs == 8
.DB $FF
.ELIF yoffs == 8
.DB $F0|(xoffs & $F)
.ELIF xoffs == 8
.DB ((yoffs & $F)*16)|$F
.ELSE
.DB ((yoffs & $F)*16)|(xoffs & $F)
.ENDIF
.DB (attr*32)|(tileoffs & $1F)
.ENDM
.MACRO SpriteAnimItem ARGS yoffs,xoffs,tileoffs,xflip
.IF     yoffs < 0
    .IF     xoffs < 0
  .db %01010000 | ((xflip&1)<<3) | (tileoffs&7)
    .ELIF   xoffs > 0
  .db %01100000 | ((xflip&1)<<3) | (tileoffs&7)
    .ELSE
  .db %01000000 | ((xflip&1)<<3) | (tileoffs&7)
    .ENDIF
.ELIF   yoffs > 0
    .IF     xoffs < 0
  .db %10010000 | ((xflip&1)<<3) | (tileoffs&7)
    .ELIF   xoffs > 0
  .db %10100000 | ((xflip&1)<<3) | (tileoffs&7)
    .ELSE
  .db %10000000 | ((xflip&1)<<3) | (tileoffs&7)
    .ENDIF
.ELSE
    .IF     xoffs < 0
  .db %00010000 | ((xflip&1)<<3) | (tileoffs&7)
    .ELIF   xoffs > 0
  .db %00100000 | ((xflip&1)<<3) | (tileoffs&7)
    .ELSE
  .db %00000000 | ((xflip&1)<<3) | (tileoffs&7)
    .ENDIF
.ENDIF
.ENDM

.SECTION "Animations" FREE

MarisaLeft:
  SpriteHeader 4,$40,0
  SpriteItem +2,+0, $8, %010    ;Leg right
  SpriteItem +0,-8, $9, %010    ;Leg left
  SpriteItem -8,+3, $D, %000    ;Shoulder
  SpriteItem -2,+1, $1, %010    ;Head
 .dw MarisaWalkLeft
MarisaDown:
  SpriteHeader 6,$40,0
  SpriteItem +2,+0, $2, %010    ;Leg right
  SpriteItem +0,-7, $2, %000    ;Leg left
  SpriteItem -8,+7,-$1, %010    ;Shoulder right
  SpriteItem +0,-7,-$1, %000    ;Shoulder left
  SpriteItem -2,+6,-$4, %010    ;Head right
  SpriteItem +0,-8,-$3, %010    ;Head left
 .dw MarisaWalkDown
MarisaRight:
  SpriteHeader 4,$40,0
  SpriteItem +2,+0, $9, %000    ;Leg right
  SpriteItem +0,-8, $8, %000    ;Leg left
  SpriteItem -8,+3, $D, %000    ;Shoulder
  SpriteItem -2,+1, $C, %010    ;Head
 .dw MarisaWalkRight
MarisaUp:
  SpriteHeader 6,$40,0
  SpriteItem +2,+0, $3, %000    ;Leg right
  SpriteItem +0,-7, $3, %010    ;Leg left
  SpriteItem -8,+7, $0, %000    ;Shoulder right
  SpriteItem +0,-7, $0, %010    ;Shoulder left
  SpriteItem -2,+0,-$2, %010    ;Head left
  SpriteItem +0,+8,-$3, %000    ;Head right
 .dw MarisaWalkUp

MarisaWalkRight:
MarisaWalkLeft:
 .db %00001100  ;Arm back
  SpriteAnimItem +0,+0,-$2, %000
  SpriteAnimItem +0,+0,-$2, %000
 .db 0
 .db %00111111  ;Arm neutral, all 1px down
  SpriteAnimItem +1,+0,+$0, %000
  SpriteAnimItem +1,+0,+$0, %000
  SpriteAnimItem +1,+0,+$2, %000
  SpriteAnimItem +1,+0,+$2, %000
  SpriteAnimItem +1,+0,+$0, %000
  SpriteAnimItem +1,+0,+$0, %000
 .db %00001100  ;Arm forward
  SpriteAnimItem +0,+0,+$2, %000
  SpriteAnimItem +0,+0,+$2, %000
 .db 0
 .db $FF    ;(Implied) Arm neutral, all 1px up
MarisaWalkDown:
MarisaWalkUp:
 .db %00010000        ;Left arm forward , no xy
  SpriteAnimItem +0,+0,+$2, %000
 .db 0
 .db %00111111        ;Left arm back    , all 1px up
  SpriteAnimItem -1,+0,+$0, %000
  SpriteAnimItem -1,+0,+$0, %000
  SpriteAnimItem -1,+0,+$0, %000
  SpriteAnimItem -1,+0,+$0, %000
  SpriteAnimItem -1,+0,-$2, %000
  SpriteAnimItem -1,+0,+$0, %000
 .db %00100000        ;Right arm forward, no xy
  SpriteAnimItem +0,+0,+$2, %000
 .db 0
 .db $FF    ;(Implied) Right arm back   , all 1px down


HatLeft:
  SpriteHeader 4,$00,0
  SpriteItem +5,-6, $0, %000    ;Side
  SpriteItem -4,+2, $3, %000    ;Left
  SpriteItem -2,+5, $0, %000    ;Tip
  SpriteItem +2,+3, $4, %000    ;Right
 .dw IdleAnim
HatDown:
  SpriteHeader 3,$00,0
  SpriteItem -2,+1, $0, %000    ;Tip
  SpriteItem +2,-2, $2, %000    ;Right
  SpriteItem +0,-8, $1, %000    ;Left
 .dw IdleAnim
HatRight:
  SpriteHeader 4,$00,0
  SpriteItem +4,+3, $0, %000    ;Side
  SpriteItem -3,-7, $3, %010    ;Left
  SpriteItem -2,+0, $0, %000    ;Tip
  SpriteItem +2,-8, $4, %010    ;Right
 .dw IdleAnim
HatUp:
  SpriteHeader 3,$00,0
  SpriteItem +0,-7, $5, %000    ;Left
  SpriteItem -2,+4, $0, %000    ;Tip
  SpriteItem +2,+4, $6, %000    ;Right
 .dw IdleAnim

HatWalkLeft:
HatWalkDown:
HatWalkRight:
HatWalkUp:
;Universal animation of "sit still"
IdleAnim:
.DB $FF


AliceLeft:
  SpriteHeader 3,$10,0
  SpriteItem +0,-3, $9, %010    ;Leg
  SpriteItem -8,+0,-$1, %010    ;Shoulder
  SpriteItem -3,+0,-$5, %010    ;Head
 .dw AliceWalkLeft
AliceDown:
  SpriteHeader 6,$08,0
  SpriteItem +0,+0, $B, %000    ;Leg right
  SpriteItem +0,-8, $8, %000    ;Leg left
  SpriteItem -8,+8, $5, %000    ;Shoulder right
  SpriteItem +0,-8, $4, %000    ;Shoulder left
  SpriteItem -4,+8, $0, %000    ;Head right
  SpriteItem +0,-8,-$1, %000    ;Head left
 .dw AliceWalkDown
AliceRight:
  SpriteHeader 3,$10,0
  SpriteItem +0,-3, $9, %000    ;Leg
  SpriteItem -8,+0,-$1, %000    ;Shoulder
  SpriteItem -3,+0,-$5, %000    ;Head
 .dw AliceWalkRight
AliceUp:
  SpriteHeader 6,$08,0
  SpriteItem +0,+0, $E, %010    ;Leg right
  SpriteItem +0,-8, $E, %000    ;Leg left
  SpriteItem -8,+8, $6, %010    ;Shoulder right
  SpriteItem +0,-8, $6, %000    ;Shoulder left
  SpriteItem -4,+8, $2, %000    ;Head right
  SpriteItem +0,-8, $1, %000    ;Head left
 .dw AliceWalkUp

AliceWalkLeft:
AliceWalkRight:
;Arm back
 .db %00000100
  SpriteAnimItem +0,+0,+$1, %000
 .db 0
;Arm center
 .db %00000100
  SpriteAnimItem +0,+0,-$1, %000
;Arm forward
 .db %00000100
  SpriteAnimItem +0,+0,+$1, 1
 .db 0
;(Implied) Arm center
 .db $FF
AliceWalkUp:
AliceWalkDown:
;Left arm up, Right foot up
 .db %00110000
  SpriteAnimItem +0,+0,+$1, %000
  SpriteAnimItem +0,+0,+$2, %000
 .db 0
;Left arm down, Right foot down
 .db %00110000
  SpriteAnimItem +0,+0,-$1, %000
  SpriteAnimItem +0,+0,-$2, %000
;Left foot up, Right arm up
 .db %00110000
  SpriteAnimItem +0,+0,+$2, %000
  SpriteAnimItem +0,+0,+$1, %000
 .db 0
;(Implied) Left foot down, Right arm down
 .db $FF


ReimuLeft:
  SpriteHeader 4,$20,0
  SpriteItem +0,-8, $9, %001    ;Waist left
  SpriteItem +0,+8, $9, %011    ;Waist right
  SpriteItem -8,-4, $0, %011    ;Head
  SpriteItem -3,+0,-$3, %011    ;Head ribbon
 .dw ReimuWalkLeft
ReimuDown:
  SpriteHeader 4,$18,0
  SpriteItem +0,+0, $9, %011    ;Waist right
  SpriteItem +0,-8, $9, %001    ;Waist left
  SpriteItem -8,+4, $7, %001    ;Head
  SpriteItem -3,+0, $4, %001    ;Head ribbon
 .dw ReimuWalkDown
ReimuRight:
  SpriteHeader 4,$20,0
  SpriteItem +0,+0, $9, %011    ;Waist right
  SpriteItem +0,-8, $9, %001    ;Waist left
  SpriteItem -8,+4, $0, %001    ;Head
  SpriteItem -3,+0,-$3, %001    ;Head ribbon
 .dw ReimuWalkRight
ReimuUp:
  SpriteHeader 4,$18,0
  SpriteItem +0,-8, $E, %001    ;Waist left
  SpriteItem +0,+8, $E, %011    ;Waist right
  SpriteItem -8,-4, $6, %001    ;Head
  SpriteItem -3,+0, $3, %001    ;Head ribbon
 .dw ReimuWalkUp

ReimuWalkLeft:
ReimuWalkRight:
;Head down 1px, arm forward
 .db %00001100
  SpriteAnimItem -1,+0,+$1, %000
  SpriteAnimItem -1,+0,+$3, %000
 .db 0
;Head up 1px, arm center
 .db %00001100
  SpriteAnimItem +1,+0,-$1, %000
  SpriteAnimItem +1,+0,-$3, %000
;Head down 1px, arm back
 .db %00001100
  SpriteAnimItem -1,+0,+$3, %000
  SpriteAnimItem -1,+0,+$2, %000
 .db 0
;(Implied) Head up 1px, arm center
 .db $FF
ReimuWalkDown:
ReimuWalkUp:
 .db 0
;Left arm forward, right arm back
 .db %00001100
  SpriteAnimItem +0,+0,+$2, %000
  SpriteAnimItem +0,+0,+$1, %000
;Center arms
 .db %00001100
  SpriteAnimItem +0,+0,-$2, %000
  SpriteAnimItem +0,+0,-$1, %000
 .db 0
;Left arm back, right arm forward
 .db %00001100
  SpriteAnimItem +0,+0,+$1, %000
  SpriteAnimItem +0,+0,+$2, %000
;(Implied) Center arms
 .db $FF


NarumiLeft:
  SpriteHeader 4,$30,0
  SpriteItem -4,+0, $B, %000    ;Body right
  SpriteItem +0,-8, $A, %000    ;Body left
  SpriteItem -8,+8, $4, %000    ;Head right
  SpriteItem +0,-8, $3, %000    ;Head left
 .dw NarumiWalkLeft
NarumiDown:
  SpriteHeader 4,$28,0
  SpriteItem -4,+0, $E, %000    ;Body right
  SpriteItem +0,-8, $D, %000    ;Body left
  SpriteItem -8,+8, $6, %000    ;Head right
  SpriteItem +0,-8, $5, %000    ;Head left
 .dw NarumiWalkDown
NarumiRight:
  SpriteHeader 4,$30,0
  SpriteItem -4,+0, $9, %000    ;Body right
  SpriteItem +0,-8, $8, %000    ;Body left
  SpriteItem -8,+8, $2, %000    ;Head right
  SpriteItem +0,-8, $1, %000    ;Head left
 .dw NarumiWalkRight
NarumiUp:
  SpriteHeader 4,$28,0
  SpriteItem -4,+0, $D, %010    ;Body right
  SpriteItem +0,-8, $F, %000    ;Body left
  SpriteItem -8,+8, $8, %000    ;Head right
  SpriteItem +0,-8, $7, %000    ;Head left
 .dw NarumiWalkUp

;Narumi kinda just hovers everywhere
NarumiWalkLeft:
NarumiWalkDown:
NarumiWalkRight:
NarumiWalkUp:
 .db 0,0,0
 .db %00001111
  SpriteAnimItem +1,+0,+$0, %000
  SpriteAnimItem +1,+0,+$0, %000
  SpriteAnimItem +1,+0,+$0, %000
  SpriteAnimItem +1,+0,+$0, %000
 .db 0,0,0
 .db $FF


;Use zombie fairy as starter, other fairies made by adding to tile no.
;Order of starting anims is important!

FairyAnimations:
 .dw FairyLeft -CADDR
 .dw FairyDown -CADDR
 .dw FairyRight-CADDR
 .dw FairyUp   -CADDR
FairyDown:
  SpriteHeader 6,$58,0
  SpriteItem +0,+5,-$4, %010    ;Lower right wing
  SpriteItem +0,-8, $5, %000    ;Body
  SpriteItem +0,-8,-$4, %000    ;Lower left wing
  SpriteItem -8,+0,-$1, %000    ;Upper left wing
  SpriteItem +0,+8, $2, %000    ;Head
  SpriteItem +0,+8,-$1, %010    ;Upper right wing
 .dw FairyWalkDown
FairyUp:
  SpriteHeader 6,$58,0
  SpriteItem +0,+5,-$4, %010    ;Lower right wing
  SpriteItem +0,-8, $B, %000    ;Body
  SpriteItem +0,-8,-$4, %000    ;Lower left wing
  SpriteItem -8,+0,-$1, %000    ;Upper left wing
  SpriteItem +0,+8, $8, %000    ;Head
  SpriteItem +0,+8,-$1, %010    ;Upper right wing
 .dw FairyWalkUp
FairyLeft:
  SpriteHeader 4,$50,0
  SpriteItem +0,+4, $4, %010    ;Lower wing
  SpriteItem -8,+0, $7, %010    ;Upper wing
  SpriteItem +8,-8, $1, %000    ;Body
  SpriteItem -8,+0,-$2, %000    ;Head
 .dw FairyWalkLeft
FairyRight:
  SpriteHeader 4,$50,0
  SpriteItem +0,-4, $1, %010    ;Body
  SpriteItem -8,+0,-$2, %010    ;Head
  SpriteItem +8,-8, $4, %000    ;Lower wing
  SpriteItem -8,+0, $7, %000    ;Upper wing
 .dw FairyWalkRight

.DEFINE FairyAnimSize 2*4+2*4*4+2*2*2+2*4+4
.EXPORT FairyAnimSize

FairyWalkLeft:
;Wings in
 .db %00001100
  SpriteAnimItem +1,-1,+$0, %000
  SpriteAnimItem -1,-1,+$0, %000
;Up
 .db %00000111
  SpriteAnimItem -1,+0,+$0, %000
  SpriteAnimItem -1,+0,+$0, %000
  SpriteAnimItem -1,+0,+$0, %000
;Wings out
 .db %00001100
  SpriteAnimItem +0,+1,+$0, %000
  SpriteAnimItem +0,+1,+$0, %000
;(Implied) Down
 .db $FF
FairyWalkRight:
;Wings in
 .db %00000011
  SpriteAnimItem +1,+1,+$0, %000
  SpriteAnimItem -1,+1,+$0, %000
;Up
 .db %00001101
  SpriteAnimItem -1,+0,+$0, %000
  SpriteAnimItem -1,+0,+$0, %000
  SpriteAnimItem -1,+0,+$0, %000
;Wings out
 .db %00000011
  SpriteAnimItem +0,-1,+$0, %000
  SpriteAnimItem +0,-1,+$0, %000
;(Implied) Down
 .db $FF
FairyWalkDown:
FairyWalkUp:
;Wings in
 .db %00101101
  SpriteAnimItem +1,-1,+$0, %000
  SpriteAnimItem +1,+1,+$0, %000
  SpriteAnimItem -1,+1,+$0, %000
  SpriteAnimItem -1,-1,+$0, %000
;Up
 .db %00010111
  SpriteAnimItem -1,+0,+$0, %000
  SpriteAnimItem -1,+0,+$0, %000
  SpriteAnimItem -1,+0,+$0, %000
  SpriteAnimItem -1,+0,+$0, %000
;Wings out
 .db %00101101
  SpriteAnimItem +0,+1,+$0, %000
  SpriteAnimItem +0,-1,+$0, %000
  SpriteAnimItem +0,-1,+$0, %000
  SpriteAnimItem +0,+1,+$0, %000
;(Implied) Down
 .db $FF

MushroomLeft:
  SpriteHeader 1,$78,0
  SpriteItem -7,-4, $4, %000
 .dw IdleAnim
MushroomDown:
  SpriteHeader 1,$78,0
  SpriteItem -7,-4, $5, %000
 .dw IdleAnim
MushroomRight:
  SpriteHeader 1,$78,0
  SpriteItem -7,-4, $6, %000
 .dw IdleAnim
MushroomUp:
  SpriteHeader 1,$78,0
  SpriteItem -2,-2, $7, %000
 .dw IdleAnim

.ENDS
