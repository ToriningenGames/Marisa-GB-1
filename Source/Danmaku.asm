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

;Animation speed for spinning
;Also a multiplier for lifetime (to make maximum time longer)
.DEFINE SpinSpeed 3

NewDanmaku:
;A= Type
;D= Starting X
;E= Starting Y
  PUSH AF
    PUSH DE
      CALL MemAlloc
      LD H,D
      LD L,E
    POP DE
    PUSH HL
      LD A,$05
      LDI (HL),A    ;Sprite pointer
      LDI (HL),A
      LDI (HL),A    ;Master X
      LD (HL),D
      INC HL
      LDI (HL),A    ;Master Y
      LD (HL),E
    POP DE
    LD HL,_AnimPtr
    ADD HL,DE
    XOR A
    LDI (HL),A  ;Dummy ROM AnimPtr
    LDI (HL),A
    LD (HL),SpinSpeed   ;AnimWait (for spinny)
    LD HL,_SprCount
    ADD HL,DE
    LD (HL),3   ;Hardcoded 3 danmaku
    LD HL,_Hitbox
    ADD HL,DE
    LD (HL),<DanmakuHitboxes    ;Don't use hitboxes (since updating them is a hassle)
    INC HL
    LD (HL),>DanmakuHitboxes
    INC HL
    LDI (HL),A      ;Invisible, at least for now
    INC HL
  POP AF
  ;Check type data
  ADD A     ;Entries 4 in size
  ADD A
  ADD <DanmakuList
  LD C,A
  LD A,0
  ADC >DanmakuList
  LD B,A
  LD A,(BC)     ;Tile
  INC BC
  LDI (HL),A
  LD A,(BC)     ;Lifetime
  AND $3F
  LDD (HL),A
  LD A,(HL)
  ;Initialize Relational Data (and Hat Val)
  LD HL,_HatVal
  ADD HL,DE
  PUSH DE
    LD D,A
    XOR A
    LDI (HL),A  ;Hatval
    LDI (HL),A  ;One
    LDI (HL),A
    LD (HL),D
    INC HL
    LDI (HL),A
    LDI (HL),A  ;Two
    LDI (HL),A
    LD (HL),D
    INC HL
    LDI (HL),A
    LDI (HL),A  ;Three
    LDI (HL),A
    LD (HL),D
    INC HL
    LDI (HL),A
  POP DE
  LD HL,_IsDirected
  ADD HL,DE
  LD A,(BC)     ;Check for direction type
  AND $C0
  JR nz,+
  LD (HL),0     ;Undirected
+
  XOR $C0
  JR z,+
  LD (HL),$FF   ;Spinny
+
  LD HL,_AIMovement
  ADD HL,DE
  INC BC
  LD A,(BC)
  INC BC
  LDI (HL),A
  LD A,(BC)
  LDI (HL),A
;Frame
  RST $00
  ;Age
  LD HL,_AnimWait
  ADD HL,DE
  DEC (HL)
  JR nz,+
  LD (HL),SpinSpeed
  LD HL,_Lifetime
  ADD HL,DE
  DEC (HL)
  JP z,Actor_Delete
+ ;Collision
  
  ;Do collision here
  
  ;Movement...
  ;...which is updating the sprite visual block
  ;Calculate one the hard way...
  ;First delta
  LD HL,_AIMovement
  ADD HL,DE
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  PUSH DE
    RST $30
  POP DE
  PUSH DE
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
      LD A,(HL)
      DEC A
      JR nz,+
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

;Danmaku Definitions

DanmakuList:
;1 byte:  Base tile
;1 byte: %TTLLLLLL
         ;||++++++--- Lifetime (frames/anim cycle)
         ;++--- Animation Type
                ;0 = Undirected
                ;1 = Spinny
                ;3 = Directed
;2 bytes: Movement function
;Reimu orbs
.db $68,%01000000
.dw DanmakuMove_Orbs

;Danmaku Actions
DanmakuMove_Orbs:
  LD BC,0
  RET


;Deploys options, sits there
;Data option 0: Distance to move, x2
_DanmakuFunction_ReimuOptions:

_DanmakuFunction_ReimuDanmaku:
  ;Directed ofuda
  ;3 streams, laserlike, waving back and forth
  ;Implement: 3 equidistant sprites, moving outward, direction set via data
    ;Fire repeatedly, and quickly, with slightly changing data values

_DanmakuFunction_MarisaDanmaku:
  ;Undirected Star-like
  ;6 streams spiraling outwards, all equidistant
  ;Implement: 6 equidistant sprites, moving outward, curving

_DanmakuFunction_AliceDanmaku:
  ;Directed orblike
  ;Two circles, and 3 swirling lines outward
  ;Implement: Lines are each fired straight, but direction changes for each fire
  ;Circles are circles
  ;If necessary, remove the swirls

_DanmakuFunction_StraightShot:


.ENDS
