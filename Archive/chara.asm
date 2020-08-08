;Player character
    ;Is probably a subset of objects
    ;Is probably a subset of characters
    ;Is probably a subset of player control
    ;Is probably an actor in cutscenes
    ;Is probably only one
;Memory
    ;Sprite pointers

;Idle animations
;Walking animations
;Input reaction
    ;Facing
    ;Moving

.SECTION "Character" FREE
;Player Characters do:
    ;Move, in response to player input
    ;Move, in response to cutscene directives
    ;Change sprite data (animate) based on input
    ;Collide with collision
    ;Hide behind priority
    ;Interact with exits based on location
        ;Possibly exits' responsibility
;Player Characters need:
    ;9 sprites
        ;3 front
        ;6 back
    ;Space for coordinates
    ;Hatted state
        ;Hat count

;Memory format:
;Block
    ;+$00, size 2: Sprite pointer
    ;+$02, size 2: Master X
    ;+$04, size 2: Master Y
    ;+$06, size 2: Subsprite relational data
    ;+$08, size 2: current animation pointer
    ;+$0A, size 1: current animation frame
    ;+$0B, size 1: current state
.DEFINE _SprPtr $00
.DEFINE _MasterX $02
.DEFINE _MasterY $04
.DEFINE _RelData $06
.DEFINE _AnimPtr $08
.DEFINE _AnimFrame $0A
.DEFINE _ButtonState $0B

.DEFINE Speed 100
CharaFrame:
;A = initial facing
    ;0 = right
    ;1 = left
    ;2 = up
    ;3 = down
;B = X start
;C = Y start
;Convert from numerical direction to boolean direction
  RLCA
  RLCA
  AND $03
  JR z,+    ;Right
  DEC A
  JR z,++   ;Left
  DEC A
  JR z,+++  ;Up
;Down
  ADD %00111111
+++
  ADD %00100000
++
  ADD %00010000
+
  ADD %00010000
  LD B,A    ;State init
  PUSH DE   ;X, Y
;Allocate and initialize memory
  CALL MemAlloc
  LD H,D
  LD L,E
  XOR A
  LD C,11   ;Not State
-
  LDI (HL),A
  DEC C
  JR nz,-
  LD A,B
  LD (HL),A
  LD B,D
  LD C,E
  CALL MemAlloc ;Subsprite
  LD HL,_RelData
  ADD HL,BC
  LD (HL),E
  INC HL
  LD (HL),D
  LD E,B
  CALL ObjInit
  LD B,E
  LD A,L
  
  LD (BC),A
  INC BC
  LD A,H
  LD (BC),A
  DEC BC
  LD HL,_MasterX+1
  ADD HL,BC
  POP DE
  LD A,D    ;X
  LDI (HL),A
  INC HL
  LD (HL),E ;Y
;BC->Memory
;Clear sprite metadata
  LD HL,_RelData
  ADD HL,BC
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  XOR A
  LD D,6
-
  LDI (HL),A
  LDI (HL),A
  LDI (HL),A
  LDI (HL),A
  DEC D
  JR nz,-
  LD D,B
  CALL MsgClear
;DONE:
    ;Spawn point set (Accept XY input) v
        ;More consistent with fairies: pass as argument
            ;Since it's a starting point, subpixel precision can be ignored
            ;So, we pass an X and a Y: 2 bytes
            ;Also, fairies need a type specifier?
    ;Initial facing v
        ;4 directions, two bits
        ;Pass in A. Fairies too. They don't need 256 variations
    ;Facing proper v
        ;When pushing a new direction to run, use that. (Change) v
        ;Else, use current direction running in.     (No Change) v
        ;Else, use direction pressed last frame.        (Change) v
        ;Else, do nothing.                           (No Change) v
    ;Animations proper v
        ;For running:
            ;Only actively pressed button!
            ;For multiple, use priority system
                ;Facing must use same
        ;For idle:
            ;No buttons!
    ;Pause acknowledgement (probably its own task) v
