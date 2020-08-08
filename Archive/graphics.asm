;Graphics storage + use
;Allows for the loading of compressed graphics

;Use LZW compression (original ver.)
;Key size = 12 bits?
;We have about $0E00 space to work with
;Canonical Huffman also looks simple and small (~3 kB)
    ;Problem is that it's a bitstream, which are hard to manipulate
;RLE is a tried-and-true method, good because tile data is highly redundant
    ;PackBits looks like an efficient RLE
;Byte Pair Encoding could work
    ;Only as good as PackBits
;Delta encoding is REALLY fast, but only enables other algorithms

;What do we want?
;We want to encode blocks of 256 bytes into a compressed format
    ;No LZ formats
;These blocks are unrelated to each other
    ;No one static dictionary
;
;
.define entrycount 16
.define entrysize 1
.define state $88
.define dataaddress $D1F0
.define base $D200

.SECTION "Huffman" FREE
;Bitstream methods are only acceptable if we come up with a way to read them
;We did
;Speedhax:
    ;Theorectically, 4 bit decompession can generate 15 bit codes, but
    ;This compression cycle didn't, so we can cheat by only using 8 bits
;

HuffmanReadEntry:
;DE -> bitstream
  LD HL,base
  LDH A,(state)
  LD C,A
-
  ;Get bit
  LD A,C
;HL -> bitstream
;A contains state data
;Bit returned in Carry
;Subsequent bits
  OR A  ;Clear carry, test for 0
  RL A  ;Not RLA, so zero flag is affected
  JR nz,+
;Byte end reached
;First bit in a byte
  SCF   ;Carry == 1 (End of byte marker)
  LD A,(DE)
  RLA
  INC DE
+
  LD C,A
  ;Add bit to tree pointer (inc/add)
  JR nc,+
  INC HL
+
  ;Follow tree pointer (add)
  LD A,(HL)
  ADD L
  LD L,A
  LD A,0
  ADC H
  LD H,A
  ;Check if not done (zero test)
  ;If not done
      ;Repeat
  ;Else, done
      ;Get data and return
  LD A,(HL)
  OR A
  JR nz,-
  INC HL
  LD A,C
  LDH (state),A
  LD A,(HL)
  RET
HuffmanSetStart:
;DE -> Compressed data header
;Copy 16 bytes of DE to RAM
  LD HL,dataaddress
  LD B,16
-
  LD A,(DE)
  INC DE
  LDI (HL),A
  DEC B
  JR nz,-
;Clear bit state
  XOR A
  LDH (state),A
  LD DE,dataaddress
  LD A,2    ;entry accumulator
  LD C,2    ;entry counter
  LD B,2    ;Offset pointer
;Do top level outside of loop, since it's level "0"
  LD (HL),B
  INC B
  INC HL
  LD (HL),B
  INC B
  INC HL
  JR +
--
  POP AF
  ADD A
  LD C,A
  POP DE
+
  PUSH DE
  PUSH AF   ;Save entry accumulator
;Check if there is a code this length
  PUSH BC
  LD C,16   ;Code count
---
  LD A,(DE)
  CP 1
  JR z,+
  INC DE
----
  DEC C
  JR nz,---
  POP BC
;No
-
  LD (HL),B
  INC B
  INC HL
  LD (HL),B
  INC B
  INC HL
  DEC C
  JR nz,-
  JR ++
+
;Yes
;Zero this entry
  XOR A
  LD (DE),A
  INC DE
  LDI (HL),A
  LD A,16
  SUB C
  LD (HL),A
  POP BC
  DEC B ;The relative pointer needs updating
  DEC B
  POP AF
  DEC A ;An entry done; it won't have children
  PUSH AF
  DEC C ;We also did an entry
  JR z,++   ;The last entry might be a code
  PUSH BC
  ;Get the value of C back
  LD A,16
  SUB (HL)
  LD C,A
  INC HL
  JR ----   ;We want the decrement and zero check
;All entries this length done
++
;Check if all codes 0
  POP AF
  POP DE
  PUSH DE
  PUSH AF
  PUSH BC
  LD C,16   ;Code count
-
  LD A,(DE)
  OR A
  JR z,+
  DEC A ;Decrement nonzero codes, so we know which codes belong this time around
  LD (DE),A
+
  INC DE
  OR B    ;Take note of any not 0
  LD B,A
  DEC C
  JR nz,-
  OR B  ;We're done if all codes 0
  POP BC
  JR nz,--
  POP AF
  POP DE
  RET
