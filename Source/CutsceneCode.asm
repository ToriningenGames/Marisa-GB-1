
;Wanted funtions:
    ;Wait value is inserted as second byte
    ;Use var as future value
        ;%W00VVVVV OOOOOOOO
        ; |||||||| ++++++++--- Offset from next instruction to overlay
        ; |||+++++--- Variable index
        ; |++--- Constant
        ; +--- Wait time posted after
    ;Control change
        ;%W01IIIII CCCCCCCC
        ; |||||||| ++++++++--- Control value
        ; |||+++++--- ID
        ; |++--- Constant
        ; +--- Wait time posted after

    ;Call from table
        ;%W1000VVV TTTTTTTT TTTTTTTT
        ; |||||||| ++++++++-++++++++--- Table address
        ; |||||+++--- Index
        ; |++++--- Constant
        ; +--- Wait time posted after
    ;Make fairies
        ;%W1001CCC
        ; |||||+++--- Count
        ; |++++--- Constant
        ; +--- Wait time posted after
    ;Set var (short)
        ;%W1010VVV IIIIIIII
        ; |||||||| ++++++++--- Variable index
        ; |||||+++--- Value
        ; |++++--- Constant
        ; +--- Wait time posted after
    ;Add to var (short)
        ;%W1011VVV IIIIIIII
        ; |||||||| ++++++++--- Variable index
        ; |||||+++--- Value
        ; |++++--- Constant
        ; +--- Wait time posted after

    ;Run text
        ;%W110001P TTTTTTTT TTTTTTTT
        ; |||||||| ++++++++-++++++++--- Text
        ; |||||||+--- Wait for text to finish
        ; |++++++--- Constant
        ; +--- Wait time posted after
    ;Wait on text
        ;%W1100001
        ; ||||||||
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Wait on map to be shown
        ;%W1100000
        ; ||||||||
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Assign Hat
        ;%W1100111 000CCCCC 000HHHHH
        ; |||||||  |||||||| |||+++++--- Hat ID
        ; |||||||  |||||||| +++--- Constant
        ; |||||||  |||+++++--- Target ID
        ; |++++++--+++--- Constant
        ; +--- Wait time posted after
    ;Camera, go here
        ;%W110010Y TTTTTTTT DDDDDDDD
        ; |||||||| |||||||| ++++++++--- X/Y dest
        ; |||||||| ++++++++--- Take this long to move
        ; |||||||+--- Move on Y if set (move on X if clear)
        ; |++++++--- Constant
        ; +--- Wait time posted after
    ;Breakout
        ;%W1101011 ...
        ; |||||||  +++--- Code
        ; |++++++--- Constant
        ; +--- Wait time posted after
    ;You, go here (with this animation)
        ;%W11011RY TTTTTTTT AAAIIIII DDDDDDDD
        ; |||||||| |||||||| |||||||| ++++++++--- X/Y dest
        ; |||||||| |||||||| |||+++++--- Actor ID
        ; |||||||| |||||||| +++--- Animation
        ; |||||||| ++++++++--- Take this long to move
        ; |||||||+--- Move on Y if set (move on X if clear)
        ; ||||||+--- Move relative to current position if set (absolute if clear)
        ; |+++++--- Constant
        ; +--- Wait time posted after

    ;You, exist
        ;%W1110000 SSSIIIII XXXXXXXX YYYYYYYY
        ; |||||||| |||||||| |||||||| ++++++++--- Y position
        ; |||||||| |||||||| ++++++++--- X position
        ; |||||||| |||+++++--- ID
        ; |||||||| +++--- Species
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Danmaku Start
        ;%W1110001
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Show this map file
        ;%W1110010
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Load Background palette
        ;%W1110011 PPPPPPPP
        ; |||||||| ++++++++--- New background palette
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Load Sprite palettes
        ;%W1110100 PPPPPPPP PPPPPPPP
        ; |||||||| |||||||| ++++++++--- New sprite palette 1
        ; |||||||| ++++++++--- New sprite palette 0
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Return
        ;%W1110101
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Jump
        ;%W1110110 DDDDDDDD DDDDDDDD
        ; |||||||| ++++++++-++++++++--- Destination
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Jump if var zero
        ;%W1110111 VVVVVVVV DDDDDDDD
        ; |||||||| |||||||| ++++++++--- Distance
        ; |||||||| ++++++++--- Var to check
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Jump if var nonzero
        ;%W1111000 VVVVVVVV DDDDDDDD
        ; |||||||| |||||||| ++++++++--- Distance
        ; |||||||| ++++++++--- Var to check
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Call
        ;%W1111001 DDDDDDDD DDDDDDDD
        ; |||||||| ++++++++-++++++++--- Dest
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Load this map file
        ;%W1111010 MMMMMMMM MMMMMMMM
        ; |||||||| ++++++++-++++++++--- Map file location
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Load this object file
        ;%W1111011 OOOOOOOO OOOOOOOO
        ; |||||||| ++++++++-++++++++--- Object file location
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Play song
        ;%W1111100 SSSSSSSS SSSSSSSS
        ; |||||||| ++++++++-++++++++--- Song
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Set var
        ;%W1111101 VVVVVVVV CCCCCCCC
        ; |||||||| |||||||| ++++++++--- Value
        ; |||||||| ++++++++--- Variable index
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Add to var (8 bit)
        ;%W1111110 0VVVVVVV CCCCCCCC
        ; |||||||| |||||||| ++++++++--- Value
        ; |||||||| |+++++++--- Variable index
        ; |+++++++-+--- Constant
        ; +--- Wait time posted after
    ;Add to var (16 bit)
        ;%W1111110 1VVVVVVV CCCCCCCC CCCCCCCC
        ; |||||||| |||||||| ++++++++-++++++++--- Value
        ; |||||||| |+++++++--- Variable index
        ; |+++++++-+--- Constant
        ; |+++++++--- Constant
        ; +--- Wait time posted after
    ;Compare for equality (Set var 0 to difference)
        ;%W1111111 0VVVVVVV CCCCCCCC
        ; |||||||| |||||||| ++++++++--- Value
        ; |||||||| |+++++++--- Variable index
        ; |+++++++-+--- Constant
        ; +--- Wait time posted after
    ;Compare (16 bit)
        ;%W1111111 1VVVVVVV CCCCCCCC CCCCCCCC
        ; |||||||| |||||||| ++++++++-++++++++--- Value
        ; |||||||| |+++++++--- Variable index
        ; |+++++++-+--- Constant
        ; +--- Wait time posted after


