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
;3: Wait
;4: Run Text
;5: Set camera
;6: Move camera
;7: Create actor
;8: Destroy actor
;9: Set actor position
;10: Animate actor
;11: Move actor
;12: Load object palette
;13: Load background palette
;14: Load map
;15: Load song
;16: Load song panning
;17: Assign hat to actor
;18: Set actor speed

;Initiate danmaku
;Open Alice's door
;Close Alice's door
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
 .dw Cutscene_ActorSet
 .dw Cutscene_ActorAnimate
 .dw Cutscene_ActorMove
 .dw Cutscene_ObjPaletteLoad
 .dw Cutscene_BkgPaletteLoad
 .dw Cutscene_MapLoad
 .dw Cutscene_SongLoad
 .dw Cutscene_SongPan
 .dw Cutscene_HatAssign
 .dw Cutscene_AnimateSpeed

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
  RLA
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
  JR -
+
--
  DEC E
  CALL HaltTask
  JR nz,--
  DEC D
  JR nz,--
  JR -

;Cutscene functions
Cutscene_End:
  POP HL    ;Return
  POP HL    ;Cutscene data
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
Cutscene_Wait:  ;Does nothing
  JP EndTask

Cutscene_CameraMove:        ;TEST
;D= Time
;E= %DDSSSSSS
    ;||++++++--- Speed (3.3)
    ;++--------- Movement direction
;Meanings:
;Direction:
    ;0, camera moves up
    ;1, camera moves left
    ;2, camera moves down
    ;3, camera moves right
;Time:
    ;How many frames to run for
;Speed:
    ;Pixels/frame
;Up down/Left right distinction
  LD C,<BkgVertScroll
  LD A,%01000000
  AND E
  JR z,+
  INC C
+
;Left up/Right down distinction
  LD A,$BF
  AND E
  LD B,A
  LD A,$80
  AND E
  SLA E
  OR E
  LD E,A
  AND $F0
  SWAP A
  BIT 3,A
  JR z,+
  OR $F0
+
  LD B,A
  LD A,$0F
  AND E
  LD E,B
  SWAP A
  LD B,A
-
  LD L,A
  ADD B
  LD H,A
  LD B,>BkgVertScroll
  LD A,(BC)
  ADC E
  LD (BC),A
  LD A,L
  LD B,H
  CALL HaltTask
  DEC D
  JR nz,-
  JP EndTask

Cutscene_BkgPaletteLoad:    ;TEST
;D= New background palette
  LD HL,BkgPal
  LD (HL),D
  JP EndTask

Cutscene_ObjPaletteLoad:    ;TEST
;D= New OBJ0 palette
;E= New OBJ1 palette
  LD HL,SpritePal0
  LD (HL),D
  INC L
  LD (HL),E
  JP EndTask

Cutscene_CameraSet:         ;TEST
;D = Camera X
;E = Camera Y
  LD HL,BkgVertScroll
  LD (HL),E
  INC L
  LD (HL),D
  JP EndTask

Cutscene_ActorNew:          ;TEST
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
    CALL NewTask
  POP HL
  JP c,EndTask  ;If no task slots, abort!!!
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
  LD B,$07
  LD A,(HL)
  LD (HL),0
-
  CALL MsgSend
  CALL HaltTask
  JR c,-
  JP EndTask

Cutscene_ActorMove:         ;TEST
;D= %DDKIIIII
    ;|||+++++--- Reference ID
    ;||+-------- Data type
    ;++--------- Direction
;If K==0
  ;E= %SSSSSSSS
      ;++++++++--- Speed (4.4)
;If K==1
  ;E= %TTTTTTTT
      ;++++++++--- Time
;Meanings:
;Direction:
    ;0, actor moves up
    ;1, actor moves left
    ;2, actor moves down
    ;3, actor moves right
;Time:
    ;How many frames to run for
;Speed:
    ;Pixels per frame movement
  LD HL,Cutscene_Actors
  LD A,$1F
  AND D
  ADD L
  LD L,A
  ;Register fiddle
  LD C,E
  LD A,$E0
  AND D
  OR 1
  LD B,A
  ;Send Actor movement message
  LD A,(HL)
-
  CALL MsgSend
  CALL HaltTask
  JR c,-
  JP EndTask

