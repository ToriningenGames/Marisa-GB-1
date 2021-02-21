;Camera code
;Maintains the game camera on Marisa, while keeping only the map in view.

.include "ActorData.asm"

.include "mapDef.asm"

.SECTION "Camera" FREE

;Keep the camera within map boundaries,
;and centered on Marisa otherwise.

;WORKING BITS:
;Center
;Upper left corner
;Upper edge
;Left edge

;BROKEN BITS:
;Upper right corner (Camera keeps moving right)
;Right edge (ditto)
;Lower right corner (ditto, and down)
;Lower edge (too far down)
;Lower left corner (ditto)

Camera_Task:
;Get Marisa
  LD A,(Cutscene_Actors+1)
  OR A
  RET z ;If no Marisa, do nothing.
  CALL Access_ActorDE
  PUSH HL
    LD BC,_ControlState
    ADD HL,BC
    LD A,(HL)
    DEC A
  POP HL
  RET nz    ;If player doesn't have control, don't follow player
;Is screen wide enough for scrolling?
  INC HL    ;Move to Marisa X hi
  INC HL
  INC HL
  LD A,(mapWidth)
  OR A
  JR z,+    ;Giant maps (width 0) do scroll
  CP 161        ;Screen width, in pixels, plus one, to catch an exact match
  JR c,_SmallMapX
+
;Map is big
  LD B,A
;Get X of Marisa
  LD A,(HL)
  SUB 8     ;Sprite offsets
;Center Marisa on camera
  SUB 80    ;20 horizontal tiles / 2 (half of screen) * 8 pixels per tile + 8 pixels slide edge
;Clamp left to map
  JR nc,++
  LD A,0
  JR _LoadPosX
++
;Clamp right to map
  LD C,A
  LD A,B
  SUB 160   ;Bring right edge of map in line with center position
  LD B,A
  SUB C ;Is Marisa far enough from this position?
  JR nc,++
;Too close to edge; use computed map edge position
  LD A,B
  JR _LoadPosX
++
  ;Marisa in completely reasonable position; use her location as center
  LD A,(HL)
  SUB 88    ;Position offset
  JR _LoadPosX
_SmallMapX:
;Map fits within screen; find center
  ;Derived:
  ;(160 - width) / 2 * -1
  ;-1 * (160 - width) / 2
  ;(-160 + width) / 2
  ;(width - 160) / 2
  ADD (~160)+1
  SRA A
_LoadPosX:
;Load into view position
  LD (BkgHortScroll),A

;Now to Y position

;Is screen tall enough for scrolling?
  LD A,(mapHeight)
  OR A
  JR z,+    ;Giant maps (height 0) do scroll
  CP 145        ;Screen height, in pixels, plus one to catch exact match
  JR c,_SmallMapY
+
;Map is big
  LD B,A
;Get Y of Marisa
  INC HL
  INC HL
  LD A,(HL)
  SUB 16    ;Sprite offsets
;Center Marisa
  SUB 72    ;18 horizontal tiles / 2 (half of screen) * 8 pixels per tile + 16 pixels slide edge
;Clamp top to map
  JR nc,++
  LD A,0
  JR _LoadPosY
++
;Clamp bottom to map
  LD C,A
  LD A,B
  SUB 144   ;Bring bottom edge of map in line with center position
  LD B,A
  SUB C ;Is Marisa far enough from this position?
  JR nc,++
;Too close to edge; use computed map edge position
  LD A,B
  JR _LoadPosY
++
  ;Marisa in completely reasonable position; use her location as center
  LD A,(HL)
  SUB 88    ;Position offset
  JR _LoadPosY
_SmallMapY:
;Map fits within screen; find center
  ;Derived:
  ;(144 - height) / 2 * -1
  ;-1 * (144 - height) / 2
  ;(-144 + height) / 2
  ;(height - 144) / 2
  ADD (~144)+1
  SRA A
_LoadPosY:
;Load into view position
  LD (BkgVertScroll),A
  RET
.ENDS