;We meddle with these structures
.include "ActorData.asm"
.include "mapDef.asm"

.SECTION "Cutscene Code" FREE

;Instruction Tables:
_3arg:
 .dw CallTable,   CreateFairy,       VarQuick, VarQuick
_2arg:
 .dw RunText,     AssignHatOrCamera, Breakout,  MoveActor
_0arg:
 .dw CreateActor, ShootDanmaku,      ShowMap,  LoadBkgCol
 .dw LoadObjCol,  Return,            Jump,     JumpVarZ
 .dw JumpVarNZ,   CallCutscene,      LoadMap,  LoadObj
 .dw PlaySong,    SetVar,            AddVar,   CompareVar

CharaTypes:
 .dw HatActorData
 .dw CharaActorData
 .dw AliceActorData
 .dw ReimuActorData
 .dw NarumiActorData
 .dw FairyActorData
 .dw MushroomActorData


.DEFINE varPage             $C0
.DEFINE TriggerSpace        $C060
.DEFINE CutsceneActiveCnt   $C07E
.DEFINE WaitCount           $C07F
.DEFINE Cutscene_Actors     $C0A0
.DEFINE Cutscene_ActorSetup $C0C0

.EXPORT Cutscene_Actors
.DEFINE Cutscene_VarPage varPage
.EXPORT Cutscene_VarPage

.DEFINE TriggerCount 8      ;This limits how many vars can be used at once


NextCutsceneByte:
  PUSH BC
  LD A,(DE)     ;Next byte
  INC DE
  ;Any substitutes trigger?
  LD HL,TriggerSpace
  LD C,TriggerCount     ;Trigger Count
