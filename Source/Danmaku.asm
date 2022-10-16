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
    LD HL,_SprCount
    ADD HL,DE
    LD (HL),3   ;Hardcoded 3 danmaku
    LD HL,_FracMove
    ADD HL,DE
    XOR A
    LDI (HL),A
    LDI (HL),A
    LDI (HL),A    ;Don't use hitboxes (since updating them is a hassle)
    INC HL
    LDI (HL),A      ;Invisible, at least for now
    INC HL
  POP AF
  ;Check type data
  ADD A     ;Entries 6 in size
  LD C,A
  ADD A
  ADD C
  ADD <DanmakuList
  LD C,A
  LD A,0
  ADC >DanmakuList
  LD B,A
  LD A,(BC)     ;Tile
  INC BC
  LDI (HL),A
  LD A,(BC)     ;Lifetime
  INC BC
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
  LD HL,_MoveData
  ADD HL,DE
  XOR A
  LDI (HL),A    ;Move data
  LDI (HL),A
  LD A,(BC)     ;Move function
  INC BC
  LDI (HL),A
  LD A,(BC)
  INC BC
  LDI (HL),A
  LD HL,_AnimPtr
  ADD HL,DE
  LD A,(BC)
  LDI (HL),A
  INC BC
  LD A,(BC)
  LDI (HL),A
  LD (HL),0     ;Anim counter
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
  ;Register position for this frame
  LD HL,_RelData
  ADD HL,DE
  LD A,3
-
  PUSH AF
    LDI A,(HL)    ;Y
    LD C,A
    LDI A,(HL)    ;X
    LD B,A
    INC HL
    INC HL
    PUSH HL
      LD HL,_MasterX+1
      ADD HL,DE
      LDI A,(HL)
      ADD B
      LD B,A
      INC HL
      LD A,(HL)
      ADD C
      LD C,A
      CALL HitboxHitAdd
    POP HL
  POP AF
  DEC A
  JR nz,-
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
    LD HL,_FracMove
    ADD HL,DE
    PUSH HL
      LD HL,_RelData
      ADD HL,DE
    POP DE
    ;BC=Delta (X,Y)
    ;Apply delta
    ;Starting with Y
    ;Integer half
    BIT 7,C
    JR nz,+
    ;Positive movement: 0 or 1?
    INC (HL)
    INC (HL)
+   ;Negative movement: -1 or -2?
    DEC (HL)
    BIT 6,C
    JR nz,+
    DEC (HL)    ;Definitely -2 or 0
+
    ;Fractional half
    LD A,$3F
    AND C
    RLCA
    RLCA
    LD C,A
    LD A,(DE)
    ADD C
    LD (DE),A
    JR nc,+
    INC (HL)
+
    LDI A,(HL)
    LD C,A
    INC DE
    ;Now for X
    ;Integer half
    BIT 7,B
    JR nz,+
    ;Positive movement: 0 or 1?
    INC (HL)
    INC (HL)
+   ;Negative movement: -1 or -2?
    DEC (HL)
    BIT 6,B
    JR nz,+
    DEC (HL)    ;Definitely -2 or 0
+
    ;Fractional half
    LD A,$3F
    AND B
    RLCA
    RLCA
    LD B,A
    LD A,(DE)
    ADD B
    LD (DE),A
    JR nc,+
    INC (HL)
+
    LD A,(HL)
    LD B,A
    LD D,2      ;Remaining danmaku count
    ;Do the Minsky Circle Algorithm for the rest
    ;More iterations is more accurate- within the bounds of fixed point precision
    ;Subsequent delta
    ;BC=Position (X,Y)
--
    INC HL
    INC HL
    INC HL
    LD E,8    ;For more accuracy, shift more and double 
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
    DEC E
    JR nz,-
    ;Apply
    LD A,C
    LDI (HL),A
    LD (HL),B
    DEC D
    JR nz,--
  POP DE
  ;Animations
  LD HL,_AnimWait
  ADD HL,DE
  INC (HL)
  LDD A,(HL)
  LD B,A
--
  LDD A,(HL)
  LD L,(HL)
  LD H,A
-
  LD A,(HL)
  OR A
  JR z,++
  CP B
  JR z,+
  LD A,B
  SUB (HL)
  JP c,Danmaku_Draw
  LD B,A
  INC HL
  INC HL
  JR -
+   ;This is the new animation
  LD B,(HL)
  INC HL
  LD C,(HL)
  LD HL,_RelData+2
  ADD HL,DE
-
  ;Generic sprite
  LD A,$FC
  AND (HL)
  LD (HL),A
  RRCA
  RRCA
  RR B
  RR C
  RR C
  RLA
  RL C
  RLA
  RRC C
  OR (HL)
  LDI (HL),A
  LD A,%10011111
  AND (HL)
  RR C
  JR nc,+
  OR %01100000
