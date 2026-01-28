# grblHAL Build and Flash Guide

## Quick Start

After deploying the Ansible role, you'll have two helper scripts:

```bash
skr3-build    # Build firmware
skr3-flash    # Flash firmware via USB (DFU)
```

## Building Firmware

### Using the Helper Script

```bash
skr3-build
```

This will:
- Build grblHAL for BTT SKR 3 (H723) with TMC5160 drivers
- Use your custom `my_machine.h` configuration
- Output firmware to `/opt/grblhal/build/firmware_latest.bin`

### Manual Build with PlatformIO

```bash
cd /opt/grblhal
platformio run -e btt_skr_30_h723_tmc5160_bl128
```

**Build Output:**
```
Firmware location: .pio/build/btt_skr_30_h723_tmc5160_bl128/firmware.bin
```

## Flashing Firmware

### Using the Helper Script (Recommended)

```bash
skr3-flash
```

The script will guide you through:
1. Entering DFU bootloader mode (interactive prompts)
2. Flashing the firmware
3. Resetting the board to run the new firmware

### Manual Flash

#### Step 1: Enter DFU Bootloader Mode

1. **Hold** the BOOT0 button on the SKR3 board
2. **Press and release** the RESET button (while holding BOOT0)
3. **Release** the BOOT0 button

**Verify DFU mode:**
```bash
dfu-util -l
```

You should see:
```
Found DFU: [0483:df11] ver=0200, devnum=X, cfg=1, intf=0, ...
```

#### Step 2: Flash Firmware

```bash
cd /opt/grblhal
dfu-util -a 0 -s 0x08020000 -D .pio/build/btt_skr_30_h723_tmc5160_bl128/firmware.bin
```

**Important:** Use address `0x08020000` (not `0x08000000`) because the SKR3 has a 128KB bootloader.

#### Step 3: Reset Board

Press the **RESET** button on the board to start the firmware.

**Verify it's running:**
```bash
lsusb | grep 0483:5740    # Should show "Virtual COM Port"
ls /dev/ttyACM*           # Serial device (usually /dev/ttyACM0)
```

## Board Configuration

| Setting | Value |
|---------|-------|
| Board | BTT SKR 3 |
| MCU | STM32H723VG |
| Bootloader | 128KB (factory) |
| Drivers | TMC5160 (SPI) |
| Flash Address | 0x08020000 |
| PlatformIO Env | `btt_skr_30_h723_tmc5160_bl128` |

## Configuration Files

### Custom Configuration: `my_machine.h`

Located at: `ansible/roles/grblhal-builder/files/my_machine.h`

Key settings:
- **Board:** `BOARD_BTT_SKR_30`
- **Drivers:** TMC5160 with UART enabled
- **Motors:** X and Y ganged with auto-squaring
- **Spindle:** PWM spindle enabled
- **Probe:** Enabled

This file is deployed separately and **not synced from upstream** to preserve your custom settings.

### PlatformIO Environment

The build uses the `btt_skr_30_h723_tmc5160_bl128` environment from `platformio.ini`:

```ini
[env:btt_skr_30_h723_tmc5160_bl128]
board = generic_stm32h723vg
board_build.ldscript = STM32H723VGTX_FLASH_BL.ld  # 128KB bootloader
build_flags = 
  -D BOARD_BTT_SKR_30
  -D HSE_VALUE=25000000
  -D TRINAMIC_ENABLE=5160
lib_deps = motors, trinamic, usb_h723, sdcard
upload_protocol = dfu
```

## Troubleshooting

### Board Not Entering DFU Mode

**Symptoms:**
```bash
dfu-util -l
# No devices found
```

**Solution:**
1. Unplug and replug USB cable
2. Carefully repeat the BOOT0/RESET sequence
3. Check with `lsusb` - should show `0483:df11`

### Flash Error: "Error during download get_status"

This error often occurs with the `:leave` flag but **the flash usually succeeded**. 

**Solution:**
- Don't use `:leave` in the dfu-util command
- Flash without it: `dfu-util -a 0 -s 0x08020000 -D firmware.bin`
- Manually press RESET after flashing

### Board Stuck in DFU Mode After Flash

**Symptoms:**
```bash
lsusb | grep 0483:df11  # Still shows DFU device
```

**Solution:**
Press the **RESET** button on the board.

### Wrong Flash Address

**Symptoms:**
- Board doesn't boot after flashing
- Stuck in DFU mode

**Common Mistake:**
Using `0x08000000` instead of `0x08020000`

**Solution:**
The BTT SKR 3 has a **128KB bootloader** at `0x08000000-0x0801FFFF`.  
The application **must** start at `0x08020000`.

### Serial Device Not Appearing

**Expected after successful flash:**
```bash
lsusb | grep 0483:5740
# Bus 001 Device XXX: ID 0483:5740 STMicroelectronics Virtual COM Port

ls /dev/ttyACM*
# /dev/ttyACM0
```

**If not appearing:**
1. Press RESET button
2. Check `dmesg | tail -20` for USB errors
3. Re-flash firmware

## Connecting to grblHAL

After successful flash:

```bash
# Check serial device
ls -l /dev/ttyACM0

# Connect with screen
screen /dev/ttyACM0 115200

# Or use gSender (web interface)
# Navigate to: http://kwcnc.local:4000
```

## Build Customization

To change the PlatformIO environment (e.g., different MCU or no bootloader):

Edit `ansible/roles/grblhal-builder/defaults/main.yml`:

```yaml
# For H743 MCU without bootloader:
grblhal_platformio_env: "btt_skr_30_h743_tmc5160"

# For H743 with 128KB bootloader:
grblhal_platformio_env: "btt_skr_30_h743_tmc5160_bl128"

# For H723 without bootloader:
grblhal_platformio_env: "btt_skr_30_h723_tmc5160"
```

Then re-run the Ansible playbook to update the build script.

## References

- [grblHAL GitHub](https://github.com/grblHAL)
- [BTT SKR 3 Documentation](https://github.com/bigtreetech/SKR-3)
- [dfu-util Documentation](http://dfu-util.sourceforge.net/)
- [PlatformIO STM32 Platform](https://docs.platformio.org/en/latest/platforms/ststm32.html)
