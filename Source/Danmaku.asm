;Danmaku behavior

;Animation
;There are 3 kinds of danmaku animation:
    ;Undirected
    ;Directed
    ;Spinning
;Undirected is a static sprite
;Directed is a sprite whose value, X flip, and Y flip are dependent on its direction
;Spinning is a sprite whose value, X flip, and Y flip change from frame to frame
;Each animation function takes a pointer to object data

;Signature:
    ;A = Animation ID
        ;0 (Undirected): Selector
        ;1 (Undirected): Dark Bubble
        ;2 (Undirected): Light Bubble
        ;3 (Undirected): Yin-Yang
        ;4 (Directed): Orb
        ;5 (Directed): Ofuda
        ;6 (Directed): Bullet
    ;DE = Initial placement

.include "ActorData.asm"

.SECTION "Danmaku" FREE

Danmaku_Entry:
  PUSH AF
    CALL Actor_New
  POP AF
  LD B,A
  LD HL,_MovementID
  ADD HL,DE
  AND $F0
  SWAP A
  LD (HL),A ;Animation ID
  LD A,$0F
  AND B
  CP 4
  JR c,_AnimUndirected
_AnimDirected:
  ;We will be changing the animation data repeatedly
  ADD <(_DirectedStarts-4)
  LD L,A
  LD A,>(_DirectedStarts-4)
  ADC 0
  LD H,A
  LD A,(HL)
  LD HL,_IsDirected
  ADD HL,DE
  LD (HL),A ;Tile base
  PUSH DE
    CALL MemAlloc
    LD C,E
    LD B,D
  POP DE
  LD HL,_AnimRAM
  ADD HL,DE
  LD (HL),C
  INC HL
  LD (HL),B
  LD HL,_DirectedTemplate
  PUSH BC
  PUSH DE
    LD E,9
-
    LDI A,(HL)
    LD (BC),A
    INC BC
    DEC E
    JR nz,-
  POP DE
  POP BC
  ;AnimRAM set, BC with animation pointer
  JR _Danmaku_General
_AnimUndirected:
  ;We will be leaving the animation data alone
  LD HL,_IsDirected
  ADD HL,DE
  LD (HL),0
  RLCA      ;Look up animation index
  ADD <_UndirectedAnims
  LD L,A
  LD A,0
  ADC >_UndirectedAnims
  LD H,A
  LDI A,(HL)
  LD B,(HL)
  LD C,A
  ;BC with pointer to animation
_Danmaku_General:
  ;Hitbox setup
  LD HL,_Hitbox
  ADD HL,DE
  LD (HL),<DanmakuHitboxes
  INC HL
  LD (HL),>DanmakuHitboxes
  ;Animation values
  LD HL,_AnimSpeed
  ADD HL,DE
  LD (HL),$06
  SCF
  PUSH DE
    CALL Actor_Draw
  POP DE
;Danmaku specific messages
    ;x: Hits
    ;x: Destruct
  ;Carry correct b/c CMP against $FF
  CALL Actor_HighPriority
  CALL HaltTask
  LD HL,_MovementID
  ADD HL,DE
  LD A,(HL)
  RLCA
  ADD <_Patterns    ;Two-star pointer LUT
  LD L,A
  LD A,0
  ADC >_Patterns
  LD H,A
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  RST $30
  LD HL,_IsDirected
  ADD HL,DE
  LD A,(HL)
  OR A  ;Zero if undirected
  JP z,Actor_Draw
  ;Determine majority direction
    ;Right majority:        |X| > |Y|*2, 0 < X    ,     Y    
    ;Left majority:         |X| > |Y|*2,     X < 0,     Y    
    ;Up majority:           |X|*2 < |Y|,     X    ,     Y < 0
    ;Down majority:         |X|*2 < |Y|,     X    , 0 < Y    
    ;Up Right majority:     |X| < |Y|*2, 0 < X    ,     Y < 0
    ;Up Left majority:      |X| < |Y|*2,     X < 0,     Y < 0
    ;Down Right majority:   |X| < |Y|*2, 0 < X    , 0 < Y    
    ;Down Left majority:    |X| < |Y|*2,     X < 0, 0 < Y    
  LD A,B
  OR C
  JP z,Actor_Draw   ;No discernable movement, stay the same
  LD A,B
  BIT 7,B   ;Place abs of each in HL
  JR z,+
  CPL
  INC A
+
  LD B,A
  LD A,C
  BIT 7,C
  JR z,+
  CPL
  INC A
