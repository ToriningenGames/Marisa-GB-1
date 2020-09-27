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
    ;Stopping player movement
    ;Try to never have a "Call this function" function
;Cutscenes will be responsible for tracking which character is which, and where,
;EXCEPT for the hat and the player; IDs for those are available at $C0E9/A
;Cutscene data is abstracted from ID juggling by using an index system;
;more detail in the actor creation commands
;Each cutscene piece refers to a function call
    ;1 byte:  function to call
    ;2 bytes: data
    ;1 byte:  waiting period

.SECTION "Cutscene" ALIGN 256 FREE

;Cutscene function signature:
    ;Are tasks
    ;DE->Data
;Cutscene abilities:
;0: End
;1: Disable player input
;2: Enable player input
;3: Run Text
;4: Set camera
;5: Move camera
;6: Create actor
;7: Destroy actor
;8: Set actor position
;9: Animate actor
;10: Move actor
;11: Load object palette
;12: Load background palette
;13: Load map
;14: Load song
;15: Load song panning
;16: Assign hat to actor
;17: Set actor speed
;18: Alter Map
;19: Shoot Danmaku
;32: End
;33: Wait
;34: Wait on text

;Attach hat to character
;Detach hat from characters

Cutscene_LUT:
 .dw Cutscene_End
 .dw Cutscene_InputChange
 .dw Cutscene_End
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

.include "ActorData.asm"


_Access_ActorDE:
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
Cutscene_Wait:          ;TEST
--
  CALL HaltTask
  DEC E
  JR nz,--
  DEC D
  JR nz,--
  JR _Cutscene_ItemReturn

Cutscene_End:
;  LD HL,Cutscene_Actors
;  LDI A,(HL)
;  LD C,A
;  LD A,(HL)
;  LD B,$17  ;Resume free will
;-
;  CALL MsgSend
;  CALL HaltTask
;  JR c,-
;  LD A,C
;-
;  CALL MsgSend
;  CALL HaltTask
;  JR c,-
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
  CALL _Access_ActorDE
  LD DE,_LandingPad
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
  CALL _Access_ActorDE
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
  LD A,5
  ADD B
  RRCA
  RRCA  ;Fix this later
  ;C preset
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
  CALL _Access_ActorDE
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

Cutscene_InputChange:       ;TEST
;Send message to actor that control state is now X?
  LD A,D
  RLA
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
  CALL _Access_ActorDE
  LD BC,_LandingPad
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
  CALL _Access_ActorDE
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
  CALL _Access_ActorDE
  LD BC,_ParentChar
  ADD HL,BC
  LD (HL),E
  INC HL
  LD (HL),D
  JP EndTask

Cutscene_DanmakuInit        ;WRITE
;D= Actor ID
;E= Danmaku type
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
.DEFINE CsAnIdleLeft    8
.DEFINE CsAnIdleDown    9
.DEFINE CsAnIdleRight  10
.DEFINE CsAnIdleUp     11

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
 .db 9,X+8, ID | ((0)*32)
 .db 9,Y+16,ID | ((1)*32)
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

.SECTION "Cutscene Data" FREE

;Demo cutscene
;TODO for Demo 1:
    ;Write appropriate music track
    ;Door cutscene functions
    ;Danmanku actor messages
        ;Danmaku as independent of actors?
    ;Write actor animations
        ;Reimu Floating animation would be cute (during danmaku firing)
        ;All fairy walk cycles
        ;Alice Down Walk
    ;Draw a few more faces
    ;Write up the last few actions
;General TODO:
    ;Player Cutscene control control
        ;A Marisa rewrite
;Problems:
    ;Alter Map items are not written
      ;Open Alice's door
      ;Close Alice's door
    ;Shoot Danmaku is not written
    ;The Camera Time macro can move camera too slow
        ;Same distance covered, takes more time. Problem of speed's precision
    ;Text waits before lowers too fast

;Map Alterations
;Order: width,height,source,dest
MapAlt_AliceDoorOpen:   ;Opens Alice's door
 .db 2,3
 .dw _AliceDoorOpen_Data,$9927
_AliceDoorOpen_Data:
 .db $84,$85,$84,$85,$86,$87
MapAlt_AliceDoorClose:  ;Closes Alice's door
 .db 2,3
 .dw _AliceDoorClose_Data,$9927
_AliceDoorClose_Data:
 .db $DA,$DB,$E0,$E1,$E6,$E7
;Camera starts on bottom of map
;Camera pans to top of map
  ;Camera pans over
    ;Reimu & Marisa, facing each other, having a drink. Able to face the door
    ;Narumi, off a little ways
    ;3-5 Fairies, visible throughout pan
