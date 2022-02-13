;Implementation notes
    ;Priority is hard to support on DMG, but easy on GBC
    ;The most viable way is frame by frame sprite priority assignment
    ;For this to work, we need a buffer of 7 pixels between prio and non-prio
    ;Code in game will have to be written to handle this every frame
    ;A 3:4 division is what comes to mind at first.
    ;But that isn't here

.include "mapDef.asm"   ;<--- LOOK HERE FOR DATA EXPLANATIONS!!

.include "macros.asm"


.SECTION "Maps" FREE

MapBackBase:
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
.db 1           ;background type
.dw MapForestN23map
.dw MapForestN23obj
.db   0 +8,   0 +16     ;right side start
.db   0 +8,   0 +16     ;up side start
.db   0 +8,   0 +16     ;left side start
.db  56 +8, 127 +16     ;down side start
.dw Cs_NarumiFightStart
MapForestN13:
.db 0
.dw MapForestN13map
.dw MapForestN13obj
.db   0 +8,   0 +16     ;-25 on X
.db  48 +8,  35 +16     ; 25 on Y
.db   0 +8,   0 +16     ; 25 on X
.db  48 +8,  71 +16     ;-25 on Y
.dw Cs_StraightTransition
MapForest00:
.db 2
.dw MapForest00map
.dw MapForest00obj
.db 135 +8, 114 +16
.db   0 +8,   0 +16
.db 106 +8, 115 +16
.db 116 +8, 119 +16
.dw Cs_Forest00
MapForest01:
.db 3
.dw MapForest01map
.dw MapForest01obj
.db 199 +8, 108 +16
.db   0 +8,   0 +16
.db   0 +8,   0 +16
.db 137 +8, 147 +16
.dw Cs_Forest01
MapForest02:
.db 0
.dw MapForest02map
.dw MapForest02obj
.db   0 +8,   0 +16
.db  69 +8,  19 +16
.db   0 +8,   0 +16
.db  64 +8, -14 +16
.dw Cs_EndingAC
MapForest03:
.db 0
.dw MapForest03map
.dw MapForest03obj
.db 209 +8, 116 +16
.db 104 +8,  19 +16
.db   0 +8,   0 +16
.db 131 +8, 209 +16
.dw Cs_StraightTransition
MapForest04:
.db 3
.dw MapForest04map
.dw MapForest04obj
.db   0 +8,   0 +16
.db   0 +8,   0 +16
.db  15 +8,  70 +16
.db  64 +8, 153 +16
.dw Cs_Forest04
MapForest10:
.db 1
.dw MapForest10map
.dw MapForest10obj
.db   0 +8,   0 +16
.db   0 +8,   0 +16
.db   0 +8,   0 +16
.db  40 +8, 129 +16
.dw Cs_StraightTransition
MapForest11:
.db 1
.dw MapForest11map
.dw MapForest11obj
.db 145 +8, 114 +16
.db 114 +8,  15 +16
.db   0 +8,   0 +16
.db 125 +8, 193 +16
.dw Cs_Forest11
MapForest12:
.db 1
.dw MapForest12map
.dw MapForest12obj
.db 225 +8,  68 +16
.db 123 +8,  15 +16
.db  15 +8,  74 +16
.db   0 +8,   0 +16
.dw Cs_StraightTransition
MapForest13:
.db 0
.dw MapForest13map
.dw MapForest13obj
.db 225 +8,  99 +16
.db 124 +8,  15 +16
.db  15 +8, 109 +16
.db 126 +8, 225 +16
.dw Cs_StraightTransition
MapForest14:
.db 2
.dw MapForest14map
.dw MapForest14obj
.db   0 +8,   0 +16
.db  96 +8,  15 +16
.db   0 +8,   0 +16
.db  69 +8, 137 +16
.dw Cs_StraightTransition
MapForest20:
.db 1
.dw MapForest20map
.dw MapForest20obj
.db   0 +8,   0 +16
.db   0 +8,   0 +16
.db   0 +8,   0 +16
.db  40 +8, 129 +16
.dw Cs_StraightTransition
MapForest21:
.db 0
.dw MapForest21map
.dw MapForest21obj
.db 145 +8,  29 +16
.db  95 +8,  15 +16
.db   0 +8,   0 +16
.db   0 +8,   0 +16
.dw Cs_StraightTransition
MapForest22:
.db 0
.dw MapForest22map
.dw MapForest22obj
.db 177 +8, 116 +16
.db 156 +8,  15 +16
.db  15 +8, 115 +16
.db   0 +8,   0 +16
.dw Cs_StraightTransition
MapForest23:
.db 2
.dw MapForest23map
.dw MapForest23obj
.db   0 +8,   0 +16
.db  88 +8,  15 +16
.db  15 +8, 105 +16
.db 100 +8, 129 +16
.dw Cs_StraightTransition
MapForest24:
.db 2
.dw MapForest24map
.dw MapForest24obj
.db   0 +8,   0 +16
.db 204 +8,  15 +16
.db  15 +8, 125 +16
.db   0 +8,   0 +16
.dw Cs_Forest24
MapForest30:
.db 1
.dw MapForest30map
.dw MapForest30obj
.db   0 +8,   0 +16
.db   0 +8,   0 +16
.db   0 +8,   0 +16
.db  70 +8, 129 +16
.dw Cs_Forest30
MapForest31:
.db 0
.dw MapForest31map
.dw MapForest31obj
.db 145 +8,  49 +16
.db   0 +8,   0 +16
.db  90 +8,  28 +16
.db   0 +8,   0 +16
.dw Cs_Forest31
MapForest32:
.db 1
.dw MapForest32map
.dw MapForest32obj
.db 145 +8,  72 +16
.db  84 +8,  19 +16
.db  15 +8,  72 +16
.db   0 +8,   0 +16
.dw Cs_StraightTransition
MapForest33:
.db 0
.dw MapForest33map
.dw MapForest33obj
.db 145 +8,  63 +16
.db 104 +8,  15 +16
.db  15 +8, 111 +16
.db 135 +8, 193 +16
.dw Cs_StraightTransition
MapForest34:
.db 0
.dw MapForest34map
.dw MapForest34obj
.db   0 +8,   0 +16
.db 128 +8,  16 +16
.db  15 +8,  65 +16
.db   0 +8,   0 +16
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

MapForestEndBmap:
.incbin "rsc/EndingB.gbm"

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
