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
  LD A,(HL)
  SUB 16
  CP 7      ;Marisa Y < trigger?
  JR nc,+
;Do top cutscene
  LD HL,exitUpCutscene+1
  XOR A
  CP (HL)
  RET z     ;No load if no link here
  LD BC,Cutscene_Task
  LD HL,exitUpCutscene
  LD E,(HL)
  INC L
  LD D,(HL)
  CALL NewTask
  LD A,B
  CALL WaitOnTask   ;Wait for cutscene to finish
  JR ExitCheck_Task
+
  LD D,H
  LD E,L
  LD HL,mapHeight
  ADD 7
  JR c,++   ;Always trigger if at bottom of background
  CP (HL)   ;Marisa Y >= trigger?
  JR c,+
  XOR A
  CP (HL)   ;If map is 256 pixels tall, don't use trigger (bottom of screen instead)
  JR z,+
++
;Do bottom cutscene
  LD HL,exitDownCutscene+1
  XOR A
  CP (HL)
  RET z     ;No load if no link here
  LD BC,Cutscene_Task
  LD HL,exitDownCutscene
  LD E,(HL)
  INC L
  LD D,(HL)
  CALL NewTask
  LD A,B
  CALL WaitOnTask   ;Wait for cutscene to finish
  JR ExitCheck_Task
+
  DEC DE
  DEC DE
  LD A,(DE)
  SUB 8 ;Rollunder important here
  CP 7      ;Marisa X < trigger?
  JR nc,+
;Do leftern cutscene
  LD HL,exitLeftCutscene+1
  XOR A
  CP (HL)
  RET z     ;No load if no link here
  LD BC,Cutscene_Task
  LD HL,exitLeftCutscene
  LD E,(HL)
  INC L
  LD D,(HL)
  CALL NewTask
  LD A,B
  CALL WaitOnTask   ;Wait for cutscene to finish
  JP ExitCheck_Task
+
  LD HL,mapWidth
  ADD 7
  JR c,+    ;Always trigger if at right edge of background
  CP (HL)   ;Marisa X >= trigger?
  RET c     ;No cutscenes to initiate; go to next frame
  XOR A
  CP (HL)   ;No trigger if fully wide map
  RET z
+
;Do rightern cutscene
  LD HL,exitRightCutscene+1
  XOR A
  CP (HL)
  RET z     ;No load if no link here
  LD BC,Cutscene_Task
  LD HL,exitRightCutscene
  LD E,(HL)
  INC L
  LD D,(HL)
  CALL NewTask
  LD A,B
  CALL WaitOnTask   ;Wait for cutscene to finish
  JP ExitCheck_Task

.ENDS
