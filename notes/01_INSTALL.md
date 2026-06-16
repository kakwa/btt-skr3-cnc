# Base Software Setup

## Pi Installation

### Pi Base OS

TODO

### Setup the Pi

TODO ansible

TODO partial apply (--tags)

## Building Firmware

Once 

### Using the Helper Script

Build can be done with the following script:

```bash
skr3-build
```

Under the hood, it's using plateform.io/pio.
It uses a custom environment (deployed at the Ansible step)
TODO run with bash -x to get the details.

TODO location `/opt/grblhal`

## Flashing Firmware

### Using the Helper Script (Recommended)

```bash
skr3-flash
```

The script will guide you through:
1. Entering DFU bootloader mode (interactive, requires you to reset the board in DFU by pushing RESET and BOOT at the same time)
2. Flashing the firmware
3. Resetting the board to run the new firmware

Once again, run the script with bash -x to get the details.

Once flash available on port `/dev/ttyACM0` *@115200**.

```bash
cnc-console
```

## Configuration tweaks:

```bash
vim /opt/grblhal/platformio.ini
```

And edit the end:

```ini
# BEGIN ANSIBLE MANAGED BLOCK: kwcnc_yeti
# KW CNC Yeti - BTT SKR 3 H743 with TMC5160, ganged XY axes, SPI drivers
[env:kwcnc_yeti]
board = generic_stm32h723vg
board_build.ldscript = STM32H723VGTX_FLASH_BL.ld
build_flags = ${env:btt_skr_30_h723_tmc5160_bl128.build_flags}
  !echo "-D BUILD_INFO='\"KWCNC_$(date +%%Y%%m%%d_%%H%%M)\"'"
  -D X_GANGED=1
  -D X_AUTO_SQUARE=1
  -D Y_GANGED=1
  -D Y_AUTO_SQUARE=1
  -D DEFAULT_X_CURRENT=1000.0f
  -D DEFAULT_Y_CURRENT=1000.0f
  -D DEFAULT_Z_CURRENT=1000.0f
  -D DEFAULT_A_CURRENT=1000.0f
  -D DEFAULT_B_CURRENT=1000.0f
  -D DEFAULT_X_STEPS_PER_MM=80.0f
  -D DEFAULT_Y_STEPS_PER_MM=80.0f
  -D DEFAULT_Z_STEPS_PER_MM=400.0f
  -D DEFAULT_A_STEPS_PER_MM=80.0f
  -D DEFAULT_B_STEPS_PER_MM=80.0f
  -D ESTOP_ENABLE=0
  -D CONTROL_ENABLE=0
  -D TRINAMIC_UART_ENABLE=0
  -D TRINAMIC_SPI_ENABLE=1
  -D TRINAMIC_ENABLE=5160
  -D TRINAMIC_R_SENSE=75
lib_deps = ${env:btt_skr_30_h723_tmc5160_bl128.lib_deps}
lib_extra_dirs = ${env:btt_skr_30_h723_tmc5160_bl128.lib_extra_dirs}
upload_protocol = dfu
# END ANSIBLE MANAGED BLOCK: kwcnc_yeti
```

If possible do the same changes in [TODO ANSIBLE PLAYBOOK REF]
