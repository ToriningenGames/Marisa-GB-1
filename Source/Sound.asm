;Sound player 4.0
;Back to basics

.define channelonebase   $CE04
.define channeltwobase   $CE44
.define channelthreebase $CE84
.define channelfourbase  $CEC4
.define musicsize $35
.define channelsize $40
.define musicglobalbase $CE00
.export channelonebase
.export channeltwobase
.export channelthreebase
.export channelfourbase
.export musicglobalbase
.export channelsize
.export musicsize


;See MMLspec.txt for binary format of music data
;Memory map:
    ;Global:
    ;+$00: 1 byte : Sound effect control
        ;%12341234
        ; ||||++++--- Sound effect requested
        ; ++++------- Sound effect playing
    ;+$01: 1 byte : Control register
        ;%1234NEQS
        ; |||||||+--- All sound on
        ; ||||||+---- Music on
        ; |||||+----- Sound effects on
        ; ||||+------ New song
        ; ++++------- Channel N on
    ;+$02: 2 bytes: song pointer
    ;Contains per channel:
    ;+$00: 3 bytes: 8 loops + counter
    ;+$18: 1 byte : 16 lengths
    ;+$28: 2 bytes: Play pointer
    ;+$2A: 2 bytes: note table pointer
    ;+$2C: 1 byte : Octave offset
    ;+$2D: 1 byte : remaining note length
    ;+$2E: 1 byte : tempo quotient value
    ;+$2F: 1 byte : tempo remainder value
    ;+$30: 1 byte : tempo remainder counter
    ;+$31: 1 byte : Stacatto value
;

;Can we make this 4 bits?
;A = B*C
;Multiply:
;  LD A,$07
;  SWAP B
;-
;  SRA C
;  JR nc,+
;  ADD B
;+
;  RRA
;  JR c,-
;  RET

;Problem:
    ;How are we gonna ensure clean translaton between beats and frames?
        ;Single tempo solution:
            ;One calculation from frames to beats that all channels use
        ;4:3 ratio:
            ;|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----
            ;|-------|-------|-------|-------|-------|-------|-------|-------|-
            ;| - - - - - - - - - - | - - - - - - - - - - | - - - - - - - - - - 
            ;
            ;
            ;240 frames / mes @ 120 bpm
    ;Solution: Every tempo needs to hand-jam a value between 0 and 2 ticks a frame
        ;This limits maximum tempo to 240
            ;Allowing hand jams of 3 alleviates this; see if convenient!
        ;For each channel, simply divide the tempo by 120: that's how many "ticks" per frame there are
        ;The 8 bit remainder can be stored and used as a sub-frame counter
        ;Channels have to take caution to always account for both ticks if 2 happen in a frame
            ;Switching from one note to the next
            ;Skipping over a note of length 1
;
;THIS IS WRONG! A tempo of 120 actually produces a song at 60 BPM!
;256 frames / mes => 01.00
;128 frames / mes => 02.00
;256/60 = 4.3 sec/mes / 60 = 0.07 min/mes / 4 = 0.02 min/bt = 56.25 bpm
;Thus:
;BPM ^-1 * 14400 = F/M
;F/M / 256 ^-1 = ticks / frame
;1/(1/BPM * 14400 / 256)
;1/( 14400 / (256 * BPM))
;256 * BPM / 14400
; BPM * 0.017777
;
;Equivalent to
;BPM * 4.55111111... / 256
;0.017777 == %0.0000 0000 0001 0100 1011 0110 0110 1101 110...?
;256 / 14400 == %00000100 / 11100001
;Dividing a 16 bit number by an 8 bit constant for a 16 bit result
;We could call divide twice
;Or we could divide first, then shift

;Remaining:
    ;Verify Stacatto (CH3)
    ;Overhaul length system
        ;Various issues affect
        ;Ties (Tempo 0)
        ;Rests
        ;Notes of length
        ;Inter-channel timing
    ;Notes:
        ;We should be storing tempo as stated in the memory map above, as an
            ;int-fraction pair, not a decimal as we are doing.
        ;This will produce exact timings
        ;Ties' current flag is a fine location, but needs to be better tracked
        ;All calls start with a tick count and end with a note playing
            ;The tick count might see that a note is still playing
            ;The tick cound might end a note, and a new one is to play
    ;Backup idea:
        ;Unify all tempos into one field, and tie music to the timer, not vBlank
       
;Quick tricks:
;Converting from Memory to IO pointer:
    ;Point to Remaining Note Length
    ;SWAP
    ;Dupe bits 3 and 2 into 1 and 0
