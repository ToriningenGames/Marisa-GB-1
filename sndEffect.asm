;Sound Effects

;Requirements:
    ;Submit a sound effect to play. Tasks do nothing else
    ;Do they stack, overwrite, or drop?
        ;Stack would be too unsettling
        ;Drop is easiest
    ;Try to avoid Channel 3.
        ;Overwriting wave data is time consuming
        ;Control register disables it; logic involving sound effects is long
        ;Master spark doesn't sound that great
;What sound effects need:
    ;Pitch sequence
    ;Envelope sequence
    ;Sweep sequence
    ;Duty sequence
    ;Stacatto sequence
    ;Channel requirements
        ;Single channel effects?
;Format:
    ;Channel needed
        ;If channel == 3, wave specifier follows
    ;Channel 1:
        ;Sweep
        ;Duty & Length
        ;Envelope
        ;Freq Lo
        ;Enable & Freq Hi
            ;%1EXXXFFF
    ;Channel 2:
        ;Duty & Length
        ;Envelope
        ;Freq Lo
        ;Enable & Freq Hi
            ;%1EXXXFFF
    ;Channel 3:
        ;Length
        ;Vol
            ;%XVVXXXXX
        ;Freq Lo
        ;Enable & Freq Hi
            ;%1EXXXFFF
    ;Channel 4:
        ;Enable & Length
            ;%1ELLLLLL
        ;Envelope
        ;Freq
    ;Frame count wait (0 for finish)
;Note: Never make those 1s 0s on Channel 2.

;Memory map:
    ;+$00:  frames until next note
    ;+$01:  Effect data pointer

.DEFINE ChOneData (channelonebase + musicsize)
.DEFINE ChTwoData (channeltwobase + musicsize)
.DEFINE ChThreeData (channelthreebase + musicsize)
.DEFINE ChFourData (channelfourbase + musicsize)
;.EXPORT ChThreeData ;Bug workaround involving arithmetic on this value

.SECTION "Snd Effects" FREE

_SndChFrame:
;Does the frame-by-frame handiwork to play a sound effect on a given channel
;DE -> channel SE data
;C -> channel base register
;B = channel reg count
    ;BC for each channel
        ;1: $0510
        ;2: $0416
        ;3: $041B
        ;4: $0320
;Returns 0 in A if sound effect done
;Check for new entry
  LD A,(DE)
  DEC A
  LD (DE),A
  RET nz
;Get new entry
  INC E
  LD A,(DE)
  LD L,A
  INC E
  LD A,(DE)
  LD H,A
;Save for later
  LD A,(HL)
  PUSH AF
;Update sound registers
-
  LDI A,(HL)
  LDH (C),A
  INC C
  DEC B
  JR nz,-
;Start and Length
  POP AF
  LDH (C),A
;Update entry pointer
  INC HL
  LD A,H
  LD (DE),A
  DEC E
  LD A,L
  LD (DE),A
  DEC E
  DEC HL
  LD A,(HL)
  LD (DE),A
  RET

SndLoop:
;Plays sound effects on each channel, if loaded
  LD A,(musicglobalbase)
;Channel 1
  RLCA
  JR nc,+
  PUSH AF
  LD DE,ChOneData
  LD BC,$0510
  CALL _SndChFrame
  OR A
  LD A,$FF
  JR nz,++
;Effect ended; Restore music channel values
  LD BC,$0510
  LD HL,$FF90
-
  LDI A,(HL)
  LDH (C),A
  INC C
  DEC B
  JR nz,-
  LD A,$FE
++
  POP BC
  AND B
+
;Channel 2
  RLCA
  JR nc,+
  PUSH AF
  LD DE,ChTwoData
  LD BC,$0416
  CALL _SndChFrame
  OR A
  LD A,$FF
  JR nz,++
;Effect ended; Restore music channel values
  LD BC,$0416
  LD HL,$FF96
-
  LDI A,(HL)
  LDH (C),A
  INC C
  DEC B
  JR nz,-
  LD A,$FE
++
  POP BC
  AND B
+
;Channel 3
  RLCA
  JR nc,+
  PUSH AF
  LD DE,ChThreeData
  LD BC,$041B
  CALL _SndChFrame
  OR A
  LD A,$FF
  JR nz,++
;Effect ended; Restore music channel values
;Wave first
  XOR A
  LDH ($1A),A
  LD HL,$FFB0
  LD BC,$1030
-
  LDI A,(HL)
  LDH (C),A
  INC C
  DEC B
  JR nz,-
  LD A,$FF
  LDH ($1A),A
;Other values
  LD BC,$041B
  LD L,$9B
