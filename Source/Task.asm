;There are two types of tasks:
    ;Those that want to run as much as they can
    ;Those that want to run once per frame
;Preempting or cooperative?
    ;Cooperative
;Firstly:
    ;For those that want to run once per frame,
    ;what should we do if they lag?
      ;- Skip frames?
      ;- Play catchup?
    ;Catchup. Frame counter indicates how much we need to catch up by.
    ;What if we can't catchup?
        ;Intuitively, once we can, we will at top speed until the frame counter
            ;runs out. About 4 seconds of zoom at max.
;How are we gonna keep track of frames?
    ;Frame counter. We shall own it.
;Complicates real-world use. Better off skipping frames
;Easier, because we just have to run every task, then HALT
;Faster, because there's no frame checking code
;Simpler, because tasks now just run every frame
;Safer, because lag does not affect the game after it goes away
;Powerier, becuase HALT turns off the CPU, instead of infinite loop
;Doier, because tasks that wanted to HALT and continue can now be supported

;Flow:
    ;List of task entry points
    ;For each element in the list:
        ;If element is not marked as frame
        ;Or frame counter is not 0
            ;Call it
    ;Decrement frame counter
;Task element:
    ;Occupied flag (0 if true)
    ;A
    ;BC
    ;DE
    ;Pointer to entry

.SECTION "Multitask" FREE
.define taskpointer  $CD00
.define taskptrsize  $CE00
.define framecounter $CFAB
.struct taskdata
    occupied    db
    reg_a       db
    reg_bc      dw
    reg_de      dw
    entry       dw
.endst

.include "macros.asm"

.EXPORT taskpointer

RunAsTask:
;DE -> function to run as task
  PUSH DE
  RET
  JR EndTask

EndTask:    ;JUMP here as a simple self-terminate
;Requires empty stack
  POP HL    ;return
  POP BC    ;task data
  PUSH BC
  DEC BC
  LD A,$FF  ;Set flag to unoccupied
  LD (BC),A
  JP HL     ;RET
HaltTask:   ;Relinquish time to other tasks, but pick up where you leave off
;Although it is a "halt", it must be called with an empty stack because its
    ;behavior is that of a return.
;We need to save the registers!
  PUSH AF
;Stack:
;AF
;Return address
;TaskLoop
;Task Register area pointer + 1
;Go past return address
  LD HL,SP+$06
;Get task info off stack
  LDI A,(HL)    ;Register area pointer + 1
  LD H,(HL)
  LD L,A
  POP AF
  LDI (HL),A
  LD (HL),C
  INC HL
  LD (HL),B
  INC HL
  LD (HL),E
  INC HL
  LD (HL),D
  INC HL
;Update task start address with this function's return address
  POP BC    ;Return
  LD (HL),C
  INC HL
  LD (HL),B
;End task
  RET

GetTaskID:
;Gets the calling task's ID (for use in messages)
;Returns ID in A
;HL destroyed
;We cheat by looking for an address in the $CD00 range on the stack
  LD HL,SP+6    ;If calling task has no stack items, this is the lowest it could be
--
  INC HL    ;Hi byte
  LDI A,(HL)
  CP >taskpointer
  JR nz,--
  DEC HL
  DEC HL    ;Lo byte of Task Data
;Sneak it from the task data pointer
  LD A,(HL)
  RRCA
  RRCA
  RRCA
  AND $1F
  RET

WaitOnTask:
;Waits for the specified task to finish, then returns
;A = Target Task ID
;Destroys DE
;Destroys HL
;Stack must be empty
  POP DE    ;Return Address
  RLA
  RLA
  RLA
-
  CALL HaltTask
  LD H,>taskpointer     ;This is much slower than using BC,
  LD L,A                ;but we want the caller to be able to save SOME data
  LD A,(HL)
  INC A
  LD A,L
  JR nz,-
  LD H,D
  LD L,E
  JP HL     ;RET

NewTask:
;Find first free task slot
;Fill it
;A = Value of A on Task Start
;BC = Start
;DE = Data
;Carry set if all tasks in use
;Returns Child Task ID in B
;Returns Parent Task ID in C
;Tasks start with value of BC as above
  PUSH AF
  LD HL,taskpointer
-
  BIT 7,(HL)    ;Is task slot open?
  JR z,+
  ;Open!
OpenTask:   ;Hack used by sprite priority task
  XOR A
  LDI (HL),A
  POP AF
  LDI (HL),A
