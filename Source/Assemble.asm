;RAM Memory Map:
;RAM exists in a contingous block from $C000-$DFFF, with SRAM (if any) from $A000-$BFFF.
;Additional HRAM exists from $FF80-$FFFE. It is the only area that can be accessed in OAM DMA
;In this project, no SRAM exists.
;The following memory locations are used for the listed purposes.

;SRAM:
;$A000-$BFFF
    ;Not available

;WRAM:
;$C000 - $C008
    ;Unused
;$C010 - $C020?
    ;CORDIC, if I can ever grasp its true form
;$C020?- $C02F
    ;Volatile memory
;$C030 - $C031
    ;LCD IRQ software support
      ;Use:
        ;Place an address here, stack order, to a function to fire on LCD IRQ
        ;Function must begin with:
            ;LD SP,HL
        ;And end with:
            ;POP HL
            ;POP AF
            ;RETI
;$C032 - $C037
    ;Init extraction state space
;$C038
    ;Text Face state
;$C039 - $C07F
    ;Free?
;$C080 - $C08F
    ;Button data area
;$C090 - $C09E
    ;Map State
;$C09E - $C09F
    ;Hat data pointer
;$C0A0 - $C0BF
    ;Cutscene actor task pointers
;$C0C0 - $C0E7
    ;Unused. But still reserved.
;$C0E8 - $C0E9
    ;Object manager state
;$C0EA:
    ;Text status (Text.asm)
;$C0EC - $C0ED:
    ;End of Hitboxes pointer
;$C0EE - $C0FA:
    ;VRAM update buffer
        ;Contains, in order, an 8 bit counter, a 16 bit source, and a 16 bit destination
        ;If something else is in the way, you can wait a frame.
;$C0FB - $C0FC
    ;Memory ring starting point
;$C0FD,$C0FE,$C0FF
    ;Storage place for tea while working.
;$C100 - $C19F: Text Data
;$C1A0 - $C3FF: Free
;$C400 - $CCFF: Initial decompression zone
;$C400 - $C8FF    |||    Overlaps    |||
    ;Hitbox data  |||                |||
;$C900 - $CCFF    |||                |||
    ;Facedata
;$CD00 - $CDFF
    ;Task data area
;$CE00 - $CEFF
    ;Sound driver
;$CF00 - $CF9F
    ;OAM buffer
;$CFA0:
    ;vBlank flags: When the listed flag is 1, that operation is performed on the following vBlank interrupt. Cycles are listed in Clock Cycles (NOP = 4 cycles).
    ;vBlank takes 4560 clocks. Always takes 392 cycles. Bit assignments follow:
        ;Bit 7: Tiledata update
            ;Takes a count from TileDataBuffer, a source address, and a destination address.
            ;Copies blocks of 8 bytes from source to destination, for count.
            ;Timings:
                ;68 cycles when used
                ;26 cycles per byte
            ;Maximum:
                ;No OAM:   152 bytes
                ;With OAM: 128 bytes
        ;Bit 6: Rectangle update
            ;Updates a rectangular region of bytes
            ;Takes width, height, source, destination starting from TileMapBuffer
            ;Timings:
                ;136 cycles when used
                ;40 cycles per byte
                ;44 cycles extra per row
            ;Maximum:
                ;No OAM:   48 - 100 bytes
                ;With OAM: 39 - 83 bytes
        ;Bit 5: Unused
        ;Bit 4: Unused
        ;Bit 3: Unused
        ;Bit 2: Unused
        ;Bit 1: Unused
        ;Bit 0: Unused
;$CFA1 - $CFAA:
    ;The following "Shadow" registers are used by vBlank every frame. You may alter their contents at any time, and the changes will take effect at the beginning of the next frame.
        ;$CFA1:
            ;Shadow LCD Control register
        ;$CFA2:
            ;Shadow LCD Counter Status
        ;$CFA3:
            ;Shadow Background Vertical Scroll
        ;$CFA4:
            ;Shadow Background Horizontal Scroll
        ;$CFA5:
            ;Shadow LY Compare counter
        ;$CFA6:
            ;Shadow Background Palette
        ;$CFA7:
            ;Shadow Sprite Palette #0
        ;$CFA8:
            ;Shadow Sprite Palette #1
        ;$CFA9:
            ;Shadow Window Vertical Scroll
        ;$CFAA:
            ;Shadow Window Horizontal Scroll (Actually 7 pixels <- left)
