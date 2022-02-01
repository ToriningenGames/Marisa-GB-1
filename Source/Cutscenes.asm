;Note: You are expected to know and calculate the offset values yourself
;This is because it carries through jumps and calls,
;and a macro is not following through all that.


.DEFINE DirHort         0
.DEFINE DirVert         1

.DEFINE DirLeft         0
.DEFINE DirDown         1
.DEFINE DirRight        2
.DEFINE DirUp           3

.DEFINE AnimFaceLeft    0
.DEFINE AnimFaceDown    1
.DEFINE AnimFaceRight   2
.DEFINE AnimFaceUp      3
.DEFINE AnimWalkLeft    4
.DEFINE AnimWalkDown    5
.DEFINE AnimWalkRight   6
.DEFINE AnimWalkUp      7

.DEFINE ChHat           0
.DEFINE ChMarisa        1
.DEFINE ChAlice         2
.DEFINE ChReimu         3
.DEFINE ChNarumi        4
.DEFINE ChFairy         5
.DEFINE ChMushroom      6


.MACRO UseVarAsVal ARGS var, offset, wait
 .IF var > %00011111
  .FAIL "Var out of range"
 .ENDIF
 .IF defined(wait)
  .db %10000000 | var, wait
 .ELSE
  .db %00000000 | var
 .ENDIF
  .db offset+1
.ENDM

.MACRO ChangeActorControl ARGS actor, value, wait
 .IF actor > %00011111
  .FAIL "Actor index out of range"
 .ENDIF
 .IF defined(wait)
  .db %10100000 | actor, wait
 .ELSE
  .db %00100000 | actor
 .ENDIF
  .db value
.ENDM

.MACRO IndirectCallCs ARGS jumpTable, index, wait
 .IF index > %00000111
  .FAIL "Table offset out of range"
 .ENDIF
 .IF defined(wait)
  .db %11000000 | index, wait
 .ELSE
  .db %01000000 | index
 .ENDIF
  .dw jumpTable
.ENDM

.MACRO CreateFairies ARGS count, wait
 .IF count > %00000111
  .FAIL "Too many fairies"
 .ENDIF
 .IF defined(wait)
  .db %11001000 | count, wait
 .ELSE
  .db %01001000 | count
 .ENDIF
.ENDM

.MACRO SetVar ARGS var, value, wait
 .IF value <= %00000111
  .IF defined(wait)
   .db %11010000 | value, wait
  .ELSE
   .db %01010000 | value
  .ENDIF
  .db var
 .ELIF value <= $FF
  .IF defined(wait)
   .db %11111101, wait
  .ELSE
   .db %01111101
  .ENDIF
  .db var, value
 .ELSE
  .FAIL "Value too large"
 .ENDIF
.ENDM

.MACRO SetVarQ ARGS var, value, wait
 .IF value > %00000111
  .FAIL "Value too large"
 .ENDIF
 .IF defined(wait)
  .db %11010000 | value, wait
 .ELSE
  .db %01010000 | value
 .ENDIF
 .db var
.ENDM

.MACRO SetVar8 ARGS var, value, wait
 .IF value > $FF
  .FAIL "Value too large"
 .ENDIF
 .IF defined(wait)
  .db %11111101, wait
 .ELSE
  .db %01111101
 .ENDIF
 .db var, value
.ENDM

.MACRO AddVar ARGS var, value, wait
 .IF value <= %00000111
  .IF defined(wait)
   .db %11011000 | value, wait
  .ELSE
   .db %01011000 | value
  .ENDIF
  .db var
 .ELIF value <= $FF
  .IF var > $7F
   .FAIL "Var index too big for 8-bit add"
  .ENDIF
  .IF defined(wait)
   .db %11111110, wait
  .ELSE
   .db %01111101
  .ENDIF
  .db var, value
 .ELIF value <= $FFFF
  .IF var > $7F
   .FAIL "Var index too big for 16-bit add"
  .ENDIF
  .IF defined(wait)
   .db %11111110, wait
  .ELSE
   .db %01111101
  .ENDIF
  .db $80|var
  .dw value
 .ELSE
  .FAIL "Value too large"
 .ENDIF
