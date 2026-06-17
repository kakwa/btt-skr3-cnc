# BTT SKR 3 Wiring Guide for grblHAL

## Configuration Overview

- **Board:** BTT SKR 3 (STM32H723VG)
- **Firmware:** grblHAL
- **Drivers:** TMC5160 (UART mode)
- **Axes:** X (ganged), Y (ganged), Z
- **Total Motors:** 5 (X, X2 on E0, Y, Y2 on E1, Z)
- **Breakout**: TODO

---

## TMC 5160 Stepper Allocation

* XM -> X1
* YM -> Y1
* ZM -> Z
* E0M -> X2 (ganged)
* E1M -> Y2 (ganged)

## Limit Switches <-> port mapping

| Name                   | GRBLHAL   | Pin  | Board label  |
|------------------------|-----------|------|--------------|
| Z Limit Switch         | GPIOC 0   | PC0  | Z- STOP      |
| Z Probe                | GPIOC 13  | PC13 | Probe        |
| Y Limit Switch         | GPIOC 3   | PC3  | Y- STOP      |
| Y Limit Max Switch     | GPIOX X   | PXX  | TODO         |
| X Limit Switch         | GPIOC 1   | PC1  | X- STOP      |
| X Limit Max Switch     | GPIOX X   | PXX  | TODO         |
| Collision Switch/ESTOP | GPIOA 7   | PA7  | EXP2 pin 5   |

## Breakout

TOP & Bottom, could make due with generic DB25 but custom board

TODO explain wiring, specially of TMC drivers

## Stepper Motors & Drivers

TODO

## Limit Switches

TODO

## E-STOP (Reset/Halt)

TODO

## Safety Bars/Doors

TODO

## Z Probe

TODO

## Spindle

TODO: not handled currently (fixed speed, started manually for now)