;$CFAB:
    ;Frame Counter
        ;Incremented each frame when vBlank interrupts are enabled.
;$CFAC - $CFFF:
    ;Active object index
;$D000 - $D5FF
    ;Map & Exit Data
        ;See "Maps.asm"
;$D600 - $DFFF
    ;Dynamically Allocated Memory

;HRAM:
;$FF80 - $FF87
    ;HRAM Routine for OAM updating
;$FF88 - $FF89
    ;Huffman state
;$FF90 - $FFA3
    ;Sound effect state
;$FFA4 - $FFFD
    ;Stack space. Squishy lower limit.
;$FFFE:
    ;Controller readout. Bit is 1 if button pressed
        ;DULRSEBA
        ;|||||||+--- A button
        ;||||||+---- B button
        ;|||||+----- Select button
        ;||||+------ Start button
        ;|||+------- Right direction
        ;||+-------- Left direction
        ;|+--------- Up direction
        ;+---------- Down direction


;There are 8 RST vectors, called like CALL instructions, but in a single byte and in 2/3 the time. Each RST vector has 8 bytes to do what it needs to do; using a call would eliminate nearly any benefit RST could provide. Some vectors could remain unused so the others could get more memory. RST $38 compiles to $FF, useful for a panic function. Then, the 8 byte limit does not matter. But, the other 7 vectors could be used for quick calculations (multiplication and the like). They are used as follows.
;RST $00
    ;Unsigned multiplication.
        ;Multiplies BC and A together, and adds the result to HL. Returns 0 in A, answer in HL, BC unchanged. HL wraps around at $FFFF, carry NOT recorded!!
;RST $08
    ;Block memory move.
        ;Moves data pointed to in HL to space pointed to in DE. C indicates the amount of bytes. 0 is treated as 256. A register is used.
;RST $10
    ;Block memory move+.
        ;Performs as above, except BC indicates no. of bytes. 0 in C is treated as 256.
;RST $18
    ;Unused
;RST $20
    ;Unsigned division.
        ;Divides the value in A by the value in B. Quotient is then added to C (no carry). Any remainder is in A. B is unchanged. Dividing by 0 results in infinte loop.
;RST $28
    ;Unused
;RST $30
    ;Equivalent to CALL (HL). 16 cycles
;RST $38
    ;Execution panic handler
;

;Backbone data
.include "memmap.asm"
.include "macros.asm"

.BANK 1 SLOT 1
.ORG $0000
.SECTION "Voice data" ALIGN 256 SEMIFREE
Wave:
.include "Voicelist.asm"
.ENDS

.ORG $3FF8
.SECTION "HRAM Routine" FORCE
HRAMRoutine:    ;8 bytes, 656 cycles. As small as can be while not interfering with OAM DMA
  LDH ($46),A
  LD A,$28
_local:
  DEC A
  JR nz,_local
  RET   ;These extra 16 cycles are not documented above.
.ENDS

;End header
.BANK 0 SLOT 0

;RST Vectors
.ORG $00
;Unsigned Multiplication v3.1
;Properly handles 0s for once.
  AND A             ;4
  RET z             ;20,8
__MultLoop:
  ADD HL,BC         ;8
  DEC A             ;4
  JR nz,__MultLoop  ;12,8
Return:
  RET               ;16

.ORG $08
;Block memory move - up to 256 bytes
__move:
  LDI A,(HL)
  LD (DE),A
  INC DE
  DEC C
  JR nz,__move
  RET

.ORG $10
;Block memory move - up to 65,536 bytes
  RST $08
  OR B
  RET z
__fullMove:
  RST $08
  DEC B
  JR nz,__fullMove
  RET

.ORG $18
;Random byte into A; preserve others
  PUSH BC
  PUSH DE
  CALL LFSR     ;A contains value of B, incidentally
  POP DE
  POP BC
  RET

