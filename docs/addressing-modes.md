# Address modes

## Immediate addressing

Use a hash symbol (#) to the right of the instruction. This denotes the immediate value.

```
; Load the decimal value 10 into ldx
ldx #10
```

[!NOTE]
Immediate mode can only be used to load a single byte

## Implied addressing

```
inx
```

`inx` increases registry `x` with one and thus doesn't need a memory address, it is `implied`.

## Zero page addressing

Accessing the first 256 bytes of memory is called zero page addressing. The instruction requires one less byte to specify and are executed in one less CPU-cycle (as oposed to absolute addressing).

```
; store value in x at memory address 1F
stx $1F
```

## Absolute addressing

When addressing memory outside of the first 256 bytes absolute addressing is required. This specifices the whole address using two bytes

```
stx $030F
```

## Indexed memory operation

```
STA $1000,X
```

Store valu in the acumilator at address `$1000` but with an ofset of the value stored at `X`.
