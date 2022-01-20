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
.ENUMID CtrlBorder0     ;None
.ENUMID CtrlBorder1     ;None
.ENUMID CtrlBorder2     ;None
.ENUMID CtrlBorder3     ;None
.ENUMID CtrlLine        ;None
.ENUMID CtrlPause       ;None
.ENUMID CtrlClear       ;None
.ENUMID CtrlRet         ;None
.ENUMID CtrlFaceShow1   ;None
.ENUMID CtrlFaceShow2   ;None
.ENUMID CtrlSpeed       ;Text speed
.ENUMID Ctrl_Invalid    ;Do not use
.ENUMID CtrlFaceShow0   ;None

.DEFINE CtrlFaceLoad1   %11000000
.DEFINE CtrlFaceLoad2   %11100000
.DEFINE CtrlWait        %10000000

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
.DB CtrlFaceLoad1|$03, CtrlFaceLoad2|$01, CtrlBorder0, CtrlSpeed,2, CtrlWait|1, CtrlFaceShow1, CtrlClear, CtrlRaise
.ASC "ALL THAT", CtrlLine
.ASC "RUCKUS OVER A", CtrlLine
.ASC "FEW LITTLE", CtrlLine
.ASC "BOOKS!", CtrlPause, CtrlClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$00
.ASC "AT LEAST I GOT", CtrlLine
.ASC "THE ONE ALICE", CtrlLine
.ASC "ASKED FOR.", CtrlPause, CtrlClear
.DB CtrlFaceShow1
.ASC "BETTER GO PAY", CtrlLine
.ASC "HER A VISIT,", CtrlLine
.ASC "THEN.", CtrlPause
.DB CtrlLower, CtrlEnd
StringOpeningMessage2:
.DB CtrlFaceLoad1|$07, CtrlFaceLoad2|$05, CtrlFaceShow1, CtrlWait|1, CtrlClear, CtrlRaise
.ASC "...I HAVE NO", CtrlLine
.ASC "IDEA WHERE", CtrlLine
.ASC "SHE LIVES.", CtrlPause
.DB CtrlFaceShow0, CtrlClear, CtrlWait|45, CtrlWait|45, CtrlFaceShow2, CtrlCorner, CtrlFaceLoad1|$06
.ASC "THERE'S ONLY", CtrlLine
.ASC "ONE THING", CtrlLine
.ASC "I CAN DO...", CtrlPause, CtrlClear
.DB CtrlEnd
StringOpeningMessage3:
.DB CtrlFaceShow1, CtrlCorner
.ASC "FIND", CtrlLine
.ASC "ALICE'S", CtrlLine
.ASC "HOUSE!", CtrlPause
.DB CtrlLower, CtrlEnd

StringNarumiStart1:
.DB CtrlFaceLoad2|$10, CtrlFaceLoad1|$00, CtrlFaceShow2, CtrlClear, CtrlBorder1, CtrlRaise
.ASC "HEYA MARISA.", CtrlPause, CtrlClear
.DB CtrlFaceShow1, CtrlFaceLoad2|$11
.ASC "OH, NARUMI.", CtrlPause, CtrlLine
.ASC "DO YOU KNOW", CtrlLine
.ASC "WHER-", CtrlClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$07
.ASC "WHAT?", CtrlPause, CtrlClear
.DB CtrlFaceShow1
.ASC "I WAS LOOKIN-", CtrlClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$02
.ASC "NO CHIT-CHAT?", CtrlPause, CtrlClear
.ASC "DON'T WANNA", CtrlLine
.ASC "SPEND TIME", CtrlLine
.ASC "WITH YOUR", CtrlLine
.ASC "FRIENDS?", CtrlPause, CtrlClear
.ASC "STRAIGHTAWAY", CtrlLine
.ASC "TO YOUR NEXT", CtrlLine
.ASC "TARGET?", CtrlPause, CtrlClear
.DB CtrlFaceShow1, CtrlFaceLoad2|$12
.ASC "LOOK, I-", CtrlClear
.DB CtrlEnd
StringNarumiStart2:
.DB CtrlFaceShow2
.ASC "C'MON, MARISA!", CtrlPause, CtrlLine
.ASC "WHY DON'T WE", CtrlLine
.ASC "GO A ROUND?", CtrlPause, CtrlClear
.ASC "IT'S BEEN", CtrlLine
.ASC "SO LONG!", CtrlPause, CtrlClear
.DB CtrlFaceShow1
.ASC "*SIGH*", CtrlPause
.DB CtrlLower, CtrlEnd