.ORG $20
;Start over with a whitened screen
;A = 0
;HL = LCDControl
  LD (HL),%10000000         ;Make sure screen is enabled - and nothing else
  LD L,<BkgPal
  LD (HL),A                 ;White out the screen
  LDH ($0F),A               ;Interrupts may be waiting
  INC A
  LDH ($FF),A               ;vBlank only
  EI
  HALT                      ;Allow vBlank to do its thing
  JP $0100

.ORG $30
  JP HL

.ORG $38
;Panic vector. Everything is on fire!.
  DI        ;Stack is likely unsafe
  XOR A
  LD HL,OpControl
  LD SP,HL                  ;RAM that can be safely overwritten (OAM buffer)
  LDI (HL),A                ;Prevent vBlank from using a corrupted transfer action
  RST $20

;vBlank
.ORG $40
  PUSH AF
  PUSH BC
  PUSH DE
  PUSH HL
  JP vBlank

;LCD IRQ
.ORG $48
;Blank sprites
  PUSH AF
  PUSH HL
  LD HL,$FF40
  JP BlankSpriteIRQ

.SECTION "Sprite Blank" FREE
BlankSpriteIRQ:
  RES 1,(HL)
  ADD SP,4  ;Tempoarily clear stack
  POP HL    ;Return
  DEC HL
  LD A,$76  ;Opcode for HALT
  CP (HL)
  JR z,+
  INC HL    ;Do not halt again
+
  PUSH HL   ;New return
  ADD SP,-4 ;Realign stack
  POP HL    ;Actually HL
  POP AF    ;Actually AF
  RETI
.ENDS

;Timer
.ORG $50
  RETI

;Serial cable
.ORG $58
  RETI

;Joypad
.ORG $60
  RETI

;Introduction Point, ROM file requirements.
.ORG $0100
;Execution starts here.
.SECTION "Header" SIZE $50 FORCE
  DI  ;disabling interrupts right away. We have a free byte, so why not?
  JP Start

;Nintendo Logo (48 bytes) (encrypted/ compressed)
;Must be present, or DMG does not boot.
 .db $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
 .db $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
 .db $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E
;Title (16 bytes on DMG, 11 bytes elsewhere)
 .db "MARISA",0,0,0,0,0
;     123456  7 8 9 A B
;Manufacturer code
 .db $00,$00,$00,$00
;Color Game Boy flag
 .db $00
;New Licensee Code
 .db $00,$00
;Super Game Boy flag
 .db $00
;Cartridge type
 .db $00
;ROM size
 .db $00
;RAM size
 .db $00
;Release destination
 .db $01            ;Not Japan
;Old Licensee code
 .db $CD            ;Made-up license
;Mask ROM version
 .db $00
;Last three bytes are checksums- handled by assembler
 .db 0,0,0
.ENDS

.ORG $0150
.SECTION "INIT" SEMIFREE
Start:
;Disable interrupts, initialize registers, set up stack (for saftey reasons)
  XOR A
  LD C,$42          ;Values these registers are initialized to are used later.
  LD DE,$CFA0
  LD H,A
  LD L,A
  LD SP,HL
  PUSH HL           ;Disables all interrupts, and sets up stack at end of HRAM, with 1 byte left for buttons

;A=$00,BC=$D142,DE=$CFA0,HL=$0000,SP=$FFFF,IME=0
;The stack points to the last USED byte on the Z80.
;Enable vBlank procedure, after clearing the necessary registers
;Wait for vBlank to count 30 frames, then increment palette.
;When the last two bits of the palette roll over, set it to $FF.
  LD H,D
  LD L,E
  LDI (HL),A
  LDH A,($40)
  LDI (HL),A        ;Copy over current LCD status
  LD (HL),0         ;No extraneous screen related interrupts.
  INC L
  LD A,($FF00+C)
  INC C
  LDI (HL),A        ;Copy the X and Y scrolls
  LD A,($FF00+C)
  LDI (HL),A
  INC L
  LDH A,($47)   ;background palette
  INC A
  LDI (HL),A
  LD A,%11010000
  LDI (HL),A        ;Initialize sprite palettes to our default values.
  LD A,%11100100
  LD (HL),A         ;OBP0: C1=white, C2=light grey, C3=black. OBP1: C1=light grey, C2=dark grey, C3=black.
  LD L,$A0
  XOR A
  LD (ObjUse),A ;No objects yet
  LD (HL),A ;No vBlank procedures get run yet
  LD L,$AB
  LD (HL),A ;Zero frame counter
  LDH ($0F),A   ;Clear interrupt flags
  INC A
  LDH ($FF),A   ;Enable vBlank

