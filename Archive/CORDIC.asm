;CORDIC 3.1
;Values will be fixed-point 8.16
;Though it works in fixed-point 8.16, the accuracy of the given answers is only 8.8 for Linear, with rounding already done.

;CORDIC in a nutshell:
;Rotation
    ;x' = x-m*y*d*2^-i
    ;y' = y+x*d*2^-i
    ;z' = z-d*atan(2^-i)
    ;d=sign of Z or Y
;Linear and hyperbolic change Z table computation

;Map:
;$C010
    ;Old X
;$C013
    ;Old Y
;$C016
    ;Old Z
;$C019
    ;New X
;$C01C
    ;New Y
;$C01F
    ;New Z
;$C022
    ;Version fiddle (1,0,-1)
;$C023
    ;Rotation/vector mode ($21,$9E)
;$C024
    ;Decision this iteration (d;0,-1)
;$C025
    ;No. of iterations thus far (i)
;$C026
    ;Hyperbolic skip (bool)
;Plan:
    ;Inputs
        ;$C019: New X-Z will be the X-Z inputs
            ;Units will be in 1/256th of a circle
        ;$C022: Type (-1: hyperbolic, 0: linear, 1: circular)
        ;$C023: Mode ($21: Rotation, $9E: Vector)
    ;Outputs
        ;Rotation:
            ;Circular:
                ;x'= K(x*cos z - y*sin z)
                ;y'= K(y*cos z + x*sin z)
                ;z'= 0
            ;Linear:
                ;x'= x
                ;y'= y+xz
                ;z'= 0
            ;Hyperbolic:
                ;x'= L(x*cosh z - y*sinh z)
                ;y'= L(y*cosh z + x*sinh z)
                ;z'= 0
        ;Vectoring:
            ;Circular:
                ;x'= K*sqrt(x^2 + y^2)
                ;y'= 0
                ;z'= z + arctan(y/x)
            ;Linear:
                ;x'= x
                ;y'= 0
                ;z'= z+y/x
            ;Hyperbolic:
                ;x'= L*sqrt(x^2 - y^2)
                ;y'= 0
                ;z'= z + arctanh(y/x)
            ;K=1.1644(35345)  = $012A18
            ;Experimental K = Unknown
            ;L=0.8281(598937) = $00D402
            ;Experimental L = Unknown
;To find sine of A:
    ;Circular   Rotation  x=1   y=0   z=A    ;K*Sin
    ;Linear     Vectoring x=K   y=y'  z=z'   ;Division
    ;sin(A) = z
;To find cosine of A:
    ;Circular   Rotation  x=1   y=0   z=A    ;K*Cos
    ;Linear     Vectoring x=K   y=x'  z=z'   ;Division
    ;cos(A) = z
;To find tangent of A:
    ;Circular   Rotation  x=1   y=0   z=A    ;K*Sin, K*Cos
    ;Linear     Vectoring x=x'  y=y'  z=z'   ;K*Sin / K*Cos
    ;tan(A) = z
;To find inverse sine of A:
;(arctan(A/sqrt(1-A^2)))
    ;Hyperbolic Vectoring x=1   y=A   z=.    ;K*sqrt(1 - A^2)
    ;Linear     Rotation  x=K   y=0   z=A    ;Multiply K by A
    ;Circular   Vectoring x=x'' y=y'  z=0    ;Division by K*sqrt(...) and arctangent
    ;arcsin(A) = z
;To find inverse cosine of A:
;(arctan(sqrt(1-A^2)/A))
    ;Hyperbolic Vectoring x=1   y=A   z=.    ;K*sqrt(1 - A^2)
    ;Linear     Rotation  x=K   y=0   z=A    ;Multiply K by A
    ;Circular   Vectoring x=y'  y=x'' z=0    ;Division by K*A and arctangent
    ;arccos(A) = z
;To find inverse tangent of A:
    ;Circular   Vectoring x=1   y=A   z=0    ;arctan of (A/1)
    ;arctan(A) = z