.ENDM

.MACRO AddVarQ ARGS var, value, wait
 .IF value > %00000111
  .FAIL "Value too large"
 .ENDIF
 .IF defined(wait)
  .db %11011000 | value, wait
 .ELSE
  .db %01011000 | value
 .ENDIF
 .db var
.ENDM

.MACRO AddVar8 ARGS var, value, wait
 .IF value > $FF
  .FAIL "Value too large"
 .ENDIF
 .IF var > $7F
  .FAIL "Var index too big for 8-bit add"
 .ENDIF
 .IF defined(wait)
  .db %11111110, wait
 .ELSE
  .db %01111110
 .ENDIF
 .db var, value
.ENDM

.MACRO AddVar16 ARGS var, value, wait
 .IF value > $FFFF
  .FAIL "Value too large"
 .ENDIF
 .IF var > $7F
  .FAIL "Var index too big for 16-bit add"
 .ENDIF
 .IF defined(wait)
  .db %11111110, wait
 .ELSE
  .db %01111110
 .ENDIF
 .db $80|var
 .dw value
.ENDM

.MACRO RunTextString ARGS text, wait
.IF defined(wait)
 .db %11100010, wait
.ELSE
 .db %01100010
.ENDIF
.dw text
.ENDM

.MACRO RunTextStringBlocking ARGS text, wait
.IF defined(wait)
 .db %11100011, wait
.ELSE
 .db %01100011
.ENDIF
.dw text
.ENDM

.MACRO WaitOnTextString ARGS wait
.IF defined(wait)
 .db %11100001, wait
.ELSE
 .db %01100001
.ENDIF
.ENDM

.MACRO AssignHat ARGS hatid, charid, wait
.IF hatid > %00011111
 .FAIL "Hat's actor ID too large"
.ENDIF
.IF charid > %00011111
 .FAIL "Target actor's actor ID too large"
.ENDIF
.IF defined(wait)
 .db %11100111, wait
.ELSE
 .db %01100111
.ENDIF
.db charid, hatid
.ENDM

.MACRO MoveActor ARGS id, anim, plane, xy, time, wait
.IF id > %00011111
 .FAIL "Actor ID too large"
.ENDIF
.IF anim > %00000111
 .FAIL "Animation value too large"
.ENDIF
.IF plane > 1
 .FAIL "Invalid direction"
.ENDIF
.IF defined(wait)
 .db %11101100|plane, wait
.ELSE
 .db %01101100|plane
.ENDIF
.db time, (anim*32)|id, xy
.ENDM

.MACRO MoveActorRel ARGS id, anim, plane, xy, time, wait
.IF id > %00011111
 .FAIL "Actor ID too large"
.ENDIF
.IF anim > %00000111
 .FAIL "Animation value too large"
.ENDIF
.IF plane > 1
 .FAIL "Invalid direction"
.ENDIF
.IF defined(wait)
 .db %11101110|plane, wait
.ELSE
 .db %01101110|plane
.ENDIF
.db time, (anim*32)|id, xy
.ENDM

.MACRO MoveCamera ARGS plane, xy, time, wait
.IF plane > 1
 .FAIL "Invalid direction"
.ENDIF
.IF defined(wait)
 .db %11100100|plane, wait
.ELSE
 .db %01100100|plane
.ENDIF
.db time, xy
.ENDM

.MACRO CreateActor ARGS id, type, x, y, wait
.IF id > %00011111
 .FAIL "Actor ID too large"
.ENDIF
.IF type > %00000111
 .FAIL "Actor type too large"
.ENDIF
.IF defined(wait)
 .db %11110000, wait
.ELSE
 .db %01110000
.ENDIF
.db (type*32)|id, x, y
.ENDM

.MACRO ShootDanmaku ARGS wait
.IF defined(wait)
 .db %11110001, wait
.ELSE
 .db %01110001
.ENDIF
.ENDM

.MACRO ShowMap ARGS wait
.IF defined(wait)
 .db %11110010, wait
