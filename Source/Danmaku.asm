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
        ;$08 (Directed): Yin-Yang
        ;$40 (Directed): Orb
        ;$43 (Directed): Ofuda
        ;$46 (Directed): Bullet
    ;DE = Initial placement

.include "ActorData.asm"

.SECTION "Danmaku" FREE

Danmaku_AnimDirected:
  ;We will be changing the animation data repeatedly
  PUSH AF
    CALL Actor_New
  POP AF
  LD HL,_IsDirected
  ADD HL,DE
  LD (HL),A ;Tile base
  LD HL,_MovementID
  ADD HL,DE
  LD (HL),A ;Animation ID
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
  ;LOAD TEMPLATE HERE
  
  ;AnimRAM set, BC with animation pointer
  JR _Danmaku_General
Danmaku_AnimUndirected:         ;TEST ME!!!
  ;We will be leaving the animation data alone
  PUSH AF
    CALL Actor_New
  POP AF
  LD HL,_IsDirected
  ADD HL,DE
  LD (HL),0
  LD HL,_MovementID
  ADD HL,DE
  LD (HL),A ;Animation ID
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
  LD (HL),<DefaultHitboxes
  INC HL
  LD (HL),>DefaultHitboxes
  ;Animation values
  LD HL,_AnimSpeed
  ADD HL,DE
  LD (HL),$10
  SCF
  PUSH DE
    CALL Actor_Draw
  POP DE
;Danmaku specific messages
    ;x: Hits
    ;x: Destruct
  ;Carry correct b/c CMP against $FF
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
 .db 1
 .db -4,-4,$0A,%00000000
_Spin:                      ;Enter with Down
 .db $12
 Animate 1,AnimTile,-1
 Animate 1,AnimAttr,%010    ;Down left, or Up right
 .db $11
 Animate 1,AnimTile,-1      ;Left, or Right
 .db $12
 Animate 1,AnimTile,+1
 Animate 1,AnimAttr,%100    ;Down right, or Up left
 .db $12
 Animate 1,AnimTile,+1      ;Down, or Up
 .db $FF
 .dw _Spin

;Spin positions:
;Down:          Tile: $48, Attr: %0x
;Down Left:     Tile: $47, Attr: %01
;Left:          Tile: $46, Attr: %x1
;Up Left:       Tile: $47, Attr: %11
;Up:            Tile: $48, Attr: %1x
;Up Right:      Tile: $47, Attr: %10
;Right:         Tile: $46, Attr: %x0
;Down Right:    Tile: $47, Attr: %00

;Pattern
_Patterns:
 .dw Return
 .dw Return
 .dw Return
 .dw Return

.ENDS
