.import Sound
.import ReadController
.import InitApu
.import Main

; Memory addresses
JOYPAD_1 = $4016
heart_1_pos_x = $02
heart_1_pos_y = $03
morran_direction = $04
morran_sprite = $05


.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4E, $45, $53, $1A
  .byte 2               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $01, $00        ; mapper 0, vertical mirroring

.segment "VECTORS"
  ;; When an NMI happens (once per frame if enabled) the label nmi:
  .addr nmi
  ;; When the processor first turns on or is reset, it will jump to the label reset:
  .addr reset
  ;; External interrupt IRQ (unused)
  .addr 0

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

; Main code segment for the program
.segment "CODE"

reset:
  sei		; disable IRQs
  cld		; disable decimal mode
  ldx #$40
  stx $4017	; disable APU frame IRQ
  ldx #$ff 	; Set up stack
  txs		;  .
  inx		; now X = 0
  stx $2000	; disable NMI
  stx $2001 	; disable rendering
  stx $4010 	; disable DMC IRQs


  ; some stuff
  ldx #1;
  stx $00;

;; first wait for vblank to make sure PPU is ready
vblankwait1:
  bit $2002
  bpl vblankwait1

clear_memory:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0200, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  inx
  bne clear_memory

;; second wait for vblank, PPU is ready after this
vblankwait2:
  bit $2002
  bpl vblankwait2

main:
load_palettes:
  lda $2002 ; Load A with value at $2002
  lda #$3f  ; Load A with value $3f
  sta $2006 ; Store the value at a in $2006
  lda #$00  ; Load A with value 0
  sta $2006 ; Store A in $2006
  ldx #$00  ; Reset x, begin loop
@loop:
  lda palettes, x
  sta $2007
  inx
  cpx #$20
  bne @loop

  ; Load background
load_background:

  lda $2002 ; reset PPU latch
  lda #$20  ; Write address $20 00 in ppu
  sta $2006
  lda #$00
  sta $2006

  ldx #$00
  load_background_loop_1:
      lda background_1, x
      sta $2007
      inx
      cpx #$ff
      bne load_background_loop_1
  
  load_background_loop_2:
      lda background_2, x
      sta $2007
      inx
      cpx #$ff
      bne load_background_loop_2
  load_background_loop_3:
      lda background_3, x
      sta $2007
      inx
      cpx #$ff
      bne load_background_loop_3

  load_background_loop_4:
      lda background_4, x
      sta $2007
      inx
      cpx #$ff
      bne load_background_loop_4
  
load_attribute:
  lda $2002
  lda #$23
  sta $2006
  lda #$C0
  sta $2006
  ldx #$00
  load_attribute_loop:
    lda attribute, x
    sta $2007
    inx
    cpx #$40
    bne load_attribute_loop

enable_rendering:
  lda #%10000000	; Enable NMI
  sta $2000
  lda #%00010000	; Enable Sprites
  sta $2001
  
  lda #%00011110 ; enable sprites, enable background
  sta $2001

  ; Disable scrolling at end of nmi
  ; See https://taywee.github.io/NerdyNights/nerdynights/backgrounds.html
  lda #$00
  sta $2005
  sta $2005

  jsr InitApu
  ;jsr Sound
  
forever:
  jsr Main
  jsr ReadController

  jmp forever


nmi:


  ldx #$00 	; Set SPR-RAM address to 0
  stx $2003

  ; Moving heart
  lda heart_1_pos_y    ; Set Y-pos
  sta $2004   ; Write Y-pos


  lda heart_1_pos_x ; Display animation depending on if x is even or not
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
  
  lda heart_1_pos_x ; Load X from memory $01
  sta $2004         ; Store X
  
  @loop:	
    lda hello, x 	; Load the text message into SPR-RAM
    sta $2004
    inx
    ; Compare value in x to 44, store results
    ; in negative, zero and carry status registries
    cpx #$3c
    bne @loop ; Branch on result not zero, z = 0
    rti

background_1:
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$26,$26,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
  
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
background_2:
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
  
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
background_3:
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
  
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

background_4:
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
  
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25


attribute:
  .byte $55,$55,$55,$55,$55,$55,$55,$55
  .byte $00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00
  .byte $55,$55,$55,$55,$55,$55,$55,$55

hello:
  ; y, tecken, attr, x
  .byte $6c, $24, $01, $62 ; Heart    00 - 03
  .byte $6c, $00, $00, $6c ; A        04 - 07
  .byte $6c, $0B, $00, $76 ; L        08 - 0b
  .byte $6c, $05, $00, $80 ; F        0c - 0f
  .byte $6c, $11, $00, $8A ; R        10
  .byte $6c, $04, $00, $94 ; E        14
  .byte $6c, $03, $00, $9E ; D        18
  .byte $6c, $24, $01, $A8 ; Heart    1c

  .byte $76, $24, $01, $62 ; Heart    20
  .byte $76, $12, $00, $6c ; S        24
  .byte $76, $04, $00, $76 ; E        28
  .byte $76, $0B, $00, $80 ; L        2c
  .byte $76, $0C, $00, $8A ; M        30
  .byte $76, $00, $00, $94 ; A        34
  .byte $76, $24, $01, $9E ; Heart    38 - 3B


palettes:
  .incbin "src/graphics/palette.dat"

.segment "CHARS"
  .incbin "src/graphics/sprites.chr"