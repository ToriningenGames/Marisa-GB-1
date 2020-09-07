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
    ;Open Alice's door
    ;Close Alice's door
;19: Shoot Danmaku
;128: Wait

;Attach hat to character
;Detach hat from characters

Cutscene_LUT:
 .dw Cutscene_End
 .dw Cutscene_InputOff
 .dw Cutscene_InputOn
 .dw TextStart
 .dw Cutscene_CameraSet
 .dw Cutscene_CameraMove
 .dw Cutscene_ActorNew
 .dw Cutscene_ActorDelete
 .dw Cutscene_ActorAnimate
 .dw Cutscene_ActorMovement
 .dw Cutscene_ObjPaletteLoad
 .dw Cutscene_BkgPaletteLoad
 .dw Cutscene_MapLoad
 .dw Cutscene_SongLoad
 .dw Cutscene_SongPan
 .dw Cutscene_HatAssign
 .dw Cutscene_MapAlter
 .dw Cutscene_DanmakuInit

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
-
  LD A,(BC)
  INC BC
  OR A
  JP z,Cutscene_End
  LD H,>Cutscene_LUT
  RLA       ;Carry out here important
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
  ;CALL HaltTask
  ;JR -
  LD DE,$0101   ;Use the user's wait routine
+
--
  CALL HaltTask
  DEC E
  JR nz,--
  DEC D
  JR nz,--
  JR -

;Cutscene functions
Cutscene_End:           ;(Not a task)
  LD HL,Cutscene_Actors
  LDI A,(HL)
  LD C,A
  LD A,(HL)
  LD B,$17  ;Resume free will
-
  CALL MsgSend
  CALL HaltTask
  JR c,-
  LD A,C
-
  CALL MsgSend
  CALL HaltTask
  JR c,-
  JP EndTask

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

Cutscene_BkgPaletteLoad:
;D= New background palette
  LD HL,BkgPal
  LD (HL),D
  JP EndTask

Cutscene_ObjPaletteLoad:
;D= New OBJ0 palette
;E= New OBJ1 palette
  LD HL,SpritePal0
  LD (HL),D
  INC L
  LD (HL),E
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
;Fairy types:
    ;HHDDWWAA:
    ;||||||++--- AI type
    ;||||++----- Wing type
    ;||++------- Dress type
    ;++--------- Hair type
  PUSH BC       ;Task info
    LD HL,Cutscene_Actors
    LD A,$1F
    AND D
    ADD L
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
  LD (HL),A
  CALL HaltTask ;Become the new character
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
  LD B,$07
  LD A,(HL)
  LD (HL),0
-
  CALL MsgSend
  CALL HaltTask
  JR c,-
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
  LD A,(HL)
-
  CALL MsgSend
  JP nc,EndTask
  CALL HaltTask
  JR -

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
  OR 8
  LD B,A
  LD C,E
  ;Send the message
  LD A,(HL)
  JR -  ;Use previous taskloop

Cutscene_MapLoad:
;DE->Map Data
;Load in the new map
  XOR A
  LD (hotMap),A
  LD BC,LoadMap_Task
  CALL NewTask
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

Cutscene_InputOff:          ;WRITE
;Send message to Marisa (actor ID 01), and hat (actor ID 00)
  JP EndTask
Cutscene_InputOn:           ;WRITE
;Send message to Marisa (actor ID 01), and hat (actor ID 00)
  JP EndTask
Cutscene_HatAssign:         ;WRITE
;D= ID to assign hat to (0 to unassign)
  JP EndTask
Cutscene_MapAlter:          ;WRITE
;DE= Pointer to alteration data
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
 .db $80
 .dw time+$100
.ENDM
.MACRO CsEnd
 .db 0
.ENDM
.MACRO CsInputOff
 .db 1,0,0
.ENDM
.MACRO CsInputOn
 .db 2,0,0
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
 .db 9,X,ID | ((0)*32)
 .db 9,Y,ID | ((1)*32)
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
 .db 10,color1,color0
