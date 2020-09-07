;Actors
;Common functions for "actors": things with sprites that move, and stuff.

.INCLUDE "ActorData.asm"

;Animation format:
    ;Two parts: Base and Active
    ;Base determines the default state to display when animation is off
    ;Active determines the actions to go through when animation is on
;Base part:
    ;24 bytes: Sprite data state
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
                ;Value=Lowest bit decides targets, high two bits toggle if set (XOR)
                ;Bit 0: Targets are bit6 and bit5 of Attribute
                ;Bit 1: Targets are bit7 and bit4 of Attribute
        ;If target is loop, two bytes for loop destination address follow
;Hitbox data format:
;All actor hitboxes are squares
    ;1 byte: hitbox count
    ;2 bytes: X position (8.8)
    ;2 bytes: Y position (8.8)
    ;2 bytes: radius (8.8)
    ;2 bytes: Action. Signature:
        ;BC->Owning actor
        ;DE->Touching actor

;STATS:
    ;W/ Minimal game items (only actor stuff, tasks, music, dummy hat):
    ;Tasks allow 29 actors simultaneously. Having this many sprites on screen
        ;results in actors showing every 5th frame, giving bad flickering.
    ;Memory allocation was at 71%, but considering only 3/4 was used for draw,
        ;actors ought to have spare for logic
    ;The actor array is in no danger of overflowing; there are 13 free slots at
        ;this point. So if one task handled multiple actors...
    ;The GB CPU is in danger of overflowing, though. Even if it is only Marisa
        ;and 28 dummy actors, the GB sees ~85-90% CPU usage.
        
        ;Theory: Once CPU usage per frame rises past 100%, until load lowers,
        ;everything will experience 50% slowdown as the task manager completes
        ;its rounds every other frame, and frames it finishes will see low CPU
        ;usage. Usage on these frames provides a mostly meaningful metric on
        ;how far above 100% CPU utilization is. Though highly unlikely, if CPU
        ;usage rises above 200%, the game will drop 2 frames per task. These
        ;drops also affect visuals, and if sprite shuffling is employed
        ;causing even mild flickering, flickering will worsen as their offscreen
        ;frames double in count. Their onscreen ones will double, too, but the
        ;visual adavantages conferred by that are already used optimally at all
        ;sprite counts.
;The music doesn't lag, though. The music never lags. And the hat never flickers

.DEFINE ActiveActorArray $CFAC
.EXPORT ActiveActorArray

.SECTION "ActorBase" FREE

;Creates and returns an initialized base actor, ready for characterization
Actor_New:
;D = X start
;E = Y start
;Returns
;DE->Actor data
;Destroys all else
  PUSH DE   ;X, Y
;Allocate and initialize memory
  CALL MemAlloc
  LD H,D
  LD L,E
  LD A,5
  LDI (HL),A
  LDI (HL),A
  XOR A
  LD C,$10
-
  LDI (HL),A
  DEC C
  JR nz,-
  LD HL,_MasterX+1
  ADD HL,DE
  POP BC
  LD A,B    ;X
  LDI (HL),A
  INC HL
  LD (HL),C ;Y
;Set up Actor Draw
;DE=Actor Data
  LD B,D
  LD C,E
  INC DE    ;Set up inital OAM dummy pointer
  LD A,1
  LD (DE),A
;Allocate relational data memory
  CALL MemAlloc ;Subsprite
  LD HL,_RelData
  ADD HL,BC
  LD (HL),E
  INC HL
  LD (HL),D
  LD D,B
  LD E,C
  RET

Actor_Draw:
;DE-> Actor data
;If carry set, new animation in BC
;Destroys all
  JR nc,+
;Initial
  LD HL,_RelData
  ADD HL,DE
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  PUSH DE
  LD D,24
-
  LD A,(BC)
  INC BC
  LDI (HL),A
  DEC D
  JR nz,-
  POP DE
;Store anim ptr & count
  LD HL,_AnimPtr
  ADD HL,DE
  LD A,C
  LDI (HL),A
  LD A,B
  LDI (HL),A
  LD A,(BC)
  AND $F0
  LD (HL),A
  JR +
