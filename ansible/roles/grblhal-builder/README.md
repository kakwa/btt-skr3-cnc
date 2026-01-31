# grblhal-builder Role

Ansible role to set up grblHAL build environment and deploy custom configuration for BTT SKR3 board with TMC5160 drivers.

## Features

- Installs ARM GCC toolchain and PlatformIO
- Deploys grblHAL sources from local repository
- Applies custom `my_machine.h` configuration
- Updates `platformio.ini` with custom board configuration
- Creates helper scripts for building and flashing firmware

## Configuration

The role configures the BTT SKR3 board with:

- **5 TMC5160 stepper drivers** in SPI mode
- **Ganged X and Y axes** with auto-squaring
- **3 primary axes** (X, Y, Z) + 2 ganged motors (X2, Y2)
- Custom build identifier with timestamp
- USB serial communication
- SD card support
- Probe support

## Variables

See `defaults/main.yml` for all available variables:

### Key Variables

- `grblhal_board`: Target board (default: `BTT_SKR_3_EZ`)
- `grblhal_mcu`: Target MCU (default: `STM32H7xx`)
- `grblhal_platformio_env`: PlatformIO environment (default: `btt_skr_30_h723_tmc5160_bl128`)
- `grblhal_source_dir`: Source directory on target (default: `/opt/grblhal`)

### Feature Toggles

- `grblhal_install_build_tools`: Install build toolchain (default: `true`)
- `grblhal_install_flash_tools`: Install DFU flash tools (default: `true`)
- `grblhal_deploy_sources`: Deploy grblHAL sources (default: `true`)

## Files

### Configuration Files

- `files/my_machine.h`: Custom machine configuration
  - Board selection
  - Motor configuration (ganged X/Y axes)
  - TMC5160 SPI mode
  - Spindle, probe, and control settings

- `files/platformio.ini`: PlatformIO build configuration
  - Simplified configuration with only BTT SKR3 board
  - Common build settings (cache, floating point, ISR location)
  - USB serial and SD card support
  - Hardware-specific settings (HSE crystal frequency)
  - Uses my_machine.h for feature configuration

### Templates

- `templates/skr3-build.sh.j2`: Build script helper
- `templates/skr3-flash.sh.j2`: Flash script helper (interactive DFU mode)

## Usage

### Basic Playbook

```yaml
- hosts: cnc_controller
  roles:
    - grblhal-builder
```

### With Custom Variables

```yaml
- hosts: cnc_controller
  roles:
    - role: grblhal-builder
      vars:
        grblhal_source_dir: /home/user/grblhal
        grblhal_update_platformio: true
```

### Building Firmware

After deployment, build firmware on the target:

```bash
# Using helper script
skr3-build

# Or directly with PlatformIO
cd /opt/grblhal
platformio run -e btt_skr_30_h723_tmc5160_bl128
```

### Flashing Firmware

```bash
# Interactive DFU flash (guides through button presses)
skr3-flash

# Or specify firmware file
skr3-flash /path/to/firmware.bin
```

## Ganged Axes Configuration

### What are Ganged Axes?

Ganged axes use **two motors for a single axis** to provide:
- More power/torque
- Better rigidity
- Auto-squaring capability (using dual limit switches)

### This Configuration

- **X axis**: 2 motors (X + X2 on M3/E0 stepper)
- **Y axis**: 2 motors (Y + Y2 on M4/E1 stepper)
- **Z axis**: 1 motor
- **Total**: 5 TMC5160 drivers

## TMC5160 Motor Current Configuration

### Key Settings in `my_machine.h`

Motor current intensity is controlled by these defines:

```c
#define DEFAULT_X_CURRENT     1000.0f  // mA RMS (run current)
#define DEFAULT_Y_CURRENT     1000.0f
#define DEFAULT_Z_CURRENT     1000.0f
#define DEFAULT_A_CURRENT     1000.0f  // X2 ganged motor
#define DEFAULT_B_CURRENT     1000.0f  // Y2 ganged motor

#define TMC_X_HOLD_CURRENT_PCT 50  // 50% current when holding
#define TRINAMIC_R_SENSE       75  // Sense resistor (milliohms)
#define TRINAMIC_DEFAULT_MICROSTEPS 16
#define TMC_STEALTHCHOP        0   // 0=SpreadCycle, 1=StealthChop
```

### How to Choose Motor Current

1. **Check motor datasheet** for rated current (usually in Amps)
2. **Set to ~70-85% of rated current** for good balance of torque and heat
3. **TMC5160 maximum**: 3000mA (3A) per driver
4. **Start conservatively**: 1000mA, increase if needed

**Examples:**
- **NEMA 17** (1.5A rated): Set to 1000-1200mA
- **NEMA 23** (2.0A rated): Set to 1400-1700mA
- **NEMA 23** (2.8A rated): Set to 2000-2400mA
- **NEMA 34** (3.0A rated): Set to 2100-2550mA

