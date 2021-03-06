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
;TODO: Move pausing authority to Marisa?

;Memory format:
.INCLUDE "ActorData.asm"

.DEFINE Speed 300
CharaFrame:
  CALL Actor_New
  LD HL,_HatVal
  ADD HL,DE
  LD (HL),1     ;Must make it nonzero
  LD HL,_Hitbox
  ADD HL,DE
  LD (HL),<PlayerHitboxes
  INC HL
  LD (HL),>PlayerHitboxes
;TODO:
    ;Destructor
    ;Hat play
    ;Action buttons
-
  CALL HaltTask
;Frame loop
;Handle messages
--
;Marisa specifc message
;Messages Marisa will care about:
    ;v: Cutscene control
    ;v: Play animation
    ;v: Destruct
  ;Cutscene detect
  LD HL,_ControlState
  ADD HL,DE
  LD A,(HL)
  INC A
  JP z,Actor_Delete
  DEC A
  AND $7F
  JR z,+
;Button check
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
  LD HL,_AnimChange
  ADD HL,DE
  ;Walking animation
  LD (HL),5
  RLA
  JR c,+++
  LD (HL),7
  RLA
  JR c,+++
  LD (HL),4
  RLA
  JR c,+++
  LD (HL),6
  JR +++
++  ;Standing animation
  LD A,(HL)
  LD HL,_AnimChange
  ADD HL,DE
  LD (HL),1
  RLA
  JR c,+++
  LD (HL),3
  RLA
  JR c,+++
  LD (HL),0
  RLA
  JR c,+++
  LD (HL),2
+++
+
  ;Anim change
  LD HL,_AnimChange
  ADD HL,DE
  LD A,$FF
  CP (HL)
  JR z,+
  LD C,(HL)
  LD (HL),A
  LD A,C
  ;Set Hatval
  AND $03
  ADD <_HatValues
  LD L,A
  LD A,0
  ADC >_HatValues
  LD H,A
  LD A,(HL)
  LD HL,_HatVal
  ADD HL,DE
  LD (HL),A
  LD A,C
  RLCA
  ADD <_Animations
  LD L,A
  LD A,0
  ADC >_Animations
  LD H,A
  LDI A,(HL)
  LD C,A
  LD A,(HL)
  LD B,A
  SCF
+
  ;Carry is set correctly for drawing, so keep it accessible
  PUSH AF
  ;Again; check for full control before moving in response to input
    LD HL,_ControlState
    ADD HL,DE
    LD A,(HL)
    AND $7F
    JR z,++
;Check for movement
    LDH A,($FE)
    AND $F0
    PUSH BC
    PUSH DE
      JR z,+++
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
      CALL Actor_Move
+++
;Other button checks
    POP DE
    POP BC
++
;Update buttonage
    LD HL,_ButtonState
    ADD HL,DE
    LDH A,($FE)
    LD (HL),A
  POP AF
  JP Actor_Draw

_charaMove


;Animation data
;Byte Order:
    ;Relative Y
    ;Relative X
    ;Tile
    ;Attribute
;All UDLR designations are screen-based
;See Actor.asm for change format
_DownWalk:
 .db 6
 .db  -8,-9,$69,%00100000  ;Head left
 .db  -8,-1,$68,%00100000  ;Head right
 .db  -6,-7,$6B,%00000000  ;Shoulder left
 .db  -6, 0,$6B,%00100000  ;Shoulder right
 .db   2,-7,$6E,%00000000  ;Leg left
 .db   2, 0,$70,%00100000  ;Leg right
_VertLoop:
 .db $53
 .db %11100000,%01010110,%11011010
 .db $74
 .db %00100000,%11010110,%01011010,$FF
 .dw _VertLoop
_UpWalk:
 .db 6
 .db  -8,-7,$6A,%00100000  ;Head left
 .db  -8, 1,$69,%00000000  ;Head right
 .db  -6,-7,$6C,%00100000  ;Shoulder left
 .db  -6, 0,$6C,%00000000  ;Shoulder right
 .db   2,-7,$6F,%00100000  ;Leg left
 .db   2, 0,$71,%00000000  ;Leg right
 .db $01
 .db $FF
 .dw _VertLoop
