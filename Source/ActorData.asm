;Actor data
    ;Centralized place for all character's memory assignments

;Animation format:
    ;Two parts: Base and Active
    ;Base determines the default state to display when animation is off
    ;Active determines the actions to go through when animation is on
;Base part:
    ;1 byte: Sprite count (up to 6)
    ;<=24 bytes: Sprite data state
;Active part:
    ;1 byte: Counts
        ;%WWWWCCCC
        ; ||||++++--- Change counts
        ; ++++------- Wait time (Loaded hi)
    ;N bytes: Sprite Changes
        ;%VVVTTTPP
        ; ||||||++--- Portion (Y val, X val, Tile, Attr, 3 if loop)
        ; |||+++----- Target (Sprite #1-6, 0 for all, 7 for loop instead)
        ; +++-------- Value (7 if loop)
        ;Meaning of Value:
            ;If selected byte is Y val, X val, or Tile:
                ;Value=Two's Compliment signed value to be added to selection
            ;If selected byte is Attribute:
                ;Value=XOR mask for attribute values
                ;Bit 0: Palette choice
                ;Bit 1: X mirror
                ;Bit 2: Y mirror
        ;If target is loop, two bytes for loop destination address follow

;Attribute bit reminder:
    ;%PYXC0000
    ; |||||||+--- (Used for forcing priority)
    ; ||||++++--- CGB Only
    ; |||+------- Palette choice
    ; ||+-------- X mirror
    ; |+--------- Y mirror
    ; +---------- Hide behind BKG

.MACRO Animate ARGS sprite, attr, val
 .db ((val & $07) << 5) | ((sprite & $07) << 2) | (attr & $03)
.ENDM
.DEFINE AnimY 0
.DEFINE AnimX 1
.DEFINE AnimTile 2
.DEFINE AnimAttr 3

;Hitbox data format:
;All actor hitboxes are squares
    ;1 byte: hitbox count
    ;2 bytes: X position (8.8)
    ;2 bytes: Y position (8.8)
    ;2 bytes: radius (8.8)
    ;2 bytes: Action. Signature:
        ;BC->Owning actor
        ;DE->Touching actor

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

;Danmaku
;.DEFINE _AnimRAM $11
.DEFINE _IsDirected $13 ;0 if undirected. Holds base tile if directed
.DEFINE _MovementID $14     ;ID of danmaku movement type
.DEFINE _MovementData $15   ;Data/state to assist movement

;Movement function notes:
    ;DE->Actor Data
  ;Edit X and Y in place
  ;Return:
    ;B = X integer movement, signed
    ;C = Y integer movement, signed

