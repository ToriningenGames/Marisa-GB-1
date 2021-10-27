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


.SECTION "Cutscenes" ALIGN 256 FREE

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
  CsJump Cs_TransitionIn

;Some of the non straight transitions
Cs_CurvedTransitionA:
  CsCall Cs_TransitionOut
  CsCall Cs_ClearActorList
  ;Separate the map bytes for analysis
  CsSetVar 23,0
  CsSetVar 25,0
  CsSetVarVar 22,32
  CsSetVarVar 24,33
  ;Check for exit from map 01 (to map 00)
  CsAddVar 22,(0 - <MapForest01map) & $FF
  CsAddVar 24,(0 - >MapForest01map) & $FF
  CsJumpRelVar 22,1
  CsJumpRel 1
  CsJumpRelVar 24,6
  ;Check for exit from map 11
  CsAddVar 22,((<MapForest01map) - (<MapForest11map)) & $FF
  CsAddVar 24,((>MapForest01map) - (>MapForest11map)) & $FF
  CsJumpRelVar 22,1
  CsJumpRel 5
  CsJumpRelVar 24,1
  CsJumpRel 3
  CsSetVar 1,CsDirLeft      ;Go Left
  CsSetVar 21,CsDirLeft*32
  CsJump Cs_TransitionIn
  ;Check for exit from map 04   fix
  CsAddVar 22,((<MapForest11map) - (<MapForest04map)) & $FF
  CsAddVar 24,((>MapForest11map) - (>MapForest04map)) & $FF
  CsJumpRelVar 22,1
  CsJumpRel 1
  CsJumpRelVar 24,6
  ;Check for exit from map 24
  CsAddVar 22,((<MapForest04map) - (<MapForest24map)) & $FF
  CsAddVar 24,((>MapForest04map) - (>MapForest24map)) & $FF
  CsJumpRelVar 22,1
  CsJumpRel 5
  CsJumpRelVar 24,1
  CsJumpRel 3
  CsSetVar 1,CsDirDown      ;Go Down
  CsSetVar 21,CsDirDown*32
  CsJump Cs_TransitionIn
  ;Check for exit from map 02
  CsAddVar 22,((<MapForest24map) - (<MapForest02map)) & $FF
  CsAddVar 24,((>MapForest24map) - (>MapForest02map)) & $FF
  CsJumpRelVar 22,1
  CsJumpRel 5
  CsJumpRelVar 24,1
  CsJumpRel 3
  CsSetVar 1,CsDirRight     ;Go Right
  CsSetVar 21,CsDirRight*32
  CsJump Cs_TransitionIn
  ;Check for exit from map 00
  CsAddVar 22,((<MapForest02map) - (<MapForest00map)) & $FF
  CsAddVar 24,((>MapForest02map) - (>MapForest00map)) & $FF
  CsJumpRelVar 22,1
  CsJump Cs_TransitionIn    ;Last check, always transition
  CsJumpRelVar 24,1
  CsJump Cs_TransitionIn
  CsSetVar 1,CsDirUp        ;Go Up
  CsSetVar 21,CsDirUp*32
  CsJump Cs_TransitionIn

Cs_CurvedTransitionB:
  CsCall Cs_TransitionOut
  CsCall Cs_ClearActorList
  ;Separate the map bytes for analysis
  CsSetVar 23,0
  CsSetVar 25,0
  CsSetVarVar 22,32
  CsSetVarVar 24,33
  ;Check for exit from map 01 (to 11)
  CsAddVar 22,(0-<MapForest01map) & $FF
  CsAddVar 24,(0->MapForest01map) $ $FF
  CsJumpRelVar 22,1
  CsJump Cs_TransitionIn    ;Last check, always transition
  CsJumpRelVar 24,1
  CsJump Cs_TransitionIn    ;Last check, always transition
  CsSetVar 1,CsDirDown      ;Go Down
  CsSetVar 21,CsDirDown*32
  CsJump Cs_TransitionIn

;Used for setting up the game
Cs_LoadInit:
  CsLoadSong SongNull ;SongRetrib
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
  CsNewActor 3,CsChNarumi,0
  CsNewActor 4,CsChReimu,0
  CsWait 2
  CsInputChange 1,0     ;Cutscene control of Marisa
  CsInputChange 2,2     ;Alice, stay still
  CsInputChange 3,2
  CsInputChange 4,2
  CsAnimateActor 1,CsAnFaceDown
  CsAnimateActor 2,CsAnFaceDown
  CsAssignHat 0,1
  CsWaitMap
  CsLoadMap MapForest23map
  CsSetActor 1,130,70
  CsSetActor 2,80,55
  CsSetActor 3,95,55
  CsSetActor 4,110,55
  CsWaitMap
  CsLoadObj MapForest23obj
  CsInputChange 1,$80   ;Camera follow
  CsCall Cs_MapFadein
  CsWait 1
  CsSetActorSpeed 1,0.9
  CsAnimSpeed 1,10
  CsInputChange 1,$81   ;Playable
Cs_None:
  CsEnd

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
  CsWaitMap
  CsLoadMap MapForest23map
  CsSetActor 1,130,70
  CsWaitMap
  CsLoadObj MapForest23obj
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
  CsInputChange 1,$81   ;Playable
  CsEnd

;Component Transitions
;These are just called by the above. Not to be used alone.

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
  CsSetVar 2,0
  CsAddVar 1,CsAnWalkLeft   ;In case fancing changed
  CsAnimateActorVar 1,1
  CsAddVar 1,-CsAnWalkLeft
  CsSetVarVar 6,1   ;Index into ComputePlayerAndCamera list (24 bytes per item)
  CsSetVar 7,0
  CsMultVar 6,24
  CsSetVar 17,0
  CsSetVar 19,0
  CsCallVar 6,Cs_ComputePlayerAndCamera
  CsCall Cs_MapFadein
  CsMoveActorVar 20,1
  CsWait 37
  CsAnimateActorVar 1,1     ;Marisa, stand still
  CsInputChange 1,$81
  CsSetVarVar 32,4
  CsSetVarVar 33,5
  CsEnd

Cs_ClearActorList:
  CsSetVar 24,0
  CsSetVar 23,30
  CsDeleteActorVar 22,1
  CsAddVar 23,-1
  CsEndVar 23
  CsJumpRel -4

;Interations
;Things people say and do when you talk to them
;All must begin with a RET to prevent being called
CsInt_Debug:
  CsRunText StringTestInteraction
  CsEnd

.ENDS
