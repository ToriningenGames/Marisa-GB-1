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
.ENUMID CtrlInput       ;None
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
;TODO: Reconsider text method...
    ;Maybe out of band control?
    ;All doable with only text and cursor movement.
        ;Tedious. Write a conversion program.
        ;And speed. And shake.
        ;And face control
StringTestMessage:  ;missing input, up, right, corner; right and corner are done incidentally
.DB CtrlSpeed,3, CtrlClear, CtrlRaise, CtrlFaceLoad,1,$10, CtrlFaceLoad,2,$05
.ASC "WELCOME TO GAME!!",CtrlLine
.ASC "*THERE'S NO SPACE",CtrlLine
.ASC "FOR THE <THE\".",CtrlLine
.DB CtrlWait,30, CtrlClear, CtrlTab
.ASC     "- SORRY."
.DB CtrlDel,CtrlDel,CtrlDel,CtrlDel,CtrlDel,CtrlDel,CtrlDel,CtrlDel
.DB CtrlWait,15
.DB CtrlSpeed,12
.ASC "ANYWAYS..."
.DB CtrlSpeed,3
.ASC           " HI~+",CtrlLine
.ASC "NOBODY KNOWS WHAT'S",CtrlLine
.ASC "IN STORE."
.DB CtrlWait,15, CtrlRet
.ASC "GOING ON...="
.DB CtrlWait,15, CtrlClear
.ASC "THIS WORLD HAS NO",CtrlLine
.ASC "COLOR.",CtrlLine, CtrlBorder,1, CtrlWait,5
.ASC "WHAT DOES THAT MEAN?"
.DB CtrlWait,15, CtrlClear
.ASC "ty",CtrlLeft,CtrlLeft,CtrlDown,"gh"
.ASC   "  I HAVE A FACE."
.DB CtrlWait,15, CtrlFaceShow,1, CtrlWait,15, CtrlClear, CtrlLine
.ASC     "I CARE ABOUT YOU"
.DB CtrlWait,30, CtrlClear, CtrlFaceShow,2, CtrlShake,$0F
.DB CtrlLine,CtrlLine
.ASC "BUT SHE DOESN'T!"
.DB CtrlWait,10, CtrlFaceShow,0, CtrlClear
.ASC "JK LOL"
.DB CtrlWait,5, CtrlClear
.ASC "SERIOUSLY, THOUGH,", CtrlLine
.ASC "WHAT KIND OF GAME", CtrlLine
.ASC "ARE WE IN FOR?"
.DB CtrlWait,60, CtrlLower
.DB CtrlEnd

StringDemoMessage:
.DB CtrlSpeed,3, CtrlClear, CtrlRaise, CtrlFaceLoad,1,$10, CtrlFaceLoad,2,$05
.DB CtrlEnd

.ENDS
