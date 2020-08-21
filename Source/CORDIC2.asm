;New CORDIC?
;We want fixed point 8.8 angles, only original rotation mode

;Need LUT of tangent values
;Process:
    ;If X < 0, negate X and Y, flip hi bit of Z
    ;For count
    ;Decide positive or negative direction
    ;Positive:
        ;Shift Y by count, sub from X to make New X
        ;Shift X by count, add to Y to make New Y
        ;Sub angles[count] from Z to make New Z
    ;Negative:
        ;Shift Y by count, add to X to make New X
        ;Shift X by count, sub from Y to make New Y
        ;Add angles[count] to Z to make New Z
;
;Or:
    ;If X < 0, negate X and Y, flip hi bit of Z
    ;For count
        ;Put bitshifted X and Y in New Y and New X, respectively
        ;Put angles[count] in New Z
        ;Negate New Y
        ;If direction = positive (Z >= 0), negate all 3
        ;Add old to new, put in new
    ;Correct X and Y for K
;To do this, we need to be able to:
    ;Add two 16 bit numbers
    ;Negate a 16 bit number
    ;Flip hi bit of a 16 bit number
    ;Branch based on signedness of 16 bit no.
        ;Zero is positive for these
    ;Bitshift 16 bit number
    ;Move 16 bit numbers
    ;Look up 16 bit numbers in table
    ;Maintain a count
    ;Multiply a 16 bit number by a 16 bit constant (K correction)

;X, Y are signed 16 bit coordinates
;Z is 16 bit angle of 65536
;Mode is as follows:
    ;%TT00000M
    ; |||||||+--- Mode: 0 for Rotation, 1 for Vector
    ; ||+++++---- Constant 0
    ; ++--------- Type: 0 for Circular, 1 for Linear, -1 for Hyperbolic

.define Dir $C01F
.define X $C020
.define Y $C022
.define Ang $C024
.define NewX $C026
.define NewY $C028
.define NewAng $C02A

.define CORDIC_Mode Dir
.define CORDIC_X X
.define CORDIC_Y Y
.define CORDIC_Z Ang

.export CORDIC_Mode
.export CORDIC_X
.export CORDIC_Y
.export CORDIC_Z

.SECTION "CORDIC" FREE

;14 iterations
LUT:    ;arctangents of inverse powers of two
 .dw 8192,4836,2555,1297,651,326,163,81,41,20,10,5,3,1

Iteration:
  RET

CORDIC:
  LD HL,Ang+1   ;Rotate by 32768 if abs(Ang) >= 32768
  LD A,(HL)
  AND $C0
  JR z,++
  XOR $C0
  JR z,++
    ;Angle too big; rotate
;Ang -= 32768
  LD A,$80
  XOR (HL)
  LD (HL),A
;Neg16 X
  LD L,<X
  XOR A
  SUB (HL)
  LDI (HL),A
  LD A,0
  SBC (HL)
  LDI (HL),A
;Neg16 Y
  XOR A
  SUB (HL)
  LDI (HL),A
  LD A,0
  SBC (HL)
  LD (HL),A
++
  LD D,14
-
;Move16 NewX, Y
  LD L,<Y+1
  LD BC,NewX+1
  LDD A,(HL)
  LD (BC),A
  DEC C
  LDD A,(HL)
  LD (BC),A
;Move16 NewY, X
  LD C,<NewY+1
  LDD A,(HL)
  LD (BC),A
  DEC C
  LDD A,(HL)
  LD (BC),A
;Bitshift16 NewX, count
  LD C,D
  XOR A
  CP C
  JR z,+
  LD L,<NewX
  LDI A,(HL)
  LD B,(HL)
-
  SRA B
  RRA
  DEC C
  JR nz,-
  LD L,<NewX
  LDI (HL),A
  LD (HL),B
+
;Bitshift16 NewY, count
  LD C,D
  XOR A
  CP C
  JR z,+
  LD L,<NewY
  LDI A,(HL)
  LD B,(HL)
