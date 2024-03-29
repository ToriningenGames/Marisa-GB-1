;Proper LZ extraction tool for Graphics
    ;Extracts tile data for Backgrounds, Text, Sprites, and Faces
        ;Compressed, it takes up less space, but we need an algorithm for our needs
            ;Huffman is already implemented, though it's slow
            ;LZ always looks attractive, but weak.
                ;LZ backref window size needs to be 256 or 512
                    ;256 is really easy, kinda looks like delta encoding here
                    ;512 matches Huffman data footprint, best opportunity for copy
            ;Profiling is now needed
                ;Profile for decompression time, decompression space,
                    ;and compressed size!
            ;Haven't we already implemented LZ for maps?
                ;Poorly named. It's just a backreference
            ;This looks better if the window is only 256, and especially if it
                ;can be started in the middle!
            ;A dictionary & window reset at each character is sensible.
        ;Try to avoid extracting at $D200; map updates and text at the same time
        ;could be useful.
        ;This precludes using the same code for extraction... almost.
;Googled. Sliding window is LZ77. LZ78 is dictionary.
    ;Found LZO. Looks akin to what I'm doing. Also open-source.
;LZO is hell to read. In any case, it's akin to what's already in Maps.asm
    ;Maps.asm's LZ77 encoding:
        ;10 bit backreference
            ;0 is a valid value, and is used for skipping output bytes.
            ;An implementation that supports Maps would need to account.
        ;8 bit length (0 is 256)
        ;Current implementation: 27 bytes
    ;Generalized:
        ;16 bit backreference
            ;Big endian due to Maps.asm's format
        ;8 bit length

.STRUCT ExtractSave
 data_source    dw
 command_source dw
 data_dest      dw
.ENDST
.DEFINE ExtractSaveSize _sizeof_ExtractSave

.EXPORT ExtractSaveSize


.SECTION "Decompress" FREE

LZDecode:
;HL= Dest
;DE= Source
;A = High byte of backreference

;Returns
;HL= Updated dest
;DE= Updated source

;Stats:
    ;Byte size:       24
    ;Minimum runtime: 184   for   1 byte
    ;Maximum runtime: 10384 for 256 bytes
        ;Byte cost: 40 cycles

  CPL
  LD B,A
  LD A,(DE)
  INC DE
  CPL
  LD C,A
  INC DE
  PUSH HL
  ADD HL,BC
  POP BC
  LD A,(DE)
  INC DE
  PUSH DE
  LD E,A
--
  LDI A,(HL)
  LD (BC),A
  INC BC
  DEC E
  JR nz,--
  POP DE
  LD H,B
  LD L,C
  RET

;For mixed literal and LZ streams
;We need some way to specify how much data to extract
    ;Also some way to deal if it's mid LZ
    ;Overrun to next page; copy over
    ;Spill data and restore state
ExtractSpec:
;HL->Source datastream
;DE->Destination datastream
;(SP)->Save location
;Extracts (up to) 256 bytes from source to dest, stopping on page boundry
;Once finished, saves state at the location pointed to on the stack pointer
;Can extract another 256 bytes by calling ExtractRestore with that value
;Will advance to subsequent pages!
  LD B,0
  LDI A,(HL)
  ADD $80
  JR c,+
;LZ
  AND $7F
  LD C,A
  LDI A,(HL)
  PUSH HL
  LD H,(HL)     ;Negate for backreference
  CPL
  ADD 1         ;We add 1 to HL like this, as opposed to an increment afterwards
  LD L,A        ;because backreferences between $100 and $1FF increment $FExx
  LD A,C        ;values, and doing that trashes OAM... sometimes
  LD C,H
  CPL
  ADC 0
  LD H,A
  ADD HL,DE
  JR __loop
+
;Literal
  ADD L     ;Setup for HL restore value
  LD C,A    ;Since it's expected to pop HL-1 off the stack after run
  LD A,B
  ADC H
  LD B,A
  DEC BC
  PUSH BC
  LD A,C
  INC A
  SUB L
  LD C,A
__loop
  LDI A,(HL)
  LD (DE),A
  INC E
  JR z,__End
__res:
  DEC C
  JR nz,__loop
  POP HL
  INC HL
  JR ExtractSpec
__End:   ;Save extraction state for future use
  INC D
  LD E,C
  LD C,L
  LD B,H
  LD HL,SP+4    ;HL,IP,goal
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  LD A,C
  LDI (HL),A
  LD A,B
  LDI (HL),A
  POP BC
  LD A,C
  LDI (HL),A
  LD A,B
  LDI (HL),A
  LD A,E
  LDI (HL),A
  LD (HL),D
  RET
;State order:
    ;HL,SV,DE
ExtractRestoreSP:
;(SP)->Extraction state
  LD HL,SP+2
  LDI A,(HL)
  LD H,(HL)
  LD L,A
ExtractRestoreHL:
;HL->Extraction state
  LDI A,(HL)
  LD C,A
  LDI A,(HL)
  LD B,A
  LDI A,(HL)
  LD E,A
  LDI A,(HL)
  LD D,A
  PUSH DE
  LDI A,(HL)
  LD E,A
  LD D,(HL)
  LD L,C
  LD H,B
  LD C,E
  LD E,0
  JR __res
.ENDS
