sound_1_addr = $0A

.export Sound
.export InitApu

.segment "CODE"

.proc InitApu
  ; Init sound 1
  lda #%01111001
  sta sound_1_addr

  ; Init $4000-4013
  ldy #$13
  @loop:  
    lda @regs,y
    sta $4000,y
    dey
    bpl @loop

    ; We have to skip over $4014 (OAMDMA)
    lda #$0f
    sta $4015
    lda #$40
    sta $4017

    rts

  @regs:
    .byte $30,$08,$00,$00
    .byte $30,$08,$00,$00
    .byte $80,$00,$00,$00
    .byte $30,$00,$00,$00
    .byte $00,$00,$00,$00 

.endproc

.proc Sound
  ;DDLC VVVV
  ;Duty = 1
  ;Length = 1 (Infinite play)
  ;Constant volume = 1
  ;Volume = 9
  lda sound_1_addr
  sta $4002

  lda #%00000010  ;$200
  sta $4003

  lda #%10111111
  sta $4000
  rts
.endproc