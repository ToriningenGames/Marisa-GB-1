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

;Alice: "..."
;Alice: "What are you all doing at my house?"
;Maris: "Partying."
;Reimu: "Alcohol."
;Alice: "And WHY at my house?"
;Maris: "Convenience."
;Reimu: "All the alcohol landed here after the explosion."
;Alice: "!!!"
;Alice: "...???"
;Maris: "Master spark. Previous owners weren't too keen on giving it up."
;Alice closes door behind her, steps off porch
;Alice: "Now would be a good time to relocate."
;Reimu: "Why?"
;Maris: "How about a drink?"
;Alice: "How about no, and how about..."
;Alice: "Getting away from my house!"
    ;Wide format
    ;| 0123456789ABCDEF01 |
    ;Narrow format
    ;|FFFF 0123456789ABCD |
StringDemoMessage1:
.DB CtrlFaceLoad,1,$02, CtrlFaceLoad,2,$17, CtrlSpeed,3
  .DB CtrlFaceShow,1, CtrlClear, CtrlRaise, CtrlWait,5
  .ASC    "WHAT ARE YOU", CtrlLine
  .ASC    "ALL DOING AT", CtrlLine
  .ASC    "MY HOUSE?"
.DB CtrlWait,25, CtrlClear, CtrlFaceShow,2, CtrlFaceLoad,1,$22
  .ASC    "PARTYING."
.DB CtrlWait,20, CtrlClear, CtrlFaceShow,1, CtrlFaceLoad,2,$04
  .ASC    "ALCOHOL."
.DB CtrlWait,25, CtrlClear, CtrlFaceShow,2, CtrlFaceLoad,1,$11
  .ASC    "AND "
  .DB CtrlSpeed,6
  .ASC        "WHY "
  .DB CtrlLine, CtrlWait,10, CtrlSpeed,3
  .ASC    "AT MY HOUSE?"
.DB CtrlWait,25, CtrlClear, CtrlFaceShow,1, CtrlFaceLoad,2,$22
  .ASC    "CONVENIENCE."
.DB CtrlWait,20, CtrlClear, CtrlFaceShow,2, CtrlFaceLoad,1,$00
  .ASC    "ALL THE", CtrlLine
  .ASC    "ALCOHOL LANDED", CtrlLine
  .ASC    "HERE AFTER THE", CtrlLine
  .ASC    "EXPLOSION."
.DB CtrlWait,25, CtrlClear, CtrlFaceShow,1, CtrlFaceLoad,2,$01
  .ASC    "!!!"
  .DB CtrlWait,25, CtrlLine
  .DB CtrlSpeed,6, CtrlFaceShow,2, CtrlFaceLoad,1,$11
  .ASC    "..."
  .DB CtrlSpeed,3
  .ASC       "???"
.DB CtrlWait,25, CtrlClear, CtrlFaceShow,1
  .ASC    "MASTER SPARK.", CtrlLine
  .ASC    "PRIOR OWNERS", CtrlLine
  .ASC    "WEREN'T TOO", CtrlLine
  .ASC    "KEEN ON...", CtrlWait,35, CtrlClear
  .ASC    "<DONATING\" IT.", CtrlLine
.DB CtrlWait,25, CtrlLower, CtrlEnd

StringDemoMessage2:
.DB CtrlFaceLoad,1,$01, CtrlFaceLoad,2,$12, CtrlSpeed,3
  .DB CtrlFaceShow,1, CtrlClear, CtrlRaise, CtrlWait,5
  .ASC    "NOW WOULD BE A", CtrlLine
  .ASC    "GOOD TIME TO", CtrlLine
  .ASC    "RELOCATE."
.DB CtrlWait,25, CtrlClear, CtrlFaceShow,2, CtrlFaceLoad,1,$22
  .ASC    "WHY?"
.DB CtrlWait,20, CtrlClear, CtrlFaceShow,1, CtrlFaceLoad,2,$00
  .ASC    "HOW ABOUT A", CtrlLine
  .ASC    "DRINK?"
.DB CtrlWait,25, CtrlClear, CtrlFaceShow,2, CtrlFaceLoad,1,$04
  .ASC    "HOW ABOUT NO,", CtrlLine, CtrlFaceShow,1, CtrlFaceLoad,2,$02
  .ASC    "AND HOW ABOUT..."
.DB CtrlWait,25, CtrlClear, CtrlFaceShow,2
.DB CtrlShake,$80
  .ASC    "GETTING AWAY", CtrlLine
  .ASC    "FROM MY HOUSE!"
.DB CtrlWait,25, CtrlLower, CtrlEnd

.ENDS