StringNarumiEnd:
.DB CtrlFaceLoad1|$13, CtrlFaceLoad2|$04, CtrlSpeed,4, CtrlFaceShow1, CtrlClear, CtrlRaise
.ASC "OOOHH...", CtrlLine
.ASC "THAT FIGHT...", CtrlLine
.ASC "TOOK MOST OF", CtrlLine
.ASC "MY ENERGY...", CtrlPause, CtrlClear
.DB CtrlFaceShow2, CtrlSpeed,2
.ASC "NOO!", CtrlLine
.ASC "DON'T DIE", CtrlLine
.ASC "ON ME, DAMNIT!", CtrlPause, CtrlClear 
.DB CtrlFaceShow1, CtrlSpeed,7
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
.DB CtrlFaceShow2, CtrlSpeed,2, CtrlWait|45
.ASC "...ALICE!", CtrlLine
.ASC "WHERE IS", CtrlLine
.ASC "HER HOUSE??", CtrlPause, CtrlClear
.DB CtrlFaceShow1, CtrlSpeed,13, CtrlFaceLoad2|$07
.ASC "WHEN...", CtrlLine
.ASC "YOU LEAVE...", CtrlLine
.ASC "TAKE... TWO...", CtrlWait|40, CtrlWait|40, CtrlClear
.ASC "...", CtrlLine, CtrlWait|40, "...", CtrlPause
.DB CtrlClear, CtrlFaceShow2, CtrlFaceLoad1|$04, CtrlSpeed,5
.ASC "...NARUMI...", CtrlWait|35, CtrlWait|35, CtrlFaceShow1, CtrlFaceLoad2|$13, CtrlLine, "!", CtrlPause, CtrlSpeed,7
.ASC CtrlClear, CtrlFaceShow2, "...RIGHTS.", CtrlPause,
.DB CtrlLower, CtrlEnd

StringAliceEscort1:
.DB CtrlFaceLoad1|$00, CtrlFaceLoad2|$00, CtrlSpeed,4, CtrlFaceShow1, CtrlClear
.DB CtrlBorder1, CtrlRaise
.ASC "TEXT", CtrlPause          ;Marisa meet Alice
.DB CtrlLower, CtrlEnd
StringAliceEscort2:
.DB CtrlFaceLoad1|$00, CtrlFaceLoad2|$00, CtrlFaceShow1, CtrlClear
.DB CtrlRaise
.ASC "TEXT", CtrlPause          ;Alice meet nonhouse
.DB CtrlLower, CtrlEnd
StringAliceEscort3:
.DB CtrlFaceLoad1|$00, CtrlFaceLoad2|$00, CtrlFaceShow1, CtrlClear
.DB CtrlRaise
.ASC "TEXT", CtrlPause          ;Marisa now talk to Alice
.DB CtrlClear, CtrlEnd
StringAliceEscort4:
.DB CtrlFaceShow2, CtrlCorner
.ASC "TEXT", CtrlPause          ;Convo continue, song change
.DB CtrlLower, CtrlEnd

