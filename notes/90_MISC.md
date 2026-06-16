# Misc Pieces of Informations

## Build Work Arounds

**Manual workaround** (if needed):

```bash
# Create symlinks to system toolchain
mkdir -p ~/.platformio/packages/toolchain-gccarmnoneeabi/bin
for f in /usr/bin/arm-none-eabi-*; do
  ln -sf "$f" ~/.platformio/packages/toolchain-gccarmnoneeabi/bin/
done

# Create package.json
cat > ~/.platformio/packages/toolchain-gccarmnoneeabi/package.json << 'EOF'
{
  "name": "toolchain-gccarmnoneeabi",
  "version": "1.70301.190214",
  "description": "System ARM GCC toolchain (symlinked)",
  "keywords": ["toolchain"],
  "license": "GPL-2.0-or-later",
  "system": ["*"]
}
EOF

# Patch platform.json (after first platformio run)
sudo sed -i 's/"version": ">=1.60301.0,<1.80000.0"/"version": "*"/' \
  /root/.platformio/platforms/ststm32/platform.json
```

## Platform.io Packages

For the build, I've created Debian packages for platform.io [here](https://github.com/kakwa/misc-pkg/).

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
| Drivers | TMC5160 (UART mode) |
| Flash Address | 0x08020000 |
| PlatformIO Env | `btt_skr_30_h723_tmc5160_bl128` |
