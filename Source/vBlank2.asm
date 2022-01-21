.include "memmap.asm"

.define OAMBuffer $CF00
.define OpControl $CFA0
.define LCDControl $CFA1
.define LCDCounter $CFA2
.define BkgVertScroll $CFA3
.define BkgHortScroll $CFA4
.define LY $CFA5
.define BkgPal $CFA6
.define SpritePal0 $CFA7
.define SpritePal1 $CFA8
.define WinVertScroll $CFA9
.define WinHortScroll $CFAA
.define FrameCount $CFAB
.define SelOAMupdates $CFAC
.DEFINE PlayerButtonBuf $C0E6

.define TileDataBuffer $C0EE
.define TileMapBuffer $C0F3

.export OAMBuffer
.export OpControl
.export LCDControl
.export LCDCounter
.export BkgVertScroll
.export BkgHortScroll
.export LY
.export BkgPal
.export SpritePal0
.export SpritePal1
.export WinVertScroll
.export WinHortScroll
.export FrameCount
.export SelOAMupdates

.export TileDataBuffer
.export TileMapBuffer

;vBlank
.ORG $40
  PUSH AF
  PUSH BC
  PUSH DE
  PUSH HL
  JP vBlank

.ORG $0150
.SECTION "vBlank" FORCE

;New vBlank routine
vBlank:
  LD HL,OpControl
  LD D,(HL) ;D contains the vBlank flags. Push D to the stack if it is needed.
;OAM Always enabled
  LD A,$CF
  CALL $FF80    ;OAM routine
;ABCE=?? HL=OpControl
;Removing selective since now it's redundant
;All registers except D are now unknown.

  BIT 7,D       ;Test for Tile Data updates
  JR z,TileDataUpdateSkip
  LD HL,TileDataBuffer
  LDI A,(HL)
  LD E,A
  LDI A,(HL)
  LD C,A
  LDI A,(HL)
  LD B,A
  LDI A,(HL)
  LD H,(HL)
  LD L,A
-
  LD A,(BC)
  INC BC
  LDI (HL),A
  LD A,(BC)
  INC BC
  LDI (HL),A
  LD A,(BC)
  INC BC
  LDI (HL),A
  LD A,(BC)
  INC BC
  LDI (HL),A
  LD A,(BC)
  INC BC
  LDI (HL),A
  LD A,(BC)
  INC BC
  LDI (HL),A
  LD A,(BC)
  INC BC
  LDI (HL),A
  LD A,(BC)
  INC BC
  LDI (HL),A
  DEC E
  JR nz,-
  RES 7,D
TileDataUpdateSkip:
  BIT 6,D       ;Test for updating tiles in a rectangle
  JR z,SquareTileSkip
  PUSH DE
  LD HL,TileMapBuffer
  LDI A,(HL)
  LD E,A
  LDI A,(HL)
  LD D,A
  LDI A,(HL)
  LD C,A
  LDI A,(HL)
  LD B,A
  LDI A,(HL)
  LD H,(HL)
  LD L,A
--
  PUSH DE
-
  LD A,(BC)
  INC BC
  LDI (HL),A
  DEC E
  JR nz,-
  POP DE
  LD A,$20  ;Square to a 32x32 screen
  SUB E
  ADD L
  LD L,A
  LD A,$00
  ADC H
  LD H,A
  DEC D
  JR nz,--
  POP DE
  RES 6,D
SquareTileSkip:

;Update LCD control registers and the like (10 total). Unrolled to save time and skip $FF46 (OAM DMA) & $FF44 (LY).
  LD HL,LCDControl
  LDI A,(HL)    ;LCD Control register
  LDH ($40),A

  LDI A,(HL)    ;LCD Counter status
  LDH ($41),A

  LDI A,(HL)    ;Background Vertical Scroll
  LDH ($42),A

  LDI A,(HL)    ;Background Horizontal Scroll
  LDH ($43),A
;Skip $FF44 (LY)

  LDI A,(HL)    ;LY Compare register
  LDH ($45),A
;Skip $FF46 (OAM DMA)

  LDI A,(HL)    ;Background palette
  LDH ($47),A

  LDI A,(HL)    ;Sprite Palette #0
  LDH ($48),A

  LDI A,(HL)    ;Sprite Palette #1
  LDH ($49),A

  LDI A,(HL)    ;Window Vertical Scroll
  LDH ($4A),A

  LDI A,(HL)    ;Window Horizontal Scroll
  LDH ($4B),A

;vBlank imperative operations finished. Non-imperative operations follow.
;Writing to STAT causes LCD interrupt to fire immediately
  XOR A
  LDH ($0F),A
  EI
  INC (HL)      ;Update frame counter

  LD L,$A0
  LD (HL),D     ;Update important flag register
;ABC=?? D=$00, HL=OpControl

  LDH A,($FE)   ;Update the read buffer
  LD (PlayerButtonBuf),A
  LD C,D
  LD A,$10      ;Read controller directions (Bit 6 is zero)
  LD ($FF00+C),A
  LD A,($FF00+C)
  LD A,($FF00+C)
  LD A,($FF00+C)
  CPL           ;Pressed buttons are returned as 0s. We want 1s
  AND $0F
  LD B,A
  LD A,$20      ;Read buttons (Bit 5 is zero)
  LD ($FF00+C),A
  LD A,($FF00+C)
  LD A,($FF00+C)
  LD A,($FF00+C)
  CPL
  AND $0F       ;Combine into A
  SWAP A
  OR B
  LDH ($FE),A   ;Move to 0xFFFE

;Sound section:
  CALL PlayTick
  POP HL
  POP DE
  POP BC
  POP AF
  RETI

LoadRectToVRAM_Task:
;DE -> Transfer data
;Copy to local mem (so parent can free)
  PUSH DE
  CALL MemAlloc
  POP HL
  LD B,6
-
  LDI A,(HL)
  LD (DE),A
  INC DE
  DEC B
  JR nz,-
  DEC DE
-
  CALL HaltTask
  LD A,(OpControl)
  OR A
  JR nz,-
  LD HL,TileMapBuffer+5
  LD B,6
-
  LD A,(DE)
  DEC DE
  LDD (HL),A
  DEC B
  JR nz,-
  INC DE
  LD HL,OpControl
  SET 6,(HL)
  CALL MemFree
  JP EndTask

LoadToVRAM_Task:
;A = No. of pages
;D = High byte of source
;E = High byte of destination
  LD B,A
  XOR A
-
  LD HL,OpControl
  LD H,(HL)     ;Test for zero, preserve A
  INC H
  DEC H
  JR z,+
  CALL HaltTask     ;Try again next time
  JR -
+
  LD HL,TileDataBuffer
  LD (HL),$10
  INC L
  LDI (HL),A
  LD (HL),D
  INC L
  LDI (HL),A
  LD (HL),E
  LD HL,OpControl
  SET 7,(HL)
  ADD $80
  JR nz,-
  ;Finished a page
  DEC B
  JP z,EndTask
  INC D
  INC E
  JR -

.ENDS
