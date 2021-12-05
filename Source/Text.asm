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
    ;Two down arrows are accessable at '^' and '_'
;Characters below $30 and above $80 are treated as control, not printing.
    ;These do not have a byte following:
        ;$00 (NUL): End of text block
        ;$01 (SOH): Return to upper-left
        ;$02 (STX): Raise window
        ;$03 (ETX): Lower window
        ;$04 (EOT): Move cursor up
        ;$05 (ENQ): Move cursor down
        ;$06 (ACK): Move cursor left
        ;$07 (BEL): Move cursor right
        ;$08 (BS):  Deletes last printed character
        ;$09 (HT):  Four spaces
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
;Dynamic memory format:
.define _textSource 0   ;+$00: Source   (Only save this if you have to!)
.define _textCurPos 2   ;+$02: Cursor Position
.define _textDelay  3   ;+$03: Frame delay
.define _vRAMBuf    4   ;+$04: Buffer for vRAM copy function
;+$0A
;+$20: OOB

.DEFINE BlinkerSpot TextData+4*32+19

.ENUMID 0 EXPORT
.ENUMID textStatus_done
.ENUMID textStatus_typing
.ENUMID textStatus_waiting

.EXPORT TextData
.EXPORT TextStatus
.EXPORT TextSize

.MACRO LoadVRAMptA ARGS width, height
  LD HL,_vRAMBuf
  ADD HL,DE
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
  LD HL,_vRAMBuf
  ADD HL,DE
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


.SECTION TextControl ALIGN 256 FREE
TextControlFunctions:
 .dw Text_EndOfText,    Text_ReturnToCorner, Text_RaiseWindow,  Text_LowerWindow
 .dw Text_MoveUp,       Text_MoveDown,       Text_MoveLeft,     Text_MoveRight
 .dw Text_Backspace,    Text_Tab,            Text_Newline,      Text_Pause
 .dw Text_Clear,        Text_CarriageReturn, Text_Error,        Text_Error
 .dw Text_SetSpeed,     Text_LoadFace,       Text_ShowFace,     Text_Error
 .dw Text_LoadBorder,   Text_Shake,          Text_Wait;,         Text_Error

;Table for window Y positions during raising and lowering
WindowLUT:
 .db $90,$8D,$8A,$88,$87,$84,$82,$80,$7F,$7D,$7B,$79,$78,$76,$75,$73,$72,$71,$70,$6F,$6E,$6D,$6C,$6B,$6B,$6A,$69,$69,$69,$68
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
;DE-> Allocated memory
;HL== temp
;Getting dynamic memory
  CALL MemAlloc
;Shall Face code take a pointer like this? Any need?
  LD HL,_textCurPos
  ADD HL,DE
  LD (HL),<TextData + 33
  INC HL
  LD (HL),1 ;Delay
  
TextProcessLoop:
;Processing delay
;Implements text speed
  LD HL,_textDelay
  ADD HL,DE
  LD A,(HL)
_textWaitLoop:   ;Multiple entrys, in case something had to wait
  CALL HaltTask
  DEC A
  JR nz,_textWaitLoop
TextProcessControlReturn:
;Next character
  LD A,(BC)
  INC BC
;Text processing:
  CP $80
  JR c,+
;High character
;There aren't any of these...
  RST $38
  JR TextProcessLoop
+
  CP $30
  JR nc,+
;Control character
  CCF   ;NO CARRY!
  LD HL,TextProcessControlReturn
  PUSH HL
  LD H,>TextControlFunctions
  RLA
  LD L,A
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  JP HL
+
;Normal character
  LD HL,_textCurPos
  ADD HL,DE
  LD L,(HL)
  LD H,>TextData
  LD (HL),A
  LD A,L
  LoadVRAMptA 1, 1      ;Idea: Don't initiate a task for this.
  CALL Text_MoveRight
  JR TextProcessLoop

Text_Wait:
  LD A,(BC)
  INC BC
  POP HL    ;Return address
  JR _textWaitLoop

Text_Shake:
  LD A,(BC)
  INC BC
  PUSH BC
  LD BC,Text_Shake_Task
  CALL NewTask
  POP BC
  RET

Text_Shake_Task:
  RLCA      ;Delay (converted to fixed 8.8 from fixed 3.5)
  RLCA
  RLCA
  LD B,A
  AND $F8
  LD C,A
  LD A,$03
  AND B
  LD B,A
  LD DE,$0800   ;Magnitude (fixed 8.8)
  LD A,D
-   ;Move screen right and left, with one frame delays
  LD HL,WinHortScroll
  ADD (HL)
  LD (HL),A
  CALL HaltTask
  SUB D
  LD (WinHortScroll),A
  CALL HaltTask
  SUB D
  LD (WinHortScroll),A
  CALL HaltTask
  ADD D
  LD (WinHortScroll),A
  CALL HaltTask
