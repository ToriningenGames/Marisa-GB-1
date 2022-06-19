;Memory management
    ;Fixed block of 32 bytes each, adjustable at assembly time
    ;Free all allocated blocks
    ;Do not free nonallocated blocks, unless you want them part of the pool!

;Memory for use:
    ;$D500-$DFFF: 2816 bytes
.DEFINE RingStart $C0FB
.DEFINE MemStart $D500
.DEFINE MemEnd $E000
.DEFINE BlockSize 64

.SECTION "MemAlloc" FREE
MemInitTask:
  LD HL,RingStart
  LD DE,MemStart
-
  LD (HL),E
  INC L
  LD (HL),D
  RST $00
  LD H,D
  LD L,E
  LD A,BlockSize
  ADD E
  LD E,A
  JR nc,-
  INC D
  LD A,>MemEnd
  CP D
  JR nz,-
  JP EndTask

MemAlloc:
;Returns: memory in DE
;Destroys A, HL
  LD HL,RingStart
  LDI A,(HL)
  LD E,A
  LDD A,(HL)
  LD D,A
  LD A,(DE)
  LDI (HL),A
  INC E
  LD A,(DE)
  LDD (HL),A
  DEC E
  RET

MemFree:
;DE -> Allocated memory
  LD HL,RingStart
  LDI A,(HL)
  LD (DE),A
  INC E
  LD A,(HL)
  LD (DE),A
  DEC E
  LD (HL),D
  DEC L
  LD (HL),E
  RET

.ENDS