;Clear OAM buffer, load in HRAM OAM routine, enable OAM copy routine.
  LD HL,$FF80
  LD BC,HRAMRoutine
HRAMRoutineLoadLoop:
  LD A,(BC)         ;Move the HRAM routine, which is at the end of the cart
  LDI (HL),A
  INC C
  JR nz,HRAMRoutineLoadLoop
  CALL OAMInit
  EI    ;Interrupts now safe
  HALT
;Start multitasker
;Clear task data area
  XOR A
  LD B,A
  CPL
  LD HL,taskpointer
  PUSH HL   ;For faking ID to descendent tasks, and trapping misbehaviors
-
  LDI (HL),A
  DEC B
  JR nz,-
;Set up Object manager first
  XOR A
  LD (ObjUse),A
  LD BC,ObjManage_Task
  CALL NewTask
;Set up sound initializer as a serparate task
  LD BC,SoundInit
  CALL NewTask
;Initialize memory
  LD BC,MemInitTask
  CALL NewTask
;Set up graphics loader as a separate task
  LD BC,GraphicsInit
  CALL NewTask
;Set up Title Screen Loader as a separate task
  LD BC,LoadTitle
  CALL NewTask
;Set up Object Priority task
  LD BC,ObjectPriority_Task
  CALL NewTaskLo
;Go to the task handler
;Forever
  JP DoTaskLoop

SoundInit:
;Turn on music
;Initialize sound section
  LD HL,musicglobalbase
  XOR A
  LD B,A
-
  LDI (HL),A    ;Set all sound section to 0
  DEC B
  JR nz,-
  LD HL,channelonebase+$2A
  LD BC,Channel1Pitch
  LD (HL),C
  INC L
  LD (HL),B
  LD L,<channeltwobase+$2A
  LD BC,Channel2Pitch
  LD (HL),C
  INC L
  LD (HL),B
  LD L,<channelthreebase+$2A
  LD BC,Channel3Pitch
  LD (HL),C
  INC L
  LD (HL),B
  LD L,<channelfourbase+$2A
  LD BC,Channel4Pitch
  LD (HL),C
  INC L
  LD (HL),B

;Music init
  LD BC,SongNull
  CALL MusicLoad
  LD A,$FF
  LD (musicglobalbase+1),A
  LDH ($26),A
  LDH ($24),A
  LDH ($25),A
  JP EndTask

GraphicsInit:
;Idea: Compress and store the tiledata backwards, so we can copy it downwards from the top
;Planning:
    ;Can copy 128 bytes from RAM to video each frame
    ;Can decompess 256 bytes at a time.
    ;Backreferences reach 1 kilo back (1024 bytes)
    ;Do we have any $1800 byte space?
        ;Even without the heap, we don't
    ;Anything smaller requires redundant copying
        ;We have time.
    ;We have the map area, which isn't used yet.
        ;$D100 - $D5FF
        ;$C400 - $C9FF
    ;And the text/facedata area
        ;$CA00 - $CCFF
    ;Spare page for saving the first 32 tiles
        ;$C200 - $C2FF WE NEED TWO
        ;$C100
    ;We can't copy over the beginning -256- 512 bytes until the screen is black
;First 32 tiles
  LD HL,Tiledata
  LD DE,$C032
  PUSH DE
  LD DE,$C400
  CALL ExtractSpec
  CALL ExtractRestoreSP
;Copy the first 512 to somewhere safe
  LD HL,$C400
  LD DE,$C100
  LD BC,$0200
  RST $10
;Extract another 7 times
  LD DE,$C682
  POP BC
-
  PUSH DE
  LD BC,$C032
  PUSH BC
  CALL ExtractRestoreSP
;Copy from $C600 to vRAM
  POP BC
  POP DE
  ;DE Correct
  LD BC,LoadToVRAM_Task
  LD A,2
  CALL NewTask
  LD A,B
  LD B,D
  LD C,E
  CALL WaitOnTask
  LD D,B
  LD E,C
  INC E
  INC D
  LD A,$CD
  CP D
  JR nz,-
