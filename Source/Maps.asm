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
  LD HL,hotMap
  LD (HL),$FF
  CALL HaltTask
  PUSH BC
  CALL ExtractRestoreSP ;Attribute data
  POP BC
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

MapForestBKG:
.incbin "rsc/Forest_20210218_(BKG).gbm"
.db $81,$00,$00,$01,$7F ;Magic string for map decompressor to wipe rest of data

MapForestN13:
.incbin "rsc/Forest_20210217_(-1~3).gbm"
.db $8C             ;Magic constant for decompressor to copy this literal string
.db   0             ;Distance from top of background to activate at
.dw Cs_Reset        ;Cutscene to play upon activation
.db 144             ;Distance to bottom of background to activate at
.dw Cs_Reset        ;Cutscene to play upon activation
.db   0             ;Distance from left of background to activate at
.dw Cs_Reset        ;Cutscene to play upon activation
.db 160             ;Distance to right of background to activate at
.dw Cs_Reset        ;Cutscene to play upon activation
.db $00,$00,$74     ;Magic string for map decompressor to ignore rest of data

MapForest02:
.incbin "rsc/Forest_20200414_(0~2).gbm"
.db $8C
.db 18                  ;up
.dw Cs_Reset
.db 250                 ;down
.dw Cs_Load02to12_1
.db 0                   ;left
.dw Cs_Reset
.db 0                   ;right
.dw Cs_Reset
.db $00,$00,$74

MapForest12:
.incbin "rsc/Forest_20210129_(1~2).gbm"
.db $8C
.db 15                  ;up
.dw Cs_Load12to02_1
.db 0                   ;down
.dw Cs_Reset
.db 16                  ;left
.dw Cs_Reset
.db 232                 ;right
.dw Cs_Load12to13_1
.db $00,$00,$74

MapForest13:
.incbin "rsc/Forest_20200414_(1~3).gbm"
.db $8C
.db 8                   ;up
.dw Cs_Reset
.db 230                 ;down
.dw Cs_Reset
.db 8                   ;left
.dw Cs_Load13to12_1
.db 230                 ;right
.dw Cs_Reset
.db $00,$00,$74

MapForest23:
.incbin "rsc/Forest_20210224_(2~3).gbm"

MapForest30:
.incbin "rsc/Forest_20210130_(3~0).gbm"
.ENDS
