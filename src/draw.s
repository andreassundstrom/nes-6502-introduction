.export DrawMorran
.export DrawScore
.export DrawHeart

morran_pos_x = $02
morran_pos_y = $03
morran_direction = $04

heart_pos_x = $0A
heart_pos_y = $0B

score_value = $10

;morran_sprite = $05 ?



.proc DrawMorran
  ; Morran
  lda morran_pos_y    ; Set Y-pos
  sta $2004   ; Write Y-pos


  lda morran_pos_x ; Display animation depending on if x is even or not
  lsr a
  lsr a
  clc
  lsr a
  bcc set_step_2
  set_step_1:
    lda #$29    ; Set sprite (morran)
    jmp store_step
  set_step_2:
    lda #$2A    ; Set sprite (morran)
    jmp store_step
  store_step:
    sta $2004   ; Store sprite
  
  lda #%00000001        ; Set attributes
  ora morran_direction  ; V-flip

  sta $2004   ; Store attributes
  
  lda morran_pos_x ; Load X from memory $01
  sta $2004         ; Store X
  rts
.endproc

.proc DrawScore
    ldx #$00
    score_loop:
      lda score, x
      sta $2004
      inx
      cpx #$14
      bne score_loop

    
    draw_score_value:
    lda #16 ; y-pos
    sta $2004
    ; Find out sprite, could be done with loop instead
    lda score_value
    cmp #$00
    beq set_core_sprite_0
    cmp #$01
    beq set_core_sprite_1
    cmp #$02
    beq set_core_sprite_2
    cmp #$03
    beq set_core_sprite_3
    cmp #$04
    beq set_core_sprite_4
    cmp #$05
    beq set_core_sprite_5
    cmp #$06
    beq set_core_sprite_6
    cmp #$07
    beq set_core_sprite_7
    cmp #$08
    beq set_core_sprite_8
    cmp #$09
    beq set_core_sprite_9

    set_core_sprite_0: lda #$23
    jmp end_set_score_sprite
    set_core_sprite_1: lda #$1A
    jmp end_set_score_sprite
    set_core_sprite_2: lda #$1B
    jmp end_set_score_sprite
    set_core_sprite_3: lda #$1C
    jmp end_set_score_sprite
    set_core_sprite_4: lda #$1D
    jmp end_set_score_sprite
    set_core_sprite_5: lda #$1E
    jmp end_set_score_sprite
    set_core_sprite_6: lda #$1F
    jmp end_set_score_sprite
    set_core_sprite_7: lda #$20
    jmp end_set_score_sprite
    set_core_sprite_8: lda #$21
    jmp end_set_score_sprite
    set_core_sprite_9: lda #$22
    jmp end_set_score_sprite

    end_set_score_sprite:
    sta $2004 ; sprite
    lda #$00  ; attr
    sta $2004
    lda #248  ; x-pos
    sta $2004

    rts

.endproc

.proc DrawHeart
  lda heart_pos_y
  sta $2004
  lda #$24
  sta $2004
  lda #1
  sta $2004
  lda heart_pos_x
  sta $2004
  rts
.endproc

score:
  .byte 16, $12, $00, 200 ; S
  .byte 16, $02, $00, 208 ; C
  .byte 16, $0E, $00, 216 ; O
  .byte 16, $11, $00, 224 ; R
  .byte 16, $04, $00, 232 ; E