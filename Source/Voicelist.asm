;Voicelist

.SECTION "Voices" ALIGN 16 FREE
Wave:

;First four match the output of channels 1 and 2
;0 Duty 0
.db $00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

;1 Duty 1
.db $00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

;2 Duty 2 (Square)
.db $00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

;3 Duty 3
.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF

;9.4 Saw
.db $00,$11,$22,$33,$44,$55,$66,$77,$88,$99,$AA,$BB,$CC,$DD,$EE,$FF

;19.5 Square and triangle
.db $01,$12,$23,$34,$45,$56,$67,$78,$FE,$ED,$DC,$CB,$BA,$A9,$98,$87

;20.6 Square, triangle, saw
.db $00,$12,$23,$44,$55,$66,$78,$89,$FF,$FE,$EE,$ED,$DD,$DD,$DC,$CC

;21.7 Square, triangle, loud saw
.db $01,$12,$33,$45,$56,$77,$88,$9A,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE

;23.8 Rounded Square
.db $40,$00,$00,$00,$00,$00,$00,$04,$CF,$FF,$FF,$FF,$FF,$FF,$FF,$FC

;24.9 Static
.db $53,$01,$C8,$B8,$97,$9B,$B3,$EF,$2B,$73,$01,$A3,$4C,$47,$8A,$BC

;26.10 Rounded Off-Duty nonsquare
.db $40,$11,$01,$11,$01,$10,$4C,$FE,$EF,$EE,$FE,$FE,$FE,$EF,$EE,$FC

;27.11 Double offset caret (?)
.db $02,$46,$8A,$CE,$FE,$DC,$BA,$98,$76,$54,$32,$10,$03,$57,$75,$30

;30.12 Square, triangle, loud saw (75%)
.db $00,$01,$22,$23,$44,$45,$66,$67,$BA,$BA,$BA,$BA,$BA,$BA,$BA,$BA

;14 Master Spark (plays at 110 Hz. Set NR33/34 to $5AC)
;.db $01,$34,$42,$16,$64,$BF,$EE,$EB,$68,$99,$92,$16,$62,$6B,$66,$42

;31 Other Master Spark. Same pitch
;.db $BE,$EA,$73,$39,$EF,$FF,$FE,$CA,$BD,$DB,$96,$32,$10,$13,$21,$24

.ENDS
