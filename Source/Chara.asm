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
;TODO: NEW: Start Marisa and hat in Cutscene mode
;TODO: Move pausing authority to Marisa?

;Memory format:
.INCLUDE "ActorData.asm"

.DEFINE Speed 100
CharaFrame:
;A = initial facing
    ;0 = right
    ;1 = left
    ;2 = up
    ;3 = down
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
  PUSH AF
    CALL Actor_New
    LD HL,_ButtonState
    ADD HL,DE
  POP AF
  LD (HL),A
  LD HL,_HatVal
  ADD HL,DE
  LD (HL),1     ;Must make it nonzero
  LD HL,_Hitbox
  ADD HL,DE
  LD (HL),<CollisionHitbox
  INC HL
  LD (HL),>CollisionHitbox
  LD HL,_AnimSpeed
  ADD HL,DE
  LD (HL),$10
  INC HL
  LD (HL),<Speed
  INC HL
  LD (HL),>Speed
;TODO:
    ;Destructor
    ;Hat play
    ;Action buttons
-
  CALL HaltTask
;Frame loop
;Handle messages
--
  CALL Actor_Message
  JR c,+
;Marisa specifc message
;Messages Marisa will care about:
    ;x: Cutscene control
    ;x: Play animation
    ;x: Destruct
+   ;No Marisa messages
  LD HL,_ButtonState
  ADD HL,DE
  LDH A,($FE)
  XOR (HL)  ;Get direction button delta
  AND $F0
  JR z,+
;New animation
;Buttons still held mean walking animation
  LDH A,($FE)
  AND $F0
;Otherwise, buttons previously held mean standing animation
  JR z,++
  LD HL,_HatVal
  ADD HL,DE
  ;Walking animation
  LD BC,_DownWalk
  LD (HL),1
  RLA
  JR c,+++
  LD BC,_UpWalk
  LD (HL),17
  RLA
  JR c,+++
  LD BC,_LeftWalk
  LD (HL),33
  RLA
  JR c,+++
  LD BC,_RightWalk
  LD (HL),49
  JR +++
++  ;Standing animation
  LD A,(HL)
  LD HL,_HatVal
  ADD HL,DE
  LD BC,_DownFace
  LD (HL),1
  RLA
  JR c,+++
  LD BC,_UpFace
  LD (HL),17
  RLA
  JR c,+++
  LD BC,_LeftFace
  LD (HL),33
  RLA
  JR c,+++
  LD BC,_RightFace
  LD (HL),49
+++
  SCF
+
  ;Carry is set correctly, so draw this frame
  PUSH DE
  CALL Actor_Draw
  POP DE
;Check for movement
  LD HL,_ButtonState
  ADD HL,DE
  LDH A,($FE)
  AND $F0
  LD (HL),A
  RET z
;Direction is being pressed if not zero
;Move handles 0 just fine, though
;DE-> Actor data
;A  = Movement direction
    ;%DULR0000
  LD HL,_MoveSpeed
  ADD HL,DE
  LD C,(HL)
  INC HL
  LD B,(HL)
  LD H,D    ;Move Actor data pointer to HL
  LD L,E
  LD DE,0
  PUSH AF
    AND $C0
    JR z,+
    LD D,B
    LD E,C
    RLA
    JR c,+
    LD A,D    ;Negate for up (More accurately, "not down")
    CPL
    LD D,A
    LD A,E
    CPL
    LD E,A
    INC DE
+
  POP AF
  AND $30
  JR nz,+ ;Are any LR buttons pressed?
  LD BC,0 ;No, don't move along X axis
+
  AND $20
  JR z,+  ;Is left pressed (necessitating a negate)?
  LD A,B
  CPL
  LD B,A
  LD A,C
  CPL
  LD C,A
  INC BC
+
  JP Actor_Move


;Animation data
;Byte Order:
    ;Relative Y
    ;Relative X
    ;Tile
    ;Attribute
;All UDLR designations are screen-based
;See Actor.asm for change format
_DownWalk:
 .db -10,-9,$69,%00100000  ;Head left
 .db -10,-1,$68,%00100000  ;Head right
 .db  -8,-7,$6B,%00000000  ;Shoulder left
 .db  -8, 0,$6B,%00100000  ;Shoulder right
 .db   0,-7,$6E,%00000000  ;Leg left
 .db   0, 0,$70,%00100000  ;Leg right