;TODO:
    ;Destructor
    ;Hat
    ;Hat play
    ;Action buttons
    ;Junko theme (Not related)
        ;Screw it up too (also not related)
-
  CALL HaltTask
;Frame loop
;Got a message?
  CALL MsgGet
  LD B,D
  JR c,+
;Message get!
;Messages Marisa will care about:
    ;Cease existing
    ;Stop moving
    ;Start moving again
    ;Cutscene manipulation
        ;Stuffing fake button state
    ;Hat stuff?
        ;An alternative is to put the hat in charge of its relationships
    ;Message format:
        ;H = Message type
        ;L = Message specific data
    ;H:
        ;0 = None
        ;1 = Stop moving
        ;2 = Start moving
        ;4 = Cutscene control
        ;8 = Skip this frame
    ;L:
        ;H == 4, L = Button presses to use 
  BIT 0,H
  JR z,++
--
  CALL HaltTask
  CALL MsgGet
  JR c,--
  BIT 1,H
  JR z,--
  JR -
++
  BIT 3,H
  JR z,++
  ;Hijack button presses by stuffing in $FFFE
  LD A,L
  LDH ($FE),A
++
  BIT 4,H
  RET nz    ;Used for slowing down animations
+   ;No messages
  LD HL,_ButtonState
  ADD HL,BC
  LDH A,($FE)
  XOR (HL)  ;Get direction button delta
  AND $F0
  JR z,+
;New animation
;Truth table for new buttons:
;State: 0 0 1 1
;New:   0 1 0 1
;Use:   0 1 0 0
;U = ~(~N | S)
  LDH A,($FE)
  CPL
  OR (HL)
  CPL
  AND $F0   ;Affect zero flag
  JR nz,+++
;Check for held buttons
  LDH A,($FE)
  AND (HL)
  AND $F0
  JR z,++
+++
;Animation based on A
  DEC HL
  LD DE,_HortWalkingEnter
  BIT 5,A
  JR nz,+++
  BIT 4,A
  JR nz,+++
;Vert
  LD DE,_VertWalkingEnter
  JR +++
++
;No buttons pressed this frame, meaning last frame of animation
  LDD A,(HL)
;Enter idle
  LD DE,_IdleEnter
+++
  LD (HL),1     ;Run the animation this frame
  DEC HL
  LD (HL),D
  DEC HL
  LD (HL),E
  DEC HL
  LD E,(HL)
  DEC HL
  LD L,(HL)
  LD H,E
;Facing based on A
;Which facing?
    ;Horizontal over vertical
  SWAP A
  LD DE,_FacingRight
  RRA
  JR c,++
  LD DE,_FacingLeft
  RRA
  JR c,++
  LD DE,_FacingUp
  RRA
  JR c,++
  LD DE,_FacingDown
++
  PUSH BC
  LD C,24
-
  LD A,(DE)
  INC DE
  LDI (HL),A
  DEC C
  JR nz,-
  POP BC
+
;Check for movement
  LD HL,_ButtonState
  ADD HL,BC
  LDH A,($FE)
  AND $F0
  LD (HL),A
  JR z,+
;Direction buttons changed
;Up/down?
  AND $C0
  JR z,+++
  RLA
  JR nc,++
  LD DE,Speed
++
  RLA
  JR nc,++
  LD DE,-(Speed)
++
;Move!
  LD HL,_MasterY
  ADD HL,BC
  LD A,(HL)
  ADD E
  LDI (HL),A
  LD A,(HL)
  ADC D
  LDI (HL),A
+++
;Left/right?
  LDH A,($FE)
  AND $30
  JR z,+
  RLA
  RLA
  RLA
  JR nc,++
  LD DE,-(Speed)
++
  RLA
  JR nc,++
  LD DE,Speed
++
;Move!
  LD HL,_MasterX
  ADD HL,BC
  LD A,(HL)
  ADD E
  LDI (HL),A
  LD A,(HL)
  ADC D
  LDI (HL),A
