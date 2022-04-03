;Fairy behaviour

.include "ActorData.asm"

;We have
    ;Long hair     and Short hair
    ;Striped dress and Solid dress
    ;Thick wing    and Thin wing
;With only a couple hiccups, these are interchangeable, leading to
;2 * 2 * 2 == 2 ^ 3 == 8 different fairy designs!
;Each additional fairy design will also only take up 4 tiles,
    ;and increase the above dramatically!
;(You forgot back and side facings when writing those numbers)

.SECTION "Fairy" FREE


;Fairy Types:
    ;%AAHHBBWW
    ;       ++--- Wing type
    ;     ++----- Body type
    ;   ++------- Hair type
  ;Values:
    ;0: Zombie part
    ;1: Prim part
    ;2: Experienced part
    ;3: Invalid part

;facing data
;Order:
    ;Relative Y
    ;Relative X
    ;Tile
    ;Attribute XOR (For correct flips)
;All UDLR designations are screen-based

FairyActorData:
 .dw 100
 .dw FairyHitboxes
 .dw FairyFrame
 .dw _HatValues
 .dw FairyAnimations

_FairyVals:                                                                                           ;Padded to 16
 .db %010100,%010101,%010110,%011000,%011001,%011010,%100100,%100101,%100110,%101000,%101001,%101010, %010101,%101010,%010101,%101010
;Zombie fairies
 .db %000000,%000001,%000010,%000100,%000101,%000110,%001000,%001001,%001010,%010000,%010001,%010010,%100000,%100001,%100010, %000000


FairyConstructorRandom:
;Creates a fairy (like below) but uses a random value
;Avoids zombie parts when Narumi is defeated
  RST $18
  AND $1F
  LD HL,$C000+18
  BIT 0,(HL)
  JR z,+
  RRA   ;carry 0 from AND
+
  ADD <_FairyVals
  LD L,A
  LD A,0
  ADC >_FairyVals
  LD H,A
  LD A,(HL)
FairyConstructor:
;Takes in the Fairy Designator byte and provides the correct animation data in RAM
;Then, it makes an instance of the fairy, which knows to free it when done
;Of course, it provides the values from creating a fairy back to the caller.
  PUSH AF
    CALL MemAlloc     ;Animations
    PUSH DE
      LD HL,FairyAnimations
      LD C,FairyAnimSize
      RST $08
      ;Correct for fairy type
    POP HL
  POP AF
  PUSH HL
    LD D,A
    ;Correct pointers
    LD C,4
-
    LD A,L
    ADD (HL)
    LDI (HL),A
    LD A,H      ;This relies on all alloc'd addresses being even
    ADC (HL)
    LDI (HL),A
    DEC C
    JR nz,-
    ;Correct tiles
    LD A,$03
    AND D       ;Wing
    LD E,A
    LD A,$0C
    AND D       ;Body
    RRCA
    RRCA
    LD C,A
    LD A,$30
    AND D       ;Hair
    SWAP A
    ;right
    LD D,E
    PUSH DE     ;Wing, Wing
    LD B,A
    PUSH BC     ;Hair, Body
    LD A,2
    PUSH AF     ;Count
    ;left
    PUSH BC     ;Hair, Body
    PUSH DE     ;Wing, Wing
    PUSH AF     ;Count
    ;up
    LD E,B
    PUSH DE     ;Wing, Hair
    LD E,D
    PUSH DE     ;Wing, Wing
    LD D,C
    PUSH DE     ;Body, Wing
    LD A,3
    PUSH AF     ;Count
    ;down
    LD D,E
    LD E,B
    PUSH DE     ;Wing, Hair
    LD E,D
    PUSH DE     ;Wing, Wing
    LD D,C
    PUSH DE     ;Body, Wing
    PUSH AF     ;Count
    ;Execute changes
    LD B,4
--
    POP AF      ;Count
    LD C,A
    INC HL      ;Skip header
-
    POP DE
    INC HL
    LD A,(HL)
    ADD E
    AND %11011111   ;Do not affect palette
    LDI (HL),A
    INC HL
    LD A,(HL)
    ADD D
    AND %11011111   ;Do not affect palette
    LDI (HL),A
    DEC C
    JR nz,-
    INC HL      ;Skip tail
    INC HL
    DEC B
    JR nz,--
    CALL MemAlloc     ;Actor header
    PUSH DE
      LD HL,FairyActorData
      LD C,8
      RST $08
      LD H,D
      LD L,E
    POP DE
  POP BC
  LD (HL),C
  INC HL
  LD (HL),B
  LD BC,Actor_FrameInit
  JP NewTaskLo

FairyFrame:
  XOR A
  RET

;This is in Animations.asm, adjacent to the animations proper
;_Animations:

_HatValues:
 .db 2
 .db 18
 .db 34
 .db 50

.ENDS
