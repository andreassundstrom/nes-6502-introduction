.export Main
.segment "CODE"

.proc Main
  ; Load 5 into x and y registers
  ldx #5;
  ldy #5;

  ; Increment X twice
  inx
  inx

  ; Decrement x once
  dex

  ; Decrement Y twice
  dey
  dey

  ; Increment Y once
  iny

  ; return
  rts
.endproc