_VertLoop:
 .db $53
 .db %11100000,%01010110,%11011010
 .db $74
 .db %00100000,%11010110,%01011010,$FF
 .dw _VertLoop
_UpWalk:
 .db -10,-7,$6A,%00100000  ;Head left
 .db -10, 1,$69,%00000000  ;Head right
 .db  -8,-7,$6C,%00100000  ;Shoulder left
 .db  -8, 0,$6C,%00000000  ;Shoulder right
 .db   0,-7,$6F,%00100000  ;Leg left
 .db   0, 0,$71,%00000000  ;Leg right
 .db $01
 .db $FF
 .dw _VertLoop
_LeftWalk:
 .db -10, -4,$6D,%00100000  ;Head
 .db   0,  0,$03,%00000000  ;Hide Sprite
 .db  -8, -5,$79,%00000000  ;Shoulder
 .db   0,  0,$03,%00000000  ;Hide sprite
 .db   0, -8,$73,%00100000  ;Leg left
 .db   0,  0,$72,%00100000  ;Leg right
_SideLoop:
 .db $63
 .db %00100000,%01010110,%01011010
 .db $43
 .db %11100000,%11010110,%11011010
 .db $55
 .db %00100000,%01010110,%01010110,%01011010,%01011010
 .db $54
 .db %11100000,%10010110,%10011010,$FF
 .dw _SideLoop
_RightWalk:
 .db -10, -4,$78,%00100000  ;Head
 .db   0,  0,$03,%00000000  ;Hide Sprite
 .db  -8, -5,$79,%00000000  ;Shoulder
 .db   0,  0,$03,%00000000  ;Hide sprite
 .db   0, -8,$72,%00000000  ;Leg left
 .db   0,  0,$73,%00000000  ;Leg right
 .db $01
 .db $FF
 .dw _SideLoop
_DownFace:
 .db -10,-9,$69,%00100000  ;Head left
 .db -10,-1,$68,%00100000  ;Head right
 .db  -8,-7,$6B,%00000000  ;Shoulder left
 .db  -8, 0,$6B,%00100000  ;Shoulder right
 .db   0,-7,$6E,%00000000  ;Leg left
 .db   0, 0,$6E,%00100000  ;Leg right
_IdleLoop:
 .db $F1
 .db $FF
 .dw _IdleLoop
_UpFace:
 .db -10,-7,$6A,%00100000  ;Head left
 .db -10, 1,$69,%00000000  ;Head right
 .db  -8,-7,$6C,%00100000  ;Shoulder left
 .db  -8, 0,$6C,%00000000  ;Shoulder right
 .db   0,-7,$6F,%00100000  ;Leg left
 .db   0, 0,$6F,%00000000  ;Leg right
 .db $F1
 .db $FF
 .dw _IdleLoop
_LeftFace:
 .db -10, -4,$6D,%00100000  ;Head
 .db   0,  0,$03,%00000000  ;Hide Sprite
 .db  -8, -5,$79,%00000000  ;Shoulder
 .db   0,  0,$03,%00000000  ;Hide sprite
 .db   0, -8,$73,%00100000  ;Leg left
 .db   0,  0,$72,%00100000  ;Leg right
 .db $F1
 .db $FF
 .dw _IdleLoop
_RightFace:
 .db -10, -4,$78,%00100000  ;Head
 .db   0,  0,$03,%00000000  ;Hide Sprite
 .db  -8, -5,$79,%00000000  ;Shoulder
 .db   0,  0,$03,%00000000  ;Hide sprite
 .db   0, -8,$72,%00000000  ;Leg left
 .db   0,  0,$73,%00000000  ;Leg right
 .db $F1
 .db $FF
 .dw _IdleLoop

DefaultHitboxes:
 .db 1
 .dw $0000,$0000,$0300
 .dw DefaultHitboxAction
DefaultHitboxAction:
  RET

CollisionHitbox:
 .db 1
 .dw $0000,$FC00,$0501  ;Lo byte radius type 1 is hitbox
 .dw CollisionHitboxAction