;Converting from IO to Memory:
    ;Point to Channel IO head
    ;Set bits 1 and 0 to 1
    ;SWAP
    ;Pointing at Remaining Note Length
;
.SECTION "Sound" FREE
MemorytoIO:
;Converts the register C from pointing to Remaining Note Length
;to an IO pointer for the same channel
  SWAP C
  LD A,C
  RRA
  RRA
  OR $FC
  AND C
  LD C,A
;Point to alternate location if sound effect is playing for this channel
  LD A,(musicglobalbase)
  BIT 1,C
  JR z,+
  RLA
  RLA
+
  BIT 0,C
  JR z,+
  RLA
+
  SLA C ;Set high bit if sound effects are playing
  RLA
  RR C
  RET
IOtoMemory:
;Undoes the effect of MemorytoIO
  RES 7,C
  LD A,C
  OR $03
  SWAP A
  LD C,A
  RET
MusicLoad:
;BC->music file
  LD HL,musicglobalbase+$03
  LD (HL),B
  DEC L
  LD (HL),C
  DEC L
  SET 3,(HL)    ;Indicate new song
  RET
MusicReadCommand:
  PUSH AF
;BC -> Channel play pointer
  LD A,(BC)
  LD L,A
  INC C
  LD A,(BC)
  LD H,A
;HL -> next command
;Do ticks for this frame
  LD A,6
  ADD C
  LD C,A
;BC -> tempo remainder value
;Calculate next decrement
    ;Add tempo remainder to the remainder counter
  LD A,(BC)
  INC C
  LD D,A
  LD A,(BC)
  ADD D
    ;If the result is >= %11100001, subtract that constant
  JR c,++   ;Overflow
  CP %11100001
  JR c,+
++
  SUB %11100001
  OR A  ;Clear carry
+
    ;Store it
  LD (BC),A
    ;Get the quotient value
  DEC C
  DEC C
  LD A,(BC)
    ;If the result earlier was bigger, add 1
  CCF   ;Carry is reverse from what we want it for the subtract
    ;Subtract this from the remaining note length
  DEC C
  LD D,A
  LD A,(BC)
  SBC D
    ;Store it
  LD (BC),A
    ;If the result is <= 0, we read directives
  JR z,CommandReadLoop
  JP nc,NewDirectiveSkip    ;If note didn't end, don't play another
CommandReadLoop:
-
;Get next command
  LDI A,(HL)
  LD D,A
;Decode the type of command
  LD A,$E0
  AND D
  JP nz,+
;2 Byte type (Loop, Tone, Tempo, Stacatto, Envelope, Sweep, Length)
;Get next byte here
  LDI A,(HL)
  LD E,A
  BIT 4,D
  JR z,++
    ;Length
;BC -> remaining note length
  PUSH BC
  LD A,D
  AND $0F
  ADD ($2D - $27 - 1)
  CPL
  ADD C
  LD C,A
  LD A,E
  LD (BC),A
  POP BC
  JR -
++
  BIT 3,D
  JR z,++
    ;Loop
;BC -> remaining note length
  LD A,$C0  ;Go to base of channel
  AND C
  ADD <channelonebase
  LD C,A
  LD A,$07  ;Multiply index by 3
  AND D
  LD D,A
  ADD A
  ADD D
  ADD C
  LD C,A
;BC -> this loop
  INC C
  INC C
  BIT 7,E
  JR z,_loopset
  LD A,(BC)
  OR A
  JR z,_loopsetgo
  DEC A
  LD (BC),A
  JR nz,_loopgo
;No loop this time; read next directive
  LD A,$C0
  AND C
  ADD <channelonebase + $2D
  LD C,A
  JR -
_loopsetgo:
;If it was zero, we want to load the count before looping
  RES 7,E   ;We want the number, not the bit set
  LD A,E
  LD (BC),A
_loopgo:
  DEC C
  LD A,(BC)
  LD H,A
  DEC C
  LD A,(BC)
  LD L,A
;Looping finished; read next directive
  LD A,$C0
  AND C
  ADD <channelonebase + $2D
  LD C,A
  JR -
_loopset:
  XOR A
  LD (BC),A
  DEC C
  PUSH HL
  LD D,A
  ADD HL,DE     ;Include offset
  DEC HL    ;Base is the loop itself
  DEC HL
  LD A,H
  LD (BC),A
  DEC C
  LD A,L
  LD (BC),A
  POP HL    ;We need the current song pointer
;Looping finished; read next directive
  LD A,$C0
  AND C
  ADD <channelonebase + $2D
  LD C,A
  JR -