.ELSE
 .db %01110010
.ENDIF
.ENDM

.MACRO LoadBackPalette ARGS pal, wait
.IF defined(wait)
 .db %11110011, wait
.ELSE
 .db %01110011
.ENDIF
.db pal
.ENDM

.MACRO LoadSpritePalettes ARGS pal0, pal1, wait
.IF defined(wait)
 .db %11110100, wait
.ELSE
 .db %01110100
.ENDIF
.db pal0, pal1
.ENDM

.MACRO Return ARGS wait
.IF defined(wait)
 .db %11110101, wait
.ELSE
 .db %01110101
.ENDIF
.ENDM

.MACRO Jump ARGS dest, wait
.IF defined(wait)
 .db %11110110, wait
.ELSE
 .db %01110110
.ENDIF
.dw dest
.ENDM

.MACRO JumpRelZ ARGS var, offset, wait
.IF defined(wait)
 .db %11110111, wait
.ELSE
 .db %01110111
.ENDIF
.db var, offset
.ENDM

.MACRO JumpRelNZ ARGS var, offset, wait
.IF defined(wait)
 .db %11111000, wait
.ELSE
 .db %01111000
.ENDIF
.db var, offset
.ENDM

.MACRO CallCs ARGS dest, wait
.IF defined(wait)
 .db %11111001, wait
.ELSE
 .db %01111001
.ENDIF
.dw dest
.ENDM

.MACRO LoadMap ARGS map, wait
.IF defined(wait)
 .db %11111010, wait
.ELSE
 .db %01111010
.ENDIF
.dw map
.ENDM

.MACRO LoadObjects ARGS obj, wait
.IF defined(wait)
 .db %11111011, wait
.ELSE
 .db %01111011
.ENDIF
.dw obj
.ENDM

.MACRO PlaySong ARGS song, wait
.IF defined(wait)
 .db %11111100, wait
.ELSE
 .db %01111100
.ENDIF
.dw song
.ENDM

.MACRO CompareVar ARGS var, val, wait
.IF var > $7F
 .FAIL "Var index too large"
.ENDIF
.IF val <= $FF
 .IF defined(wait)
  .db %11111111, wait
 .ELSE
  .db %01111111
 .ENDIF
 .db var, val
.ELIF val <= $FFFF
 .IF defined(wait)
  .db %11111111, wait
 .ELSE
  .db %01111111
 .ENDIF
 .db $80|var
 .dw val
.ELSE
 .FAIL "Value too large"
.ENDIF
.ENDM

.MACRO CompareVar8 ARGS var, val, wait
 .IF var > $7F
  .FAIL "Var index too large"
 .ENDIF
 .IF val > $FF
  .FAIL "Value too large"
 .ENDIF
 .IF defined(wait)
  .db %11111111, wait
 .ELSE
  .db %01111111
 .ENDIF
 .db var, val
.ENDM

.MACRO CompareVar16 ARGS var, val, wait
 .IF var > $7F
  .FAIL "Var index too large"
 .ENDIF
 .IF defined(wait)
  .db %11111111, wait
 .ELSE
  .db %01111111
 .ENDIF
 .db $80|var
 .dw val
.ENDM

.MACRO Break ARGS wait
 .IF defined(wait)
 .db %11101011, wait
 .ELSE
 .db %01101011
 .ENDIF
.ENDM

.MACRO WaitOnMap ARGS wait
 .IF defined(wait)
 .db %11100000, wait
 .ELSE
 .db %01100000
 .ENDIF
.ENDM

.MACRO AnimateActor ARGS id, anim, wait
 .IF defined(wait)
 .db %11101001, wait
 .ELSE
 .db %01101001
 .ENDIF
 .db id | (anim * 32)
.ENDM

.SECTION "Cutscene Data" FREE

