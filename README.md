# btt-skr3-cnc

CNC configuration for BTT SKR3 + grblHAL + Pi + gSender

## Hardware Configuration

- **Board**: BTT SKR 3 (STM32H7xx)
- **Stepper Drivers**: TMC5160 (SPI mode)
- **Control**: Pi running gSender
- **Motors**: X, Y, Z + ganged X2, Y2

# Pi Configuring

## Repostory Checkout

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

**Find Pi IP Address:**

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
