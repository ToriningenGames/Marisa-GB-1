;Fairy behaviour

.include "ActorData.asm"

;We have
    ;Long hair     and Short hair
    ;Striped dress and Solid dress
    ;Thick wing    and Thin wing
;With only a couple hiccups, these are interchangeable, leading to
;2 * 2 * 2 == 2 ^ 3 == 8 different fairy designs!
;Each additional fairy design will also only take up 4 tiles,
    ;and increase the above dramatically!
;(You forgot back and side facings when writing those numbers)

.SECTION "Fairy" FREE

;Animation:
    ;Take the upper wings, and move them down one tile
    ;Take the lower wings, and move them up one tile
    ;Wait
    ;Take the upper wings, and move them up one tile
    ;Take the lower wings, and move them down one tile
    ;Wait
    ;Repeat
    
    ;Head bob optional
    ;Move the wings inwards too?

;facing data
;Order:
    ;Relative Y
    ;Relative X
    ;Tile
    ;Attribute XOR (For correct flips)
;All UDLR designations are screen-based
;Down
 .db $00,$00,$67,%00000000  ;Head left
 .db $00,$00,$68,%00000000  ;Head right
 .db $00,$00,$6B,%00000000  ;Shoulder left
 .db $00,$00,$6B,%00100000  ;Shoulder right
 .db $00,$00,$6E,%00000000  ;Leg left
 .db $00,$00,$6E,%00100000  ;Leg right
;Up
 .db $00,$00,$69,%00000000  ;Head left
 .db $00,$00,$6A,%00000000  ;Head right
 .db $00,$00,$6C,%00100000  ;Shoulder left
 .db $00,$00,$6C,%00000000  ;Shoulder right
 .db $00,$00,$6F,%00100000  ;Leg left
 .db $00,$00,$6F,%00000000  ;Leg right
;Left
 .db $00,$00,$78,%00000000  ;Head
 .db $00,$00,$00,%00000000  ;Hide Sprite
 .db $00,$00,$79,%00000000  ;Shoulder
 .db $00,$00,$00,%00000000  ;Hide sprite
 .db $00,$00,$73,%00100000  ;Leg left
 .db $00,$00,$72,%00100000  ;Leg right
;Right
 .db $00,$00,$6D,%00000000  ;Head
 .db $00,$00,$00,%00000000  ;Hide Sprite
 .db $00,$00,$79,%00000000  ;Shoulder
 .db $00,$00,$00,%00000000  ;Hide sprite
 .db $00,$00,$72,%00000000  ;Leg left
 .db $00,$00,$73,%00000000  ;Leg right

FairyFrame:
  CALL Actor_New    ;Null actor (w/visibility)
  ;Hitbox setup
  LD HL,_Hitbox
  ADD HL,DE
  LD (HL),<DefaultHitboxes
  INC HL
  LD (HL),>DefaultHitboxes
  ;Animation values
  LD HL,_HatVal
  ADD HL,DE
  LD (HL),3
  LD BC,_DownFace
  CALL HaltTask
  ;Face new direction
  PUSH DE
    SCF
    CALL Actor_Draw
  POP DE
  CALL HaltTask
  LD HL,_LandingPad
  ADD HL,DE
;Fairy specific messages
    ;x: Cutscene control
    ;x: Play animation
    ;x: Destruct
  OR A  ;Clear carry
  JP Actor_Draw

_DownFace:
 .db -10,-9,$69,%00100000  ;Head left
 .db -10,-1,$68,%00100000  ;Head right
 .db  -8,-7,$6B,%00000000  ;Shoulder left
 .db  -8, 0,$6B,%00100000  ;Shoulder right
 .db   0,-7,$6E,%00000000  ;Leg left
 .db   0, 0,$6E,%00100000  ;Leg right
_IdleLoop:
 .db $F1
 .db $FF
 .dw _IdleLoop

.ENDS