-
  DEC (HL)
  INC HL
  JR nz,+
  ;Sub triggered
  ADD (HL)      ;Overlay
  LD (HL),0     ;Deactivate
+
  INC HL
  DEC C
  JR nz,-
;Triggers done
  POP BC
  RET

Cutscene_Task:
  ;DE->Cutscene data
  LD HL,CutsceneActiveCnt
  INC (HL)      ;Nest one more layer
--
  ;Perform an instruction
  CALL CutsceneDecode
  ;Wait as necessary
  LD A,(WaitCount)
  OR A
  JR z,--
-
  RST $00
  DEC A
  JR nz,-
  LD (WaitCount),A  ;Finished wait; don't wait again next frame
  JR --

CutsceneDecode:
;Decodes and executes one instruction
  CALL NextCutsceneByte
  LD C,A
  BIT 7,C
  JR z,+
  ;Wait time here
  CALL NextCutsceneByte
  LD (WaitCount),A
+
;Decode the instruction
  BIT 6,C
  JR nz,+
  ;%WxxVVVVV
  BIT 5,C
  JR z,UseVar
  JR ChangeControl
+
  BIT 5,C
  JR nz,+
  ;%W1xxxVVV
  LD A,%00111000
  AND C
  RRCA
  RRCA
  LD HL,_3arg
  JR ++
+
  BIT 4,C
  JR nz,+
  ;%W11xxxVV
  LD A,%00011100
  AND C
  RRCA
  LD HL,_2arg
  JR ++
+
  ;%W111xxxx
  LD A,%00001111
  AND C
  RLCA
  LD HL,_0arg
++  ;Instruction found; jump to it
  ADD L
  LD L,A
  LD A,0
  ADC H
  LD H,A
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  JP HL

UseVar:
;Find open trigger space
  LD HL,TriggerSpace+TriggerCount*2-1
-
  XOR A
  OR (HL)
  DEC HL
  DEC HL    ;Do not affect zero flag
  JR nz,-
;Found open space
  INC L
  ;Offset first
  PUSH HL
    CALL NextCutsceneByte
  POP HL
  LDI (HL),A
  ;Var val next
  LD A,%00011111
  AND C
  LD C,A
  LD B,varPage
  LD A,(BC)
  LD (HL),A
  RET

ChangeControl:
  CALL NextCutsceneByte
  LD B,A
  LD A,%00011111
  AND C
  ;Get Actor to send message to
  ADD <Cutscene_Actors
  LD L,A
  LD H,>Cutscene_Actors
  ;Are we deleting?
  LD A,B
  INC A
  LD A,(HL)
  JR nz,+
  ;Delete actor
  LD (HL),0
+
  OR A      ;Check for empty actor
  RET z
  CALL Access_ActorDE
  LD A,%00011111
  AND C
  DEC A         ;Ready zero flag for Player Character check here
  LD A,B            ;Send message
  LD BC,_ControlState
  ADD HL,BC
  LD (HL),A
  RET nz
  ;Is player character; adjust button state
  LD BC,_ButtonState-_ControlState
  ADD HL,BC
  LD (HL),0
  RET

CallTable:
  ;Ready index into offset
  LD A,%00000111
  AND C
  ADD A
  LD C,A
  ;Get address
  CALL NextCutsceneByte
  LD B,A
  CALL NextCutsceneByte
  LD H,A
  LD L,B
  ;Squish them together
  LD B,0
  ADD HL,BC
  ;Get actual cutscene destination
  LD B,(HL)
  INC HL
  LD A,(HL)
  ;Call this cutscene
  JR _CallCutsceneInternal

CallCutscene:
  CALL NextCutsceneByte
  LD B,A
  CALL NextCutsceneByte
_CallCutsceneInternal:
  PUSH DE
    LD E,B
    LD D,A
    LD BC,Cutscene_Task
    CALL NewTask
  POP DE
  POP BC    ;Return
  LD HL,CutsceneActiveCnt
  LD A,(HL)
-   ;Wait for cutscene to end
  RST $00
  LD HL,CutsceneActiveCnt
  CP (HL)
  JR nz,-
  PUSH BC
  RET
  
