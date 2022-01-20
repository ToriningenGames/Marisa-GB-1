;Text
;A stream of bytes, some of which are displayed, and some of which edit controls
;This will integrate with Faces and Faceswap, so they are together in one file.

;How much control should be given to text?
    ;Characters (obviously)
    ;Line breaks
    ;Pauses
    ;Prompts to advance (arrow)
    ;Options & selection
    ;Face choice?
    ;End of text
    ;Start of text?
    ;Load face? (Would take 2 frames)
    ;Text speed?
    ;Clear? (For interruptions)
    ;Window movements?

;Charcters are ASCII except
    ;There are no lowercase
    ;The following characters are missing:
        ;$*+<=>@[\]`{|}^_
    ;Single and double quotes are both closing quotes specifically.
        ;` is a single opening quote
        ;< is a double opening quote
    ;Some nonstandard characters are available:
        ;There is a komejirushi.    Use "*"
        ;There is a textual smiley. Use "="
        ;There is a heart.          Use "+"
        ;There is a yen sign.       Use "$"
    ;Base text is mostly monochrome, but there are exceptions:
        ;The four palette colors can be acessed as letter squares:
            ;" " is palette 0 (BKG color)
            ;"@" is palette 1
            ;"[" is palette 2
            ;"]" is palette 3 (Text color)
    ;Two next arrows are accessable at '^' and '_'
;Characters below $30 and above $80 are treated as control, not printing.
    ;These do not have a byte following:
        ;$00 (NUL): End of text block
        ;$01 (SOH): Return to upper-left
        ;$02 (STX): Raise window
        ;$03 (ETX): Lower window
        ;$04 (EOT): Snap window up
        ;$0A (LF):  Newline
        ;$0B (VT):  Wait for input
        ;$0C (FF):  Clear
        ;$0D (CR):  Return to left, don't go to next line
        ;$0E (SO):  Show/Hide face
        ;$0F (SI):  Swap face
    ;These have a byte following:
        ;$10 (DLE): Text speed following
        ;$11 (DC1): Load face for character
        ;$12 (DC2): Load face for chara and immediately display
        ;$13 (DC3):
        ;$14 (DC4): Load border
        ;$15 (NAK): Shake w/ speed
        ;$16 (SYN): Wait for time
        ;$17 (ETB):
        ;$18 (CAN):
        ;$19 (EM):
        ;$1A (SUB):
        ;$1B (ESC):
        ;$1C (FS):
        ;$1D (GS):
        ;$1E (RS):
        ;$1F (US):

.include "macros.asm"

.DEFINE TextData    $C100
.DEFINE TextSize    5 * 32
.DEFINE WinYRaised  144 - 8 * 5
.DEFINE WinYLowered 144
.DEFINE TextStatus  $C0EA
;Control memory format:
.define TextSource $C1A0   ;Source   (Only save this if you have to!)
.define TextCurPos $C1A2   ;Cursor Position
.define TextDelay  $C1A3   ;Frame delay
.define VRAMBuf    $C1A4   ;Buffer for vRAM copy function

.DEFINE BlinkerSpot TextData+4*32+19

.ENUMID 0 EXPORT
.ENUMID textStatus_done
.ENUMID textStatus_typing
.ENUMID textStatus_waiting

.EXPORT TextData
.EXPORT TextStatus
.EXPORT TextSize

.MACRO LoadVRAMptA ARGS width, height
  LD HL,VRAMBuf
  PUSH DE
  LD D,H
  LD E,L
  LD (HL),width
  INC HL
  LD (HL),height
  INC HL
  LDI (HL),A
  LD (HL),>TextData
  INC HL
  LDI (HL),A    ;Window low
  LD (HL),$9C   ;Window high
  PUSH BC
  LD BC,LoadRectToVRAM_Task
  CALL NewTask
  POP BC
  POP DE
