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
        ;7 (Directed): Laser (Proposed)
    ;DE = Initial placement

.include "ActorData.asm"

.SECTION "Danmaku" FREE

Danmaku_Entry:
  PUSH AF
    CALL Actor_New
    PUSH DE
      CALL MemAlloc   ;Set up AnimRAM
      LD C,E
      LD B,D
    POP DE
    LD HL,_AnimRAM
    ADD HL,DE
    LD (HL),C
    INC HL
    LD (HL),B
    PUSH DE
      CALL MemAlloc   ;Set up Movement Data
      LD C,E
      LD B,D
    POP DE
    LD HL,_MovementData
    ADD HL,DE
    LD (HL),C
    INC HL
    LD (HL),B
    LD H,B
    LD L,C
    LD C,32
    XOR A
-
    LDI (HL),A  ;Clear out Movement Data
    DEC C
    JR nz,-
  POP AF
  LD C,A
  RLCA  ;Index into patterns
  RLCA  ;(11 bytes per entry)
  ADD C
  RLCA
  ADD C
  ADD <_Patterns
  LD C,A
  LD A,0
  ADC >_Patterns
  LD B,A
  PUSH DE
    LD HL,_AnimRAM
    ADD HL,DE
    LDI A,(HL)
    LD H,(HL)
    LD L,A
    PUSH BC
      LD A,(BC)     ;Load (BC) into BC
      INC BC
      LD E,A
      LD A,(BC)
      LD C,E
      LD B,A
      ;BC -> Anim Template
      ;HL -> Anim RAM
      ;(SP) -> Danmaku Pattern
      ;(SP+2) -> Actor RAM
      LD E,32
-
      LD A,(BC)     ;Copy template to RAM
      INC BC
      LDI (HL),A
      DEC E
      JR nz,-
    POP BC
  POP DE
  LD HL,_IsDirected
  ADD HL,DE
  INC BC
  INC BC
  LD A,(BC)     ;Directed value
  LDI (HL),A
  INC BC
  LD A,(BC)     ;Movement Function lo
  LDI (HL),A
  INC BC
  LD A,(BC)     ;Movement Function hi
  LDI (HL),A
  INC BC
  LDI A,(HL)    ;Go to Movement Data area
  LD H,(HL)
  LD L,A
  LD A,(BC)     ;Movement Data 0
  LDI (HL),A
  INC BC
  LD A,(BC)     ;Movement Data 1
  LDI (HL),A
  INC BC
  LD A,(BC)     ;Movement Data 2
  LDI (HL),A
  INC BC
  LD A,(BC)     ;Movement Data 3
  LDI (HL),A
  INC BC
  LD HL,_Hitbox ;TODO: Make a deep copy later
  ADD HL,DE
  LD A,(BC)     ;Hitbox lo
  LDI (HL),A
  INC BC
  LD A,(BC)     ;Hitbox hi
  LDI (HL),A
  LD HL,_AnimRAM
  ADD HL,DE
  LDI A,(HL)    ;Ready BC with animation pointer
  LD B,(HL)
  LD C,A
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
  LD HL,_SprCount
  ADD HL,DE
  LD A,(HL)
  INC A
  PUSH AF
-   ;For each danmaku
  POP AF
  DEC A
  JR nz,+
  ;Bail out to draw
  LD HL,_AnimRAM
  ADD HL,DE
  LDI A,(HL)    ;Load Anim pointer
  LD B,(HL)
  LD C,A
  LD HL,_IsDirected
  ADD HL,DE
  LD A,(HL)
  OR A  ;Unset carry
  JP Actor_Draw
+
  PUSH AF
    PUSH DE
      LD HL,_MovementData+1
      ADD HL,DE
      LD D,(HL)
      DEC HL
      LD E,(HL)
      DEC HL
      LD B,(HL)
      DEC HL
      LD L,(HL)
      LD H,B
      RST $30
    POP DE
  ;Move sprite
  POP AF
  PUSH AF
    PUSH BC
      LD HL,_RelData    ;Go to this sprite in the RelData
      ADD HL,DE
      DEC A
      RLCA
      RLCA
      ADD (HL)
      LD C,A
      INC HL
      LD A,0
      ADC (HL)
      LD H,A
      LD L,C
    POP BC
    LD A,(HL)
    ADD B
    LDI (HL),A
    LD A,(HL)
    ADD C
    LD (HL),A
    ;TODO: Move hitbox here
    LD HL,_IsDirected
    ADD HL,DE
    LD A,(HL)
    OR A  ;Zero if undirected
    JR z,-
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
    JR z,-      ;No discernable movement, stay the same
  POP AF
  PUSH AF
    LD L,A
    PUSH BC
      LD A,B
      BIT 7,B   ;Place abs of each in BC
      JR z,+
      CPL
      INC A
      LD B,A
