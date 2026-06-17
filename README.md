# btt-skr3-cnc

Reviving a [Yeti Tool SmartBench](https://www.yetitool.com/) CNC router with new hardware and open-source firmware.

This project replaces pretty much all the sketchy eletronics original electronics with an even sketckier setup.

It keeps the original stepper motors, overal frame, and endstops.

## Project Status

* [done] Pi configuration
* [done] Base grblHAL setup
* [done] Wiring/adapter board
* [in-progress] End stops and safety stop configuration
* [in-progress] Proper enclosure for electronics
* [ ] Spindle control (optional)

## Hardware & Software components

| Component           | Details                                                          |
|---------------------|------------------------------------------------------------------|
| Controller board    | [BTT SKR 3 EZ](https://github.com/bigtreetech/SKR-3)             |
| Stepper drivers     | TMC5160                                                          |
| SBC                 | [BTT Pi](https://github.com/bigtreetech/BTT-Pi) (or RPi > 3)     |
| Firmware            | [grblHAL](https://github.com/grblHAL/core/blob/master/README.md) |
| UI & gCode Uploader | [gSender](https://sienci.com/gsender/)                           |
| Motors Setup        | X, Y, Z + ganged X2, Y2                                          |

## Repository Layout

- `docs/` — project documentation (start here); numbered markdown files covering intro, hardware, install, configuration, troubleshooting, and settings
- `ansible/` — Ansible playbook to provision the BTT Pi (roles: avahi, gsender, grblhal-builder, nginx, ...)
- `grblhal/` — grblHAL firmware as a git submodule (STM32 driver)
- `pcbs/` — KiCad PCB designs for the DB25 breakout boards and adapters
- `cad/` — FreeCAD enclosure and mounting parts
- `tests/` — G-code test files
- `misc/` — utility scripts and raw settings dumps

## Documentation

Project documentation is available in [`docs/`](docs/).
