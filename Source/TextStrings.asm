    ;Wide format
    ;| 0123456789ABCDEF01 |
    ;Narrow format
    ;|FFFF 0123456789ABCD |

.ENUMID 0               ;Arguments
.ENUMID CtrlEnd         ;None
.ENUMID CtrlPauseLine   ;None
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
.ENUMID CtrlPauseClear  ;None
.ENUMID CtrlFaceShow1   ;None
.ENUMID CtrlFaceShow2   ;None
.ENUMID CtrlSpeed       ;Text speed
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
.DB CtrlSpeed,2, CtrlEnd, CtrlFaceLoad1|$03, CtrlFaceLoad2|$01, CtrlBorder0, CtrlWait|1, CtrlFaceShow1, CtrlClear, CtrlRaise
.ASC "ALL THAT", CtrlLine
.ASC "RUCKUS OVER A", CtrlLine
.ASC "FEW LITTLE", CtrlLine
.ASC "BOOKS!", CtrlPauseClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$00
.ASC "AT LEAST I GOT", CtrlLine
.ASC "THE ONE ALICE", CtrlLine
.ASC "ASKED FOR.", CtrlPauseClear
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
.DB CtrlFaceShow0, CtrlClear, CtrlWait|45, CtrlWait|45, CtrlFaceShow2, CtrlClear, CtrlFaceLoad1|$06
.ASC "THERE'S ONLY", CtrlLine
.ASC "ONE THING", CtrlLine
.ASC "I CAN DO...", CtrlPauseClear
.DB CtrlEnd
StringOpeningMessage3:
.DB CtrlFaceShow1, CtrlClear
.ASC "FIND", CtrlLine
.ASC "ALICE'S", CtrlLine
.ASC "HOUSE!", CtrlPause
.DB CtrlLower, CtrlEnd

StringNarumiStart1:
.DB CtrlSpeed,2, CtrlFaceLoad2|$10, CtrlFaceLoad1|$00, CtrlFaceShow2, CtrlClear, CtrlBorder1, CtrlRaise
.ASC "HEYA MARISA.", CtrlPauseClear
.DB CtrlFaceShow1, CtrlFaceLoad2|$11
.ASC "OH, NARUMI.", CtrlPauseLine
.ASC "DO YOU KNOW", CtrlLine
.ASC "WHER-", CtrlClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$07
.ASC "WHAT?", CtrlPauseClear
.DB CtrlFaceShow1
.ASC "I WAS LOOKIN-", CtrlClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$02
.ASC "NO CHIT-CHAT?", CtrlPauseClear
.ASC "DON'T WANNA", CtrlLine
.ASC "SPEND TIME", CtrlLine
.ASC "WITH YOUR", CtrlLine
.ASC "FRIENDS?", CtrlPauseClear
.ASC "STRAIGHTAWAY", CtrlLine
.ASC "TO YOUR NEXT", CtrlLine
.ASC "TARGET?", CtrlPauseClear
.DB CtrlFaceShow1, CtrlFaceLoad2|$12
.ASC "LOOK, I-", CtrlClear
.DB CtrlEnd
StringNarumiStart2:
.DB CtrlFaceShow2
.ASC "C'MON, MARISA!", CtrlPauseLine
.ASC "WHY DON'T WE", CtrlLine
.ASC "GO A ROUND?", CtrlPauseClear
.ASC "IT'S BEEN", CtrlLine
.ASC "SO LONG!", CtrlPauseClear
.DB CtrlFaceShow1
.ASC "*SIGH*", CtrlPause
.DB CtrlLower, CtrlEnd

