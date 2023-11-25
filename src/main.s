heart_1_pos_x = $02
heart_1_pos_y = $03

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
  handle_x:
    lda JOYPAD_1    ; Read JOYPAD_1 state
    and #%00000011  ; Reset all bits but the left and right

    cmp #%00000001  ; Right button is pressed
    beq move_right
    
    cmp #%00000010  ; Right button is pressed
    beq move_left   ; Left button is pressed

    jmp handle_y    ; no button is pressed

  move_right:
    ldx heart_1_pos_x
    inx 
    stx heart_1_pos_x
    jmp handle_y

  move_left:
    ldx heart_1_pos_x
    dex
    stx heart_1_pos_x
    jmp handle_y

  handle_y:
    lda JOYPAD_1
    and #%00001100

    cmp #%00001000
    beq move_up

    cmp #%00000100
    beq move_down

    jmp return

  move_up:
    ldx heart_1_pos_y
    dex
    stx heart_1_pos_y

    jmp return

  move_down:
    ldx heart_1_pos_y
    inx
    stx heart_1_pos_y

    jmp return

  return:
    rts
.endproc