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

.DEFINE CsChHat      0
.DEFINE CsChMarisa   1
.DEFINE CsChAlice    2
.DEFINE CsChReimu    3
.DEFINE CsChNarumi   4
.DEFINE CsChFairy    5
.DEFINE CsChMushroom 6

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
.MACRO CsEnd
 .db $80
 .dw 0
.ENDM
.MACRO CsEndVar ARGS var, check
 .IF NARGS >= 2
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
.MACRO CsRunText ARGS TextPtr
 .db 3
 .dw TextPtr
.ENDM
.MACRO CsSetCamera ARGS X, Y
 .db 4,Y,X
.ENDM
.MACRO CsMoveCameraSpeed ARGS dir, speed, dist
;I want to move in [dir], and go [dist] via [speed] pixels/frame
 .db 5,dist,(dir<<6) | ((speed*16) & $3F)
.ENDM
.MACRO CsMoveCameraTime ARGS dir, time, dist
;I want to move in [dir], and go [dist] in exactly [time] frames
 .db 5,dist,(dir<<6) | (((dist/time)*16) & $3F)
.ENDM
.MACRO CsNewActor ARGS ID, species, race
 .db 6,race,(species << 5) | ID
.ENDM
.MACRO CsDeleteActor ARGS ID
 .db 7,ID,0
.ENDM
.MACRO CsDeleteActorVar ARGS var, ID
 .db $40+7,var,ID
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
.MACRO CsSetActorSpeed ARGS ID, speed
 .db 9,speed*16,ID | ((2)*32)
.ENDM
.MACRO CsMoveActor ARGS ID, dir, dist
 .db 9,dist,ID | ((dir + 3)*32)
.ENDM
.MACRO CsMoveActorVar ARGS var, ID, dir
 .IF NARGS >= 3
 .db $40+9,var,ID | ((dir + 3)*32)
 .ELSE
 .db $40+9,var,ID
 .ENDIF
.ENDM
.MACRO CsMoveActorSpeed ARGS ID, dir, speed, dist
 .db 9,speed*16,ID | ((2)*32)
 .db 9,dist, ID | ((dir + 3)*32)
.ENDM
.MACRO CsMoveActorDist ARGS ID, dir, dist
 .db 9,dist,ID | ((dir + 3)*32)
.ENDM
.MACRO CsMoveActorTime ARGS ID, dir, time, dist
 .db 9,dist/time*16,ID | ((2)*32)
 .db 9,dist, ID | ((dir + 3)*32)
.ENDM
.MACRO CsLoadObjColor ARGS color0, color1
 .db $80+30,color1,color0
.ENDM
.MACRO CsLoadBkgColor ARGS color
 .db $80+31,color,0
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
.MACRO CsWaitReadyMap
 .db $80+27
 .db 0,$80
.ENDM
.MACRO CsShowMap
 .db 26,0,0
 .db $80+27,0,$FF       ;Wait on map after
.ENDM
.MACRO CsLoadSong ARGS song
 .db 13
 .dw song
.ENDM
.MACRO CsPanSong ARGS channelSelect, stereoVolume
 .db 14,channelSelect,stereoVolume
.ENDM
.MACRO CsAssignHat ARGS hat, ID
 .db 10,hat,ID
.ENDM
.MACRO CsAlterMap ARGS alteration
 .db 16
 .dw alteration
.ENDM
.MACRO CsShootDanmaku ARGS ID, type
 .db 17,type,ID
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
 .db $80+21,0,offs*3
.ENDM
.MACRO CsJumpRelVar ARGS var, offs
 .db $C0+21,var,offs*3
.ENDM
.MACRO CsSnapCamera
 .db $80+20,0,0
.ENDM
.MACRO CsMultVar ARGS var, scale
 .db $80+23,scale,var
.ENDM

.SECTION "Block Cutscenes" BITWINDOW 8 FREE

;It is required that this pointer is page-aligned
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

.ENDS

.SECTION "Cutscenes" FREE

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