;Decay
  LD A,E
  SUB C
  LD E,A
  LD A,D
  SBC B
  LD D,A
  JR nc,-
  JP EndTask
  
;Old method
  ;WinX += -C
  ;for (C *= 2; C; C--)
    ;for (i = 0; i < C; i++) WinX++, delay
    ;C--
    ;for (i = 0; i < C; i++) WinX--, delay
  LD C,16   ;C*2 as above
  LD (HL),0 ;Initial (-8 because of window's offset)
  LD D,C    ;i as above
Text_Shake_Task_Loop:
  LD D,C
-
  LD A,B
--
  CALL HaltTask
  DEC A
  JR nz,--
  LD HL,WinHortScroll
  INC (HL)
  DEC D
  JR nz,-
  DEC C
  LD D,C
-
  LD A,B
--
  CALL HaltTask
  DEC A
  JR nz,--
  LD HL,WinHortScroll
  DEC (HL)
  DEC D
  JR nz,-
  DEC C
  JR nz,Text_Shake_Task_Loop
  JP EndTask

Text_EndOfText:
  ;Escape this prison!
  CALL MemFree
  POP HL    ;Return address
  LD HL,TextStatus  ;Update status
  LD (HL),textStatus_done
  JP EndTask

Text_ReturnToCorner:
;There is difficulty in telling whether the "Corner" is b/c of faces
;If a face is displayed, the corner is as window's (4,1)
;If there is no face, the corner is at window's (2,1)
;Because of this ambiguity, this command is marked "Face"
  LD A,(FaceState)
  OR A
  LD A,$21  ;For no face
  JR z,+
  LD A,$25  ;For face
+
  LD HL,_textCurPos
  ADD HL,DE
  LD (HL),A
  RET

Text_LowerWindow:
;Just like RaiseWindow, but in reverse!
  POP HL    ;Return
  LD A,C
  LD (DE),A
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
  LD (LCDCounter),A   ;Disable LY interrupt
  LD HL,$FFFF
  RES 1,(HL)
  LD A,(DE)
  LD B,A
  DEC DE
  LD A,(DE)
  LD C,A
  JP TextProcessControlReturn

Text_RaiseWindow:
;Summation to >= 40
;9, by 1: 45
;6, by 2: 42
;5, by 3: 45
;4, by 4: 40
;NEW: Slow it down
;LUT?
  POP HL    ;Return
  LD A,%01000000    ;Enable LY interrupt
  LD (LCDCounter),A
  XOR A
  LDH ($0F),A
  LD HL,$FFFF
  SET 1,(HL)
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

Text_MoveUp:            ;test
  LD HL,_textCurPos
  ADD HL,DE
  LD A,(HL)
  SUB 32
  CP 32     ;Bounds: border on top
  RET c
  LD (HL),A
  RET

Text_MoveDown:
  LD HL,_textCurPos
  ADD HL,DE
  LD A,(HL)
  ADD 32
  CP 160    ;Bounds: bottom of visible window
  RET nc
  LD (HL),A
  RET

Text_MoveLeft:
  LD HL,_textCurPos
  ADD HL,DE
  LD A,(HL)
  AND $1F
;Check for wrapping
  CP $06
  JR nc,++
;Wrap maybe
  CP $02
  JR c,+
;Do wrap if there is a face
  LD A,(FaceState)
  OR A
  JR z,++
+   ;Do wrap
  LD A,(HL)
;%sss10011  ,there is a -1 later to make it 18 mod 32
  AND %11100000
  SUB %00001100
  LD (HL),A
++  ;Do not wrap
  DEC (HL)
  RET

Text_MoveRight:
  LD HL,_textCurPos
  ADD HL,DE
  LD A,(HL)
  AND $1F
;Check for potential wrapping
  CP $13
  JR c,++
    ;Do wrap
  LD A,(HL)
  AND $E0   ;Very beginning due to later +1
  ADD $20
  LD (HL),A
;Adjust offset from left if there is a face
  LD A,(FaceState)
  AND $03
  JR z,+
;Face; apply offset
  LD A,4
  ADD (HL)
  LD (HL),A
+   ;No face
++  ;Do not wrap
  INC (HL)
  RET

Text_Backspace:
  LD HL,_textCurPos
  ADD HL,DE
  LD L,(HL)
  LD H,>TextData
  DEC L
  LD (HL),$30
  LD A,L
  POP HL    ;Return
  LD HL,_textCurPos
  ADD HL,DE
  LD (HL),A
  LoadVRAMptA 1, 1
  JP TextProcessLoop

Text_Tab:
  LD HL,_textCurPos
  ADD HL,DE
  PUSH BC
  LD C,(HL)
  LD L,C
  LD H,>TextData
  LD A,$03  ;Up to the tab stop
  AND L
  OR $FC
  CPL
  INC A ;Make it positive
  INC A ;Offset by 1
  LD B,A
-
  LD (HL),$30
  INC L
  DEC A
  JR nz,-
  LD A,L
  LD HL,_textCurPos ;Update cursor
  ADD HL,DE
  LD (HL),A
  LD HL,_vRAMBuf
  ADD HL,DE
  PUSH DE
  LD D,H
  LD E,L
  LD (HL),B
  INC HL
  LD (HL),1
  INC HL
  LD (HL),C
  INC HL
  LD (HL),>TextData
  INC HL
  LD (HL),C    ;Window low
  INC HL
  LD (HL),$9C   ;Window high
  LD BC,LoadRectToVRAM_Task
  CALL NewTask
  POP DE
  POP BC
  POP HL    ;This is a printing character, therefore we need the delay
  JP TextProcessLoop

Text_Newline:
  CALL Text_CarriageReturn
  JP Text_MoveDown

Text_Pause:
  POP HL    ;Return
;Status
  LD A,textStatus_waiting
  LD (TextStatus),A
;Place icon
  LD HL,BlinkerSpot
  LD (HL),$6E
  LD HL,_vRAMBuf
  ADD HL,DE
  PUSH DE
    LD D,H
    LD E,L
    LD A,1
    LDI (HL),A    ;Width
    LDI (HL),A    ;Height
    LD (HL),<BlinkerSpot  ;Source
    INC HL
    LD (HL),>BlinkerSpot
    INC HL
    LD (HL),<BlinkerSpot  ;Destination
    INC HL
    LD (HL),$9C   ;Window page
    PUSH BC
      LD BC,LoadRectToVRAM_Task
      CALL NewTask
    POP BC
  POP DE
--
  LD A,32
-
  CALL HaltTask
;Check for button, other than pause
  LD L,A
  LDH A,($FE)
  AND %11110111 ;All buttons save Start
  JR nz,+
  LD A,L
  DEC A
  JR nz,-
;Animate icon
  LD HL,BlinkerSpot
  LD A,1    ;Toggle b/w the two tiles
  XOR (HL)
  LD (HL),A
  PUSH DE       ;Buffer correct from setup
    PUSH BC
      LD HL,_vRAMBuf
      ADD HL,DE
      LD D,H
      LD E,L
      LD BC,LoadRectToVRAM_Task
      CALL NewTask
    POP BC
  POP DE
  JR --
+
;  JR TextProcessLoop
;Calling pause resets the cursor to the upper left. Which is what clear does.
  PUSH HL   ;Dummy return
Text_Clear:
;Return cursor to the upper-left corner
  CALL Text_ReturnToCorner
;And clear out the text input area
;Set HL to upper left corner of text area
  LD HL,_textCurPos
  ADD HL,DE
  LD L,(HL)
  LD H,>TextData
  DEC HL    ;Actually the column before
;Clear it
  PUSH BC
--
  LD A,$9F
  LD BC,32  ;Row movement
-
  LD (HL),$30
  ADD HL,BC
  CP L
  JR nc,-
  LD BC,1-4*32      ;First row, next column
  ADD HL,BC
  LD A,$34
  CP L
  JR nz,--
  LD BC,LoadToVRAM_Task
  LD A,1
  PUSH DE
  LD DE,(>TextData)<<8 | $9C
  CALL NewTask
  POP DE
  POP BC
  POP HL
  JP TextProcessLoop

Text_CarriageReturn:
  LD HL,_textCurPos
  ADD HL,DE
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
  LD HL,_textDelay
  ADD HL,DE
  LD (HL),A
  RET

Text_ShowFace:
  POP HL    ;Return
-
  LD A,(BC)
  INC BC
  PUSH BC
    LD BC,FaceShow_Task
    CALL NewTask
  POP BC
  LD A,1
  JP nc,_textWaitLoop
  DEC BC        ;If not enough tasks, try again next frame
  CALL HaltTask
  JR -

Text_LoadFace:
  POP HL        ;Return
-
  PUSH DE
    LD A,(BC)
    INC BC
    LD D,A
    LD A,(BC)
    INC BC
    PUSH BC
      LD BC,FaceLoad_Task
      CALL NewTask
    POP BC
  POP DE
  JP nc,TextProcessControlReturn
  DEC BC    ;If task unavailable, try again next time
  DEC BC
  CALL HaltTask
  JR -

Text_LoadBorder:
  LD A,(BC)
  INC BC
  RLCA  ;Transform into border tile index
  RLCA
  ADD $20
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
  
Text_Error:
  RST $38

.ENDS