StringNarumiEnd:
.DB CtrlFaceLoad1|$13, CtrlFaceLoad2|$04, CtrlSpeed,4, CtrlFaceShow1, CtrlClear, CtrlRaise
.ASC "OOOHH...", CtrlLine
.ASC "THAT FIGHT...", CtrlLine
.ASC "TOOK MOST OF", CtrlLine
.ASC "MY ENERGY...", CtrlPauseClear
.DB CtrlFaceShow2, CtrlSpeed,2
.ASC "NOO!", CtrlLine
.ASC "DON'T DIE", CtrlLine
.ASC "ON ME, DAMNIT!", CtrlPauseClear 
.DB CtrlFaceShow1, CtrlSpeed,7
.ASC "IT'S...", CtrlLine
.ASC "IT'S OK...", CtrlLine
.ASC "MARISA...", CtrlPauseClear
.ASC "I'LL JUST...", CtrlLine
.ASC "REVERT TO A...", CtrlLine
.ASC "A STATUE...", CtrlLine
.ASC "FOR A WHILE.", CtrlPauseClear
.ASC "IT'S LIKE...", CtrlLine
.ASC "TAKING...", CtrlLine
.ASC "A NAP...", CtrlPauseClear, CtrlSpeed,8
.ASC "WHAT WAS IT...", CtrlLine
.ASC "YOU WERE...", CtrlLine
.ASC "LOOKING FOR?", CtrlPauseClear
.DB CtrlFaceShow2, CtrlSpeed,2, CtrlWait|45
.ASC "...ALICE!", CtrlLine
.ASC "WHERE IS", CtrlLine
.ASC "HER HOUSE??", CtrlPauseClear
.DB CtrlFaceShow1, CtrlSpeed,13, CtrlFaceLoad2|$07
.ASC "WHEN...", CtrlLine
.ASC "YOU LEAVE...", CtrlLine
.ASC "TAKE... TWO...", CtrlWait|40, CtrlWait|40, CtrlClear
.ASC "...", CtrlLine, CtrlWait|40, "...", CtrlPauseClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$04, CtrlSpeed,5
.ASC "...NARUMI...", CtrlPauseLine, CtrlFaceShow1, CtrlFaceLoad2|$13, "!", CtrlSpeed,7, CtrlWait|40
.ASC CtrlClear, CtrlFaceShow2, "...RIGHTS.", CtrlPause,
.DB CtrlLower, CtrlEnd

StringAliceEscort1:
.DB CtrlSpeed,4, CtrlFaceLoad1|$00, CtrlFaceLoad2|$08, CtrlFaceShow1, CtrlClear
.DB CtrlBorder3, CtrlRaise
.ASC "AH,", CtrlLine
.ASC "THERE YOU ARE!", CtrlPauseClear
.DB CtrlFaceShow2
.ASC "YES, I AM HERE."
.ASC "SO WHAT?", CtrlPauseClear
.DB CtrlFaceShow1, CtrlFaceLoad2|$09
.ASC "I GOT THE BOOK", CtrlLine
.ASC "YOU WANTED.", CtrlPauseClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$01
.ASC "OH?", CtrlPauseLine
.ASC "WELL, WE", CtrlLine
.ASC "BETTER HEAD TO", CtrlLine
.ASC "MY PLACE, THEN.", CtrlPauseClear
.ASC "(HOW IS SHE", CtrlLine
.ASC "STILL ALIVE?)", CtrlPauseClear
.DB CtrlFaceShow1, CtrlFaceLoad2|$0B
.ASC "LEAD THE WAY!", CtrlPause
.DB CtrlLower, CtrlEnd
StringAliceEscort2:
.DB CtrlFaceShow2, CtrlFaceLoad1|$05, CtrlClear, CtrlRaise
.ASC "...WHERE IS", CtrlLine
.ASC "MY HOUSE?", CtrlPauseClear
.ASC "WHAT DID", CtrlLine
.ASC "YOU DO WITH", CtrlLine
.ASC "MY HOUSE?", CtrlPauseClear
.DB CtrlFaceShow0, CtrlEnd
StringAliceEscort3:
.DB CtrlFaceShow1, CtrlFaceLoad2|$0A
.ASC "I DON'T EVEN", CtrlLine
.ASC "KNOW WHERE", CtrlLine
.ASC "YOU LIVE!", CtrlPauseClear
.ASC "AND HOW DO YOU", CtrlLine
.ASC "EXPECT ME TO", CtrlLine
.ASC "MOVE A", CtrlLine
.ASC "WHOLE HOUSE?!", CtrlPauseClear
.DB CtrlEnd
StringAliceEscort4:
.DB CtrlFaceShow2, CtrlFaceLoad1|$06
.ASC "I- WH-", CtrlPauseLine
.ASC "DON'T STAND", CtrlLine
.ASC "THERE!", CtrlPauseClear
.DB CtrlFaceShow1
.ASC "IT'S NOT A", CtrlLine
.ASC "BURIAL SITE!", CtrlLine
.ASC "CALM DOWN!", CtrlPause
.DB CtrlLower, CtrlEnd

