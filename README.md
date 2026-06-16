# btt-skr3-cnc

Reviving a [Yeti Tool SmartBench](https://www.yetitool.com/) CNC router with modern open-source hardware and firmware: [BTT SKR 3 EZ](https://github.com/bigtreetech/SKR-3) controller board running [grblHAL](https://github.com/grblHAL), managed by a [BTT Pi](https://github.com/bigtreetech/BTT-Pi) running [gSender](https://sienci.com/gsender/).

The original SmartBench electronics were replaced entirely. This repo contains everything needed to reproduce the setup: firmware configuration, Pi provisioning via Ansible, custom adapter PCBs, and enclosure CAD files.

## Project Status

* [x] Pi configuration
* [x] Base grblHAL setup
* [~] End stops and safety stop configuration
* [~] Proper enclosure for electronics
* [~] Wiring/adapter board
* [ ] Spindle control (optional)

## Hardware

| Component | Details |
|-----------|---------|
| Controller board | [BTT SKR 3 EZ](https://github.com/bigtreetech/SKR-3) — STM32H723VG |
| Stepper drivers | TMC5160 |
| SBC | [BTT Pi](https://github.com/bigtreetech/BTT-Pi) |
| Sender | [gSender](https://sienci.com/gsender/) |
| Motors | X, Y, Z + ganged X2, Y2 |

## Repository Layout

```
.
├── docs/           # Project documentation (start here)
│   ├── 00_INTRO.md          # Project background and overview
│   ├── 01_HARDWARE.md       # Wiring and board configuration
│   ├── 02_INSTALL.md        # Pi OS and software installation
│   ├── 03_CONFIGURATION.md  # grblHAL configuration
│   ├── 04_TROUBLESHOOTING.md
│   ├── 90_MISC.md           # Build notes and workarounds
│   └── 99_SETTINGS.md       # grblHAL settings reference
├── ansible/        # Ansible playbook to provision the BTT Pi
│   ├── pi-setup.yml
│   └── roles/      # avahi, gsender, grblhal-builder, nginx, …
├── grblhal/        # grblHAL firmware (git submodule, STM32 driver)
├── pcbs/           # KiCad PCB designs
│   ├── breakout_top_dsub25/   # Top breakout board (DB25)
│   ├── breakout_bottom_dsub25/
│   ├── breakout_top_vga/
│   └── adapters/
├── cad/            # FreeCAD enclosure and mounting parts
├── tests/          # G-code test files
└── misc/           # Utility scripts and raw settings dumps
```

## Documentation

Full documentation lives in [`docs/`](docs/). Start with [docs/00_INTRO.md](docs/00_INTRO.md) for project background, then follow the numbered files in order.
