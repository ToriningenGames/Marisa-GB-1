;Graphics storage

.SECTION "Tiledata" FREE
Tiledata:
.incbin "rsc/TileData.lzc"
.ENDS

.SECTION "Facedata" FREE
FacesList:
 .dw Marisa1, Marisa2, Alice1, Reimu1, Narumi1
Alice1:
.incbin "rsc/Alice1.lzc"
Marisa1:
.incbin "rsc/Marisa1.lzc"
Marisa2:
.incbin "rsc/Marisa2.lzc"
Reimu1:
.incbin "rsc/Reimu1.lzc"
Narumi1:
.incbin "rsc/Narumi1.lzc"
.ENDS

;Face list:
;$00: Marisa Smug
;$01: Marisa Catlike
;$02: Marisa Displeased
;$03: Marisa Interested
;$04: Marisa Shocked
;$05: Marisa Tired
;$06: Marisa Aggressive
;$07: Marisa Worried
;$08: Alice Smile
;$09: Alice Concern
;$0A: Alice Angry
;$0B: Alice Shineless
;$0C: Reimu Pleased
;$0D: Reimu Interested
;$0E: Reimu Neutral
;$0F: Reimu Sick
;$10: Narumi Normal
;$11: Narumi Inquisitive
;$12: Narumi Fired up
;$13: Narumi Dying
