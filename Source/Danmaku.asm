;Danmaku behavior

;Animation
;There are 3 kinds of danmaku animation:
    ;Undirected
    ;Directed
    ;Spinning
;Undirected is a static sprite
;Directed is a sprite whose value, X flip, and Y flip are dependent on its direction
;Spinning is a sprite whose value, X flip, and Y flip change from frame to frame
;Each animation function takes a pointer to object data

Danmaku_AnimUndirected:
  RET   ;No action needed
Danmaku_AnimDirected:
Danmaku_AnimSpinning:
  

;Pattern