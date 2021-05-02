;Implementation notes
    ;Priority is hard to support on DMG, but easy on GBC
    ;The most viable way is frame by frame sprite priority assignment
    ;For this to work, we need a buffer of 7 pixels between prio and non-prio
    ;Code in game will have to be written to handle this every frame
    ;A 3:4 division is what comes to mind at first.
    ;But that isn't here

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
  CALL HaltTask
  PUSH BC
  CALL ExtractRestoreSP
  POP BC
  CALL HaltTask
  PUSH BC
  CALL ExtractRestoreSP
  POP BC
  CALL HaltTask
  PUSH BC
  CALL ExtractRestoreSP
  POP BC
  CALL HaltTask
  PUSH BC
  CALL ExtractRestoreSP
  POP BC
  CALL HaltTask
  PUSH BC
  CALL ExtractRestoreSP ;Attribute data
  POP BC
  CALL HaltTask
;Place random grass in the designated areas
  LD HL,MapArea
  LD BC,1024+$100   ;Map size
  LD A,$EF      ;Sentinel value for grass
-
  CP (HL)
  JR nz,+
;Is grass
  RST $18   ;Random
  AND $F
  RRA   ;Random number [0-8], with 0s and 8s being unlikely
  ADC (HL)  ;offset into grass
  LD (HL),A
  LD A,$EF      ;Sentinel value for grass
+   ;Is not grass
  INC HL
  DEC C
  JR nz,-
  DEC B
  JR nz,-
++
  LD HL,hotMap
  LD (HL),$80
  JP EndTask

;Loads map in RAM to screen
ShowMap_Task:
  LD DE,LoadMapMagicVal
  LD A,4
  LD BC,LoadToVRAM_Task
-
  CALL HaltTask
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

.SECTION "Maps" FREE

MapForestBKG01:
.db 32,32
.db $82,$97,$98     ;Upper left corner is Tile $97 (the solid dark tree part)
.db $00,$02,$1E
.db $82,$AA,$AD
.db $00,$02,$1E
.db $00,$40,$00
.db $00,$40,$00
.db $00,$40,$00
.db $00,$40,$00

MapForestBKG02:
.db 32,32
.db $82,$98,$97     ;Upper left corner is Tile $98 (side border b/w two dark trees)
.db $00,$02,$1E
.db $82,$AD,$AA
.db $00,$02,$1E
.db $00,$40,$00
.db $00,$40,$00
.db $00,$40,$00
.db $00,$40,$00

MapForestBKG03:
.db 32,32
.db $82,$AA,$AD     ;Upper left corner is Tile $AA (top border b/w two dark trees)
.db $00,$02,$1E
.db $82,$97,$98
.db $00,$02,$1E
.db $00,$40,$00
.db $00,$40,$00
.db $00,$40,$00
.db $00,$40,$00

MapForestBKG04:
.db 32,32
.db $82,$AD,$AA     ;Upper left corner is Tile $AD (dark tree four corner)
.db $00,$02,$1E
.db $82,$98,$97
.db $00,$02,$1E
.db $00,$40,$00
.db $00,$40,$00
.db $00,$40,$00
.db $00,$40,$00

MapForestN23:
.incbin "rsc/Forest_(-2~3).gbm"
.db $88
.dw 0                   ;up
.dw Cs_LoadN23toN13_1   ;down
.dw 0                   ;left
.dw 0                   ;right
.db $00,$00,$78

MapForestN13:
.incbin "rsc/Forest_(-1~3).gbm"
.db $88                 ;Magic constant for decompressor to copy this literal string
.dw Cs_LoadN13toN23_1   ;up
.dw Cs_LoadN13to03_1    ;down
.dw 0                   ;left
.dw 0                   ;right
.db $00,$00,$78         ;Magic string for map decompressor to ignore rest of data

MapForest00:
.incbin "rsc/Forest_(0~0).gbm"
.db $88
.dw 0                   ;up
.dw 0                   ;down
.dw 0                   ;left
.dw Cs_Load00to01_1     ;right
.db $00,$00,$78

MapForest01:
;This map is shared with 04, so the cutscene loads that one.
;.incbin "rsc/Forest_(0~1).gbm"
.db $88
MapForest01Obj:
.dw 0                   ;up
.dw Cs_Load01to00_1     ;down
.dw 0                   ;left
.dw Cs_Load01to11_1     ;right
.db $00,$00,$78

MapForest02:
.incbin "rsc/Forest_(0~2).gbm"
.db $88
.dw Cs_Load02to24_1     ;up
.dw Cs_Load02to12_1     ;down
.dw 0                   ;left
.dw 0                   ;right
.db $00,$00,$78