;Reached end of buffer;
;Do the end of data check here (should meet here 4 times), move buffer
  LD A,$98
  CP E
  JR z,+
  LD D,$C8
  PUSH DE
;Copy the last kilo back to beginning
  LD HL,$C900
  LD DE,$C400
  LD BC,$0400
  RST $10
  POP DE
;Edit stored state information
  LD HL,$C037
  LD A,(HL)
  SUB 5
  LD (HL),A
  JR -
+
  LD B,$FF
-
  CALL HaltTask
  LD A,(BkgPal)
  XOR B
  JR nz,-
;Screen black
  LD BC,LoadToVRAM_Task
  LD DE,$C180   ;Copy first half a kilobyte
  LD A,2
  CALL NewTask
  LD HL,LCDControl
  LD (HL),%11000011 ;BKG ON @ $98, WIN OFF @ $9C, SPR ON & 8x8, BKG TILE @ $88
  JP EndTask

LoadTitle:
;Set up cutscene player
  LD HL,Cutscene_Actors
  LD C,$20
  XOR A
-
  LDI (HL),A
  DEC C
  JR nz,-
;Now pausable
  LD BC,PauseTask
  CALL NewTask
;Camera Setup
  LD BC,Camera_Task
  CALL NewTaskLo
;Play opening cutscene
  LD DE,Cs_LoadInit
  LD BC,Cutscene_Task
  CALL NewTask
;Wait for cutscene to finish, so Marisa is initialized
  LD A,B
  CALL WaitOnTask
;Exits
  LD BC,ExitCheck_Task
  CALL NewTask
;Sprites
;Collision
  LD BC,HitboxUpdate_Task
  CALL NewTask
  JP EndTask
.ENDS


;16 bit Linear-Feedback Shift Register, for random number generation
;Only one byte needs to be initialized to a nonzero value. The other can remain untouched.
;Sample implementation:
    ;Every time the random function is called,
    ;The LFSR increments one step, and produces its output.
    ;This output has the frame counter added to it,
    ;and the current state of the buttons, either from the port directly, or some buffered value supplied by vBlank. Directly sounds more random, but also more susceptible to manipulation, especially by TASers. Though, is it really that big of a deal? It may be better yet to implement a Mersenne Twister, if that's a concern. The values on startup in RAM are semi-random anyways, it's unlikely storing a value would ever be necessary.

;If we wanted to do a Linear congruential generator instead (x = a * seed + c % m), Wikipedia lists three rules that must be followed to ensure maximum period:
    ; m and the offset c are relatively prime
    ; a - 1 is divisible by all prime factors of m
    ; a - 1 is divisible by 4 if m is divisible by 4
;Since m (the modulo) is most likely a power of 2, the following could be easily derived for more than 1 bit generators:
    ; a must be odd
    ; c must be odd
    ; a - 1 is a multiple of 4. In base 2, bit 1 must be 0.
;Thus, for an LCG, a = ...xxxxxx01, c = ...xxxxxxx1 for an efficient implementation.
;Sadly, while this guarantees the longest period, it does NOT guarantee very good randomness. If a = c = 1, the above are obeyed, and period is at its longest, but it's not very random.
;An optimisation could be made if a was a power of two plus one, by copying the value, and adding it to a shifted version of itself.
;Unfortunately, the low order bits are even less random than the high order ones, especially with powers of 2.
;Mersenne twister is too computationally costly
.SECTION "LFSR" FREE
;Current state located in BC
;When done,
    ;A  = B
    ;BC = New state
    ;DE = ???
    ;HL = Unchanged
LFSR:
  LD E,$00
  LD A,C
  SLA A ;Most direct method given CY and A are unknown
  LD C,A
  RL E
  AND %00010000
  LD D,A
  LD A,B
  RR E
  RLA
  LD B,A
  RR E
  AND %10100000
  ADD D
  LD D,A    ;D contains the taps
  LD A,E    ;E contains the carry