-
  LDI A,(HL)
  LDH (C),A
  INC C
  DEC B
  JR nz,-
  LD A,$FE
++
  POP BC
  AND B
+
;Channel 4
  RLCA
  JR nc,+
  PUSH AF
  LD DE,ChFourData
  LD BC,$0320
  CALL _SndChFrame
  OR A
  LD A,$FF
  JR nz,++
;Effect ended; Restore music channel values
  LD BC,$0420
  LD HL,$FFA0
-
  LDI A,(HL)
  LDH (C),A
  INC C
  DEC B
  JR nz,-
  LD A,$FE
++
  POP BC
  AND B
+
  SWAP A    ;Bring back to start
  LD (musicglobalbase),A
  RET

SndLoad:
;Sets up a sound effect to play
;BC -> sound effect
;Carry set if effect can't be played
;KNOWN (theoretical) BUG: if vBlank happens while called,
    ;and another sound effect ends, it is restarted with garbage data.
    ;When music channel is resumed, no data is lost.
    ;Testing needed to determine severety.
  LD HL,musicglobalbase
  LD A,(BC)
  LD D,A
  LD E,A
  LD A,(HL)
-
  RLA
  DEC D
  JR nz,-
  RET c     ;if channel is already taken, return with carry set
  SCF
  LD D,E    ;Take this channel
-
  RRA
  DEC D
  JR nz,-
  LD D,A    ;Save for after we set data
;Get to next channel's data by multiplying E by $40 (channelsize)
;Then adding 4 for base offset
;And subtracting size from max to get to channel sound effect
;Then go to the 3rd data entry
  LD A,E
  RRCA
  RRCA
  AND $F0   ;Channel 4 equaling %100 messes this up otherwise
  SUB 5 ;$0B - $04 + 2
  LD L,A
;Load the pointer to data (not channel req.) and a frame count of 1
  INC BC
  LD (HL),B
  DEC L
  LD (HL),C
  DEC L
  LD (HL),1
;Save this channel's data
;(E-1) * 5 + $10
  DEC E
  LD A,E
  RLCA
  RLCA
  ADD E
  ADD $10
  LD H,$FF
  LD L,A
  ADD $80
  LD C,A
  LD B,5
-
  LDI A,(HL)
  LDH (C),A
  INC C
  DEC B
  JR nz,-
;If Channel 3, also save and load wave data
  LD A,E
  SUB 2 ;We subtracted 1 earlier
  JR nz,+
;Save, then load wave
  LDH ($1A),A   ;Turn off channel
  LD BC,$10B0
  LD L,$30
-
  LDI A,(HL)
  LDH (C),A
  INC C
  DEC B
  JR nz,-
;Get new wave index
  LD HL,ChThreeData+1
  INC (HL)  ;Increment out of wave index
  LDI A,(HL)
  JR nz,++
  INC (HL)  ;Carry
++
  LD H,(HL)
  LD L,A
  DEC HL
  LD A,(HL)
;Convert wave index to pointer
  SWAP A
  LD L,A
  AND $0F
  ADD >Voicelist
  LD H,A
  LD A,$F0
  AND L
  LD L,A
;Load new wave
  LD BC,$1030
-
  LDI A,(HL)
  LDH (C),A
  INC C
  DEC B
  JR nz,-
;Turn on channel
  OR $FF
  LDH ($1A),A
+
;Actually claim the channel, now that we have valid data
  LD A,D
  LD (musicglobalbase),A
  OR A  ;Clear carry
  RET

.ENDS
;Needed:
    ;Variable length sound effects
;Testing:
;Minimal testing: Make sure environment is sane
    ;Channel 1, changing sweep. One entry. Make sure song continues.
;Call testing: Avoid crashes and bricked states
    ;More than one request. Ensure denial.
    ;Requests on two channels. Ensure success.
    ;Request channel 3. Make sure wave works.
;Internal testing: Make sure song returns to normal
    ;More than one entry long.
    ;Really long effect.
    ;All channels.
    ;Shortest effect.
;Usefulness testing: Some use cases
    ;Step sound effect: Only when she is moving.
    ;Master spark effect: Only when she fires.
    ;Bonk sound effect: When she touches a thing.
    ;Beep sound effect: When a menu pointer is changed.

;Random Master spark:
;CH1: Duty 1 Env $7 Note $02B
;CH2: Duty 3 Env $7 Note $362
;CH3: Vol 1 Note $5AC
;Wave data: BE EA 73 39 EF FF FE CA BD DB 96 32 10 13 21 24
;Add static
;Mess around with it
;This could work!
