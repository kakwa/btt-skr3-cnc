# Trying to revive a Yeti Tool SmartBench CNC

## Parts

- **[01_HARDWARE.md](01_HARDWARE.md)** - BTT SKR 3 wiring guide for grblHAL
- **[02_INSTALL.md](02_INSTALL.md)** - Base software setup (Pi, grblHAL build & flash)
- **[03_CONFIGURATION.md](03_CONFIGURATION.md)** - grblHAL configuration
- **[04_TROUBLESHOOTING.md](04_TROUBLESHOOTING.md)** - Troubleshooting and gotchas
- **[90_MISC.md](90_MISC.md)** - Miscellaneous notes
- **[99_SETTINGS.md](99_SETTINGS.md)** - grblHAL settings reference

## Intro

In 2025, I joined a local fablab. If you like building stuff, I would highly recommend it.
These are great places to learn new skills, spend time with really nice people and play
with machines typically out of reach of most.

One of these out-of-reach tools is a SmartBench CNC router by YetiTool. Would love to play with it, but unfortunately, the board burnt out, and it went out of service months before I joined.
To complicate matters, [Yeti Tool went under in 2024](https://find-and-update.company-information.service.gov.uk/company/11310906/insolvency). Not ideal, even if [Trend UK](https://www.trend-eu.com/products/cnc-machines/trend-yeti-cnc-smartbench/trend-yeti-cnc-smartbench) stepped up and started providing spare parts and support.

While I could probably investigate and try fixing the issue, I'm not convinced it's the correct approach:

1. a fix would likely be a fragile bodge just waiting to break again.
2. even if it lasts, it would leave the tool in an unmaintainable state, with no effective software support and partial hardware one.
3. It's less fun

Given I already [built a Voron 0.2](https://www.youtube.com/watch?v=Ej5ZsTKy6t4), it should be easy pizzie lemon squizzy </Dunning-Kruger syndrome>.

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
