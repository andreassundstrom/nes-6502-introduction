.export Init
morran_pos_x = $02
morran_pos_y = $03
morran_direction = $04
morran_sprite = $05
score = $10
heart_pos_x = $0A
heart_pos_y = $0B

.proc Init
  
  ; reset score
  lda #0
  sta score

  ; Set position
  lda #20
  sta morran_pos_x
  sta morran_pos_y

  lda #128
  sta heart_pos_x
  lda #64
  sta heart_pos_y

  rts
.endproc