;Var list
.DEFINE varAns              0
.DEFINE varEntryDir         1
.DEFINE varMapBack          3
.DEFINE varMapPtr           4
.DEFINE varObjPtr           6
.DEFINE varEnterPosRight    8
.DEFINE varEnterPosUp       10
.DEFINE varEnterPosLeft     12
.DEFINE varEnterPosDown     14
.DEFINE varReimuFull        16
.DEFINE varReimuMet         17
.DEFINE varNarumiBeat       18
.DEFINE varShroomA          19
.DEFINE varShroomB          20
.DEFINE varShroomC          21
.DEFINE varKeepMusic        22
.DEFINE varOldMap           32


;Unimplemented, here for linking reasons
Cs_ReimuMeet:
Cs_EndingB:
Cs_MushroomCollect:
  RET
Cs_EndingAC:
Cs_NarumiFightStart:
  Return


Cs_MapFadeout:
  LoadBackPalette %11111001
  LoadSpritePalettes %11100101,%11111001, 7
  LoadBackPalette %11111110
  LoadSpritePalettes %11111010,%11111110, 7
  LoadBackPalette %11111111
  LoadSpritePalettes %11111111,%11111111
  Return

Cs_MapFadein:
  LoadBackPalette %11111110
  LoadSpritePalettes %11111010,%11111110, 5
  LoadBackPalette %11111001
  LoadSpritePalettes %11100101,%11111001, 5
  LoadBackPalette %11100100
  LoadSpritePalettes %11010000,%11100100
  Return

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
  CallCs Cs_TransitionOut
  CallCs Cs_ClearActorList
  JumpRelNZ varKeepMusic,5
  PlaySong SongSpark        ;Change music
  SetVar varKeepMusic,1
  Jump Cs_TransitionIn

;Some of the non straight transitions
Cs_CurvedTransitionA:
  CallCs Cs_TransitionOut
  CallCs Cs_ClearActorList
  ;Check for exit from map 04
  CompareVar16 varOldMap,MapForest04map
  JumpRelNZ varAns,5
  SetVar varEntryDir,DirRight
  Jump Cs_TransitionIn
  ;Check for exit from map 24
  CompareVar16 varOldMap,MapForest24map
  JumpRelNZ varAns,5
  SetVar varEntryDir,DirDown
  Jump Cs_TransitionIn
  ;Check for exit from map 02
  CompareVar16 varOldMap,MapForest02map
  JumpRelNZ varAns,2     ;Always transition
  SetVar varEntryDir,DirRight
  Jump Cs_TransitionIn


;Maps that contain NPCs/Objects

;Not a shroom room, but shares with one temporally
Cs_Forest01:
  CallCs Cs_TransitionOut
  CallCs Cs_ClearActorList
  JumpRelNZ varShroomB,6
  CreateActor 2,ChMushroom,177,65
  AnimateActor 2,AnimFaceRight
;This room is also 90 degrees off from what the neighbors would indicate
;Check for exit from map 11 (Enter left if so, up if not, since only 00 is left)
  CompareVar16 varOldMap,MapForest11map
  SetVar varEntryDir,DirUp
  JumpRelNZ varAns,2
  SetVar varEntryDir,DirLeft
  Jump Cs_TransitionIn

;Shroom room
Cs_Forest30:
  CallCs Cs_TransitionOut
  CallCs Cs_ClearActorList
  JumpRelNZ varShroomA,6
  CreateActor 2,ChMushroom,30,121
  AnimateActor 2,AnimFaceDown
  Jump Cs_TransitionIn

;Shroom room
Cs_Forest04:
  CallCs Cs_TransitionOut
  CallCs Cs_ClearActorList
  JumpRelNZ varShroomB,6
  CreateActor 2,ChMushroom,177,65
  AnimateActor 2,AnimFaceRight
  Jump Cs_TransitionIn

;Shroom room
Cs_Forest11:
  CallCs Cs_TransitionOut
  CallCs Cs_ClearActorList
  ;There's a shroom in the room
  JumpRelNZ varShroomC,6
  CreateActor 2,ChMushroom,80,78
  AnimateActor 2,AnimFaceLeft
  ;Check for exit from map 01
  CompareVar16 varOldMap,MapForest01map
  JumpRelNZ varAns,2
  SetVar varEntryDir,DirDown
  Jump Cs_TransitionIn

