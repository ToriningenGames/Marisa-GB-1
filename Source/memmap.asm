.IFNDEF MEM_MAP
.DEFINE MEM_MAP

;Multiple maps are available for different building purposes.
;Remember to clean between switching maps, or keep them in separate build directories

;Expanded 64KiB memory map
;This map isn't actually supported by the game, and there's no mapper for it.
;It exists for editing the game and allowing WLA to give you statistics even when you're over size
;This gives you an idea how overweight the game is, and how much to trim by.
;Merely looking at how much free space won't give you the right statistic;
;check to make sure WLA's verbose output says there's free space starting at $4000
;for each bank.
;It is entirely possible there is enough space, but alignment requirements push over the barrier

.IF defined(FATMAP)

.MEMORYMAP          ;Memory Map (For wla-gb)
SLOTSIZE $8000
DEFAULTSLOT 1
SLOT 0 $0000
SLOT 1 $8000
.ENDME

.ROMBANKMAP         ;ROM Bank Map (no mapping)
BANKSTOTAL 2
BANKSIZE $8000
BANKS 2
.ENDRO

.ELIF defined(ALTMAP)

;Nonstandard 32KiB memory map
;This is completely functional, but allows banks to cross the $4000 mark

.MEMORYMAP          ;Memory Map (For wla-gb)
SLOTSIZE $8000
DEFAULTSLOT 0
SLOT 0 $0000
.ENDME

.ROMBANKMAP         ;ROM Bank Map (no mapping)
BANKSTOTAL 1
BANKSIZE $8000
BANKS 1
.ENDRO

.ELSE

;Standard 32KiB memory map
;This is the regulation way to lay the banks

.MEMORYMAP          ;Memory Map (For wla-gb)
SLOTSIZE $4000
DEFAULTSLOT 1
SLOT 0 $0000
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
