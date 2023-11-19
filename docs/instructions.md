# Instructions

Complete list with [instructions](https://www.masswerk.at/6502/6502_instruction_set.html).

| Instruction | Name                         | Description |
| ----------- | ---------------------------- | ----------- |
| ADC         | Add with carry               |             |
| LDA         | Load Accumulator with memory |             |
| LDX         | Load X with memory           |             |

## Loading and storing to/from registries

Basic loading of the registries `A`, `X` and `Y` is done with the `LD{A|X|Y}` instruction.

Basic storing of the registries can be done with `ST{A|X|Y}`.

## Incrementing and decrementing registries

`IN{X|Y}` and `DE{X|Y}` can be used to increment or decrement the value in the registries. This is useful for loops.

## Compare memory and registry