StringAliceHouse1:
.DB CtrlFaceLoad1|$00, CtrlFaceShow1, CtrlFaceLoad2|$04, CtrlBorder0
.DB CtrlClear, CtrlSpeed,3, CtrlRaise
.ASC "AHH... FINALLY.", CtrlPause
.ASC "THE ONLY OTHER", CtrlLine
.ASC "HOUSE IN THE", CtrlLine
.ASC "FOREST.", CtrlPauseClear
.ASC "SO, IT'S", CtrlLine
.ASC "PROBABLY", CtrlLine
.ASC "ALICE'S.", CtrlPause
.DB CtrlLower, CtrlEnd
StringAliceHouse2:
.DB CtrlFaceShow2, CtrlClear, CtrlRaise, CtrlFaceLoad1|$05
.ASC "OH, ALICE!", CtrlPauseClear
.ASC "DIDN'T EXPECT", CtrlLine
.ASC "TO SEE YOU", CtrlLine
.ASC "HERE.", CtrlPause
.DB CtrlFaceShow1, CtrlSpeed,5, CtrlFaceLoad2|$0B
.ASC      "..AT YOUR", CtrlLine
.ASC "HOUSE...", CtrlPauseClear, CtrlSpeed,3
.DB CtrlFaceShow2, CtrlFaceLoad1|$00
.ASC "HOW'D YOU KNOW", CtrlLine
.ASC "WHERE I LIVE?", CtrlPauseClear
.DB CtrlEnd
StringAliceHouse3:
.DB CtrlFaceShow1
.ASC "NARUMI TOLD ME.", CtrlPauseClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$01
.ASC "...I SEE. I'LL", CtrlLine
.ASC "DEAL WITH HER", CtrlLine
.ASC "LATER.", CtrlPauseClear
.ASC "FOR NOW, YOU", CtrlLine
.ASC "COME IN.", CtrlPauseClear
.DB CtrlEnd
StringAliceHouse4:
.DB CtrlFaceShow1
.ASC "TRIAL AND", CtrlLine
.ASC "ERROR.", CtrlPauseClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$01
.ASC "...I SEE.", CtrlPauseLine
.ASC "FINE. WHATEVER."
.ASC "COME IN,", CtrlLine
.ASC "I GUESS.", CtrlPauseClear
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
.DB CtrlFaceLoad1|$00, CtrlFaceLoad2|$03, CtrlFaceShow1, CtrlBorder0
.DB CtrlClear, CtrlRaise, CtrlSpeed,2
.ASC "NEVER SEEN", CtrlLine
.ASC "THIS PLACE", CtrlLine
.ASC "BEFORE!", CtrlPauseClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$01
.ASC "MAYBE IT'S", CtrlLine
.ASC "A DUNGEON?", CtrlPauseClear
.DB CtrlFaceShow1
.ASC "THERE'S ALWAYS", CtrlLine
.ASC "GOOD LOOT TO", CtrlLine
.ASC "BE HAD IN", CtrlLine
.ASC "A DUNGEON!", CtrlPauseClear
.DB CtrlEnd
StringHouseBack2:
.DB CtrlFaceShow2, CtrlFaceLoad1|$04
.ASC "SO MUCH FABRIC!", CtrlPause
.ASC "WOODEN HEADS?", CtrlLine
.ASC "POSEABLE ARMS?", CtrlPauseLine
.ASC "OOH CREEPY!", CtrlPauseClear
.ASC "ALICE WOULD", CtrlLine
.ASC "LOVE", CtrlLine
.ASC "THIS PLACE.", CtrlPauseClear
.DB CtrlWait|63
.ASC "HOW LIFELIKE!", CtrlPauseLine
.ASC "IT'S EVEN", CtrlLine
.ASC "SQUISHY~", CtrlPauseLine
.DB CtrlFaceShow1, CtrlFaceLoad2|$00
.ASC "OW! IT BIT ME!", CtrlPauseClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$06
.ASC "OH!", CtrlLine
.ASC "YOU MUST BE", CtrlLine
.ASC "THE DUNGEON", CtrlLine
.ASC "ENEMIES!", CtrlPauseClear
.DB CtrlFaceShow1, CtrlFaceLoad2|$0A
.ASC "I'LL BLOW YOU", CtrlLine
.ASC "ALL TO", CtrlLine
.ASC "SMITHEREENS!", CtrlPause
.DB CtrlLower, CtrlEnd
StringHouseBack3:
.DB CtrlFaceShow2, CtrlFaceLoad1|$00 CtrlClear, CtrlRaise
.ASC "WHAT ON EARTH", CtrlLine
.ASC "IS GOING ON", CtrlLine
.ASC "IN HERE?!", CtrlPauseClear
.DB CtrlFaceShow1
.ASC "OH, ALICE!", CtrlLine
.ASC "WHAT A", CtrlLine
.ASC "SURPRISE!", CtrlPauseClear
.ASC "ARE YOU ALSO", CtrlLine
.ASC "EXPLORING", CtrlLine
.ASC "THIS DUNGEON?", CtrlPauseClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$07
.ASC "WHAT?", CtrlPauseLine
.ASC "WHAT ARE YOU", CtrlLine
.ASC "DOING HERE?!", CtrlPauseClear
.DB CtrlFaceShow1
.ASC "I WAS-", CtrlClear
.DB CtrlFaceShow2
.ASC "SHUT UP!", CtrlLine
.ASC "GET OUT!", CtrlPauseClear
.DB CtrlFaceShow1
.ASC "HEY, WHA-", CtrlFaceShow0, CtrlClear
.DB CtrlLower, CtrlEnd

