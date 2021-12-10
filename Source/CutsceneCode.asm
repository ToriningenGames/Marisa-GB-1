;Cutscenes

;Cutscenes are functions. Cutscenes are responsible for the following tasks:
    ;Camera movement
    ;Speech initiation
    ;Automated movement
    ;Map switching
;Generally, gluing the various game features together
;Every cutscene bit that may be needed:
    ;Load a map
    ;Load a song
    ;Wait for time T
    ;Move actor from point A to point B over time T
    ;Move camera from point A to point B over time T
    ;Change palette
    ;Play actor animation
    ;Open door
    ;Stopping player controlled movement
    ;Try to never have a "Call this function" function
;Cutscenes will be responsible for tracking which character is which, and where,
;EXCEPT for the hat and the player; IDs for those are available at $C0E9/A
;Cutscene data is abstracted from ID juggling by using an index system;
;more detail in the actor creation commands
;Each cutscene piece refers to a function call
    ;1 byte:  function to call
    ;2 bytes: data

;IMPORTANT: Cutscene Actor 0 must always be the hat,
       ;and Cutscene Actor 1 must always be Marisa!
       ;Actor 1 is assumed to be playable,
       ;and Actor 0 is assumed to be assignable.

.include "ActorData.asm"

.include "mapDef.asm"

.SECTION "Cutscene Data" ALIGN 256 FREE

;Cutscene function signature:
    ;Some are tasks
    ;DE->Data
;Cutscene abilities:
;End (If D == E)
;Disable player input
;Enable player input
;Run Text
;Set camera
;Move camera
;Create actor
;Destroy actor
;Set actor position
;Animate actor
;Move actor
;Load object palette
;Load background palette
;Load map
;Load song
;Load song panning
;Assign hat to actor
;Set actor speed
;Alter Map
;Shoot Danmaku
;Wait for time
;Wait on text

;Attach hat to character
;Detach hat from characters

;Action IDs are indexes into this table, with the following notes:
    ;Bit 7:
        ;clear calls the action as a task
        ;set set calls it as a function
    ;Bit 6:
        ;clear calls the action with DE as-is
        ;set uses E as a var number.
            ;E is replaced with the value at $C000+var,
            ;D is added with the value at $C001+var
Cutscene_LUT:
 .dw Cutscene_End
 .dw Cutscene_InputChange
 .dw Cutscene_CutsceneCall
 .dw TextStart
 .dw Cutscene_CameraSet
 .dw Cutscene_CameraMove
 .dw Cutscene_ActorNew
 .dw Cutscene_ActorDelete
 .dw Cutscene_ActorAnimate
 .dw Cutscene_ActorMovement
 .dw Cutscene_HatAssign
 .dw Cutscene_ObjectsLoad
 .dw Cutscene_MapLoad
 .dw Cutscene_SongLoad
 .dw Cutscene_SongPan
 .dw LoadRectToVRAM_Task
 .dw Cutscene_DanmakuInit
 .dw Cutscene_VarAdd
 .dw Cutscene_Task      ;CsJump
 .dw Cutscene_VarSet
 .dw Cutscene_CameraSnap
 .dw Cutscene_RelJump
 .dw Cutscene_VarToVar  ;CsSetVarVar
 .dw Cutscene_VarMultiply
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_MapWait
 .dw Cutscene_Wait
 .dw Cutscene_TextWait
 .dw Cutscene_ObjPaletteLoad
 .dw Cutscene_BkgPaletteLoad

CharaTypes:
 .dw HatActorData
 .dw CharaActorData
 .dw AliceActorData
 .dw ReimuActorData
 .dw NarumiActorData
 .dw FairyActorData
 .dw MushroomActorData

.DEFINE Cutscene_Actors $C0A0
.EXPORT Cutscene_Actors
.DEFINE Cutscene_ActorSetup $C0C0

.DEFINE varPage $C0
.DEFINE Cutscene_VarPage varPage
.EXPORT Cutscene_VarPage

.ENDS

.SECTION "Cutscene Code" FREE
;Cutscene loop
Cutscene_Task:
;DE->Cutscene data
  LD B,D
  LD C,E
_Cutscene_ItemReturn:
-
  LD A,(BC)
  INC BC
  LD H,>Cutscene_LUT
  SLA A     ;Carry out here important (Same task cutscene item)
  LD L,A
  LD A,(BC)
  INC BC
  LD E,A
  LD A,(BC)
  INC BC
  LD D,A
  BIT 7,L   ;Var indirection indicator
  JR z,++
  RES 7,L
  PUSH HL   ;Grab DE from vars
  PUSH AF
    LD H,varPage
    LD L,E
    LD E,(HL)
    INC L
    LD A,D
    ADD (HL)
    LD D,A
  POP AF
  POP HL