Jump:
  CALL NextCutsceneByte
  LD B,A
  CALL NextCutsceneByte
  LD D,A
  LD E,B
  RET

CreateActor:
  CALL NextCutsceneByte
  PUSH AF
  PUSH DE
    ;Get actor type
    AND %11100000
    SWAP A
    ADD <CharaTypes
    LD L,A
    LD H,>CharaTypes
    LDI A,(HL)
    LD D,(HL)
    LD E,A
    ;Create actor in slot
    LD BC,Actor_FrameInit
    CALL NewTaskLo
  POP DE
  POP AF
  ;Put new actor in slot
  AND %00011111
  ADD <Cutscene_Actors
  LD L,A
  LD H,>Cutscene_Actors
  LD (HL),B
  LD A,B
  POP BC        ;Return
  RST $00 ;Give actor a moment to initialize
  PUSH BC       ;Return
  CALL Access_ActorDE
  LD B,H
  LD C,L
  CALL NextCutsceneByte
  ;Set X
  INC BC
  INC BC
  INC BC
  LD (BC),A
  CALL NextCutsceneByte
  ;Set Y
  INC BC
  INC BC
  LD (BC),A
  RET

VarQuick:
  CALL NextCutsceneByte
  LD H,varPage
  LD L,A
  LD A,%00000111
  AND C
  ;Sign extend
  ;BIT 2,A
  ;JR z,+
  ;OR %11111000
+
  BIT 3,C
  JR z,+
  ADD (HL)
+
  LD (HL),A
  RET

CreateFairy:
  ;Get a random number
  ;Make that fairy
  ;Put it at a random spot (~0 away from the player)
  ;Repeat for the given count
  RET

AssignHatOrCamera:
  BIT 1,C
  JR z,MoveCamera
AssignHat:
  CALL NextCutsceneByte    ;Get Target
  ADD <Cutscene_Actors
  LD L,A
  LD H,>Cutscene_Actors
  LD A,(HL)
  CALL Access_ActorDE
  PUSH HL
    CALL NextCutsceneByte      ;Get Hat
    ADD <Cutscene_Actors
    LD L,A
    LD H,>Cutscene_Actors
    LD A,(HL)
    CALL Access_ActorDE
    LD BC,_ParentChar
    ADD HL,BC
  POP BC    ;Target
  ;Put Target in Hat data
  LD (HL),C
  INC HL
  LD (HL),B
  RET

MoveCamera:
  ;Test direction
  LD B,<BkgVertScroll
  BIT 0,C
  JR nz,+
  ;Horizontal movement
  LD B,<BkgHortScroll
+
  CALL NextCutsceneByte
  LD C,A
  CALL NextCutsceneByte
  PUSH DE
    LD D,B
    LD E,C
    LD BC,MoveCamera_Task
    CALL NewTask
  POP DE
  RET

Breakout:
;Call the followng code in the cutscene
  PUSH DE
  RET
BreakRet:
;Get next DE value from the given return value
  POP DE    ;Return/CS
  RET

MoveActorAnim_Task:
;Handle the actor animations here
;A= MoveActor_Task ID
;D= Actor ID
;E= Animation
  PUSH AF
    LD A,D
    ADD <Cutscene_Actors
    LD L,A
    LD H,>Cutscene_Actors
    LD A,(HL)
    LD D,A
    CALL Access_ActorDE
    LD BC,_AnimChange
    ADD HL,BC
    LD (HL),E
  POP AF
  LD B,E
  LD C,D
  CALL WaitOnTask
  LD A,C
  CALL Access_ActorDE
  LD DE,_AnimChange
  ADD HL,DE
  LD A,B
  AND $03
  LD (HL),A
  JP EndTask

MoveActor_Task:
;A= %D00AAAAA
    ;|  +++++--- Actor ID
    ;+--- Set for Y movement
;D= Destination
;E= Time
  LD C,A
  AND %00011111
  ADD <Cutscene_Actors
  LD L,A
  LD H,>Cutscene_Actors
  LD A,(HL)
  CALL Access_ActorDE
  INC HL
  INC HL    ;Go to X lo position
  BIT 6,C
  JR z,+
  INC HL    ;Go to Y lo position
  INC HL
