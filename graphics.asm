;Graphics storage

.SECTION "Tiledata" FREE
Tiledata:
.incbin "TileData.lzc"
.ENDS

.SECTION "Facedata" FREE
FacesList:
 .dw Alice1,  Alice2,  Alice1,  Alice1
 .dw Marisa1, Marisa2, Marisa1, Marisa1
 .dw Reimu1
Alice1:
.incbin "Faces/Alice1.lzc"
Alice2:
.incbin "Faces/Alice2.lzc"
Marisa1:
.incbin "Faces/Marisa1.lzc"
Marisa2:
.incbin "Faces/Marisa2.lzc"
Reimu1:
.incbin "Faces/Reimu1.lzc"
.ENDS

;Note on list:
;Alice Smile
;Alice Concern
;Alice Angry
;Alice Sleeping
;^ matches Faces line 2/
;Reimu Neutral
;Reimu Talk
;Reimu Unamused
;Reimu Angry
;^ matches Faces line 1/
;Null x8
;^ expected 8 null
;Marisa Yukkuri
;Marisa Smug (most; missing top layer)
;Marisa Worried
;Marisa Zoned out
;^ matches Faces line 4/
;Null x12
;^ expected Marisa 2
;Reimu etc...
;(lol task overflow kills faceload)