;Complete Cutscenes
;These cutscenes are meant to be used in Map definitions etc.

;Used for when entrance direction aligns with exit direction
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
Cs_StraightTransition:
  CsCall Cs_TransitionOut
  CsCall Cs_ClearActorList
  CsJumpRelVar 126,1
  CsJump Cs_TransitionIn
  CsLoadSong SongRetrib         ;Change music
  CsSetVar 126,1
  CsJump Cs_TransitionIn

;Some of the non straight transitions
Cs_CurvedTransitionA:
  CsCall Cs_TransitionOut
  CsCall Cs_ClearActorList
  ;Check for exit from map 01 (to map 00)
  CsAddVar 32,(0 - <MapForest01map) & $FF
  CsAddVar 33,(0 - >MapForest01map) & $FF
  CsJumpRelVar 32,1
  CsJumpRel 1
  CsJumpRelVar 33,6
  ;Check for exit from map 11
  CsAddVar 32,((<MapForest01map) - (<MapForest11map)) & $FF
  CsAddVar 33,((>MapForest01map) - (>MapForest11map)) & $FF
  CsJumpRelVar 32,1
  CsJumpRel 5
  CsJumpRelVar 33,1
  CsJumpRel 3
  CsSetVar 1,CsDirLeft      ;Go Left
  CsSetVar 21,(CsDirLeft+3)*32
  CsJump Cs_TransitionIn
  ;Check for exit from map 04   fix
  CsAddVar 32,((<MapForest11map) - (<MapForest04map)) & $FF
  CsAddVar 33,((>MapForest11map) - (>MapForest04map)) & $FF
  CsJumpRelVar 32,1
  CsJumpRel 1
  CsJumpRelVar 33,6
  ;Check for exit from map 24
  CsAddVar 32,((<MapForest04map) - (<MapForest24map)) & $FF
  CsAddVar 33,((>MapForest04map) - (>MapForest24map)) & $FF
  CsJumpRelVar 32,1
  CsJumpRel 5
  CsJumpRelVar 33,1
  CsJumpRel 3
  CsSetVar 1,CsDirDown      ;Go Down
  CsSetVar 21,(CsDirDown+3)*32
  CsJump Cs_TransitionIn
  ;Check for exit from map 02
  CsAddVar 32,((<MapForest24map) - (<MapForest02map)) & $FF
  CsAddVar 33,((>MapForest24map) - (>MapForest02map)) & $FF
  CsJumpRelVar 32,1
  CsJumpRel 5
  CsJumpRelVar 33,1
  CsJumpRel 3
  CsSetVar 1,CsDirRight     ;Go Right
  CsSetVar 21,(CsDirRight+3)*32
  CsJump Cs_TransitionIn
  ;Check for exit from map 00
  CsAddVar 32,((<MapForest02map) - (<MapForest00map)) & $FF
  CsAddVar 33,((>MapForest02map) - (>MapForest00map)) & $FF
  CsJumpRelVar 32,1
  CsJump Cs_TransitionIn    ;Last check, always transition
  CsJumpRelVar 33,1
  CsJump Cs_TransitionIn
  CsSetVar 1,CsDirUp        ;Go Up
  CsSetVar 21,(CsDirUp+3)*32
  CsJump Cs_TransitionIn


;Special loads for NPCs/Objects
;Shroom room
Cs_Forest30:
  CsCall Cs_TransitionOut
  CsCall Cs_ClearActorList
  CsNewActor 2,CsChMushroom,0
  CsWait 2
  CsAnimateActor 2,CsAnFaceDown
  CsSetActor 2,10,10
  CsJump Cs_TransitionIn

