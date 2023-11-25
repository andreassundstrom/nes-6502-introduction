# Controller

The controller buttons are represented by a byte where each bit corresponds to a button on the controller.

| Bit | Button |
| --- | ------ |
| 0   | A      |
| 1   | B      |
| 2   | Select |
| 3   | Start  |
| 4   | 🡱      |
| 5   | 🡳      |
| 6   | 🡰      |
| 7   | 🡲      |

Reading/writing to the controller is done via the memory addresses $4016 (joypad 1) and $4017 (joypad 2).

## Reading from the controller

The controller state can be read one bit at a time. To instruct the controller to take a snapshot of the current button state begin by writing a 1 to the registry. Then send a 0 to the registry to instruct the controller to stop storing the state.

```asm
lda #1
sta $4016

lda #0
sta $4016
```

After this the controller state can be read one bit at a time. If the A and B button is pressed the state in the controller will be `1100 0000`.

```asm
lda $4016 ;Read state
```

The first bit will be placed in the `a` registry so that `a = 0000 0001`. The bit can be shifted right to the `c`-flag. After this a memory address can be used
and shift the carry flag in via rotate left instruction, this will shift all bits left and shift in the carry flag.

```asm
lsr a   ;Shift a right, the rightmost bit will drop in the c-flag
rol $20 ;Shift the carry flag into $20 and shift the current bits to the left
```

Controller state = `1100 0000`

| Instruction | $20       | a         | c   | Comment                |
| ----------- | --------- | --------- | --- | ---------------------- |
| `lda $4016` |           | 0000 0001 | 0   | Load first bit into a  |
| `lsr a`     |           | 0000 0000 | 1   | Shift bit to c         |
| `rol $20`   | 0000 0001 |           | 0   | Rotate $20 and get c   |
| `lda $4016` |           | 0000 0001 |     | Load second bit into a |
| `lsr a`     |           | 0000 0000 | 1   | Shift it to c          |
| `rol $20`   | 0000 0011 |           | 0   | Rotate $20 and get c   |

Doing this 8 times will read all the buttons.

The instructions can also be done via a loop. This loads a 1 into the first bit of memory address and jumps as long as the carry flag is not set to 1.

```asm
JOYPAD_1 = $4016
JOYPAD_1_STATE = $20

.proc ReadController

  lda #1
  sta JOYPAD_1_STATE

  sta JOYPAD_1
  lda #0
  sta JOYPAD_1_STATE

  read_loop:
    lda JOYPAD_1_STATE
    lsr a
    rol JOYPAD_1_STATE
    bcc read_loop      ; branch on carry clear

.endproc
```
