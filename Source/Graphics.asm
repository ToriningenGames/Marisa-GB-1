;Graphics storage

.SECTION "Tiledata" FREE
Tiledata:
.incbin "rsc/TileData.lzc"
.ENDS

.SECTION "Facedata" FREE
FacesList:
 .dw Alice1,  Alice2,  Alice1,  Alice1
 .dw Marisa1, Marisa2, Marisa3, Marisa1
 .dw Reimu1
Alice1:
.incbin "rsc/Alice1.lzc"
Alice2:
.incbin "rsc/Alice2.lzc"
Marisa1:
.incbin "rsc/Marisa1.lzc"
Marisa2:
.incbin "rsc/Marisa2.lzc"
Marisa3:
.incbin "rsc/Marisa3.lzc"
Reimu1:
.incbin "rsc/Reimu1.lzc"
.ENDS

;List
;Alice Smile
;Alice Concern
;Alice Angry
;Alice Sleeping
;Alice Shineless
;Alice Laughing
;Null x10
;Marisa Yukkuri
;Marisa Smug
;Marisa Worried
;Marisa Zoned out
;Marisa Shocked
;Marisa Interested
;Marisa Confused
;Marisa Catlike
;Marisa Tired
;Marisa Displeased
;Marisa Agressive
;Null x5
;Reimu Neutral
;Reimu Interested
;Reimu Unamused
;Reimu Angry
;Null x12

