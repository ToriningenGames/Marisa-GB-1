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
.DB CtrlFaceLoad,1,$03, CtrlFaceLoad,2,$01, CtrlBorder,1, CtrlSpeed,2, CtrlClear, CtrlFaceShow,1, CtrlRaise
.ASC "ALL THAT", CtrlLine
.ASC "RUCKUS OVER A", CtrlLine
.ASC "FEW LITTLE", CtrlLine
.ASC "BOOKS!", CtrlPause, CtrlClear
.DB CtrlFaceShow,2, CtrlFaceLoad,1,$00
.ASC "AT LEAST I GOT", CtrlLine
.ASC "THE ONE ALICE", CtrlLine
.ASC "ASKED FOR.", CtrlPause, CtrlClear
.DB CtrlFaceShow,1
.ASC "BETTER GO PAY", CtrlLine
.ASC "HER A VISIT,", CtrlLine
.ASC "THEN.", CtrlPause
.DB CtrlLower, CtrlEnd
StringOpeningMessage2:
.DB CtrlFaceLoad,1,$07, CtrlFaceLoad,2,$05, CtrlFaceShow,1, CtrlClear, CtrlRaise
.ASC "...I HAVE NO", CtrlLine
.ASC "IDEA WHERE", CtrlLine
.ASC "SHE LIVES.", CtrlPause
.DB CtrlFaceShow,0, CtrlClear, CtrlWait,90, CtrlFaceShow,2, CtrlCorner, CtrlFaceLoad,1,$06, CtrlRaise
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
.ASC "OOOHH... THAT FIGHT", CtrlLine
.ASC "... TOOK MOST OF MY", CtrlLine
.ASC "ENERGY...", CtrlPause, CtrlClear
.DB CtrlFaceShow,2, CtrlSpeed,2
.ASC "NOO! DON'T DIE ON ME", CtrlLine
.ASC "DAMNIT!", CtrlPause, CtrlClear 
.DB CtrlFaceShow,1, CtrlSpeed,5
.ASC "IT'S... IT'S OK...", CtrlLine
.ASC "MARISA...", CtrlPause, CtrlClear
.ASC "I'LL JUST... REVERT", CtrlLine
.ASC "TO A... A STATUE", CtrlLine
.ASC "FOR A WHILE.", CtrlPause, CtrlClear
.ASC "IT'S LIKE...", CtrlLine
.ASC "TAKING...", CtrlLine
.ASC "A NAP...", CtrlPause, CtrlClear, CtrlSpeed,7
.ASC "WHAT WAS IT...", CtrlLine
.ASC "YOU WERE...", CtrlLine
.ASC "LOOKING FOR?", CtrlPause, CtrlClear
.DB CtrlFaceShow,2, CtrlSpeed,2, CtrlWait,45
.ASC "...ALICE!", CtrlLine
.ASC "WHERE IS ALICE'S", CtrlLine
.ASC "HOUSE??", CtrlPause, CtrlClear
.DB CtrlFaceShow,1, CtrlSpeed,8, CtrlFaceLoad,2,$00
.ASC "WHEN...", CtrlLine
.ASC "YOU LEAVE...", CtrlLine
.ASC "TAKE... TWO...", CtrlWait,30, CtrlClear
.ASC "...", CtrlLine, "..."
.DB CtrlClear, CtrlFaceShow,2, CtrlFaceLoad,1,$00, CtrlSpeed,3
.ASC "...NARUMI...", CtrlWait,15, CtrlFaceShow,1, CtrlFaceLoad,2,$00, CtrlLine, "!", CtrlWait,10
.ASC CtrlClear, CtrlFaceShow,2, "...RIGHTS.", CtrlPause,
.DB CtrlLower

StringAliceEscort1:
.DB CtrlFaceLoad,1,$00, CtrlFaceLoad,2,$00, CtrlSpeed,4, CtrlFaceShow,1, CtrlClear
.DB CtrlBorder,1, CtrlRaise
.ASC "TEXT", CtrlPause
.DB CtrlLower, CtrlEnd
StringAliceEscort2:
.DB CtrlFaceLoad,1,$00, CtrlFaceLoad,2,$00, CtrlFaceShow,1, CtrlClear
.DB CtrlRaise
.ASC "TEXT", CtrlPause
.DB CtrlLower, CtrlEnd
StringAliceEscort3:
.DB CtrlFaceLoad,1,$00, CtrlFaceLoad,2,$00, CtrlFaceShow,1, CtrlClear
.DB CtrlRaise
.ASC "TEXT", CtrlPause, CtrlClear, CtrlEnd
StringAliceEscort4:
.DB CtrlFaceLoad,1,$00, CtrlFaceLoad,2,$00
.DB CtrlFaceShow,1, CtrlCorner
.ASC "TEXT", CtrlPause
.DB CtrlLower, CtrlEnd

;Conversations:
;Things people say
StringTestInteraction:
.DB CtrlSpeed,3, CtrlFaceShow,0, CtrlClear, CtrlBorder,0, CtrlRaise, CtrlWait,30
.ASC "HI!", CtrlWait,30, CtrlPause
.DB CtrlLower, CtrlEnd
.ENDS