StringReimuMeet:
.DB CtrlFaceLoad1|$00, CtrlFaceLoad2|$0E, CtrlFaceShow1, CtrlClear
.DB CtrlSpeed,2, CtrlBorder2, CtrlRaise
.ASC "HEY.", CtrlPauseClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$03
.ASC "OI.", CtrlPauseClear
.DB CtrlFaceShow1
.ASC "WHAT'CHA DOING", CtrlLine
.ASC "IN THE FOREST?", CtrlPauseClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$05
.ASC "HEADING TO", CtrlLine
.ASC "KOURINDOU.", CtrlPauseClear
.DB CtrlFaceShow1, CtrlWait|40, CtrlWait|40
;   *pause*
.ASC "...IT'S RIGHT", CtrlLine
.ASC "THERE.", CtrlPauseClear
.DB CtrlFaceShow2
.ASC "TOO HUNGRY.", CtrlLine
.ASC "CAN'T MOVE.", CtrlPauseClear
.DB CtrlFaceShow1
.ASC "THEN EAT.", CtrlPauseClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$07
.ASC "SHION'S BEEN", CtrlLine
.ASC "STAYING AT THE", CtrlLine
.ASC "SHRINE,", CtrlPauseClear
.ASC "SO I HAVEN'T", CtrlLine
.ASC "HAD ANY FOOD", CtrlLine
.ASC "IN DAYS.", CtrlPauseClear
.DB CtrlFaceShow1, CtrlFaceLoad2|$00
.ASC "OUCH.", CtrlPause, CtrlFaceShow2, "I'LL SEE", CtrlLine
.ASC "IF I CAN FIND", CtrlLine
.ASC "SOMETHIN'", CtrlLine
.ASC "FOR YA.", CtrlPause
.DB CtrlLower, CtrlEnd

