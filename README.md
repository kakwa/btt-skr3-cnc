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

### Flashing

TODO Rasp link
TODO Other option, BTT Pi (because 24V) Link to ARMBIAN instruction

### Enable Root Login & SSH key

TODO (Find IP of BTT Pi or RASP Pi (linux command look for MAC Address prefix BTT -> 26:a4:ec:e1:be:61)

### Wifi Configuration

TODO nmtui

## Configuration & MCU Firmware + Flashing Tool

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