;Reimu room
Cs_Forest00:
  CallCs Cs_TransitionOut
  CallCs Cs_ClearActorList
  JumpRelNZ varReimuFull,8
  CreateActor 2,ChReimu,112,104
  AnimateActor 2,AnimFaceDown
  ChangeActorControl 2,2     ;Interact!
  ;Check for exit from map 01
  CompareVar16 varOldMap,MapForest01map
  JumpRelNZ varAns,2
  SetVar varEntryDir,DirLeft
  Jump Cs_TransitionIn

;Alice room
Cs_Forest24:
  CallCs Cs_TransitionOut
  CallCs Cs_ClearActorList
  CreateActor 2,ChAlice,$55,$42
  AnimateActor 2,AnimFaceDown
  ChangeActorControl 2,2     ;Interactable
  Jump Cs_TransitionIn

;New setup
Cs_Intro:
;Data control things
  SetVar $90,$FF    ;Map byte
;Opening
  PlaySong SongRetrib, 38
  LoadBackPalette $FE, 38
  LoadBackPalette $FF
  LoadSpritePalettes $FF,$FF, 38
  ;First Scene setup
  LoadMap MapForestBKG03
  CreateActor 0,ChHat,0,0
  CreateActor 1,ChMarisa,138,85
  AssignHat 0,1
  ChangeActorControl 1,0     ;Cutscene control of Marisa
  AnimateActor 1,AnimFaceDown
  LoadMap MapForest23map
  LoadObjects MapForest23obj
  ShowMap
  ChangeActorControl 1,$80   ;Camera follow
  WaitOnMap
  ;Marisa walk into scene here
  CallCs Cs_MapFadein, 5
  ;RunTextStringBlocking StringOpeningMessage1
  ;Marisa does a shuffle here
  ;RunTextStringBlocking StringOpeningMessage2
  PlaySong SongMagus  ;Load main actioney song
  ;RunTextStringBlocking StringOpeningMessage3
  ChangeActorControl 1,$87   ;Playable
  Return

;Component Transitions
;These are just called by the above. Not to be used alone.

Cs_DirToAnimAndPlane:
  Break
    ;Split Var 1 to get plane; put in Var 23
    ;Turn Var 1 into animation value in Var 24
    ;Put an appropriate distance in Var 25
    ;Put its inverse in Var 26
    LD HL,$C001
    LD A,(HL)
    AND 1
    LD L,23
    LDI (HL),A
    LD A,($C001)
    ADD AnimWalkLeft
    SWAP A  ;Get it in the right spot
    ADD A
    LDI (HL),A
    ADD %00100000
    AND %01000000
    LD A,30
    JR nz,+  ;Positive or negative?
    ;Move Up/Left (Negative)
    CPL
    INC A
+
    LDI (HL),A
    CPL
    INC A
    LDI (HL),A
    CALL BreakRet
  Return

Cs_TransitionOut:
  ChangeActorControl 1,0
  CallCs Cs_DirToAnimAndPlane
  UseVarAsVal 23,4    ;X/Y Plane
  UseVarAsVal 24,4    ;Animation
  UseVarAsVal 25,3    ;Distance
  MoveActorRel 1,0,0,0,30
  CallCs Cs_MapFadeout, 7
  Break
    ;Multiply Var 3 by 26
    LD HL,$C003
    LD B,(HL)
    LD C,26
    CALL Multiply
    LD (HL),B
    DEC L
    LD (HL),C
    CALL BreakRet
  UseVarAsVal 2,3   ;MapBackBase offset
  UseVarAsVal 3,2
  LoadMap MapBackBase
  UseVarAsVal 4,3   ;Map to load
  UseVarAsVal 5,2
  LoadMap 0
  UseVarAsVal 6,3   ;Objects to load
  UseVarAsVal 7,2
  LoadObjects 0
  ShowMap
  Return
  