_LeftWalk:
 .db 4
 .db  -8, -4,$6D,%00100000  ;Head
 .db  -6, -5,$79,%00000000  ;Shoulder
 .db   2, -8,$73,%00100000  ;Leg left
 .db   2,  0,$72,%00100000  ;Leg right
_SideLoop:
 .db $63
 .db %00100000,%01001110,%01010010
 .db $43
 .db %11100000,%11001110,%11010010
 .db $55
 .db %00100000,%01001110,%01001110,%01010010,%01010010
 .db $54
 .db %11100000,%10001110,%10010010,$FF
 .dw _SideLoop
_RightWalk:
 .db 4
 .db  -8, -4,$78,%00100000  ;Head
 .db  -6, -5,$79,%00000000  ;Shoulder
 .db   2, -8,$72,%00000000  ;Leg left
 .db   2,  0,$73,%00000000  ;Leg right
 .db $01
 .db $FF
 .dw _SideLoop
_DownFace:
 .db 6
 .db  -8, -9,$69,%00100000  ;Head left
 .db  -8, -1,$68,%00100000  ;Head right
 .db  -6, -7,$6B,%00000000  ;Shoulder left
 .db  -6,  0,$6B,%00100000  ;Shoulder right
 .db   2, -7,$6E,%00000000  ;Leg left
 .db   2,  0,$6E,%00100000  ;Leg right
_IdleLoop:
 .db $F1
 .db $FF
 .dw _IdleLoop
_UpFace:
 .db 6
 .db  -8, -7,$6A,%00100000  ;Head left
 .db  -8,  1,$69,%00000000  ;Head right
 .db  -6, -7,$6C,%00100000  ;Shoulder left
 .db  -6,  0,$6C,%00000000  ;Shoulder right
 .db   2, -7,$6F,%00100000  ;Leg left
 .db   2,  0,$6F,%00000000  ;Leg right
 .db $F1
 .db $FF
 .dw _IdleLoop
_LeftFace:
 .db 4
 .db  -8, -4,$6D,%00100000  ;Head
 .db  -6, -5,$79,%00000000  ;Shoulder
 .db   2, -8,$73,%00100000  ;Leg left
 .db   2,  0,$72,%00100000  ;Leg right
 .db $F1
 .db $FF
 .dw _IdleLoop
_RightFace:
 .db 4
 .db  -8, -4,$78,%00100000  ;Head
 .db  -6, -5,$79,%00000000  ;Shoulder
 .db   2, -8,$72,%00000000  ;Leg left
 .db   2,  0,$73,%00000000  ;Leg right
 .db $F1
 .db $FF
 .dw _IdleLoop

_Animations:
 .dw _LeftFace
 .dw _DownFace
 .dw _RightFace
 .dw _UpFace
 .dw _LeftWalk
 .dw _DownWalk
 .dw _RightWalk
 .dw _UpWalk

_HatValues:
 .db 1
 .db 17
 .db 33
 .db 49

DefaultIdleAnim:
 .db $F1
 .db $FF
 .dw DefaultIdleAnim

.ENDS

.SECTION "Hat" FREE

.DEFINE HatSig $C09E    ;To identify a data pointer as a hat
.EXPORT HatSig

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
  CALL Actor_New
  ;Hitbox setup
  LD HL,_Hitbox
  ADD HL,DE
  LD (HL),<DefaultHitboxes
  INC HL
  LD (HL),>DefaultHitboxes
  ;Hat is global
  LD HL,HatSig
  LD A,E
  LDI (HL),A
  LD (HL),D
  ;Self-parenting
  LD HL,_ParentChar
  ADD HL,DE
  LD (HL),E
  INC HL
  LD (HL),D
  LD HL,_HatVal
  ADD HL,DE
  LD (HL),0
  CALL HaltTask
  ;Enforce drawing at top sprites (the Hat Hack)
  LD A,0
  LD (DE),A
  INC DE
  LD A,$CF
  LD (DE),A
  DEC DE
  ;Check for doing AI stuffs here
