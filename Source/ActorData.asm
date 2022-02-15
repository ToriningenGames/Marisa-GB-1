;Actor data
    ;Centralized place for all character's memory assignments

;Animation format:
    ;Two parts: Base and Active
    ;Base determines the default state to display when animation is off
    ;Active determines the actions to go through when animation is on

;Base part:
;Header:
;%TTTTPCCC
; |||||+++--- Sprite Count
; ||||+--- Always on top
; ++++--- Starting tile

;For each sprite:
;%YYYYXXXX YXPOOOOO
; |||||||| |||+++++--- Tile offset (signed)
; |||||||| ||+--- Palette choice
; |||||||| |+--- X mirror
; |||||||| +--- Y mirror
; ||||++++--- signed X offset from previous sprite (-1 for movement by 8)
; ++++--- signed Y offset from previous sprite (-1 for movement by 8)

;Tailer: pointer to animation stream

;Active part:
;%E0654321
; | ++++++--- Set if sprite changes this frame
; +--- End of animation
;For each sprite set (lo to hi)
;%YYYYXXXX YXCOOOOO
; |||||||| |||+++++--- Tile change (signed)
; |||||||| ||+--- Palette choice toggle
; |||||||| |+--- X mirror toggle
; |||||||| +--- Y mirror toggle
; ||||++++--- X movement (signed)
; ++++--- Y movement (signed)

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
    ;1 byte:  radius (pixels)
    ;1 byte:  type
    ;2 bytes: Action. Signature:
        ;BC->Owning actor
        ;DE->Touching actor

;Memory format:
;Global
    ;+$00, size 2: Sprite pointer (to shadow OAM)
    ;+$02, size 2: Master X
    ;+$04, size 2: Master Y
    ;+$06, size 2: Subsprite relational data (to RAM)
    ;+$08, size 2: current animation pointer (to ROM)
    ;+$0A, size 1: current animation wait
    ;+$0B, size 1: current animation ID
    ;+$0C, size 2: Movement Speed (pixels, 8.8)
    ;+$0E, size 2: Hitbox data
    ;+$10, size 1: Visible on screen
    ;+$11, size 1: Cardinal direction most recently moving/facing
    
    ;+$14, size 1: Actor specific value used in cutscenes
    ;+$15, size 1: Actor specific setting
    ;+$16, size 2: AI Movement function
    ;+$18, size 2: Hat value list
    ;+$1A, size 2: Animation pointer list
    ;+$1C, size 1: Animation sprite count
    ;+$1D, size 1: Control state
    ;+$1E, size 1: New animation ID
    ;+$1F, size 1: Hat value
;Marisa
    ;+$12, size 1: current button state
;Hat
    ;+$12, size 2: current character wearing
;Fairy
    ;+$12, size 2: Pointer to RAM holding animation data
    ;+$15, size 1: Configuration settings
;Danmaku
    ;+$12, size 2: Pointer to RAM holding animation data
    ;+$14, size 1: Tile animation direction setting
    ;+$15, size 2: Pointer to data for moving danmaku

;Control bit states:
;%C0000OTE
; |    ||+--- Free existence enable
; |    |+---- Interaction permitted
; |    +----- Can exit room
; +---------- Free camera
;$FF: Self Destruct

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
.DEFINE _AnimID $0B
.DEFINE _MoveSpeed $0C
.DEFINE _Hitbox $0E
.DEFINE _Visible $10
.DEFINE _LastFacing $11

.DEFINE _CutsceneLocal $14
.DEFINE _Settings $15
.DEFINE _AIMovement $16
.DEFINE _HatValList $18
.DEFINE _AnimPtrList $1A
.DEFINE _SprCount $1C
.DEFINE _ControlState $1D
.DEFINE _AnimChange $1E
.DEFINE _HatVal $1F

;Marisa
.DEFINE _ButtonState $12

;Hat
.DEFINE _ParentChar $12

;Fairy
.DEFINE _AnimRAM $12

;Danmaku
;.DEFINE _AnimRAM $11
.DEFINE _IsDirected $12         ;0 if undirected. Holds base tile if directed
.DEFINE _MovementData $13       ;Pointer to data for moving danmaku
.DEFINE _MovementFunction $16   ;Function for moving danmaku

