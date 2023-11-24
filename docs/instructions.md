# Instructions

## Status flags

The 6502 has a special register with processor status flags. Instructions will alter these flags and can then be used by succeeding instructions.

| Flag | Name     |
| ---- | -------- |
| C    | Carry    |
| Z    | Zero     |
| N    | Negative |
| V    | Overflow |

- **Negative**: After instructions that have result, set if result is negative
- **Zero**: After instructions that have result, will be set if result is zero

Complete list with [instructions](https://www.masswerk.at/6502/6502_instruction_set.html).

| Instruction | Name                         | Description |
| ----------- | ---------------------------- | ----------- |
| ADC         | Add with carry               |             |
| LDA         | Load Accumulator with memory |             |
| LDX         | Load X with memory           |             |

## Branching

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

## Loading and storing to/from registries

Basic loading of the registries `A`, `X` and `Y` is done with the `LD{A|X|Y}` instruction.

Basic storing of the registries can be done with `ST{A|X|Y}`.

## Incrementing and decrementing registries

`IN{X|Y}` and `DE{X|Y}` can be used to increment or decrement the value in the registries. This is useful for loops.

## Compare memory and registry