;Hat specific messages
    ;v: Destruct
  ;Destruct detect
  LD HL,_ControlState
  ADD HL,DE
  LD A,(HL)
  INC A
  JP z,Actor_Delete
  ;Exist based on parent's location
  LD HL,_ParentChar
  ADD HL,DE
  LDI A,(HL)
  LD B,(HL)
  LD C,A
  INC BC
  INC BC
  LD HL,_MasterX
  ADD HL,DE
  LD A,(BC)
  LDI (HL),A
  INC BC
  LD A,(BC)
  LDI (HL),A
  INC BC
  LD A,(BC)
  LDI (HL),A
  INC BC
  LD A,(BC)
  LD (HL),A
  LD A,_HatVal-5
  ADD C
  LD C,A
  LD A,0
  ADC B
  LD B,A
  LD A,(BC)
  LD HL,_HatVal
  ADD HL,DE
  CP (HL)
  JR z,+
  ;New anim
  LD (HL),A
  AND $F0
  SWAP A
  LD HL,_AnimChange
  ADD HL,DE
  LD (HL),A
+ ;Actor specific placement adjustment
  LD HL,_MasterY+1
  ADD HL,DE
  LD A,(BC)
  AND $0F
  RLA
  ADD <HeadPosTable
  LD C,A
  LD A,>HeadPosTable
  ADC 0
  LD B,A
  LD A,(BC)
  INC BC
  ADD (HL)
  LDD (HL),A
  DEC HL
  LD A,(BC)
  ADD (HL)
  LD (HL),A
;Anim check
  LD A,$FF
  LD HL,_AnimChange
  ADD HL,DE
  CP (HL)
  JR z,+
  ;Change animation
  LD C,(HL)
  LD (HL),A
  ;Send new anim pointer
  LD A,C
  RLA
  ADD <_Animations
  LD L,A
  LD A,>_Animations
  ADC 0
  LD H,A
  LDI A,(HL)
  LD B,(HL)
  LD C,A
  SCF   ;New animation
+
  ;Carry correct b/c CMP against $FF
  JP Actor_Draw

;Table of positions and tile choices for the hat, when it finds a head tile

;Tip, left, right, side edge
;Universal order: Left/Down/Right/Up
_Left:
 .db 4
 .db -1, 1,$01,%00000000    ;Tip
 .db  1,-4,$64,%00000000    ;Left
 .db  1, 4,$65,%00000000    ;Right
 .db  5,-6,$01,%00000000    ;Side
 .db $F1
 .db $FF
 .dw DefaultIdleAnim
_Down:
 .db 3
 .db  -2, 1,$01,%00000000
 .db  -0,-9,$62,%00000000
 .db  -0,-1,$63,%00000000
 .db $F1
 .db $FF
 .dw DefaultIdleAnim
_Right:
 .db 4
 .db -1, -4,$01,%00000000
 .db  1,-12,$65,%00100000
 .db  1, -4,$64,%00100000
 .db  4,  3,$01,%00000000
 .db $F1
 .db $FF
 .dw DefaultIdleAnim
_Up:
 .db 3
 .db  -2,-3,$01,%00000000
 .db  -0,-7,$66,%00000000
 .db  -0, 1,$67,%00000000
 .db $F1
 .db $FF
 .dw DefaultIdleAnim

_Animations:
 .dw _Left
 .dw _Down
 .dw _Right
 .dw _Up

;Character offset value
HeadPosTable:
;Y,X
 .db    0, 0    ;None
 .db  -12, 0    ;Marisa
 .db  -12, 0    ;Fairy
 .db  -10, 0    ;Narumi
 .db  -16, 0    ;Alice
 .db  -14, 0    ;Reimu
 .db    0, 0    ;Danmaku

.ENDS
