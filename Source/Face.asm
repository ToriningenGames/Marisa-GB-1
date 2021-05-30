;Face manipulations
;Designed to go along with Text

;Decisions to make:
    ;Where is the Facedata?
    ;How is it organized?
        ;By character? Expression? Etc.
    ;How much is available at once, before needing to call an extract?
    ;Where will extracted data live?
        ;One uncompressed face takes up 256 bytes
        ;Previous data suggests a layout of 4 faces/character (total 8) at once
        ;Consider: with more than 4 faces, we may need to pick and choose 
            ;which faces to have available differently, depending on the scene
        ;We currently have drawn 15 unique faces
        ;There was also an implied that Marisa would always be available.
            ;We'll see.
        ;RAM space: 512 bytes already allocated, going by multiples
            ;An extra 512 at $C100, at former Text interface space.
            ;So, either 4 faces total, or dynamic loading.
            ;Why not both? A face can be shown while it's being replaced, no tear
            ;Complex. Dynamic loading reduces space complexity.
        ;At this time (2019-10-22) we have 15622 bytes free ROM space
            ;13077 bytes on bank 0
            ;02545 bytes on bank 1
        ;Uncompressed, we fit not quite 10 faces on Bank 1 (ideal location)
;Future lesson: Make all components rely on a COMMON set of generic tools!

;Fancy this: Nothing externally needs to know how faces are handled, they only
;need to know "Ready this face" and "Show this face"
;...Do they have to know "Ready this face"?
    ;It takes at least 3 frames to copy over the requisite data to vRAM

.INCLUDE "macros.asm"

.DEFINE FaceExtractState    $C0E0
.DEFINE FaceExtractArea     $C900
.DEFINE FaceState   $C0E7
    ; %E00000FF
    ;  ||||||++--- Which face is on screen (0: No face, 1: Showing 1, 2: Showing 2)
    ;  |+++++----- Unused. Keep 0
    ;  +---------- Currently extracting face
.DEFINE Face0Start  $0000
.DEFINE Face1Start  $9000   ;Tiledata addr. that Face 1 starts on
.DEFINE Face2Start  $9100   ;Ditto for 2

.EXPORT FaceState

.SECTION "Face" FREE

FaceData0:
 .db $30,$30,$30,$30
 .db $30,$30,$30,$30
 .db $30,$30,$30,$30
 .db $30,$30,$30,$30
FaceData1:
 .db $00,$01,$02,$03
 .db $04,$05,$06,$07
 .db $08,$09,$0A,$0B
 .db $0C,$0D,$0E,$0F
FaceData2:
 .db $10,$11,$12,$13
 .db $14,$15,$16,$17
 .db $18,$19,$1A,$1B
 .db $1C,$1D,$1E,$1F

FaceLoad_Task:
;D = Face loc ID
;A=Face to load
    ;Format:
    ;%CCCCBBFF
    ; ||||||++--- Face
    ; ||||++----- Bank
    ; ++++------- Character
    ;Face and Bank are implementation details; basically, 16 faces per character
  LD HL,FaceState
  BIT 7,(HL)
  RET nz
  SET 7,(HL)
  PUSH DE
  LD B,A
  LD D,0
  AND $FC
  RRCA
  LD E,A
  LD HL,FacesList
  ADD HL,DE
  ;Got Character
  ;Got Bank
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  ;Decompress to this face
  LD A,$03
  AND B
  INC A
  LD DE,FaceExtractState
  PUSH AF
  PUSH DE
  LD DE,FaceExtractArea
  CALL ExtractSpec
  POP HL
  POP AF
  DEC A
  JR z,+
-
  PUSH AF
  PUSH HL
  CALL ExtractRestoreHL
  POP HL
  POP AF
  DEC A
  JR nz,-
+   ;Grab face
  POP AF
  ADD (>Face1Start)-1
  LD DE,5   ;>data_dest
  ADD HL,DE
  LD D,(HL)
  DEC D
  LD E,A
  LD A,1
  LD BC,LoadToVRAM_Task
  CALL NewTask
  LD A,B
  CALL WaitOnTask
  LD HL,FaceState
  RES 7,(HL)
  JP EndTask

;Copy the requested face to given location, and issue copy to vRAM in text box
;0 counts as no face
FaceShow_Task:
;A = Face
  LD HL,FaceState
  LD C,A
  LD A,(HL)
  AND $FC
  OR C
  LD (HL),A
  LD A,C
  LD HL,FaceTransferData0
  RLCA
  RLCA
  RLCA
  LD E,A
  LD D,0
  ADD HL,DE
  LD D,H
  LD E,L
  LD BC,LoadRectToVRAM_Task
  CALL NewTask
;Copy face tile data to text buffer too.
  LD H,D
  LD L,E
  INC HL
  INC HL
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  LD DE,TextData+32
  LD BC,$0404
-
  LDI A,(HL)
  LD (DE),A
  INC E
  DEC C
  JR nz,-
  LD A,32-4
  ADD E
  LD E,A
  LD C,4
  DEC B
  JR nz,-
  JP EndTask
FaceTransferData0:
.db 4,4,<FaceData0,>FaceData0,$20,$9C,0,0
FaceTransferData1:
.db 4,4,<FaceData1,>FaceData1,$20,$9C,0,0
FaceTransferData2:
.db 4,4,<FaceData2,>FaceData2,$20,$9C

.ENDS