-
  SRA B
  RRA
  DEC C
  JR nz,-
  LD L,<NewY
  LDI (HL),A
  LD (HL),B
+
;LUT16 NewAng, Count
  LD A,D
  ADD A
  ADD <LUT
  LD L,A
  LD A,0
  ADC >LUT
  LD H,A
  LDI A,(HL)
  LD B,(HL)
  LD HL,NewAng
  LDI (HL),A
  LD (HL),B
;Branch16 Ang
;Returns Z set if D = 1, else clear if D = -1
;Dependent on mode
    ;Rotation: D = 1 if Z >= 0
    ;Vector:   D = 1 if Y <  0
  LD A,(Dir)
  RRA
  JR nc,++
  LD A,(Y+1)
  AND $80
  JR z,+
++
  LD A,(Ang+1)
  RLA
  JR c,+
    ;Positive angle
;Neg16 NewX
  LD L,<NewX
  XOR A
  SUB (HL)
  LDI (HL),A
  LD A,0
  SBC (HL)
  LD (HL),A
;Neg16 NewAng
  LD L,<NewAng
  XOR A
  SUB (HL)
  LDI (HL),A
  LD A,0
  SBC (HL)
  LD (HL),A
  JR ++
+   ;Negative angle
;Neg16 NewY
  LD L,<NewY
  XOR A
  SUB (HL)
  LDI (HL),A
  LD A,0
  SBC (HL)
  LD (HL),A
++
;Add16 X, NewX
  LD L,<NewX
  LDI A,(HL)
  LD B,(HL)
  LD L,<X
  ADD (HL)
  LDI (HL),A
  LD A,B
  ADC (HL)
  LD (HL),A
;Add16 Y, NewY
  LD L,<NewY
  LDI A,(HL)
  LD B,(HL)
  LD L,<Y
  ADD (HL)
  LDI (HL),A
  LD A,B
  ADC (HL)
  LD (HL),A
;Add16 Ang, NewAng
  LD L,<NewAng
  LDI A,(HL)
  LD B,(HL)
  LD L,<Ang
  ADD (HL)
  LDI (HL),A
  LD A,B
  ADC (HL)
  LD (HL),A
  DEC D
  JR nz,-
;K scaling corrections
  LD L,<X
  LDI A,(HL)
  LD B,(HL)
  LD C,A
  CALL KCorrect
;Store
  LD B,H
  LD C,L
  LD HL,X
  LD (HL),C
  INC L
  LD (HL),B

  LD L,<Y
  LDI A,(HL)
  LD B,(HL)
  LD C,A
  CALL KCorrect
;Store
  LD B,H
  LD C,L
  LD HL,Y
  LD (HL),C
  INC L
  LD (HL),B
  RET

.define K %1001101101110101
;For 14, this value is 0.607252936517010234128971242079738890823360692670630211165
;Approximation can be done by accumulating the following left shifts:
    ;1      0.5
    ;4      0.5625
    ;5      0.59375
    ;7      0.6015625
    ;8      0.60546875
    ;10     0.6064453125
    ;11     0.6069335938
    ;12     0.6071777344
    ;14     0.6072387695
    ;16     0.6072540283
;TODO: Calculate delta error on this operation and CORDIC in whole
;CORDIC (no KCorrect): X, Y: ~12    Z: 6.5
;KCorrect: 8.393 + inaccuracy with K (K off by 0.000014167)
;So, of a given number, the last 4 bits can't be trusted.
KCorrect:   ;Dependent on interations
  LD DE,K
  LD HL,0
;BC = input, DE = K
;Corrected output in HL
-
  XOR A
  OR B
  OR C
  RET z
  SRA B
  RR C
  RLA
  SLA E     ;When DE becomes 0, a 1 bit will be shifted into carry
  RL D
  JR nc,-
  ADD HL,BC
  AND 1
  JR z,+
  INC HL    ;Rounding
  XOR A
+
  OR E
  OR D
  JR nz,-
  RET

.ENDS
