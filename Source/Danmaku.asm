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
    ;DE = Initial placement

;Lifetime
;Movement function
;Hardcode 3
;How hit detect?
    ;Maintain distance to player, trigger when value gets too low
    ;This requires updating from the danmaku and looking at the player delta
;Can't use existing actor infrastructure due to the anim and collision reqs

.include "ActorData.asm"

.SECTION "Danmaku" FREE

.DEFINE SpinSpeed 2

NewDanmaku:
;A =Type
;DE=Source Actor
  PUSH AF
  PUSH DE
    CALL MemAlloc   ;Basic Actor
  POP DE
  POP AF
  ;Type needs to provide
    ;Movement
    ;Visual
    ;Anim type
  ;Do the standard Actor fills (but no Collision boxes)
    ;Load Anim wait (with SpinSpeed)
    ;Empty Hitbox data
    ;Clear Visibility value
    ;Fill AI movement
    ;Use sane hat val
    ;Init anim relation data
  ;Copy starting location from source actor THIS FRAME!
  ;Fill in type correctly based on whether we be spinnin' or directin'
  ;Fill _Lifetime
;Frame
  RST $00
  ;Age
  LD HL,_Lifetime
  ADD HL,DE
  DEC (HL)
  JP z,Actor_Delete
  ;Collision
  
  ;Do collision here
  
  ;Movement...
  ;...which is updating the sprite visual block
  ;Calculate one the hard way...
  ;First delta
  LD HL,_AIMovement
  ADD HL,DE
  PUSH DE
    RST $30
    LD HL,_RelData
    ADD HL,DE
    ;BC=Delta (X,Y)
    LD D,H
    LD E,L
    LD H,B
    LD L,C
    LD B,3      ;No. of danmaku
    JR +
    ;...and do the Minsky Circle Algorithm for the rest
    ;More iterations is more accurate- within the bounds of fixed point precision
    ;Subsequent delta
    ;HL=Delta temp (X,Y)
--
    LD C,8    ;For more accuracy, shift more and double C
    LD A,L
-
    RRCA
    RRCA
    AND $3F
    ADD H
    LD H,A
    RRCA
    RRCA
    AND $3F
    CPL
    ADC L
    LD L,A
    DEC C
    JR nz,-
+
    ;Apply delta
    ;DE=Rel Data for this danmaku
    LD A,L
    ADD -4    ;Center of tile, visually
    LD (DE),A
    INC DE
    LD A,H
    ADD -4    ;Ditto
    LD (DE),A
    INC DE
    ;If directed danmaku, tile/attribute is dependent on movement delta
    ;Check for direction
    ;Preserve BC,DE,HL
    ;...but the value on stack is needed?
    PUSH BC
    PUSH HL
    PUSH DE
      LD HL,SP-6
      LDI A,(HL)
      LD D,(HL)
      LD E,A
      LD HL,_IsDirected
      ADD HL,DE
      LD A,(HL)
      OR A
      JR z,+
      INC A
      JR z,+++
      DEC A
      ;Directed. Adjust heading based on delta
      POP HL    ;Current danmaku under consideration
      PUSH HL
      LD (HL),A
      ;Tile. Dependent on whether movement is predominantly vert or hort, or neither
      ;Diag if 2*H>V && 2*V>H
      ;Also works comparing against the linear equations defining the regions
      LD A,B
      RRA
      CP C
      JR nc,++  ;Y <= X * 0.5
      INC (HL)  ;Diagonal or vertical
++
      LD B,A
      ADD A
      CP C
      JR nc,++  ;X * 2 > Y
      INC (HL)  ;Vertical
++
      ;Attribute. Choose correctly for the quadrant movement is in/towards
      ;Pos Y -> no Y flip
      ;Pos X -> no X flip
      INC HL
      LD A,%10011111
      AND (HL)
      BIT 7,B
      JR z,++
      OR %00100000
++
      BIT 7,C
      JR z,++
      OR %01000000
++
      LD (HL),A
      JP +

+++     ;Spinny danmaku
      ;Spinning looks better done every few frames (avoids too much blurring)
      LD HL,_AnimWait
      ADD HL,DE
      DEC (HL)
      JR nz,+
      LD (HL),SpinSpeed
      POP HL    ;Danmaku under consideration
      PUSH HL
      ;4 tiles' spin, whose values are aligned
      LD A,(HL)
      LD B,A
      AND %11111100
      LD C,A
      LD A,B
      INC A
      AND %00000011
      OR C
      LDI (HL),A
      ;Mirroring changes once a tile loop
      AND %00000011
      JR z,+
      LD A,%01100000
      XOR (HL)
      LD (HL),A

+       ;Undirected danmaku; do nothing
    POP DE
    POP HL
    POP BC
    INC DE      ;Point to next danmaku
    INC DE
    DEC B
    JR nz,--
  POP DE
  ;Visuals
  JP Danmaku_Draw

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
  DEC A     ;Only tick life on danmaku 1
  JR nz,+
  LD H,D
  LD L,E
  DEC (HL)
  JP z,_Danmaku_Die
+
  INC A
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
 .db  20, 20,  0,  0
 .dw _DanmakuHitboxes
;Hitboxes
_DanmakuHitboxes:
 .db 1
 .dw $0000,$0000,$0202
 .dw _DanmakuHitboxAction
_DanmakuHitboxAction:
  RET

.ENDS
