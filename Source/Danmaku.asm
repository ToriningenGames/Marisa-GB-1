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
    LD HL,_FracMove
    ADD HL,DE
    LDI (HL),A
    LDI (HL),A
    LDI (HL),A    ;Don't use hitboxes (since updating them is a hassle)
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
  AND $7F
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
  LD (HL),$FF   ;Spinny
  AND $80
  JR nz,+
  LD (HL),A     ;Undirected
+
  INC HL
  INC HL
  XOR A
  LDI (HL),A    ;Move data
  LDI (HL),A
  INC BC
  LD A,(BC)     ;Move function
  INC BC
  LDI (HL),A
  LD A,(BC)
  LDI (HL),A
  CALL Actor_HighPriority
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
  JR nz,+
  ;Die
  PUSH DE
    INC HL
    LDI A,(HL)    ;Move Data
    LD E,A
    LDI A,(HL)
    LD D,A
    LDI A,(HL)    ;Move Func
    LD H,(HL)
    LD L,A
    LD A,D        ;If the function has data to free, D is nonzero
    RST $30       ;Otherwise, finals don't matter
  POP DE
  JP Actor_Delete
+ ;Collision

  ;Do collision here

  ;Movement...
  ;...which is updating the sprite visual block
  ;Calculate one the hard way...
  ;First delta
  LD HL,_MoveData
  ADD HL,DE
  PUSH DE
    PUSH HL
      LDI A,(HL)
      LD E,A
      LDI A,(HL)
      LD D,A
      LDI A,(HL)
      LD H,(HL)
      LD L,A
      XOR A
      RST $30
    POP HL
    LD A,E
    LDI (HL),A
    LD (HL),D
  POP DE
  PUSH DE
    LD HL,_RelData
    ADD HL,DE
    PUSH HL
      LD HL,_FracMove
      ADD HL,DE
    POP DE
    ;BC=Delta (X,Y)
    ;Apply delta
    LD A,(HL)
    ADD C
    LD C,A
    AND $3F
    LDI (HL),A
    SRA C
    SRA C
    SRA C
    SRA C
    SRA C
    SRA C
    LD A,(DE)
    ADD C
    LD (DE),A
    LD C,A
    INC DE
    LD A,(HL)
    ADD B
    LD B,A
    AND $3F
    LD (HL),A
    SRA B
    SRA B
    SRA B
    SRA B
    SRA B
    SRA B
    LD A,(DE)
    ADD B
    LD (DE),A
    LD B,A
    LD H,2      ;Remaining danmaku count
    ;Do the Minsky Circle Algorithm for the rest
    ;More iterations is more accurate- within the bounds of fixed point precision
    ;Subsequent delta
    ;BC=Position (X,Y)
--
    INC DE
    INC DE
    INC DE
    LD L,8    ;For more accuracy, shift more and double 
    LD A,C
-
    SRA A
    SRA A
    ADD B
    LD B,A
    SRA A
    SRA A
    CPL
    INC A
    ADD C
    LD C,A
    DEC L
    JR nz,-
    ;Apply
    LD A,C
    LD (DE),A
    INC DE
    LD A,B
    LD (DE),A
    DEC H
    JR nz,--
  POP DE
  LD HL,_IsDirected
  ADD HL,DE
  LD A,(HL)
  OR A
  JP z,++
  ;Spinny danmaku. Spin at a reasonable rate
  LD HL,_AnimWait
  ADD HL,DE
  LD A,(HL)
  DEC A
  JR nz,++
  LD (HL),SpinSpeed
  LD HL,_RelData+2
  ADD HL,DE
  LD B,3    ;Danmaku count
-
  LD A,(HL)
  AND %11111100
  LD C,A
  LD A,(HL)
  INC A
  AND %00000011
  OR C
  LDI (HL),A
  ;Mirroring changes once a tile loop
  AND %00000011
  JR nz,+
  LD A,%01100000
  XOR (HL)
  LD (HL),A
+
  INC HL
  INC HL
  INC HL
  DEC B
  JR nz,-
++
  ;Undirected danmaku. Do nothing
  JP Danmaku_Draw


;Danmaku Definitions

DanmakuList:
;1 byte:  Base tile
;1 byte: %TLLLLLLL
         ;|+++++++--- Lifetime (frames/anim cycle)
         ;+--- Animation Type
                ;0 = Undirected
                ;1 = Spinny
;2 bytes: Movement function
;Reimu orbs
.db $68,%10000000
.dw DanmakuMove_Orbs
;Reimu ofuda
.db $79,%00000000
.dw DanmakuMove_Ofuda

;Danmaku Actions
    ;DE=Move Data
    ;A!=0 if being destroyed
;Return
    ;B=Move X (2.6)
    ;C=Move Y (2.6)
    ;DE=Move Data
    ;Move data is private to each Danmaku; edit it as you please
DanmakuMove_Orbs:
;2 phases:
    ;Extend
    ;Speen
  OR A
  LD H,D
  LD L,E
  JP nz,MemFree
  LD A,D
  OR E
  JR nz,+
;Init
  CALL MemAlloc
  LD A,$10
  LD H,D
  LD L,E
  LDI (HL),A
  XOR A
  LDI (HL),A
  LD (HL),$C0
+
  LD H,D
  LD L,E
  DEC (HL)
  LD BC,$00F0
  RET nz    ;Extend phase
;Spin phase
  INC (HL)
  INC HL
  LDI A,(HL)    ;Y (4.4)
  LD C,A
  LD B,(HL)     ;X (4.4)
  SRA A
  SRA A
  SRA A
  ADD B
  LD B,A
  SRA A
  SRA A
  SRA A
  CPL
  INC A
  ADD C
  LD C,A
  LD (HL),B
  DEC HL
  LDI (HL),A
  RET

DanmakuMove_Ofuda:
  LD A,D
  OR E
  JR nz,+
  ;First run; "correct" the heading data
  INC D
  LD HL,SP+$04
  LDI A,(HL)
  LD D,(HL)
  LD E,A
  LD HL,_RelData+2
  ADD HL,DE
  INC (HL)      ;First sprite: face down
  INC (HL)
  INC HL
  INC HL
  INC HL        ;Second sprite: go up-right
  INC HL
  INC (HL)
  INC HL
  LD A,%01000000
  OR (HL)
  LDI (HL),A
  INC HL        ;Third sprite: go up-left
  INC HL
  INC (HL)
  INC HL
  LD A,%01100000
  OR (HL)
  LD (HL),A
+
  LD BC,$0080
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

;Unit speed 40/60

.ENDS
