;Camera code
;Maintains the game camera on Marisa, while keeping only the map in view.

.SECTION "Camera" FREE

;Keep the camera within map boundaries,
;and centered on Marisa otherwise.

;Get Marisa
  LD A,(Cutscene_Actors+1)
  CALL Access_ActorDE
;Set X
  INC HL
  INC HL
.ENDS