++
;Channel 3 check goes here
  LD A,<channelthreebase+$2D
  CP C
  JP z,ChannelThreeSpecial
  BIT 2,D
  JR z,++
    ;Tone
;BC -> remaining note length
  INC C     ;Get Stacatto
  INC C
  INC C
  INC C
  LD A,(BC)
  DEC C
  DEC C
  DEC C
  DEC C
  LD E,A
  CALL MemorytoIO
  INC C
  LD A,D
  RRCA
  RRCA
  AND $C0
  OR E
  LDH (C),A
  DEC C
  CALL IOtoMemory
  JP -
++
  DEC D
  JR nz,++
    ;Envelope
;BC -> remaining note length
;Convert C from memory pointer to IO pointer
  CALL MemorytoIO
;Set Envelope
  INC C
  INC C
  LD A,E
  LDH (C),A
;Convert C from IO pointer to memory pointer
  DEC C
  DEC C
  CALL IOtoMemory
  JP -
++
  DEC D
  JR nz,++
    ;Stacatto
;BC -> remaining note length
  LD A,$3F  ;Don't affect wave
  AND E
  LD E,A
  CALL MemorytoIO
  INC C
  LDH A,(C)
  AND $C0
  OR E
_stacattoentry:
  LDH (C),A
  DEC C
  CALL IOtoMemory
  INC C
  INC C
  INC C
  INC C
  LD A,E
  LD (BC),A
  DEC C
  DEC C
  DEC C
  DEC C
  JP -
++
  DEC D
  JR nz,++
_tempo:
;BC -> remaining note length
  LD A,E
  AND E
  JR nz,+++  ;Tempo 0: a tie
  SET 5,B
  JP -
+++
  PUSH HL
  PUSH BC
;X Beats  * 1 min       * 256 ticks   =   4 ticks
;1 Min    * 3600 frame  * 4 beats     = 225 frame
  LD C,E    ;Convert from BPM to ticks/frame
  LD A,0
  SLA C     ;Multiply by 4
  RLA
  SLA C
  RLA
  LD B,A
  LD E,%11100001    ;BC * 256 / 14400 (4/225)
  CALL Divide
  LD E,A
  LD D,L
  POP BC
  POP HL
  INC C
  LD A,D
  LD (BC),A
  INC C
  LD A,E
  LD (BC),A
  DEC C
  DEC C
  JP -
++  ;Sweep
;BC -> remaining note length
  CALL MemorytoIO
  LD A,E
  LDH (C),A
  CALL IOtoMemory
  JP -
+   ;1 Byte type (Note, Rest, Octave)
;Channel 4 check goes here (for special note handling)
  LD A,<channelfourbase+$2D
  CP C
  JP z,ChannelFourSpecial
  LD A,$C0
  AND D
  JR nz,+
  BIT 4,D
  JR nz,+++
    ;Octave
;BC -> remaining note length
  ;Subtract 2 from the read octave, since the GameBoy can't handle it
  LD A,$0F
  AND D
  SUB 2
  DEC C
  LD (BC),A
  INC C
  JP -
;For these, check the remaining note length and add it in - it could be negative
+++ ;Rest
;BC -> remaining note length
;Stamp 0 into envelope register temporarily, then skip pitch lookup and note playing
  SET 5,B   ;Use Tempo continuation to skip note start
  CALL MemorytoIO
  INC C
  INC C
  LDH A,(C) ;Stuff 0 into envelope
  LD E,A
  XOR A
  LDH (C),A ;This ends the note immediately
  LD A,E
  LDH (C),A ;Put the envelope back
  DEC C
  DEC C
  LDH A,(C) ;Hit up origin address too- might be Channel 3, and envelope doesn't end the note; On/Off does
  LD E,A
  XOR A
  LDH (C),A
  LD A,E
  LDH (C),A
  CALL IOtoMemory   ;Go back to remaining note length
+   ;Note
;At this point, we probably won't read another directive
;Update note pointer
  DEC C
  DEC C
  DEC C
  DEC C
  LD A,H
  LD (BC),A
  DEC C
  LD A,L
  LD (BC),A
  PUSH HL
;HL now free
  LD A,D    ;Directive
;Get length
  AND $0F   ;-(Length Index + 1)
  CPL
  ADD C
  LD C,A
  LD A,(BC) ;This note's length
;Get out of the length fields
  PUSH AF
  LD A,C
  AND $C0   ;Channel filter
  OR <channelonebase+$2D
  LD C,A
  POP HL    ;Note Length