HuffmanReadBlock:
;DE -> bitstream
;HL -> destination
-
  PUSH HL
  CALL HuffmanReadByte
  POP HL
  LDI (HL),A
  XOR A
  CP L
  JR nz,-
  RET
HuffmanReadByte:
;DE -> bitstream
  CALL HuffmanReadEntry
  LD B,A
  CALL HuffmanReadEntry
  SWAP B
  OR B
  RET
;Old code:

;HuffmanReadEntry:
;;Reading a Huffman entry
;;HL -> bitstream
;  LD BC,0
;---
;  LDH A,(state)
;;HL -> bitstream
;;A contains state data
;;Bit returned in Carry
;;Subsequent bits
;  OR A  ;Clear carry, test for 0
;  RL A  ;Not RLA, so zero flag is affected
;  JR nz,+
;;Byte end reached
;;First bit in a byte
;  SCF   ;Carry == 1 (End of byte marker)
;  LDI A,(HL)
;  RLA
;+
;  LDH (state),A
;  RL C
;  RL B
;  LD DE,base-1
;--
;  INC DE
;-
;  LD A,>baseend
;  CP D
;  JR nz,+
;  LD A,<baseend
;  CP E
;  JR z,---
;+
;  LD A,(DE)
;  INC DE
;  CP C
;  JR nz,--
;  LD A,(DE)
;  INC DE
;  CP B
;  JR nz,-
;  LD A,E
;  RR D
;  RRA
;  DEC A ;DE was pointing to next entry
;;A = this byte
;  RET
;
;;While it works (mostly), it is entirely too slow
;;This is because we keep rereading the data previous for each call
;;We need to not clear state between calls, or...
;;We need a function to call to get 256 bytes at a time, but let it keep advancing
;;Or a much more efficient skip function
;HuffmanSetStart:
;;DE -> compressed data start
;  XOR A
;  LDH (state),A     ;Clear bitstream read state
;;Construct a new table
;;Constructing the Huffman table
;;DE -> compressed data header
;  PUSH DE
;  LD HL,base
;  LD E,L
;  LD D,H
;  XOR A
;  LD B,entrycount
;-
;  LDI (HL),A    ;Clear the bitvalue for all bytes
;  LDI (HL),A
;  DEC B
;  JR nz,-
;  INC A
;  LD C,B
;  POP HL    ;codebook
;  PUSH HL
;;Alignment to accomodate the compare code in the loop
;  PUSH AF
;--
;  POP AF
;;Look for each bit-length, and store the code
;-
;  CP (HL)
;  JR nz,+
;  ;Matching code
;  PUSH AF
;  LD A,C
;  LD (DE),A
;  INC DE
;  LD A,B
;  LD (DE),A
;  DEC DE
;  POP AF
;  INC BC
;+
;  INC DE
;  INC DE
;  INC HL
;  INC HL
;  PUSH AF
;  LD A,H
;  CP >(codebook + entrysize * entrycount)
;  JR nz,--
;  LD A,L
;  CP <(codebook + entrysize * entrycount)
;  JR nz,--
;  POP AF
;;This length done; shift code
;  POP HL    ;codebook
;  PUSH HL
;  LD DE,base
;  INC A
;  SLA C
;  RL B
;;Are we done?
;  JR nc,-
;  POP HL    ;codebook
;  LD BC,entrysize * entrycount
;  ADD HL,BC
;;Store this where ReadBlock will find it
;  LD A,L
;  LD (dataaddress),A
;  LD A,H
;  LD (dataaddress+1),A
;  RET
;HuffmanReadBlock:
;;DE -> destination of data
;  PUSH DE
;  LD DE,dataaddress
;  LD A,(DE)     ;Retrieve compressed data address
;  LD L,A
;  INC E
;  LD A,(DE)
;  LD H,A
;;Actually read this data
;  XOR A
;+
;  LD C,A    ;256 byte counter
;-
;  PUSH BC
;  CALL HuffmanReadEntry
;  POP BC
;  LD B,A
;  PUSH BC
;  CALL HuffmanReadEntry
;  POP BC
;  SWAP B
;  OR B
;;A = recomposed byte
;  POP DE
;  LD (DE),A
;  INC DE
;  PUSH DE
;  DEC C
;  JR nz,-
;  PUSH AF
;  LD A,L
;  LD (dataaddress),A
;  LD A,H
;  LD (dataaddress+1),A
;  POP AF
;  POP DE
;  RET
.ENDS

.SECTION "Tiledata" FREE
Tiledata:
.incbin "TileData.lzc"
.ENDS
