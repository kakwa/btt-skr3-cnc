# Trying to revive a Yeti Tool SmartBench CNC

## Introduction

Last year, I joined a local fablab. If you like building stuff, I would highly recommend it.
These are great places to learn new skills, spend time with wonderful people and play with machines out of reach of a typical toolbox.

One of these tools in my local fablab is a CNC router by Yeti Tool. I would love to play with it, but unfortunately, it went out of service months before I joined.
To complicate matters, [Yeti Tool went under in 2024](https://find-and-update.company-information.service.gov.uk/company/11310906/insolvency). Not ideal, even if [Trend UK](https://www.trend-eu.com/products/cnc-machines/trend-yeti-cnc-smartbench/trend-yeti-cnc-smartbench) stepped-up and started providing spare parts and support.

In our case, it's the electronic boards which have various issues, from broken connectors to fried components.
I'm not actually sure what the issues are. I could probably investigate and fix these, but I'm actually not too keen on it:

1. the fix would likely be a fragile bodge work just waiting to break again.
2. even if it worked, it would let the tool in an unmaintainable state, with no effective software support and partial hardware one.
3. I would not learn as much.

For all these reasons, plus my incurable Open Source ethos, I'm much more keen on trying to rebuild the whole controller & stepper drivers stuff.
I might be way over my head, Dunning-Kruger style, but as we say, You Live Only Once, and it's a nice step up from a Voron 0.2 build.

## What Are The Options?

Let's limit ourselves to Open Source options, so no [Mach 4](https://www.mach-labs.com/) or similar.

### LinuxCNC + Mesa Hardware

[LinuxCNC](https://linuxcnc.org/) is the gold standard for OSS CNC control: mature, extremely capable, supports virtually any machine topology. But I would not learn that much from it, plus using a PC & Linux for Realtime stuff doesn't seem to fully click.


### FluidNC + ESP32

[FluidNC](https://github.com/bdring/FluidNC) runs on an ESP32 with WiFi built in and YAML-based configuration. It looks really nice and is really promising. The catch is the lack of decent and easily sourceable ESP32 boards. The closest is the [BTT Rodent](https://biqu.equipment/products/bigtreetech-rodent), but it's lacking on the IO and driver department. Plus the drivers are integrated

### grblHAL + STM32

[grblHAL](https://github.com/grblHAL) is GRBL ported to ARM microcontrollers. It keeps GRBL's familiar G-code dialect and adds proper TMC driver support, ganged-axis auto-squaring, and Modbus VFD control. It supports common boards like BTT SKR 3 (STM32H723) I ended up choosing: 5 driver slots, enough GPIO, support of TMC5160.

### Final Choice: grblHAL + BTT SKR 3 + TMC5160 + Pi + gSender

- **BTT SKR 3** (STM32H723VG) running **grblHAL** as the motion controller
- **TMC5160** drivers in UART mode (StallGuard, CoolStep)
- **BTT Pi** running **gSender** as the G-code sender and web UI

For the UI, I picked [gSender](https://sienci.com/gsender/), which is quite nice and has frequent updates.

## Table of Contents

- [Introduction](#introduction)
- [What Are The Options?](#what-are-the-options)
  - [LinuxCNC + Mesa Hardware](#linuxcnc--mesa-hardware)
  - [FluidNC + ESP32](#fluidnc--esp32)
  - [grblHAL + STM32](#grblhal--stm32)
  - [Final Choice: grblHAL + BTT SKR 3 + TMC5160 + Pi + gSender](#final-choice-grblhal--btt-skr-3--tmc5160--pi--gsender)
- [Documentation](#documentation)

## Documentation

- **[01_HARDWARE.md](01_HARDWARE.md)** - BTT SKR 3 wiring guide for grblHAL
- **[02_INSTALL.md](02_INSTALL.md)** - Base software setup (Pi, grblHAL build & flash)
- **[03_CONFIGURATION.md](03_CONFIGURATION.md)** - grblHAL configuration
- **[04_TROUBLESHOOTING.md](04_TROUBLESHOOTING.md)** - Troubleshooting and gotchas
- **[90_MISC.md](90_MISC.md)** - Miscellaneous notes
- **[99_SETTINGS.md](99_SETTINGS.md)** - grblHAL settings reference