;Set length here
;Add Note length to remaining note length
  LD A,(BC)
  LD L,A
  ADD H
;H = Note length, L = -(Extra ticks), A = H + L
;Store in remaining note length
  LD (BC),A
;Check if note is too short for this frame's tick (remaining note length <= 0)
;In order:
;0 + 0 = nc, 0;     jump    A check Zero
;- + + =  c, 0;     jump
;- + + =  c, 1;  no jump    A check Carry
;0 + + = nc, 1;  no jump    L check Zero
;- + 0 = nc, 1;     jump
;- + + = nc, 1;     jump
  JR z,++   ;If the result was 0, get more notes
  JR c,+    ;If the result carried, we are done
  XOR A
  OR L
  JR z,+    ;If there were no extra ticks, we are done
++
    ;If so,
        ;Turn off tie/rest
  LD B,>musicglobalbase
        ;Go back and read more
  POP HL    ;We need this
  JP -
+
  POP HL    ;Stack alignment
;Check for Tie/Rest
    ;If tie/rest, skip to the end
  BIT 5,B
  JR nz,NewDirectiveSkip

;BC -> remaining note length
;D  =  Directive
  LD H,D
  DEC C
  LD A,(BC) ;Octave
  PUSH AF
  DEC C
  LD A,(BC) ;Note table
  LD D,A
  DEC C
  LD A,(BC)
  LD E,A
  POP AF    ;Octave
  RLCA
  RLA
  RLA
  LD L,A
  RLA
  ADD L
  ADD E
  LD E,A
  LD A,H    ;Directive
  SUB $40
  AND $F0
  SWAP A
  RLCA
  ADD E
  LD E,A
;BC -> Remaining Note Length
;DE -> Note pitch
;Do we need to activate stacatto?
  LD A,7
  ADD C
  LD C,A
  LD A,(BC)
  LD B,$80
  OR A
  JR z,+
  SET 6,B
+
  DEC C
  DEC C
  DEC C
  DEC C
;Convert C from memory pointer to IO pointer
  CALL MemorytoIO
;This might be channel 3; in which case, we need to turn the note off first
;to preserve wave data
  LDH A,(C)
  LD L,A
  XOR A
  LDH (C),A
  LD A,L
  LDH (C),A
;Set note (pitch pointed to by DE)
  INC C
  INC C
  INC C
  LD A,(DE)
  INC E
  LDH (C),A
  INC C
  LD A,(DE)
  OR B  ;Stacatto active bit/Note active bit
  LDH (C),A
;Convert C from IO pointer to memory pointer
  DEC C
  DEC C
  DEC C
  DEC C
  CALL IOtoMemory
NewDirectiveSkip:
  LD B,$CE  ;Don't tie to note in next channel
  POP AF
  RET

;Special handling for Channel 3
ChannelThreeSpecial:
  BIT 2,D
  JR z,++
    ;Tone
;We can ignore D and use E as an index into the wave table
  CALL MemorytoIO
  PUSH HL
  LD HL,Wave
  SWAP E ;Waves are 16 bytes long
  LD A,$0F
  LDH (C),A   ;Have to turn off the channel to change the wave
  AND E
  LD D,A
  LD A,$F0
  AND E
  LD E,A
  ADD HL,DE
  LD A,$30-$1A
  ADD C
  LD C,A
--
  LDI A,(HL)
  LDH (C),A
  INC C
  BIT 6,C
  JR z,--
  LD C,<channelthreebase+$2D
  LD A,C    ;Turn the channel back on again
  LDH ($1A),A
  POP HL
  JP -
++
  DEC D
  JR nz,++
    ;Envelope
;Take the high two bits of the volume component
;And convert them such that
;00 -> 00; 01 -> 11; 10 -> 10; 11 -> 01;
;So, b1 = b1 ^ b0
;FE DC BA 98 76 54 32 10
;11 11 11 22 22 33 33 00
;ECA86420
;11122330
  CALL MemorytoIO   ;We do this, despite knowing the destination, because sound effects
  INC C     ;work by letting the music player think it's running, but the I/O
  INC C     ;writes get intercepted, so as to not interrupt the sound effect
  LD A,$E0
  AND E
  LD E,A
  XOR A
  SUB E
  CP %00100000  ;Edge case: E/F
  JR nz,+
  RLA
+
  RRA
  LDH (C),A   ;Guaranteed Channel 3
  DEC C
  DEC C
  CALL IOtoMemory
  JP -
++
  DEC D
  JR nz,++
    ;Stacatto
  LD A,E    ;DO affect wave
  CALL MemorytoIO
  INC C
  JP _stacattoentry