StringAliceHouse1:
.DB CtrlFaceLoad1|$00, CtrlFaceShow1, CtrlFaceLoad2|$04
.DB CtrlClear, CtrlSpeed,3, CtrlRaise
.ASC "AHH... FINALLY.", CtrlPause
.ASC "THE ONLY OTHER", CtrlLine
.ASC "HOUSE IN THE", CtrlLine
.ASC "FOREST.", CtrlPause, CtrlClear
.ASC "SO, IT'S", CtrlLine
.ASC "PROBABLY", CtrlLine
.ASC "ALICE'S.", CtrlPause
.DB CtrlLower, CtrlEnd
StringAliceHouse2:
.DB CtrlFaceShow2, CtrlClear, CtrlRaise, CtrlFaceLoad1|$05
.ASC "OH, ALICE!", CtrlPause, CtrlClear
.ASC "DIDN'T EXPECT", CtrlLine
.ASC "TO SEE YOU", CtrlLine
.ASC "HERE", CtrlPause
.DB CtrlFaceShow1, CtrlSpeed,5, CtrlFaceLoad2|$0B
.ASC     "...AT YOUR", CtrlLine
.ASC "HOUSE...", CtrlPause, CtrlClear, CtrlSpeed,3
.DB CtrlFaceShow2, CtrlFaceLoad1|$00
.ASC "HOW'D YOU KNOW", CtrlLine
.ASC "WHERE I LIVE?", CtrlPause, CtrlClear
.DB CtrlEnd
StringAliceHouse3:
.DB CtrlFaceShow1
.ASC "NARUMI TOLD ME.", CtrlPause, CtrlClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$01
.ASC "...I SEE. I'LL", CtrlLine
.ASC "DEAL WITH HER", CtrlLine
.ASC "LATER.", CtrlPause, CtrlClear
.ASC "FOR NOW, YOU", CtrlLine
.ASC "COME IN.", CtrlPause, CtrlClear
.DB CtrlEnd
StringAliceHouse4:
.DB CtrlFaceShow1
.ASC "TRIAL AND", CtrlLine
.ASC "ERROR.", CtrlPause, CtrlClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$01
.ASC "...I SEE.", CtrlPause, CtrlLine
.ASC "FINE. WHATEVER."
.ASC "COME IN,", CtrlLine
.ASC "I GUESS.", CtrlPause, CtrlClear
.DB CtrlEnd
StringAliceHouse5:
.DB CtrlFaceShow1, CtrlFaceLoad2|$04
.ASC "OKIE-DOKIE!", CtrlPause
.DB CtrlLower, CtrlEnd
StringAliceHouse6:
.DB CtrlFaceShow2, CtrlClear
.DB CtrlSnapUp
.ASC "WHOA!"
.DB CtrlSnapDown, CtrlEnd

StringHouseBack1:
.DB CtrlFaceShow0, CtrlClear, CtrlRaise
.ASC ".", CtrlPause
.DB CtrlLower, CtrlEnd

StringReimuMeet:
.DB CtrlFaceLoad1|$00, CtrlFaceLoad2|$0E, CtrlFaceShow1, CtrlClear
.DB CtrlSpeed,2, CtrlBorder2, CtrlRaise
.ASC "HEY.", CtrlPause, CtrlClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$03
.ASC "OI.", CtrlPause, CtrlClear
.DB CtrlFaceShow1
.ASC "WHAT'CHA DOING", CtrlLine
.ASC "IN THE FOREST?", CtrlPause, CtrlClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$05
.ASC "HEADING TO", CtrlLine
.ASC "KOURINDOU.", CtrlPause, CtrlClear
.DB CtrlFaceShow1, CtrlWait|40, CtrlWait|40
;   *pause*
.ASC "...IT'S RIGHT", CtrlLine
.ASC "THERE.", CtrlPause, CtrlClear
.DB CtrlFaceShow2
.ASC "TOO HUNGRY.", CtrlLine
.ASC "CAN'T MOVE.", CtrlPause, CtrlClear
.DB CtrlFaceShow1
.ASC "THEN EAT.", CtrlPause, CtrlClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$07
.ASC "SHION'S BEEN", CtrlLine
.ASC "STAYING AT THE", CtrlLine
.ASC "SHRINE,", CtrlPause, CtrlClear
.ASC "SO I HAVEN'T", CtrlLine
.ASC "HAD ANY FOOD", CtrlLine
.ASC "IN DAYS.", CtrlPause, CtrlClear
.DB CtrlFaceShow1, CtrlFaceLoad2|$00
.ASC "OUCH.", CtrlPause, CtrlFaceShow2, "I'LL SEE", CtrlLine
.ASC "IF I CAN FIND", CtrlLine
.ASC "SOMETHIN'", CtrlLine
.ASC "FOR YA.", CtrlPause
.DB CtrlLower, CtrlEnd

