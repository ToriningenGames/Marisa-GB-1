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

FairyFrame:
  PUSH AF
    CALL Actor_New    ;Null actor (w/visibility)
    ;Config data
  POP AF
  LD HL,_Settings
  ADD HL,DE
  LD (HL),A
  LD B,D
  LD C,E
  CALL MemAlloc
  LD HL,_AnimRAM
  ADD HL,BC
  LD (HL),E
  INC HL
  LD (HL),D
  LD D,B
  LD E,C
  ;Hitbox setup
  LD HL,_Hitbox
  ADD HL,DE
  LD (HL),<DefaultHitboxes
  INC HL
  LD (HL),>DefaultHitboxes
  ;Animation setup
  ;Animation values
  LD HL,_AnimChange
  ADD HL,DE
  LD (HL),1 ;Face down
  CALL HaltTask
  LD HL,_LandingPad
  ADD HL,DE
  ;Check for doing AI stuffs here
;Fairy specific messages
    ;x: Cutscene control
    ;v: Play animation
    ;x: Destruct
  LD A,$FF
  LD HL,_AnimChange
  ADD HL,DE
  CP (HL)
  JR z,+
  ;Change animation
  LD C,(HL)
  LD (HL),A
  ;Change HatVal
  LD A,$03
  AND C
  ADD <_HatValues
  LD L,A
  LD A,<_HatValues
  ADC 0
  LD H,A
  LD A,(HL)
  LD HL,_HatVal
  ADD HL,DE
  LD (HL),A
  ;Send new anim pointer
  LD HL,_Settings
  ADD HL,DE
  LD A,$3F  ;Omit AI setting
  AND (HL)
  LD B,A
;B=Fairy Type
    ;%00HHBBWW
    ;       ++--- Wing type
    ;     ++----- Body type
    ;   ++------- Hair type
  PUSH DE
    LD HL,_AnimRAM  ;Grab RAM buffer
    ADD HL,DE
    LDI A,(HL)
    LD D,(HL)
    LD E,A
    PUSH DE
      LD A,C
      RLA
      ADD <_Animations ;Grab this animation pointer
      LD L,A
      LD A,>_Animations
      ADC 0
      LD H,A
      LDI A,(HL)
      LD H,(HL)
      LD L,A
      LD C,29
-
      LDI A,(HL)    ;Copy animation to RAM
      LD (DE),A
      INC DE
      DEC C
      JR nz,-
    POP HL
    PUSH HL
      LD A,$30  ;Get fairy type modifications into DE
      AND B
      RLCA
      RLCA
      OR B
      LD E,A
      LD A,$F0
      AND E
      SWAP A
      LD D,A
      LD C,(HL) ;Sprite count
-
      INC HL        ;Edit tiles to match fairy type
      INC HL
      INC HL
      LD A,$03
      AND E
      RR D
      RR E
      RR D
      RR E
      ADD (HL)
      LDI (HL),A
      DEC C
      JR nz,-
    POP BC
  POP DE
  SCF
+
  ;Carry correct b/c CMP against $FF
  JP Actor_Draw

_DownFace:
 .db 6
 .db -8, -4,$50,%00000000  ;Head
 .db  0, -4,$53,%00000000  ;Body
 .db -8,-12,$5C,%00000000  ;Upper left wing
 .db -8,  4,$5C,%00100000  ;Upper right wing
 .db  0,-12,$59,%00000000  ;Lower left wing
 .db  0,  4,$59,%00100000  ;Lower right wing
_IdleLoop:
 .db $F1
 .db $FF
 .dw _IdleLoop

_UpFace:
 .db 6
 .db -8, -4,$5F,%00000000  ;Head
 .db  0, -4,$56,%00000000  ;Body
 .db -8,-12,$5C,%00000000  ;Upper left wing
 .db -8,  4,$5C,%00100000  ;Upper right wing
 .db  0,-12,$59,%00000000  ;Lower left wing
 .db  0,  4,$59,%00100000  ;Lower right wing
 .db $F1
 .db $FF
 .dw _IdleLoop

_LeftFace:
 .db 4
 .db -8, -4,$4A,%00000000  ;Head
 .db  0, -4,$4D,%00000000  ;Body
 .db -8,  4,$5C,%00100000  ;Upper wing
 .db  0,  4,$59,%00100000  ;Lower wing
 .db $F1
 .db $FF
 .dw _IdleLoop