+   ;Perform animation timer
  LD HL,_AnimWait
  ADD HL,DE
  LDI A,(HL)
  SUB (HL)
  DEC HL
  LDD (HL),A
  JP nc,+
;Change visual
  LD HL,_AnimPtr+1
  ADD HL,DE
  LDD A,(HL)
  LD B,A
  LD A,(HL)
  LD C,A
  PUSH DE
  ;Update anim pointer here
  LD A,(BC)
  INC BC
  AND $0F
  INC A
  PUSH AF
  ADD (HL)
  LDI (HL),A
  LD A,0
  ADC (HL)
  LDD (HL),A
  DEC HL
  LDD A,(HL)
  LD L,(HL)
  LD H,A
  PUSH HL
;Act on each edit
--
  POP HL
  POP AF
  DEC A
  JR z,++++
  PUSH AF
  LD A,(BC)
  INC BC
  LD E,A
  INC A     ;Test for end of animation
  JR z,++
  PUSH HL
;Do change sprite
;Detect all sprite/Perform load
  LD D,1    ;General case
  LD A,$1C
  AND E
  JR nz,+++
;All sprites affected
  LD A,$04  ;Adjust E so position hits right
  ADD E
  LD E,A
  LD D,6
+++ ;Go to position
  LD A,E
  AND $1F
  SUB $04
  ADD L
  LD L,A
  LD A,0
  ADC H
  LD H,A
;Detect Attribute change
  LD A,$03
  AND E
  XOR $03
  JR z,+++
;General change
;Sign extend the 3 bit value
  SRA E
  SRA E
  SRA E
  SRA E
  SRA E
-
  LD A,E
  ADD (HL)
  LDI (HL),A
  INC HL
  INC HL
  INC HL
  DEC D
  JR nz,-
  JR --
+++
;Attribute change
  LD A,$E0
  AND E
;Turn %ab000000 to %a00b0000
;Turn %ab100000 to %0ab00000 
  RRCA
  RRCA
  BIT 3,A
  JR z,+++
  ADD %01100000
  AND %10010000
  RRCA
+++
  ADD A
  LD E,A
-
  LD A,E
  XOR (HL)
  LDI (HL),A
  INC HL
  INC HL
  INC HL
  DEC D
  JR nz,-
  JR --
++  ;End of animation
  POP AF
  POP DE
  LD HL,_AnimPtr
  ADD HL,DE
  LD A,(BC)
  INC BC
  LDI (HL),A
  LD A,(BC)
  LDD (HL),A
  LD B,A
  LD C,(HL)
  JR ++
++++    ;End of anim edits
  POP DE
++  ;New wait
  LD A,(BC)
  LD HL,_AnimWait
  ADD HL,DE
  AND $F0
  ADD (HL)
  LD (HL),A
+   ;Move visual data to shadow OAM
  LD A,6    ;No. of sprites
HatDrawHackEntry:
  PUSH AF   ;Hat only has 3, so it's hacked in here
  LD H,D
  LD L,E
  LDI A,(HL)    ;SprPtr
  LD C,A
  LDI A,(HL)
  LD B,A
  PUSH BC
  INC HL
  LDI A,(HL)    ;_MasterX hi
  LD B,A
  INC HL
  LDI A,(HL)    ;_MasterY hi
  LD C,A
  LDI A,(HL)    ;_RelData
  LD H,(HL)
  LD L,A
  PUSH HL
  CALL ObjOffset
  JR nc,+
;Object not visible
  LD HL,_Visible
  ADD HL,DE
  LD A,(HL) ;Test and reset bit 0
  RRCA
  SCF
  CCF
  RLA
  LD (HL),A
  CALL c,Actor_Hide
  POP HL
  POP BC
  POP AF
  RET
+
;Object visible
  LD HL,_Visible
  ADD HL,DE
  LD A,(HL) ;Test and set bit 0
  RRCA
  SCF
  RLA
  LD (HL),A
  PUSH BC
  PUSH AF
  CALL nc,Actor_Show
  POP AF
  POP DE
  POP HL
  POP BC
  JR c,+
  POP AF
  RET       ;Don't draw this frame
