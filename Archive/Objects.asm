
.DEFINE ObjUse $C0FA
.EXPORT ObjUse

.SECTION "ObjData" FREE ALIGN 256
ObjLoc:
 .db $10,$28,$40,$58,$70,$88
.ENDS

.SECTION "Object" FREE
;Provide convenience functions
ObjInit:
;Returns sprites in HL
;Destroys A and B
  LD A,(ObjUse)
  LD H,>ObjLoc
  LD L,6
-
  RRA
  JR nc,+
  DEC L
  JR nz,-
;No free slots
+
;Found one
;Reserve it
  LD B,L
  SCF
  RRA
  RRA
-
  RRA
  DEC B
  JR nz,-
  LD (ObjUse),A
  DEC L ;((L - 1) * 6 + 4) * 4 == L * 24 - 8
  LD L,(HL) ;Done via lookup
  LD H,$CF
  RET
ObjGetHiPrio:
;B = no. of objects
;Returns: Pointer in HL
  LD HL,OAMBuffer
--
  LD C,B
  LD E,L
-
;Sanity check
  LD A,L
  CP $A0
  JR nc,+   ;Shared error handler
  XOR A
  OR (HL)
  INC L
  OR (HL)
  INC L
  OR (HL)
  INC L
  OR (HL)
  INC L
  OR A
  JR nz,--
  DEC C ;Successfully found
  JR nz,-
  LD L,E
  RET

ObjGetLoPrio:
;B = no. of objects
;Returns: Pointer in HL
  LD HL,OAMBuffer + $A0
--
  LD C,B
-
;Sanity check
  LD A,L
  CP $A0
  JR nc,+
  XOR A
  DEC L
  OR (HL)
  DEC L
  OR (HL)
  DEC L
  OR (HL)
  DEC L
  OR (HL)
  JR nz,--
  DEC C ;Successfully found
  JR nz,-
  RET
+   ;Error
  LD HL,0
  SCF
  RET

;Given a pair of 8.8 map coordinates, get sprite coordinates
ObjOffset:
  RET

.ENDS
