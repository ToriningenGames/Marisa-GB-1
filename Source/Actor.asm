;Actors
;Common functions for "actors": things with sprites that move, and stuff.

.INCLUDE "ActorData.asm"

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

Access_ActorDE:
;A= Task ID
;Returns task's DE in HL
  LD H,>taskpointer
  RLA
  RLA
  RLA
  ADD <taskpointer + 4
  LD L,A
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  RET

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
  LD B,D    ;Save to BC due to next alloc
  LD C,E
  INC DE    ;Set up inital OAM dummy pointer
  LD A,1
  LD (DE),A
  LD HL,_SprCount
  ADD HL,BC
  LD (HL),0
;Allocate relational data memory
  CALL MemAlloc ;Subsprite
  LD HL,_RelData
  ADD HL,BC
  LD (HL),E
  INC HL
  LD (HL),D
  LD D,B
  LD E,C
  ;Set up control values
  LD HL,_ControlState
  ADD HL,DE
  LD (HL),0     ;Actors start out in cutscenes
  LD HL,_AnimChange
  ADD HL,DE
  LD (HL),0     ;Forces initialization of animation
  LD HL,_Visible
  ADD HL,DE
  LD (HL),0     ;Invisible by default
  RET

;Not a function; JP to here
Actor_Delete:
;DE-> Actor data
;Does not return
  CALL Actor_Hide
  LD HL,_RelData
  ADD HL,DE
  LDI A,(HL)
  LD B,(HL)
  LD C,A
  CALL MemFree
  LD D,B
  LD E,C
  CALL MemFree
  JP EndTask

Actor_Draw:
;DE-> Actor data
;If carry set, new animation in BC
;Destroys all
  JR nc,+
;Initial
  LD HL,_SprCount
  ADD HL,DE
  LD A,(BC) ;Sprite counter
  LD (HL),A
  LD HL,_RelData
  ADD HL,DE
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  LD A,(BC) ;Sprite counter
  INC BC
  PUSH DE
    RLA
    RLA
    LD D,A
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
        RRCA
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
  LD HL,_SprCount
  ADD HL,DE
  LD A,(HL) ;No. of sprites
  PUSH AF
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

;TODO: There is some bug involving being able to pass into collision when
    ;moving diagonally near the corner of bg collision groups
    ;Specifically, when Marisa moves diagonally, the point to her side and to
    ;her front are separately checked for collision, providing the bounding.
    ;When she moves diagonally into an object, she "slots" into the corner.
    ;She can then move extra close to walls, because horizonal collision isn't
    ;checked for vertical movement, and vice-versa
    ;A fix would involve a total of 4 more point checks written,
    ;and two to run each movement.
    ;We can't only test the diagonal, because then Marisa would be able to pass
    ;through cattycorners while moving diagonally, which is worse, and it makes
    ;sense to slide along a surface linearly while moving diagonally

  PUSH DE
    PUSH BC
;Maginify movements by 5 (x) and 3 (y) constant for hitboxing
      BIT 7,B
      JR z,+
      LD A,B
      SUB 5
      LD B,A
      JR ++
+
      LD A,B
      ADD 5
      LD B,A
++
      BIT 7,D
      JR z,+
      LD A,D
      SUB 3
      LD D,A
      JR ++
+
      LD A,D
      ADD 3
      LD D,A
++
;Test X+Y deltas simultaneously
;      PUSH BC
        INC HL
        INC HL