+
  LD C,A
  LD HL,_IsDirected ;Grab tile base; update AnimRAM
  ADD HL,DE
  LDD A,(HL)
  PUSH AF
    LDD A,(HL)
    LD L,(HL)
    LD H,A
  POP AF
  INC HL
  INC HL
  INC HL
  LD (HL),A
  LD A,B    ;Detect diagonal vs cardinal
  RRA
  CP C
  JR nc,+
  ;Possible diagonal
  LD A,C
  RRA
  CP B
  JR nc,++
  ;Is diagonal
  INC (HL)  ;Select diagonal tile
  INC HL
  BIT 7,B
  JR z,+++
  ;Up Right/Up Left detect
  BIT 7,C
  JR z,++++
        ;Face Up Left
  LD A,%10011111
  AND (HL)
  OR %01100000
  LD (HL),A
  JR _FacingDetectionEnd
++++    ;Face Up Right
  LD A,%10011111
  AND (HL)
  OR %01000000
  LD (HL),A
  JR _FacingDetectionEnd
+++ ;Down Right/Down Left detect
  BIT 7,C
  JR z,+++
        ;Face Down Left
  LD A,%10011111
  AND (HL)
  OR %00100000
  LD (HL),A
  JR _FacingDetectionEnd
+++     ;Face Down Right
  LD A,%10011111
  AND (HL)
  LD (HL),A
  JR _FacingDetectionEnd
++  ;Up down detect
  INC (HL)  ;Select Up/down tile
  INC (HL)
  INC HL
  BIT 7,B
  JR z,++
        ;Face Up
  LD A,%10011111
  AND (HL)
  OR %01000000
  LD (HL),A
  JR _FacingDetectionEnd
++      ;Face Down
  LD A,%10011111
  AND (HL)
  LD (HL),A
  JR _FacingDetectionEnd
+   ;Right left detect
  INC HL    ;Select left/right tile
  BIT 7,C
  JR z,+
        ;Face Left
  LD A,%10011111
  AND (HL)
  OR %00100000
  LD (HL),A
  JR _FacingDetectionEnd
+       ;Face Right
  LD A,%10011111
  AND (HL)
  LD (HL),A
_FacingDetectionEnd:
  SCF
  JP Actor_Draw

;Display
_UndirectedAnims:
 .dw _MenuBubble
 .dw _DarkBubble
 .dw _LightBubble
 .dw _YinYang

_DirectedStarts:
 .db $40    ;(Directed): Orb
 .db $43    ;(Directed): Ofuda
 .db $46    ;(Directed): Bullet

_DirectedTemplate
 .db 1
 .db -4,-4,$00,%00000000
 .db $11,$FF
 .dw _Still

_DarkBubble:
 .db 1
 .db -4,-4,$02,%00000000
 .db $F1,$FF
 .dw _Still
_LightBubble:
 .db 1
 .db -4,-4,$49,%00000000
 .db $F1,$FF
 .dw _Still
_MenuBubble:
 .db 1
 .db -4,-4,$00,%00000000
_Still:
 .db $F1,$FF
 .dw _Still

_YinYang:
 .db 2
 .db -4,12,$09,%00000000
 .db  4,12,$09,%00000000
_Spin:                      ;Enter with Down
 .db $11
 Animate 0,AnimTile,+1      ;Down left, or Up right
 .db $12
 Animate 0,AnimAttr,%110
 Animate 0,AnimTile,-3      ;Left, or Right
 .db $11
 Animate 0,AnimTile,+1      ;Down right, or Up left
 .db $12
 Animate 0,AnimTile,+1      ;Down, or Up
 .db $FF
 .dw _Spin

;Spin positions:
;Down:          Tile: $48, Attr: %0x v
;Down Left:     Tile: $47, Attr: %01 x
;Left:          Tile: $46, Attr: %x1 x
;Up Left:       Tile: $47, Attr: %11 v
;Up:            Tile: $48, Attr: %1x v
;Up Right:      Tile: $47, Attr: %10 x
;Right:         Tile: $46, Attr: %x0 x
;Down Right:    Tile: $47, Attr: %00 v

;Pattern
_Patterns:
 .dw Return
 .dw Return
 .dw Return
 .dw Return

;Mechanics
DanmakuHitboxes:
 .db 1
 .dw $0000,$0000,$0202
 .dw DanmakuHitboxAction
DanmakuHitboxAction:
  RET

.ENDS
