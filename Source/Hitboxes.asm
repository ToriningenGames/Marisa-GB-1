;Hitboxes
;For keeping things from phasing, and for limiting telepathy

.include "actorData.asm"

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
 .dw $0000,$0000,$0002  ;Speaking
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

DefaultHitboxAction:
  RET

.ENDS
