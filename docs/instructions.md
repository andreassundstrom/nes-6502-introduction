# Instructions

## Status flags

The 6502 has a special register with processor status flags. Instructions will alter these flags and can then be used by succeeding instructions.

| Flag | Name     |
| ---- | -------- |
| C    | Carry    |
| Z    | Zero     |
| N    | Negative |
| V    | Overflow |

- **Carry**:
  - **Bitshift**: (ASL, LSR, ROL, ROR): Containts the bit that was shifted out
- **Zero**: After instructions that have result, will be set if result is zero
- **Negative**: After instructions that have result, set if result is negative

Complete list with [instructions](https://www.masswerk.at/6502/6502_instruction_set.html).

| Instruction | Name                         | Description |
| ----------- | ---------------------------- | ----------- |
| ADC         | Add with carry               |             |
| LDA         | Load Accumulator with memory |             |
| LDX         | Load X with memory           |             |

## Branching

| Instruction | Name                            | Condition |
| ----------- | ------------------------------- | --------- |
| BEQ         | Branch on result zero           | Z = 1     |
| BNE         | Branch on result not zero equal | Z = 0     |
| BPL         | Branch on result plus           | N = 0     |
| BCC         | Branch on cary clear            | C = 0     |
| BCS         | Branch on carry set             | C = 1     |

`BPL`: **B**ranch on **PL**us result (N = 0).

```asm
ldy #$0A
@loop:
  dey       ; set N = 1 if result is negative
  bpl @loop ; branch if N = 1
```

Would be equivalent to the C-code:

```c
int y = 10;

while (y > 0) {
  y -= 1;
}
```

`BCC`: **B**ranch on **C**arry **Clear** (C = 0)

In bitshift operations thils will branch if the shifted bit is 0.

```asm
  lda #%10000000  ; Load value 1000 0000 into a
  lsr a           ; Shift value a right
                  ; A = 0100 0000
                  ; The shifted bit is = 0
  bcc something   ; Will jump since above instruction cleard c
```

`BCS`: **B**ranch on **C**arry **S**et (C = 1)

```asm
  lda #%00000001  ; Load value 0000 0001 into a
  lsr a           ; Shift value a right
                  ; The shifted bit is in C
  bcs             ; Since shifted bit is set, will jump
```

## Loading and storing to/from registries

Basic loading of the registries `A`, `X` and `Y` is done with the `LD{A|X|Y}` instruction.

Basic storing of the registries can be done with `ST{A|X|Y}`.

## Incrementing and decrementing registries

`IN{X|Y}` and `DE{X|Y}` can be used to increment or decrement the value in the registries. This is useful for loops.

## Bitwise compare

| Instruction | Description                  |
| ----------- | ---------------------------- |
| AND         | Bitwise AND with accumilator |
| ORA         | Bitwise OR with accumilator  |

Some examples:

```asm
; Bitwise AND
lda #%11001100  ;1100 1100
and #%11111111  ;1111 1111
                ;1100 1100 stored in a

; Bitwise OR
lda #%11001100  ;1100 1100
ora #%11111100  ;1111 1100
                ;1111 1100 stored in a

```

## Bitshiftoperations

### LSR (memory or accumilator)

Shift one bit right. The shifted bit will be stored
in the `C`arry flag.

```asm
sta #%10000001  ; A contains 1000 0001
lsr a           ; Shift one bit right
                ; A contains 0100 0000
                ; C containts the shifted bit 1
```

### ROL (rotate one bit left)

Shift all bits left. The new bit will be taken from the
`C`arry flag. The shifted bit will be stored in the `C`arry
flag.

```asm
sta #%10101010  ; The value 0101 0101, C contains 1
rol a           ; Shift all numbers left
                ; A should contain 0101 0101
                ; C should be set to 1
```
