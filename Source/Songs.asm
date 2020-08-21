;Songs file
;See game engine file for formats.



.SECTION "nullsong" FREE
SongNull:
.incbin "rsc\NULL.mcs"
.ENDS

.SECTION "song_spark" FREE
SongSpark:
 .incbin "rsc\Spark2.mcs"
.ENDS

.SECTION "notepitches" ALIGN $100 FREE
;Channel pitches
Channel1Pitch:
Channel2Pitch:
;Octaves 3 - 8 available
 .dw $FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF    ;These notes are too low to input
Channel3Pitch:
;Octaves 2 - 7 available
 .dw $FFF,$FFF,$FFF,  44, 157, 263, 363, 457, 547, 631, 711, 786
 .dw  856, 923, 986,1046,1102,1155,1205,1253,1297,1339,1379,1417 
 .dw 1452,1486,1517,1547,1575,1602,1627,1650,1673,1694,1714,1732
 .dw 1750,1767,1783,1798,1812,1825,1837,1849,1860,1871,1881,1890
 .dw 1899,1907,1915,1923,1930,1936,1943,1949,1954,1959,1964,1969
 .dw 1974,1978,1982,1985,1989,1992,1995,1998,2001,2004,2006,2009    ;It starts being grossly inaccurate
 .dw 2011,2013,2015,2017,2018,2020,2022,2023,2025,2026,2027,2028
;Channel 3 octave 8 (do not use)
 .dw 2029,2030,2031,2032,2033,2034,2035,2036,2036,2037,2038,2038
Channel4Pitch:
;Octaves 2 - 6, following special format
;The high-order byte is the associated envelope
 ;      A           B     C           D           E     F           G
 .dw $F173,$4934,$8134,$7101,$3511,$9351,$1E51,$7425,$8A25,$8124,$BA23,$F251
 .dw $00FF,$00FF,$4921,$00FF,$00FF,$D351,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF
 .dw $00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF
 .dw $00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF
 .dw $00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF
Channel4Stacatto:
;Associated Stacatto data
 .db $1D,  $00,  $02,  $1F,  $00,  $04,  $00,  $00,  $00,  $30,  $00,  $04
 .db $FF,  $FF,  $00,  $FF,  $FF,  $04,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF
 .db $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF
 .db $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF
 .db $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF,  $FF
;Format:
;Octave 2: usual percussion. Always available
    ;A: Bass drum
    ;B-: Snare drum roll crescendo
    ;B: Snare drum
    ;C: Hi hat (closed)
    ;C+: Hi hat (open)
    ;D: Elec. snare
    ;D+: Elec. snare roll crescendo
    ;E: Crash cymbal
    ;F: Mid tom
    ;G: Hi tom
    ;G+: Elec. snare loudest
;Octave 3: Rolls, rides, and runs
    ;A
    ;B: Snare roll crescendo
    ;C
    ;D: Elec. Snare (mid-loud)
    ;E
    ;F
    ;G
;Channel 3 voices
;Wave:
; .include "Voicelist.asm"
.ENDS