.ENDM
.MACRO LoadVRAM ARGS width, height, point
  LD HL,VRAMBuf
  PUSH DE
  LD D,H
  LD E,L
  LD (HL),width
  INC HL
  LD (HL),height
  INC HL
  LD (HL),point
  INC HL
  LD (HL),>TextData
  INC HL
  LD (HL),point ;Window low
  INC HL
  LD (HL),$9C   ;Window high
  PUSH BC
  LD BC,LoadRectToVRAM_Task
  CALL NewTask
  POP BC
  POP DE
.ENDM


.SECTION TextControl BITWINDOW 8 FREE
TextControlFunctions:
 .dw Text_EndOfText,    Text_Pause,          Text_RaiseWindow,  Text_LowerWindow
 .dw Text_SnapWindowUp, Text_SnapWindowDown, Text_LoadBorder0,  Text_LoadBorder1
 .dw Text_LoadBorder2,  Text_LoadBorder3,    Text_Newline,      Text_Pause
 .dw Text_Clear,        Text_Pause,          Text_ShowFace1,    Text_ShowFace2
 .dw Text_SetSpeed,     Text_ShowFace0

;Table for window Y positions during raising and lowering
WindowLUT:
 .db $8D,$8A,$88,$87,$84,$82,$80,$7F,$7D,$7B,$79,$78,$76,$75,$73,$72,$71,$70,$6F,$6E,$6D,$6C,$6B,$6B,$6A,$69,$69,$69,$68
WindowLUTEnd:
.DEFINE WindowLUTSize (WindowLUTEnd-WindowLUT)
.ENDS


.SECTION "Text Processing" FREE

TextStart:
;DE -> Text String
;Declare status
  LD HL,TextStatus
  LD (HL),textStatus_typing
  LD B,D    ;Text string
  LD C,E

;Variables needed:
    ;Speed
    ;Cursor X, Y
        ;Destination
    ;Source
    ;Facedata
;BC-> source
;HL== temp
  
TextProcessLoop:
;Processing delay
;Implements text speed
  LDH A,($FE)   ;If B is pressed, run text at max speed
  RRA
  AND %00000001
  JR nz,_textWaitLoop
  LD A,(TextDelay)
_textWaitLoop:   ;Multiple entrys to here, in case something had to wait
  CALL HaltTask
  DEC A
  JR nz,_textWaitLoop
TextProcessControlReturn:
;Next character
  LD A,(BC)
  INC BC
;Text processing:
  BIT 7,A
  JR z,+
;High character
;Check between Wait and Face Load
  BIT 6,A
  JP nz,Text_LoadFace
  AND $3F   ;Wait time
  JR _textWaitLoop
+
  CP $30
  JR nc,+
;Control character
  LD HL,TextProcessControlReturn
  PUSH HL
  LD H,>TextControlFunctions
  ADD A
  ADD <TextControlFunctions
  LD L,A
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  JP HL
+
;Normal character
  LD HL,TextCurPos
  LD L,(HL)
  LD H,>TextData
  LD (HL),A
  LD A,L
-
  LD HL,OpControl
  BIT 6,(HL)
  JR z,+
  CALL HaltTask
  JR -
+
  LD HL,TileMapBuffer
  LD (HL),1
  INC HL
  LD (HL),1
  INC HL
  LDI (HL),A
  LD (HL),>TextData
  INC HL
  LDI (HL),A    ;Window low
  LD (HL),$9C   ;Window high
  LD HL,OpControl
  SET 6,(HL)
;Move the cursor over
  LD HL,TextCurPos
  LD A,(HL)
  INC (HL)
  AND $1F
;Check for potential wrapping
  CP $13
  CALL nc,Text_Newline
  JR TextProcessLoop

Text_EndOfText:
  ;Escape this prison!
  POP HL    ;Return address
  LD HL,TextStatus  ;Update status
  LD (HL),textStatus_done
  JP EndTask

