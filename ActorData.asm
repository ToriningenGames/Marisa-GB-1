;Actor data
    ;Centralized place for all character's memory assignments

;Memory format:
;Global
    ;+$00, size 2: Sprite pointer (to shadow OAM)
    ;+$02, size 2: Master X
    ;+$04, size 2: Master Y
    ;+$06, size 2: Subsprite relational data (to RAM)
    ;+$08, size 2: animation pointer (to ROM)
    ;+$0A, size 1: current animation wait (4.4)
    ;+$0B, size 1: current animation speed (per frame, 4.4)
    ;+$0C, size 2: Movement Speed (pixels, 8.8)
    ;+$0E, size 2: Hitbox data
    ;+$10, size 1: Visible on screen
    ;+$1F, size 1: Hat value
;Marisa
    ;+$11, size 1: current button state
;Hat
    ;+$11, size 2: current character wearing

;Hat values:
;0:  This actor cannot wear a hat
;1:  Marisa, facing down
;2:  Fairy,  facing down
;3:  Narumi, facing down
;4:  Alice,  facing down
;5:  Reimu,  facing down
;6:  Danmaku
;17: Marisa, facing up
;18: Fairy,  facing up
;19: Narumi, facing up
;20: Alice,  facing up
;21: Reimu,  facing up
;33: Marisa, facing left
;34: Fairy,  facing left
;35: Narumi, facing left
;36: Alice,  facing left
;37: Reimu,  facing left
;49: Marisa, facing right
;50: Fairy,  facing right
;51: Narumi, facing right
;52: Alice,  facing right
;53: Reimu,  facing right

.DEFINE _SprPtr $00
.DEFINE _MasterX $02
.DEFINE _MasterY $04
.DEFINE _RelData $06
.DEFINE _AnimPtr $08
.DEFINE _AnimWait $0A
.DEFINE _AnimSpeed $0B
.DEFINE _MoveSpeed $0C
.DEFINE _Hitbox $0E
.DEFINE _Visible $10
.DEFINE _HatVal $1F

.DEFINE _ButtonState $11

.DEFINE _ParentChar $11
