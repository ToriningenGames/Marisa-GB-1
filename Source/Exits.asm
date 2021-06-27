;Exits

;Detects if Marisa hits the edge of a map, and plays the appropriate cutscene.

;How vars are set up between maps:
    ;0: ?
    ;2: Map bkg type
    ;4: Map Data
    ;6: Entry direction
    ;8: Entry destination

.include "mapDef.asm"
.include "actorData.asm"

.SECTION "Exits" FREE

.DEFINE Left  0
.DEFINE Down  1
.DEFINE Right 2
.DEFINE Up    3

ExitCheck_Task:
  CALL HaltTask     ;Set point of return
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
;Top
  LD HL,exitUpMap+1
  XOR A
  CP (HL)
  RET z     ;No load if no map
  LD A,Up
  JR +++
+
  LD D,H
  LD E,L
  LD HL,mapHeight
  ADD 7
  JR c,++   ;Always trigger if at bottom of background
  CP (HL)   ;Marisa Y > trigger?
  JR c,+
  XOR A
  CP (HL)   ;Do not always trigger on full size maps
  JR z,+
++  ;Bottom
  LD A,Down
  JR +++
+
  DEC DE
  DEC DE
  LD A,(DE)
  SUB 8 ;Rollunder important here
  CP 7      ;Marisa X < trigger?
  JR nc,+
;Left
  LD A,Left
  JR +++
+
  LD HL,mapWidth
  ADD 7
  JR c,++   ;Always trigger if at right edge of background
  CP (HL)   ;Marisa X >= trigger?
  RET c     ;No cutscenes to initiate; go to next frame
  XOR A
  CP (HL)   ;No trigger if fully wide map
  RET z
++  ;Right
  LD A,Right
+++
  LD DE,VarArea+1
  LD (DE),A     ;Entrance facing direction
  INC E
  LD HL,ObjArea
  ADD A     ;Index to proper map data
  ADD L
  LD L,A
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  XOR A
  LD (DE),A     ;Zero var 2
  INC E
;Data is in front of map; load it in to vars, map data and go
  LD C,mapDefSize-2
-
  LDI A,(HL)
  LD (DE),A
  INC E
  DEC C
  JR nz,-
  LDI A,(HL)
  LD D,(HL)
  LD E,A
  LD BC,Cutscene_Task
  CALL NewTask
  LD A,B
  CALL WaitOnTask
  JP ExitCheck_Task

.ENDS
