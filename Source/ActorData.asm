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
    ;+$1C, size 1: Animation sprite count
    ;+$1D, size 1: Existence status
    ;+$1E, size 1: Animation ID
    ;+$1F, size 1: Hat value
;Marisa
    ;+$11, size 1: current button state
;Hat
    ;+$11, size 2: current character wearing
;Fairy
    ;+$11, size 2: Pointer to RAM holding animation data
    ;+$13, size 1: Configuration settings

;Existence values:
;0:   Exist freely
;1:   Cutscene control
;2:   Be unseen. Exist but hidden
;255: Destruct

;Animation IDs:
;0:   Face Left
;1:   Face Down
;2:   Face Right
;3:   Face Up
;4:   Walk Left
;5:   Walk Down
;6:   Walk Right
;7:   Walk Up
;8:   Idle Left
;9:   Idle Down
;10:  Idle Right
;11:  Idle Up
;255: No anim change

;Hat values:
;0:  This actor cannot wear a hat
;1:  Marisa, facing left
;2:  Fairy,  facing left
;3:  Narumi, facing left
;4:  Alice,  facing left
;5:  Reimu,  facing left
;6:  Danmaku
;17: Marisa, facing down
;18: Fairy,  facing down
;19: Narumi, facing down
;20: Alice,  facing down
;21: Reimu,  facing down
;33: Marisa, facing right
;34: Fairy,  facing right
;35: Narumi, facing right
;36: Alice,  facing right
;37: Reimu,  facing right
;49: Marisa, facing up
;50: Fairy,  facing up
;51: Narumi, facing up
;52: Alice,  facing up
;53: Reimu,  facing up

;General
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

.DEFINE _SprCount $1C
.DEFINE _LandingPad $1D
.DEFINE _AnimChange $1E
.DEFINE _HatVal $1F

;Marisa
.DEFINE _ButtonState $11

;Hat
.DEFINE _ParentChar $11

;Fairy
.DEFINE _AnimRAM $11
.DEFINE _Settings $13
