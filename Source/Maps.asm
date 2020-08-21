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

;We use the same compressor for tiledata and map data.
;The reduction in code size makes up for the minor increase in data size
;Because the converter still expects transparent maps, map design has to be thorough

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


.DEFINE MapArea $D000
.DEFINE PriArea $D400
.DEFINE ColArea $D480
.DEFINE VisArea $D500
.ENUM $D500 ;MapInfo
    hotMap      DB  ;Zero if LoadMap is running
    mapExtract  DS 6;ExtractSaveSize
.ENDE

.DEFINE LoadMapMagicVal $D098
.DEFINE LoadWinMagicVal $D09C

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

;General test map
MAP002HALL:
.incbin "rsc/Hall.gbm"

MapForest02:
.incbin "rsc/Forest_20200414_(0~2).gbm"

.ENDS
