    ;Wide format
    ;| 0123456789ABCDEF01 |
    ;Narrow format
    ;|FFFF 0123456789ABCD |

.ENUMID 0               ;Arguments
.ENUMID CtrlEnd         ;None
.ENUMID CtrlCorner      ;None
.ENUMID CtrlRaise       ;None
.ENUMID CtrlLower       ;None
.ENUMID CtrlSnapUp      ;None
.ENUMID CtrlSnapDown    ;None
.ENUMID CtrlLeft        ;None (Do not use)
.ENUMID CtrlRight       ;None (Do not use)
.ENUMID CtrlDel         ;None (Do not use)
.ENUMID CtrlTab         ;None (Do not use)
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
.ENUMID CtrlShake       ;Shake slowness (Do not use)
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
.DB CtrlFaceLoad,1,$03, CtrlFaceLoad,2,$01, CtrlBorder,0, CtrlSpeed,2, CtrlWait,1, CtrlFaceShow,1, CtrlClear, CtrlRaise
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
.DB CtrlFaceLoad,1,$07, CtrlFaceLoad,2,$05, CtrlFaceShow,1, CtrlWait,1, CtrlClear, CtrlRaise
.ASC "...I HAVE NO", CtrlLine
.ASC "IDEA WHERE", CtrlLine
.ASC "SHE LIVES.", CtrlPause
.DB CtrlFaceShow,0, CtrlClear, CtrlWait,90, CtrlFaceShow,2, CtrlCorner, CtrlFaceLoad,1,$06
.ASC "THERE'S ONLY", CtrlLine
.ASC "ONE THING", CtrlLine
.ASC "I CAN DO...", CtrlPause, CtrlClear
.DB CtrlEnd
StringOpeningMessage3:
.DB CtrlFaceShow,1, CtrlCorner
.ASC "FIND", CtrlLine
.ASC "ALICE'S", CtrlLine
.ASC "HOUSE!", CtrlPause
.DB CtrlLower, CtrlEnd

StringNarumiStart1:
.DB CtrlFaceLoad,2,$10, CtrlFaceLoad,1,$00, CtrlFaceShow,2, CtrlClear, CtrlBorder,1, CtrlRaise
.ASC "HEYA MARISA.", CtrlPause, CtrlClear
.DB CtrlFaceShow,1, CtrlFaceLoad,2,$11
.ASC "OH, NARUMI.", CtrlPause, CtrlLine
.ASC "DO YOU KNOW", CtrlLine
.ASC "WHER-", CtrlClear
.DB CtrlFaceShow,2, CtrlFaceLoad,1,$07
.ASC "WHAT?", CtrlPause, CtrlClear
.DB CtrlFaceShow,1
.ASC "I WAS LOOKIN-", CtrlClear
.DB CtrlFaceShow,2, CtrlFaceLoad,1,$02
.ASC "NO CHIT-CHAT?", CtrlPause, CtrlClear
.ASC "DON'T WANNA", CtrlLine
.ASC "SPEND TIME", CtrlLine
.ASC "WITH YOUR", CtrlLine
.ASC "FRIENDS?", CtrlPause, CtrlClear
.ASC "STRAIGHTAWAY", CtrlLine
.ASC "TO YOUR NEXT", CtrlLine
.ASC "TARGET?", CtrlPause, CtrlClear
.DB CtrlFaceShow,1, CtrlFaceLoad,2,$12
.ASC "LOOK, I-", CtrlClear
.DB CtrlEnd
StringNarumiStart2:
.DB CtrlFaceShow,2
.ASC "C'MON, MARISA!", CtrlPause, CtrlLine
.ASC "WHY DON'T WE", CtrlLine
.ASC "GO A ROUND?", CtrlPause, CtrlClear
.ASC "IT'S BEEN", CtrlLine
.ASC "SO LONG!", CtrlPause, CtrlClear
.DB CtrlFaceShow,1
.ASC "*SIGH*", CtrlPause
.DB CtrlLower, CtrlEnd

