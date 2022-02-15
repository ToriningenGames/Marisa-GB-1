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

;Given a pointer to an actor specification, sets up and runs said actor
;A-> Actor specific setting
;DE->Actor specification data
        ;1 byte:  Anim speed
        ;2 bytes: Move speed (8.8)
        ;2 bytes: Hitboxes
        ;2 bytes: AI movement function
                ;Called with
                    ;DE->actor data
                ;Return with
                    ;A=direction of movement
                    ;%00UD00LR
        ;2 bytes: Hatval list
        ;2 bytes: Anim list
;Run as task
Actor_FrameInit:
  PUSH AF
    PUSH DE
    ;Returns
    ;DE->Actor data
    ;Destroys all else
    ;Allocate and initialize memory
      CALL MemAlloc
      LD H,D
      LD L,E
      LD A,5
      LDI (HL),A
      LDI (HL),A
      XOR A
      LD C,$11
    -
      LDI (HL),A
      DEC C
      JR nz,-
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
      LD (HL),1     ;Actors start out in control
      INC HL
      LD (HL),0     ;Initially never moved
    POP BC
    ;Initial data copy
    LD HL,_AnimWait
    ADD HL,DE
    LD A,$01
    LDI (HL),A    ;Anim speed
    INC HL        ;Anim ID
    LD A,(BC)     ;Move Speed lo
    INC BC
    LDI (HL),A
    LD A,(BC)     ;Move Speed hi
    INC BC
    LDI (HL),A
    LD A,(BC)     ;Hitbox lo
    INC BC
    LDI (HL),A
    LD A,(BC)     ;Hitbox hi
    INC BC
    LDI (HL),A
    LD (HL),0     ;Initially invisible
    LD HL,_Settings
    ADD HL,DE
  POP AF
  LDI (HL),A    ;Actor setting
  LD A,(BC)     ;AI movement lo
  INC BC
  LDI (HL),A
  LD A,(BC)     ;AI movement hi
  INC BC
  LDI (HL),A
  LD A,(BC)     ;Hatval list lo
  INC BC
  LDI (HL),A
  LD A,(BC)     ;Hatval list hi
  INC BC
  LDI (HL),A
  LD A,(BC)     ;Anim list lo
  INC BC
  LDI (HL),A
  LD A,(BC)     ;Anim list hi
  LDI (HL),A
  ;Animation values
  LD HL,_AnimChange
  ADD HL,DE
  LD (HL),1 ;Face down
  RST $00
;Given an appropriate data set, runs the given actor
Actor_Frame:
  ;Check for doing AI stuffs here
    ;v: Cutscene control
    ;v: Play animation
    ;v: Destruct
  ;Cutscene detect
  LD HL,_ControlState
  ADD HL,DE
  LD A,(HL)
  INC A
  JP z,Actor_Delete
  DEC A
  AND $7F
  JR z,+    ;Cutscene control
;AI behavior here
  LD HL,++
  PUSH HL
  LD HL,_AIMovement
  ADD HL,DE
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  JP HL
++
  OR A
  JR z,++++     ;Not moving
  ;Move actor
  ;Transfer A into XY delta
  PUSH AF
  PUSH DE
    LD HL,_MoveSpeed
    ADD HL,DE
    LD E,(HL)
    INC HL
    LD D,(HL)
    ;Does BC get a value? (X movement)
    LD BC,0
    LD H,A
    AND $0F
    JR z,++
    ;BC movement
    LD B,D
    LD C,E
    ;This is positive X movement (rightwards), but are we going left?
    LD A,%00000010
    AND H
    JR z,++
    ;Going left
    LD A,C
    CPL
    LD C,A
    LD A,B
    CPL
    LD B,A
    INC BC
++
    ;Does DE get a value? (Y movement)
    LD A,$F0
    AND H
    JR z,++
    ;DE movement
    ;DE already has positive Y movement (downwards), but are we going up?
    LD A,%00100000
    AND H
    JR z,+++
    ;Going up
    LD A,E
    CPL
    LD E,A
    LD A,D
    CPL
    LD D,A
    INC DE
    JR +++
