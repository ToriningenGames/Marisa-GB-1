.SECTION "Effects" FREE
TestCh1:
 .db 1              ;Channel
 .db 0,$40,$A0,$05,$87    ;Registers (Sweep, Duty & Length, Env, Freq, Enable)
 .db 120            ;Wait for next entry
 .db 0,$40,$70,$2B,$80    ;Registers (Sweep, Duty & Length, Env, Freq, Enable)
 .db 120            ;Wait for next entry
 .db 0,0,0,0,$80    ;Registers
 .db 0              ;End
TestCh2:
 .db 2              ;Channel
 .db $C0,$90,$62,$83      ;Registers (Duty & Length, Env, Freq, Enable)
 .db 120            ;Wait for next entry
 .db $C0,$90,$62,$83      ;Registers (Duty & Length, Env, Freq, Enable)
 .db 120            ;Wait for next entry
 .db 0,0,0,$80      ;Registers
 .db 0              ;End
TestCh3:
 .db 3              ;Channel
 .db 14             ;Wave for this effect
 .db 0,$20,$AC,$85        ;Registers (Length, Vol, Freq, Enable)
 .db 120            ;Wait for next entry
 .db 0,$20,$AC,$85        ;Registers (Length, Vol, Freq, Enable)
 .db 120            ;Wait for next entry
 .db 0,0,0,$80      ;Registers
 .db 0              ;End
TestCh4:
 .db 4              ;Channel
 .db $80,$30,$64          ;Registers (Enable & Length, Env, Freq)
 .db 120            ;Wait for next entry
 .db $80,$30,$64          ;Registers (Enable & Length, Env, Freq)
 .db 120            ;Wait for next entry
 .db $80,0,0        ;Registers
 .db 0              ;End
.ENDS
