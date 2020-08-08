;OAM interface

;This interface works together with the vBlank routine to ensure every object has time in the light, even if the program stupidly scheduled 80 sprites.

;What this interface does:
    ;Manages used and unused OAM slots
    ;Organises and selects OAM slots at a program's request
    ;Provides a contiguous RAM space to safely read and write to for OAM data
    ;Cycles OAM entries every other frame, so everything gets seen

;What must be done:
    ;Each frame when called, gotta see what wasn't shown last frame, and show that first
    ;v Fill in remaining slots as available
    ;DON'T fill with sprites violating the >10 per line limit
    ;Mark those sprites unseen as such
    ;Don't mark unseeable sprites as unseen
    ;v Provide a subroutine that reserves and outputs memory for writing sprite data
    ;v Provide a subroutine that frees and clears memory for above

;OAMClearEntry
        ;A=ID to clear
    ;Return
        ;A, BC destroyed
;OAMSetEntry
        ;A=No. of entries.
    ;Return
        ;A=ID on success, 0 on failure
        ;HL=Memory to use on success, undefined on failure
        ;BC, D destroyed
;OAMInit
        ;No arguments
    ;Return
        ;A, BC, HL destroyed
        ;DE preserved
;OAMFrame
        ;No arguments
    ;Return
        ;All destroyed

;At the moment...
    ;The routines don't actually cycle sprites. It does schedule and provide memory, though.

;Memory:
    ;Available ID list
        ;Bitfield of used IDs. Issued so memory can be tagged
    ;ID to Memory list
        ;Maps each of the IDs to lengths of used memory and however much is used
    ;OAM data memory
        ;At least 160 bytes of memory (preferrably 312)

.DEFINE OAMIDlist $C200
.DEFINE OAMtranslate $C220
.DEFINE OAMmemory $C280
.DEFINE OAMIDlistLo <OAMIDlist
.DEFINE OAMtranslateLo <OAMtranslate
.DEFINE OAMmemoryLo <OAMmemory
.DEFINE OAMIDlistHi >OAMIDlist
.DEFINE OAMtranslateHi >OAMtranslate
.DEFINE OAMmemoryHi >OAMmemory

.DEFINE OAMentryMax 40
.DEFINE OAMmemoryMax (OAMentryMax * 2 * 4 - 8)

OAMClearEntry:
.IF OAMIDlistLo != 0
  LD HL,OAMIDlist
  LD B,A
  SRL A     ;Divide by 8, with truncation
  SRL A
  SRL A
  ADD L
  LD L,A
  LD A,$07
  AND B
.ELSE
  LD H,OAMIDlistHi
  LD L,A
  SRL L     ;Divide by 8, with truncation
  SRL L
  SRL L
  AND $07
.ENDIF
  LD C,A
  LD B,A
  LD A,(HL)
-
  RRCA      ;Roll the right bit to spot 0, erase it, then roll it back.
  DEC B
  JR nz,-
  RES 0,A
-
  LD B,C
  RLCA 
  DEC B
  JR nz,-
  LD (HL),A
.IF OAMtranslateHi != OAMIDlistHi
  LD HL,OAMtranslate    ;Find all allocated memories, and free those
.ELIF OAMtranslateLo != 0
  LD L,OAMtranslateLo
.ELSE
  LD L,B
.ENDIF
-
  LDI A,(HL)    ;Find first entry
  CP C
  JR nz,-
  DEC L
-
  XOR A         ;Zero until last entry
  LDI (HL),A
  LD A,(HL)
  CP C
  JR z,-
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OAMSetEntry:
  OR A
  RET z
  LD B,A
  LD HL,OAMtranslate
  XOR A
  LD C,A
  LD D,OAMmemoryMax/4
-   ;Make sure we have enough entries
  CP (HL)
  JR z,+
  INC C
+
  INC L
  DEC D
  JR nz,-
  LD A,$7F
  AND B
  ADD C
  DEC A     ;So there's a carry if there's exactly enough entries
  CP OAMentryMax    ;It eliminates the carry if there's 0 requested entries and 0 used, which is a catastrophic error anyways.
  LD A,D    ;For error's sake
  RET nc
  BIT 7,B
  JR z,OAMSetEntryHi
  RES 7,B
  JR OAMSetEntryLo
