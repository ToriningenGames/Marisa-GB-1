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
;End
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
;End
;Wait for time
;Wait on text

;Attach hat to character
;Detach hat from characters

Cutscene_LUT:
 .dw Cutscene_End
 .dw Cutscene_InputChange
 .dw Cutscene_CallCutscene
 .dw TextStart
 .dw Cutscene_CameraSet
 .dw Cutscene_CameraMove
 .dw Cutscene_ActorNew
 .dw Cutscene_ActorDelete
 .dw Cutscene_ActorAnimate
 .dw Cutscene_ActorMovement
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_MapLoad
 .dw Cutscene_SongLoad
 .dw Cutscene_SongPan
 .dw Cutscene_HatAssign
 .dw LoadRectToVRAM_Task
 .dw Cutscene_DanmakuInit
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_End
 .dw Cutscene_End
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
  SLA A     ;Carry out here important
  LD L,A
  LD A,(BC)
  INC BC
  LD E,A
  LD A,(BC)
  INC BC
  LD D,A
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
Cutscene_Wait:
--
  CALL HaltTask
  DEC E
  JR nz,--
  DEC D
  JR nz,--
  JR _Cutscene_ItemReturn

Cutscene_End:
  JP EndTask

Cutscene_TextWait
  LD DE,TextStatus
-
  CALL HaltTask
  LD A,(DE)
  CP textStatus_done
  JR nz,-
  JR _Cutscene_ItemReturn

Cutscene_BkgPaletteLoad:
;D= New background palette
  LD HL,BkgPal
  LD (HL),D
  JR _Cutscene_ItemReturn

Cutscene_ObjPaletteLoad:
;D= New OBJ0 palette
;E= New OBJ1 palette
  LD HL,SpritePal0
  LD (HL),D
  INC L
  LD (HL),E
  JR _Cutscene_ItemReturn

Cutscene_CallCutscene:
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
  JR _Cutscene_ItemReturn


;These are tasks

Cutscene_CameraMove:
;D= Distance
;E= %DDSSSSSS
    ;||++++++--- Speed (2.4)
    ;++--------- Movement direction
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
  BIT 6,E
  JR z,+
  INC C
+
;Convert E to 4.4 format
  LD B,E
  LD A,$3F
  AND E
;  RLA  ;When speed is in 3.3
  LD E,A
  XOR A
  BIT 7,B
  LD B,>BkgVertScroll
  JR z,+
-   ;Down/Right
  ADD E
  LD L,A    ;Delta accumulator
  AND $F0
  SWAP A
  LD H,A
  LD A,(BC)
  ADD H
  LD (BC),A
  LD A,D        ;Check if distance covered
  SUB H
  JR c,++
  LD D,A
  LD A,L
  AND $0F       ;Integer applied; only accumulate fractional
  CALL HaltTask
  JR -
++
  CPL       ;Correct for overshoot
  INC A
  LD D,A
  LD A,(BC)
  SUB D
  LD (BC),A
  JP EndTask
+
-   ;Up/Left
  ADD E
  LD L,A
  AND $F0
  SWAP A
  LD H,A
  LD A,(BC)
  SUB H
  LD (BC),A
  LD A,D        ;Check if distance covered
  SUB H
  JR c,++
  LD D,A
  LD A,L
  AND $0F
  CALL HaltTask
  JR -
++
  CPL       ;Correct for overshoot
  INC A
  LD D,A
  LD A,(BC)
  ADD D
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
  PUSH BC       ;Task info
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
      LDI A,(HL)
      LD B,(HL)
      LD C,A
    POP HL
  POP AF    ;Task info
  CALL HaltTask ;Become the new character
  PUSH AF
    LD H,>Cutscene_Actors
    LD A,$1F
    AND D
    ADD <Cutscene_Actors
    LD L,A
  POP AF
  LD (HL),A ;Place task
  LD A,E    ;Character Type
  LD H,B
  LD L,C
  JP HL

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
    ;               3: Move actor up
    ;               4: Move actor left
    ;               5: Move actor down
    ;               6: Move actor right
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
  LD DE,LoadMapMagicVal
  LD A,4
  JP LoadToVRAM_Task

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