Cs_TransitionIn:
  CallCs Cs_DirToAnimAndPlane
  ;Get Marisa to her final position
  UseVarAsVal 1,0
  AddVarQ 1,0
  UseVarAsVal 1,0
  UseVarAsVal varEnterPosRight+1,3
  MoveActor 1,AnimWalkRight,DirVert,0,1
  UseVarAsVal 1,0
  UseVarAsVal varEnterPosRight,4
  MoveActor 1,AnimWalkRight,DirHort,0,1, 1
  ;Get Camera to update
  ChangeActorControl 1,$80, 1
  ChangeActorControl 1,0
  ;Get her in place to have her walk on screen
  UseVarAsVal 23,2    ;X/Y Plane
  UseVarAsVal 26,4    ;Inverted Distance
  MoveActorRel 1,AnimWalkRight,0,0,1, 1
  ;Walk in
  UseVarAsVal 23,4    ;X/Y Plane
  UseVarAsVal 24,5    ;Animation
  UseVarAsVal 25,4    ;Distance
  MoveActorRel 1,0,0,0,30, 15
  WaitOnMap
  CallCs Cs_MapFadein, 5
  ChangeActorControl 1,$87
  UseVarAsVal varMapPtr,2
  SetVar8 varOldMap,0
  UseVarAsVal varMapPtr+1,2
  SetVar8 varOldMap+1,0
  Return

Cs_ClearActorList:
  SetVar 23,30
  UseVarAsVal 23,0   ;Actor
  ChangeActorControl 1,$FF
  AddVar8 23,-1
  JumpRelNZ 23,-10
  Return

.ENDASM
;Made it to Alice's house; determine which ending to give
Cs_EndingAC:
  ;Specifically, is she coming from the back?
  CsAddVar 32,(0-<MapForest24map) & $FF
  CsJumpRelVar 32,1
  CsJump Cs_EndingA
  CsAddVar 33,(0->MapForest24map) & $FF
  CsJumpRelVar 33,1
  CsJump Cs_EndingA