OAMSetEntryRet:
;Seek to a zero
    ;Save location of this zero
    ;Count until either need is exhausted, or nonzero is reached
    ;If nonzero,
        ;Go back to 1
    ;Else,
        ;This is your memory
;Take that saved location, and fill the space with the ID
;Calculate that memory's position, return it
;This code is dependent on the particular positions of the pointers
  LD A,L
  SUB OAMtranslateLo   ;Get from OAMtranslate to OAM memory, while multiplying by 4
  RLCA
  RLCA
  ADD OAMmemoryLo
  LD L,A
  LD A,$00
  ADC H
  LD H,A
  LD A,D
  RET

OAMSetEntryLo:
;Same as OAMSetEntryHi, but we seek from top to bottom here (lo prio)
;Find an available ID, take it
;D= ID
    ;ID = 0
    ;Get a field, compare to 255
        ;If so, add 8 to ID
        ;Else, rotate until a 0, add 1 to ID each time
    ;Once else, set that bit to 1 and restore
    ;Replace
    ;You now have your ID
  LD L,OAMIDlistLo + $1F
  LD C,D    ;Clear C
-
  LD A,$FF
  CP (HL)
  JR nz,+
  DEC L
  LD A,8
  ADD D
  LD D,A
  JR -
+
  LD A,(HL)
-
  BIT 0,A
  JR z,+
  RRCA
  INC C
  INC D
  JR -
+
  SET 0,A
-
  RLCA
  DEC C
  JR nz,-
  LD (HL),A
;Find the empty memory needed, reserve it
  LD L,OAMtranslateLo + $5F
--
  LDD A,(HL)    ;Find zero
  OR A
  JR nz,--
  LD A,B
  LD C,A
  INC L
-
  LDD A,(HL)
  OR A      ;See if length is long enough
  JR nz,--
  DEC C
  JR nz,-
;Long enough
  LD A,B
  LD C,B
  LD A,D
-
  LDI (HL),A
  DEC C
  JR nz,-
  DEC L
  JR OAMSetEntryRet
OAMSetEntryHi:
;Find an available ID, take it
;D= ID
    ;ID = 0
    ;Get a field, compare to 255
        ;If so, add 8 to ID
        ;Else, rotate until a 0, add 1 to ID each time
    ;Once else, set that bit to 1 and restore
    ;Replace
    ;You now have your ID
  LD L,OAMIDlistLo
  LD C,D    ;Clear C
-
  LD A,$FF
  CP (HL)
  JR nz,+
  INC L
  LD A,8
  ADD D
  LD D,A
  JR -
+
  LD A,(HL)
-
  BIT 0,A
  JR z,+
  RRCA
  INC C
  INC D
  JR -
+
  SET 0,A
-
  RLCA
  DEC C
  JR nz,-
  LD (HL),A
;Find the empty memory needed, reserve it
  LD L,OAMtranslateLo
--
  LDI A,(HL)    ;Find zero
  OR A
  JR nz,--
  LD A,B
  LD C,A
  DEC L
-
  LDI A,(HL)
  OR A      ;See if length is long enough
  JR nz,--
  DEC C
  JR nz,-
;Long enough
  LD A,B
  LD C,B
  LD A,D
-
  LDD (HL),A
  DEC C
  JR nz,-
  INC L
  JR OAMSetEntryRet

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OAMInit:
  LD HL,OAMIDlist
  LD (HL),$01   ;ID 0 always reserved
  INC L
  LD BC,OAMmemoryMax + $0100    ;Length of memory, counter style
  XOR A
-
  LDI (HL),A
  DEC C
  JR nz,-
  DEC B
  JR nz,-
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OAMFrame:
  LD HL,OAMmemory
  LD BC,OAMtranslate
  LD DE,$CF00   ;OAM update area
