morran_pos_x = $02
morran_pos_y = $03
morran_direction = $04
morran_sprite = $05

heart_pos_x = $0A
heart_pos_y = $0b

score_value = $10

JOYPAD_1 = $20
collision = $0C
collision_temp = $0D

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
    lda #%00000000
    sta morran_direction

    ldx morran_pos_x
    inx 
    stx morran_pos_x
    jmp handle_y

  move_left:
    lda #%01000000
    sta morran_direction

    ldx morran_pos_x
    dex
    stx morran_pos_x
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
    ldx morran_pos_y
    dex
    stx morran_pos_y

    jmp return

  move_down:
    ldx morran_pos_y
    inx
    stx morran_pos_y

    jmp return

  return:
    jsr check_collision
    rts
.endproc

.proc check_collision
  lda #0
  sta collision_temp

  heart_is_lower:
    lda morran_pos_x
    adc #$08
    cmp heart_pos_x
    bcc heart_add_eight_is_lower
    lda #%00001000
    sta collision_temp

  heart_add_eight_is_lower:
    lda morran_pos_x
    sbc #$08
    cmp heart_pos_x
    bcs heart_y_is_higher
    lda collision_temp
    ora #%00000100
    sta collision_temp
  
  heart_y_is_higher:
    lda morran_pos_y
    adc #$08
    cmp heart_pos_y
    bcc heart_y_add_eight_is_lower
    lda collision_temp
    ora #%00000010
    sta collision_temp
  
  heart_y_add_eight_is_lower:
    lda morran_pos_y
    sbc #$08
    cmp heart_pos_y
    bcs store_value
    lda collision_temp
    ora #%00000001
    sta collision_temp
  
  store_value:
    lda collision_temp
    cmp #$0f
    beq handle_collision
    rts
  
  handle_collision:
    lda heart_pos_y
    adc #64
    sta heart_pos_y

    lda heart_pos_x
    adc #80
    sta heart_pos_x

    lda score_value
    adc #1
    sta score_value

    rts
.endproc