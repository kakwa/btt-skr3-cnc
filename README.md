# btt-skr3-cnc

Reviving a Yetitool CNC using a Bigtreetech SKR3 EZ + grblHAL + PI + gSender.

## Project Status

* [x] Pi configuration
* [x] Base GRBLHAL setup
* [ ] End Stops and safety stop configuration
* [ ] Spindle Control (optional)
* [ ] Proper Case for elec
* [ ] Wiring/adapter board 

## Hardware Configuration

- **Board**: [BTT SKR 3 EZ (STM32H7xx)](https://github.com/bigtreetech/SKR-3)
- **Stepper Drivers**: TMC5160
- **Control**: [BTT Pi](https://github.com/bigtreetech/BTT-Pi) running [gSender](https://sienci.com/gsender/)
- **Motors**: X, Y, Z + ganged X2, Y2

# Pi Configuring

## Repository Checkout

```bash
git clone https://github.com/kakwa/btt-skr3-cnc
cd btt-skr3-cnc/
git submodule update --init --recursive
```

## Pi Preparation

### SDCard Flashing

Flash the OS to an SD card. Choose one of:

- **Raspberry Pi**: Use Raspberry Pi Imager - https://www.raspberrypi.com/software/
- **BTT Pi** (cheap & 24V, no 5V required): Use Armbian - https://www.armbian.com/bigtreetech-cb1/

### Initial Setup

**Find Pi IP Address via Ethernet (Quick DHCP Server Method):**

If the Pi is not yet on your network, you can set up a quick DHCP server on your local machine to assign it an IP:

```bash
# On your local machine (Linux), install dnsmasq if not already installed
sudo apt install dnsmasq

# Configure a DHCP server on your ethernet interface
# Edit /etc/dnsmasq.conf and add:
# interface=eth0  (or your ethernet interface name)
# dhcp-range=192.168.100.50,192.168.100.150,24h
# dhcp-option=3   (no default gateway needed)

# Run dnsmasq in foreground (for debugging):
sudo dnsmasq -d -C /etc/dnsmasq.conf

# In another terminal, connect your Pi via ethernet and find its IP:
arp-scan -l | grep -i "bigtreetech\|raspberry"
# Or check DHCP leases:
cat /var/lib/dnsmasq/dnsmasq.leases
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

## Configuration & MCU Firmware + Flashing Tool

### Installing The PI Stuff

```bash
# Raspberry Pi IP Address Discovery
export PI_IP=$(ip neigh | awk '/b8:27:eb|dc:a6:32|e4:5f:01/ {print $1, $5}')


# BTT PI IP Address discovery
export PI_IP=$(ip neigh | awk '/26:a4:ec/ {print $1}')


# Go in Ansible directory
cd ansible/

# Run Playbook
ansible-playbook -i "${PI_IP}," -u root pi-setup.yml
```

if everything went well, at the end you should get:

```
[...]

TASK [grblhal-builder : Display helper scripts information] **********************************
ok: [192.168.1.46] => {
    "msg": [
        "========================================",
        "grblHAL Build Environment Ready!",
        "========================================",
        "Source directory: /opt/grblhal",
        "Build directory: /opt/grblhal/build",
        "Target board: BTT_SKR_3_EZ",
        "MCU: STM32H7xx",
        "PlatformIO environment: btt_skr_30_h723_tmc5160_bl128",
        "",
        "Helper scripts installed:",
        "  - skr3-build    Build the firmware",
        "  - skr3-flash    Flash the firmware via USB (DFU)",
        "",
        "Usage:",
        "  skr3-build                    # Build firmware",
        "  skr3-flash                    # Flash latest firmware (interactive)",
        "  skr3-flash custom.bin         # Flash specific firmware file",
        "",
        "The flash script will guide you through the DFU bootloader process.",
        "========================================"
    ]
}

PLAY RECAP ***********************************************************************************
192.168.1.46               : ok=10   changed=57    unreachable=0    failed=0    skipped=6    rescued=0    ignored=0
```

### Flashing the MCU

Connect as root on the PI:

```bash
# or get a root shell another way
ssh root@<PI_IP>
```

Compiling grblhal using the [build helper script](TODO):

```bash
skr3-build
```

You should get an output similar to:

```
[...]
======================================================== 1 succeeded in 00:11:29.833 ========================================================
Build successful!
Firmware: .pio/build/btt_skr_30_h723_tmc5160_bl128/firmware.bin
Firmware copied to: /opt/grblhal/build/firmware_latest.bin

======================================
Build Complete!
======================================
```

Finally, locate the boot and reset button on the SKR3/MCU board,
and then flash grblhal on the MCU using [flashing helper script](TODO) :

```bash
# Run the script and follow the instructions
skr3-flash
```


You should get an output similar to:

```
[...]
═══════════════════════════════════════
  Flash Complete! ✓
═══════════════════════════════════════

To start the new firmware:

Press the RESET button on the board
        Press any key after you've pressed RESET...

Waiting for board to restart...
✓ Board is running! (Virtual COM Port detected)
✓ Serial device: /dev/ttyACM0

You can now connect to grblHAL via /dev/ttyACM0

## Connect to gSender

From there, if you are on the same network, you should be able to connect with the following URL: https://kwcnc.local (accept self-signed cert).

Once connected you should be able to control the CNC or run gcode.

# Wiring Everything

## TMC 5160 Stepper Controler

* XM -> X1
* YM -> Y1
* ZM -> Z
* E0M -> X2 (ganged)
* E1M -> Y2 (ganged)

## Limit Switches

+------------------------+-----------+------+--------------+
| Name                   | GRBLHAL   | Pin  | Board label  |
+------------------------+-----------+------+--------------+
| Z Limit Switch         | GPIOC 0   | PC0  | Z- STOP      |
| Z Probe                | GPIOC 13  | PC13 | Probe        |
| Y Limit Switch         | GPIOC 3   | PC3  | Y- STOP      |
| Y Limit Max Switch     | GPIOX X   | PXX  | TODO         |
| X Limit Switch         | GPIOC 1   | PC1  | X- STOP      |
| X Limit Max Switch     | GPIOX X   | PXX  | TODO         |
| Collision Switch/ESTOP | GPIOA 7   | PA7  | EXP2 pin 5   |
+------------------------+-----------+------+--------------+

## Spindle PWM Controller

+--------------------+-----------+------+------------------+
| Function           | GRBLHAL   | Pin  | Board label      |
+--------------------+-----------+------+------------------+
| Spindle PWM        | GPIOB 0   | PB0  | EXP1 pin 9       |
| Spindle enable     | GPIOB 6   | PB6  | FAN1             |
+--------------------+-----------+------+------------------+

Also need a PWM to 1-10V converter + a relay board (Spindle enable)

## Schematic

TODO