+
      LD A,C
      BIT 7,C
      JR z,+
      CPL
      INC A
      LD C,A
+
      LD A,L
      PUSH AF
        LD HL,_IsDirected ;Grab tile base; update RelData
        ADD HL,DE
        LD A,(HL)
      POP HL
      PUSH AF
        PUSH HL
          LD HL,_RelData
          ADD HL,DE
          LDI A,(HL)
          LD H,(HL)
          LD L,A
        POP AF
        DEC A
        INC HL
        INC HL
        RLCA
        RLCA
        ADD L
        LD L,A
        LD A,0
        ADC H
        LD H,A
      POP AF
      LD (HL),A
      LD A,B    ;Detect diagonal vs cardinal
      SRA A
      CP C
      JR nc,++
      ;Possible diagonal
      LD A,C
      SRA A
      CP B
    POP BC
    JR nc,+
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
    JR _FacingDetectionEnd
++++    ;Face Up Right
    LD A,%10011111
    AND (HL)
    OR %01000000
    JR _FacingDetectionEnd
+++ ;Down Right/Down Left detect
    BIT 7,C
    JR z,+++
          ;Face Down Left
    LD A,%10011111
    AND (HL)
    OR %00100000
    JR _FacingDetectionEnd
+++     ;Face Down Right
    LD A,%10011111
    AND (HL)
    JR _FacingDetectionEnd
++  ;Up down detect
    POP BC
    INC (HL)  ;Select Up/down tile
    INC (HL)
    INC HL
    BIT 7,B
    JR z,++
        ;Face Up
    LD A,%10011111
    AND (HL)
    OR %01000000
    JR _FacingDetectionEnd
++      ;Face Down
    LD A,%10011111
    AND (HL)
    JR _FacingDetectionEnd
+   ;Right left detect
    INC HL      ;Left/right tile already selected
    BIT 7,C
    JR z,+
          ;Face Left
    LD A,%10011111
    AND (HL)
    OR %00100000
    JR _FacingDetectionEnd
+       ;Face Right
    LD A,%10011111
    AND (HL)
_FacingDetectionEnd:
    LD (HL),A
    JP -

;Display

;_DirectedStarts:
; .db $40    ;(Directed): Orb
; .db $43    ;(Directed): Ofuda
; .db $46    ;(Directed): Bullet
; .db $7A    ;(Directed): Star

;_DirectedTemplate
; .db 1
; .db -4,-4,$00,%00000000
; .db $11,$FF
; .dw _Still
;
;_DarkBubble:
; .db 1
; .db -4,-4,$02,%00000000
; .db $F1,$FF
; .dw _Still
;_LightBubble:
; .db 1
; .db -4,-4,$49,%00000000
; .db $F1,$FF
; .dw _Still
;_MenuBubble:
; .db 1
; .db -4,-4,$00,%00000000
;_Still:
; .db $F1,$FF
; .dw _Still
;
_YinYang:
 .db 2
 .db -4,12,$09,%00000000
 .db  4,12,$09,%00000000
_YinYangSpin:               ;Enter with Down
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
 .dw _YinYangSpin

_ReimuOptions:
 .db 2
 .db -1, -3,$09,%00000000
 .db -1, -4,$09,%00000000
 .db $11,$FF
 .dw _YinYangSpin

_StarType:
 .db 6
 .db -4, -4,$7C,%01000000   ;Vertical mirror
 .db -4, -4,$7C,%01000000
 .db -4, -4,$7C,%01000000
 .db -4, -4,$7C,%01000000
 .db -4, -4,$7C,%01000000
 .db -4, -4,$7C,%01000000
_StarSpin:
 .db $41
 Animate 0,AnimTile,-1
 .db $42
 Animate 0,AnimTile,-1
 Animate 0,AnimAttr,%100
 .db $41
 Animate 0,AnimTile,+1
 .db $43
 Animate 0,AnimTile,+1
 Animate 0,AnimAttr,%010
 .db $FF
 .dw _StarSpin

_DirectedOrb:
 .db 6
 .db -4, -4,$46,%00000000
 .db -4, -4,$46,%00000000
 .db -4, -4,$46,%00000000
 .db -4, -4,$46,%00000000
 .db -4, -4,$46,%00000000
 .db -4, -4,$46,%00000000
_Idle:
 .db $F1
 .db $FF
 .dw _Idle

