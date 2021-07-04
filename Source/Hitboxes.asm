;Hitboxes
;For keeping things from phasing, and for limiting telepathy

.include "actorData.asm"

.DEFINE HitboxStart     $C400
.DEFINE HitboxEndPtr    $C0EC

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
HitboxUpdate_Task:
;Puts updated hitbox information in the extract area so pushing etc are up to date
---
  CALL HaltTask
  ;Back to front for ease of end checking
  LD A,(ObjUse)
  ADD A ;Double. affecting zero flag
  RET z ;No actors; nothing to do
  ADD <ActiveActorArray
  LD C,A
  LD B,>ActiveActorArray
  ;Point HL to beginning of Hitbox Data Collection
  LD HL,HitboxStart
-
  ;For each actor
  ;Don't edit HL
  ;Get actor in DE
  DEC C
  LD A,(BC)
  LD D,A
  DEC C
  LD A,(BC)
  ADD _Hitbox
  LD E,A
  LD A,0
  ADC D
  LD D,A
  PUSH BC
    ;Get hitbox data in BC
    LD A,(DE)
    INC DE
    LD C,A
    LD A,(DE)
    LD B,A
    LD A,-(_Hitbox+1)
    ADD E       ;Back to base
    LD E,A
    LD A,-1
    ADC D
    LD D,A
    ;Get no. of hitboxes
    LD A,(BC)
    INC BC
--
;BC->Actor Hitbox Data
;DE->Actor Data
;HL->Hitbox Data Collection
    ;For each hitbox
    PUSH AF
      ;Get absolute hitbox position
      INC DE
      INC DE
      INC DE    ;Only high bytes
      INC BC
      LD A,(BC)       ;X offset
      INC BC
      INC BC
      LD (HL),A
      LD A,(DE)
      INC DE
      INC DE
      ADD (HL)
      LDI (HL),A
      LD A,(BC)       ;Y offset
      INC BC
      LD (HL),A
      LD A,(DE)
      ADD (HL)
      LDI (HL),A
      DEC DE          ;Return DE to start of actor
      DEC DE
      DEC DE
      DEC DE
      DEC DE
      LD A,(BC)       ;Radius
      INC BC
      LDI (HL),A
      LD A,(BC)       ;type
      INC BC
      LDI (HL),A
      LD A,E
      LDI (HL),A      ;Owning actor
      LD A,D
      LDI (HL),A
      LD A,(BC)       ;Action
      INC BC
      LDI (HL),A
      LD A,(BC)
      INC BC
      LDI (HL),A
    POP AF
    DEC A
    JR nz,--
  POP BC
  LD A,<ActiveActorArray
  CP C
  JR nz,-

;DoPush_Task:
;Checks all actors and hits them as necessary
;For each actor
    ;Check against subsequent actors
  LD E,L
  LD D,H
  LD L,E
  LD H,D
  ;Back to front for ease of end checking
  ;HL contains the end of hitbox array
  ;Compare every hitbox with every other hitbox
  ;(This grows half as fast as O(n^2), best case if most hitboxes are moving)
-
  LD A,L    ;Go to beginning of next hitboxes
  SUB 8
  LD L,A
  LD A,H
  SBC 0
  LD H,A
  LD A,L    ;Don't compare hitboxes to themselves
  SUB 8
  LD C,A
  LD A,H
  SBC 0
  LD B,A
  SUB (>HitboxStart)-1  ;When HL is the last, BC underflows
  JP z,---
--
  ;Hit check:
  ;Circles:
  ;sqrt((X2 - X1)^2 + (Y2 - Y1)^2) - R1 - R2 < 0
  ;sqrt((X2 - X1)^2 + Y2^2 - Y2Y1 + Y1^2) - (R1 + R2) < 0
  ;(X2 - X1)^2 + Y2^2 - Y2Y1 + Y1^2 - (R1 + R2)^2 < 0
  ;(X2 - X1)^2 + (Y2 - Y1)^2 - (R2 + R1)^2 < 0
  ;Circles are computationally expensive, so use squares instead:
  ;(X2 + R2) < (X1 - R1) || (X2 - R2) > (X1 + R1)
  ;X2 + R2 + R1 < X1 || X2 - R2 - R1 > X1
  ;X2 + R2 + R1 - X1 < 0 || X2 - R2 - R1 - X1 > 0
  ;abs(X2 - X1) - (R2 + R1) < 0
  LD A,(BC)     ;D = abs(X2 - X1)
  INC BC
  SUB (HL)
  INC HL
  JR nc,+
  CPL
  INC A
