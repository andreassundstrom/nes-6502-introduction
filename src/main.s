.export Main
.segment "CODE"

.proc Main
  
  ldx $01
  inx
  stx $01

  cpx #$00
  ; if $01 == 0 goto return
  bne @return

  ldx $02
  inx
  stx $02

  ldx $03
  dex
  stx $03

  @return:
    rts
.endproc