+   ;HL now pointing to the correct dimension
  LD B,H
  LD C,L
  LD A,D
  ;Move actor blindly as distance over time,
  ;and we're guaranteed to end up in the right spot when time == 1
-
  RST $00
  ;Perform movement for this frame
  LD H,B
  LD L,C
  PUSH HL
    BIT 7,A
    PUSH AF     ;Need the zero flag
      JR z,+
      CPL     ;Division is unsigned; negate if needed
      INC A
+
      LD B,A
      LD C,0
      PUSH DE
        CALL Divide
      POP DE
    POP AF
    JR z,+
    ;Value was negative; re-negate
    LD A,L
    CPL
    LD L,A
    LD A,H
    CPL
    LD H,A
    INC HL
+
    LD B,H
    LD A,L
  POP HL
  ;Move character
  ADD (HL)
  LDI (HL),A
  LD A,B
  ADC (HL)
  LDD (HL),A
  ;We moved an amount; subtract it
  LD A,D
  SUB B
  LD D,A
  ;Restore BC to their initial values
  LD B,H
  LD C,L
  ;...but update frame counter
  DEC E
  JR nz,-
  JP EndTask

MoveActor:
  LD A,$03      ;Dir bit, Rel bit
  AND C
  RRCA
  RRCA
  LD C,A
  CALL NextCutsceneByte
  LD B,A
  CALL NextCutsceneByte
  PUSH AF
    AND %00011111
    OR C
    LD C,A
    CALL NextCutsceneByte
    PUSH DE
      BIT 7,C
      JR nz,++      ;Rel bit?
      ;Absolute position; make relative
      LD D,A
      LD A,%00011111
      AND C
      ADD <Cutscene_Actors
      LD L,A
      LD H,>Cutscene_Actors
      LD A,(HL)
      CALL Access_ActorDE
      INC HL
      INC HL
      INC HL
      BIT 6,C
      LD A,D
      JR z,+
      ;Go to Y
      INC HL
      INC HL
+
      SUB (HL)
++
      LD D,A      ;Destination
      LD E,B      ;Time
      LD A,C      ;Actor, plane
      LD BC,MoveActor_Task
      CALL NewTask
    POP DE
  POP AF
  PUSH DE
    LD D,A
    AND %11100000
    SWAP A
    RRCA
    LD E,A    ;Anim
    LD A,%00011111
    AND D
    LD D,A    ;Actor ID
    LD A,B    ;Task ID
    LD BC,MoveActorAnim_Task
    CALL NewTask
  POP DE
  RET

MoveCamera_Task:
;A= Destination
;D= Address
;E= Time
  PUSH AF   ;Save the initial value of Destination each time
    LD L,D
    LD H,>BkgVertScroll   ;Also hort; depends on D
    SUB (HL)
    JP z,EndTask      ;Already there
    PUSH HL
      PUSH AF     ;Need the carry flag
        PUSH BC
          JR nc,+
          CPL     ;Division is unsigned; negate if needed
          INC A
+
          LD B,0
          LD C,A
          PUSH DE
            CALL Divide
          POP DE
        POP BC
        ADD B         ;Accumulate remainder
        LD B,A
        LD A,0
        ADC L
        LD L,A
      POP AF
      LD A,L
      JR nc,+
      ;Value was negative; re-negate
      CPL
      INC A
+
    POP HL
    ADD (HL)
    LD (HL),A
  POP AF
  LD D,L    ;Restore A and D to initial values
  DEC E     ;...but update the frame counter
  RST $00         ;Do again next frame
  JR MoveCamera_Task

RunText:
  ;Are we waiting for the last one to finish? (Or a map wait)
  BIT 1,C
  JR z,WaitTextOrMap
  LD A,C
  PUSH AF
    CALL NextCutsceneByte
    LD B,A
    CALL NextCutsceneByte
    PUSH DE
      LD D,A
      LD E,B
      LD BC,TextStart
      CALL NewTask
    POP DE
  POP AF
  ;Are we letting this one finish?
  AND $01
  RET z
  ;Fall through