;BC->OAM shadow
;DE =(X,Y)
;HL->Relational data
-
  PUSH AF
+
;Y
  LDI A,(HL)
  ADD E
  LD (BC),A
  INC BC
;X
  LDI A,(HL)
  ADD D
  LD (BC),A
  INC BC
;Tile
  LDI A,(HL)
  LD (BC),A
  INC BC
;Attribute
  LDI A,(HL)
  LD (BC),A
  INC BC
  POP AF
  DEC A
  JR nz,-
  RET

;!NEW! Call to move the actor in the indicated X and Y delta, with bg collision
Actor_Move:
;BC = X delta
;DE = Y delta
;HL-> Actor Data
;Destroys A, HL

;For collision, we only need a tile address
;That is, high 5 bits of X and Y, after adding current pos and delta
;Only apply new position if collision check passes
;Do a buffer of 4 pixels on U/D, and 8 on L/R?
    ;While this applies to every character, the only one who really cares is the player
;Idea: Attempt X and Y separately, to allow semi-diagonal movement
;Test deltas
  INC HL
  INC HL
  PUSH HL
    LD A,C
    OR B
    JR z,++ ;No X delta; don't check
    ;Test X delta
    LD A,B  ;Round up and away from 0
    CP 1
    INC HL
    LDI A,(HL)    ;Master X
    ADC B ;X delta
    INC HL
    LD H,(HL)     ;Master Y
    RRCA  ;Get bit address
    RRCA
    RRCA
    DEC A   ;X positions are 8 pixels greater than collision map positions
    PUSH AF
      RRCA    ;Get byte address
      RRCA
      RRCA
      AND $03
      LD L,A
      LD A,$F8
      AND H
      SUB 16  ;Y position is 16 pixels greater than collision map position
      RRCA
      OR L
      ADD <ColArea    ;Guarantee no carry. In fact, no bit overlap; ADD is easier to read
      LD L,A
      LD H,>ColArea
    POP AF    ;Bit portion
    AND $07
    ;"BIT A,(HL)" here
    LD H,(HL)
    LD L,A
    LD A,H
    INC L
-
    RLA
    DEC L
    JR nz,-
  POP HL
  PUSH HL
    JR nc,++  ;If 0 (collidable block), don't do X movement
    ;Perform X movement
    LD A,(HL)
    ADD C
    LDI (HL),A
    LD A,(HL)
    ADC B
    LDD (HL),A
++
    LD A,E
    OR D
    SCF ;Do not move!
    JR z,++ ;No Y delta
    ;Test Y delta
    LD A,D
    CP 1    ;Round up to 1 from numbers less than 0
    INC HL
    LD C,(HL)     ;Master X
    INC HL
    INC HL
    LD A,(HL)     ;Master Y
    ADC D   ;Y delta, rounded away from 0
    SUB 16  ;Y position is 16 pixels greater than collision map position
    LD B,A
    LD A,C
    RRCA  ;Get bit address
    RRCA
    RRCA
    DEC A   ;X positions are 8 pixels greater than collision map positions
    LD C,A
    RRCA    ;Get byte address
    RRCA
    RRCA
    AND $03
    LD L,A
    LD A,$F8
    AND B
    RRCA
    OR L
    ADD <ColArea    ;Guarantee no carry. In fact, no bit overlap; ADD is easier to read
    LD L,A
    LD H,>ColArea
    LD A,C    ;Bit portion
    AND $07
    ;"BIT A,(HL)"
    LD C,A
    LD A,(HL)
    INC C
-
    RLA
    DEC C
    JR nz,-
++
  POP HL
  JR nc,+   ;If 0 (collidable block), don't do Y movement
  ;Perform Y movement
  INC HL
  INC HL
  LD A,(HL)
  ADD E
  LDI (HL),A
  LD A,(HL)
  ADC D
  LDD (HL),A
+
  RET

;Remove from sprite viewing order
Actor_Hide:
;Null the object pointer
  LD HL,_SprPtr+1
  ADD HL,DE
  LD (HL),$05
;Find this actor in viewing order
  LD HL,ActiveActorArray
