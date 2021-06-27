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

MapBackBase:
.dw MapForestBKG01,MapForestBKG02,MapForestBKG03,MapForestBKG04

MapForestN23:
.db 2           ;background type
.dw MapForestN23map
.dw MapForestN23obj
.db 0,  0       ;right side start
.db 0,  0       ;up side start
.db 0,  0       ;left side start
.db 56, 152     ;down side start
.dw Cs_StraightTransition
MapForestN13:
.db 0
.dw MapForestN13map
.dw MapForestN13obj
.db 0,  0
.db 48, 10
.db 0,  0
.db 48, 96
.dw Cs_StraightTransition
MapForest00:
.db 4
.dw MapForest00map
.dw MapForest00obj
.db 160,114
.db 0,  0
.db 81, 115
.db 116,144
.dw Cs_StraightTransition
MapForest01:
.db 6
.dw MapForest01map
.dw MapForest01obj
.db 224,108
.db 0,  0
.db 0,  0
.db 137,172
.dw Cs_StraightTransition       ;Edit
MapForest02:
.db 0
.dw MapForest02map
.dw MapForest02obj
.db 0,  0
.db 74, 250
.db 0,  0
.db 68, 10
.dw Cs_StraightTransition
MapForest03:
.db 0
.dw MapForest03map
.dw MapForest03obj
.db 234,116
.db 104,250
.db 0,  0
.db 131,234
.dw Cs_StraightTransition
MapForest04:
.db 6
.dw MapForest04map
.dw MapForest04obj
.db 0,  0
.db 0,  0
.db 245,70
.db 64, 178
.dw Cs_StraightTransition
MapForest10:
.db 2
.dw MapForest10map
.dw MapForest10obj
.db 0,  0
.db 0,  0
.db 0,  0
.db 40, 154
.dw Cs_StraightTransition
MapForest11:
.db 2
.dw MapForest11map
.dw MapForest11obj
.db 170,114
.db 114,-10
.db 0,  0
.db 125,218
.dw Cs_StraightTransition
MapForest12:
.db 2
.dw MapForest12map
.dw MapForest12obj
.db 250,68
.db 123,-10
.db -10,74
.db 0,  0
.dw Cs_StraightTransition
MapForest13:
.db 0
.dw MapForest13map
.dw MapForest13obj
.db 250,99
.db 124,-10
.db -10,109
.db 126,250
.dw Cs_StraightTransition
MapForest14:
.db 4
.dw MapForest14map
.dw MapForest14obj
.db 0,  0
.db 96,-10
.db 0,  0
.db 69,162
.dw Cs_StraightTransition
MapForest20:
.db 2
.dw MapForest20map
.dw MapForest20obj
.db 0,  0
.db 0,  0
.db 0,  0
.db 40, 154
.dw Cs_StraightTransition
MapForest21:
.db 0
.dw MapForest21map
.dw MapForest21obj
.db 170,29
.db 95, -10
.db 0,  0
.db 0,  0
.dw Cs_StraightTransition
MapForest22:
.db 0
.dw MapForest22map
.dw MapForest22obj
.db 202,116
.db 156,-10
.db -10,115
.db 0,  0
.dw Cs_StraightTransition
MapForest23:
.db 4
.dw MapForest23map
.dw MapForest23obj
.db 0,  0
.db 88, -10
.db -10,105
.db 100,154
.dw Cs_StraightTransition
MapForest24:
.db 4
.dw MapForest24map
.dw MapForest24obj
.db 0,  0
.db 204,-10
.db 0,  0
.db -10,125
.dw Cs_StraightTransition
MapForest30:
.db 2
.dw MapForest30map
.dw MapForest30obj
.db 0,  0
.db 0,  0
.db 0,  0
.db 70, 154
.dw Cs_StraightTransition
MapForest31:
.db 0
.dw MapForest31map
.dw MapForest31obj
.db 170,49
.db 83, 0
.db 0,  0
.db 0,  0
.dw Cs_StraightTransition
MapForest32:
.db 2
.dw MapForest32map
.dw MapForest32obj
.db 170,72
.db 84, -6
.db -10,72
.db 0,  0
.dw Cs_StraightTransition
MapForest33:
.db 0
.dw MapForest33map
.dw MapForest33obj
.db 170,63
.db 104,-10
.db -10,111
.db 135,218
.dw Cs_StraightTransition
MapForest34:
.db 0
.dw MapForest34map
.dw MapForest34obj
.db 0,  0
.db 128,-9
.db -10,65
.db 0,  0
.dw Cs_StraightTransition

