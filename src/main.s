heart_1_pos_x = $02
heart_2_pos_x = $03

.import Sound
.export Main
.segment "CODE"

.proc Main
  
  ldx $01
  inx
  stx $01

  cpx #$00
  ; if $01 == 0 goto return
  bne @return


  ldx heart_1_pos_x
  inx
  stx heart_1_pos_x

  ldx heart_2_pos_x
  dex
  stx heart_2_pos_x


  @return:
    rts
.endproc