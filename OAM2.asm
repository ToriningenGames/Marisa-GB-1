;OAM2

;Idea:
    ;Free memory is indicated by zeroed regions
    ;It is the owner's responsibility to zero regions when finished
    ;An invisible frame routine will load in active sprites
;For small projects, we don't need more than 40 sprites
.SECTION "OAM" FREE

.DEFINE OAMMemEnd $CF9F

OAMInit:
  LD HL,OAMMemEnd
  XOR A
-
  LDD (HL),A
  CP L
  JR nz,-
  RET

.ENDS