_Ofuda:
 .db 3
 .db -4, -4,$43,%00000000
 .db -4, -4,$43,%00000000
 .db -4, -4,$43,%00000000
 .db $F1
 .db $FF
 .dw _Idle

;Movement functions
;Arguments:
    ;A  =  Sprite Number
    ;DE -> Actor Data
;Returns:
    ;DE -> Actor Data
    ;BC == Y, X integer movement
;Only the numerics need be provided, danmaku function handles actor updates
;Called for each danmaku, back to front

;Idea: Have danmaku destory itself after a small set timespan:
    ;Reduces sprite load
    ;Still indicates danmaku firing
    ;Doesn't clutter screen
    ;Frees actors, memory, and tasks
    ;Configurable timespan could destory real danmaku after leaving screen

;Does nothing
_DanmakuFunction_Dummy:
  LD BC,0
  RET

;Deploys options, sits there
;Data option 0: Distance to move, x2
_DanmakuFunction_ReimuOptions:
  LD BC,0
  LD HL,0
  ADD HL,DE
  LD A,(HL)
  OR A
  RET z
  DEC A
  LD (HL),A
  RRCA
  LD C,1    ;First orb
  RET c
  LD C,-1   ;Second orb
  RET

;Data option 0: Lifetime
;Data option 1: Speed
;Data option 2: Angle
;Data option 16: Fractional locations
    ;Sprite 0 Y fraction
    ;Sprite 0 X fraction
    ;Sprite 1 Y fraction
    ;Sprite 1 X fraction
    ;etc...
_DanmakuFunction_ReimuDanmaku:
  ;Directed ofuda
  ;3 streams, laserlike, waving back and forth
  ;Implement: 3 equidistant sprites, moving outward, direction set via data
    ;Fire repeatedly, and quickly, with slightly changing data values
  LD H,D
  LD L,E
  DEC (HL)
  JP z,_Danmaku_Die
  LD B,A
  PUSH AF
    LD C,256/6    ;Rotate to this sprite
    LD H,D
    CALL Multiply
    LD D,H
    LD A,C
    LD HL,2
    ADD HL,DE
    ADD (HL)
    LD C,A    ;Angle
    DEC HL
    LD B,(HL) ;Speed
  POP AF
  RLCA
  PUSH BC
    PUSH AF
      LD H,>SinCosTable ;Sin
      LD L,C
      LD C,(HL)
      LD A,C
      XOR B
      LD L,A    ;Calculate resultant sign
      BIT 7,B   ;Unnegate everything
      JR z,+
      LD A,B
      CPL
      INC A
      LD B,A
+
      BIT 7,C
      JR z,+
      LD A,C
      CPL
      INC A
      LD C,A
+
      LD H,D
      CALL Multiply
      LD D,H
      BIT 7,L   ;Set sign of result
      JR z,+
      LD A,C
      CPL
      LD C,A
      LD A,B
      CPL
      LD B,A
      INC BC
+
      SRA B
      RR C
      SRA B
      RR C
      LD L,16 ;Go to this sprite's Y fractional
    POP AF
    ADD L
    LD L,A
    LD H,0
    ADD HL,DE
    LD A,(HL)
    ADD C
    LDI (HL),A
    LD A,0
    ADC B
  POP BC
  PUSH AF   ;Y get!
    PUSH HL
      LD A,C
      ADD $40 ;Cos
      LD H,>SinCosTable
      LD L,A
      LD C,(HL)
      LD A,C
      XOR B
      LD L,A    ;Calculate resultant sign
      BIT 7,B   ;Unnegate everything
      JR z,+
      LD A,B
      CPL
      INC A
      LD B,A
+
      BIT 7,C
      JR z,+
      LD A,C
      CPL
      INC A
      LD C,A
+
      LD H,D
      CALL Multiply
      LD D,H
      BIT 7,L   ;Set sign of result
      JR z,+
      LD A,C
      CPL
      LD C,A
      LD A,B
      CPL
      LD B,A
      INC BC
+
      SRA B
      RR C
      SRA B
      RR C
    POP HL
    LD A,(HL)
    ADD C
    LD (HL),A
    LD A,0
    ADC B
    LD C,A  ;X get!
  POP AF
  LD B,A
  RET

;Data option 0: Lifetime
;Data option 1: Speed
;Data option 2: Base angle
;Data option 3: Turn speed
_DanmakuFunction_MarisaDanmaku:
  ;Undirected Star-like
  ;6 streams spiraling outwards, all equidistant
  ;Implement: 6 equidistant sprites, moving outward, curving
    ;Fire repeatedly, precisely