StringReimuFeed1:
.DB CtrlFaceLoad1|$0C, CtrlFaceLoad2|$01, CtrlFaceShow1, CtrlClear
.DB CtrlSpeed,2, CtrlBorder2, CtrlRaise
.ASC "FOOD?", CtrlPause, CtrlClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$0E
.ASC "NO.", CtrlPause, CtrlClear
.DB CtrlFaceShow1
.ASC "...", CtrlPause
.DB CtrlLower, CtrlEnd

StringReimuFeed2:
.DB CtrlFaceLoad1|$00, CtrlFaceLoad2|$0D, CtrlFaceShow1, CtrlClear
.DB CtrlSpeed,2, CtrlBorder2, CtrlRaise
.ASC "FOUND A", CtrlLine
.ASC "MUSHRO"   ;Interrupted
.DB CtrlClear, CtrlFaceShow2, CtrlFaceLoad1|$03
.ASC "*OM NOM NOM*", CtrlPause, CtrlClear
.DB CtrlFaceShow1, CtrlFaceLoad2|$0E
.ASC "...BETTER?", CtrlPause, CtrlClear
.DB CtrlEnd
StringReimuFeed3:
.DB CtrlFaceShow2, CtrlFaceLoad1|$02
.ASC "NO.", CtrlPause, CtrlClear
.DB CtrlFaceShow1
.ASC "...", CtrlPause
.DB CtrlLower, CtrlEnd

;Run Feed 2 first
StringReimuFeed4:
.DB CtrlFaceLoad2|$0F, CtrlWait|2, CtrlFaceShow2, CtrlFaceLoad1|$07, CtrlSpeed,3
.ASC "...I FEEL SICK", CtrlPause, CtrlClear
.DB CtrlFaceShow1
.ASC "UHH...", CtrlPause, CtrlClear
.DB CtrlFaceShow2
.ASC "WHAT MUSHROOMS", CtrlLine
.ASC "HAVE YOU BEEN", CtrlLine
.ASC "FEEDING ME?", CtrlPause, CtrlClear
.DB CtrlFaceShow1
.ASC "UM...", CtrlLine, CtrlLine, CtrlWait|60
.ASC "AMANITA?", CtrlPause, CtrlClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$05
.ASC "WHY WOULD YOU", CtrlEnd
StringReimuFeed5:
.DB CtrlFaceShow0, CtrlClear, CtrlSpeed,5
.ASC "  $!&\"*<+/=`#'%  ", CtrlPause
.DB CtrlFaceShow1, CtrlClear, CtrlSpeed,2
.ASC "NOT A GOOD WAY", CtrlLine
.ASC "TO FIGHT", CtrlLine
.ASC "HUNGER, REIMU.", CtrlPause, CtrlEnd
StringReimuFeed6:
.DB CtrlFaceShow2, CtrlClear
.ASC "YOU...", CtrlPause, CtrlLine
.ASC "NEXT TIME,", CtrlLine
.ASC "YOUR ASS", CtrlLine
.ASC "IS MINE!", CtrlPause
.DB CtrlLower, CtrlEnd

StringMushroomFound:
.DB CtrlFaceLoad1|$03, CtrlFaceShow1, CtrlFaceLoad2|$02, CtrlClear, CtrlRaise, CtrlSpeed,2
.ASC "OOH A MUSHROOM", CtrlWait|60, CtrlWait|60, CtrlClear, CtrlFaceShow2, CtrlSpeed,4
.ASC "LOOKS... ", CtrlWait|45, CtrlWait|45, CtrlSpeed,2
.ASC          "TASTY", CtrlLine, CtrlWait|60, CtrlWait|60
.ASC "SURE. TASTY.", CtrlWait|60, CtrlWait|60, CtrlWait|60
.DB CtrlLower, CtrlEnd

.ENDS