StringNarumiEnd:
.DB CtrlFaceLoad,1,$13, CtrlFaceLoad,2,$04, CtrlSpeed,4, CtrlFaceShow,1, CtrlClear, CtrlRaise
.ASC "OOOHH...", CtrlLine
.ASC "THAT FIGHT...", CtrlLine
.ASC "TOOK MOST OF", CtrlLine
.ASC "MY ENERGY...", CtrlPause, CtrlClear
.DB CtrlFaceShow,2, CtrlSpeed,2
.ASC "NOO!", CtrlLine
.ASC "DON'T DIE", CtrlLine
.ASC "ON ME, DAMNIT!", CtrlPause, CtrlClear 
.DB CtrlFaceShow,1, CtrlSpeed,7
.ASC "IT'S...", CtrlLine
.ASC "IT'S OK...", CtrlLine
.ASC "MARISA...", CtrlPause, CtrlClear
.ASC "I'LL JUST...", CtrlLine
.ASC "REVERT TO A...", CtrlLine
.ASC "A STATUE...", CtrlLine
.ASC "FOR A WHILE.", CtrlPause, CtrlClear
.ASC "IT'S LIKE...", CtrlLine
.ASC "TAKING...", CtrlLine
.ASC "A NAP...", CtrlPause, CtrlClear, CtrlSpeed,8
.ASC "WHAT WAS IT...", CtrlLine
.ASC "YOU WERE...", CtrlLine
.ASC "LOOKING FOR?", CtrlPause, CtrlClear
.DB CtrlFaceShow,2, CtrlSpeed,2, CtrlWait,45
.ASC "...ALICE!", CtrlLine
.ASC "WHERE IS", CtrlLine
.ASC "HER HOUSE??", CtrlPause, CtrlClear
.DB CtrlFaceShow,1, CtrlSpeed,13, CtrlFaceLoad,2,$07
.ASC "WHEN...", CtrlLine
.ASC "YOU LEAVE...", CtrlLine
.ASC "TAKE... TWO...", CtrlWait,80, CtrlClear
.ASC "...", CtrlLine, CtrlWait,40, "...", CtrlPause
.DB CtrlClear, CtrlFaceShow,2, CtrlFaceLoad,1,$04, CtrlSpeed,5
.ASC "...NARUMI...", CtrlWait,70, CtrlFaceShow,1, CtrlFaceLoad,2,$13, CtrlLine, "!", CtrlPause, CtrlSpeed,7
.ASC CtrlClear, CtrlFaceShow,2, "...RIGHTS.", CtrlPause,
.DB CtrlLower, CtrlEnd

StringAliceEscort1:
.DB CtrlFaceLoad,1,$00, CtrlFaceLoad,2,$00, CtrlSpeed,4, CtrlFaceShow,1, CtrlClear
.DB CtrlBorder,1, CtrlRaise
.ASC "TEXT", CtrlPause          ;Marisa meet Alice
.DB CtrlLower, CtrlEnd
StringAliceEscort2:
.DB CtrlFaceLoad,1,$00, CtrlFaceLoad,2,$00, CtrlFaceShow,1, CtrlClear
.DB CtrlRaise
.ASC "TEXT", CtrlPause          ;Alice meet nonhouse
.DB CtrlLower, CtrlEnd
StringAliceEscort3:
.DB CtrlFaceLoad,1,$00, CtrlFaceLoad,2,$00, CtrlFaceShow,1, CtrlClear
.DB CtrlRaise
.ASC "TEXT", CtrlPause          ;Marisa now talk to Alice
.DB CtrlClear, CtrlEnd
StringAliceEscort4:
.DB CtrlFaceShow,2, CtrlCorner
.ASC "TEXT", CtrlPause          ;Convo continue, song change
.DB CtrlLower, CtrlEnd

StringAliceHouse1:
.DB CtrlFaceShow,0, CtrlClear, CtrlRaise
.ASC ".", CtrlPause
.DB CtrlLower, CtrlEnd
StringAliceHouse2:
.DB CtrlClear, CtrlRaise
.ASC "!", CtrlPause
.DB CtrlLower, CtrlEnd
StringAliceHouse3:
.DB CtrlFaceLoad,1,$04, CtrlSpeed,2, CtrlFaceShow,1, CtrlClear
.DB CtrlSnapUp
.ASC "WHOA"
.DB CtrlSnapDown, CtrlEnd

StringHouseBack1:
.DB CtrlFaceShow,0, CtrlClear, CtrlRaise
.ASC ".", CtrlPause
.DB CtrlLower, CtrlEnd

StringReimuMeet:
.DB CtrlFaceLoad,1,$00, CtrlFaceLoad,2,$0E, CtrlFaceShow,1, CtrlClear
.DB CtrlSpeed,2, CtrlBorder,2, CtrlRaise
.ASC "HEY.", CtrlPause, CtrlClear
.DB CtrlFaceShow,2, CtrlFaceLoad,1,$03
.ASC "OI.", CtrlPause, CtrlClear
.DB CtrlFaceShow,1
.ASC "WHAT'CHA DOING", CtrlLine
.ASC "IN THE FOREST?", CtrlPause, CtrlClear
.DB CtrlFaceShow,2, CtrlFaceLoad,1,$05
.ASC "HEADING TO", CtrlLine
.ASC "KOURINDOU.", CtrlPause, CtrlClear
.DB CtrlFaceShow,1, CtrlWait,80
;   *pause*
.ASC "...IT'S RIGHT", CtrlLine
.ASC "THERE.", CtrlPause, CtrlClear
.DB CtrlFaceShow,2
.ASC "TOO HUNGRY.", CtrlLine
.ASC "CAN'T MOVE.", CtrlPause, CtrlClear
.DB CtrlFaceShow,1
.ASC "THEN EAT.", CtrlPause, CtrlClear
.DB CtrlFaceShow,2, CtrlFaceLoad,1,$07
.ASC "SHION'S BEEN", CtrlLine
.ASC "STAYING AT THE", CtrlLine
.ASC "SHRINE,", CtrlPause, CtrlClear
.ASC "SO I HAVEN'T", CtrlLine
.ASC "HAD ANY FOOD", CtrlLine
.ASC "IN DAYS.", CtrlPause, CtrlClear
.DB CtrlFaceShow,1, CtrlFaceLoad,2,$00
.ASC "OUCH.", CtrlPause, CtrlFaceShow,2, "I'LL SEE", CtrlLine
.ASC "IF I CAN FIND", CtrlLine
.ASC "SOMETHIN'", CtrlLine
.ASC "FOR YA.", CtrlPause
.DB CtrlLower, CtrlEnd

