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

;Fairy Types:
    ;%AAHHBBWW
    ;       ++--- Wing type
    ;     ++----- Body type
    ;   ++------- Hair type
    ; ++--------- AI type
  ;Values:
    ;0: Zombie part
    ;1: Prim part
    ;2: Experienced part
    ;3: Invalid part

;facing data
;Order:
    ;Relative Y
    ;Relative X
    ;Tile
    ;Attribute XOR (For correct flips)
;All UDLR designations are screen-based

FairyActorData:
 .dw 100
 .dw FairyHitboxes
 .dw FairyFrame
 .dw _HatValues
 .dw _Animations

FairyConstructor:
;Takes in the Fairy Designator byte and provides the correct animation data in RAM
;Then, it makes an instance of the fairy, which knows to free it when done
;Of course, it provides the values from creating a fairy back to the caller.
  RET

FairyFrame:
  XOR A
  RET

_Animations:
 .dw FairyLeft
 .dw FairyDown
 .dw FairyRight
 .dw FairyUp

_HatValues:
 .db 2
 .db 18
 .db 34
 .db 50

.ENDS