MapForest03:
.incbin "rsc/Forest_(0~3).gbm"
.db $88
.dw Cs_Load03toN13_1    ;up
.dw Cs_Load03to13_1     ;down
.dw 0                   ;left
.dw Cs_Load03to04_1     ;right
.db $00,$00,$78

MapForest04:
.incbin "rsc/Forest_(0~4).gbm"
.db $88
.dw Cs_Load04to31_1     ;up
.dw Cs_Load04to14_1     ;down
.dw Cs_Load04to03_1     ;left
.dw 0                   ;right
.db $00,$00,$78

MapForest10:
.incbin "rsc/Forest_(1~0).gbm"
.db $88
.dw Cs_Load10to00_1     ;up
.dw 0                   ;down
.dw 0                   ;left
.dw 0                   ;right
.db $00,$00,$78

MapForest11:
.incbin "rsc/Forest_(1~1).gbm"
.db $88
.dw Cs_Load11to01_1     ;up
.dw Cs_Load11to21_1     ;down
.dw 0                   ;left
.dw Cs_Load11to12_1     ;right
.db $00,$00,$78

MapForest12:
.incbin "rsc/Forest_(1~2).gbm"
.db $88
.dw Cs_Load12to02_1     ;up
.dw 0                   ;down
.dw Cs_Load12to11_1     ;left
.dw Cs_Load12to13_1     ;right
.db $00,$00,$78

MapForest13:
.incbin "rsc/Forest_(1~3).gbm"
.db $88
.dw Cs_Load13to03_1     ;up
.dw Cs_Load13to23_1     ;down
.dw Cs_Load13to12_1     ;left
.dw 0                   ;right
.db $00,$00,$78

MapForest14:
.incbin "rsc/Forest_(1~4).gbm"
.db $88
.dw Cs_Load14to04_1     ;up
.dw Cs_Load14to24_1     ;down
.dw Cs_Load14to13_1     ;left
.dw 0                   ;right
.db $00,$00,$78

MapForest20:
;.incbin "rsc/Forest_(2~0).gbm"
.db $88
MapForest20Obj:
.dw Cs_Load20to10_1     ;up
.dw 0                   ;down
.dw 0                   ;left
.dw 0                   ;right
.db $00,$00,$78

MapForest21:
.incbin "rsc/Forest_(2~1).gbm"
.db $88
.dw Cs_Load21to11_1     ;up
.dw 0                   ;down
.dw 0                   ;left
.dw Cs_Load21to22_1     ;right
.db $00,$00,$78

MapForest22:
.incbin "rsc/Forest_(2~2).gbm"
.db $88
.dw Cs_Load22to30_1     ;up
.dw Cs_Load22to32_1     ;down
.dw Cs_Load22to21_1     ;left
.dw Cs_Load22to23_1     ;right
.db $00,$00,$78

MapForest23:
.incbin "rsc/Forest_(2~3).gbm"
.db $88
.dw Cs_Load23to13_1     ;up
.dw Cs_Load23to33_1     ;down
.dw Cs_Load23to22_1     ;left
.dw 0                   ;right
.db $00,$00,$78

MapForest24:
.incbin "rsc/Forest_(2~4).gbm"
.db $88
.dw Cs_Load24to14_1     ;up
.dw 0                   ;down
.dw Cs_Load24to02_1     ;left
.dw 0                   ;right
.db $00,$00,$78

MapForest30:
.incbin "rsc/Forest_(3~0).gbm"
.db $88
.dw Cs_Load30to20_1     ;up
.dw Cs_Load30to22_1     ;down
.dw 0                   ;left
.dw 0                   ;right
.db $00,$00,$78

MapForest31:
.incbin "rsc/Forest_(3~1).gbm"
.db $88
.dw 0                   ;up
.dw 0                   ;down
.dw 0                   ;left
.dw Cs_Load31to32_1     ;right
.db $00,$00,$78

MapForest32:
.incbin "rsc/Forest_(3~2).gbm"
.db $88
.dw 0                   ;up
.dw 0                   ;down
.dw Cs_Load32to31_1     ;left
.dw Cs_Load32to33_1     ;right
.db $00,$00,$78

MapForest33:
.incbin "rsc/Forest_(3~3).gbm"
.db $88
.dw Cs_Load33to23_1     ;up
.dw Cs_Load33to34_2     ;down
.dw Cs_Load33to32_1     ;left
.dw Cs_Load33to34_1     ;right
.db $00,$00,$78

MapForest34:
.incbin "rsc/Forest_(3~4).gbm"
.db $88
.dw Cs_Load34to33_2     ;up
.dw 0                   ;down
.dw Cs_Load34to33_1     ;left
.dw Cs_Load34to00_1     ;right
.db $00,$00,$78

.ENDS