-
  XOR D     ;XOR each of the taps
  SLA D
  JR nz,-   ;Break when no more taps
  RLA       ;Put the input bit into the carry and feed it in
  LD A,C
  ADC D     ;D is already 0
  LD C,A
  LD A,B
  ADC D     ;Carry through 16 bits
  LD B,A
;BC contains the current state of the LFSR.
  LDH A,($04)   ;Timer divider register as additional entropy
  XOR C
  LD C,A
  LDH A,($04)
  CPL
  XOR B
  LD B,A
  RET
.ENDS

;How about Xoroshiro128+?
;Really big. We can't even hold 64 bits!
;What about a 32 bit version? Xoroshiro32-
;Too long. Space is a premium
;XOR shift is also long and unweildy.
;What about LCGs? They're tiny
    ;How does that multiplication of big numbers go again?
;Chaining multiple LFSRs
    ;Need coprime periods: I.E. 16 of them.
;No new RNG for us today.

;If compression is needed, try huffman for text/ code, or Lempel-Ziv-Welch for tiles/ text

.SECTION "DIVIDER" FREE
;Software divider; 16 bit numerator, 8 bit denominator
;Numerator: BC
;Denominator: E
;Output:
    ;A= Remainder
    ;BC=0
    ;D unchanged
    ;E=0
    ;HL= Quotient
;If E==0,
    ;A =0
    ;BC unchanged
    ;DE unchanged
    ;HL=0
;Statistics: (w/o call opcode)
    ;Every case: 1368 cycles
    ;DIV0 case: 40 cycles
    ;26 bytes size
Divide:
  XOR A
  LD L,A   ;HL does double duty as a counter
  LD H,A
  OR E  ;Panic if the Denominator is zero
  RET z
  JR +++    ;Valid because A==E, then this sets the end flag in HL
-
  SLA C ;Set the low bit of the Remainder to the high bit of the Numerator
  RL B
  RLA
  JR nc,++   ;Guaranteed greater than -> don't jump
  SUB E
  CP A  ;Clear the carry flag
  JR +
++
  CP E  ;If R >= D, don't jump
  JR c,+
+++
  SUB E ;R = R-D
+       ;Shift 1 into the Quotient
  CCF   ;if the branch was NOT taken
  RL L
  RL H
  JR nc,-
  RET
.ENDS

.SECTION "MULTIPLIER" FREE
;Software 8-bit multiplier

;NEW (17 July 2018) I've found a smaller, faster method, that fits in 2 RST vectors.
;With some register twiddling, it might improve.
;By calculating the answer in a register pair including A, we get some savings/
;It uses the non-accumulating part of the answer register pair as the tracker,
;thereby making the completeness check free, space and timewise.
;It is also time-constant, which is beneficial for tight sections,
;and is also rather pretty.
;BC = B*C
;A, D destroyed
Multiply:
  XOR A     ;Beautiful multiply (15 bytes, 368 cycles always)
  LD D,C
  LD C,$7F
-
  SRA D
  JR nc,+
  ADD B
+
  RRA
  RR C
  JR c,-
  LD B,A
  RET

;Square 8.8 value
;BC = 8.8 value
;Destroys A, DE
;Returns squared value in BC. Carry set if it carried (carried value in A)
Square:    ;Squaring BC (semi)correctly
    ;X * Y
    ;X = B*100 + C
    ;Y = D*100 + E
    ;(B*100 + C) * (D*100 + E)
    ;B*D*10000 + C*D*100 + B*E*100 + C*E
    ;^ Ignore b/c out of range
    ;But squaring...
    ;B*B*10000 + C*B*100 + B*C*100 + C*C
    ;B*B*10000 + 2*C*B*100 + C*C
    ;Fixed 8.8 conversion:
    ;B*B*100 + 2*C*B
    LD E,B
    CALL Multiply ;Right term
    LD A,C    ;Save lower byte only
    LD B,E
    LD C,E
    LD E,A
    CALL Multiply ;Left term
    SLA E   ;Multiply by 2
    LD A,C
    ADC 0   ;Propagate carry
    ;A->C, C->B, B->A
    LD E,B
    LD B,C
    LD C,A
    LD A,E
    ADC 0   ;Final propogation
    RET z   ;Carry set right, b/c it would only be set and zero if A overflowed
    SCF
    RET
.ENDS