CollisionHitboxAction:
;We have
  ;Distance we want to be from other actor
  ;Our hitbox position
  ;Their hitbox position
;We need
  ;Position we want to move
;We can get it via
  ;Finding our hitbox position in polar, and using distance to find delta
  ;Finding our preferred X and Y position, and use our hitbox for finding delta
    ;Problem: Distance gives us magnitude, but not angle
  ;Call vec CORDIC on current XY distance
  ;Use theta value, call rot CORDIC on ideal distance
  ;Subtract ideal XY distance from current XY distance
  ;or...
  ;Call vec CORDIC on current XY distance
  ;Subtract current distance from ideal distance
  ;Call rot CORDIC on delta XY distance

  ;Check if our argument is also a collision hitbox
  LD HL,SP+4    ;Their hitbox
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  DEC HL
  DEC HL
  LD A,(HL)
  AND $01   ;Hitbox type check
  XOR $01
  RET nz

;Squares instead of circles:
  ;Push actors only on the most convenient axis (largest)
  ;So, find the axis with the greatest separation
  PUSH BC
    LD HL,SP+4    ;DE-> Our hitbox
    LDI A,(HL)
    SUB 6 ;Get to the bottom of the hitbox data
    LD E,A
    LDI A,(HL)
    SBC 0
    LD D,A
    LDI A,(HL)    ;HL-> Their hitbox
    SUB 6
    LD C,A
    LD A,(HL)
    LD L,C
    SBC 0
    LD H,A
    LD A,(DE)     ;Get X delta
    SUB (HL)
    LD C,A
    INC DE
    INC HL
    LD A,(DE)
    SBC (HL)
    LD B,A
    INC DE
    INC HL
    PUSH BC
      LD A,(DE)   ;Get Y delta
      SUB (HL)
      LD C,A
      INC DE
      INC HL
      LD A,(DE)
      SBC (HL)
      LD B,A
      INC DE
      INC HL
      PUSH BC
        LD A,(DE)   ;Get hitbox delta
        ADD (HL)
        INC DE
        INC HL
        LD C,A
        LD A,(DE)
        ADC (HL)
        LD D,A
        LD E,C
      POP HL
      ;Our radius should be reduced by the absolute value of
      ;our current delta, and take its sign
      ;A way is to negate current delta, and add radius with opposite sign
      ;Movement = DeltaSign * (Radius - |Delta|)
      ;Movement = DeltaSign * Radius - Delta
      ;Movement = DeltaSign * Radius + -1 * Delta
    POP BC
    ;HL = Delta Y
    ;DE = Radius
    ;BC = Delta X
    PUSH DE
      ;Find the greater axis
      LD A,B
      BIT 7,A
      JR z,+
      CPL
      INC A
+
      LD D,A
      LD A,H
      BIT 7,A
      JR z,+
      CPL
      INC A
+
      CP D
      JR c,+    ;Jump for larger X movement
      ;Y movement larger
      LD D,H
      LD E,L
      ;Move, along the direction of DE, to half the distance to the radius size
    POP HL
    XOR A
    LD B,A  ;Zero BC
    LD C,A
    BIT 7,D
    JR z,++
    ;Negate radius
    SUB L
    LD L,A
    LD A,B
    SBC H
    LD H,A
++
    ;Subtract DE from radius
    LD A,L
    SUB E
    LD E,A
    LD A,H
    SBC D
    LD D,A
    ;Move half distance, since other object will too
    SRA D
    RR E
  POP HL
  JP Actor_Move
+   ;X movement larger
    POP HL
    XOR A
    LD D,A  ;Zero DE
    LD E,A
    BIT 7,B
    JR z,++
    ;Negate radius
    SUB L
    LD L,A
    LD A,D
    SBC H
    LD H,A
++
    ;Subtract BC from radius
    LD A,L
    SUB C
    LD C,A
    LD A,H
    SBC B
    LD B,A
    ;Move half distance
    SRA B
    RR C
  POP HL
  JP Actor_Move

.ENDS

.SECTION "Hat" FREE