-
  LDI A,(HL)
  CP E
  LDI A,(HL)
  JR nz,-
  CP D
  JR nz,-
  DEC L
  DEC L
  LD B,H
  LD C,L
;Decrement ObjUse
  LD HL,ObjUse
  DEC (HL)
;Find final actor
  LD L,(HL)
  RLC L
  LD A,<ActiveActorArray
  ADD L
  LD L,A
  LD A,>ActiveActorArray
  ADC 0
  LD H,A
;Put final actor in our place
  LDI A,(HL)
  LD (BC),A
  INC BC
  LD A,(HL)
  LD (BC),A
  RET

;Start showing actor on screen
Actor_Show:
;DE->Actor data
;Destroys BC, HL
  LD HL,ObjUse
  LD C,(HL)
  INC (HL)
  RLC C
  LD B,0
  LD HL,ActiveActorArray
  ADD HL,BC
  LD (HL),E
  INC HL
  LD (HL),D
  RET

;Process common messages
    ;0: Snap to X location
        ;E= X position, in pixels
    ;1: Snap to Y location
        ;E= Y position, in pixels
    ;2: Set actor speed
        ;E= speed (4.4) pixels/frame
    ;3: Move actor up
        ;E= distance (pixels)
    ;4: Move actor left
        ;E= distance (pixels)
    ;5: Move actor down
        ;E= distance (pixels)
    ;6: Move actor right
        ;E= distance (pixels)
    ;8: Set animation speed
        ;E= speed
    ;9: Play animation
        ;E= animation ID
    ;128: Cease existing
    ;129: Start/Stop cutscene control
Actor_Message:
;DE->Actor data
;Destroys A,BC,HL
  CALL MsgGet
  RET c
  ;Message get!
  ;H= Message ID
  ;L= Data
  INC H ;Allow 0
  LD A,L
  DEC H
  JR nz,+
  ;Snap to X position
  LD HL,_MasterX+1
  ADD HL,DE
  LDD (HL),A
  ;LD (HL),0    ;If subpixel position causes problems, use this line
  JR Actor_Message  ;Check for more messages
+
  DEC H
  JR nz,+
  ;Snap to Y position
  LD HL,_MasterY+1
  ADD HL,DE
  LDD (HL),A
  JR Actor_Message  ;Check for more messages
+
  DEC H
  JR z,+
  DEC H
  JR z,+
  DEC H
  JR z,+
  DEC H
  JR nz,++
+   ;Move Actor up/left/down/right
  LD A,L
  LD BC,Actor_DistMove_Task
  CALL NewTask
  JR Actor_Message  ;Check for more messages
++
  DEC H
  DEC H
  JR nz,+
  ;Set animation speed
  LD HL,_MoveSpeed
  ADD HL,DE
  ;4.4 to 8.8
  SWAP A
  LD C,A
  AND $F0
  LDI (HL),A
  LD A,$0F
  AND C
  LD (HL),A
  JR Actor_Message  ;Check for more messages
+
  LD A,8
  ADD H
  LD H,A
  RET   ;Actor-specific message

;Move actor in a direction over a certain distance
Actor_DistMove_Task:
;DE->Actor Data
;A= %DDLLLLLL
    ;||++++++--- Length of move, in pixels
    ;++--------- Direction U/L/D/R
  LD B,A
  AND $3F
  BIT 7,B
  JR nz,++
  BIT 6,B
  JR nz,+
    ;Up movement
-
  CALL HaltTask
  PUSH AF   ;Distance
    LD HL,_MoveSpeed
    ADD HL,DE
    LDI A,(HL)  ;Collected inside loop in case of changes (allow acceleration)
    LD C,A
    LD B,(HL)
    LD HL,_MasterY
    ADD HL,DE
    LD A,(HL)
    SUB C
    LDI (HL),A
    LD A,(HL)
    SBC B
    LD (HL),A
  POP AF
  SUB B
  JR nc,-
  SUB (HL) ;Pos Hi
  LD (HL),A ;Subtracting negative overflow to make position exact
  JP EndTask