++
  JR c,+    ;Same task cutscene item
  PUSH BC
    LD C,(HL)
    INC HL
    LD B,(HL)
    CALL NewTask
  POP BC
  JR nc,-
  DEC BC    ;If task creation failed, try again next frame
  DEC BC
  DEC BC
  CALL HaltTask
  JR -
+
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  JP HL

;Cutscene functions
;These are not tasks

Cutscene_CameraSnap:
  PUSH BC
    CALL CameraSnap
  POP BC
  JR _Cutscene_ItemReturn

Cutscene_End:
  LD A,D
  CP E
  JR nz,_Cutscene_ItemReturn
  JP EndTask

Cutscene_BkgPaletteLoad:
;D= New background palette
  LD HL,BkgPal
  LD (HL),D
  JR _Cutscene_ItemReturn

Cutscene_VarSet:
;D= variable to set
;E= value to set to
  LD H,varPage
  LD L,D
  LD (HL),E
  JR _Cutscene_ItemReturn

Cutscene_ObjPaletteLoad:
;D= New OBJ0 palette
;E= New OBJ1 palette
  LD HL,SpritePal0
  LD (HL),D
  INC L
  LD (HL),E
  JR _Cutscene_ItemReturn

Cutscene_Wait:
;DE=Time
--
  CALL HaltTask
  DEC E
  JR nz,--
  DEC D
  JR nz,--
  JR _Cutscene_ItemReturn

Cutscene_VarToVar:
;D= dest
;E= src
  LD H,varPage
  LD L,E
  LD A,(HL)
  LD L,D
  LD (HL),A
  JR _Cutscene_ItemReturn

Cutscene_MapWait:
  LD DE,hotMap
-
  CALL HaltTask
  LD A,(DE)
  INC A
  JR nz,-
  JR _Cutscene_ItemReturn

Cutscene_TextWait
  LD DE,TextStatus
-
  CALL HaltTask
  LD A,(DE)
  CP textStatus_done
  JR nz,-
  JP _Cutscene_ItemReturn

Cutscene_CutsceneCall:
;DE=Cutscene to run
-
  PUSH BC
    LD BC,Cutscene_Task
    CALL NewTask
    LD A,B
  POP BC
  JR nc,+
  CALL HaltTask
  JR -
+
  CALL WaitOnTask
  JP _Cutscene_ItemReturn

Cutscene_VarAdd:
;D= variable to add to
;E= value to add
  LD H,varPage
  LD L,D
  LD A,(HL)
  ADD E
  LD (HL),A
  JP _Cutscene_ItemReturn

Cutscene_VarMultiply:
;D= variable involved
;E= multiplier
  PUSH BC
    LD H,varPage
    LD L,D
    LD B,(HL)
    LD C,E
    CALL Multiply
    LD (HL),C
    INC L
    LD (HL),B
  POP BC
  JP _Cutscene_ItemReturn
  
Cutscene_RelJump:
;E= 0 to go
;D= offset
  LD A,E
  OR A
  JP nz,_Cutscene_ItemReturn
  LD A,D
  RLCA
  JR c,+
  ;Positive offset
  LD A,D
  ADD C
  LD C,A
  LD A,0
  ADC B
  LD B,A
  JP _Cutscene_ItemReturn
+ ;Negative offset
  LD A,C
  ADD D
  LD C,A
  LD A,B
  ADC -1
  LD B,A
  JP _Cutscene_ItemReturn


;These are tasks

Cutscene_CameraMove:
;D= %DDSSSSSS
    ;||++++++--- Speed (2.4)
    ;++--------- Movement direction
;E= Distance
;Meanings:
;Direction:
    ;0, camera moves left
    ;1, camera moves down
    ;2, camera moves right
    ;3, camera moves up
;Distance:
    ;How many pixels to move the camera
;Speed:
    ;Pixels/frame
  ;Modify direction just a tad to be easier to test
  LD A,$40
  ADD D
  LD D,A
;Up down/Left right distinction
  LD C,<BkgVertScroll
  BIT 6,D
  JR z,+
  INC C
+
;Convert E to 4.4 format
  LD B,D
  LD A,$3F
  AND D
;  RLA  ;When speed is in 3.3
  LD D,A
  XOR A
  BIT 7,B
  LD B,>BkgVertScroll
  JR z,+