Text_LowerWindow:
;Just like RaiseWindow, but in reverse!
  POP HL    ;Return
  LD A,C
  LD (DE),A     ;Save BC
  INC DE
  LD A,B
  LD (DE),A
  LD BC,WindowLUTEnd-1
  LD A,WindowLUTSize
-
  CALL HaltTask
  PUSH AF
    LD A,(BC)
    DEC BC
    LD (WinVertScroll),A
    LD (LY),A     ;LY interrupt line for sprite disabling
  POP AF
  DEC A
  JR nz,-
  LD A,(DE)     ;Restore BC
  LD B,A
  DEC DE
  LD A,(DE)
  LD C,A
  PUSH HL   ;Stack alignment
Text_SnapWindowDown:
  POP HL    ;Return
Text_WindowSetDown:
  XOR A
  LD (LCDCounter),A   ;Disable LY interrupt
  LD A,$90              ;Final window removal
  LD (WinVertScroll),A  ;Done here to avoid disabling sprites at top of screen
  LD HL,$FFFF
  RES 1,(HL)
  JP TextProcessControlReturn

Text_RaiseWindow:
;Summation to >= 40
;9, by 1: 45
;6, by 2: 42
;5, by 3: 45
;4, by 4: 40

  POP HL    ;Return
  CALL Text_WindowSetUp
  LD A,C
  LD (DE),A
  INC DE
  LD A,B
  LD (DE),A
  LD BC,WindowLUT
  LD A,WindowLUTSize
-
  CALL HaltTask
  PUSH AF
  LD A,(BC)   ;Next frame movement delta
  INC BC
  LD (WinVertScroll),A
  LD (LY),A     ;LY interrupt line for sprite disabling
  POP AF
  DEC A
  JR nz,-
  LD A,(DE)
  LD B,A
  DEC DE
  LD A,(DE)
  LD C,A
  JP TextProcessControlReturn

Text_WindowSetUp:
  LD A,%01000000    ;Enable LY interrupt
  LD (LCDCounter),A
  XOR A
  LDH ($0F),A
  LD HL,$FFFF
  SET 1,(HL)
  RET

Text_SnapWindowUp:
  POP HL    ;Return
  CALL Text_WindowSetUp
  LD A,$68      ;Raised window position
  LD (WinVertScroll),A
  LD (LY),A     ;LY interrupt line for sprite disabling
  JP TextProcessControlReturn

Text_Newline:
;Go to beginning of line
  LD HL,TextCurPos
  LD A,(FaceState)
  OR A
  LD A,%11100000
  JR z,+
    ;Face present
  AND (HL)
  OR %00000101
  JR ++
+   ;No face present
  AND (HL)
  INC A
++
;Then move down one column
  ADD 32
  LD (HL),A
  RET

Text_Pause:
  POP HL    ;Return
;Status
  LD A,textStatus_waiting
  LD (TextStatus),A
;Place icon
  LD HL,BlinkerSpot
  LD (HL),$6E
  LD HL,VRAMBuf+5
  LD A,<BlinkerSpot
  LD (HL),$9C   ;Window page
  DEC HL
  LDD (HL),A    ;Destination
  LD (HL),>BlinkerSpot
  DEC HL
  LDD (HL),A    ;Source
  LD A,1
  LDD (HL),A    ;Height
  LD (HL),A    ;Width
  LD E,L
  LD D,H
  PUSH BC
    LD BC,LoadRectToVRAM_Task
    CALL NewTask
  POP BC
  LD A,32
-
  CALL HaltTask
;Check for button, other than pause
  LD L,A
  LDH A,($FE)
  AND %00000111 ;All buttons save Start/Directional
  JR z,+
;Do we clear or newline next?
  DEC BC    ;Get the command just ran
  LD A,(BC)
  INC BC
  LD HL,TextProcessControlReturn    ;Restore return
  PUSH HL
  CP $01
  JR z,Text_Newline
  CP $0D
  JR z,Text_Clear
  RET
