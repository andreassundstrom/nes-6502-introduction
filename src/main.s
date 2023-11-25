heart_1_pos_x = $02
heart_2_pos_x = $03

JOYPAD_1 = $20

.export Main
.segment "CODE"

.proc Main
  
  ldx $01
  inx
  stx $01

  cpx #$00
  ; if $01 == 0 goto return
  bne @return

  lda JOYPAD_1  ; Read JOYPAD_1 state
  rol a         ; Rotate a left, placing first bit in C

  bcc @return   ; If c is clear jump to return

  ldx heart_1_pos_x
  inx
  stx heart_1_pos_x

  ldx heart_2_pos_x
  dex
  stx heart_2_pos_x


  @return:
    rts
.endproc