-   ;Down/Right
  ADD D
  LD L,A    ;Delta accumulator
  AND $F0
  SWAP A
  LD H,A
  LD A,(BC)
  ADD H
  LD (BC),A
  LD A,E        ;Check if distance covered
  SUB H
  JR c,++
  LD E,A
  LD A,L
  AND $0F       ;Integer applied; only accumulate fractional
  CALL HaltTask
  JR -
++
  CPL       ;Correct for overshoot
  INC A
  LD E,A
  LD A,(BC)
  SUB E
  LD (BC),A
  JP EndTask
+
-   ;Up/Left
  ADD D
  LD L,A
  AND $F0
  SWAP A
  LD H,A
  LD A,(BC)
  SUB H
  LD (BC),A
  LD A,E        ;Check if distance covered
  SUB H
  JR c,++
  LD E,A
  LD A,L
  AND $0F
  CALL HaltTask
  JR -
++
  CPL       ;Correct for overshoot
  INC A
  LD E,A
  LD A,(BC)
  ADD E
  LD (BC),A
  JP EndTask

Cutscene_CameraSet:
;D = Camera X
;E = Camera Y
  LD HL,BkgVertScroll
  LD (HL),E
  INC L
  LD (HL),D
  JP EndTask

Cutscene_ActorNew:
;D= %CCCIIIII
    ;   +++++--- Reference ID
    ;+++-------- Character
;E= Character type
;Characters:
    ;0: Hat
    ;1: Marisa
    ;2: Alice
    ;3: Reimu
    ;4: Narumi
    ;5: Fairy
  LD H,>Cutscene_Actors
  LD A,$1F
  AND D
  ADD <Cutscene_Actors
  LD L,A
;Should the slot already be filled, do we
    ;Delete the old one?
    ;Forgo the new one?     v
  LD A,(HL)
  OR A
  JP nz,EndTask
  LD A,$E0
  AND D
  PUSH HL
    SWAP A
    ADD <CharaTypes
    LD L,A
    LD H,>CharaTypes
    LDI A,(HL)
    LD H,(HL)
    LD L,A
    LD BC,Actor_FrameInit
    LD A,E
    LD D,H
    LD E,L
    ;Put actors in the back so any cutscenes moving them always run before they're drawn
    ;Should also reduce priority flicker under load, since there's less space for vBlank to happen in
    CALL NewTaskLo
++
  POP HL
  JP c,EndTask
  LD (HL),B
  JP EndTask

Cutscene_ActorDelete:
;D= %000IIIII
    ;   +++++--- Reference ID
  LD HL,Cutscene_Actors
  LD A,$1F
  AND D
  ADD L
  LD L,A
  ;Send deletion message
  LD A,(HL)
  LD (HL),0
  OR A
  JP z,EndTask
  CALL Access_ActorDE
  LD DE,_ControlState
  ADD HL,DE
  LD (HL),$FF   ;Message to self-destruct
  JP EndTask

Cutscene_ActorMovement:
;D= %DDDIIIII
    ;|||+++++--- Reference ID
    ;+++-------- Action
    ;               0: Set X position
    ;               1: Set Y position
    ;               2: Set actor speed
    ;               3: Move actor left
    ;               4: Move actor down
    ;               5: Move actor right
    ;               6: Move actor up
;E= Value
    ;Set X, Y: Position (pixels)
    ;Actor speed: Pixels/frame (4.4)
    ;Move actor U/L/D/R: Distance (pixels)
    ;Anim speed: speed val
  LD A,$1F
  AND D
  ADD A,<Cutscene_Actors
  LD C,A
  LD A,>Cutscene_Actors
  ADC 0
  LD B,A
  ;Send the message
-
  LD A,(BC)
  OR A
  JR nz,+
  CALL HaltTask ;If actor does not exist, wait for them
  JR -
+   ;Set the message
  CALL Access_ActorDE
  LD A,$E0
  AND D
  SWAP A
  RRA
  LD B,A
  LD C,E
    ;Modify the actor data
  INC B
  DEC B
  JR nz,+
  ;Set X
  LD DE,_MasterX
  XOR A
  JR ++
+
  DEC B
  JR nz,+
  ;Set Y
  LD DE,_MasterY
  XOR A
  JR ++
+
  DEC B
  JR nz,+
  ;Set speed
  LD DE,_MoveSpeed
  SWAP C
  LD A,$F0
  AND C
  LD B,A
  LD A,$0F
  AND C
  LD C,A
  LD A,B
  LD B,0
  JR ++
+
  DEC B
  DEC B
  DEC B
  DEC B
  DEC B ;Options 3-6 should now be <0
  BIT 7,B   ;Is it now negative?
  JR z,++
  ;Move actor U/L/D/R
  LD D,H
  LD E,L
  LD A,4
  ADD B
  ;Set BC
  LD B,C
  LD C,0
  JP Actor_DistMove