;Alice opens door
;Alice: "..."
;Alice: "What are you all doing at my house?"
;Maris: "Partying."
;Reimu: "Alcohol."
;Alice: "And WHY at my house?"
;Maris: "Convenience."
;Reimu: "All the alcohol landed here after the explosion."
;Alice: "!!!"
;Alice: "...???"
;Maris: "Master spark. Previous owners weren't too keen on giving it up."
;Alice closes door behind her, steps off porch
;Alice: "Now would be a good time to relocate."
;Reimu: "Why?"
;Maris: "How about a drink?"
;Alice: "How about no, and how about..."
;Alice: "Getting away from my house!"
;Alice starts shooting danmaku.
;Reimu and Marisa respond in kind.
;Fairies flee
;Narumi chills
;Fadeout
OpeningDemo:
  CsPanSong $FF,$FF
  CsLoadSong SongSpark
  CsWait 15             ;Fade to black
  CsLoadBkgColor $FD
  CsWait 35
  CsLoadBkgColor $FE
  CsWait 35
  CsLoadBkgColor $FF
  CsLoadObjColor $FF,$FF
  CsWait 35
  CsLoadMap MapForest02
  CsSetCamera 0,112
  CsNewActor 0,CsChHat,0
  CsNewActor 1,CsChMarisa,0
  CsNewActor 2,CsChReimu,0
  CsNewActor 3,CsChNarumi,0
  CsNewActor 4,CsChFairy,%00011001
  CsNewActor 5,CsChFairy,%00000101
  CsNewActor 6,CsChFairy,%00101010
  CsNewActor 7,CsChFairy,%00000000
  CsAssignHat 0,1
  CsAnimSpeed 1,$05
  CsAnimSpeed 2,$05
  CsAnimSpeed 3,$05
  CsAnimSpeed 4,$05
  CsAnimSpeed 5,$05
  CsAnimSpeed 6,$05
  CsAnimSpeed 7,$05
  CsAnimateActor 1,CsAnFaceLeft
  CsAnimateActor 2,CsAnFaceRight
  CsAnimateActor 3,CsAnFaceDown
  CsAnimateActor 4,CsAnWalkUp
  CsAnimateActor 5,CsAnWalkRight
  CsAnimateActor 6,CsAnWalkLeft
  CsAnimateActor 7,CsAnWalkLeft
  CsSetActor 1,76,116
  CsSetActor 2,54,116
  CsSetActor 3,112,130
  CsSetActor 4,72,232
  CsSetActor 5,40,192
  CsSetActor 6,128,152
  CsSetActor 7,136,224
  CsWait 7      ;Wait for map load
;  CsMoveActorTime 4,CsDirUp,300,96
;  CsMoveActorSpeed 5,CsDirRight,1.5,72
;  CsMoveActorSpeed 6,CsDirLeft,1.1,40
;  CsMoveActorSpeed 7,CsDirLeft,1,96
 ;   Fade in
  CsLoadBkgColor %11111110
  CsLoadObjColor %11111000,%11111100
  CsWait 3
  CsMoveCameraTime CsDirUp,300,94      ;Not quite top of map (Keep all in view)
  CsLoadBkgColor %11111010
  CsLoadObjColor %11101000,%11111000
  CsWait 3
  CsLoadBkgColor %11111001
  CsLoadObjColor %11100100,%11111000
  CsWait 3
  CsLoadBkgColor %11101001
  CsLoadObjColor %11100100,%11101000
  CsWait 3
  CsLoadBkgColor %11100100
  CsLoadObjColor %11010000,%11100100
  CsWait 3
  CsLoadBkgColor %11100100
  CsLoadObjColor %11010000,%11100100
  CsWait 300+120    ;2 second pause
  CsAlterMap MapAlt_AliceDoorOpen   ;Door open
  CsNewActor 8,CsChAlice,0
  CsAnimSpeed 8,$05
  CsAnimateActor 8,CsAnFaceDown
  CsSetActor 8,64,84
  CsWait 5
  CsAnimateActor 1,CsAnFaceUp
  CsWait 3
  CsAnimateActor 2,CsAnFaceUp
  CsWait 4
  CsRunText StringDemoMessage1
  CsWaitText
  CsAlterMap MapAlt_AliceDoorClose  ;Door close
  CsAnimateActor 8,CsAnWalkDown
  CsMoveActorTime 8,CsDirDown,5,20
  CsWait 5
  CsAnimateActor 8,CsAnFaceDown
  CsWaitText
  CsRunText StringDemoMessage2
  CsWaitText
  CsShootDanmaku 8,0
  CsWait 30
  ;Reimu Marisa danmaku
  CsWait 5
  ;Narumi Watch
  CsAnimateActor 3,CsAnFaceUp
  CsWait 7
  ;Fairy escape
  CsWait 2
  ;Fade out
  CsMoveCameraTime CsDirUp,60,18    ;Rest of map
  CsWait 10
  CsLoadBkgColor %11100100
  CsLoadObjColor %11010000,%11100100
  CsWait 10
  CsLoadBkgColor %11101001
  CsLoadObjColor %11100100,%11101000
  CsWait 10
  CsLoadBkgColor %11111001
  CsLoadObjColor %11100100,%11111000
  CsWait 10
  CsLoadBkgColor %11111010
  CsLoadObjColor %11101000,%11111000
  CsWait 10
  CsLoadBkgColor %11111110
  CsLoadObjColor %11111000,%11111100
  CsWait 10
  CsLoadBkgColor %11111111
  CsLoadObjColor %11111100,%11111100
  CsWait 10
  CsEnd
.ENDS