;I'll quit wasting your time.
;e^A = sinhA + coshA
;ln A = 2*arctanh((A-1)\(A+1))
;log(B)A = ln A / ln B
;arccosh(A) = ln(A + sqrt(1-A^2))
;arcsinh(A) = ln(A + sqrt(1+A^2))
;sqrt(A) = sqrt((A+1/4)^2 - (A-1/4)^2)
;A^B = e^(B*lnA)
    ;That last one could use some expansion
        ;A^B = sinh(2B*arctanh((A-1) / (A+1))) + cosh(2B*arctanh((A-1) / (A+1)))
    ;And CORDIC can reduce it, because
        ;Hyperbolic Rotation  x=1   y=1   z=A    ;L* sinhA + coshA
    ;finds L*e^A in y
    ;so,
        ;SHL B
        ;Hyperbolic Vectoring x=A+1 y=A-1 z=0    ;the arctanh(...)s
        ;Linear     Rotation  x=B   y=0   z=z'   ;multiplication by 2B
        ;Hyperbolic Rotation  x=1   y=1   z=y'   ;sinh(...) + cosh(...)
        ;A^B = y

;Lookup table for tan values
;Looking for the results to:
;arctan(1/2), arctan(1/4), arctan(1/8)... for as many iterations as desired
;Converting to a 256 based "bigree" system.
;Conversions from 256 style:
    ;x * 360 / 256 = degrees
    ;x * 2pi / 256 = radians
    ;x * 400 / 256 = gradients
;Simplified
    ;x * 45/32 = degrees
    ;x * pi/128 = radians
    ;x * 25/16 = gradients