Cutscene_ActorSet:          ;TEST
;D= %YYYIIIII
    ;|||+++++--- Reference ID
    ;+++-------- Lower Y position (in tiles)
;E= %XXXXXXYY
    ;||||||++--- Upper Y position
    ;++++++----- X position (in half tiles)
  LD HL,Cutscene_Actors
  LD A,$1F
  AND D
  ADD L
  LD L,A
  ;Fiddle X and Y into BC
  LD A,$E0
  AND D
  LD B,A
  LD A,$03
  AND E
  OR B
  RRCA
  RRCA
  LD B,A
  LD A,$FC
  AND E
  LD C,A
  ;Send Actor movement message
  LD A,(HL)
-
  CALL MsgSend
  CALL HaltTask
  JR c,-
  JP EndTask

Cutscene_ActorAnimate:      ;TEST
;D= %000IIIII
    ;   +++++--- Reference ID
;E= Animation ID
  LD H,>Cutscene_Actors
  LD A,<Cutscene_Actors
  ADD D
  LD L,A
  LD A,(HL)
  LD C,E    ;Animation ID
  LD B,3    ;Animation indicator
-
  CALL MsgSend
  CALL HaltTask
  JR c,-
  JP EndTask

Cutscene_AnimateSpeed:      ;TEST
;D= %000IIIII
    ;   +++++--- Reference ID
;E= Animation Speed
  LD H,>Cutscene_Actors
  LD A,<Cutscene_Actors
  ADD D
  LD L,A
  LD A,(HL)
  LD C,E    ;Animation ID
  LD B,11   ;Animation speed indicator
-
  CALL MsgSend
  CALL HaltTask
  JR c,-
  JP EndTask

Cutscene_MapLoad:           ;TEST
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

Cutscene_SongLoad:          ;TEST
;DE->Song Data
  LD B,D
  LD C,E
  CALL MusicLoad
  LD A,$FF
  LD (musicglobalbase+1),A
  LDH ($26),A
  JP EndTask

Cutscene_SongPan:           ;TEST
;D= Shadow $FF24
;E= Shadow $FF25
  LD A,D
  LDH ($24),A
  LD A,E
  LDH ($25),A
  JP EndTask

Cutscene_InputOff:          ;WRITE
;Send message to Marisa (actor ID 01), and hat (actor ID 00)
Cutscene_InputOn:           ;WRITE
;Send message to Marisa (actor ID 01), and hat (actor ID 00)
  JP EndTask
Cutscene_HatAssign:         ;WRITE
;D= ID to assign hat to (0 to unassign)
  JP EndTask

.ENDS

;TODO: Macro cutscenes; I don't wanna type and monotonously calculate 100s of numbers
;TODO: Remove wait field; use CsWait as a 16 bit frame counter for waits

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
 .IF dist > 0
  .IF speed >= 8
   .db 5,(dir<<6) | $38,dist/speed
    CsMoveCameraSpeed dir, speed-7, dist - 7*dist/speed
  .ELSE
   .db 5,(dir<<6) | ((speed<<3) & $3F),dist/speed
  .ENDIF
 .ENDIF
.ENDM
.MACRO CsMoveCameraTime ARGS dir, time, dist
  ;I want to move in [dir], and go [dist] in exactly [time] frames
 .IF dist > 0
  .IF dist/time >= 8
   .db 5,(dir<<6) | $38,time
    CsMoveCameraTime dir, time, dist - 7*time
  .ELSE
   .db 5,(dir<<6) | (((dist/time)<<3) & $3F),time
  .ENDIF
 .ENDIF
.ENDM
.MACRO CsNewActor ARGS ID, species, race
 .db 6,race,(species << 5) | ID
.ENDM
.MACRO CsDeleteActor ARGS ID
 .db 7,0,ID
.ENDM
.MACRO CsSetActor ARGS ID, X, Y
 .db 8,((X<<2) & $FC) | ((Y>>3) & $03),ID | ((Y<<5) & $07)
.ENDM
.MACRO CsAnimateActor ARGS ID, anim
 .db 9,anim,ID
.ENDM
.MACRO CsAnimSpeed ARGS ID, animspeed
 .db 18,animspeed,ID
