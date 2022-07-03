;Hitboxes
;For keeping things from phasing, and for limiting telepathy

.include "actorData.asm"

.DEFINE HitboxStart     $C400
.DEFINE HitboxEndPtr    $C0EC

.DEFINE PlayerButtonBuf $C0E6

;This is size of BOTH hiboxes together when colliding!
.DEFINE MasterHitboxSize $08

.SECTION "Collision" FREE
;Hitbox memory format:
    ;2 bytes: X position (8.8)
    ;2 bytes: Y position (8.8)
    ;2 bytes: Radius     (8.8)
    ;2 bytes: Owning Actor
    ;2 bytes: Action
;Action signature:
    ;BC->Owning actor
    ;DE->Touching actor

;This task needs more speed.
    ;Hit detection always uses squares. For close actors, actual hit handlers
        ;can determine true collisions
    ;Hit detection only uses integer positions. Close actors as above
    ;Streamline data organization for execution speed
    ;TODO: Detect against Marisa only
    
;TODO: convert actor hitbox data to a bit array of allowable actions,
    ;and assume size+location from actor data itself
    ;After all, no meaningful actor has a disjoint hibox (save the interactor)
;;
;Bit assignments:
;%000000PIC
;       ||+--- Can collide
;       |+--- Can be interacted with
;       +--- Can be pushed

;Get last actor
;For each actor
        ;If this actor does not collide, go to next actor
    ;Get the next actor
        ;If next actor is invalid, done
        ;If next actor does not collide, go to next actor
    ;Get distance
        ;If distance > a value, go to next actor
    ;Push away from each other
        ;(figure out a good algo for this)
;If A not pressed this frame, done.
    ;Else, get interactivity point
    ;Check interactivity point against each actor for
        ;interactivity
        ;position
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
    SUB MasterHitboxSize
  POP DE
  POP BC
  JR nc,--
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
    CPL     ;absolute value
    INC A
    OR A  ;No carry
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

;Like hitboxes, but only against 1 actor, and only when A is freshly pressed
InteractUpdate_Task:
.ENDS

.SECTION "Hitbox Definitions" FREE

.ENUMID 0
.ENUMID HitboxNone
.ENUMID HitboxCollision
.ENUMID HitboxTalk

HatHitboxes:
DanmakuHitboxes:
 .db 1
 .dw $0000,$0000
 .db $03,HitboxNone
 .dw DefaultHitboxAction

FairyHitboxes:
NarumiHitboxes:
 .db 1
 .dw $0000,$0000
 .db $05,HitboxCollision
 .dw DefaultHitboxAction

PlayerHitboxes:
 .db 2
 .dw $0000,$0000
 .db $04,HitboxCollision
 .dw PlayerHitboxAction
 .dw $0000,$0000
 .db $0C,HitboxTalk
 .dw PlayerTalkAction

AliceHitboxes:
 .db 2
 .dw $0000,$0000
 .db $03,HitboxCollision
 .dw DefaultHitboxAction
 .dw $0000,$0000
 .db $05,HitboxTalk
 .dw Cs_EndingB
 
ReimuHitboxes:
 .db 2
 .dw $0000,$0000
 .db $03,HitboxCollision
 .dw DefaultHitboxAction
 .dw $0000,$0000
 .db $05,HitboxTalk
 .dw Cs_ReimuMeet
 
MushroomHitboxes:
 .db 1
 .dw $0000,$0000
 .db $04,HitboxTalk
 .dw Cs_MushroomCollect
.ENDS

.SECTION "Hitbox Behaviors" FREE

PlayerHitboxAction:
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
  LD HL,SP+4    ;Data frame
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  DEC HL
  LDD A,(HL)
  CP HitboxCollision    ;Hitbox type check
  RET nz
;Push ourselves half distance away from the other
    ;on the largest axis of separation from their hitbox
  DEC HL
  LD D,(HL)     ;Their hitbox Y
  DEC HL
  LD E,(HL)     ;Their hitbox X
  INC BC
  INC BC
  INC BC
  LD A,(BC)     ;Our X
  SUB E
  JR nc,+   ;Make sure it's positive
  CPL
  INC A
+
  LD E,A
  INC BC
  INC BC
  LD A,(BC)     ;Our Y
  SUB D
  JR nc,+   ;Positive difference
  CPL
  INC A
+
  CP E
  JR nc,+++
  ;Horizontal separation
  DEC BC
  DEC BC
  LD A,(BC)
  SUB (HL)
  DEC BC    ;Realign to our actor start
  DEC BC
  DEC BC
  JR nc,++  ;Determine left/right based on sub above
  ;Go left; movement along negative X
  LD HL,SP+7    ;Collective radius (This op, though shared, affects carry)
  ADD (HL)      ;Find difference between radius and current distance, via R + -D
  CPL
  INC A
  JR +  ;Shared code path
++  ;Go right; movement along positive X
  LD HL,SP+7    ;Collective radius
  CPL
  INC A
  ADD (HL)      ;Find difference between radius and current distance
+   ;Shared path for left/right movement
  LD H,B    ;HL = Actor Data
  LD L,C
  LD B,A
  XOR A     ;DE = Y delta
  LD D,A
  LD E,A
  LD C,A
  JP Actor_Move
+++   ;Vertical separation
  INC HL
  LD A,(BC)
  SUB (HL)
  DEC BC    ;Realign to our actor start
  DEC BC
  DEC BC
  DEC BC
  DEC BC
  JR nc,++  ;Determine up/down based on sub above
  ;Go up; movement along negative Y
  LD HL,SP+7    ;Collective radius (This op, though shared, affects carry)
  ADD (HL)      ;Find difference between radius and current distance, via R + -D
  CPL
  INC A
  JR +  ;Shared code path
++  ;Go down; movement along positive Y
  LD HL,SP+7    ;Collective radius
  CPL
  INC A
  ADD (HL)      ;Find difference between radius and current distance
+   ;Shared path for up/down movement
  LD D,A
  LD H,B    ;HL = Actor Data
  LD L,C
  XOR A     ;BC = X delta
  LD B,A
  LD C,A
  LD E,A
  JP Actor_Move

DefaultHitboxAction:
  RET

PlayerTalkAction:
;If player has talking control, run the cutscene on the other hitbox
  ;Only talk if freshly interacting
  LDH A,($FE)
  LD HL,PlayerButtonBuf
  XOR (HL)
  AND %00000001
  RET z
  ;Check if chara has control
  LD A,_ControlState
  ADD C
  LD C,A
  JR nc,+
  INC B
+
  LD A,(BC)
  AND 2
  RET z
  ;Check if our argument is an interaction hitbox
  LD HL,SP+4    ;Data frame
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  DEC HL
  LDI A,(HL)
  CP HitboxTalk    ;Hitbox type check
  RET nz
  ;Run opposing hitbox's cutscene
  PUSH BC
    INC HL
    INC HL
    LDI A,(HL)
    LD D,(HL)
    LD E,A
    INC DE        ;Skip leading RET
    LD BC,Cutscene_Task
    CALL NewTask
  POP BC
  RET c ;If cutscene didn't start, don't worry about trying again next frame
  LD A,(BC)
  AND $FD
  LD (BC),A
  RET

.ENDS