;  LD HL,0
;  ADD HL,DE
;  DEC (HL)
;  JP z,_Danmaku_Die
;  ;Multiply sprite no. by constant angle
;  PUSH AF
;    LD B,A
;    LD C,256/6
;    LD H,D
;    CALL Multiply
;    LD D,H
;    ;Current angle is base angle
;    ;Add sprite no. angle adjustment to current angle
;    LD HL,2
;    ADD HL,DE
;    LD A,(HL)
;    ADD C
;  ;If sprite == 0:
;  POP AF
;  OR A
;  JR nz,+
;  ;Add constant to base angle
;  LDI A,(HL)     ;HL at correct location
;  ADD (HL)
;  DEC HL
;  LD (HL),A
;+
;  ;Create vector from current angle and speed
;  LD HL,1
;  ADD HL,DE
;  LD B,(HL)
;  PUSH BC   ;Speed, angle
;    LD H,>SinCosTable   ;Get sin
;    LD L,C
;    LD C,(HL)
;    LD H,D
;    CALL Multiply
;    LD D,H
;    ;Adjusting for decimal point:
;    ;00.000000
;    ;0000.0000
;    ;000000.00 00000000
;    SRA B
;    SRA B
;    LD A,B
;  POP BC
;  PUSH AF   ;Y get!
;    LD A,C
;    ADD $40     ;Get cos
;    LD H,>SinCosTable
;    LD L,A
;    LD C,(HL)
;    LD H,D
;    CALL Multiply
;    LD D,H
;    SRA B
;    SRA B
;    LD C,B  ;X get!
;  POP AF
;  LD B,A
;  ;Return current direction vector
;  RET

;Data option 0: Lifetime
;Data option 1: Speed
_DanmakuFunction_AliceDanmaku:
  ;Directed orblike
  ;Two circles, and 3 swirling lines outward
  ;Implement: Lines are each fired straight, but direction changes for each fire
  ;Circles are circles
  ;If necessary, remove the swirls
  LD HL,0
  ADD HL,DE
  DEC (HL)
  JP z,_Danmaku_Die
  DEC A
  JR nz,+
  LD BC,$0100
  RET
+
  DEC A
  JR nz,+
  LD BC,$0101
  RET
+
  DEC A
  JR nz,+
  LD BC,$01FF
  RET
+
  DEC A
  JR nz,+
  LD BC,$FE00
  RET
+
  DEC A
  JR nz,+
  LD BC,$FF01
  RET
+
  LD BC,$FFFF
  RET

;Data option 0: X change
;Data option 1: Y change
;Data option 2: Lifetime
_DanmakuFunction_StraightShot:
  LD HL,0
  ADD HL,DE
  LD C,(HL)
  INC HL
  LD B,(HL)
  INC HL
  DEC (HL)
  RET nz

_Danmaku_Die:
  ;Die
  CALL MemFree  ;Free Movement Data
  POP HL    ;Return
  POP DE    ;Actor Data
  POP HL    ;Parent AF
  LD HL,_AnimRAM
  ADD HL,DE
  LD B,D
  LD C,E
  LD D,H
  LD E,L
  CALL MemFree
  LD D,B
  LD E,C
  JP Actor_Delete

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
    ;2 bytes: Template pointer
    ;1 byte:  Directed Value    (0 for undirected, tile base for directed)
    ;2 bytes: Movement Function
    ;4 bytes: Movement Data
    ;2 bytes: Hitbox pointer
_Patterns:
;Test pattern
 .dw _YinYang
 .db 0
 .dw _DanmakuFunction_StraightShot
 .db   0,  2,  0,  0
 .dw _DanmakuHitboxes
;Reimu's accompaying options
 .dw _ReimuOptions
 .db 0
 .dw _DanmakuFunction_ReimuOptions
 .db  21,  0,  0,  0
 .dw _DanmakuHitboxes
;Marisa's "Astral Sign: Milky Way"
 .dw _StarType
 .db 0
 .dw _DanmakuFunction_MarisaDanmaku
 .db   0,  4,  0,  3
 .dw _DanmakuHitboxes
;Some spell card I made up for Reimu
 .dw _Ofuda
 .db $43
 .dw _DanmakuFunction_ReimuDanmaku
 .db   0,  4,  0,  0
 .dw _DanmakuHitboxes
;Alice's "Doll Mystery"
 .dw _DirectedOrb
 .db $46
 .dw _DanmakuFunction_ReimuDanmaku
 .db 120, 20,  0,  0
 .dw _DanmakuHitboxes
;Hitboxes
_DanmakuHitboxes:
 .db 1
 .dw $0000,$0000,$0202
 .dw _DanmakuHitboxAction
_DanmakuHitboxAction:
  RET

.ENDS
