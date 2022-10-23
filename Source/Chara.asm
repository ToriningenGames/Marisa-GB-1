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

.DEFINE PlayerButtonBuf $C0E6

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
 .dw 120*2
 .db %101
 .db $00
 .dw CharaFrame
 .dw _HatValues
 .dw _Animations

CharaFrame:
  CALL HitboxPushAdd
;Check interations
  ;Only talk if freshly interacting
  LDH A,($FE)
  LD HL,PlayerButtonBuf
  XOR (HL)
  AND %00000001
  CALL nz,HitboxInteract
  ;Since interactions are checked, we can clear the list
  XOR A
  LD (HitboxInteractCount),A
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

.DEFINE Hitstun $C01E
.EXPORT Hitstun

;This is what happens when a danmaku hits Marisa
Hit_Task:
  ;D=X of attack source direction
;Is Marisa wearing her hat?
  LD HL,HatSig
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  LD BC,_ParentChar
  ADD HL,BC
  LDI A,(HL)
  LD B,(HL)
  LD C,A
  LD A,(Cutscene_Actors+1)
  CALL Access_ActorDE
  LD A,L    ;Trick to check if two pointers are the same
  XOR C     ;Works since there's less than 256 possible memory pointers, and they all use different bits
  XOR H     ;Done here so the check can be reversed to a pointer equality check over inequality
  XOR B
  JR z,+
;Marisa not wearing her hat. Push her back
  LD A,20
  LD (Hitstun),A
  LD C,15
-
  RST $00
  ;Hold still for a bit?
  LDH A,($FE)
  AND %00001111
  LDH ($FE),A
  DEC C
  JR nz,-
  JP EndTask
+
;Marisa wearing her hat. Make it fly away
  ;Free hat
  LD HL,HatSig
  LDI A,(HL)
  LD B,(HL)
  LD C,A
  LD HL,_ParentChar
  ADD HL,BC
  LD A,C
  LDI (HL),A
  LD (HL),B
  LD A,60
  LD (Hitstun),A
  LD A,1
  LD ($C0D0),A
  LD HL,_HatVal
  ADD HL,BC
  LD A,(HL)
  AND $30
  LD (HL),A
  ;Hi hat
  PUSH BC
  PUSH DE
    LD D,B
    LD E,C
    CALL Actor_HighPriority
  POP DE
  POP BC
  ;Fly at a 45 degree angle away from the danmaku source
  LD A,D
  LD DE,$20E0
  BIT 7,A
  JR z,++
  LD D,$E0
++
-
  RST $00
  ;Hat speen
  ;Once every 20 frames
  LD HL,$C0D0
  DEC (HL)
  JR nz,++
  LD (HL),9
  LD HL,_HatVal
  ADD HL,BC
  LD A,(HL)
  ADD $10
  AND $30
  LD (HL),A
++
  ;Parabolic arc, via moving constant X and incremented Y each frame
  ;Finish once either X under/overflows or Y overflows (NOT under)
  INC E
  LD HL,_MasterX
  ADD HL,BC
  PUSH DE
    LD A,D
    RLCA
    RLCA
    LD D,A
    AND $03
    BIT 1,A
    JR z,++
    OR $FC
++
    LD E,A
    LD A,$FC
    AND D
    ADD (HL)
    LDI (HL),A
    LD A,E
    ADC (HL)
    LDI (HL),A
    BIT 7,E       ;End when we cross 0
  POP DE
  JR z,++
  JR nc,+++
  .db $D2       ;Skip the following conditional jump with JP nc,xxxx (guaranteed to miss)
++
  JR c,+++
  PUSH DE
    LD A,E
    RLCA
    RLCA
    LD E,A
    AND $03
    BIT 1,A
    JR z,++
    OR $FC
++
    LD D,A
    LD A,$FC
    AND E
    ADD (HL)
    LDI (HL),A
    LD A,D
    ADC (HL)
    LD (HL),A
    BIT 7,E       ;End only if Y overflows
  POP DE
  JR nz,-   ;Not done if moving up
  JR nc,-
+++
  ;Finished moving off screen; now the hat dies :(
  ;(do this using the cutscene function... sneakily)
  LD BC,$FF00
  CALL ChangeControl+2  ;skip the read part of the cutscene function
  JP EndTask

.ENDS

.SECTION "Hat" FREE

.DEFINE HatSig $C09E    ;To identify a data pointer as a hat
.EXPORT HatSig

_hatHatVals:
.db $00,$10,$20,$30

HatActorData:
 .dw 0          ;Don't let Actor Control move the hat
 .dw %000
 .dw HatFrame
 .dw _hatHatVals
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
  XOR A
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
  POP HL    ;Return
  LD C,0
  JP ActorHatRet

_Animations:
 .dw HatLeft
 .dw HatDown
 .dw HatRight
 .dw HatUp

;Character offset value
HeadPosTable:
;Y,X
 .db    0,  0    ;None
 .db  -12,  0    ;Marisa
 .db  -12,  0    ;Fairy
 .db  -15,  0    ;Narumi
 .db  -16,  0    ;Alice
 .db  -13,  0    ;Reimu
 .db   -8, -3    ;Mushroom

.ENDS
