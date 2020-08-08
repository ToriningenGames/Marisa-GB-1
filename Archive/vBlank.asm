;vBlank transfer idea:

;Bitfield type

;vBlank routine scans a bitfield, possibly for different types of tranfers,
;and initiates a transfer from a fixed location for each set bit

;Considerations

;Bit instructions are costly, except acculumator rolling
;Careful balance between transfer count and max byte throughput
;what transfer types should be available?
    ;Direct?
    ;Pointer?
    ;Vertical?
    ;Rectangular?
    ;Point?
    ;Giant?
;
;Stats!
    ;Maximum bytes
        ;One transfer
            ;Alone:    98 - 88
            ;With OAM: 81 - 71
        ;Remaining cycles
            ;Alone:    32
            ;With OAM: 4
        ;Transfer byte time equivalent
            ;Min: 3.6   = 3 bytes + 24 cycles
            ;Max: 12.55 = 12 bytes + 22 cycles
;cycles when used, no transfers, no tiles:  112
;cycles when used, every new transfer:      144 min, 508 max
;cycles when used, every empty transfer:    52
;cycles when used, every extra byte:        40

;112 : 144 : 52 : 40

;If this code is running, that means a transfer is detected
  PUSH DE           ;16
  LD L,$FF          ;8
  LDI A,(HL)        ;8
  LD E,A            ;4
  JR _f             ;12
-
  LDI A,(HL)        ;8
  LD D,A            ;4
  LDI A,(HL)        ;8
  LD C,A            ;4
  LDI A,(HL)        ;8
  LD B,A            ;4
  LDI A,(HL)        ;8
  PUSH HL           ;16
  LD H,(HL)         ;8
  LD L,A            ;4
--
  LD A,(BC)         ;8
  LDI (HL),A        ;8
  INC BC            ;8
  DEC D             ;4
  JR nz,--          ;8 / 12
  POP HL            ;12
  INC L             ;4
_
  SRL E             ;8
  JR c,-            ;8 / 12
  JR z,+            ;8 / 12
  LD A,$05          ;8
  ADD L             ;4
  LD L,A            ;4
  JR _b             ;12
+   ;Transfers finished
  LD A,E            ;4
  LD HL,$CFFF       ;12
  LD (HL),A         ;8
  POP DE            ;12
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   OR

;172 : 100 : 52 : 40

  PUSH DE           ;16
  LD ($C000),SP     ;20
  LD SP,$CFFE       ;12
  POP AF            ;12
  LD E,A            ;4
  JR _f             ;12
-
  LD A,E            ;4
  POP DE            ;12
  LD E,A            ;4
  POP BC            ;12
  POP HL            ;12
--
  LD A,(BC)         ;8
  LDI (HL),A        ;8
  INC BC            ;8
  DEC D             ;4
  JR nz,--          ;8 / 12
_
  SRL E             ;8
  JR c,-            ;8 / 12
  JR z,+            ;8 / 12
  ADD SP,+$06       ;16
  JR _b             ;12
+
  LD SP,$C000       ;12
  POP HL            ;12
  LD SP,HL          ;8
  LD A,E            ;4
  LD HL,$CFFF       ;12
  LD (HL),A         ;8
  POP DE            ;12

;Update a given set of tiles
  LD HL,TileUpdateBase
  LDI A,(HL)
  RLCA
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

;Update a rectangle
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
  DEC D
  JR nz,--
