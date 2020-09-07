;Reimu character file

.SECTION "Reimu" FREE

ReimuFrame:
  CALL MsgClear     ;Null actor
  CALL Actor_New
  CALL HaltTask
  CALL Actor_Message
  RET

.ENDS