;Ending C (Found Alice's house from the back)
Cs_EndingC:
  CallCs Cs_TransitionOut
  LoadMap MapForest02map
  CallCs Cs_ClearActorList
  PlaySong SongDoll
  CsSetVar 1,CsDirDown
  CsSetVar 21,(CsDirDown+3)*32
  CsWaitReadyMap
  ShowMap
  CallCs Cs_ComputePlayerAndCamera+8*3*1        ;Top of map
  CallCs Cs_MapFadein, 5
  CsMoveActorVar 20,1   ;Enter Marisa
  CsWait 37
  CsAnimateActor 1,CsAnFaceDown   ;Marisa, stand still
  CsRunText StringHouseBack1
  CsWaitText
  CsMoveActorTime 1,CsDirDown,90,48
  CsWait 120
  CsRunText StringHouseBack2
  CsWait 30
  ;Fairies sneak in from the front; a lot of them
  
  CsWaitText
  CallCs Cs_MapFadeout
  CsNewActor 2,CsChAlice,0
  CsWait 60*4
  CsSetActor 2,64,124   ;Alice comes home
  CsAnimateActor 2,CsAnWalkUp
  CsMoveActorTime 2,CsDirUp,75,37
  ;Door things here
  CallCs Cs_MapFadein, 5
  CsWait 60
  CsRunText StringHouseBack3
  CsWaitText
  CallCs Cs_MapFadeout
  Return

;Ending A (Found Alice's house from the front)
Cs_EndingA:
  CallCs Cs_TransitionOut
  CallCs Cs_ClearActorList
  PlaySong SongDoll
  LoadMap MapForest02map
  CsWaitReadyMap
  ShowMap
  LoadMap MapForestEndA1map   ;Ready the open door
  CallCs Cs_ComputePlayerAndCamera+8*3*3        ;Bottom of map
  CallCs Cs_MapFadein, 5
  CsMoveActorVar 20,1   ;Enter Marisa
  CsWait 37
  CsAnimateActor 1,CsAnFaceUp     ;Marisa, stand still
  CsWait 50
  CsAnimSpeed 1,$04
  CsAnimateActor 1,CsAnWalkUp   ;Ok now go
  CsMoveActorSpeed 1,CsDirUp,0.2,20
  CsMoveCameraSpeed CsDirUp,0.66,111     ;Pan camera up to house
  CsWait 360
  CsSetActorY 1,170     ;Marisa made it to the house weirdly quick
  CsSetActorX 1,64
  CsAnimateActor 1,CsAnFaceUp
  CsMoveCameraTime CsDirDown,80,40      ;Pan down to Marisa
  CsWait 80
  CsRunText StringAliceHouse1
  CsWaitText
  CsAnimSpeed 1,$06
  CsAnimateActor 1,CsAnWalkUp   ;Walk up to door
  CsMoveActorTime 1,CsDirUp,190,72
  CsWait 190
  ShowMap             ;Door opens
  CsNewActor 2,CsChAlice,0      ;Alice in doorway
  LoadMap MapForestEndA2map   ;Ready the closed door
  CsWait 1
  CsSetActor 2,64,87
  CsAnimateActor 2,CsAnFaceDown
  CsAnimateActor 1,CsAnFaceUp   ;Marisa startled
  CsMoveActorTime 1,CsDirDown,7,18
  CsWait 20
  CsRunText StringAliceHouse2
  CsWaitText
  ;Narumi check
  CsJumpRelVar 118,2
  CsRunText StringAliceHouse3   ;Beat Narumi
  CsJumpRel 1
  CsRunText StringAliceHouse4   ;Narumi not met
  CsWaitText
  CsRunText StringAliceHouse5
  CsWaitText
  CsAnimateActor 1,CsAnWalkUp   ;Marisa walks in
  CsMoveActorTime 1,CsDirUp,150,33
  CsWait 20
  CsAnimateActor 2,CsAnFaceUp   ;Alice leaves from doorway
  CsWait 30
  CsDeleteActor 2
  CsWait 100
  CsAnimateActor 1,CsAnFaceUp
  CsWait 30
  AssignHat 0,0
  CsSetActor 0,200,200
  CsWait 20
  CsRunText StringAliceHouse6
  CsDeleteActor 1
  CsWait 20
  ShowMap             ;Door close
  PlaySong SongNull
  CsWait 90
  LoadBackPalette %11111001
  LoadSpritePalettes %11100101,%11111001
  CsWait 90
  LoadBackPalette %11111110
  LoadSpritePalettes %11111010,%11111110
  CsWait 90
  LoadBackPalette %11111111
  LoadSpritePalettes %11111111,%11111111
  Return

;Ending B (Escorted by Alice)
Cs_EndingB:
  RET   ;Used as interaction function
  ;Marisa, Alice, don't move anymore, and no camera tracking
  ChangeActorControl 1,0
  ChangeActorControl 2,0
  CsRunText StringAliceEscort1
  CsWaitText
  PlaySong SongDoll
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
  CallCs Cs_MapFadeout
  LoadMap MapForestBKG01
  CsWaitReadyMap
  LoadMap MapForest02map
  ;Bottom entrance
  CsSetActor 2,100,240
  CsSetActor 1,98,250
  CsAnimateActor 2,CsAnWalkUp
  CsAnimateActor 1,CsAnWalkUp
  CsSetCamera 0,111
  CsWaitReadyMap
  LoadMap MapForestEndBmap
  CsWaitReadyMap
  ShowMap
  ;Camera follows Alice
  CallCs Cs_MapFadein, 5
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
  PlaySong SongMagus
  CsRunText StringAliceEscort4
  CsWaitText
  ;Danmaku
  
  ;Fade to black
  CallCs Cs_MapFadeout
  Return

;Bad insult lines:
  ;I'm gonna hang you with your own apron!
  ;Not if I garotte you with your own dollstrings first!
  ;I'm gonna shove so much gunpowder down your throat, it explodes out your ass!
  ;Not if I shove so many mushrooms down your throat, they sprout our your cro-

;Narumi Fight intro
Cs_NarumiFightStart:
  CallCs Cs_TransitionOut
  CallCs Cs_ClearActorList
  PlaySong SongNull   ;No song plays if the fight is finished
  CsSetVar 126,0        ;Change music on exit
  CsNewActor 2,CsChNarumi,0
  CsWait 2
  CsSetActor 2,56,72
  CsAnimateActor 2,CsAnFaceDown
  CallCs Cs_TransitionIn
  ChangeActorControl 1,$87
  ReturnVar 118,1        ;No text etc if the fight already happened
  ChangeActorControl 1,$80   ;Camera follow, but sit still
  CsRunText StringNarumiStart1
  CsWaitText
  PlaySong SongMagus
  CsRunText StringNarumiStart2
  CsWaitText
  ;Return

;Narumi Fight outro
Cs_NarumiFightEnd:
  PlaySong SongDoll
  CsRunText StringNarumiEnd
  CsWaitText
  CsSetVar 118,1        ;Narumi is beaten
  ChangeActorControl 1,$87   ;Marisa may leave
  Return

;Feeding Reimu Shrooms
Cs_ReimuMeet:
  RET
  ChangeActorControl 1,0
  CallCs Cs_ReimuFeed
  ChangeActorControl 1,$87
  ReturnVar 116,1
  ChangeActorControl 1,0
  CsRunText StringReimuMeet
  CsWaitText
  CsSetVar 116,1
  ChangeActorControl 1,$87
  Return
  
Cs_ReimuFeed:
  ReturnVar 116
  ;Does Marisa have mushrooms?
  CallCs Cs_ReimuMushroomTest
  ReturnVar 0
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
  CsJumpRelVar 120,3
  CsJumpRelVar 122,2
  CsJumpRelVar 124,1
  CsJump Cs_ReimuDone
  CsRunText StringReimuFeed3
  CsWaitText
  Return

Cs_ReimuDone:
  CsRunText StringReimuFeed4
  CsWaitText
  CsAnimateActor 2,CsAnFaceUp
  CsRunText StringReimuFeed5
  CsWaitText
  CsAnimateActor 2,CsAnFaceDown
  CsRunText StringReimuFeed6
  CsWaitText
  CsAnimateActor 2,CsAnFaceLeft
  CsWait 20
  CsAnimateActor 2,CsAnWalkLeft
  CsMoveActorTime 2,CsDirLeft,40,6
  CsWait 40
  CsAnimateActor 2,CsAnFaceLeft
  CsWait 70
  CsAnimateActor 2,CsAnWalkLeft
  CsMoveActorTime 2,CsDirLeft,40,6
  CsWait 40
  CsAnimateActor 2,CsAnFaceLeft
  CsWait 70
  CsAnimateActor 2,CsAnWalkLeft
  CsMoveActorTime 2,CsDirLeft,60,10
  CsWait 30
  CsSetVar 114,0
  Return

;Uses Var 0 for whether Marisa has shrooms or not
Cs_ReimuMushroomTest:
  CsSetVar 0,1
  ReturnVar 120,1
  ReturnVar 122,1
  ReturnVar 124,1
  ;No mushrooms collected
  CsSetVar 0,0
  CsRunText StringReimuFeed1
  CsWaitText
  Return

Cs_MushroomCollect:
  RET
  CsDeleteActor 2   ;Mushroom plucked
  CsSetVarVar 0,32
  CsSetVarVar 1,33
  ;Check for map 30
  CsAddVar 0,(0 - <MapForest30map) & $FF
  CsAddVar 1,(0 - >MapForest30map) & $FF
  CsJumpRelVar 0,1
  CsJumpRel 4
  CsJumpRelVar 1,1
  CsJumpRel 2
  CsSetVar 120,1
  CsJumpRel 9
  ;Check for map 11
  CsAddVar 0,((<MapForest30map) - (<MapForest11map)) & $FF
  CsAddVar 1,((>MapForest30map) - (>MapForest11map)) & $FF
  CsJumpRelVar 0,1
  CsJumpRel 4
  CsJumpRelVar 1,1
  CsJumpRel 2
  CsSetVar 124,1
  CsJumpRel 1
  ;Assume map 04
  CsSetVar 122,1
  ;String stuff runs last, so the player doesn't have time to switch rooms
  CsWaitText
  CsRunText StringMushroomFound
  Return
.ASM
.ENDS