+   ;Left movement
-
  CALL HaltTask
  PUSH AF   ;Distance
    LD HL,_MoveSpeed
    ADD HL,DE
    LDI A,(HL)  ;Collected inside loop in case of changes (allow acceleration)
    LD C,A
    LD B,(HL)
    LD HL,_MasterX
    ADD HL,DE
    LD A,(HL)
    SUB C
    LDI (HL),A
    LD A,(HL)
    SBC B
    LD (HL),A
  POP AF
  SUB B
  JR nc,-
  SUB (HL) ;Pos Hi
  LD (HL),A ;Adding negative overflow to make position exact
  JP EndTask
++  ;Down/Right
  BIT 6,B
  JR nz,+
    ;Down movement
-
  CALL HaltTask
  PUSH AF   ;Distance
    LD HL,_MoveSpeed
    ADD HL,DE
    LDI A,(HL)  ;Collected inside loop in case of changes (allow acceleration)
    LD C,A
    LD B,(HL)
    LD HL,_MasterY
    ADD HL,DE
    LD A,(HL)
    ADD C
    LDI (HL),A
    LD A,(HL)
    ADC B
    LD (HL),A
  POP AF
  SUB B
  JR nc,-
  ADD (HL) ;Pos Hi
  LD (HL),A ;Subtracting negative overflow to make position exact
  JP EndTask
+   ;Right movement
-
  CALL HaltTask
  PUSH AF   ;Distance
    LD HL,_MoveSpeed
    ADD HL,DE
    LDI A,(HL)  ;Collected inside loop in case of changes (allow acceleration)
    LD C,A
    LD B,(HL)
    LD HL,_MasterX
    ADD HL,DE
    LD A,(HL)
    ADD C
    LDI (HL),A
    LD A,(HL)
    ADC B
    LD (HL),A
  POP AF
  SUB B
  JR nc,-
  ADD (HL) ;Pos Hi
  LD (HL),A ;Adding negative overflow to make position exact
  JP EndTask
.ENDS

.DEFINE HitboxStart     $C400
.DEFINE HitboxEndPtr    $C0EC

.SECTION "Collision" FREE
;Hitbox memory format:
    ;2 bytes: X position (8.8)
    ;2 bytes: Y position (8.8)
    ;2 bytes: Radius     (8.8)
    ;2 bytes: Owning Actor
    ;2 bytes: Action
;Action signature:
    ;BC->Owning actor
    ;DE->Touching actor

;This task needs more speed.
    ;Make hit detection squares. Handlers can decide actual shape
    ;Streamline data organization for execution speed
HitboxUpdate_Task:
;Puts updated hitbox information in the extract area so pushing etc are up to date
---
  CALL HaltTask
  ;Back to front for ease of end checking
  LD A,(ObjUse)
  RLC A ;affect zero flag
  RET z ;No actors; nothing to do
  ADD <ActiveActorArray
  LD C,A
  LD B,>ActiveActorArray
  ;Point HL to beginning of Hitbox Data Collection
  LD HL,HitboxStart
-
  ;For each actor
  ;Don't edit HL
  ;Get actor in DE
  DEC C
  LD A,(BC)
  LD D,A
  DEC C
  LD A,(BC)
  ADD _Hitbox
  LD E,A
  LD A,0
  ADC D
  LD D,A
  PUSH BC
    ;Get hitbox data in BC
    LD A,(DE)
    INC DE
    LD C,A
    LD A,(DE)
    LD B,A
    LD A,-(_Hitbox+1)
    ADD E       ;Back to base
    LD E,A
    LD A,-1
    ADC D
    LD D,A
    ;Get no. of hitboxes
    LD A,(BC)
    INC BC
