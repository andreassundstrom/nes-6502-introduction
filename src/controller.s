.export ReadController
JOYPAD_1 = $4016
JOYPAD_1_STATE = $20

.proc ReadController

  lda #1
  sta $20
  
  sta $4016
  lda #0
  sta $4016

  read_loop:
    lda $4016
    lsr a
    rol $20
    bcc read_loop
  rts
.endproc