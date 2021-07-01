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

.SECTION "Cutscene Code" ALIGN 256 FREE

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
 .dw HatFrame
 .dw CharaFrame
 .dw AliceFrame
 .dw ReimuFrame
 .dw NarumiFrame
 .dw FairyFrame

.DEFINE Cutscene_Actors $C0A0
.EXPORT Cutscene_Actors

.DEFINE varPage $C0
.DEFINE Cutscene_VarPage varPage
.EXPORT Cutscene_VarPage

;Cutscene loop
Cutscene_Task:
;DE->Cutscene data
  LD B,D    ;Do not control player; cutscenes can have player movement
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
  JP z,_Cutscene_ItemReturn
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
  SUB D
  LD C,A
  LD A,B
  SBC -1
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
    ;0, camera moves up
    ;1, camera moves left
    ;2, camera moves down
    ;3, camera moves right
;Distance:
    ;How many pixels to move the camera
;Speed:
    ;Pixels/frame
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
  SWAP A
  ADD <CharaTypes
  PUSH HL
    LD L,A
    LD H,>CharaTypes
    LD C,(HL)
    INC HL
    LD B,(HL)
    CP <CharaTypes    ;Check for hats
    JR z,+
    CALL NewTask
    JR ++
+
    CALL NewTaskLo    ;Hats go last b/c they're dependent on their parent's position
++
  POP HL
  LD (HL),B
  JP EndTask

Cutscene_ActorDelete:       ;TEST
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

.DEFINE CsChHat    0
.DEFINE CsChMarisa 1
.DEFINE CsChAlice  2
.DEFINE CsChReimu  3
.DEFINE CsChNarumi 4
.DEFINE CsChFairy  5

.DEFINE CsAnFaceLeft    0
.DEFINE CsAnFaceDown    1
.DEFINE CsAnFaceRight   2
.DEFINE CsAnFaceUp      3
.DEFINE CsAnWalkLeft    4
.DEFINE CsAnWalkDown    5
.DEFINE CsAnWalkRight   6
.DEFINE CsAnWalkUp      7

.DEFINE CsDirLeft   0
.DEFINE CsDirDown   1
.DEFINE CsDirRight  2
.DEFINE CsDirUp     3

.MACRO CsWait ARGS time
 .db $80+28
 .dw time+$100
.ENDM
.MACRO CsWaitVar ARGS var, timebase
 .IF NARGS >= 3
 .db $C0+28,var,>basetime
 .ELSE
 .db $C0+28,var,$01     ;default +$100 to match CsWait
 .ENDIF
.ENDM
.MACRO CsEnd
 .db $80
 .dw 0
.ENDM
.MACRO CsEndVar ARGS var, check
 .IF NARGS >= 3
 .db $C0,var,check
 .ELSE
 .db $C0,var,0
 .ENDIF
.ENDM
.MACRO CsWaitText
 .db $80+29
 .dw 0      ;Dummy
.ENDM
.MACRO CsInputChange ARGS ID, control
 .db 1,control,ID
.ENDM
.MACRO CsInputChangeVar ARGS var, ID
 .db $40+1,var,ID
.ENDM
.MACRO CsRunText ARGS TextPtr
 .db 3
 .dw TextPtr
.ENDM
.MACRO CsRunTextVar ARGS var, textbase
 .IF NARGS >= 3
 .db $40+3,var,>textbase
 .ELSE
 .db $40+3,var,0
 .ENDIF
.ENDM
.MACRO CsSetCamera ARGS X, Y
 .db 4,Y,X
.ENDM
.MACRO CsSetCameraVar ARGS var, morex
 .IF NARGS >= 3
 .db $40+4,var,morex
 .ELSE
 .db $40+4,var,0
 .ENDIF
.ENDM
.MACRO CsMoveCameraSpeed ARGS dir, speed, dist
;I want to move in [dir], and go [dist] via [speed] pixels/frame
 .db 5,dist,(dir<<6) | ((speed*16) & $3F)
.ENDM
.MACRO CsMoveCameraSpeedVar ARGS var, dir=0, morespeed
 .IF NARGS >= 3
 .db $40+5,var,(dir<<6) | ((morespeed*16) & $3F)
 .ELSE
 .db $40+5,var,(dir<<6)
 .ENDIF
.ENDM
.MACRO CsMoveCameraTime ARGS dir, time, dist
;I want to move in [dir], and go [dist] in exactly [time] frames
 .db 5,dist,(dir<<6) | (((dist/time)*16) & $3F)
.ENDM
.MACRO CsNewActor ARGS ID, species, race
 .db 6,race,(species << 5) | ID