.ENDM
.MACRO CsLoadBkgColor ARGS color
 .db 11,0,color
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
.MACRO CsAssignHat ARGS ID
 .db 15,0,ID
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
    ;Cutscene data
    ;Actors receiving messages
    ;Player Cutscene control control
    ;Door cutscene functions
    ;Danmanku actor messages
        ;Danmaku as independent of actors?
    ;How long does the text take (We can automate measurement)
;Problems:
    ;Something in the Actor chain isn't working right
    ;Alter Map is not written
    ;Shoot Danmaku is not written
    ;Where do we need task reliefs?
        ;Count per-cutscene items+actors. Try to keep usage under 32
    ;The Camera Time macro can move camera too slow
        ;Same distance covered, takes more time. Problem of speed's precision
    ;Textbox cursor start always "No portrait"
    ;Faces wrong
    ;Final block of Demo1 too long.
    ;Final line of Demo2 missing first letter?
    ;Text waits before lowers too fast
    

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
  CsWait 10             ;Fade to black
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
;  CsNewActor 3,CsChNarumi,0
  CsInputOff
  CsAssignHat 1
  CsNewActor 4,CsChFairy,$00
  CsNewActor 5,CsChFairy,$54
  CsNewActor 6,CsChFairy,$A8
  CsNewActor 7,CsChFairy,$68
  CsAnimSpeed 1,$10
  CsAnimSpeed 2,$10
;  CsAnimSpeed 3,$10
  CsAnimSpeed 4,$10
  CsAnimSpeed 5,$10
  CsAnimSpeed 6,$10
  CsAnimSpeed 7,$10
  CsAnimateActor 1,CsAnFaceLeft
  CsAnimateActor 2,CsAnFaceRight
;  CsAnimateActor 3,CsAnFaceDown
  CsAnimateActor 4,CsAnWalkUp
  CsAnimateActor 5,CsAnWalkRight
  CsAnimateActor 6,CsAnWalkLeft
  CsAnimateActor 7,CsAnWalkLeft
  CsSetActor 1,80,128
  CsSetActor 2,96,128
;  CsSetActor 3,112,136
  CsSetActor 4,72,232
  CsSetActor 5,40,192
  CsSetActor 6,128,152
  CsSetActor 7,136,224
  CsWait 7      ;Wait for map load
  CsMoveActorTime 4,CsDirUp,300,96
  CsMoveActorSpeed 5,CsDirRight,1.5,72
  CsMoveActorSpeed 6,CsDirLeft,1.1,40
  CsMoveActorSpeed 7,CsDirLeft,1,96
 ;   Fade in
  CsLoadBkgColor %11111110
  CsLoadObjColor %11111000,%11111100
  CsWait 1
  CsLoadBkgColor %11111010
  CsLoadObjColor %11101000,%11111000
  CsWait 1
  CsLoadBkgColor %11111001
  CsLoadObjColor %11100100,%11111000
  CsWait 1
  CsLoadBkgColor %11101001
  CsLoadObjColor %11100100,%11101000
  CsWait 1
  CsLoadBkgColor %11100100
  CsLoadObjColor %11010000,%11100100
  CsWait 1
  CsLoadBkgColor %11100100
  CsLoadObjColor %11010000,%11100100
  CsWait 1
  CsMoveCameraTime CsDirUp,300,112     ;112 pix over 5 seconds
  CsWait 300+120    ;2 second pause
  CsAlterMap 0      ;Door open
  CsNewActor 8,CsChAlice,0
  CsAnimateActor 8,CsAnFaceDown
  CsSetActor 8,64,84
  CsWait 5
  CsAnimateActor 1,CsAnFaceUp
  CsWait 3
  CsAnimateActor 2,CsAnFaceUp
  CsWait 4
  CsRunText StringDemoMessage1
  CsAlterMap 0      ;Door close
  CsAnimateActor 8,CsAnWalkDown
  CsMoveActorTime 8,CsDirDown,5,20
  CsWait 5
  CsAnimateActor 8,CsAnFaceDown
  CsWait 65000  ;Dialog finish wait
  CsRunText StringDemoMessage2
  CsShootDanmaku 8,0
  CsWait 30
  ;Reimu Marisa danmaku
  CsWait 5
  ;Narumi Watch
  CsWait 7
  ;Fairy escape
  CsWait 2
  ;Fade out
.ENDS