StringReimuFeed1:
.DB CtrlFaceLoad1|$0C, CtrlFaceLoad2|$01, CtrlFaceShow1, CtrlClear
.DB CtrlSpeed,2, CtrlBorder2, CtrlRaise
.ASC "FOOD?", CtrlPauseClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$0E
.ASC "NO.", CtrlPauseClear
.DB CtrlFaceShow1
.ASC "...", CtrlPause
.DB CtrlLower, CtrlEnd

StringReimuFeed2:
.DB CtrlFaceLoad1|$00, CtrlFaceLoad2|$0D, CtrlFaceShow1, CtrlClear
.DB CtrlSpeed,2, CtrlBorder2, CtrlRaise
.ASC "FOUND A", CtrlLine
.ASC "MUSHRO"   ;Interrupted
.DB CtrlClear, CtrlFaceShow2, CtrlFaceLoad1|$03
.ASC "*OM NOM NOM*", CtrlPauseClear
.DB CtrlFaceShow1, CtrlFaceLoad2|$0E
.ASC "...BETTER?", CtrlPauseClear
.DB CtrlEnd
StringReimuFeed3:
.DB CtrlFaceShow2, CtrlFaceLoad1|$02
.ASC "NO.", CtrlPauseClear
.DB CtrlFaceShow1
.ASC "...", CtrlPause
.DB CtrlLower, CtrlEnd

;Run Feed 2 first
StringReimuFeed4:
.DB CtrlFaceLoad2|$0F, CtrlWait|2, CtrlFaceShow2, CtrlFaceLoad1|$07, CtrlSpeed,3
.ASC "...I FEEL SICK", CtrlPauseClear
.DB CtrlFaceShow1
.ASC "UHH...", CtrlPauseClear
.DB CtrlFaceShow2
.ASC "WHAT MUSHROOMS", CtrlLine
.ASC "HAVE YOU BEEN", CtrlLine
.ASC "FEEDING ME?", CtrlPauseClear
.DB CtrlFaceShow1
.ASC "UM...", CtrlLine, CtrlLine, CtrlWait|60
.ASC "AMANITA?", CtrlPauseClear
.DB CtrlFaceShow2, CtrlFaceLoad1|$05
.ASC "WHY WOULD YOU", CtrlEnd
StringReimuFeed5:
.DB CtrlFaceShow0, CtrlClear, CtrlSpeed,5
   ;| 0123456789ABCDEF01 |
.ASC "  $!&\"*<+/=`#'%  ", CtrlPause
.DB CtrlFaceShow1, CtrlClear, CtrlSpeed,2
.ASC "NOT A GOOD WAY", CtrlLine
.ASC "TO FIGHT", CtrlLine
.ASC "HUNGER, REIMU.", CtrlPause, CtrlEnd
StringReimuFeed6:
.DB CtrlFaceShow2, CtrlClear
.ASC "YOU...", CtrlPauseLine
.ASC "NEXT TIME,", CtrlLine
.ASC "YOUR ASS", CtrlLine
.ASC "IS MINE!", CtrlPause
.DB CtrlLower, CtrlEnd

StringMushroomFound:
.DB CtrlFaceLoad1|$03, CtrlFaceShow1, CtrlBorder2, CtrlFaceLoad2|$02, CtrlClear, CtrlRaise, CtrlSpeed,2
.ASC "OOH A MUSHROOM!", CtrlWait|60, CtrlWait|60, CtrlSpeed,4
.ASC "LOOKS... ", CtrlWait|45, CtrlFaceShow2, CtrlWait|45, CtrlSpeed,2
.ASC          "TASTY.", CtrlWait|60, CtrlWait|60
.ASC "SURE. TASTY.", CtrlWait|60, CtrlWait|60, CtrlWait|60
.DB CtrlLower, CtrlEnd

.ENDS