Cutscene_DanmakuInit
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

.DEFINE CsDirUp     0
.DEFINE CsDirLeft   1
.DEFINE CsDirDown   2
.DEFINE CsDirRight  3

.MACRO CsWait ARGS time
 .db $A1
 .dw time+$100
.ENDM
.MACRO CsEnd
 .db $80
.ENDM
.MACRO CsWaitText
 .db $A2
 .dw 0      ;Dummy
.ENDM
.MACRO CsInputChange ARGS ID, control
 .db 1,control,ID
.ENDM
.MACRO CsRunText ARGS TextPtr
 .db 3
 .dw TextPtr
.ENDM
.MACRO CsSetCamera ARGS X, Y
 .db 4,Y,X
.ENDM
.MACRO CsMoveCameraSpeed ARGS dir, speed, dist
;I want to move in [dir], and go [dist] via [speed] pixels/frame
 .db 5,(dir<<6) | ((speed*16) & $3F),dist
.ENDM
.MACRO CsMoveCameraTime ARGS dir, time, dist
;I want to move in [dir], and go [dist] in exactly [time] frames
 .db 5,(dir<<6) | (((dist/time)*16) & $3F),dist
.ENDM
.MACRO CsNewActor ARGS ID, species, race
 .db 6,race,(species << 5) | ID
.ENDM
.MACRO CsDeleteActor ARGS ID
 .db 7,0,ID
.ENDM
.MACRO CsSetActor ARGS ID, X, Y
 .db 9,(X+8)  & $FF,ID | ((0)*32)
 .db 9,(Y+16) & $FF,ID | ((1)*32)
.ENDM
.MACRO CsAnimateActor ARGS ID, anim
 .db 8,anim,ID | ((1)*32)
.ENDM
.MACRO CsAnimSpeed ARGS ID, animspeed
 .db 8,animspeed,ID | ((0)*32)
.ENDM
.MACRO CsMoveActorSpeed ARGS ID, dir, speed, dist
 .db 9,speed*16,ID | ((2)*32)
 .db 9,dist, ID | ((dir + 3)*32)
.ENDM
.MACRO CsMoveActorTime ARGS ID, dir, time, dist
 .db 9,dist/time*16,ID | ((2)*32)
 .db 9,dist, ID | ((dir + 3)*32)
.ENDM
.MACRO CsLoadObjColor ARGS color0, color1
 .db $A3,color1,color0
.ENDM
.MACRO CsLoadBkgColor ARGS color
 .db $A4,0,color
.ENDM
.MACRO CsLoadMap ARGS Map
 .db 12
 .dw Map
.ENDM
.MACRO CsLoadSong ARGS Song
 .db 13
 .dw Song
.ENDM
.MACRO CsPanSong ARGS channelSelect, stereoVolume
 .db 14,channelSelect,stereoVolume
.ENDM
.MACRO CsAssignHat ARGS hat, ID
 .db 15,hat,ID
.ENDM
.MACRO CsAlterMap ARGS alteration
 .db 16
 .dw alteration
.ENDM
.MACRO CsShootDanmaku ARGS ID, type
 .db 17,type,ID
.ENDM
.MACRO CsCall ARGS Cs
 .db $82
 .dw Cs
.ENDM


.SECTION "Cutscene Data" FREE

Cs_Fadeout:
  CsLoadBkgColor %11111001
  CsLoadObjColor %11100101,%11111001
  CsWait 7
  CsLoadBkgColor %11111110
  CsLoadObjColor %11111010,%11111110
  CsWait 7
  CsLoadBkgColor %11111111
  CsLoadObjColor %11111111,%11111111
  CsEnd

