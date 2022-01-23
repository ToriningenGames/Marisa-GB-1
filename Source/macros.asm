
.IFNDEF MACROS
.DEFINE MACROS

.MACRO TaskWaitForZero ARGS address, waitbit, sig
  JR TaskWaitLoopZEntry\@_\3
TaskWaitLoopZ\@_\3:
  RST $00
TaskWaitLoopZEntry\@_\3:
  ;Wait condition goes here
  LD HL,address
  BIT waitbit,(HL)
  JR nz,TaskWaitLoopZ\@_\3
.ENDM

.MACRO TaskWaitForNonzero ARGS address, waitbit, sig
  JR TaskWaitLoopEntry\@_\3
TaskWaitLoop\@_\3:
  RST $00
TaskWaitLoopEntry\@_\3:
  ;Wait condition goes here
  LD HL,address
  BIT waitbit,(HL)
  JR z,TaskWaitLoop\@_\3
.ENDM

.ENDIF
