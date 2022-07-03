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
 .dw 120*3
 .dw %101
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

_Animations:
 .dw MarisaLeft
 .dw MarisaDown
 .dw MarisaRight
 .dw MarisaUp

_HatValues:
 .db 1
 .db 17
 .db 33
 .db 49

.ENDS

.SECTION "Hat" FREE

.DEFINE HatSig $C09E    ;To identify a data pointer as a hat
.EXPORT HatSig

HatActorData:
 .dw 0          ;Don't let Actor Control move the hat
 .dw %000
 .dw HatFrame
 .dw HeadPosTable
 .dw _Animations

HatFrame:
;Follow the character pointed to by DE
;If I collide with a danmaku, follow it instead
;If I am following nobody, follow the next character I collide with
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

_Animations:
 .dw HatLeft
 .dw HatDown
 .dw HatRight
 .dw HatUp

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
