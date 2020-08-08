;Pause task

;Causes a game with the multitasker to pause
;Run as its own task

;TODO: Make pausing disableable, so cutscenes can't be paused

.SECTION "Pause" FREE

.DEFINE _PauseMask %00001000

PauseTask:
;Do pause enabled check here
  LDH A,($FE)   ;Button Data
  AND _PauseMask ;Check for start pressed
  RET z         ;Done if not pressed
;Disable sound here
  LD HL,musicglobalbase+1
  RES 1,(HL)    ;Don't advance music track
  XOR A
  LDH ($25),A   ;No sound output
;Possibly replace with 4-channel sound effect
    ;Bonus effect of saving all registers
    ;Well timed Sound disable also gets battery savings
        ;Remember to restore $24 and $25!
;Possibly display graphics
-   ;System takeover
  HALT
  LDH A,($FE)   ;Wait for button to be released
  AND _PauseMask
  JR nz,-
  LD C,A        ;Counter
--
  LD D,71
-   ;Active screen section
  HALT
  LDH A,($FE)   ;As above
  AND _PauseMask ;Wait for it to be pressed again
  JR nz,+
  DEC C
  JR nz,-
  DEC D
  JR nz,-
;Passive screen section
;Set interrupt state here
;Joypad interrupts exclusively for STOPs
  LDH (C),A     ;Enable all buttons
  DEC C
  LDH A,(C)     ;Save current interrupt enables
  LD B,A
  LDH A,($0F)     ;Remove flag if present
  AND $FE
  LDH ($0F),A
  LDH A,(C)   ;Enable tripping of interrupt
  OR 1
  LDH (C),A
  STOP      ;System put in standby until button pressed
  NOP
  LD A,B    ;vBlank must be reenabled
  LDH (C),A
  JR --
+
;Wait for it to be released
-
  HALT
  LDH A,($FE)
  AND _PauseMask
  JR nz,-
;Continue gameplay
;Possibly replace below with a sound effect
;Reenable sound here
  XOR A
  CPL
  LDH ($25),A
  SET 1,(HL)
  RET

.ENDS
