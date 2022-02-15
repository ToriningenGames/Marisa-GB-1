;Fairy behaviour

.include "ActorData.asm"

;We have
    ;Long hair     and Short hair
    ;Striped dress and Solid dress
    ;Thick wing    and Thin wing
;With only a couple hiccups, these are interchangeable, leading to
;2 * 2 * 2 == 2 ^ 3 == 8 different fairy designs!
;Each additional fairy design will also only take up 4 tiles,
    ;and increase the above dramatically!
;(You forgot back and side facings when writing those numbers)

.SECTION "Fairy" FREE

;Animation:
    ;Take the upper wings, and move them down one tile
    ;Take the lower wings, and move them up one tile
    ;Wait
    ;Take the upper wings, and move them up one tile
    ;Take the lower wings, and move them down one tile
    ;Wait
    ;Repeat
    
    ;Head bob optional
    ;Move the wings inwards too?

;Fairy Types:
    ;%AAHHBBWW
    ;       ++--- Wing type
    ;     ++----- Body type
    ;   ++------- Hair type
    ; ++--------- AI type
  ;Values:
    ;0: Zombie part
    ;1: Prim part
    ;2: Experienced part
    ;3: Invalid part

;facing data
;Order:
    ;Relative Y
    ;Relative X
    ;Tile
    ;Attribute XOR (For correct flips)
;All UDLR designations are screen-based

FairyActorData:
 .dw 100
 .dw FairyHitboxes
 .dw FairyFrame
 .dw _HatValues
 .dw _Animations

FairyConstructor:
;Takes in the Fairy Designator byte and provides the correct animation data in RAM
;Then, it makes an instance of the fairy, which knows to free it when done
;Of course, it provides the values from creating a fairy back to the caller.
  RET

FairyFrame:
;  PUSH AF
;    ;CALL Actor_New    ;Null actor (w/visibility)
;    ;Config data
;  POP AF
;  LD HL,_Settings
;  ADD HL,DE
;  LD (HL),A
;  LD B,D
;  LD C,E
;  CALL MemAlloc
;  LD HL,_AnimRAM
;  ADD HL,BC
;  LD (HL),E
;  INC HL
;  LD (HL),D
;  LD D,B
;  LD E,C
;  ;Animation setup
;  ;Animation values
;  LD HL,_AnimChange
;  ADD HL,DE
;  LD (HL),1 ;Face down
;  RST $00
;;Fairy specific messages
;    ;v: Cutscene control
;    ;v: Play animation
;    ;v: Destruct
;  ;Cutscene detect
;  LD HL,_ControlState
;  ADD HL,DE
;  LD A,(HL)
;  INC A
;  JP z,Actor_Delete
;  DEC A
;  AND $7F
;  JR z,+    ;Cutscene control
;;AI behavior here
;+
;  ;Animations
;  LD A,$FF
;  LD HL,_AnimChange
;  ADD HL,DE
;  CP (HL)
;  JR z,+
;  ;Change animation
;  LD C,(HL)
;  LD (HL),A
;  ;Change HatVal
;  LD A,$03
;  AND C
;  ADD <_HatValues
;  LD L,A
;  LD A,<_HatValues
;  ADC 0
;  LD H,A
;  LD A,(HL)
;  LD HL,_HatVal
;  ADD HL,DE
;  LD (HL),A
;  ;Send new anim pointer
;  LD HL,_Settings
;  ADD HL,DE
;  LD A,$3F  ;Omit AI setting
;  AND (HL)
;  LD B,A
;;B=Fairy Type
;    ;%00HHBBWW
;    ;       ++--- Wing type
;    ;     ++----- Body type
;    ;   ++------- Hair type
;  PUSH DE
;    LD HL,_AnimRAM  ;Grab RAM buffer
;    ADD HL,DE
;    LDI A,(HL)
;    LD D,(HL)
;    LD E,A
;    PUSH DE
;      LD A,C
;      RLA
;      ADD <_Animations ;Grab this animation pointer
;      LD L,A
;      LD A,>_Animations
;      ADC 0
;      LD H,A
;      LDI A,(HL)
;      LD H,(HL)
;      LD L,A
;      LD C,29
;-
;      LDI A,(HL)    ;Copy animation to RAM
;      LD (DE),A
;      INC DE
;      DEC C
;      JR nz,-
;    POP HL
;    PUSH HL
;      LD A,$30  ;Get fairy type modifications into DE
;      AND B
;      RLCA
;      RLCA
;      OR B
;      LD E,A
;      LD A,$F0
;      AND E
;      SWAP A
;      LD D,A
;      LD C,(HL) ;Sprite count
;-
;      INC HL        ;Edit tiles to match fairy type
;      INC HL
;      INC HL
;      LD A,$03
;      AND E
;      RR D
;      RR E
;      RR D
;      RR E
;      ADD (HL)
;      LDI (HL),A
;      DEC C
;      JR nz,-
;    POP BC
;  POP DE
;  SCF
;+
;  ;Carry correct b/c CMP against $FF always yields no carry
;  JP Actor_Draw

_Animations:
 .dw FairyLeft
 .dw FairyDown
 .dw FairyRight
 .dw FairyUp

_HatValues:
 .db 2
 .db 18
 .db 34
 .db 50

.ENDS