.ENDM
.MACRO CsNewActorVar ARGS var, ID, speciesmod
 .IF NARGS >= 3
 .db $40+6,var,(speciesmod << 5) | ID
 .ELSE
 .db $40+6,var,ID
 .ENDIF
.ENDM
.MACRO CsDeleteActor ARGS ID
 .db 7,0,ID
.ENDM
.MACRO CsSetActorX ARGS ID, X
 .db 9,(X+8) & $FF,ID | ((0)*32)
.ENDM
.MACRO CsSetActorY ARGS ID, Y
 .db 9,(Y+16) & $FF,ID | ((1)*32)
.ENDM
.MACRO CsSetActor ARGS ID, X, Y
 .db 9,(X+8)  & $FF,ID | ((0)*32)
 .db 9,(Y+16) & $FF,ID | ((1)*32)
.ENDM
.MACRO CsSetActorXVar ARGS var, ID
 .db $40+9,var,ID | ((0)*32)
.ENDM
.MACRO CsSetActorYVar ARGS var, ID
 .db $40+9,var,ID | ((1)*32)
.ENDM
.MACRO CsSetActorVar ARGS varx, vary, ID
  CsSetActorXVar varx,ID
  CsSetActorYVar vary,ID
.ENDM
.MACRO CsAnimateActor ARGS ID, anim
 .db 8,anim,ID | ((1)*32)
.ENDM
.MACRO CsAnimateActorVar ARGS var, ID
 .db $40+8,var,ID | ((1)*32)
.ENDM
.MACRO CsAnimSpeed ARGS ID, animspeed
 .db 8,animspeed,ID | ((0)*32)
.ENDM
.MACRO CsAnimSpeedVar ARGS var, ID
 .db $40+8,var,ID | ((0)*32)
.ENDM
.MACRO CsSetActorSpeed ARGS ID, speed
 .db 9,speed*16,ID | ((2)*32)
.ENDM
.MACRO CsSetActorSpeedVar ARGS var, ID
 .db $40+9,var,ID | ((2)*32)
.ENDM
.MACRO CsMoveActor ARGS ID, dir, dist
 .db 9,dist,ID | ((dir + 3)*32)
.ENDM
.MACRO CsMoveActorVar ARGS var, ID, dir
 .IF NARGS >= 3
 .db $40+9,var,ID | ((dir + 3)*32)
 .ELSE
 .db $40+9,var,ID | ((3)*32)
 .ENDIF
.ENDM
.MACRO CsMoveActorSpeed ARGS ID, dir, speed, dist
 .db 9,speed*16,ID | ((2)*32)
 .db 9,dist, ID | ((dir + 3)*32)
.ENDM
.MACRO CsMoveActorSpeedVar ARGS varspeed, vardist, ID, dir
 .db $40+9,varspeed,ID | ((2)*32)
 .IF NARGS >= 3
 .db $40+9,vardist, ID | ((dir + 3)*32)
 .ELSE
 .db $40+9,vardist, ID | ((3)*32)
 .ENDIF
.ENDM
.MACRO CsMoveActorDist ARGS ID, dir, dist
 .db 9,dist,ID | ((dir + 3)*32)
.ENDM
.MACRO CsMoveActorDistVar ARGS var, ID, dir
 .IF NARGS >= 3
 .db $40+9,vardist,ID | ((dir + 3)*32)
 .ELSE
 .db $40+9,vardist,ID | ((3)*32)
 .ENDIF
.ENDM
.MACRO CsMoveActorTime ARGS ID, dir, time, dist
 .db 9,dist/time*16,ID | ((2)*32)
 .db 9,dist, ID | ((dir + 3)*32)
.ENDM
.MACRO CsLoadObjColor ARGS color0, color1
 .db $80+30,color1,color0
.ENDM
.MACRO CsLoadObjColorVar ARGS var, morecolor0
 .IF NARGS >= 2
 .db $C0+30,var,morecolor0
 .ELSE
 .db $C0+30,var,0
 .ENDIF
.ENDM
.MACRO CsLoadBkgColor ARGS color
 .db $80+31,0,color
.ENDM
.MACRO CsLoadBkgColorVar ARGS var, morecolor
 .IF NARGS >= 2
 .db $C0+31,var,morecolor
 .ELSE
 .db $C0+31,var,0
 .ENDIF
.ENDM
.MACRO CsLoadObj ARGS objs
 .db 11
 .dw objs
.ENDM
.MACRO CsLoadObjVar ARGS var, objbase
 .IF NARGS >= 2
 .db $40+11,var,>objbase
 .ELSE
 .db $40+11,var,0
 .ENDIF