;        LDI A,(HL)
;        ADD C
;        LDI A,(HL)
;        ADC B
;        LD C,A
;        LDI A,(HL)
;        ADD E
;        LDD A,(HL)
;        ADC D
;        LD B,A
;        PUSH HL
;          CALL GetColAtBC
;        POP HL
;      POP BC
;      JR nc,+   ;Fully diagonal movement failed
;;Move along diagonal
;    POP BC
;  POP DE
;  LD A,(HL)
;  ADD E
;  LDI (HL),A
;  LD A,(HL)
;  ADC D
;  LDD (HL),A
;  DEC HL
;  DEC HL
;  LD A,(HL)
;  ADD C
;  LDI (HL),A
;  LD A,(HL)
;  ADC B
;  LD (HL),A
;  RET
+
;Test X delta
;      DEC HL
;      DEC HL
      LDI A,(HL)
      ADD C
      LDI A,(HL)
      ADC B
      LD C,A      ;Set up BC to integer XY
      INC HL
      LD B,(HL)
      PUSH HL
        CALL GetColAtBC
      POP HL
    POP BC
    DEC HL
    JR nc,+     ;Don't perform movement if there is collision
    DEC HL
    DEC HL
    LD A,(HL)
    ADD C
    LDI (HL),A
    LD A,(HL)
    ADC B
    LDI (HL),A
;  POP DE        ;Because diagonal movement was tested, and horizonal succeeded,
;  RET           ;we know that vertical failed; no need to test it.
+
;Test Y delta
    LDI A,(HL)
    ADD E
    LDD A,(HL)
    ADC D
    LD B,A      ;Set up BC to integer XY
    DEC HL
    LD C,(HL)
    PUSH HL
      CALL GetColAtBC
    POP HL
  POP DE
  JR nc,+   ;Don't perform movement if there is collision
  INC HL
  LD A,(HL)
  ADD E
  LDI (HL),A
  LD A,(HL)
  ADC D
  LDI (HL),A
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

;Force actor priority over background
Actor_HighPriority:
  LD HL,_SprCount
  ADD HL,DE
  LD B,(HL)
  LD HL,_RelData
  ADD HL,DE
  LDI A,(HL)
  LD H,(HL)
  LD L,A
-
  INC HL
  INC HL
  INC HL
  LD A,$7F
  AND (HL)
  OR 1
  LDI (HL),A
  DEC B
  JR nz,-
  RET

;Force actor priority behind background
;Destroys HL,A,B
Actor_LowPriority:
  LD HL,_SprCount
  ADD HL,DE
  LD B,(HL)
  LD HL,_RelData
  ADD HL,DE
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  INC HL
-
  INC HL
  INC HL
  LD A,$FE
  AND (HL)
  OR $80
  LDI (HL),A
  DEC B
  JR nz,-
  RET

;Free actor priority to natural state
;Destroys HL,A,B
Actor_NormalPriority:
  LD HL,_SprCount
  ADD HL,DE
  LD B,(HL)
  LD HL,_RelData
  ADD HL,DE
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  INC HL
-
  INC HL
  INC HL
  LD A,$7E
  AND (HL)
  LDI (HL),A
  DEC B
  JR nz,-
  RET

;Move actor in a direction over a certain distance
Actor_DistMove:
;DE->Actor Data
;BC= Length of move, in pixels (8.8)
;A= Direction U/L/D/R
  PUSH AF
    AND 1   ;Move DE to MasterX/Y depending on direction
    XOR 1
    RLCA
    ADD 2
    ADD E
    LD E,A
    LD A,D
    ADC 0
    LD D,A
-
  POP AF
  CALL HaltTask
  PUSH AF
    AND 1   ;Set HL to MoveSpeed value, regarding of DE's location
    RLCA
    ADD <(_MoveSpeed-_MasterY)
    LD L,A
    LD A,>(_MoveSpeed-_MasterY)
    ADC 0
    LD H,A
    ADD HL,DE
    LDI A,(HL)
    LD H,(HL)
    LD L,A
  POP AF
  PUSH AF
    AND $02     ;Determine between addition/subtraction
    LD A,(DE)
    JR z,+
    ADD L           ;Add MoveSpeed to MasterX/Y
    LD (DE),A
    INC DE
    LD A,(DE)
    ADC H
    JR ++
+
    SUB L           ;Subtract MoveSpeed from MasterX/Y
    LD (DE),A
    INC DE
    LD A,(DE)
    SBC H
