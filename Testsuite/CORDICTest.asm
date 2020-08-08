.MEMORYMAP          ;Memory Map (For wla-gb)
SLOTSIZE $4000
DEFAULTSLOT 1
SLOT 0 $0000    ;ROM banks
SLOT 1 $4000
.ENDME

.ROMBANKMAP         ;ROM Bank Map (no mapping)
BANKSTOTAL 2
BANKSIZE $4000
BANKS 2
.ENDRO

.EMPTYFILL $FF  ;RST $38

.COMPUTEGBCHECKSUM  ;Checksum calculations (perfomed by wla-gb)
.COMPUTEGBCOMPLEMENTCHECK

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
 .db "CORDIC TEST"
;     123456789AB
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
  LD HL,TestData
  LD DE,TestResults
  LD BC,Storage
-
  PUSH BC
  PUSH DE
  LD BC,CORDIC_X
  LD E,6
--
  LDI A,(HL)
  LD (BC),A
  INC C
  DEC E
  JR nz,--
  PUSH HL
  CALL CORDIC
  POP HL
  POP DE
  POP BC
  PUSH HL
  LD HL,CORDIC_X
  LD E,6
--
  LDI A,(HL)
  LD (BC),A
  INC BC
  DEC E
  JR nz,--
  POP HL
  JR -
TestData:
 .dw 0,0,0, 1101,2202,0, 0,0,80, 0,0,65535, 1101,1101,10923, 1101,2202,16385, 1101,1101,35316, 1101,2202,35316, 65535,65535,65535
TestResults:
 .dw 0,0,0, $44D,$89A,0, 0,0,0,  0,0,0,    $FE6D,$5E0,0,     $F766,$44D,0     $FCDE,$FAC9,0,   $FDE8,$F69D,0,   5,$FFF9,0

.define Storage $D000

.ENDS
