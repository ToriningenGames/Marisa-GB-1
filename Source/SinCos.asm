;Sin/Cos hack
;Instead of some juicy, time-consuming algorithm, we'll use a LUT
;LUTs are undoubtedly the fastest method, and it might even be the smallest.
;Angles are assumed to be of the 256 bigree variety
;Results are in 2.6 format
;Defined using for [0, 1) for sin

.SECTION "SinCos" ALIGN 256 FREE
;sin going forwards from 0..1
SinCosTable:
 .db $00,$02,$03,$05,$06,$08,$09,$0B,$0C,$0E,$10,$11,$13,$14,$16,$17,$18,$1A,$1B
 .db $1D,$1E,$20,$21,$22,$24,$25,$26,$27,$29,$2A,$2B,$2C,$2D,$2E,$2F,$30,$31,$32
 .db $33,$34,$35,$36,$37,$38,$38,$39,$3A,$3B,$3B,$3C,$3C,$3D,$3D,$3E,$3E,$3E,$3F
 .db $3F,$3F,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$3F,$3F,$3F,$3E,$3E,$3E
 .db $3D,$3D,$3C,$3C,$3B,$3B,$3A,$39,$38,$38,$37,$36,$35,$34,$33,$32,$31,$30,$2F
 .db $2E,$2D,$2C,$2B,$2A,$29,$27,$26,$25,$24,$22,$21,$20,$1E,$1D,$1B,$1A,$18,$17
 .db $16,$14,$13,$11,$10,$0E,$0C,$0B,$09,$08,$06,$05,$03,$02,$00,$FE,$FD,$FB,$FA
 .db $F8,$F7,$F5,$F4,$F2,$F0,$EF,$ED,$EC,$EA,$E9,$E8,$E6,$E5,$E3,$E2,$E0,$DF,$DE
 .db $DC,$DB,$DA,$D9,$D7,$D6,$D5,$D4,$D3,$D2,$D1,$D0,$CF,$CE,$CD,$CC,$CB,$CA,$C9
 .db $C8,$C8,$C7,$C6,$C5,$C5,$C4,$C4,$C3,$C3,$C2,$C2,$C2,$C1,$C1,$C1,$C0,$C0,$C0
 .db $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$C1,$C1,$C1,$C2,$C2,$C2,$C3,$C3,$C4,$C4,$C5
 .db $C5,$C6,$C7,$C8,$C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF,$D0,$D1,$D2,$D3,$D4,$D5,$D6
 .db $D7,$D9,$DA,$DB,$DC,$DE,$DF,$E0,$E2,$E3,$E5,$E6,$E8,$E9,$EA,$EC,$ED,$EF,$F0
 .db $F2,$F4,$F5,$F7,$F8,$FA,$FB,$FD,$FE

;Example of getting cosine:
Cosine:
  ADD $40   ;One quarter turn off
;Example of getting sine:
Sin:
  LD H,>SinCosTable
  LD L,A
  LD A,(HL)
TwoSixToEightEight:
  ;Convert from 2.6 to 8.8
  LD H,A
  AND $3F
  RLCA
  RLCA
  LD L,A
  LD A,$C0
  AND H
  BIT 7,A
  JR z,+
  OR $3F
+
  RLCA
  RLCA
  LD H,A
  RET

.ENDS
