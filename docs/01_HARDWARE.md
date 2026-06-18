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

## Limit Switches — Port Mapping

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

The SmartBench design requires splitting the electronics in two: one part on the top/toolhead, the other below the spoilboard,
with both requiring a wire harness to communicate and transmit power.

The original harness was split in two chains:
* 4 conductors for 24V+230V for powering stuff.
* 13 conductors for the logic and endstops (the loom with the VGA connector).

This split is good: it avoids interference from the power wires.
However, the logic side did not have enough conductors (13) for my setup (3 endstops + 2 SPI TMC drivers).
I even doubt it had enough conductors for the original electronics — the step/dir/enable pins of the two bottom/Y TMC drivers were shared and
the SPI lines were not wired, which seems iffy.

After considering the options (CAN bus, VGA, RJ45 cables, all drivers on top), I decided to replace the logic loom with a DB25 cable.
This connector has enough pins, is common, and should be easy to replace if needed.

I also wanted the setup to be fully reversible with the original electronics — no cutting or clamping of endstop and motor cables.

For all these reasons, I designed two breakout PCBs using KiCad:

* [Bottom breakout PCB](../pcbs/breakout_bottom_dsub25/)
* [Top breakout PCB](../pcbs/breakout_top_dsub25/)

The end result looks like this:

![Custom PCBs — top (large) and bottom (small)](img/pcbs.jpg)

These boards interconnect the bottom and top components (via the DB25 cable) and act as adapters between the existing wiring/connectors and what the SKR3 and the TMC5160 drivers expect.
They were also a good opportunity to learn KiCad.

If you are willing to cut some cables, manufacturing these PCBs is not necessary — a pair of DB25 breakout boards with screw terminals can also work:
![DB25 screw-terminal breakout boards (commercial alternative)](img/DB25_breakout.jpg)

## Stepper Motors & Drivers

Each TMC5160 driver requires at least the following signals routed from the SKR3:

* `STEP`, `DIR`, `EN` — motion control
* `CS` — SPI chip-select (one per driver)
* Shared SPI bus: `MOSI`, `MISO`, `SCK`
* `24V`, `GND` — shared power rails

To connect the Y drivers at the bottom to the SKR 3 board, two cable adapters are needed:

![Main motor connector adapter](img/custom_connector_main.jpg)

![Secondary motor connector adapter](img/custom_connector_secondary.jpg)


![TMC5160 drivers installed on the SKR3](img/stepper_controller_wiring.jpg)

With almost everything connected, things look a bit unwieldy:

![Top electronics enclosure — top PCB, SKR3, and TMC5160 drivers](img/top_wiring.jpg)

The bottom is a bit more manageable:

![Bottom breakout board installed, with Y stepper connectors and DB25 cable](img/bottom_board.jpg)

## Limit Switches, Probe, and Safeties

TODO (schema)

## Spindle

Not handled currently — the spindle runs at fixed speed and is started manually before the job.