--
;BC->Actor Hitbox Data
;DE->Actor Data
;HL->Hitbox Data Collection
    ;For each hitbox
    PUSH AF
      INC DE
      INC DE
      LD A,(BC)       ;X offset
      INC BC
      LD (HL),A
      LD A,(DE)
      INC DE
      ADD (HL)
      LDI (HL),A
      LD A,(BC)
      INC BC
      LD (HL),A
      LD A,(DE)
      INC DE
      ADC (HL)
      LDI (HL),A
      LD A,(BC)       ;Y offset
      INC BC
      LD (HL),A
      LD A,(DE)
      INC DE
      ADD (HL)
      LDI (HL),A
      LD A,(BC)
      INC BC
      LD (HL),A
      LD A,(DE)
      ADC (HL)
      LDI (HL),A
      LD A,-(_MasterY+1)     ;Return DE to start of actor
      ADD E
      LD E,A
      LD A,-1
      ADC D
      LD D,A
      LD A,(BC)      ;Radius
      INC BC
      LDI (HL),A
      LD A,(BC)
      INC BC
      LDI (HL),A
      LD A,E
      LDI (HL),A      ;Owning actor
      LD A,D
      LDI (HL),A
      LD A,(BC)       ;Action
      INC BC
      LDI (HL),A
      LD A,(BC)
      INC BC
      LDI (HL),A
    POP AF
    DEC A
    JR nz,--
  POP BC
  LD A,<ActiveActorArray
  CP C
  JR nz,-

;DoPush_Task:
;Checks all actors and hits them as necessary
;For each actor
    ;Check against background
        ;Do this in move
    ;Check against subsequent actors
    ;For pushing:
        ;Get line between our hitbox and theirs
            ;Their hitbox position, minus our hitbox position
        ;Move away from that direction, by amount of overlap
            ;Negate above value
            ;Scale(?) to their radius plus our radius minus our distance
  LD E,L
  LD D,H
  CALL HaltTask     ;Test for alt-frame collision detection. Remove if in-game circumstances make no situations with very large actor counts
  LD L,E
  LD H,D
  ;Back to front for ease of end checking
  ;HL contains the end of hitbox array
  ;Compare every hitbox with every other hitbox
  ;(This grows half as fast as O(n^2), best case if most hitboxes are moving)
-
  LD A,L    ;Go to beginning of next hitboxes
  SUB 10
  LD L,A
  LD A,H
  SBC 0
  LD H,A
  LD A,L    ;Don't compare hitboxes to themselves
  SUB 10
  LD C,A
  LD A,H
  SBC 0
  LD B,A
  SUB (>HitboxStart)-1  ;When HL is the last, BC underflows
  JP z,---
--
  ;Hit check:
  ;Circles:
  ;sqrt((X2 - X1)^2 + (Y2 - Y1)^2) - R1 - R2 < 0
  ;sqrt((X2 - X1)^2 + Y2^2 - Y2Y1 + Y1^2) - (R1 + R2) < 0
  ;(X2 - X1)^2 + Y2^2 - Y2Y1 + Y1^2 - (R1 + R2)^2 < 0
  ;(X2 - X1)^2 + (Y2 - Y1)^2 - (R2 + R1)^2 < 0
  ;Circles are computationally expensive, so use squares instead:
  ;(X2 + R2) < (X1 - R1) || (X2 - R2) > (X1 + R1)
  ;X2 + R2 + R1 < X1 || X2 - R2 - R1 > X1
  ;X2 + R2 + R1 - X1 < 0 || X2 - R2 - R1 - X1 > 0
  ;abs(X2 - X1) - (R2 + R1) < 0
  LD A,(BC)   ;DE = abs(X2 - X1)
  INC BC
  SUB (HL)
  INC HL
  LD E,A
  LD A,(BC)
  INC BC
  SBC (HL)
  INC HL
  LD D,A
  JR nc,+
  CPL
  LD D,A
  LD A,E
  CPL
  LD E,A
  INC DE
  LD A,D
+
  AND $C0
  JR z,+      ;X delta too large for hitbox to cover?
  LD DE,4     ;Prepare HL
  ADD HL,DE
  INC BC      ;Next BC hitbox
  INC BC
  INC BC
  INC BC
  JR _nohit
+
  PUSH DE
    LD A,(BC)   ;DE = abs(Y2 - Y1)
    INC BC
    SUB (HL)
    INC HL
    LD E,A
    LD A,(BC)
    INC BC
    SBC (HL)
    INC HL
    LD D,A
    JR nc,+
    CPL
    LD D,A
    LD A,E
    CPL
    LD E,A
    INC DE
    LD A,D