+   ;Still paused
  LD A,L
  DEC A
  JR nz,-
;Animate icon
  LD HL,BlinkerSpot
  LD A,1    ;Toggle b/w the two tiles
  XOR (HL)
  LD (HL),A
  PUSH BC       ;Buffer correct from setup
    LD HL,VRAMBuf
    LD D,H
    LD E,L
    LD BC,LoadRectToVRAM_Task
    CALL NewTask
  POP BC
  RET   ;Try again

Text_Clear:
;Return cursor to the upper-left corner
;There is difficulty in telling whether the "Corner" is b/c of faces
;If a face is displayed, the corner is at window's (6,1)
;If there is no face, the corner is at window's (2,1)
  LD A,(FaceState)
  OR A
  LD A,$21  ;For no face
  JR z,+
  LD A,$25  ;For face
+
  LD HL,TextCurPos
  LD (HL),A
;And clear out the text input area
  LD L,A
  LD H,>TextData
  DEC HL    ;Actually the column before
;Clear it
  PUSH BC
--
  LD A,$30  ;Space
  LD BC,32  ;Row movement
  LD (HL),A
  ADD HL,BC
  LD (HL),A
  ADD HL,BC
  LD (HL),A
  ADD HL,BC
  LD (HL),A
  LD BC,1-3*32      ;First row, next column
  ADD HL,BC
  LD A,$33
  CP L
  JR nc,--
  LD BC,LoadToVRAM_Task
  LD A,1
  LD DE,(>TextData)<<8 | $9C
  CALL NewTask
  POP BC
  POP HL    ;Return
  LD HL,TextProcessLoop
  PUSH HL
  JP HaltTask

Text_CarriageReturn:
  LD HL,TextCurPos
  LD A,(FaceState)
  OR A
  LD A,%11100000
  JR z,+
    ;Face present
  AND (HL)
  OR %00000101
  JR ++
+   ;No face present
  AND (HL)
  INC A
++
  LD (HL),A
  RET

Text_SetSpeed:
  LD A,(BC)
  INC BC
  LD (TextDelay),A
  RET

Text_ShowFace0:
  XOR A
  .db $21   ;LD HL,$xxxx
  ;Skip the next two bytes
Text_ShowFace1:
  LD A,1
  .db $21   ;LD HL,$xxxx
  ;Skip the next two bytes
Text_ShowFace2:
  LD A,2
  POP HL    ;Return
-
  LD D,B
  LD E,C
  LD BC,FaceShow_Task
  CALL NewTask
  LD B,D
  LD C,E
  JP nc,_textWaitLoop
  CALL HaltTask     ;If not enough tasks, try again next frame
  JR -

Text_LoadFace:
  LD D,1    ;Determine which face place is being loaded to
  BIT 5,A
  JR z,+
  INC D
+
  AND $1F   ;Determine which face no. to load
-
  CALL HaltTask
  PUSH BC
    LD BC,FaceLoad_Task
    CALL NewTask
  POP BC
  JP nc,TextProcessControlReturn
  JR -      ;If task unavailable, try again next time

Text_LoadBorder0:
  LD A,$20
  .db $21   ;LD HL,$xxxx
  ;Skip the next two bytes
Text_LoadBorder1:
  LD A,$24
  .db $21   ;LD HL,$xxxx
  ;Skip the next two bytes
Text_LoadBorder2:
  LD A,$28
  .db $21   ;LD HL,$xxxx
  ;Skip the next two bytes
Text_LoadBorder3:
  LD A,$2C
  LD HL,TextData    ;At the top of window
  PUSH BC
  LD BC,$0504
-
  LDI (HL),A
  INC A
  DEC C
  JR nz,-
  LD C,4
  SUB C
  DEC B
  JR nz,-
  POP BC
  LoadVRAM 20, 1, $00
  RET

.ENDS
