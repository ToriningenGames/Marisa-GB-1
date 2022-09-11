.include "actorData.asm"

;There is a need for 3 types of collision:
    ;Pushing (Fairies, Marisa to Fairies, Marisa)
    ;Hits (Danmaku to Marisa/Hat)
    ;Interaction (Marisa to various)

;Each type is similar, but because collision checks are expensive,
    ;as many unnecessary checks need to be eliminated as possible.
;Additionally, the prior detector was fragile,
    ;with garbage data from stale actors often resulting in a crash
;Separating the different types ensures only sensible collisions are checked
;and minimizes the number of actor changes that result in crashes.

;Stability will be enhanced with explicit calls to enter and exit collision lists
;Therefore, actors only exist in the list when valid
;Visual culling still occurs when the calls are made as appropriate.

;The only relevant information are where actors are, and what to do on hit.
    ;For interactions, a detect can merely provide the actor ID back to Marisa
    ;For pushes, the two actors need to be pushed back
    ;For hits, that interaction isn't defined yet
;Pushes and hits detection can run every frame, or every other
;Interactions detection runs whenever Marisa asks for it (on A press)
;Existing non-pushing actors can (almost) be replaced with static room boxes
    ;(Reimu's missing after her subplot is done, so the room would be passable there)

;How to make Reimu collidable but not pushable
;Edit Collision map to make Reimu collidable
;  LD HL,ColArea+45
;  LD (HL),$FF
;  ADD HL,ColArea+45+4
;  LD (HL),$FF

;At least 8
;At most 64
;Do not cross a page boundary
.DEFINE HitboxPushStart     $C400
.DEFINE HitboxPushEnd       $C4FF
.DEFINE HitboxPushCount     $C0EB
.DEFINE HitboxPushSize      $04
    ;X Position
    ;Y Position
    ;Actor data pointer lo
    ;Actor data pointer hi
;At least 4
.DEFINE HitboxInteractStart $C500
.DEFINE HitboxInteractEnd   $C5FF
.DEFINE HitboxInteractCount $C0EC
;At least 64
.DEFINE HitboxHitStart      $C600
.DEFINE HitboxHitEnd        $C6FF
.DEFINE HitboxHitCount      $C0ED

.SECTION "Collision" FREE

HitboxHitAdd:
;DE=Actor to add
  LD L,<HitboxHitCount
  LD H,>HitboxHitStart

HitboxInteractAdd:
;DE=Actor to add
;BC=Cutscene to run
  LD L,<HitboxInteractCount
  LD H,>HitboxInteractStart
  JR _hitboxAdd

HitboxPushAdd:
;DE=Actor to add
  LD L,<HitboxPushCount
  LD H,>HitboxPushStart
  LD B,D
  LD C,E
_hitboxAdd:
  PUSH DE
    PUSH HL
      LD H,>HitboxPushCount
      LD A,(HL)
      INC (HL)
      ADD A
      ADD A
    POP HL
    LD L,A
    INC DE
    INC DE
    INC DE
    LD A,(DE)
    LDI (HL),A
    INC DE
    INC DE
    LD A,(DE)
    LDI (HL),A
  POP DE
  LD (HL),C
  INC HL
  LD (HL),B
  RET

HitboxUpdate_Task:
  CALL HitboxPush
  XOR A
  LD HL,HitboxPushCount
  LDI (HL),A
  LDI (HL),A
  LDI (HL),A
  RET

HitboxPush:
  ;Only try if there are 2+ hitboxes
  LD A,(HitboxPushCount)
  SUB 1
  RET z
  RET c
  LD C,A
  LD B,1
--
  LD DE,HitboxPushStart
  LD A,C
  ADD A
  ADD A
  LD L,A
  LD H,>HitboxPushStart
  PUSH BC
-
    LD A,(DE)   ;Dirty approximation of euclidean distance (manhattan)
    SUB (HL)
    BIT 7,A
    JR z,+
    CPL
    INC A
+
    INC E
    INC L
    LD C,A
    LD A,(DE)
    SUB (HL)
    BIT 7,A
    JR z,+
    CPL
    INC A
+
    ADD C
    CP 8
    JR nc,+
    ;Push these actors half the computed distance
    ;Use the sign of the deltas to determine addition or subtraction
    LD A,(DE)
    SUB (HL)
    PUSH HL
    PUSH DE
      ;Push to 8
      ADD -8
      CPL
      INC A
      BIT 7,A
      JR z,++
      XOR A
++
      JR nc,++  ;Was delta below zero?
      ;Value was negative; correct it
      SUB 16
      JR c,++
      XOR A     ;X too distant; don't move it
++
      PUSH AF
        DEC E
        DEC L
        LD A,(DE)
        SUB (HL)
        ;Push to 8
        ADD -8
        CPL
        INC A
        BIT 7,A
        JR z,++
        XOR A
++
        JR nc,++
        ;Value was negative; correct it
        SUB 16
        JR c,++
        XOR A
++
        PUSH AF
          INC DE
          INC DE
          INC HL
          INC HL
          LDI A,(HL)
          LD H,(HL)
          LD L,A
          PUSH HL
            LD A,(DE)
            INC DE
            LD L,A
            LD A,(DE)
            LD H,A
            LD DE,3
            ADD HL,DE
          POP DE
          INC DE
          INC DE
          INC DE
          ;X push
          ;The pointers are backwards, so (HL) moves with the sign and (DE) moves against
        POP AF
        SRA A
        SRA A
        LD C,A
        ADD (HL)
        LDI (HL),A
        LD A,(DE)
        SUB C
        LD (DE),A
        INC DE
        INC DE
        INC HL
        ;Y push
      POP AF
      SRA A
      SRA A
      LD C,A
      ADD (HL)
      LDI (HL),A
      LD A,(DE)
      SUB C
      LD (DE),A
    POP DE
    POP HL
+
    INC E
    INC E
    INC E
    INC L
    INC L
    INC L
    DEC B
    JR nz,-
  POP BC
  INC B
  DEC C
  JP nz,--
  RET

HitboxHit:
  RET

HitboxInteract:
  LD A,(HitboxInteractCount)
  OR A
  RET z
  PUSH DE
;Get the relevant point
    LD HL,_AnimID
    ADD HL,DE
    INC DE
    INC DE
    INC DE
    LD A,(DE)
    LD B,A
    INC DE
    INC DE
    LD A,(DE)
    LD C,A
    ;Positive or negative change?
    LD A,(HL)
    AND $03
    JR z,+
    XOR $03
    JR z,+
    ;Positive change
    LD A,10
    .db $CA     ;Skip next instruction (as a JP z,$nnnn)
+   ;Negative change
    LD A,-10
    ;X or Y?
    BIT 0,(HL)
    JR z,+
    ;Y change
    ADD C
    LD C,A
    .db $CA     ;Skip next instruction pair (as a JP z,$nnnn)
+   ;X change
    ADD B
    LD B,A
;Got point in BC
;For each hitbox:
    LD A,(HitboxInteractCount)
    LD E,A
    LD HL,HitboxInteractStart
-
    LDI A,(HL)  ;Dirty approximation of euclidean distance (manhattan)
    SUB B
    BIT 7,A
    JR z,+
    CPL
    INC A
+
    LD D,A
    LDI A,(HL)
    SUB C
    BIT 7,A
    JR z,+
    CPL
    INC A
+
    ADD D
    CP 12
    JR nc,+
    ;Point hit
    LDI A,(HL)
    LD D,(HL)
    LD E,A
    LD BC,Cutscene_Task
    RST $28
    LD E,1
+
    INC L
    INC L
    DEC E
    JR nz,-
  ;No point hit
  POP DE
  RET

.ENDS
