;Alice character file

.SECTION "Alice" FREE

AliceFrame:
  CALL MsgClear     ;Null actor
  CALL Actor_New
  CALL HaltTask
  CALL Actor_Message
  RET

.ENDS
