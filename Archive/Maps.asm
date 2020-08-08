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


.DEFINE MapArea $C400
.DEFINE PriArea $C800
.DEFINE ColArea $C880
.DEFINE VisArea $C900
.DEFINE MapTemp $D200
.DEFINE MapBasePort $88
.ENUM $C980 ;MapInfo
    hotMap      DB  ;Zero if LoadMap is running
    mapExtract  DS 6;ExtractSaveSize
.ENDE

.EXPORT MapArea
.EXPORT PriArea
.EXPORT ColArea
.EXPORT VisArea
.EXPORT hotMap

.include "macros.asm"

.SECTION "Map support" FREE

;DE->map data
;Loads map to RAM, sets hotMap upon copying visuals
;Starts by loading to a scratch area over Huffman data in its native size
;Then, copies over to the shadow map, converting to a 32x32 map
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
  JP EndTask
  
  LD HL,MapTemp
  LD A,$FF  ;Sentry clear value
  CALL ClearMapData
  CALL HaltTask
  CALL LoadMapData
;Temporary map loaded; copy to RAM map
  LD HL,hotMap
  LD (HL),$01
  CALL HaltTask
  LD A,$FF  ;Skip $FFs first time, $00s second
  DEC DE
  LD A,(DE)
  DEC DE
  LD B,A
  LD A,(DE)
  INC DE
  INC DE
  PUSH DE
  LD C,A
  LD DE,MapArea
  LD HL,MapTemp
  CALL CopySubArr
  POP DE
  CALL HaltTask
;Second time, to catch $FFs missed first time 'round
  XOR A
  CALL ClearMapData
  CALL HaltTask
  CALL LoadMapData
  LD HL,hotMap
  LD (HL),H
  CALL HaltTask
  XOR A     ;Skip $FFs first time, $00s second
  DEC DE
  LD A,(DE)
  DEC DE
  LD B,A
  LD A,(DE)
  INC DE
  INC DE
  PUSH DE
  LD C,A
  LD DE,MapArea
  LD HL,MapTemp
  CALL CopySubArr
;Visuals done
  POP DE
  LD HL,hotMap
  LD A,%00000010
  OR (HL)
  LD (HL),A
  CALL HaltTask
;Attributes
  XOR A
  CALL ClearMapData
  CALL HaltTask
  CALL LoadAttrData
;Attributes ready to transfer
;Transfer each bit if set in corresponding activation array
  LD HL,MapTemp-1
  DEC DE
  LD A,(DE)
  LD B,A
  DEC DE
  LD A,(DE)
  LD C,A
  PUSH BC
;Expand map! (back to front)
  CALL Multiply
  ADD HL,BC
  LD DE,MapTemp+$03FF
  POP BC
  LD A,32
  SUB B
  JR z,+    ;If map is already 32 x 32, no need to expand
  LD C,A
--
  PUSH BC
  XOR A
-
  LD (DE),A
  DEC DE
  DEC C
  JR nz,-
-
  LDD A,(HL)
  LD (DE),A
  DEC DE
  DEC B
  JR nz,-
  POP BC
  LD A,>(MapTemp-1)
  CP H
  JR nz,--
  INC HL
;Copy from one array to three, taking into account masks
+
  CALL HaltTask
  LD DE,PriArea
  LD HL,MapTemp-1
;Priority
--
  LD C,9
  LD A,(DE)
-
  RLA
  DEC C
  JR z,+
  INC HL
  BIT 6,(HL)
  JR z,-
  SCF
  BIT 2,(HL)
  JR nz,-
  CCF
  JR -
+
  LD (DE),A
  INC E
  BIT 7,E
  JR z,--
  CALL HaltTask
  LD HL,MapTemp-1
;Collision
--
  LD C,9
  LD A,(DE)
-
  RLA
  DEC C
  JR z,+
  INC HL
  BIT 5,(HL)
  JR z,-
  SCF
  BIT 1,(HL)
  JR nz,-
  CCF
  JR -
+
  LD (DE),A
  INC E
  BIT 7,E
  JR nz,--
  INC D
  CALL HaltTask
  LD HL,MapTemp-1
;Visibility
--
  LD C,9
  LD A,(DE)
-
  RLA
  DEC C
  JR z,+
  INC HL
  BIT 4,(HL)
  JR z,-
  SCF
  BIT 0,(HL)
  JR nz,-
  CCF
  JR -
+
  LD (DE),A
  INC E
  BIT 7,E
  JR z,--
;Finished!
  JP EndTask

;Copy a BxC map into a 32x32 space, ignoring any tiles with A's value
;Copies from HL to DE
CopySubArr:
  PUSH BC
  PUSH AF
  JR +
