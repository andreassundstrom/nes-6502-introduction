# Graphics

## Color palette

The NES can hold 4 background palettes and 4 sprite palettes, each with 4 colors. The 4 colors in the palette are picked from the NES available colors $00 - $3f. The first color in the palette is always transparent, so a palette can in reality only display 3 colors.

![palette](resources/palette.png)

## Writing data to the PPU

The memory of the PPU, `VRAM`, can be accessed via special mapped memory locations. First write the inteded PPU-address to `$2006` (two bytes) then write the actual data to `$2007` (one byte at a time).

```asm
lda #$3F  ; Hight byte
sta $2006 ; Send to PPU
lda #$00  ; Low byte
sta $2006 ; Send to PPU

; Ready to begin writing data
lda #$00    ; Value
sta #$2007  ; Send to PPU write-channel
```

## PPU internal addresses

## Sprites

The sprites are defined ...

By writing to the memory location `$2003`

| Byte | Sets       |
| ---- | ---------- |
| 1    | Y-position |
| 2    | Tile       |
| 3    | Attributes |
| 4    | X-position |

For the attribute byte each bit has special meaning:
|Bit|Meaning|
|-|-|
|0|Vertical flip|
|1|Horizontal flip|
|2|Background priority|
|3|-|
|4|-|
|5|-|
|6 - 7|Palette|