;Shroom room
Cs_Forest11:
  CsCall Cs_TransitionOut
  CsCall Cs_ClearActorList
  ;There's a shroom in the room
  CsNewActor 2,CsChMushroom,0
  CsWait 2
  CsAnimateActor 2,CsAnFaceLeft
  CsSetActor 2,10,10
  ;Check for exit from map 01 (to 11)
  CsAddVar 32,(0-<MapForest01map) & $FF
  CsAddVar 33,(0->MapForest01map) & $FF
  CsJumpRelVar 32,1
  CsJump Cs_TransitionIn    ;Last check, always transition
  CsJumpRelVar 33,1
  CsJump Cs_TransitionIn    ;Last check, always transition
  CsSetVar 1,CsDirDown      ;Go Down
  CsSetVar 21,(CsDirDown+3)*32
  CsJump Cs_TransitionIn

;Shroom room
Cs_Forest04:
  CsCall Cs_TransitionOut
  CsCall Cs_ClearActorList
  CsNewActor 2,CsChMushroom,0
  CsWait 2
  CsAnimateActor 2,CsAnFaceRight
  CsSetActor 2,10,10
  CsJump Cs_TransitionIn

;Reimu room
Cs_Forest00:
  CsCall Cs_TransitionOut
  CsCall Cs_ClearActorList
  CsNewActor 2,CsChReimu,0
  CsWait 2
  CsAnimateActor 2,CsAnFaceDown
  CsSetActor 2,10,10
  CsJump Cs_CurvedTransitionA+6

;Alice room
Cs_Forest24:
  CsCall Cs_TransitionOut
  CsCall Cs_ClearActorList
  CsNewActor 2,CsChAlice,0
  CsWait 2
  CsAnimateActor 2,CsAnFaceDown
  CsSetActor 2,$4D,$32
  CsInputChange 2,2     ;Interactable
  CsJump Cs_TransitionIn

;New setup
Cs_Intro:
  CsLoadSong SongRetrib
  CsPanSong $FF,$AA
  CsWait 45
  CsLoadBkgColor $FE
  CsWait 45
  CsLoadBkgColor $FF
  CsLoadObjColor $FF,$FF
  CsWait 45
  CsLoadMap MapForestBKG03
  CsNewActor 0,CsChHat,0
  CsNewActor 1,CsChMarisa,0
  CsWait 2
  CsInputChange 1,0     ;Cutscene control of Marisa
  CsAnimateActor 1,CsAnFaceDown
  CsAssignHat 0,1
  CsWaitReadyMap
  CsLoadMap MapForest23map
  CsSetActor 1,130,70
  CsWaitReadyMap
  CsLoadObj MapForest23obj
  CsShowMap
  CsInputChange 1,$80   ;Camera follow
  ;Marisa walk into scene here
  CsCall Cs_MapFadein
  CsRunText StringOpeningMessage1
  CsWait 1
  CsWaitText
  ;Marisa does a shuffle here
  CsRunText StringOpeningMessage2
  CsWait 1
  CsWaitText
  CsLoadSong SongMagus  ;Load main actioney song
  CsRunText StringOpeningMessage3
  CsWait 1
  CsWaitText
  CsSetActorSpeed 1,0.9
  CsAnimSpeed 1,10
  CsInputChange 1,$87   ;Playable
  CsEnd

;Component Transitions
;These are just called by the above. Not to be used alone.

Cs_TransitionOut:
  CsInputChange 1,0
  CsAddVar 1,CsAnWalkLeft
  CsAnimateActorVar 1,1
  CsAddVar 1,-CsAnWalkLeft
  CsSetVar 20,30    ;Distance
  CsSetVarVar 21,1
  CsAddVar 21,3
  CsMultVar 21,32   ;put the dir part in its place in the byte
  CsMoveActorVar 20,1
  CsCall Cs_MapFadeout
  CsSetVarVar 2,3   ;Convert backing to short and index into back maps (26 bytes per item)
  CsMultVar 2,26
  CsAddVar 2,<MapBackBase
  CsAddVar 3,>MapBackBase
  CsLoadMapVar 2
  CsWaitReadyMap
  CsLoadMapVar 4
  CsWaitReadyMap
  CsLoadObjVar 6
  CsShowMap
  CsEnd

