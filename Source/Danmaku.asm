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
  LD HL,_Lifetime
  ADD HL,DE
  DEC (HL)
  JR nz,+
  ;Die
  CALL Actor_Hide
  LD H,D
  LD L,E
  CALL MemFree
  JP EndTask
+ ;Collision

  ;Do collision here
  ;Each of the three is in their own position
  ;For each danmaku
    ;Check against Marisa position
    ;If hit
        ;If hat
            ;Remove hat
        ;Else
            ;Push Marisa

  ;Movement...
  ;...which is updating the sprite visual block
  ;Calculate one the hard way...
  ;First delta
  PUSH DE
    LD HL,_Lifetime
    ADD HL,DE
    LDI A,(HL)
    PUSH HL
      PUSH AF
        LDI A,(HL)
        LD E,A
        LDI A,(HL)
        LD D,A
        LDI A,(HL)
        LD H,(HL)
        LD L,A
      POP AF
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
         ;|+++++++--- Lifetime (frames)
         ;+--- Animation Type
                ;0 = Undirected
                ;1 = Spinny
;2 bytes: Movement function

;Spike
.db $74,%00100000
.dw DanmakuMove_Spike
;Clover
.db $68,%10101001
.dw DanmakuMove_Clover
;Triangle
.db $78,%01011011
.dw DanmakuMove_Triangle
;Guard
.db $6C,%11111001
.dw DanmakuMove_Guard
;Windmill
.db $70,%10111001
.dw DanmakuMove_Windmill

;Scythe
.db $68,%10111100
.dw DanmakuMove_Scythe
;Wave
.db $6C,%11001001
.dw DanmakuMove_Wave
;Curtain
.db $78,%00010101
.dw DanmakuMove_Curtain
;Wiggle Snake Down
.db $6C,%10111101
.dw DanmakuMove_WiggleSnakeDown
;Wiggle Snake Up
.db $6C,%10111101
.dw DanmakuMove_WiggleSnakeUp

;Danmaku Actions
    ;DE=Move Data
    ;A =Frames remaining
;Return
    ;B=Move X (2.6)
    ;C=Move Y (2.6)
    ;DE=Move Data
    ;Move data is private to each Danmaku; edit it as you please

;Idea for saving precision: move twice as much every other frame

DanmakuMove_Curtain:
DanmakuMove_Spike:
  LD BC,$0078
  RET

DanmakuMove_Guard:
  LD BC,$0000
  CP 120-15
  RET c
  LD C,$90
  RET

DanmakuMove_Triangle:
  LD BC,%0000000011010101
  CP 90-15
  RET nc
  LD BC,%0010110010110010
  CP 75-25
  RET nc
  LD BC,%1010011000000000
  CP 50-25
  RET nc
  LD BC,%1101100011111000
  RET

DanmakuMove_Windmill:
  LD BC,%0001101101010001
  CP 24+8
  RET nc
  LD BC,%0001101010111000
  CP 12+8
  RET nc
  LD BC,%1100001000110000
  RET

DanmakuMove_WiggleSnakeDown:
  ;Like the other one, but negative
  CALL DanmakuMove_WiggleSnakeUp
  LD A,C
  CPL
  LD C,A
  INC C
  RET

DanmakuMove_WiggleSnakeUp:
  CP %00111100
  JR nz,+
  ;Start
  LD DE,$3000
+
  LD C,$20
  LD A,D
  BIT 0,E
  JR nz,+
  SUB $04
  .db $21   ;Opcode for LD HL,nn ~ Effectively skips next two bytes (aka the ADD $04)
+
  ADD $04
  LD D,A
  LD B,A
  CP $20
  JR nc,+
  BIT 7,A
  JR nz,+
  ;Hit max angle
  INC E
  RET
+
  CP $E0
  RET nc
  BIT 7,A
  RET z
  ;Hit min angle
  DEC E
  RET

DanmakuMove_Clover:
  CP %00101000
  JR nz,+
  ;Start
  LD DE,$C000   ;Initial position on circle (5.3)
+   ;Minsky move
  LD A,E
  LD B,A    ;(5.3) to (2.6)
  SRA A
  SRA A
  SRA A
  ADD D
  LD D,A
  CPL
  INC A
  LD C,A    ;(5.3) to (2.6)
  SRA A
  SRA A
  SRA A
  ADD E
  LD E,A
  RET

DanmakuMove_Wave:
  CP %00010100
  JR nz,+
  ;Start
  LD DE,$B050
+
  LD C,E
  LD A,$04
  ADD D
  LD D,A
  LD B,A
  RET

DanmakuMove_Scythe:
  LD BC,%0000000011100111
  CP 59-19
  RET nc
  CP 59-20
  JR z,++
  CP 25
  JR c,+
  .db $21   ;Opcode for LD HL,nn ~ Effectively skips next two bytes (aka the LD DE). The third byte becomes a LD A,(BC)
++
  LD DE,%0000101000111110   ;Initial position on first circle (5.3)
  ;Minsky left
  LD A,E
  CPL
  INC A
  LD B,A    ;(5.3) to (2.6)
  SRA A
  SRA A
  SRA A
  ADD D
  LD D,A
  LD C,A    ;(5.3) to (2.6)
  SRA A
  SRA A
  SRA A
  ADD E
  LD E,A
  RET
+
  JR nz,++
  LD DE,%1010010011101000   ;Initial position on second circle (5.3)
++
  ;Minsky right (the broader one)
  LD A,E
  LD B,A    ;(5.3) to (2.6)
  SRA A
  SRA A
  SRA A
  ADD D
  LD D,A
  CPL
  INC A
  LD C,A    ;(5.3) to (2.6)
  SRA A
  SRA A
  SRA A
  ADD E
  LD E,A
  RET

.ENDS
