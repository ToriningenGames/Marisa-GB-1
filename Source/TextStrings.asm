    ;Wide format
    ;| 0123456789ABCDEF01 |
    ;Narrow format
    ;|FFFF 0123456789ABCD |

.ENUMID 0               ;Arguments
.ENUMID CtrlEnd         ;None
.ENUMID CtrlCorner      ;None
.ENUMID CtrlRaise       ;None
.ENUMID CtrlLower       ;None
.ENUMID CtrlUp          ;None
.ENUMID CtrlDown        ;None
.ENUMID CtrlLeft        ;None
.ENUMID CtrlRight       ;None
.ENUMID CtrlDel         ;None
.ENUMID CtrlTab         ;None
.ENUMID CtrlLine        ;None
.ENUMID CtrlPause       ;None
.ENUMID CtrlClear       ;None
.ENUMID CtrlRet         ;None
.ENUMID Ctrl_Invalid1   ;Do not use
.ENUMID Ctrl_Invalid2   ;Do not use
.ENUMID CtrlSpeed       ;Text speed
.ENUMID CtrlFaceLoad    ;Slot, Face ID
.ENUMID CtrlFaceShow    ;Slot
.ENUMID Ctrl_Invalid0   ;Do not use
.ENUMID CtrlBorder      ;Border ID
.ENUMID CtrlShake       ;Shake slowness
.ENUMID CtrlWait        ;Frames to wait

;This is dependent on the tile data. Then again, this entire process is.
.ASCIITABLE
MAP " " TO "_" = $30
MAP "+" = $34
MAP "=" = $3B
MAP "$" = $4D
MAP "`" = $4E
MAP "m" = $50
MAP "k" = $6B
MAP "~" = $6C
MAP "o" = $6D
MAP "s" = $71
MAP "e" = $70
MAP "a" = $72
MAP "b" = $73
MAP "u" = $74
MAP "d" = $76
MAP "l" = $77
MAP "r" = $75
MAP "z" = $78
MAP "x" = $79
MAP "c" = $7A
MAP "v" = $7B
MAP "t" = $7C
MAP "y" = $7D
MAP "g" = $7E
MAP "h" = $7F
.ENDA

.SECTION "Strings" FREE

;Welcome message:
    ;Marisa needs to go to Alice's house,
    ;but she realizes she doesn't know how to get there.
    ;She becomes resolved to find Alice's house.
    
    ;Marisa walks on set from an impossible angle
    ;M: "All that ruckus over a few little books!"
    ;M: "At least I got the one Alice asked for."
    ;M: "Better go pay her a visit, then"
    ;Marisa kinda shuffles to and fro
    ;M: "...I have no idea where she lives."
    ;Pause
    ;M: "There's only one thing I can do..."
    ;M: "Find Alice's house!"
    
    ;"0123456789ABCD"
StringOpeningMessage1:
.DB CtrlFaceLoad,1,$19, CtrlFaceLoad,2,$17, CtrlBorder,1, CtrlSpeed,2, CtrlClear, CtrlFaceShow,1, CtrlRaise
.ASC "ALL THAT", CtrlLine
.ASC "RUCKUS OVER A", CtrlLine
.ASC "FEW LITTLE", CtrlLine
.ASC "BOOKS!", CtrlPause, CtrlClear
.DB CtrlFaceShow,2, CtrlFaceLoad,1,$11
.ASC "AT LEAST I GOT", CtrlLine
.ASC "THE ONE ALICE", CtrlLine
.ASC "ASKED FOR.", CtrlPause, CtrlClear
.DB CtrlFaceShow,2
.ASC "BETTER GO PAY", CtrlLine
.ASC "HER A VISIT,", CtrlLine
.ASC "THEN.", CtrlPause
.DB CtrlLower, CtrlEnd
StringOpeningMessage2:
.DB CtrlFaceLoad,1,$12, CtrlFaceLoad,2,$18, CtrlClear, CtrlFaceShow,1, CtrlRaise
.ASC "...I HAVE NO", CtrlLine
.ASC "IDEA WHERE", CtrlLine
.ASC "SHE LIVES.", CtrlPause
.DB CtrlLower, CtrlWait,90, CtrlFaceShow,2, CtrlClear, CtrlFaceLoad,1,$1A, CtrlRaise
.ASC "THERE'S ONLY", CtrlLine
.ASC "ONE THING", CtrlLine
.ASC "I CAN DO...", CtrlPause, CtrlClear
.DB CtrlEnd
StringOpeningMessage3:
.DB CtrlFaceShow,1
.ASC "FIND", CtrlLine
.ASC "ALICE'S", CtrlLine
.ASC "HOUSE!", CtrlPause, CtrlClear
.DB CtrlLower, CtrlEnd

StringNarumiEnd:
.DB CtrlFaceLoad,1,$00, CtrlFaceLoad,2,$00, CtrlSpeed,4, CtrlClear, CtrlFaceShow,1, CtrlRaise
.ASC "Ooohh... That fight... took most of my energy...", CtrlPause, CtrlClear
.DB CtrlFaceShow,2, CtrlSpeed,2
.ASC "Noo! Don't die on me, damnit!", CtrlPause, CtrlClear 
.DB CtrlFaceShow,1, CtrlSpeed,5
.ASC "It's... It's OK... Marisa...", CtrlPause, CtrlLine
.ASC "I'll just... revert to a... a statue for a while.", CtrlPause, CtrlLine
.ASC "It's like... taking... a nap...", CtrlPause, CtrlClear, CtrlSpeed,7
.ASC "What was it... you were... looking for?", CtrlPause, CtrlClear
.DB CtrlFaceShow,2, CtrlSpeed,2, CtrlWait,45
.ASC "...Alice! Where is Alice's house??", CtrlPause, CtrlClear
.DB CtrlFaceShow,1, CtrlSpeed,8, CtrlFaceLoad,2,$00
.ASC "When... you leave... take... two...", CtrlLine
.ASC "...", CtrlLine, "..."
.DB CtrlClear, CtrlFaceShow,2, CtrlFaceLoad,1,$00, CtrlSpeed,3
.ASC "...Narumi...", CtrlWait,15, CtrlFaceShow,1, CtrlFaceLoad,2,$00, CtrlLine, "!", CtrlWait,10
.ASC CtrlClear, CtrlFaceShow,2, "...rights.", CtrlPause,
.DB CtrlLower

;Conversations:
;Things people say
StringTestInteraction:
.DB CtrlSpeed,3, CtrlClear, CtrlRaise, CtrlFaceShow,0, CtrlBorder,0
.ASC "HI!", CtrlPause
.DB CtrlLower, CtrlEnd
.ENDS