.ENDM
.DEFINE oldspeed -1
.MACRO CsMoveActorSpeed ARGS ID, dir, speed, dist
 .IF speed != oldspeed
  .db 10,speed<<4,(dir<<6) | ID
 .ENDIF
 .redefine oldspeed speed
 .db 10,dist/speed,(dir<<6) | $20 | ID
.ENDM
.MACRO CsMoveActorTime ARGS ID, dir, time, dist
 .IF dist/time != oldspeed
  .db 10,dist/time,(dir<<6) | ID
 .ENDIF
 .redefine oldspeed dist/time
 .db 10,time,(dir<<6) | $20 | ID
.ENDM
.MACRO CsLoadObjColor ARGS color0, color1
 .db 11,color1,color0
.ENDM
.MACRO CsLoadBkgColor ARGS color
 .db 12,0,color
.ENDM
.MACRO CsLoadMap ARGS Map
 .db 13
 .dw Map
.ENDM
.MACRO CsLoadSong ARGS Song
 .db 14
 .dw Song
.ENDM
.MACRO CsPanSong ARGS channelSelect, stereoVolume
 .db 15,channelSelect,stereoVolume
.ENDM
.MACRO CsAssignHat ARGS ID
 .db 16,0,ID
.ENDM
.MACRO CsAlterMap ARGS alteration
 .db 0
 .dw alteration
.ENDM
.MACRO CsShootDanmaku ARGS ID, type
 .db 0,type,ID
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
  CsLoadBkgColor $FF
  CsLoadObjColor $FF,$FF
  CsPanSong $FF,$FF
  CsLoadSong SongSpark
  CsLoadMap MapForest02
  CsSetCamera 0,112
  CsNewActor 0,CsChHat,0
  CsNewActor 1,CsChMarisa,0
  CsNewActor 2,CsChReimu,0
  CsNewActor 3,CsChNarumi,0
  CsInputOff
  CsAssignHat 1
  CsWait 1      ;Task relief
  CsNewActor 4,CsChFairy,$00
  CsNewActor 5,CsChFairy,$54
  CsNewActor 6,CsChFairy,$A8
  CsNewActor 7,CsChFairy,$68
  CsAnimSpeed 1,$10
  CsAnimSpeed 2,$10
  CsAnimSpeed 3,$10
  CsAnimSpeed 4,$10
  CsAnimSpeed 5,$10
  CsAnimSpeed 6,$10
  CsAnimSpeed 7,$10
  CsWait 1      ;Task relief
  CsAnimateActor 1,CsAnFaceLeft
  CsAnimateActor 2,CsAnFaceRight
  CsAnimateActor 3,CsAnFaceDown
  CsAnimateActor 4,CsAnWalkUp
  CsAnimateActor 5,CsAnWalkRight
  CsAnimateActor 6,CsAnWalkLeft
  CsAnimateActor 7,CsAnWalkLeft
  CsWait 1      ;Task relief
  CsSetActor 1,10,16
  CsSetActor 2,6,16
  CsSetActor 3,14,17
  CsSetActor 4,9,29
  CsSetActor 5,5,24
  CsSetActor 6,16,19
  CsSetActor 7,17,28
  CsMoveActorTime 4,CsDirUp,255,96
  CsMoveActorSpeed 5,CsDirRight,1.5,72
  CsMoveActorSpeed 6,CsDirLeft,1.1,40
  CsMoveActorSpeed 7,CsDirLeft,1,96
  CsWait 7      ;Wait for map load
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
  CsMoveCameraTime CsDirUp,255,56   ;112 pix over 3 seconds
  CsWait 255
  CsMoveCameraTime CsDirUp,255,56
  CsWait 255
  CsWait 120    ;2 second pause
  CsAlterMap 0      ;Door open
  CsNewActor 8,CsChAlice,0
  CsAnimateActor 8,CsAnFaceDown
  CsSetActor 8,8,10.5
  CsWait 5
  CsAnimateActor 1,CsAnFaceUp
  CsWait 3
  CsAnimateActor 2,CsAnFaceUp
  CsWait 4
  CsRunText StringDemoMessage1
  CsAlterMap 0      ;Door close
  CsAnimateActor 8,CsAnWalkDown
  CsMoveActorTime 8,CsDirDown,5,2.5
  CsWait 5
  CsAnimateActor 8,CsAnFaceDown
  CsWait 1  ;Dialog finish wait
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