+
    AND $C0
    JR z,+      ;Y delta too large for hitbox to cover?
  POP DE    ;Stack realignment
  INC HL    ;Setup HL
  INC HL
  INC BC    ;Setup BC
  INC BC
  JR _nohit
+
    PUSH DE
      LD A,(BC)   ;DE = (R2 + R1)
      INC BC
      ADD (HL)
      INC HL
      LD E,A
      LD A,(BC)
      INC BC
      ADC (HL)
      INC HL
      LD D,A
      ;For both X delta and Y delta,
      ;Subtract radii from delta
      ;Axis misses if no carry
      ;Both axes have to hit
      PUSH HL
        LD HL,SP+2
        LDI A,(HL)
        SUB E
        LDI A,(HL)
        SBC D
        JR nc,+
        LDI A,(HL)
        SUB E
        LDI A,(HL)
        SBC D
+
      POP HL
    POP DE
  POP DE
  JR nc,_nohit
;Hit. Call hit actions
  PUSH HL   ;The order of the next four push/pop pairs is important
  PUSH BC   ;The called-on hitbox is always top of the stack
    ;Call the actions on BC and HL if they are different actors
    LDI A,(HL)  ;DE->Touching actor
    LD E,A
    LD D,(HL)
    LD H,B  ;Copy this actor to HL
    LD L,C
    LDI A,(HL)  ;BC->Owning actor
    LD C,A
    LDI A,(HL)
    LD B,A
    LDI A,(HL)  ;HL->Action
    LD H,(HL)
    LD L,A
    LD A,B      ;Make sure they're different (WARNING: clever!)
    XOR C       ;By a wonder of the addresses MemAlloc returns, this will always work
    XOR D       ;Specifically, they are all $DXX0, so the only varied bits don't overlap in XORs
    XOR E       ;If and only if the addresses are the same will the result be 0
    CALL nz,$0030
  POP BC
  POP HL
  ;Call HL's action too
  PUSH BC
  PUSH HL
    LD A,(BC) ;DE->Touching actor
    INC BC
    LD E,A
    LD A,(BC)
    LD D,A
    LDI A,(HL)    ;BC->Owning actor
    LD C,A
    LDI A,(HL)
    LD B,A
    LDI A,(HL)    ;HL->Action
    LD H,(HL)
    LD L,A
    LD A,B      ;Make sure they're different
    XOR C       ;As above.
    XOR D       ;Should MemAlloc change to return more addresses, a few false positives would occur.
    XOR E       ;A reasonable alternative could be adding them instead
    CALL nz,$0030
  POP HL
  POP BC
_nohit:     ;Result greater than zero? Didn't hit
  LD DE,-6  ;Realign HL
  ADD HL,DE
  LD A,C
  SUB 16    ;Next hitbox
  LD C,A
  LD A,B
  SBC 0
  LD B,A
;Check for end of loop
  SUB (>HitboxStart)-1
  JP nz,--
  JP -

.ENDS

.DEFINE ObjUse $C0FA
.EXPORT ObjUse

.DEFINE MidQueue $C0F9

.SECTION "ObjData" FREE
ObjLoc:
 .db $10,$28,$40,$58,$70,$88
.ENDS

.SECTION "Object" FREE
;Provide management functions

;Manipulates the sprite pointers in Active actors
;to allow additional sprites at the cost of flickering

;This turns ObjUse into an actor counter,
;so we know if and when to sprite cycle, and how much
;Alt, for just doing a rotating buffer
ObjManage_Task:
  LD DE,ActiveActorArray    ;Setup Rotating queue
--
  CALL HaltTask
;Clear stale memory
  LD HL,$CF9F
  XOR A
-
  LDD (HL),A
  CP L
  JR nz,-
  LD HL,ObjUse
  LD A,(HL)
;Sprite counts may have changed between now and the last time the queue was set.
;Since we use it now, only do the bounds check now
  INC A
  PUSH AF
  DEC A
  RLCA
  ADD <ActiveActorArray - 1
  LD B,A
;Start assigning object pointers
  LD C,$10
