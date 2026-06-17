# BTT SKR 3 Wiring Guide for grblHAL

## Hardware Overview

- **Board:** [BTT SKR 3 EZ](https://github.com/bigtreetech/SKR-3) (STM32H723VG)
- **Drivers:** [TMC5160T Plus](https://global.bttwiki.com/TMC5160TPlus.html) and/or [TMC5160T Pro](https://global.bttwiki.com/TMC5160T%20Pro%20V1.0.html)
- **Axes:** X (ganged), Y (ganged), Z
- **Total Motors:** 5 (X, X2 on E0, Y, Y2 on E1, Z)

---

## Stepper Controller Allocation

* X          -> X1
* Y          -> Y1
* Z          -> Z
* Extruder 0 -> X2 (ganged)
* Extruder 1 -> Y2 (ganged)

## Limit Switches <-> port mapping

| Name                   | GRBLHAL   | Pin  | Board label |
|------------------------|-----------|------|-------------|
| Z Limit Switch         | GPIOC 0   | PC0  | Z- STOP     |
| Z Probe                | GPIOC 13  | PC13 | Probe       |
| Y Limit Switch         | GPIOC 3   | PC3  | Y- STOP     |
| Y Limit Max Switch     | GPIOX X   | PXX  | TODO        |
| X Limit Switch         | GPIOC 1   | PC1  | X- STOP     |
| X Limit Max Switch     | GPIOX X   | PXX  | TODO        |
| Collision Switch/ESTOP | GPIOA 7   | PA7  | EXP2 pin 5  |

## Breakout Boards

The SmartBench design forces more or less to split the electronic in two: one part on the top/toolhead, the other bellow the spoilboard,
with the twos requiring some wire harness to communicate and transmit power.

The original harness was actually split in two chains: 
* 4 conductors for 24V+230V for powering stuff.
* 13 conductors for the logic and endspots stuff (the loom with the VGA connector).

This split-up is good: it avoids possible interferences from the power wires.
But the logic side did not had enough conductors (13) for my setup (3 end stops + 2 SPI TMC drivers connection).
In truth, I even doubt it had enough conductors for the original electronic, the step/dir/enable pins of the two bottom/Y TMC drivers were shared and
the SPI stuff not wired, which seems a bit iffy. 

So, after pondering the differente options (CAN bus, VGA, RJ45 cables, all drivers on top), I decided to replace the logic loom with a DB25 cable.
This connectic and cable has enough connectors, is common enough, and should be easy to replace if needed. I'm just not sure the cable will like being flexed...

Also, as a requirement, I wanted my setup to be fully reversible with the original electronics. So, no cutting and clamping endstops and motor cables.

For all these reasons, I've designed two dumb breakout PCBs using kicad:

* TODO link bottom pcb
* TODO link top pcb

TODO photos

The role of these boards is to interconnect bottom and top (with the DB25 cable), and be the middle man for the existing wiring/connectors and what the SKR3 and the TMC 5160 drivers expect.

They are also designe to offer a bit of flexibility/adjustments.

They were also a good opportunity for me to gently learn kicad. But if you are willing to cut some cables, manufacturing these PCBs is not necessary, A pair of DB25 breakout thingy could also work.

TODO photo db25 breakout
 
## Stepper Motors & Drivers

TODO explain which pins is needed to be wired between top and bottom

TODO show wiring of adapter thingy (main and secondary)

## Limit Switches, Probe, and Safeties

TODO add pinout boards SKR 3 with annotations for endstops

## Spindle

TODO: not handled currently (fixed speed, started manually for now)