HatFrame:
;Follow the character pointed to by DE
;If I collide with another character, follow them instead
;If I collide with a danmaku, follow it instead
;If what I'm following disappears, fall N pixels and stay put
    ;How do I know if they die?
    ;We'll set up the destructor to clear Hitbox
    ;Thus, if the chara's hitbox disappears, fall
;TODO:
    ;Detect a change in parent
        ;Do via collision
  LD A,B
  LD (Cutscene_Actors),A
  CALL Actor_New
  INC DE
  LD A,$CF      ;Constant sprite pointer
  LD (DE),A
  DEC DE
  XOR A
  LD (DE),A
  LD HL,_ParentChar
  ADD HL,DE
  LD (HL),E     ;No parent, so make ourselves the parent
  INC HL
  LD (HL),D
  LD HL,_Hitbox
  ADD HL,DE
  LD (HL),<CollisionHitbox
  INC HL
  LD (HL),>CollisionHitbox
  LD HL,_HatVal
  ADD HL,DE
  LD (HL),0
  CALL HaltTask
;DE->Actor data
;Override automatic sprite hiding
  INC DE
  LD A,$CF      ;Constant sprite pointer
  LD (DE),A
  DEC DE
;Copy our character's position
  LD HL,_ParentChar
  ADD HL,DE
  LDI A,(HL)
  LD C,A
  LD B,(HL)
  PUSH DE
  INC DE
  INC DE
  LD HL,_MasterX
  ADD HL,BC
  LDI A,(HL)
  LD (DE),A
  INC DE
  LDI A,(HL)
  LD (DE),A
  INC DE
  LDI A,(HL)
  LD (DE),A
  INC DE
  LD A,(HL)
  LD (DE),A
  POP DE
;Find the hat value
  LD HL,_HatVal
  ADD HL,BC
  LD A,(HL)
  PUSH AF
;Set relational data to the proper table
  LD BC,HeadDataTable
  AND $F0   ;Multiples of 16
  LD L,A
  LD H,0
  ADD HL,BC
  LD B,H
  LD C,L
  LD HL,_RelData
  ADD HL,DE
  LD (HL),C
  INC HL
  LD (HL),B
;Edit hat's position based on table
  LD BC,HeadPosTable
  POP AF
  AND $0F
  RLCA
  LD L,A
  LD H,0
  ADD HL,BC
  LD B,H
  LD C,L
  LD HL,_MasterY+1
  ADD HL,DE
  LD A,(BC)
  INC BC
  ADD (HL)
  LDD (HL),A
  DEC HL
  LD A,(BC)
  ADD (HL)
  LD (HL),A
+   ;Draw
  LD A,4
  JP HatDrawHackEntry

.ENDS

.SECTION "HatData" FREE
;Table of positions and tile choices for the hat, when it finds a head tile
HeadDataTable:
;Tile and position choice
;Tip, left, right, side edge
 .db -7, 1,$67,%00000000,-0, -9,$61,%00000000,-0,-1,$62,%00000000,-16,-0,$03,%00000000   ;down
 .db -7,-3,$67,%00000000,-0, -7,$65,%00000000,-0, 1,$66,%00000000,-32,-0,$03,%00000000   ;up
 .db -6, 1,$67,%00000000, 1, -4,$63,%00000000, 1, 4,$64,%00000000, -0,-6,$67,%00000000   ;left
 .db -6,-4,$67,%00000000, 1,-12,$64,%00100000, 1,-4,$63,%00100000, -1, 3,$67,%00000000   ;right
;Character offset value
HeadPosTable:
;Y,X
 .db    0, 0    ;None
 .db  -14, 0    ;Marisa
 .db  -12, 0    ;Fairy
 .db  -10, 0    ;Narumi
 .db  -16, 0    ;Alice
 .db  -14, 0    ;Reimu
 .db    0, 0    ;Danmaku

;NEW: Dedicate hat and menu pointer, use remaining 36 sprite slots as
;fixed blocks of 6? Would work so far, since everything is multiple of 6
;except the hat and the kedama and the decorations, which could be fixed in
;a few ways. May limit our future creativity, but would guarantee contiguous
;sprite tiles for metasprites, and would fix data sizes for... anything really
;Definitions, animations, area would all be fixed.
.ENDS
