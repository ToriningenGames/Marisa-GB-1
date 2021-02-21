;Exits

;Detects if Marisa hits the edge of a map, and plays the appropriate cutscene.

.include "mapDef.asm"
.include "actorData.asm"

.SECTION "Exits" FREE

ExitCheck_Task:
  LD A,(Cutscene_Actors+1)
  OR A
  RET z     ;No go if no Marisa
  CALL Access_ActorDE
  LD DE,_MasterY+1
  ADD HL,DE
  LD D,H
  LD E,L
  LD HL,ObjArea
  LD A,(DE)
  SUB 16
  CP (HL)   ;Marisa Y < trigger?
  INC HL
  JR nc,+
;Do top cutscene
  LD E,(HL)
  INC HL
  LD D,(HL)
  LD BC,Cutscene_Task
  CALL NewTask
  LD A,B
  CALL WaitOnTask   ;Wait for cutscene to finish
  JR ExitCheck_Task
+
  INC HL
  INC HL
  CP (HL)   ;Marisa Y >= trigger?
  JR c,+
  LD A,(HL)
  OR A      ;Except if trigger == 0
  JR z,+
  INC HL
;Do bottom cutscene
  LD E,(HL)
  INC HL
  LD D,(HL)
  LD BC,Cutscene_Task
  CALL NewTask
  LD A,B
  CALL WaitOnTask   ;Wait for cutscene to finish
  JR ExitCheck_Task
+
  DEC DE
  DEC DE
  INC HL
  INC HL
  INC HL
  LD A,(DE)
  SUB 8
  CP (HL)   ;Marisa X < trigger?
  INC HL
  JR nc,+
;Do leftern cutscene
  LD E,(HL)
  INC HL
  LD D,(HL)
  LD BC,Cutscene_Task
  CALL NewTask
  LD A,B
  CALL WaitOnTask   ;Wait for cutscene to finish
  JR ExitCheck_Task
+
  INC HL
  INC HL
  CP (HL)   ;Marisa X >= trigger?
  RET c     ;No cutscenes to initiate; go to next frame
  LDI A,(HL)
  OR A      ;Except if trigger == 0
  RET z
;Do rightern cutscene
  LD E,(HL)
  INC HL
  LD D,(HL)
  LD BC,Cutscene_Task
  CALL NewTask
  LD A,B
  CALL WaitOnTask   ;Wait for cutscene to finish
  JR ExitCheck_Task

.ENDS