-
  LD A,$A0  ;Check for end of OAM
  CP E
  JR z,+++
  LD A,OAMmemoryMax/4 + OAMtranslateLo
  CP C      ;Check for end of IDlist
  JR z,++
  LD A,(BC)
  INC C
  OR A  ;Is this memory used?
  JR nz,+
;No
  INC HL
  INC HL
  INC HL
  INC HL
  JR -
+;Yes
  LDI A,(HL)    ;Unrolled for simplicity
  LD (DE),A
  INC E
  LDI A,(HL)
  LD (DE),A
  INC E
  LDI A,(HL)
  LD (DE),A
  INC E
  LDI A,(HL)
  LD (DE),A
  INC E
  JR -
++  ;Blank out rest of OAM
-
  XOR A
  LD (DE),A
  INC E
  LD A,$A0
  CP E
  JR nz,-
+++
  LD HL,$CFA0   ;vBlank flags
  SET 0,(HL)
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Methods:
;Seek through the free list & find where it would go (Sort)
;See if the end of the previous entry matches this one, or if the end of this entry matches the next one (Tape)
;Insert a new entry, or modify an existing entry(Concatenate)

;OR

;Find memories with the matching ID tag, and clear those
;Alternate memory layout:
    ;Used ID bitfield ($00 or $FF reserved)
    ;Byte per 4 of OAM data memory, filled with owning ID
;Advantages:
    ;Constant memory requirement
    ;Faster
;Limitations:
    ;Nonextesible; Hard maximum
    ;Increases linearly
;In order to prevent Memory overrun complications, the pointer method would also increase memory requirements linearly, in order to deal with maximum fragmentation (see appendix A).
;In light of the above, for each system, maximum fragmentation would be identical to nonconcatenated entries, already ruling out pointers' nonconstant memory requirement. Thus, the amount of bytes needed for each entry determines the system with better space usage.
;Pointers:
    ;2 bytes to point to location + 1-2 bytes for size/ end pointer + 1 byte for ID + 3-4 bytes for any free entries.
    ;Size: Unallocated, 3-4 bytes. Fully allocated, 315-394 bytes.
;ID field:
    ;1 byte for ID
    ;Size: 78 bytes constant
;ID field superior at 20-16 allocation changes

;Appendix A: Maximum fragmentation:
    ;Let the maximum number of handleable sprites be X, and the amount of OAM data memory needed for one sprite be M. A given implementation that has reserved memories alternating with unreserved memories in a pattern of {0,1,0,1...}, where 0 is an unreserved entry and 1 is a reserved entry. If a request is made for 2M memory, the request cannot be fulfilled, despite sufficient memory being available, because said memory is fragmented so enough contiguous memory is not available. A solution to this issue is to provide (2X+1)M memory. But is this sufficient? Or are there other constraining situations?
    ;However, there is a problem with this proposition. In order for memory to be allocated in that pattern, there must first have been (2X-1) sprites at once, exceeding the maximum of X for any X>1. Creating such a system where only X sprites are allocated at once, requires a memory of (X+1)M. This is clearly just barely above a default of XM.
    ;A system could request X-2 sprites, then one sprite, free the first, then request X-1 sprites. This is easily seen as the opposite end of possible fragmentation cases. In this case, the amount of memory needed would be (X-2 + X-1 + 1)M = (2X-2)M
    ;Further analysis would suggest that for worst case fragmentation cases, the memory requirement to ensure successful allocation is (X+G)M, where G is the size of unallocated space between entries. This maximum case is X-2, to ensure both that A: there is enough sprites remaining to allow at least one allocated entry, to permit fragmentation, and B: the largest allocateable array possible, allowing A.
    ;Although it seems unlikely for X-1 sprites to require allocation at the same time, in order to ensure that memory limitations don't become apparent, room for 2(X-1)M memory must be reserved.
    ;This is indeed the worst case scenareo, for it is the largest value for which system every step is a logical allocation behavior, and the amount requested is highest allowing for the minimum number of entries (1) required to create fragmentation, with the largest fragmentation gap. In the event XM is a convenient sum of memory, 2XM is only 2M away