++
    LD (DE),A
    DEC DE
    LD A,C        ;Subtract MoveSpeed from BC (MoveDist)
    SUB L
    LD C,A
    LD A,B
    SBC H
    LD B,A
    JR nc,-   ;Go until full distance moved
  POP AF
  LD A,(DE)     ;Remove overshoot from MasterX/Y
  ADD C
  LD (DE),A
  INC DE
  LD A,(DE)
  ADC B
  LD (DE),A
  JP EndTask
.ENDS

.SECTION "Object" FREE

.DEFINE MidQueue $C0E8
.DEFINE ObjUse $C0E9
.EXPORT ObjUse

;Provide management functions

;Manipulates the sprite pointers in Active actors
;to allow additional sprites at the cost of flickering
ObjManage_Task:
;Initialization
  LD DE,MidQueue
  LD BC,ObjUse
  XOR A
  LD (BC),A
  LD A,<ActiveActorArray+1
  LD (DE),A
-   ;Frame loop
  CALL HaltTask
;Clear stale memory
  LD HL,$CF9F
  XOR A
-
  LDD (HL),A
  CP L
  JR nz,-
  LD (HL),A
  LD A,(BC)
  OR A
  RET z ;No sprites -> no work
;Move MidQueue, should it be higher than our actor count allows
  RLA
  ADD <ActiveActorArray-1
  LD H,D
  LD L,E
  CP (HL)
  JR nc,+
  LD (HL),A ;Replace MidQueue with new top
+   ;Pick up where we left off
  LD A,(HL)
  LD L,A
  LD H,>ActiveActorArray
  LD D,4    ;Current sprite use count (4 to allow hat to always be lowest)
--  ;Sprite loop
;For this actor:
  LDD A,(HL)
  LD B,A
  LDD A,(HL)
  LD C,A
  ;Is it the hat?
  LD A,(HatSig)
  CP C
  JR nz,++  ;Is not the hat
  LD A,(HatSig+1)
  CP B
  JR z,+    ;Is the hat
++
  ;Do we have enough sprites left?
  LD A,C
  ADD _SprCount
  LD C,A
  LD A,B
  ADC 0
  LD B,A
  LD A,(BC)
  ADD D
  CP 41
  JR nc,+
  ;Assign sprite pointer
  LD E,D
  LD D,A    ;Sprite use
  LD A,E    ;Where this sprite group starts
  OR A  ;Clear carry
  RLA   ;Sprites->bytes
  RLA
  INC L
  LD C,(HL)
  INC L
  LD B,(HL)
  DEC L
  DEC L
  LD (BC),A
  INC BC
  LD A,$CF
  LD (BC),A
+
  ;Check for underflow
  LD A,<ActiveActorArray
  CP L
  JR c,++
  LD H,>ActiveActorArray
  LD A,(ObjUse)
  SLA A
  ADD <ActiveActorArray-1
  LD L,A
++
  ;Check for all written
  LD A,(MidQueue)
  CP L
  JR nz,--
  ;All written
  RET
+   ;Out of sprites
  INC L
  INC L
  LD E,L
  ;Give remainder null values
--
  LDD A,(HL)
  LD B,A
  LDD A,(HL)
  LD C,A
  ;Is it the hat?
  LD A,(HatSig)
  CP C
  JR nz,++
  LD A,(HatSig+1)
  CP B
  JR z,+
++
  INC BC
  XOR A
  LD (BC),A
+
  ;Check for underflow
  LD A,<ActiveActorArray
  CP L
  JR c,++
  LD H,>ActiveActorArray
  LD A,(ObjUse)
  SLA A
  ADD <ActiveActorArray-1
  LD L,A
++
  ;Check for all written
  LD A,(MidQueue)
  CP L
  JR nz,--
  ;All written
  LD A,E
  LD (MidQueue),A
  RET

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
  BIT 0,(HL)
  JR nz,+   ;If object demands it stays in the foreground, let it
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
  INC L
  ADD 3
  LD B,A
  LD A,(DE)
  ADD (HL)      ;X portion
  DEC L
  ADD 3
  LD C,A
;Get map tile bit
;Checking 4x4 square
  PUSH HL
    CALL GetPriAtBC
  POP HL
  JR c,-
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