Cs_TransitionIn:
  CsAddVar 1,CsAnWalkLeft   ;In case fancing changed
  CsAnimateActorVar 1,1
  CsAddVar 1,-CsAnWalkLeft
  CsSetVarVar 6,1   ;Index into ComputePlayerAndCamera list (24 bytes per item)
  CsSetVar 7,0
  CsMultVar 6,24
  CsAddVar 6,<Cs_ComputePlayerAndCamera
  CsAddVar 7,>Cs_ComputePlayerAndCamera
  CsSetVar 17,0
  CsSetVar 19,0
  CsCallVar 6
  CsCall Cs_MapFadein
  CsMoveActorVar 20,1
  CsWait 37
  CsAnimateActorVar 1,1     ;Marisa, stand still
  CsInputChange 1,$87
  CsSetVarVar 32,4
  CsSetVarVar 33,5
  CsEnd

Cs_ClearActorList:
  CsSetVar 23,30
  CsDeleteActorVar 23,1
  CsAddVar 23,-1
  CsEndVar 23
  CsJumpRel -4

;Ending A (Found Alice's house from the front)
Cs_EndingA:
  CsCall Cs_TransitionOut
  CsCall Cs_ClearActorList
  CsLoadSong SongDoll
  CsCall Cs_TransitionIn
  ;Pan camera up to house
  ;Pan down to Marisa
  ;Text
  ;Walk up to door
  ;Door opens; Alice in doorway
  ;Text
  ;Marisa walks in, Alice leaves from doorway
  ;Door close
  ;Camera pans up, scene fades to white
  ;Text?
  CsEnd

;Ending B (Escorted by Alice)
Cs_EndingB:
  RET   ;Used as interaction function
  ;Marisa, Alice, don't move anymore, and no camera tracking
  CsInputChange 1,0
  CsInputChange 2,0
  CsRunText StringAliceEscort1
  CsWaitText
  CsLoadSong SongDoll
  CsSetActorSpeed 2,60/(50+110)
  CsSetActorSpeed 1,60/(50+110)
  CsAnimSpeed 2,$08
  ;Marisa scoots to the side, Alice moves down
  CsAnimateActor 2,CsAnWalkDown
  CsMoveActorDist 2,CsDirDown,60
  ;Marisa tails behind Alice
  CsWait 50
  CsAnimateActor 1,CsAnWalkDown
  CsMoveActorDist 1,CsDirDown,60
  CsWait 110
  ;Alice moves right
  CsAnimateActor 2,CsAnWalkRight
  CsMoveActorDist 2,CsDirRight,(190+50)*(60/(50+110))
  CsWait 50
  CsAnimateActor 1,CsAnWalkRight
  CsMoveActorDist 1,CsDirRight,(190+50)*(60/(50+110))
  CsWait 170
  CsCall Cs_MapFadeout
  CsLoadMap MapForestBKG01
  CsWaitReadyMap
  CsLoadMap MapForest02map
  ;Bottom entrance
  CsSetActor 2,100,240
  CsSetActor 1,98,250
  CsAnimateActor 2,CsAnWalkUp
  CsAnimateActor 1,CsAnWalkUp
  CsSetCamera 0,111
  CsWaitReadyMap
  CsLoadMap MapForestEndBmap
  CsWaitReadyMap
  CsShowMap
  ;Camera follows Alice
  CsCall Cs_MapFadein
  ;Alice moves up
  CsMoveCameraTime CsDirUp,400,101
  CsMoveActorTime 2,CsDirUp,400,130
  CsMoveActorTime 1,CsDirUp,400,120
  ;Camera stops at top of map (Alice stops at same time)
  CsWait 400
  CsAnimateActor 1,CsAnFaceUp
  CsAnimateActor 2,CsAnFaceUp
  CsRunText StringAliceEscort2
  CsWaitText
  ;Marisa moves around Alice to closer to house
  CsAnimateActor 1,CsAnWalkLeft
  CsMoveActorTime 1,CsDirLeft,50,28
  CsWait 50
  CsAnimateActor 1,CsAnWalkUp
  CsMoveActorTime 1,CsDirUp,80,44
  CsWait 80
  CsAnimateActor 1,CsAnWalkRight
  CsMoveActorTime 1,CsDirRight,30,12
  CsWait 30
  ;Marisa faces Alice
  CsAnimateActor 1,CsAnFaceDown
  CsRunText StringAliceEscort3
  CsWaitText
  CsLoadSong SongMagus
  CsRunText StringAliceEscort4
  CsWaitText
  ;Danmaku
  
  ;Fade to black
  CsCall Cs_MapFadeout
  CsEnd

;Ending C (Found Alice's house from the back)
Cs_EndingC:
  CsLoadSong SongDoll
  ;Marisa doesn't recognise the house
  ;Marisa sneaks in to the house (for perusal)
  ;Some comments on how "Alice-like" it is
  ;Fairies sneak in from the front; a lot of them
  ;Battle ensues
  ;Fadeout... time passes
  ;Alice comes home, is displeased at the carnage
  ;Blames Marisa, more battle ensues
  CsEnd

;Bad insult lines:
  ;I'm gonna hang you with your own apron!
  ;Not if I garotte you with your own dollstrings first!
  ;I'm gonna shove so much gunpowder down your throat, it explodes out your ass!
  ;Not if I shove so many mushrooms down your throat, they sprout our your cro-

;Narumi Fight intro
Cs_NarumiFightStart:
  CsCall Cs_TransitionOut
  CsCall Cs_ClearActorList
  CsLoadSong SongNull   ;No song plays if the fight is finished
  CsSetVar 126,0        ;Change music on exit
  CsNewActor 2,CsChNarumi,0
  CsWait 2
  CsSetActor 2,56,72
  CsAnimateActor 2,CsAnFaceDown
  CsCall Cs_TransitionIn
  CsInputChange 1,$87
  CsEndVar 118,1        ;No text etc if the fight already happened
  CsInputChange 1,$80   ;Camera follow, but sit still
  CsRunText StringNarumiStart1
  CsWaitText
  CsLoadSong SongSpark
  CsRunText StringNarumiStart2
  CsWaitText
  CsEnd

;Narumi Fight outro
Cs_NarumiFightEnd:
  CsLoadSong SongDoll
  CsRunText StringNarumiEnd
  CsWaitText
  CsSetVar 118,1        ;Narumi is beaten
  CsInputChange 1,$87   ;Marisa may leave
  CsEnd

;Feeding Reimu Shrooms
Cs_ReimuMeet:
  CsCall Cs_ReimuFeed
  CsEndVar 116,1
  CsRunText StringReimuMeet
  CsWaitText
  CsSetVar 116,1
  CsEnd
  
Cs_ReimuFeed:
  CsEndVar 116
  ;Does Marisa have mushrooms?
  CsCall Cs_ReimuMushroomTest
  CsEndVar 0
  ;Marisa has mushrooms
  CsRunText StringReimuFeed2
  ;Those mushrooms are gone now
  CsJumpRelVar 120,1
  CsSetVar 120,2
  CsJumpRelVar 122,1
  CsSetVar 122,2
  CsJumpRelVar 124,1
  CsSetVar 124,2
  ;Are there any left?
  CsWaitText
  CsJumpRelVar 120,4
  CsJumpRelVar 122,3
  CsJumpRelVar 124,2
  CsRunText StringReimuFeed4
  CsJumpRel 1
  CsRunText StringReimuFeed3
  CsWaitText
  CsEnd

;Uses Var 0 for whether Marisa has shrooms or not
Cs_ReimuMushroomTest:
  CsSetVar 0,1
  CsEndVar 120,1
  CsEndVar 122,1
  CsEndVar 124,1
  ;No mushrooms collected
  CsSetVar 0,0
  CsRunText StringReimuFeed1
  CsWaitText
  CsEnd

.ENDS