WaitText:
  POP BC    ;Return
  RST $00
  LD A,(TextStatus)
  CP textStatus_done
  RET nz    ;Not now
  PUSH BC
  RET

WaitTextOrMap:
  BIT 0,C
  JR nz,WaitText
  ;Wait for map showing to be done
  POP BC    ;Return
  RST $00
  LD HL,hotMap
  LD A,(HL)
  INC A
  RET nz
  PUSH BC   ;Return
  RET

ShowMap:
  ;Wait for map loading to be ready
  POP BC    ;Return
  RST $00
  LD HL,hotMap
  BIT 7,(HL)
  RET z
  PUSH BC
  LD BC,ShowMap_Task
  JP NewTask

LoadBkgCol:
  CALL NextCutsceneByte
  LD (BkgPal),A
  RET

LoadObjCol:
  CALL NextCutsceneByte
  LD (SpritePal0),A
  CALL NextCutsceneByte
  LD (SpritePal1),A
  RET

Return:
  ;End this task
  LD HL,CutsceneActiveCnt
  DEC (HL)      ;Finish this layer
  POP HL    ;Return
  JP EndTask

JumpVarZ:
  CALL JumpVar
  RET nz
  JR +
  
JumpVarNZ:
  CALL JumpVar
  RET z
+
  LD C,B
  ;Sign extend
  LD B,0
  BIT 7,C
  JR z,+
  LD B,$FF
+   ;Go
  LD H,D
  LD L,E
  ADD HL,BC
  LD D,H
  LD E,L
  RET

JumpVar:
  CALL NextCutsceneByte
  LD C,A
  CALL NextCutsceneByte
  LD B,A
  LD L,C
  LD H,varPage
  LD A,(HL)
  OR A
  RET

LoadMap:
  ;Wait for map loading to be ready
  POP BC    ;Return
  RST $00
  LD HL,hotMap
  BIT 7,(HL)
  RET z
  PUSH BC   ;Return
  CALL NextCutsceneByte
  LD C,A
  CALL NextCutsceneByte
  PUSH DE
    LD D,A
    LD E,C
    LD BC,LoadMap_Task
    CALL NewTask
  POP DE
  RET

LoadObj:
  ;Wait for map loading to be ready
  POP BC    ;Return
  RST $00
  LD HL,hotMap
  BIT 7,(HL)
  RET z
  PUSH BC   ;Return
  CALL NextCutsceneByte
  LD C,A
  CALL NextCutsceneByte
  LD B,A
  LD HL,ObjArea
  LD A,8
-
  PUSH AF
    LD A,(BC)
    INC BC
    LDI (HL),A
  POP AF
  DEC A
  JR nz,-
  RET

PlaySong:
  CALL NextCutsceneByte
  LD C,A
  CALL NextCutsceneByte
  LD B,A
  CALL MusicLoad
  LD (HL),$FF
  RET

SetVar:
  CALL NextCutsceneByte
  LD C,A
  CALL NextCutsceneByte
  LD L,C
  LD H,varPage
  LD (HL),A
  RET

AddVar:
  CALL NextCutsceneByte
  LD C,A
  CALL NextCutsceneByte
  LD L,C
  RES 7,L
  LD H,varPage
  ADD (HL)
  LDI (HL),A
  BIT 7,C
  RET z
  PUSH AF   ;We need the carry
  PUSH HL
    CALL NextCutsceneByte
    LD C,A
  POP HL
  POP AF
  LD A,C
  ADC (HL)
  LD (HL),A
  RET

CompareVar:
  CALL NextCutsceneByte
  LD C,A
  CALL NextCutsceneByte
  LD L,C
  RES 7,L
  LD H,varPage
  SUB (HL)
  INC L
  LD (varPage*256),A
  BIT 7,C
  RET z
  LD A,L
  PUSH AF   ;Maintain add's carry
  PUSH HL
    CALL NextCutsceneByte
    LD C,A
  POP HL
  POP AF
  LD A,C
  SBC (HL)
  LD (varPage*256+1),A
  RET

ShootDanmaku:
  RET

.ENDS