;Get parent Task ID
  PUSH HL
  CALL GetTaskID
  POP HL
  LDI (HL),A    ;C now contains Task ID of task's parent
  LD A,L
  RRCA
  RRCA
  RRCA
  AND $1F
  LDI (HL),A    ;B now contains Task ID of newly created task
  PUSH AF   ;Save for parent
  LD (HL),E
  INC HL
  LD (HL),D
  INC HL
  LD (HL),C
  INC HL
  LD (HL),B
  POP BC    ;Task ID of newly created task
  OR A  ;Clear carry flag
  RET
+   ;Task slot used
  LD A,_sizeof_taskdata
  ADD L
  LD L,A
  LD A,$00
  ADC H
  LD H,A
;At end?
  CP >taskptrsize
  JR nz,-
;No open tasks
  POP AF
  SCF   ;Carry on error
  RET

DoTaskLoop:
--
  HALT
  LD HL,taskpointer
-
  LDI A,(HL)
  OR A
  JR nz,+
  PUSH HL   ;We need this
  LDI A,(HL)    ;Saved A
  PUSH AF
  LD C,(HL) ;Saved BC
  INC HL
  LD B,(HL)
  INC HL
  LD E,(HL) ;Saved DE
  INC HL
  LD D,(HL)
  INC HL
  LDI A,(HL)    ;Task pointer
  LD H,(HL)
  LD L,A
  POP AF    ;Saved A
  RST $30   ;CALL HL
  POP HL
+   ;Not this task
  LD A,_sizeof_taskdata -1
  ADD L
  LD L,A
;At end?
  JR nc,-
  JR --
.ENDS

.SECTION "Messages" FREE
;Also, we need messages. Doable with IDs and a message queue
;Two functions, GetMsg and SendMsg
;Also, NewTask needs to return an ID
;To implement, we need some sort of queue
    ;What is a message?
        ;Who it's from
        ;Who it's to
        ;Some amount of information
;Where should this queue be?
    ;Its size determines maximum message count
    ;Destination can be encoded in address
        ;This also solves cases of fragmentation and multiple messages
;With this, messages are 2 - 4 bytes
;We have 32 task spots, and intend for 256 bytes memory
    ;This results in 2 - 4 messages per task
;These messages should be cleared out when starting a new task.
    ;IDs should also be provided to parent (caller) and child (callee)
        ;BC is a prime candidate, since its value is bogus currently
;Message memory format:
    ;$00: Target ID
    ;$01: Sender ID
    ;$02: Data (2 bytes)

.DEFINE MsgMem $C300

MsgClear:
  CALL GetTaskID
MsgClearOtherTask:      ;Don't use, stupid.
;A = Task ID
;Destroys A, B, HL
  LD H,>MsgMem
  RLA
  RLA
  RLA
  LD L,A
  LD A,$FF
  LD B,8
-
  LDI (HL),A
  DEC B
  JR nz,-
  RET
MsgSend:
;A = Target ID
;BC = Data
;HL Destroyed
;DE Destroyed
;Returns carry set if queue full
  LD D,>MsgMem
  PUSH AF
    RLA
    RLA
    RLA
    LD E,A
    LD A,(DE)
    INC A
    JR z,+
  ;First slot used; try again
    INC E
    INC E
    INC E
    INC E
    LD A,(DE)
    INC A
  POP AF
  SCF
  RET nz    ;If both used, return in error
+   ;Available slot in DE
  POP AF
  LD (DE),A
  INC E
  CALL GetTaskID
  LD H,D
  LD L,E
  LDI (HL),A
  LD A,C
  LDI (HL),A
  LD (HL),B
  RET   ;Carry clear because last affecting instruction is AND in GetTaskID

MsgGet:
;If there is a message in the queue, retrieve it
;Returns data in HL
;Returns sender ID in A
;Destroys B on message
;Carry set if no messages in queue
  CALL GetTaskID
  LD H,>MsgMem
  RLA
  RLA
  RLA
  LD L,A
  LD A,(HL)
  INC A
  SCF
  JR nz,+
  INC L
  INC L
  INC L
  INC L
  LD A,(HL)
  INC A
  RET z
+   ;Message found
  CCF
  LD (HL),$FF   ;Message received
  INC L
  LDI A,(HL)    ;Sender ID
  LD B,A
  LDI A,(HL)    ;Data lo
  LD H,(HL)     ;Data hi
  LD L,A
  LD A,B
  RET
.ENDS
