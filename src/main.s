heart_1_x_speed = $04
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
  bne return

  ; Read
  handle_right:
    lda JOYPAD_1            ; Read JOYPAD_1 state
    lsr a                   ; Rotate a right, placing first bit in C

    bcc set_0
    bcs set_1

    set_1:
      lda #1
      jmp store
    set_0:
      lda #0
      jmp store
    store:
      sta heart_1_x_speed

  increase_position:
    lda heart_1_pos_x
    adc heart_1_x_speed
    sta heart_1_pos_x

  return:
    rts
.endproc