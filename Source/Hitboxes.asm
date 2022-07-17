;Hitboxes
;For keeping things from phasing, and for limiting telepathy

.include "actorData.asm"

.DEFINE HitboxStart     $C400
.DEFINE HitboxEndPtr    $C0EC


;This is size of BOTH hiboxes together when colliding!
;This value is also negative
.DEFINE MasterHitboxSize $C01C

.SECTION "Collision" FREE
;Basic idea:
;We check every pair of actors once (O(n log n))
;If the pair can collide, we check their distance using Manhattan geometry
;If their distance is less the the Master size, they are pushed apart on the easiest axis (smallest push)
;If they can both be pushed, the distance is split between the two
;Two immovables is accomodated.

HitboxUpdate_Task:
  ;Number of actors (and thus location of last actor)
  LD A,(ObjUse)
  ADD A     ;2 bytes per actor
  RET z     ;0 actors. No hitboxes
  ADD <ActiveActorArray
  LD C,A
  LD B,>ActiveActorArray
-
  ;Next "first" actor
  DEC BC
  DEC BC
  LD A,C
  CP <ActiveActorArray
  RET z     ;Hit end of effective list with "first" actor, due to no seconds
  ;Does the actor collide?
  LD A,(BC)
  INC BC
  LD L,A
  LD A,(BC)
  DEC BC
  LD H,A
  LD DE,_Hitbox
  ADD HL,DE
  BIT 0,(HL)
  JR z,-
  ;Actor can collide; compare to the rest
  LD D,B
  LD E,C
--
  ;Next "second" actor
  DEC DE
  DEC DE
  LD A,E
  CP <ActiveActorArray
  JR c,-    ;Hit end of list
  LD A,(DE)
  INC DE
  LD L,A
  LD A,(DE)
  DEC DE
  LD H,A
  PUSH DE
    LD DE,_Hitbox
    ADD HL,DE
  POP DE
  BIT 0,(HL)
  JR z,--
  PUSH BC
  PUSH DE
    ;Get from actor slots to actual data
    LD A,(BC)
    INC BC
    LD L,A
    LD A,(BC)
    LD B,A
    LD C,L
    LD A,(DE)
    INC DE
    LD L,A
    LD A,(DE)
    LD D,A
    LD E,L
    ;Compare distances
    ;Manhattan is cheaper
    INC BC
    INC BC
    INC BC
    INC DE
    INC DE
    INC DE  ;Master X int parts
    LD A,(BC)
    LD L,A
    LD A,(DE)
    SUB L
    JR nc,+
    ;Positive delta only
    CPL
    INC A
+
    LD H,A
    INC BC
    INC BC
    INC DE
    INC DE  ;Master Y int parts
    LD A,(BC)
    LD L,A
    LD A,(DE)
    SUB L
    JR nc,+
    ;Positive delta only
    CPL
    INC A
+
    ADD H
    LD L,A
    LD A,(MasterHitboxSize)
    SUB L
  POP DE
  POP BC
  JR c,--
  ;Collided, move them apart
  PUSH BC
  PUSH DE
    PUSH AF
      ;Get from actor slots to actual data
      LD A,(BC)
      INC BC
      LD L,A
      LD A,(BC)
      LD B,A
      LD C,L
      LD A,(DE)
      INC DE
      LD L,A
      LD A,(DE)
      LD D,A
      LD E,L
      ;Can these actors be pushed?
      LD HL,_Hitbox
      ADD HL,BC
      LD A,(HL)
      LD HL,_Hitbox
      ADD HL,DE
      LD L,(HL)
      SWAP A
      OR L
      LD L,A
      AND %01000100
      JR z,++   ;Neither actor can be pushed
      PUSH HL
        ;Get deltas
        INC BC
        INC BC
        INC BC
        INC DE
        INC DE
        INC DE    ;Master X int
        LD A,(BC)
        LD H,A
        LD A,(DE)
        SUB H
        LD L,A
        INC BC
        INC BC
        INC DE
        INC DE
        LD A,(BC)
        LD H,A
        LD A,(DE)
        SUB H
        LD H,A
        ;Wherever one moves, the other moves exactly opposite (full negation, both directions)
        ;Move along the greater axis such that |dX| + |dY| = HitSize
        LD A,H
        CP L
        JR nc,+
        ;Moving along X instead
        DEC BC
        DEC BC
        DEC DE
        DEC DE
        LD A,L
+
        ;Delta movement is on stack, negated
      POP HL
      LD H,A    ;Save present delta to determine sign later
    POP AF
    RRA
    ADC 0 ;Err to larger movements
    BIT 7,H
    JR nz,+
    ;Moving up/left, make movement negative
    CPL
    INC A
+
    ;Apply delta to BC actor, if it can be pushed
    LD H,A
    BIT 6,L
    JR z,+
    LD A,(BC)
    ADD H
    LD (BC),A
    ;Apply it twice if the other actor can't be pushed
    BIT 2,L
    JR nz,+
    LD A,(BC)
    ADD H
    LD (BC),A
    ;This is the only code path where the second actor is not pushable
    JR ++
+   ;Second actor can be pushed
    ;DE moves in other direction
    LD A,H
    CPL
    INC A
    LD H,A
    LD A,(DE)
    ADD H
    LD (DE),A
    ;If first actor couldn't be pushed, apply twice
    BIT 6,L
    JR nz,++
    LD A,(DE)
    ADD H
    LD (DE),A
++
  POP DE
  POP BC
  JP --

.ENDS

.SECTION "Interactions" FREE BITWINDOW 8

InteractionActions:
 .dw Cs_MushroomCollect
 .dw Cs_EndingB
 .dw Cs_ReimuMeet
 ;.dw Cs_NarumiFightEnd

.ENDS