_RightFace:
 .db 4
 .db -8, -4,$4A,%00100000  ;Head
 .db  0, -4,$4D,%00100000  ;Body
 .db -8,-12,$5C,%00000000  ;Upper wing
 .db  0,-12,$59,%00000000  ;Lower wing
 .db $F1
 .db $FF
 .dw _IdleLoop

_DownWalk:
 .db 6
 .db -8, -4,$50,%00000000  ;Head
 .db  0, -4,$53,%00000000  ;Body
 .db -8,-12,$5C,%00000000  ;Upper left wing
 .db -8,  4,$5C,%00100000  ;Upper right wing
 .db  0,-12,$59,%00000000  ;Lower left wing
 .db  0,  4,$59,%00100000  ;Lower right wing
 .db $11
 .db $FF
 .dw _VertWalkLoop

_UpWalk:
 .db 6
 .db -8, -4,$5F,%00000000  ;Head
 .db  0, -4,$56,%00000000  ;Body
 .db -8,-12,$5C,%00000000  ;Upper left wing
 .db -8,  4,$5C,%00100000  ;Upper right wing
 .db  0,-12,$59,%00000000  ;Lower left wing
 .db  0,  4,$59,%00100000  ;Lower right wing
 .db $11
 .db $FF
 .dw _VertWalkLoop

_VertWalkLoop:
 .db $37
  Animate 3,AnimX, 1    ;Wing upper left    move right
  Animate 4,AnimX,-1    ;Wing upper right   move left
  Animate 5,AnimX, 1    ;Wing lower left    move right
  Animate 6,AnimX,-1    ;Wing lower right   move left
  Animate 0,AnimY,-1    ;Everything         move up
  Animate 3,AnimY, 1    ;Wing upper left    stay put
  Animate 4,AnimY, 1    ;Wing upper right   stay put
 .db $44
  Animate 3,AnimX,-1    ;Wing upper left    move left
  Animate 4,AnimX, 1    ;Wing upper right   move right
  Animate 5,AnimX,-1    ;Wing lower left    move left
  Animate 6,AnimX, 1    ;Wing lower right   move right
 .db $43
  Animate 0,AnimY, 1    ;Everything         move down
  Animate 5,AnimY,-1    ;Wing lower left    stay put
  Animate 6,AnimY,-1    ;Wing lower right   stay put
 .db $34
  Animate 3,AnimY,-1    ;Wing upper left    move up
  Animate 4,AnimY,-1    ;Wing upper right   move up
  Animate 5,AnimY, 1    ;Wing lower left    move down
  Animate 6,AnimY, 1    ;Wing lower right   move down
 .db $11
 .db $FF
 .dw _VertWalkLoop

_LeftWalk:
 .db 4
 .db -8, -4,$4A,%00000000  ;Head
 .db  0, -4,$4D,%00000000  ;Body
 .db  0,  4,$59,%00100000  ;Lower wing
 .db -8,  4,$5C,%00100000  ;Upper wing
 .db $11
 .db $FF
 .dw _HortWalkLoop

_RightWalk:
 .db 4
 .db -8, -4,$4A,%00100000  ;Head
 .db  0, -4,$4D,%00100000  ;Body
 .db  0,-11,$59,%00000000  ;Lower wing
 .db -8,-11,$5C,%00000000  ;Upper wing
 .db $11
 .db $FF
 .dw _HortWalkLoop

_HortWalkLoop
 .db $21
 Animate 3,AnimY,-1     ;Lower wing up
 .db $34
 Animate 1,AnimY,-1     ;Head up
 Animate 2,AnimY,-1     ;Body up
 Animate 3,AnimX,-1     ;Lower wing left
 Animate 4,AnimX,-1     ;Upper wing left
 .db $42
 Animate 3,AnimX, 1     ;Lower wing right
 Animate 4,AnimX, 1     ;Upper wing right
 .db $42
 Animate 0,AnimY, 1     ;All down
 Animate 4,AnimY,-1     ;Except Upper wing
 .db $11
 .db $FF
 .dw _HortWalkLoop

_Animations:
 .dw _LeftFace
 .dw _DownFace
 .dw _RightFace
 .dw _UpFace
 .dw _LeftWalk
 .dw _DownWalk
 .dw _RightWalk
 .dw _UpWalk

_HatValues:
 .db 2
 .db 18
 .db 34
 .db 50

.ENDS
