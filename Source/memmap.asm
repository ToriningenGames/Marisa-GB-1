.IFNDEF MEM_MAP
.DEFINE MEM_MAP

;Expanded 64KiB memory map
;This map isn't actually supported by the game, and there's no mapper for it.
;It exists for editing the game and allowing WLA to give you statistics even when you're over size
;This gives you an idea how overweight the game is, and how much to trim by.
;Merely looking at how much free space won't give you the right statistic;
;check to make sure WLA's verbose output says there's free space starting at $4000
;for each bank.
;It is entirely possible there is enough space, but alignment requirements push over the barrier

.IFDEF FATMAP

.MEMORYMAP          ;Memory Map (For wla-gb)
SLOTSIZE $8000
DEFAULTSLOT 1
SLOT 0 $0000    ;ROM banks
SLOT 1 $8000
.ENDME

.ROMBANKMAP         ;ROM Bank Map (no mapping)
BANKSTOTAL 2
BANKSIZE $8000
BANKS 2
.ENDRO

.ELSE

;Standard 32KiB memory map
;This is the only configuration the game supports running

.MEMORYMAP          ;Memory Map (For wla-gb)
SLOTSIZE $4000
DEFAULTSLOT 1
SLOT 0 $0000    ;ROM banks
SLOT 1 $4000
.ENDME

.ROMBANKMAP         ;ROM Bank Map (no mapping)
BANKSTOTAL 2
BANKSIZE $4000
BANKS 2
.ENDRO

.ENDIF

.EMPTYFILL $FF  ;RST $38

.COMPUTEGBCHECKSUM  ;Checksum calculations (perfomed by wla-gb)
.COMPUTEGBCOMPLEMENTCHECK

.ENDIF