-       ;Done check here so hat and menu pointer work right
  POP AF
  DEC A
  JR z,--
  PUSH AF
  ; MidQueue >= ObjUse == overflow
  LD A,B
  CP E
  JR nc,+
;MidQueue overflowed
  ;Mod logical queue point with ObjUse
  ;...or just go to beginning
  LD E,<ActiveActorArray
+   ;Valid MidQueue obtained
;Find this object and give it one
  LD A,(DE)
  LD L,A
  INC E
  LD A,(DE)
  LD H,A
  INC E
  LD A,(HL)
  CP 4
  JR c,-   ;If lower byte is <4, this is hat/menu pointer, and we don't touch
  LD A,C
  LDI (HL),A
  LD (HL),$CF
++
;Next object pointer!
  LD A,$18
  ADD C
  LD C,A
  CP $9F
  JR c,-
;...Fresh out of pointers. Save DE for next time
  LD H,D
  LD L,E
  POP AF    ;Swap stack
  PUSH DE
  LD D,B
  LD E,A
-
  LD A,D
  CP L
  JR nc,+
  ;HL Wrapped
  LD L,<ActiveActorArray
+
  LD C,(HL)
  INC L
  LD B,(HL)
  INC L
  LD A,5    ;In ROM, but >= 4
  LD (BC),A
  INC BC
  LD (BC),A
;Finished?
  DEC E
  JR nz,-
  POP DE
  JR --

;In contrast to the above, this one needs to be absolutely last in the tasklist
;This one goes through all of the sprites, and puts them behind the background
    ;if they are on a tile that says so
ObjectPriority_Task:
  LD HL,$CFA0
-
  LD A,L
  OR A
  RET z ;Lots of things loop back without checking
  DEC L
  BIT 7,(HL)
  JR nz,+   ;If object decided it should be background anyways, no need
;Decide if bit should be set
;Is this sprite offscreen? (Stricter than below)
  DEC L
  DEC L
  LDD A,(HL)    ;X
  DEC A ;Catch 0
  CP 167
  JR nc,-
  LD A,(HL)     ;Y
  SUB 9     ;Y=0 is 16 pixels offscreen
  CP 151
  JR nc,-
;Is it on a relevant tile? (Looser than you think)
;X and Y are pixel positions, each
  LD DE,BkgVertScroll
  LD A,(DE)
  INC E
  ADD (HL)      ;Y portion
  ADD 4-16
  INC L
  AND $F8   ;Chop off the lower 3 bits (bit to tile)
  RRCA
  LD B,A
  LD A,(DE)
  ADD (HL)      ;X portion
  ADD 4-8   ;Coordinates are center of tile
  DEC L
  RRCA      ;Convert from bit coordinates to tile coordinates
  RRCA
  RRCA
  LD C,A
  LD A,$18  ;Each tile is a bit in collision array
  AND C
  RRCA
  RRCA
  RRCA
  OR B
  LD B,A    ;Byte address
  LD A,$07
  AND C     ;Bit address
  LD C,A
;Get map tile bit
  LD D,>PriArea
  LD E,B
  LD A,(DE)
  INC C ;One based rotation
--
  RLA
  DEC C
  JR nz,--
  JR c,-    ;Due to a bu-...feature in the map generator, activate on clear bits
;Set it
  INC L
  INC L
  INC L
  SET 7,(HL)
+
  DEC L
  DEC L
  DEC L
  JR nz,-
  RET

;Given a pair of 8,8 map coordinates, get sprite coordinates
ObjOffset:
;BC = (X,Y) coordinate
;Returns X in B, Y in C
;Destroys A, HL
;Sets carry if object >24 px offscreen
;In this case, BC is meaningless
  LD HL,BkgHortScroll
  LD A,B
  SUB (HL)
  DEC L
  LD B,A
  ;Offscreen if 240 >= X >= 192
  ;Thus, also if 255 >= X+15 >= 207
  ;We can ignore the left check, and focus on the right
  ADD 15
  CP 207    ;Screen right
  CCF
  RET c
  LD A,C
  SUB (HL)
  LD C,A
  ;As above, but 248 >= X >= 184
  ADD 7
  CP 191    ;Screen bottom
  CCF
  RET

.ENDS
