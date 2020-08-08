;Exit Format:
;To be decided...
;Will contain cutscenes, which will contain actor lists


;Map format inspiration:
    ;For a given object, the tiles will be in close proximity to each other
    ;This permits a smaller number encoding the tile, with a base+offset format
    ;Now, if we could get overlays to work, that'd be great.
;Map Design Workflow:
    ;We can use Tiled as our map editor, regardless of the format, as long as we take care of a couple sticking points:
        ;We need a program to take raw tiledata and convert it into an image.
        ;Windows snippet can do this, if we organize the three banks correctly
        ;We need a program to convert from Tiled's XML format to our Gameboy format
        ;There is a convenient looking tiny XML parser on Github (/ooxi/xml.c)
        ;We also need to decide on the format (obviously)

;Despite really wanting it, an object based approach doesn't seem to be the best
;for the types of maps we want to create.
    ;When we boil it down, there's only really, what, four types of terrain we want?
        ;Trees
        ;Ground
        ;Holes
        ;Decorations
;Deciding on what goes in the format hasn't been that contentious.
;It how to get it to take up less space that's been the source of argument.
    ;How much map do we want to have?
    ;8 x 8 32x32 maps
    ;That is, 65536 tiles (!)
    ;Uncompressed, that is 81920 bytes
    ;Obviously insane. Compression is needed
        ;The types of compression that would work well for bitmaps and tilemaps
        ;are different.
        ;Run-length encoding can work well for bitmaps if bits run more than 8.
        ;RLE would be even better if we picked a bitwidth fitting of the data
        ;Hence, 4 bit RLE for collision/priority data
    ;Actual tiledata:
        ;Though maps may use as many as 256 tiles, an individual item (tree, log, etc.)
        ;is only going to use, what, 8? Let's say 16 tiles.
        ;Thus, any thing's object data can have a base tile, with 4 bit offsets

;...I still want an object based design, simply because it will make some effects
    ;easier and lends itself well to intuition.

        ;With this 4 bit representation, the other 4 bits can represent collsion,
        ;visibility, priority, and something else. A special code could indicate
        ;control information, like "Skip", "Done", "Change base", etc.
;Representation:
    ;%TTTTPCV1
    ; |||||||+--- 1 if this byte is a tile
    ; ||||||+---- Visibility bit. Enemies can't see through this tile
    ; |||||+----- Collision bit. Objects can't pass through this tile
    ; ||||+------ Priority bit. Tile comes in front of objects
    ; ++++------- Tile offset. Offset from base this tile index is

    ;Bit 0 always follows as above

    ;(Ugh. Gotta access the entire range of tiles)

    ;Change base value:
    ;%TTTTTT00
    ;This sets the base value to this byte's value.

    ;Repeat previous byte(s):
    ;%nn000110 %nnnnnnnn %TTTTTTTT
    ;Go back n bytes and copy T bytes to current position
        ;Setting n to 0 allows to 'skip' tiles

    ;Skip byte, setting attributes:
    ;%PCV01110 %PCV11110
    ;Byte 1:
        ;Which of Priority, Collision, or Visibility to affect
    ;Byte 2:
        ;What to set each of the above to

    ;Done processing:
    ;%00010110
    ;Map finished; cease reading bytes

;Header
    ;Data wanted:
        ;Width
        ;Height
        ;Backfill?
        ;Object list
        ;Exit list
    ;Can be added separately from converter
    ;Order?
        ;Exit list
        ;Height
        ;Width  (Only thing required by map loader)
    ;Object list in exits
    ;Pointer is to start of data (after Exit list, Height, and Width)

;Implementation notes
    ;Priority is hard to support on DMG, but easy on GBC
    ;The most viable way is frame by frame sprite priority assignment
    ;For this to work, we need a buffer of 7 pixels between prio and non-prio
    ;Code in game will have to be written to handle this every frame
    ;A 3:4 division is what comes to mind at first.
    ;But that isn't here

;Memory requirements:
    ;1024 bytes for tilemap (persistent)
        ;Persistence waiverable for many frames' time
    ;128 bytes for visibility (persistent)
    ;128 bytes for collsion (persistent)
    ;128 bytes for priority (persistent)
    ;1024 bytes for new map (transient)
    ;128 bytes for affected visibility (transient)
    ;128 bytes for affected collsion (transient)
    ;128 bytes for affected priority (transient)
;2.75kB, 1.375kB persistent

;Reducing RAM requirements:
    ;Text! Textboxes won't be open during a map transition!
    ;If we run over the map twice, we can display $FF tiles.
    ;With this, we can also split VCP data over time, saving space
    ;Ideally, we could split the map in threes


.DEFINE MapArea $D100
.DEFINE PriArea $D500
.DEFINE ColArea $D580
.DEFINE VisArea $D080
.ENUM $D00B ;MapInfo
    hotMap      DB  ;Zero if LoadMap is running
    mapExtract  DS 6;ExtractSaveSize
.ENDE

.DEFINE LoadMapMagicVal $D198
.DEFINE LoadWinMagicVal $D19C

.EXPORT MapArea
.EXPORT PriArea
.EXPORT ColArea
.EXPORT VisArea
.EXPORT hotMap
.EXPORT LoadMapMagicVal
.EXPORT LoadWinMagicVal

.include "macros.asm"

.SECTION "Map support" FREE

;DE->map data
;Loads map to RAM, sets hotMap upon copying visuals
;Overwrites old map in shadow RAM with new one. Does not copy to screen
LoadMap_Task:
  LD HL,hotMap
  LD (HL),0
  LD HL,mapExtract
  PUSH HL
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
  LD HL,hotMap
  LD (HL),$FF
  CALL HaltTask
  PUSH BC
  CALL ExtractRestoreSP ;Attribute data
  POP BC
  JP EndTask

;Sets entire map to tile specified in A
;Sets Priority, Collision, and Visibility to bits 0, 1, and 2 set in B
;Sets hotMap upon finishing
ClearMap_Task:
  LD HL,MapArea
  LD C,0    ;No. of bytes, divided by 4
-
  LDI (HL),A    ;Tiles
  LDI (HL),A
  LDI (HL),A
  LDI (HL),A
  DEC C
  JR nz,-
  LD D,3
--
  XOR A
  RR B
  JR nc,+
  CPL
+   ;Each bitfield, in order
  LD C,$80
-
  LDI (HL),A
  DEC C
  JR nz,-
  DEC D
  JR nz,--
  LD HL,hotMap
  LD (HL),$FF
  JP EndTask
.ENDS

.SECTION "Maps" FREE
;Test map
; .db 32     ;height
; .db 32     ;width
MAP000TEST:
.incbin "Maps/Test.gbm"
; .db 18     ;height
; .db 20     ;width
MAP001DEBUG:
.incbin "Maps/Debug.gbm"
MAP002HALL:
.incbin "Maps/Hall.gbm"
.ENDS
