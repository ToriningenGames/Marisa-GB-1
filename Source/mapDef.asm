;Exit Format:
;To be decided...
;Will contain cutscenes, which will contain actor lists
    ;Want/need some way to specify different exits upon loading room


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
.DEFINE ObjArea $D580
.ENUM ObjArea
    exitUpCutscene      DW
    exitDownCutscene    DW
    exitLeftCutscene    DW
    exitRightCutscene   DW
.ENDE
.ENUM $C090 ;MapInfo    (14 bytes max)
    hotMap          DB      ;Zero if LoadMap is running
    mapExtract      DS 6    ;ExtractSaveSize
    mapWidth        DB      ;Width in pixels
    mapHeight       DB      ;Height in pixels
.ENDE

.DEFINE LoadMapMagicVal $D098
.DEFINE LoadWinMagicVal $D09C
