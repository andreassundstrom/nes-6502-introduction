# Memory addresses

A list of memory addresses
|Address|Description||
|-|-|-|
|$2003|Specify OAM-address||
|$2004|Write OAM-data||
|$2006|Specify PPU-address|High and low byte|
|$2007|PPU-data|One byte|

## Audio Processing Unit (APU)

### Pulse ($4000 - $4007)

| Address | Bits      | Description                                             |
| ------- | --------- | ------------------------------------------------------- |
| $4000   | DDLC VVVV | **D**uty, **L**oop, **C**onstant volume, **V**olume     |
| $4001   | EPPP NSSS | Sweep: **E**nabled, **P**eriod, **N**egative, **S**hift |
| $4002   | TTTT TTTT | Timer low                                               |
| $4003   | LLLL LTTT | **L**ength counter load, **T**imer high                 |