### Tuning Motor Current

**Too Low Current:**
- Motors skip steps under load
- Lost position / weak cutting
- Machine stalls easily

**Too High Current:**
- Motors overheat
- Drivers overheat (check heatsinks!)
- Wasted power
- Potential damage

**Testing:**
1. Start with calculated value (70% of rated)
2. Run test moves with typical cutting forces
3. Check motor temperature after 30 minutes
   - Warm to touch = OK (~40-50°C)
   - Too hot to touch = Reduce current (~60°C+)
4. Increase current if losing steps
5. Add heatsinks if drivers get hot

### Hold Current

`TMC_X_HOLD_CURRENT_PCT` reduces power when motors are stationary:
- **50%**: Good balance (default)
- **30%**: More power saving, may allow movement on vertical axes
- **70%**: More holding torque, more heat

### StealthChop vs SpreadCycle

**SpreadCycle** (`TMC_STEALTHCHOP 0`) - Default, recommended for CNC:
- ✅ High torque at all speeds
- ✅ Better for cutting operations
- ❌ Audible motor hum

**StealthChop** (`TMC_STEALTHCHOP 1`) - Quiet mode:
- ✅ Nearly silent operation
- ❌ Reduced torque at higher speeds
- ⚠️ Not recommended for CNC (use for 3D printers)

### Microstepping

`TRINAMIC_DEFAULT_MICROSTEPS` - Steps per full step:
- **16** (default): Best balance for CNC (smooth + good torque)
- **32/64**: Smoother motion, slightly less torque
- **256**: Maximum smoothness, lowest torque per microstep
- **8**: More torque, less smooth (rarely needed)

### Runtime Configuration

After flashing, motor current can be tuned via grblHAL settings without rebuilding firmware. These settings are stored in EEPROM and persist across reboots.

### Important Notes

1. **N_AXIS remains 3**: grblHAL reports `[AXS:3:XYZ]` because ganged motors are not separate axes
2. **Settings**: Look for `$103`, `$104` (steps/mm for X2, Y2), `$113`, `$114` (max rate)
3. **Auto-squaring**: Requires dual limit switches per ganged axis

## Configuration Architecture

### Primary Configuration: `my_machine.h`

All feature settings are defined in `my_machine.h`:

```c
#define BOARD_BTT_SKR_30      // Board selection
#define X_GANGED 1            // Enable X axis ganging
#define X_AUTO_SQUARE 1       // Enable X auto-squaring
#define Y_GANGED 1            // Enable Y axis ganging
#define Y_AUTO_SQUARE 1       // Enable Y auto-squaring
#define TRINAMIC_ENABLE 5160  // TMC5160 support
#define TRINAMIC_SPI_ENABLE 1 // Use SPI mode
#define GRBL_BUILD_INFO "BTT-SKR3-TMC5160-SPI-XY-GANGED"
```

### PlatformIO Build Settings

The `platformio.ini` file contains **only hardware-specific build settings**:
- HSE crystal frequency (25MHz)
- Linker script (128KB bootloader)
- Library dependencies
- Build optimizations (cache, ISR location, floating point)

**No `OVERRIDE_MY_MACHINE`**: The configuration uses `my_machine.h` as the single source of truth for feature settings.

## Troubleshooting

### Build Issues

**Problem**: Ganged axes not working after build
**Solution**: Ensure `my_machine.h` is deployed correctly. Run the playbook again to deploy the configuration.

**Problem**: Build fails with "BTT SKR-3 supports 5 motors max"
**Solution**: Don't set `N_AXIS > 3`. Use ganged axes (N_AXIS=3 + 2 ganged motors = 5 total)

**Problem**: Configuration changes in `my_machine.h` not taking effect
**Solution**: Verify `OVERRIDE_MY_MACHINE` is **not** defined in `platformio.ini`. Clean build cache: `pio run -t clean`

### Flash Issues

**Problem**: Board not in DFU mode
**Solution**: Hold BOOT0, press RESET, release BOOT0. Use `lsusb | grep 0483:df11` to verify.

**Problem**: Permission denied on /dev/ttyACM0
**Solution**: Add user to dialout group: `sudo usermod -a -G dialout $USER` (then logout/login)

## Directory Structure

```
grblhal-builder/
├── README.md                           # This file
├── defaults/
│   └── main.yml                        # Default variables
├── files/
│   ├── my_machine.h                    # Board configuration
│   └── platformio.ini                  # PlatformIO configuration
├── tasks/
│   └── main.yml                        # Main tasks
└── templates/
    ├── skr3-build.sh.j2                # Build script
    └── skr3-flash.sh.j2                # Flash script
```

## References

- [grblHAL Documentation](https://github.com/grblHAL/core)
- [BTT SKR 3 Documentation](https://github.com/bigtreetech/SKR-3)
- [TMC5160 Datasheet](https://www.trinamic.com/products/integrated-circuits/details/tmc5160/)
