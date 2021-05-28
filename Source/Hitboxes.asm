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
  CALL HaltTask     ;Test for collisions every other frame; collisions are CPU expensive
  LD L,E
  LD H,D
  ;Back to front for ease of end checking
  ;HL contains the end of hitbox array
  ;Compare every hitbox with every other hitbox
  ;(This grows half as fast as O(n^2), best case if most hitboxes are moving)
-
  LD A,L    ;Go to beginning of next hitboxes
  SUB 7
  LD L,A
  LD A,H
  SBC 0
  LD H,A
  LD A,L    ;Don't compare hitboxes to themselves
  SUB 7
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
  ADD (HL)
  INC HL
  CPL
  INC A
  PUSH AF
    ADD D       ;R + X, R + Y staying negative indicates hit
    LD A,E
  POP DE    ;Rotate around D, A, E so we can clear the stack
  JR nc,_nohit
  ADC D
  JR nc,_nohit
;Hit. Call hit actions
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
_nohit:     ;Result greater than zero? Didn't hit
  DEC HL    ;Realign HL
  DEC HL
  DEC HL
  LD A,C
  SUB 7+3   ;Next hitbox
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

DefaultHitboxes:
 .db 1
 .dw $0000,$0000,$0300
 .dw DefaultHitboxAction

NPCHitboxes:
 .db 2
 .dw $0000,$FC00,$0301  ;Collision
 .dw DefaultHitboxAction
 .dw $0000,$FC00,$0502  ;Speaking
 .dw DefaultHitboxAction

PlayerHitboxes:
 .db 2
 .dw $0000,$FC00,$0501  ;Lo byte radius type 1 is hitbox
 .dw PlayerHitboxAction
 .dw $0000,$0000,$0102  ;Speaking
 .dw DefaultHitboxAction
 
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
  LD HL,SP+4    ;Their hitbox
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  DEC HL
  DEC HL
  LD A,(HL)
  XOR $01   ;Hitbox type check
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

DefaultHitboxAction:
  RET

.ENDS