MapForestN23map:
.incbin "rsc/Forest_(-2~3).gbm"
MapForestN13map:
.incbin "rsc/Forest_(-1~3).gbm"
MapForest00map:
.incbin "rsc/Forest_(0~0).gbm"
MapForest01map:
MapForest04map:
.incbin "rsc/Forest_(0~4).gbm"
MapForest02map:
.incbin "rsc/Forest_(0~2).gbm"
MapForest03map:
.incbin "rsc/Forest_(0~3).gbm"
MapForest10map:
MapForest20map:
.incbin "rsc/Forest_(1~0).gbm"
MapForest11map:
.incbin "rsc/Forest_(1~1).gbm"
MapForest12map:
.incbin "rsc/Forest_(1~2).gbm"
MapForest13map:
.incbin "rsc/Forest_(1~3).gbm"
MapForest14map:
.incbin "rsc/Forest_(1~4).gbm"
MapForest21map:
.incbin "rsc/Forest_(2~1).gbm"
MapForest22map:
.incbin "rsc/Forest_(2~2).gbm"
MapForest23map:
.incbin "rsc/Forest_(2~3).gbm"
MapForest24map:
.incbin "rsc/Forest_(2~4).gbm"
MapForest30map:
.incbin "rsc/Forest_(3~0).gbm"
MapForest31map:
.incbin "rsc/Forest_(3~1).gbm"
MapForest32map:
.incbin "rsc/Forest_(3~2).gbm"
MapForest33map:
.incbin "rsc/Forest_(3~3).gbm"
MapForest34map:
.incbin "rsc/Forest_(3~4).gbm"

MapForestN23obj:
.dw 0               ;left
.dw MapForestN13    ;down
.dw 0               ;right
.dw 0               ;up
MapForestN13obj:
.dw 0               ;left
.dw MapForest03     ;down
.dw 0               ;right
.dw MapForestN23    ;up
MapForest00obj:
.dw 0               ;left
.dw 0               ;down
.dw MapForest01     ;right
.dw 0               ;up
MapForest01obj:
.dw 0               ;left
.dw MapForest00     ;down
.dw MapForest11     ;right
.dw 0               ;up
MapForest02obj:
.dw 0               ;left
.dw MapForest12     ;down
.dw 0               ;right
.dw MapForest24     ;up
MapForest03obj:
.dw 0               ;left
.dw MapForest13     ;down
.dw MapForest04     ;right
.dw MapForestN13    ;up
MapForest04obj:
.dw MapForest03     ;left
.dw MapForest14     ;down
.dw 0               ;right
.dw MapForest31     ;up
MapForest10obj:
.dw 0               ;left
.dw 0               ;down
.dw 0               ;right
.dw MapForest00     ;up
MapForest11obj:
.dw 0               ;left
.dw MapForest21     ;down
.dw MapForest12     ;right
.dw MapForest01     ;up
MapForest12obj:
.dw MapForest11     ;left
.dw 0               ;down
.dw MapForest13     ;right
.dw MapForest02     ;up
MapForest13obj:
.dw MapForest12     ;left
.dw MapForest23     ;down
.dw 0               ;right
.dw MapForest03     ;up
MapForest14obj:
.dw MapForest13     ;left
.dw MapForest24     ;down
.dw 0               ;right
.dw MapForest04     ;up
MapForest20obj:
.dw 0               ;left
.dw 0               ;down
.dw 0               ;right
.dw MapForest10     ;up
MapForest21obj:
.dw 0               ;left
.dw 0               ;down
.dw MapForest22     ;right
.dw MapForest11     ;up
MapForest22obj:
.dw MapForest21     ;left
.dw MapForest32     ;down
.dw MapForest23     ;right
.dw MapForest30     ;up
MapForest23obj:
.dw MapForest22     ;left
.dw MapForest33     ;down
.dw 0               ;right
.dw MapForest13     ;up
MapForest24obj:
.dw MapForest02     ;left
.dw 0               ;down
.dw 0               ;right
.dw MapForest14     ;up
MapForest30obj:
.dw 0               ;left
.dw MapForest22     ;down
.dw 0               ;right
.dw MapForest20     ;up
MapForest31obj:
.dw 0               ;left
.dw 0               ;down
.dw MapForest32     ;right
.dw 0               ;up
MapForest32obj:
.dw MapForest31     ;left
.dw 0               ;down
.dw MapForest33     ;right
.dw 0               ;up
MapForest33obj:
.dw MapForest32     ;left
.dw MapForest34     ;down
.dw MapForest34     ;right
.dw MapForest23     ;up
MapForest34obj:
.dw MapForest33     ;left
.dw 0               ;down
.dw MapForest00     ;right
.dw MapForest33     ;up

.ENDS
