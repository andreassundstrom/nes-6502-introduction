.import Sound
.import ReadController
.import InitApu
.import Main

; Memory addresses
JOYPAD_1 = $4016
heart_1_pos_x = $02
heart_1_pos_y = $03
morran_direction = $04

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
  load_background_loop:
      lda background, x
      sta $2007
      inx
      cpx #$ff
      bne load_background_loop
  
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
    cpx #$7f
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

  lda #$09    ; Set sprite (heart)
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
    cpx #$44 
    bne @loop ; Branch on result not zero, z = 0
    rti

background:
  .byte $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
  .byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
  .byte $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
  .byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0B,$0B,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
  
  .byte $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
  .byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
  .byte $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
  .byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
  
  .byte $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
  .byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
  .byte $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
  .byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
  
  .byte $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
  .byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
  .byte $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
  .byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A



attribute:
  .byte %00000000, %00000100, %00000000, %00000000,%00000000, %00000000, %00000000, %00000000

hello:
  ; y, tecken, ?, x
  .byte $6c, $08, $00, $62 ; Heart
  .byte $6c, $00, $00, $6c ; A
  .byte $6c, $01, $00, $76 ; L
  .byte $6c, $02, $00, $80 ; F
  .byte $6c, $03, $00, $8A ; R
  .byte $6c, $04, $00, $94 ; E
  .byte $6c, $05, $00, $9E ; D
  .byte $6c, $08, $00, $A8 ; Heart

  .byte $76, $08, $00, $62 ; Heart
  .byte $76, $06, $00, $6c ; S
  .byte $76, $04, $00, $76 ; E
  .byte $76, $01, $00, $80 ; L
  .byte $76, $07, $00, $8A ; M
  .byte $76, $00, $00, $94 ; A
  .byte $76, $08, $00, $9E ; Heart


palettes:
  ; Background Palette
  .byte $0f, $09, $19, $2a
  .byte $0f, $05, $15, $25
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00

  ; Sprite Palette
  .byte $0f, $20, $15, $00
  .byte $0f, $04, $20, $14
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

  .byte %01111111 ; S (06)
  .byte %11111111
  .byte %11000000
  .byte %11111110
  .byte %00111111
  .byte %00000011
  .byte %11111111
  .byte %11111110
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11100111 ; M (07)
  .byte %11100111
  .byte %11100111
  .byte %11111111
  .byte %11011011
  .byte %11011011
  .byte %11000011
  .byte %11000011
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  ; Hjärta (08)
  .byte %01100110	;  **  **
  .byte %10011001 ; *  **  *
  .byte %10000001 ; *      *
  .byte %10000001 ; *      *
  .byte %10000001 ; *      *
  .byte %01000010 ;  *    *
  .byte %00100100 ;   *  *
  .byte %00011000 ;    **

  .byte %00000000	;  **  **
  .byte %01100110 ; *  **  *
  .byte %01111110 ; *      *
  .byte %01111110 ; *      *
  .byte %01111110 ; *      *
  .byte %00111100 ;  *    *
  .byte %00011000 ;   *  *
  .byte %00000000 ;    **

  ; Morran (09)
  .byte %00111100 ;
  .byte %01101010 ;
  .byte %11111111 ;
  .byte %11111110 ;
  .byte %11100000 ;
  .byte %11011111 ;
  .byte %11111111 ;
  .byte %11111111 ;

  .byte %00101100 ;
  .byte %01010100 ;
  .byte %10000000 ;
  .byte %00000000 ;
  .byte %00011110 ;
  .byte %00111110 ;
  .byte %00000000 ;
  .byte %00000000 ;

  ; Color 1 ($0A)
  .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  ; Color 2 ($0B)
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

  ; Color 3 ($0C)
  .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