-
  PUSH BC
  PUSH AF
  LD A,32
  SUB B
  ADD E
  LD E,A
  LD A,D
  ADC 0
  LD D,A
--
  POP AF
  PUSH AF
+
  CP (HL)
  LDI A,(HL)
  JR z,+
  LD (DE),A
+
  INC DE
  DEC B
  JR nz,--
  POP AF
  POP BC
  DEC C
  JR nz,-
  RET

ClearMapData:
  LD B,0
-
  LDI (HL),A
  LDI (HL),A
  LDI (HL),A
  LDI (HL),A
  DEC B
  JR nz,-
  RET

LoadMapData:
  PUSH DE
  LD HL,MapTemp ;Only visuals!
-
  LD A,(DE)
  INC DE
  BIT 0,A
  JR z,+
  ;Tile
  SWAP A    ;Tile part
  AND $0F
  LD (HL),A
  LDH A,(MapBasePort)   ;Base
  ADD (HL)  ;This is how they combine into a valid tile
  LDI (HL),A
  JR -
+ ;Nontile
  BIT 1,A
  JR nz,+
  ;Base change
  LDH (MapBasePort),A
  JR -
+ ;LZ or attribute (or done)
  CP $16    ;Done processing
  JR z,++
  ;LZ or attribute
  BIT 3,A
  JR nz,-
  ;LZ
;  RLCA
;  RLCA
;  AND $03
  CALL LZDecode
  JR -
+ ;Attribute
  BIT 4,A
  JR z,-
  ;Set attributes
  INC HL
  JR -
++
  POP DE
  RET

LoadAttrData:
  PUSH DE
;We can do all 3 maps simultaneously without fuss, if we can read and write...
        ;...bitsteams.
;Ow. no. How about, one bit per nibble, then an activation array afterwards
;Interleaved. That way, addresses accurately point at both
  LD HL,MapTemp
-
  LD A,(DE)
  INC DE
  BIT 0,A
  JR z,+
  ;Tile
  LD (HL),$70   ;Affect everything
  AND $E0
  RRCA
  JR +++        ;Use A like an attribute set
+ ;Nontile
  BIT 1,A
  JR z,-    ;Base change
+ ;LZ or attribute (or done)
  CP $16    ;Done processing
  JR z,++
  ;LZ or attribute
  BIT 3,A
  JR nz,+
  ;LZ
;  RLCA
;  RLCA
;  AND $03
  CALL LZDecode
  JR -
+ ;Attribute
  BIT 4,A
  JR nz,+
  ;Set affects
  AND $E0
  RRCA
  LDH (MapBasePort),A
  JR -
+
  ;Set attributes
  ;Check for what we're actually setting
  LD B,A
  LDH A,(MapBasePort)
  LD (HL),A
  RRC B
  AND B
+++
  SWAP A
  OR (HL)
  LDI (HL),A
  JR -
++
  POP DE
  RET

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
  LD (HL),H
  JP EndTask

;A = $38 if mapdata==$9800, $40 if mapdata==$9C00
;Places map on screen
;ShowMap_Task:
  LD B,A    ;Save for later
  LD C,8    ;No. of times we need to transfer
-
  TaskWaitForZero OpControl, 7
  LD HL,TileDataBuffer
  LD A,L
  LD (HL),16    ;Counter
  INC L
  INC L
  LD A,<(((>(MapArea))*2)+8)
  SUB C     ;Src and Dst addresses increment by $80 each iteration,
  SCF       ;Deducible via taking the end, and subtracting C in fixed point
  RRA
  LDD (HL),A    ;Src hi
  RRA
  AND $80
  LDI (HL),A    ;Src lo
  INC L
  INC L
  LD A,B    ;Destination address is variable, multiples of $80 per iteration
  SUB C
  SCF
  RRA
  LDD (HL),A    ;Dst hi
  RRA
  AND $80
  LD (HL),A     ;Dst lo
  LD HL,OpControl
  SET 7,(HL)    ;Enable the vBlank transfer
  DEC C
  JR nz,-
  JP EndTask
;
;New show map?
ShowMap_Task:
;D = High byte of source
;E = High byte of destination
  LD A,4
-
  TaskWaitForZero OpControl, 7
  LD HL,TileDataBuffer
  LD (HL),$10
  INC L
  LD (HL),$00
  INC L
  LD (HL),D
  INC L
  LD (HL),$00
  INC L
  LD (HL),E
  LD HL,OpControl
  SET 7,(HL)
  TaskWaitForZero OpControl, 7
  LD HL,TileDataBuffer
  LD (HL),$10
  INC L
  LD (HL),$80
  INC L
  LD (HL),D
  INC L
  LD (HL),$80
  INC L
  LD (HL),E
  LD HL,OpControl
  SET 7,(HL)
  INC D
  INC E
  DEC A
  JR nz,-
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