.ENDM
.MACRO CsLoadMap ARGS map
 .db 12
 .dw map
.ENDM
.MACRO CsLoadMapVar ARGS var, mapbase
 .IF NARGS >= 2
 .db $40+12,var,>mapbase
 .ELSE
 .db $40+12,var,0
 .ENDIF
.ENDM
.MACRO CsWaitMap
 .db $80+27
 .dw 0      ;Dummy
.ENDM
.MACRO CsLoadSong ARGS song
 .db 13
 .dw song
.ENDM
.MACRO CsLoadSongVar ARGS var, songbase
 .IF NARGS >= 2
 .db $40+13,var,>songbase
 .ELSE
 .db $40+13,var,0
 .ENDIF
.ENDM
.MACRO CsPanSong ARGS channelSelect, stereoVolume
 .db 14,channelSelect,stereoVolume
.ENDM
.MACRO CsPanSongVar ARGS var, moreStereoVolume
 .IF NARGS >= 2
 .db $40+14,var,moreStereoVolume
 .ELSE
 .db $40+14,var,0
 .ENDIF
.ENDM
.MACRO CsAssignHat ARGS hat, ID
 .db 10,hat,ID
.ENDM
.MACRO CsAlterMap ARGS alteration
 .db 16
 .dw alteration
.ENDM
.MACRO CsAlterMapVar ARGS var, altbase
 .IF NARGS >= 2
 .db $40+16,var,>altbase
 .ELSE
 .db $40+16,var,0
.ENDM
.MACRO CsShootDanmaku ARGS ID, type
 .db 17,type,ID
.ENDM
.MACRO CsShootDanmakuVar ARGS var, ID
 .db $40+17,var,ID
.ENDM
.MACRO CsCall ARGS cs
 .db $80+2
 .dw cs
.ENDM
.MACRO CsCallVar ARGS var, csbase
 .IF NARGS >= 2
 .db $C0+2,var,>csbase
 .ELSE
 .db $C0+2,var,0
 .ENDIF
.ENDM
.MACRO CsAddVar ARGS var, value
 .db $80+17,value,var
.ENDM
.MACRO CsAddVarVar ARGS var1, var2
 .db $C0+17,var2,var1
.ENDM
.MACRO CsSetVar ARGS var, value
 .db $80+19,value,var
.ENDM
.MACRO CsSetVarVar ARGS var1, var2
 .db $80+22,var2,var1
.ENDM
.MACRO CsJump ARGS cs
 .db $80+18
 .dw cs
.ENDM
.MACRO CsJumpVar ARGS var, csbase
 .IF NARGS >= 2
 .db $C0+18,var,>csbase
 .ELSE
 .db $C0+18,var,0
 .ENDIF
.ENDM
.MACRO CsJumpRel ARGS offs
 .db $80+21,0,offs
.ENDM
.MACRO CsJumpRelVar ARGS var, offs
 .db $C0+21,var,offs
.ENDM
.MACRO CsSnapCamera
 .db $80+20,0,0
.ENDM
.MACRO CsMultVar ARGS var, scale
 .db $80+23,scale,var
.ENDM


.SECTION "Cutscene Data" ALIGN 256 FREE

Cs_ComputePlayerAndCamera:
  ;Come in from right
  CsSetVarVar 16,8      ;bytes to shorts
  CsSetVarVar 18,9
  CsSetActorYVar 18,1
  CsSetActorX 1,255
  CsWait 1
  CsSnapCamera
  CsSetActorXVar 16,1
  CsEnd
  ;Come in from top
  CsSetVarVar 16,10     ;bytes to shorts
  CsSetVarVar 18,11
  CsSetActorXVar 16,1
  CsSetActorY 1,1
  CsWait 1
  CsSnapCamera
  CsSetActorYVar 18,1
  CsEnd
  ;Come in from left
  CsSetVarVar 16,12     ;bytes to shorts
  CsSetVarVar 18,13
  CsSetActorYVar 18,1
  CsSetActorX 1,1
  CsWait 1
  CsSnapCamera
  CsSetActorXVar 16,1
  CsEnd
  ;Come in from bottom
  CsSetVarVar 16,14     ;bytes to shorts
  CsSetVarVar 18,15
  CsSetActorXVar 16,1
  CsSetActorY 1,255
  CsWait 1
  CsSnapCamera
  CsSetActorYVar 18,1
  CsEnd

;Var definitions on map changes
    ;1: Entry facing direction
    ;3: Map backing type
    ;4: Map data
    ;6: Object data
    ;8: entry pos left side
    ;10: entry pos down side
    ;12: entry pos right side
    ;14: entry pos up side