+
;Check for animation
  LD HL,_AnimFrame
  ADD HL,BC
  DEC (HL)
  JR nz,+
;New anim frame
  DEC HL
  LD D,(HL)
  DEC HL
  LD E,(HL)
  INC HL
  INC HL
  LD A,(DE)
  OR A
  JR nz,++
;Animation end
  INC DE
  LD A,(DE)
  PUSH AF
  INC DE
  LD A,(DE)
  LD D,A
  POP AF
  LD E,A
  LD A,(DE)
++
  LDD (HL),A    ;New animation counter
  LD HL,_RelData
  ADD HL,BC
  LDI A,(HL)    ;To relational sprite data
  LD H,(HL)
  LD L,A
  CPL
  INC DE
  PUSH AF
-
  LD A,(DE)
  ADD (HL)
  LDI (HL),A
  INC DE
  LD A,(DE)
  ADD (HL)
  LDI (HL),A
  INC DE
  LD A,(DE)
  ADD (HL)
  LDI (HL),A
  INC DE
  LD A,(DE)
  XOR (HL)
  LDI (HL),A
  INC DE
  ;End check
  POP AF
  PUSH AF
  ADD L
  CP 23
  JR nz,-
  POP AF
  LD HL,_AnimPtr
  ADD HL,BC
  LD (HL),E
  INC HL
  LD (HL),D
+
;Update visuals
  LD HL,_MasterX
  ADD HL,BC
  PUSH BC
  LD C,(HL)
  INC HL
  LD B,(HL)
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  CALL ObjOffset
;Sprite global offset obtained, apply to all parts
  POP DE    ;Memory
  LD HL,_RelData
  ADD HL,DE
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  LD A,(DE)
  PUSH AF
  INC DE
  LD A,(DE)
  LD D,A
  POP AF
  LD E,A
  LD A,6
-
  PUSH AF
  LDI A,(HL)
  ADD C
  LD (DE),A
  INC E
  LDI A,(HL)
  ADD B
  LD (DE),A
  INC E
  LDI A,(HL)
  LD (DE),A
  INC E
  LDI A,(HL)
  LD (DE),A
  INC E
  POP AF
  DEC A
  JR nz,-
  RET

;Character facing data
;Order:
    ;Relative Y
    ;Relative X
    ;Tile
    ;Attribute XOR (For correct flips)
;All UDLR designations are screen-based
;Down
_FacingDown:
 .db -10,-9,$69,%00100000  ;Head left
 .db -10,-1,$68,%00100000  ;Head right
 .db  -8,-7,$6B,%00000000  ;Shoulder left
 .db  -8, 0,$6B,%00100000  ;Shoulder right
 .db   0,-7,$6E,%00000000  ;Leg left
 .db   0, 0,$6E,%00100000  ;Leg right
;Up
_FacingUp:
 .db -10,-7,$6A,%00100000  ;Head left
 .db -10, 1,$69,%00000000  ;Head right
 .db  -8,-7,$6C,%00100000  ;Shoulder left
 .db  -8, 0,$6C,%00000000  ;Shoulder right
 .db   0,-7,$6F,%00100000  ;Leg left
 .db   0, 0,$6F,%00000000  ;Leg right
;Left
_FacingLeft:
 .db -10, -4,$6D,%00100000  ;Head
 .db 'B','J',$FF,%00000000  ;Hide Sprite
 .db  -8, -5,$79,%00000000  ;Shoulder
 .db 'O','Y',$FF,%00000000  ;Hide sprite
 .db   0, -8,$73,%00100000  ;Leg left
 .db   0,  0,$72,%00100000  ;Leg right
;Right
_FacingRight:
 .db -10, -4,$78,%00100000  ;Head
 .db 'S','O',$FF,%00000000  ;Hide Sprite
 .db  -8, -5,$79,%00000000  ;Shoulder
 .db 'C','T',$FF,%00000000  ;Hide sprite
 .db   0, -8,$72,%00000000  ;Leg left
 .db   0,  0,$73,%00000000  ;Leg right
