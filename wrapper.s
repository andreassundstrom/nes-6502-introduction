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
  lda $2002
  lda #$3f
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
@loop:
  lda palettes, x
  sta $2007
  inx
  cpx #$20
  bne @loop

enable_rendering:
  lda #%10000000	; Enable NMI
  sta $2000
  lda #%00010000	; Enable Sprites
  sta $2001

forever:
  jmp forever

nmi:
  ldx #$00 	; Set SPR-RAM address to 0
  stx $2003
@loop:	
  lda hello, x 	; Load the hello message into SPR-RAM
  sta $2004
  inx
  cpx #$28
  bne @loop
  rti

hello:
  .byte $6c, $06, $00, $62 ; Hjärta
  .byte $6c, $00, $00, $6c
  .byte $6c, $01, $00, $76
  .byte $6c, $02, $00, $80
  .byte $6c, $03, $00, $8A
  .byte $6c, $04, $00, $94
  .byte $6c, $05, $00, $9E
  .byte $6c, $06, $00, $A8 ; Hjärta

palettes:
  ; Background Palette
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00

  ; Sprite Palette
  .byte $0f, $20, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00

; Character memory
.segment "CHARS"
  .byte %01111110	; A (00)
  .byte %11111111
  .byte %11000011
  .byte %11111111
  .byte %11111111
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11000000	; L (01)
  .byte %11000000
  .byte %11000000
  .byte %11000000
  .byte %11000000
  .byte %11000000
  .byte %11111111
  .byte %11111111
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111111	; F (02)
  .byte %11111111
  .byte %11000000
  .byte %11000000
  .byte %11111000
  .byte %11111000
  .byte %11000000
  .byte %11000000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111111	; R (03)
  .byte %11111111
  .byte %11000011
  .byte %11000011
  .byte %11111000
  .byte %11111100
  .byte %11000110
  .byte %11000111
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111111	; E (04)
  .byte %11111111
  .byte %11000000
  .byte %11111100
  .byte %11111100
  .byte %11000000
  .byte %11111111
  .byte %11111111
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %01111110	; D (05)
  .byte %11001111
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11001111
  .byte %11111100
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  ; Hjärta (06)
  .byte %01100110	;  **  **
  .byte %10011001 ; *  **  *
  .byte %10000001 ; *      *
  .byte %10000001 ; *      *
  .byte %10000001 ; *      *
  .byte %01000010 ;  *    *
  .byte %00100100 ;   *  *
  .byte %00011000 ;    **
  .byte $00, $00, $00, $00, $00, $00, $00, $00