;"Bigrees"
    ;Degrees:   Multiply by 45, then shift right 5 times
    ;Radians:   IDK, multiply by some odd constant? (pi is irrational, so it can't be reduced to integers. An approximation is likely if radians are needed).
    ;Gradients: Multiply by 25, then shift right 4 times
;256 bigrees in a circle, means
    ;256 / 4 = 64
;bigrees in a quadrant
;Halfway through the first quadrant is arctan(1), which is
    ;64 / 2 = 32
;32 bigrees

;arctan(1) = 32

;Afterwards, these become fractional, and with 8 binary digits after the decimal point, we can generate precision down to about 0.004 in decimal.
;Needs more iterations to be accurate.

;To get us in the correct quadrant, we must expand in the other direction, which will include every power of two.
;To get more accurate, decimals can be added.
;Together, the above cover everything.
;If the point is in quadrants 3 or 4 (y is negative), make y positive and invert x to rotate by 128 bigrees.
;Then, if the point is in quadrant 2 (x is negative), make x positive to rotate by 64 bigrees
;Basically, keep track of the signs of x and y. CORDIC is an unsigned rotationer.
;Negation rotation is gainless.

;For Circular rotations, the iteration value is actuall i+whatever
;For Linear rotations, the iteration value is actually i+6

;256 bigrees/circle
;128 bigrees/hemicircle
;64 bigrees/quadrant
;32 bigrees = 45 degrees


;Phases:
    ;Compute New X
    ;Compute New Y
    ;Compute New Z
    ;Decide if at end of table
        ;exit
    ;Copy New to Old
    ;Find next angle value
    ;Fix X's y input to accomodate the current mode
    ;Go to step 1

CORDICLoop:
  LD L,$10
  LD C,$19
;Compute New X
    ;Old Y in DEA (Fiddled and negated), Old X at HL, New X at BC
  ADD (HL)  ;Negated Y so we could use adds, which are associative
  LD (BC),A
  INC C
  INC L
  LDI A,(HL)
  ADC E
  LD (BC),A
  INC C
  LDI A,(HL)
  ADC D
  LD (BC),A
;Prepare for New Y
  LD L,$24
  LD C,(HL) ;Storing decision for negation
  LD L,$12
  LDD A,(HL)
  XOR C
  LD D,A
  LDD A,(HL)
  XOR C
  LD E,A
  LD A,(HL)
  XOR C
  RL C
  ADC $00     ;Two's compliment
  JR nc,+
  INC DE
+
  LD C,D    ;Shift left x8
  LD D,E
  LD E,A
  LD L,$25
  LD A,$07
  CP (HL)
  JR c,++
  XOR A
  LD B,(HL)     ;Value now in CDEA
  INC B
  INC B
-
  SRA C
  RR D
  RR E
  RRA
  DEC B
  JR nz,-
  JR +
++
  LD A,(HL)
  SUB $06   ;See below
  LD B,A
  LD A,C
  LD C,B
-
  DEC C ;C guaranteed to be at least 1
  JR z,+
  SRA D
  RR E
  RRA
  JR -
+
  ADC $00   ;Proper rounding
  JR nc,+
  INC DE
+
  LD L,$13
  LD BC,$C01C  
;Compute New Y
    ;Old X in DEA (Fiddled), Old Y at HL, New Y at BC
  ADD (HL)
  LD (BC),A
  INC C
  INC L
  LDI A,(HL)
  ADC E
  LD (BC),A
  INC C
  LDI A,(HL)
  ADC D
  LD (BC),A
;Remember which CORDIC we are doing
  LD L,$22
  BIT 7,(HL)
  JR nz,CORDICHyperbolic
  BIT 0,(HL)
  JR nz,CORDICCircular
;Prepare for New Z
CORDICLinear:
  LD L,$25
  LD C,(HL)
  XOR A
  LD E,A
  LD D,$40  ;DEA = 64 (2^6)
  OR C
  JR z,+++  ;Edge case where C==0
  LD A,E
-
  SRA D
  RR E
  RRA
  DEC C
  JR nz,-
  ADC $00   ;Proper rounding
  JR nc,+++
  INC DE
  JR +++
CORDICHyperbolic:
  LD HL,CORDICHyperbolicTable
  LD C,$25
  LD A,(BC)
  RLA   ;Multiply by 2
  ADD L     ;16-bit add
  LD L,A
  LD D,$00  ;All hyperbolic begin with 0
  LD A,D
  ADC H
  LD H,A
  LDI A,(HL)
  LD E,(HL)
  LD H,B
  JR +++
CORDICCircular:
  LD HL,CORDICCircularTable
  LD C,$25
  LD A,(BC)
  LD D,A    ;Multiply by 3
  RLCA
  ADD D
  ADD L     ;16-bit add
  LD L,A
  LD A,$00
  ADC H
  LD H,A
  DEC HL
  LDD A,(HL)
  LD D,A
  LDD A,(HL)
  LD E,A
  LD A,(HL)
  LD H,B
+++
  LD L,$24  ;Negate test
  BIT 7,(HL)
  JR nz,+
  CPL
  LD C,A
  LD A,E
  CPL
  LD E,A
  LD A,D
  CPL
  LD D,A
  LD A,C
  INC A
  JR nz,+
  INC DE
+
  LD L,$16
  LD C,$1F
;Compute New Z
    ;Angle change in DEA (negated), Old Z at HL, New Z at BC
  ADD (HL)
  LD (BC),A
  INC C
  INC L
  LDI A,(HL)
  ADC E
  LD (BC),A
  INC C
  LDI A,(HL)
  ADC D
  LD (BC),A
;Update iteration variables
  LD L,$22
  LD C,(HL)
  BIT 7,C
  JR z,+    ;Hyperbolic skip test
  LD L,$26
  XOR A
  BIT 0,(HL)
  LD (HL),A
  JR nz,++
+   ;Next iteration
  LD L,$25
  INC (HL)
  LD A,$04
  CP (HL)
  JR nz,+   ;Hyperbolic skip test
  INC A
  INC L
  LDD (HL),A
+
  BIT 7,C   ;Test for return
  JR z,+
;Hyperbolic
  LD A,$0D
  JR ++
+
  BIT 0,C
  JR z,+
;Circular
  LD A,$19
  JR ++
+
;Linear
  LD A,$19  ;Maximum accuracy in Linear Vector
++
;Possible return
  CP (HL)
  JR nz,+
  POP BC
  POP DE
  RET
;ENTRY POINT
CORDIC:
  PUSH DE
  PUSH BC
  LD HL,$C026
  LD B,H
  XOR A
  LDD (HL),A
  LD (HL),A
+
;Compute D
  DEC L
  DEC L     ;$23
  LD C,(HL)
  LD A,$7F
  AND C
  LD L,A
  LD A,(HL)
  LD L,$24
;Setting A to -1 or 0 for this iteration (for d)
  RLA
  LD A,$DB
  ADC L
  CPL
  RL C
  JR nc,++
  CPL   ;Vector mode inverts
++
  LD (HL),A
;Copy New values to Old values
  LD L,$21
  LD C,$18
-
  LDD A,(HL)
  LD (BC),A
  DEC C
  BIT 4,C
  JR nz,-
;Prepare for New X
  LD L,$22
  XOR A
  LD D,A
  LD E,A
  OR (HL)
  JP z,CORDICLoop
  LDI A,(HL)
  INC L
  XOR (HL)  ;If one of decision or mode is negative, we do not negate
  LD C,A
  LD L,$15
  LD D,(HL)
  DEC L
  LD E,(HL)
  DEC L
  LD A,(HL)
  LD L,$25  ;Division by 2
  LD B,(HL)
  INC B
  OR A      ;Clear carry
-
  DEC B
  JR nz,+
  SRA D
  RR E
  RRA
  JR -
+
  ADC $00   ;Proper rounding
  JR nc,+
  INC DE
+
  LD B,H
  BIT 7,C   ;Negation test
  JP nz,CORDICLoop
  CPL       ;Do negate
  LD C,A
  LD A,E
  CPL
  LD E,A
  LD A,D
  CPL
  LD D,A
  LD A,C
  INC A
  JP nz,CORDICLoop
  INC DE
  JP CORDICLoop

CORDICHyperbolicTable:
;The leading bytes are all zeros, so the table is condensed
;For this to work, some values must be used twice. They are doubled in the table
;atanh(1) = inf
 .db $00,$64    ;atanh(1/2)     = 0.3906177026
 .db $7F,$2E    ;atanh(1/4)     = 0.1816268885
 .db $E0,$16    ;atanh(1/8)     = 0.08935624117
 .db $65,$0B    ;atanh(1/16)    = 0.04450245083
 .db $B6,$00    ;atanh(1/32)    = 0.002777791906
 .db $5B,$00    ;atanh(1/64)    = 0.001388890655
 .db $2E,$00    ;atanh(1/128)   = 0.0006944446652
 .db $17,$00    ;atanh(1/256)   = 0.0003472222498
 .db $0B,$00    ;atanh(1/512)   = 0.0001736111146
 .db $05,$00    ;atanh(1/1024)  = 0.00008680555599
 .db $03,$00    ;atanh(1/2048)  = 0.00004340277783
 .db $01,$00    ;atanh(1/4096)  = 0.0000217013889
 .db $01,$00    ;atanh(1/8192)  = 0.00001085069445
CORDICCircularTable:
 .db $00,$00,$20    ;atan(1)       = 32
 .db $05,$E4,$12    ;atan(1/2)     = 18.89070306
 .db $38,$FB,$09    ;atan(1/4)     = 9.981328688
 .db $12,$11,$05    ;atan(1/8)     = 5.066678293
 .db $0D,$8B,$02    ;atan(1/16)    = 2.543171111
 .db $D8,$45,$01    ;atan(1/32)    = 1.272825321
 .db $F6,$A2,$00    ;atan(1/64)    = 0.6365679717
 .db $7C,$51,$00    ;atan(1/128)   = 0.3183034104
 .db $BE,$28,$00    ;atan(1/256)   = 0.1591541336
 .db $5F,$14,$00    ;atan(1/512)   = 0.07957737036
 .db $30,$0A,$00    ;atan(1/1024)  = 0.03978872312
 .db $18,$05,$00    ;atan(1/2048)  = 0.01989436631
 .db $8C,$02,$00    ;atan(1/4096)  = 0.009947183746
 .db $46,$01,$00    ;atan(1/8192)  = 0.004973591947
 .db $A3,$00,$00    ;atan(1/2^-14) = 0.002486795983
 .db $51,$00,$00    ;atan(1/2^-15) = 0.001243397993
 .db $29,$00,$00    ;atan(1/2^-16) = 0.0006216989964
 .db $14,$00,$00    ;atan(1/2^-17) = 0.0003108494982
 .db $0A,$00,$00    ;atan(1/2^-18) = 0.0001554247491
 .db $05,$00,$00    ;atan(1/2^-19) = 0.00007771237456
 .db $03,$00,$00    ;atan(1/2^-20) = 0.00003885618728
 .db $01,$00,$00    ;atan(1/2^-21) = 0.00001942809364
 .db $01,$00,$00    ;atan(1/2^-22) = 0.00000971404682