;Animation format, array of:
  ;Frame wait (0 for repeat)
  ;RLE Encoded?:
    ;Signed Y movement
    ;Signed X movement
    ;Signed tile change
    ;Attribute XOR
_VertWalkingEnter:
 .db 1
 .db 0,0,0,0
 .db 0,0,0,0
 .db 0,0,0,0
 .db 0,0,0,0
 .db 0,0,0,0
 .db 0,0,2,0
_VertWalkingLoop:
 .db 5
 .db -1,0,0,0
 .db -1,0,0,0
 .db -1,0,0,0
 .db -1,0,0,0
 .db -1,0,2,0
 .db -1,0,-2,0
 .db 7
 .db 1,0,0,0
 .db 1,0,0,0
 .db 1,0,0,0
 .db 1,0,0,0
 .db 1,0,-2,0
 .db 1,0,2,0
 .db 0
 .dw _VertWalkingLoop
_HortWalkingEnter:
_HortWalkingLoop:
 .db 6
 .db 1,0,0,0
 .db 1,0,0,0
 .db 1,0,0,0
 .db 1,0,0,0
 .db 1,0,2,0
 .db 1,0,2,0
 .db 4
 .db -1,0,0,0
 .db -1,0,0,0
 .db -1,0,0,0
 .db -1,0,0,0
 .db -1,0,-2,0
 .db -1,0,-2,0
 .db 5
 .db 1,0,0,0
 .db 1,0,0,0
 .db 1,0,0,0
 .db 1,0,0,0
 .db 1,0,4,0
 .db 1,0,4,0
 .db 5
 .db -1,0,0,0
 .db -1,0,0,0
 .db -1,0,0,0
 .db -1,0,0,0
 .db -1,0,-4,0
 .db -1,0,-4,0
 .db 0
 .dw _HortWalkingLoop
_IdleEnter:
_IdleLoop:
 .db $FF
 .db 0,0,0,0
 .db 0,0,0,0
 .db 0,0,0,0
 .db 0,0,0,0
 .db 0,0,0,0
 .db 0,0,0,0
 .db 0
 .dw _IdleLoop
.ENDS

.SECTION "Hat" FREE

HatInit:
  LD B,3
;  CALL ObjGetHiPrio
  LD B,H
  LD C,L
  CALL MemAlloc
  LD A,C
  LD (DE),A
  INC E
  LD A,B
  LD (DE),A
  DEC E
  LD BC,HatFrame
  JP NewTask

HatFrame:
;DE->preallocated memory
    ;Memory format:
        ;+$00, size 2: Sprite pointer
        ;+$02, size 2: Pointer to current head
  LD A,(DE)
  LD L,A
  INC E
  LD A,(DE)
  LD H,A
  INC L
  INC L
;Hat tiles: 1, 2, 3
  LD (HL),1
  INC L
  INC L
  INC L
  INC L
  LD (HL),2
  INC L
  INC L
  INC L
  INC L
  LD (HL),3
  INC L
;  LD H,>CoordArea
;Constants here because of test
  LD (HL),50
  DEC L
  DEC L
  LD (HL),90
  DEC L
  DEC L
  LD (HL),56
  DEC L
  DEC L
  LD (HL),90
  DEC L
  DEC L
  LD (HL),62
  DEC L
  DEC L
  LD (HL),90
  DEC L
  DEC L
  RET


;NEW: Dedicate hat and menu pointer, use remaining 36 sprite slots as
;fixed blocks of 6? Would work so far, since everything is multiple of 6
;except the hat and the kedama and the decorations, which could be fixed in
;a few ways. May limit our future creativity, but would guarantee contiguous
;sprite tiles for metasprites, and would fix data sizes for... anything really
;Definitions, animations, area would all be fixed.
.ENDS