+
  LD D,A
  LD A,(BC)     ;E = abs(Y2 - Y1)
  INC BC
  SUB (HL)
  INC HL
  JR nc,+
  CPL
  INC A
+
  LD E,A
  LD A,(BC)     ;A = -(R2 + R1)
  INC BC
  INC BC
  ADD (HL)
  INC HL    ;Skip type
  INC HL
  CPL
  INC A
  PUSH AF
    ADD D       ;R + X, R + Y staying negative indicates hit (No carry, b/c R is negative)
    LD A,E
  POP DE    ;Rotate around D, A, E so we can clear the stack
  JR c,_nohit
  ADD D
  JR c,_nohit
;Hit. Call hit actions
  LD A,D    ;Place collective radius back on stack... but positive
  CPL
  INC A
  PUSH AF
  PUSH HL   ;The order of the next four push/pop pairs is important
  PUSH BC   ;The called-on hitbox is always top of the stack
    ;Call the actions on BC and HL if they are different actors
    LDI A,(HL)  ;DE->Touching actor
    LD E,A
    LD D,(HL)
    LD H,B  ;Copy this actor to HL
    LD L,C
    LDI A,(HL)  ;BC->Owning actor
    LD C,A
    LDI A,(HL)
    LD B,A
    LDI A,(HL)  ;HL->Action
    LD H,(HL)
    LD L,A
    LD A,B      ;Make sure they're different (WARNING: clever!)
    XOR C       ;By a wonder of the addresses MemAlloc returns, this will always work
    XOR D       ;Specifically, they are all $DXX0, so the only varied bits don't overlap in XORs
    XOR E       ;If and only if the addresses are the same will the result be 0
    CALL nz,$0030
  POP BC
  POP HL
  ;Call HL's action too
  PUSH BC
  PUSH HL
    LD A,(BC) ;DE->Touching actor
    INC BC
    LD E,A
    LD A,(BC)
    LD D,A
    LDI A,(HL)    ;BC->Owning actor
    LD C,A
    LDI A,(HL)
    LD B,A
    LDI A,(HL)    ;HL->Action
    LD H,(HL)
    LD L,A
    LD A,B      ;Make sure they're different
    XOR C       ;As above.
    XOR D       ;Should MemAlloc change to return more addresses, a few false positives would occur.
    XOR E       ;A reasonable alternative could be adding them instead
    CALL nz,$0030
  POP HL
  POP BC
  ADD SP,+2 ;Take the collective radius off the stack
_nohit:     ;Result greater than zero? Didn't hit
  DEC HL    ;Realign HL to this hitbox
  DEC HL
  DEC HL
  DEC HL
  LD A,C
  SUB 8+4   ;Next hitbox
  LD C,A
  LD A,B
  SBC 0
  LD B,A
;Check for end of loop
  SUB (>HitboxStart)-1
  JP nz,--
  JP -

.ENDS

.SECTION "Hitbox Definitions" FREE

.ENUMID 0
.ENUMID HitboxNone
.ENUMID HitboxCollision
.ENUMID HitboxTalk

DefaultHitboxes:
 .db 1
 .dw $0000,$0000
 .db $03,HitboxNone
 .dw DefaultHitboxAction

NPCHitboxes:
 .db 2
 .dw $0000,$0000
 .db $03,HitboxCollision
 .dw DefaultHitboxAction
 .dw $0000,$0000
 .db $05,HitboxTalk
 .dw DefaultHitboxAction

PlayerHitboxes:
 .db 2
 .dw $0000,$0000
 .db $05,HitboxCollision
 .dw PlayerHitboxAction
 .dw $0000,$0000
 .db $01,HitboxTalk
 .dw PlayerTalkAction
 
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
  RET

.ENDS
