;Go see Maps.asm too.

.include "mapDef.asm"   ;<--- LOOK HERE FOR DATA EXPLANATIONS!!

.include "macros.asm"

.SECTION "Map support" FREE

;DE->map data
;Loads map to RAM, sets hotMap upon copying visuals
;Overwrites old map in shadow RAM with new one. Does not copy to screen
LoadMap_Task:
  LD HL,hotMap
  LD (HL),0
  INC HL
  PUSH HL   ;mapExtract
  LD HL,mapWidth
  LD A,(DE)
  INC DE
  LDI (HL),A
  LD A,(DE)
  INC DE
  LD (HL),A
  LD H,D
  LD L,E
  LD DE,MapArea
  CALL ExtractSpec
  POP BC
  RST $00
  PUSH BC
  CALL ExtractRestoreSP
  POP BC
  RST $00
  PUSH BC
  CALL ExtractRestoreSP
  POP BC
  RST $00
  PUSH BC
  CALL ExtractRestoreSP
  POP BC
  RST $00
  PUSH BC
  CALL ExtractRestoreSP
  POP BC
  RST $00
  PUSH BC
  CALL ExtractRestoreSP ;Attribute data
  POP BC
  RST $00
;Place random grass in the designated areas
  LD HL,MapArea
  LD BC,1024+$100   ;Map size
  LD A,$EF      ;Sentinel value for grass
-
  CP (HL)
  JR z,+
  INC HL   ;Is not grass
--
  DEC C
  JR nz,-
  LD D,H
  LD E,L
  RST $00         ;Let other things run (and conserve battery)
  LD H,D
  LD L,E
  DEC B
  JR nz,-
++
  LD HL,hotMap
  LD (HL),$80
  JP EndTask
+
;Is grass
  RST $18   ;Random
  AND $F
  RRA   ;Random number [0-8], with 0s and 8s being unlikely
  ADC (HL)  ;offset into grass
  LDI (HL),A
  LD A,$EF      ;Sentinel value for grass
  JR --

;Loads map in RAM to screen
ShowMap_Task:
  LD DE,LoadMapMagicVal
  LD A,4
  LD BC,LoadToVRAM_Task
-
  RST $00
  CALL NewTask
  JR c,-
  LD A,B
  CALL WaitOnTask
  LD HL,hotMap
  LD (HL),$FF
  JP EndTask

;B=Y pos
;C=X pos
;Returns value in carry
;Destroys BC,A,HL
GetPriAtBC:
  LD HL,PriArea
  JR _GetItmAtBC
GetVisAtBC:
  LD HL,VisArea
  JR _GetItmAtBC
GetColAtBC:
  LD HL,ColArea
_GetItmAtBC:
  LD A,B
  SUB 16    ;Fix GB-level location offset
  LD B,A
  LD A,C
  SUB 8
  LD C,A
  LD A,$F8  ;Get byte address, Y portion
  AND B
  RRCA
  ADD L
  LD L,A
  LD A,$C0  ;Get byte address, X portion
  AND C
  RLCA
  RLCA
  ADD L
  LD L,A
  LD A,$38  ;Get bit from byte
  AND C
  RRCA
  RRCA
  RRCA
  INC A
  LD C,A
  LD A,(HL)
-
  RLA
  DEC C
  JR nz,-
  RET
.ENDS