+
  LDI (HL),A
  INC HL
  INC HL
  LD A,%00001111
  AND L
  XOR %00001110
  JR nz,-
  JP Danmaku_Draw
++  ;End of animations; start at the beginning
  LD HL,_AnimPtr+1
  ADD HL,DE
  JR --


;Danmaku Definitions

DanmakuList:
;1 byte:  Base tile
;1 byte:  Lifetime (frames)
;2 bytes: Movement function
;2 bytes: Anim list

;Spike
.db $74,%00100000
.dw DanmakuMove_Spike
.dw DanmakuAnim_Spike
;Clover
.db $68,%00101001
.dw DanmakuMove_Clover
.dw DanmakuAnim_Clover
;Triangle
.db $78,%01011011
.dw DanmakuMove_Triangle
.dw DanmakuAnim_Triangle
;Guard
.db $6C,%01111001
.dw DanmakuMove_Guard
.dw DanmakuAnim_Guard
;Windmill
.db $70,%00111001
.dw DanmakuMove_Windmill
.dw DanmakuAnim_Windmill

;Scythe
.db $68,%00111100
.dw DanmakuMove_Scythe
.dw DanmakuAnim_Scythe
;Wave
.db $6C,%01001001
.dw DanmakuMove_Wave
.dw DanmakuAnim_Wave
;Curtain
.db $78,%00010101
.dw DanmakuMove_Curtain
.dw DanmakuAnim_Curtain
;Wiggle Snake Down
.db $6C,%00111101
.dw DanmakuMove_WiggleSnakeDown
.dw DanmakuAnim_WiggleSnakeDown
;Wiggle Snake Up
.db $6C,%00111101
.dw DanmakuMove_WiggleSnakeUp
.dw DanmakuAnim_WiggleSnakeUp

;Undercut (an Alice special)
.db $6C,%00111100
.dw DanmakuMove_Scythe
.dw DanmakuAnim_Undercut

;Danmaku Actions
    ;DE=Move Data
    ;A =Frames remaining
;Return
    ;B=Move X (2.6)
    ;C=Move Y (2.6)
    ;DE=Move Data
    ;Move data is private to each Danmaku; edit it as you please

;Idea for saving precision: move twice as much every other frame

;Danmaku Animations
;Array of:
    ;%TTTTTTTD
    ; |||||||+--- Direction for sprite 3 (hi)
    ; ++++++++--- Time when this frame of animation begins
    ;%33222111
    ;      +++--- Direction for sprite 1
    ;   +++--- Direction for sprite 2
    ; ++--- Direction for sprite 3 (lo)
;Directions:
    ;0: Right
    ;1: Right-down
    ;2: Down
    ;3: Left-down
    ;4: Left
    ;5: Left-up
    ;6: Up
    ;7: Right-up

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
  LD BC,%0000000010100000
  CP 90-15
  RET nc
  LD BC,%0100000001100000
  CP 75-25
  RET nc
  LD BC,%1000000000000000
  CP 50-25
  RET nc
  LD BC,%0100000010100000
  RET

DanmakuMove_Windmill:
  LD BC,%0011101101100001
  CP 24+8
  RET nc
  LD BC,%0001101010111000
  CP 12+8
  RET nc
  LD BC,%0011000011000010
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
  LD DE,$B05F
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

.SECTION "Danmaku Anims" FREE


DanmakuAnim_Clover:
DanmakuAnim_Scythe:
DanmakuAnim_Windmill:
;Fast spin
.db %00000010,%00000000
.db %00000010,%01001001
.db %00000010,%10010010
.db %00000010,%11011011
.db %00000011,%00100100
.db %00000011,%01101101
.db %00000011,%10110110
.db %00000011,%11111111
.db 0

DanmakuAnim_Guard:
DanmakuAnim_Wave:
DanmakuAnim_WiggleSnakeDown:
DanmakuAnim_WiggleSnakeUp:
DanmakuAnim_Undercut:
;Slow pulse (2,3,0,1,0,3)
.db %00001000,%10010010
.db %00001000,%11011011
.db %00001000,%00000000
.db %00001000,%01001001
.db %00001000,%00000000
.db %00001000,%11011011
.db 0

;These are directional
DanmakuAnim_Triangle:
.db %00000010,%01011110 ;up,         left-down,  right-down
.db %00001111,%00111001 ;right-down, right-up,   left
.db %00011001,%11001100 ;left,       right-down, right-up
.db %00011000,%01100111 ;right-up,   left,       right-down
.db $FF

DanmakuAnim_Spike:
DanmakuAnim_Curtain:
;Straight out/down
.db %00000001,%01111010
.db $FF

.ENDS
