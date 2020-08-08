
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

.define TileDataBuffer $D000
.define TileMapBuffer $D005

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

  BIT 0,D       ;Test for OAM updates
  JR z,OAMUpdateSkip
  LD A,$CF
  CALL $FF80    ;OAM routine
  RES 0,D
OAMUpdateSkip:
;ABCE=?? D=xxxxxxx0 HL=OpControl

  BIT 1,D       ;Test for selective OAM updates
  JR z,SelectiveOAMUpdateSkip
  LD L,$AC
  LDI A,(HL)    ;There's only one index count.
  LD E,A
-
  LD B,$CF  ;Shadow OAM
  LDI A,(HL)
  LD C,A    ;C indexes into OAMs
  LD A,(BC)
  LD B,$FE  ;Actual OAM
  LD (BC),A
  DEC E
  JR nz,-
  RES 1,D
SelectiveOAMUpdateSkip:
;All registers except D are now unknown.

  BIT 7,D       ;Test for Tile Data updates
  JR z,TileDataUpdateSkip
  LD HL,$D000
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
  LD HL,$D005
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
  EI
  INC (HL)      ;Update frame counter

  LD L,$A0
  LD (HL),D     ;Update important flag register
;ABC=?? D=$00, HL=OpControl

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
  LD BC,musicglobalbase+1
  LD A,(BC)
  RRCA
  LDH ($26),A
  JR nc,SoundSkip
  RRA   ;Bit 1
  JR nc,MusicSkip
  RRA   ;Sound effects
  RRA   ;New song
  JR nc,+
  PUSH AF
  INC C     ;Get song pointer
  LD A,(BC)
  LD L,A
  INC C
  LD A,(BC)
  LD H,A
  LD D,H
  LD E,L
  DEC DE
  DEC DE
  LD C,<channelfourbase+$28
  LD A,$08
-   ;Copy over channel pointers
  PUSH AF   ;And make every channel assume default values
  ADD E
  LD L,A
  LD A,$00
  ADC D
  LD H,A
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  ADD HL,DE
  INC HL
  INC HL
  LD A,L
  LD (BC),A
  INC C
  LD A,H
  LD (BC),A
  INC C
  INC C
  INC C ;Octave (default 4) (but it's stored as 2)
  LD A,$02
  LD (BC),A
  INC C ;Remaining note length
  XOR A
  LD (BC),A
  INC C ;Tempo (default 120)
  INC A
  INC A
  LD (BC),A
  INC C
  INC A
  LD (BC),A
  INC C
  LD (BC),A
  LD A,C
  SUB channelsize + 8
  LD C,A
  POP AF
  DEC A
  DEC A
  JR nz,-
  LD HL,musicglobalbase+1
  RES 3,(HL)
  POP AF
+   ;New song finished
  RRA
  JR nc,+
  LD C,<channelfourbase+$28
  CALL MusicReadCommand
+   ;Channel 4 finished
  RRCA  ;Channel 3 is handled specially
  JR nc,+
  LDH ($1A),A
  LD C,<channelthreebase+$28
  CALL MusicReadCommand
+   ;Channel 3 finished
  RRA
  JR nc,+
  LD C,<channeltwobase+$28
  CALL MusicReadCommand
+   ;Channel 2 finished
  RRA
  JR nc,+
  LD C,<channelonebase+$28
  CALL MusicReadCommand
+   ;Channel 1 finished
MusicSkip:
;Sound effects go here
;Sound channel will have to disable Channel 3 if neither are using it
;When sound effects finish, they'll have to load values from himem to the ch.
SoundSkip:
  POP HL
  POP DE
  POP BC
  POP AF
  RETI

.ENDS