Cs_MapFadeout:
  CsInputChange 1,0
  CsLoadBkgColor %11111001
  CsLoadObjColor %11100101,%11111001
  CsWait 7
  CsLoadBkgColor %11111110
  CsLoadObjColor %11111010,%11111110
  CsWait 7
  CsLoadBkgColor %11111111
  CsLoadObjColor %11111111,%11111111
  CsEnd

Cs_MapFadein:
  CsWait 5
  CsLoadBkgColor %11111110
  CsLoadObjColor %11111010,%11111110
  CsWait 5
  CsLoadBkgColor %11111001
  CsLoadObjColor %11100101,%11111001
  CsWait 5
  CsLoadBkgColor %11100100
  CsLoadObjColor %11010000,%11100100
  CsEnd

Cs_LoadInit:
  CsLoadSong SongRetrib
  CsPanSong $FF,$AA
  CsWait 45
  CsLoadBkgColor $FE
  CsWait 45
  CsLoadBkgColor $FF
  CsLoadObjColor $FF,$FF
  CsWait 45
  CsSetCamera 24,0
  CsLoadMap MapForestBKG03
  CsNewActor 0,CsChHat,0
  CsNewActor 1,CsChMarisa,0
  CsNewActor 2,CsChAlice,0
  CsWait 2
  CsInputChange 1,0     ;Cutscene control of Marisa
  CsInputChange 2,2     ;Alice, stay still
  CsAnimateActor 1,CsAnFaceDown
  CsAnimateActor 2,CsAnFaceDown
  CsAssignHat 0,1
  CsWaitMap
  CsLoadMap MapForest23map
  CsSetActor 1,130,70
  CsSetActor 2,80,55
  CsWaitMap
  CsLoadObj MapForest23obj
  CsInputChange 1,$80   ;Camera follow
  CsCall Cs_MapFadein
  CsRunText StringTestMessage   ;Testing text run with input
Cs_MakePlayable:
  CsWait 1
  CsSetActorSpeed 1,0.9
  CsAnimSpeed 1,10
  CsInputChange 1,$81   ;Playable
Cs_None:
  CsEnd

;Map to map transitions
;TODO: Something to accomodate potentially curved transistions
    ;00-01  Left turn
    ;01-11  Right turn
    ;02-24  Right turn
    ;04-31  U Turn
;TODO: Affect camera by placing Marisa on perpendicular, preset on parallel, then snap
;Order:
    ;Set Marisa trotting off in the right direction
        ;Direction in var 1
    ;Fade out
    ;Load map data
        ;Backing in var 3
        ;Map in var 4-5
        ;Obj in var 6-7
    ;Snap camera
    ;Place Marisa in the right spot
        ;Spot indexed by var 1 into var 8-14
    ;Set Marisa trotting off
        ;Direction in var 1
    ;Fade in
    ;Control

Cs_TransitionOut:
  CsInputChange 1,0
  CsSetVar 2,0
  CsAddVar 1,CsAnWalkLeft
  CsAnimateActorVar 1,1
  CsAddVar 1,-CsAnWalkLeft
  CsSetVar 20,30    ;Distance
  CsSetVarVar 21,1
  CsMultVar 21,32   ;put the dir part in its place in the byte
  CsMoveActorVar 20,1
  CsCall Cs_MapFadeout
  CsSetVarVar 2,3   ;Convert backing to short and index into back maps (26 bytes per item)
  CsSetVar 3,0
  CsMultVar 2,26
  CsLoadMapVar 2,MapBackBase
  CsWaitMap
  CsLoadMapVar 4
  CsWaitMap
  CsLoadObjVar 6
  CsEnd

Cs_TransitionIn:
  CsSetVarVar 6,1   ;Index into ComputePlayerAndCamera list (24 bytes per item)
  CsSetVar 7,0
  CsMultVar 6,24
  CsSetVar 17,0
  CsSetVar 19,0
  CsCallVar 6,Cs_ComputePlayerAndCamera
  CsCall Cs_MapFadein
  CsMoveActorVar 20,1
  CsWait 37
  CsSetVar 2,0
  CsAnimateActorVar 1,1     ;Marisa, stand still
  CsInputChange 1,$81
  CsEnd

Cs_StraightTransition:
  CsCall Cs_TransitionOut
  CsJump Cs_TransitionIn

Cs_FullTurnTransition:
  CsCall Cs_TransitionOut
  CsAddVar 1,2      ;U turn happens here
  CsAddVar 21,2*32
  CsJump Cs_TransitionIn