++
  ADD HL,DE
  LDI (HL),A
  LD (HL),C
  JP EndTask

Cutscene_ActorAnimate:
;D= %DDDIIIII
    ;|||+++++--- Reference ID
    ;+++-------- Action
    ;               0: Set anim speed
    ;               1: Play animation
;E= Value
    ;Play animation: anim ID
    ;Anim speed: speed val
  LD H,>Cutscene_Actors
  LD A,$1F
  AND D
  ADD A,<Cutscene_Actors
  LD L,A
  ;Set the message
  LD A,$E0
  AND D
  SWAP A
  RRA
  LD B,A
  LD C,E
  ;Send the message
-
  LD A,(HL)
  OR A
  JR nz,+
  LD E,L
  CALL HaltTask ;If actor does not exist, wait for them
  LD L,E
  LD H,>Cutscene_Actors
  JR -
+   ;Modify the actor data
  CALL Access_ActorDE
  INC B
  DEC B
  JR nz,+
  ;Set anim speed
  LD DE,_AnimSpeed
+
  DEC B
  JR nz,+
  ;New Animation
  LD DE,_AnimChange
+
  ADD HL,DE
  LD (HL),C
  JP EndTask

Cutscene_MapLoad:
;DE->Map Data
;Load in the new map
  XOR A
  LD (hotMap),A
-
  LD BC,LoadMap_Task
  CALL NewTask
  JR nc,+
  CALL HaltTask
  JR -
+
;Wait for map to be loaded
  LD A,B
  CALL WaitOnTask
;Put map on screen
  JP ShowMap_Task

Cutscene_ObjectsLoad:
;DE->Objects data
;Load in the boundaries
  LD C,8
  LD HL,ObjArea
-
  LD A,(DE)
  INC DE
  LDI (HL),A
  DEC C
  JR nz,-
  JP EndTask

Cutscene_SongLoad:
;DE->Song Data
  LD B,D
  LD C,E
  CALL MusicLoad
  LD A,$FF
  LD (musicglobalbase+1),A
  LDH ($26),A
  JP EndTask

Cutscene_SongPan:
;D= Shadow $FF24
;E= Shadow $FF25
  LD A,D
  LDH ($24),A
  LD A,E
  LDH ($25),A
  JP EndTask

Cutscene_InputChange:
;D= Actor ID
;E= New control state
;Send message to actor that control state is now X?
  LD A,D
  ADD <Cutscene_Actors
  LD C,A
  LD B,>Cutscene_Actors
  ;Get the actor task, once extant
-
  LD A,(BC)
  OR A
  JR nz,+
  CALL HaltTask
  JR -
+ ;Insert new Existence status
  CALL Access_ActorDE
  LD BC,_ControlState
  ADD HL,BC
  LD (HL),E
;Clear out button state, if player character
  LD A,1
  CP D
  JR nz,+
  LD BC,_ButtonState-_ControlState
  ADD HL,BC
  LD (HL),0
+
  JP EndTask

Cutscene_HatAssign:
;D= ID to assign hat to (self to unassign)
;E= ID of hat
  LD A,D
  ADD <Cutscene_Actors
  LD C,A
  LD B,>Cutscene_Actors
  ;Get actor task, once it exists
-
  LD A,(BC)
  OR A
  JR nz,+
  CALL HaltTask
  JR -
+
  CALL Access_ActorDE
  LD A,E
  LD D,H
  LD E,L
  ;Get hat
  ADD <Cutscene_Actors
  LD C,A
  ;Get actor task, once it exists
-
  LD A,(BC)
  OR A
  JR nz,+
  CALL HaltTask
  JR -
+
  CALL Access_ActorDE
  LD BC,_ParentChar
  ADD HL,BC
  LD (HL),E
  INC HL
  LD (HL),D
  JP EndTask

Cutscene_DanmakuInit:
;D= Actor ID
;E= Danmaku type
  LD A,D
  ADD <Cutscene_Actors
  LD C,A
  LD B,>Cutscene_Actors
  ;Get actor task, once it exists
-
  LD A,(BC)
  OR A
  JR nz,+
  CALL HaltTask
  JR -
+
  LD B,E
  LD C,A
  CALL Access_ActorDE
  INC HL
  INC HL
  INC HL
  LDI A,(HL)
  LD D,A
  INC HL
  LD E,(HL)
  LD A,B
  ;JP PatternFire
  JP EndTask

.ENDS
