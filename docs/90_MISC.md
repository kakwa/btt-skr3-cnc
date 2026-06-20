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

## Pi Setup

## Repository Checkout
        
```bash
git clone https://github.com/kakwa/btt-skr3-cnc
cd btt-skr3-cnc/
git submodule update --init --recursive
```     

## Pi Preparation

### SD Card Flashing

Flash the OS to an SD card. Choose one of:

- **Raspberry Pi**: Use Raspberry Pi Imager - https://www.raspberrypi.com/software/
- **BTT Pi** (cheap & 24V, no 5V required): Use Armbian - https://www.armbian.com/bigtreetech-cb1/

### Initial Setup

**Find Pi IP Address via Ethernet (Quick DHCP Server Method):**

If the Pi is not yet on your network, you can set up a quick DHCP server on your local machine to assign it an IP:

```bash
# On your local machine (Linux), install dnsmasq if not already installed
sudo apt install dnsmasq

# List network interfaces and pick your ethernet NIC (often eno1, eth0, enp*s0):
ip addr

# Assign a static address on the link to the Pi (replace eno1 with your interface):
sudo ip addr add 192.168.100.1/24 dev eno1

# Write a minimal dnsmasq config (replace eno1 with your interface):
sudo tee /etc/dnsmasq.conf > /dev/null <<'EOF'
interface=eno1
dhcp-range=192.168.100.50,192.168.100.150,24h
dhcp-option=3
EOF

# Run dnsmasq in foreground
sudo dnsmasq -d -C /etc/dnsmasq.conf

# You should see the IP allocated to the Pi in the logs
# if not, unplug and replug it
```

**Find Pi IP Address via Network Scan:**

```bash
# Scan network for Pi by MAC address prefix
ip neigh | grep -E 'b8:27:eb|dc:a6:32|e4:5f:01|26:a4:ec'
```

**Configure WiFi (if needed):**

```bash
ssh root@<PI_IP>
sudo nmtui
```

**Enable SSH root login:**

```bash
# Enable root login in SSH config
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

**Setup SSH key for passwordless access:**

```bash
# On your local machine, create SSH key if you don't have one
ssh-keygen
# Copy key to Pi
ssh-copy-id root@<PI_IP>
```