StringReimuFeed1:
.DB CtrlFaceLoad,1,$0C, CtrlFaceLoad,2,$01, CtrlFaceShow,1, CtrlClear
.DB CtrlSpeed,2, CtrlBorder,2, CtrlRaise
.ASC "FOOD?", CtrlPause, CtrlClear
.DB CtrlFaceShow,2, CtrlFaceLoad,1,$0E
.ASC "NO.", CtrlPause, CtrlClear
.DB CtrlFaceShow,1
.ASC "...", CtrlPause
.DB CtrlLower, CtrlEnd

StringReimuFeed2:
.DB CtrlFaceLoad,1,$00, CtrlFaceLoad,2,$0D, CtrlFaceShow,1, CtrlClear
.DB CtrlSpeed,2, CtrlBorder,2, CtrlRaise
.ASC "FOUND A", CtrlLine
.ASC "MUSHRO"   ;Interrupted
.DB CtrlClear, CtrlFaceShow,2, CtrlFaceLoad,1,$03
.ASC "*OM NOM NOM*", CtrlPause, CtrlClear
.DB CtrlFaceShow,1, CtrlFaceLoad,2,$0E
.ASC "...BETTER?", CtrlPause, CtrlClear
.DB CtrlEnd
StringReimuFeed3:
.DB CtrlFaceShow,2, CtrlFaceLoad,1,$02
.ASC "NO.", CtrlPause, CtrlClear
.DB CtrlFaceShow,1
.ASC "...", CtrlPause
.DB CtrlLower, CtrlEnd

;Run Feed 2 first
StringReimuFeed4:
.DB CtrlFaceLoad,2,$0F, CtrlWait,2, CtrlFaceShow,2, CtrlFaceLoad,1,$07, CtrlSpeed,3
.ASC "...I FEEL SICK", CtrlPause, CtrlClear
.DB CtrlFaceShow,1
.ASC "UHH...", CtrlPause, CtrlClear
.DB CtrlFaceShow,2
.ASC "WHAT MUSHROOMS", CtrlLine
.ASC "HAVE YOU BEEN", CtrlLine
.ASC "FEEDING ME?", CtrlPause, CtrlClear
.DB CtrlFaceShow,1
.ASC "UM...", CtrlLine, CtrlLine, CtrlWait,60
.ASC "AMANITA?", CtrlPause, CtrlClear
.DB CtrlFaceShow,2, CtrlFaceLoad,1,$05
.ASC "WHY WOULD YOU", CtrlEnd
StringReimuFeed5:
.DB CtrlFaceShow,0, CtrlClear, CtrlSpeed,5
.ASC "  $!&\"*<+/=`#'%  ", CtrlPause
.DB CtrlFaceShow,1, CtrlClear, CtrlSpeed,2
.ASC "NOT A GOOD WAY", CtrlLine
.ASC "TO FIGHT", CtrlLine
.ASC "HUNGER, REIMU.", CtrlPause, CtrlEnd
StringReimuFeed6:
.DB CtrlFaceShow,2, CtrlClear
.ASC "YOU...", CtrlPause, CtrlLine
.ASC "NEXT TIME,", CtrlLine
.ASC "YOUR ASS", CtrlLine
.ASC "IS MINE!", CtrlPause
.DB CtrlLower, CtrlEnd

StringMushroomFound:
.DB CtrlFaceLoad,1,$03, CtrlFaceShow,1, CtrlFaceLoad,2,$02, CtrlClear, CtrlRaise, CtrlSpeed,2
.ASC "OOH A MUSHROOM", CtrlWait,120, CtrlClear, CtrlFaceShow,2, CtrlSpeed,4
.ASC "LOOKS... ", CtrlWait,90, CtrlSpeed,2
.ASC          "TASTY", CtrlLine, CtrlWait,120
.ASC "SURE. TASTY.", CtrlWait,180
.DB CtrlLower, CtrlEnd

.ENDS