Cs_TransitionOutUp:
  CsAnimateActor 1,CsAnWalkUp
  CsMoveActorTime 1,CsDirUp,14,12
  CsCall Cs_MapFadeout
  CsEnd

Cs_TransitionOutLeft:
  CsAnimateActor 1,CsAnWalkLeft
  CsMoveActorTime 1,CsDirLeft,14,12
  CsCall Cs_MapFadeout
  CsEnd

Cs_TransitionOutDown:
  CsAnimateActor 1,CsAnWalkDown
  CsMoveActorTime 1,CsDirDown,14,12
  CsCall Cs_MapFadeout
  CsEnd

Cs_TransitionOutRight:
  CsAnimateActor 1,CsAnWalkRight
  CsMoveActorTime 1,CsDirRight,14,12
  CsCall Cs_MapFadeout
  CsEnd

Cs_TransitionInUp:
  CsAnimateActor 1,CsAnWalkUp
  CsMoveActorTime 1,CsDirUp,45,30
  CsCall Cs_MapFadein
  CsWait 30
  CsAnimateActor 1,CsAnFaceUp
  CsCall Cs_MakePlayable
  CsEnd

Cs_TransitionInLeft:
  CsAnimateActor 1,CsAnWalkLeft
  CsMoveActorTime 1,CsDirLeft,45,30
  CsCall Cs_MapFadein
  CsWait 30
  CsAnimateActor 1,CsAnFaceLeft
  CsCall Cs_MakePlayable
  CsEnd

Cs_TransitionInDown:
  CsAnimateActor 1,CsAnWalkDown
  CsMoveActorTime 1,CsDirDown,45,30
  CsCall Cs_MapFadein
  CsWait 30
  CsAnimateActor 1,CsAnFaceDown
  CsCall Cs_MakePlayable
  CsEnd

Cs_TransitionInRight:
  CsAnimateActor 1,CsAnWalkRight
  CsMoveActorTime 1,CsDirRight,45,30
  CsCall Cs_MapFadein
  CsWait 30
  CsAnimateActor 1,CsAnFaceRight
  CsCall Cs_MakePlayable
  CsEnd

;List of odd room to room transitions (not straight lines)

Cs_Load01to00_1:
  CsCall Cs_TransitionOutDown
  CsLoadMap MapForestBKG03
  CsWaitMap
  CsLoadMap MapForest00
  CsWaitMap
  CsSetActor 1,160,114
  CsSetCamera 0,0
  CsCall Cs_TransitionInLeft
  CsEnd

Cs_Load00to01_1:
  CsCall Cs_TransitionOutRight
  CsLoadMap MapForestBKG04
  CsWaitMap
  CsLoadMap MapForest04
  CsWaitMap
  CsLoadObj MapForest01obj
  CsSetActor 1,137,172
  CsSetCamera 56,24
  CsCall Cs_TransitionInUp
  CsEnd

Cs_Load11to01_1:
  CsCall Cs_TransitionOutUp
  CsLoadMap MapForestBKG04
  CsWaitMap
  CsLoadMap MapForest04
  CsWaitMap
  CsLoadObj MapForest01obj
  CsSetActor 1,224,108
  CsSetCamera 56,24
  CsCall Cs_TransitionInLeft
  CsEnd

Cs_Load24to02_1:
  CsCall Cs_TransitionOutLeft
  CsLoadMap MapForest02
  CsWaitMap
  CsSetActor 1,74,250
  CsSetCamera 0,0
  CsCall Cs_TransitionInDown
  CsEnd

Cs_Load01to11_1:
  CsCall Cs_TransitionOutRight
  CsLoadMap MapForestBKG02
  CsWaitMap
  CsLoadMap MapForest11
  CsWaitMap
  CsSetActor 1,114,-10
  CsSetCamera 0,0
  CsCall Cs_TransitionInDown
  CsEnd

Cs_Load02to24_1:
  CsCall Cs_TransitionOutUp
  CsLoadMap MapForestBKG03
  CsWaitMap
  CsLoadMap MapForest24
  CsWaitMap
  CsSetActor 1,-10,125
  CsSetCamera 0,53
  CsCall Cs_TransitionInRight
  CsEnd

Cs_Load04to31_1:
  CsCall Cs_TransitionOutUp
  CsLoadMap MapForestBKG01
  CsWaitMap
  CsLoadMap MapForest31
  CsWaitMap
  CsSetActor 1,83,0
  CsSetCamera 0,0
  CsCall Cs_TransitionInDown
  CsEnd

.ENDS