Cs_Fadein:
  CsLoadBkgColor %11111110
  CsLoadObjColor %11111010,%11111110
  CsWait 7
  CsLoadBkgColor %11111001
  CsLoadObjColor %11100101,%11111001
  CsWait 7
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
  CsWait 45
  CsLoadMap MapForestBKG
  CsNewActor 0,CsChHat,0
  CsNewActor 1,CsChMarisa,0
  CsWait 2
  CsAnimSpeed 1,10
  CsInputChange 1,0     ;Cutscene control of Marisa
  CsWait 8
  CsAnimateActor 1,CsAnFaceDown
  CsAssignHat 0,1
  CsLoadMap MapForest13
  CsSetActor 1,125,110
  CsWait 10
  CsInputChange 1,1     ;Playable before fade-in to allow camera to set
  CsCall Cs_Fadein
  CsEnd

Cs_Load13to12_1:
  CsInputChange 1,0
  CsCall Cs_Fadeout
  CsLoadMap MapForest12
  CsSetActor 1,218,68
  CsWait 10
  CsInputChange 1,1
  CsCall Cs_Fadein
  CsEnd

Cs_Load12to13_1:
  CsInputChange 1,0
  CsCall Cs_Fadeout
  CsLoadMap MapForest13
  CsSetActor 1,12,99
  CsWait 10
  CsInputChange 1,1
  CsCall Cs_Fadein
  CsEnd

Cs_Load12to02_1:
  CsInputChange 1,0
  CsCall Cs_Fadeout
  CsLoadMap MapForest02
  CsSetActor 1,68,239
  CsWait 10
  CsInputChange 1,1
  CsCall Cs_Fadein
  CsEnd

Cs_Load02to12_1:
  CsInputChange 1,0
  CsCall Cs_Fadeout
  CsLoadMap MapForest12
  CsSetActor 1,118,30
  CsWait 10
  CsInputChange 1,1
  CsCall Cs_Fadein
  CsEnd

Cs_Reset:
  CsInputChange 1,0
  CsLoadBkgColor %10010000
  CsLoadObjColor %10000000,%10010000
  CsWait 7
  CsLoadBkgColor %01000000
  CsLoadObjColor %01000000,%01000000
  CsWait 7
  CsLoadBkgColor %00000000
  CsLoadObjColor %00000000,%00000000
  CsLoadMap MapForest13
  CsSetActor 1,128,128
  CsInputChange 1,1
  CsWait 15
  CsLoadBkgColor %01000000
  CsLoadObjColor %01000000,%01000000
  CsWait 7
  CsLoadBkgColor %10010000
  CsLoadObjColor %10000000,%10010000
  CsWait 7
  CsLoadBkgColor %11100100
  CsLoadObjColor %11010000,%11100100
Cs_LoadN23toN13_1:
Cs_LoadN13toN23_1:
Cs_LoadN13to03_1:
Cs_Load03toN13_1:
Cs_Load00to01_1:
Cs_Load01to00_1:
Cs_Load01to11_1:
Cs_Load11to01_1:
Cs_Load10to00_1:
Cs_Load20to10_1:
Cs_Load30to20_1:
Cs_Load34to00_1:
Cs_Load04to31_1:
Cs_Load22to30_1:
Cs_Load30to22_1:
Cs_Load02to24_1:
Cs_Load24to02_1:
Cs_Load11to12_1:
Cs_Load12to11_1:
Cs_Load11to21_1:
Cs_Load21to11_1:
Cs_Load21to22_1:
Cs_Load22to21_1:
Cs_Load22to23_1:
Cs_Load23to22_1:
Cs_Load22to32_1:
Cs_Load31to32_1:
Cs_Load32to31_1:
Cs_Load32to33_1:
Cs_Load33to32_1:
Cs_Load33to34_1:
Cs_Load34to33_1:
Cs_Load33to23_1:
Cs_Load23to33_1:
Cs_Load24to14_1:
Cs_Load14to24_1:
Cs_Load14to04_1:
Cs_Load04to14_1:
Cs_Load14to13_1:
Cs_Load04to03_1:
Cs_Load03to04_1:
Cs_Load03to13_1:
Cs_Load13to03_1:
Cs_Load13to23_1:
Cs_Load23to13_1:
Cs_None:
  CsEnd

.ENDS