++
    LD DE,0
+++
    POP HL        ;Actor data
    PUSH HL
    CALL Actor_Move
  POP DE
  POP AF
  ;Correct animation data
  ;Am moving; use appropriate walking anim
  ;L==4,D==5,R==6,U==7
  ;A=%00UD00LR
  LD C,4
  AND %00110001
  JR z,+++
  INC C
  AND %00100001
  JR z,+++
  INC C
  AND %00100000
  JR z,+++
  INC C
+++
  LD A,C
  ;Don't change anims if we were already moving
  LD HL,_LastFacing
  ADD HL,DE
  CP (HL)
  JR z,+
  LD HL,_AnimChange
  ADD HL,DE
  LD (HL),A
  JR +  
++++
  ;Did we just stop moving?
  LD HL,_LastFacing
  ADD HL,DE
  OR (HL)
  JR z,+        ;No anim change; skip even the check
  ;Just stopped; stand in same direction
  SUB 4
  LD HL,_AnimChange
  ADD HL,DE
  LD (HL),A
  XOR A
+
  ;Always update last facing
  ;Safe if player control (value doesn't change if not updated)
  ;Changes value to 0 if cutscene control (aka as if not moving)
  ;so if player is holding a direction, chara doesn't slide once cutscene ends
  LD HL,_LastFacing
  ADD HL,DE
  LD (HL),A
  ;Animation check
  LD A,$FF
  LD HL,_AnimChange
  ADD HL,DE
  CP (HL)
  JR z,+++
  ;Change animation
  LD C,(HL)
  LD (HL),A
  ;Change HatVal
  LD HL,_HatValList
  ADD HL,DE
  LD A,C
  AND $03
  ADD (HL)
  INC HL
  LD H,(HL)
  LD L,A
  JR nc,++
  INC H
++
  LD A,(HL)
  LD HL,_HatVal
  ADD HL,DE
  LD (HL),A
  ;Change stored anim ID
  LD HL,_AnimID
  ADD HL,DE
  LD (HL),C
  CALL Actor_LoadAnim
+++
  JP Actor_Draw

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
  LD HL,_AnimPtrList
  ADD HL,DE
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  PUSH HL
    CALL MemFree        ;Free Sprite Relative Data
    LD D,B
    LD E,C
    CALL MemFree        ;Free Actor Data
  POP HL
  LD A,$80      ;Test for RAM animations
  CP H
  JP nc,EndTask
  ;Free the eight pointers in the RAM anim area
  LD C,8
  LD A,L
  ADD 16
  LD L,A
  JR nc,+
  INC H
+
-
  DEC HL
  LDD A,(HL)
  LD E,(HL)
  CP $80
  JR c,+        ;Don't free if it's a ROM pointer
  LD D,A
  PUSH HL
    CALL MemFree
  POP HL
+
  DEC C
  JR nz,-
  LD D,H
  LD E,L
  CALL MemFree  ;Free the RAM anim area
  JP EndTask

Actor_Animate:
;Perform animation frame
;Are we even walking?
  LD HL,_AnimID
  ADD HL,DE
  LDD A,(HL)
  BIT 2,A
  RET z
;Is the anim frame finished?
  DEC (HL)
  RET nz
  LD (HL),$05   ;Debug value
;Grab the pointers for animating
  DEC HL
  LDD A,(HL)    ;Anim data
  LD C,A
  LDD A,(HL)
  LD B,A
;Are we looking at the end?
  LD A,(BC)
  ADD A
  JR nc,+
;End of animation; go back to start
  JR Actor_LoadAnim
+   ;Real animation; go animate!
  LDD A,(HL)    ;Rel data
  LD L,(HL)
  LD H,A
  LD A,(BC)     ;Sprite change bitfield
  INC BC
;Move each sprite
-
  RRA
  JR c,+
    ;this sprite did not change
  INC HL
  INC HL
  INC HL
  INC HL
  JR ++
+   ;this sprite changed
  PUSH AF
    LD A,(BC)
    RLA
    JR nc,+
    INC (HL)
+
    RLA
    JR nc,+
    DEC (HL)
+
    INC HL
    RLA
    JR nc,+
    INC (HL)
+
    RLA
    JR nc,+
    DEC (HL)
+
    INC HL
    LD A,(BC)
    AND $07
    BIT 2,A
    JR z,+  ;Sign extend
    OR $F8
+
    ADD (HL)
    LDI (HL),A
    LD A,(BC)
    INC BC
    AND %00001000
    JR z,+
    RLCA
    RLCA
    XOR (HL)
    LD (HL),A
+
    INC HL
  POP AF
++
  OR A  ;End check
  JR nz,-
;Put the anim pointer back
  LD HL,_AnimPtr
  ADD HL,DE
  LD (HL),B
  INC HL
  LD (HL),C
  RET

Actor_LoadAnim:
;DE-> Actor data
;Go get the animation
  LD HL,_AnimID
  ADD HL,DE
  LD A,(HL)
  AND $03
  ADD A     ;Turn into table offset
  LD HL,_AnimPtrList
  ADD HL,DE
  ADD (HL)
  INC HL
  LD H,(HL)
  LD L,A
  JR nc,+
  INC H
+
  LDI A,(HL)    ;Get initial anim data pointer
  LD B,(HL)
  LD C,A
;Load sprite count
  LD HL,_SprCount
  ADD HL,DE
  LD A,(BC)
  AND $07
  LD (HL),A
;Load initial data into anim ram
  LD HL,_RelData
  ADD HL,DE
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  LD A,(BC)
  INC BC
  PUSH DE
    PUSH BC
      LD D,A
      AND $F0
      RRCA
      LD E,A    ;Starting tile
      LD A,$07
      AND D
      LD C,A    ;Sprite count
      LD A,$08
      AND D
      RRCA
      RRCA
      RRCA
      LD B,A    ;Starting Attribute
      XOR A     ;Starting Y, X
-
      LDI (HL),A    ;Y
      LDI (HL),A    ;X
      LD (HL),E     ;Tile
      INC HL
      LD (HL),B     ;Attribute
      INC HL
      DEC C
      JR nz,-
;Run first frame of animation, correcting X and Y
      LD A,$07
      AND D     ;Sprite count
      LD DE,0   ;Initial X,Y
    POP BC
-
    PUSH AF
      DEC HL    ;moving backwards
      INC BC
      LD A,(BC)     ;Attributes
      RRCA
      AND %01110000
      XOR (HL)
      LDD (HL),A
      LD A,(BC)     ;Tile change
      AND $1F
      BIT 4,A
      JR z,+
      ;Sign extend
      OR $E0
+
      ADD (HL)
      LDD (HL),A
      DEC BC
      LD A,(BC)     ;X movement
      AND $0F
      BIT 3,A
      JR z,+
      ;Sign extend
      OR $F0
+
      INC A
      JR nz,+
      ;Sentinel for 8
      LD A,9
+
      DEC A
      ADD D
      LD D,A
      LDD (HL),A
      LD A,(BC)     ;Y movement
      AND $F0
      SWAP A
      BIT 3,A
      JR z,+
      ;Sign extend
      OR $F0
+
      INC A
      JR nz,+
      ;Sentinel for 8
      LD A,9
+
      DEC A
      ADD E
      LD E,A
      LD (HL),A
      INC BC
      INC BC
    POP AF
    DEC A
    JR nz,-
;Chase tail for subsequent animation data
    LD A,(BC)
    INC BC
    LD D,A
    LD A,(BC)
    LD C,A
    LD B,D
  POP DE
;Load animation pointer
  LD HL,_AnimPtr+1
  ADD HL,DE
  LD (HL),B
  DEC HL
  LD (HL),C
  RET

Actor_Draw:
;DE-> Actor data
;Destroys all
  CALL Actor_Animate
;Move visual data to shadow OAM
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
;Maginify movements by 4 (x) and 3 (y) constant for hitboxing
      BIT 7,B
      JR z,+
      LD A,B
      SUB 4
      LD B,A
      JR ++
+
      LD A,B
      ADD 4
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
      INC HL
      INC HL
+
;Test X delta
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
  RST $00
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
