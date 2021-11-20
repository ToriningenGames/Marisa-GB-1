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

CharaActorData:
 .db $10
 .dw 300
 .dw PlayerHitboxes
 .dw CharaFrame
 .dw _HatValues
 .dw _Animations

CharaFrame:
;Perform movement
  LDH A,($FE)
  LD C,A
  LD A,%00110000        ;L/R
  AND C
  SWAP A        ;put L/R in lo nibble
  LD B,A
  XOR A         ;Swap D/U and put in hi nibble
  RL C
  RRA
  RL C
  RRA
  RRA
  RRA
  OR B  ;Compound
  RET


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

HatActorData:
 .db $10
 .dw 0          ;Don't let Actor Control move the hat
 .dw DefaultHitboxes
 .dw HatFrame
 .dw HeadPosTable
 .dw _Animations

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
  ;Hat is global
  LD HL,HatSig
  LD A,E
  LDI (HL),A
  LD (HL),D
  ;Enforce drawing at top sprites (the Hat Hack)
  LD A,0
  LD (DE),A
  INC DE
  LD A,$CF
  LD (DE),A
  DEC DE
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
  LD A,_HatVal-_MasterY-1
  ADD C
  LD C,A
  JR nc,+
  INC B
+
  LD A,(BC)
  LD HL,_HatVal
  ADD HL,DE
;HatVal adjustment and facing consideration
  LD (HL),A
  AND $F0
  SWAP A
  ;LDRU -> %00UD00LR
  LD L,A
  LD A,%00010000
  DEC L
  JR z,+
  LD A,%00000001
  DEC L
  JR z,+
  LD A,%00100000
  DEC L
  JR z,+
  LD A,%00000010
+
  PUSH AF
    ;Actor specific placement adjustment
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
  POP AF
  RET

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