++
  DEC D
  JP z,_tempo
    ;Sweep
;No action
  JP -

ChannelFourSpecial:
;Channel 4 adjusts stacatto and envelope in addition to notes
  LD A,$C0
  AND D
  JR nz,+
  BIT 4,D
  JR nz,+++
    ;Octave
;BC -> remaining note length
  ;Subtract 2 from the read octave, since the GameBoy can't handle it
  LD A,$0F
  AND D
  SUB 2
  DEC C
  LD (BC),A
  INC C
  JP -
;For these, check the remaining note length and add it in - it could be negative
+++ ;Rest
;BC -> remaining note length
;Stamp 0 into envelope register temporarily, then skip pitch lookup and note playing
  SET 5,B   ;Use Tempo continuation to skip note start
  CALL MemorytoIO
  INC C
  INC C
  LDH A,(C) ;Stuff 0 into envelope
  LD E,A
  XOR A
  LDH (C),A ;This ends the note immediately
  LD A,E
  LDH (C),A ;Put the envelope back
  LD C,<channelfourbase+$2D ;Go back to remaining note length
+   ;Note
;At this point, we probably won't read another directive
;Update note pointer
  DEC C
  DEC C
  DEC C
  DEC C
  LD A,H
  LD (BC),A
  DEC C
  LD A,L
  LD (BC),A
  PUSH HL
;HL now free
  LD A,D    ;Directive
;Get length
  AND $0F   ;-(Length Index + 1)
  CPL
  ADD C
  LD C,A
  LD A,(BC) ;This note's length
;Get out of the length fields
  LD H,A    ;Note Length
  LD C,<channelfourbase+$2D

;Set length here
;Add Note length to remaining note length
  LD A,(BC)
  LD L,A
  ADD H
;H = Note length, L = -(Extra ticks), A = H + L
;Store in remaining note length
  LD (BC),A
;Check if note is too short for this frame's tick (remaining note length <= 0)
;In order:
;0 + 0 = nc, 0;     jump    A check Zero
;- + + =  c, 0;     jump
;- + + =  c, 1;  no jump    A check Carry
;0 + + = nc, 1;  no jump    L check Zero
;- + 0 = nc, 1;     jump
;- + + = nc, 1;     jump
  JR z,++   ;If the result was 0, get more notes
  JR c,+    ;If the result carried, we are done
  XOR A
  OR L
  JR z,+    ;If there were no extra ticks, we are done
++
    ;If so,
        ;Turn off tie/rest
  LD B,>musicglobalbase
        ;Go back and read more
  POP HL    ;We need this
  JP -
+
  POP HL    ;Stack alignment
;Check for Tie/Rest
    ;If tie/rest, skip to the end
  BIT 5,B
  JP nz,NewDirectiveSkip

;BC -> remaining note length
;D  =  Directive
  LD H,D
  DEC C
  DEC C
  DEC C
  LD A,(BC) ;Note table
  INC C
  ADD 120   ;Stacatto portion
  LD E,A
  LD A,(BC)
  ADC 0
  LD D,A
  INC C
  LD A,(BC) ;Octave
  RLCA      ;x12
  RLA
  LD L,A
  RLA
  ADD L
  LD L,A
  LD A,H    ;Directive
  SUB $40
  AND $F0
  SWAP A
  ADD L ;Octave offset
  LD L,A    ;We need this later
  ADD E
  LD E,A
  LD A,0
  ADC D
  LD D,A
  INC C
;BC -> Remaining Note Length
;DE -> Note pitch
;Do we need to activate stacatto?
;For channel 4, this is held in the note table (DE)
  LD A,(DE)
  LD B,$80
  OR A
  JR z,+
  SET 6,B
+
;Convert C from memory pointer to IO pointer
  CALL MemorytoIO
  INC C
;Set Stacatto, Envelope, note (Stacatto pointed to by DE)
  LD A,(DE)
  LDH (C),A ;Stacatto
  INC C
  LD A,L    ;Move from stacatto to note data
  SUB 119
  ADD E
  LD E,A
  JR c,+
  DEC D
+
  LD A,(DE)
  LDH (C),A ;Envelope
  INC C
  DEC E
  LD A,(DE)
  LDH (C),A ;Note
  INC C
  LD A,B  ;Stacatto active bit/Note active bit
  LDH (C),A
;Convert C from IO pointer to memory pointer
  LD BC,channelfourbase+$2D  ;Don't tie to note in next channel
  POP AF
  RET
.ENDS
