# Troubleshooting & Gotchas

## Access

This setup is network accessible. Ideally, you should join the Pi to a wifi network.
If not, plug it to an RJ45/Ethernet network with DHCP (look at `misc/pi-dhcp-nat.sh` script to temporary transform your laptop into a router if necessary).

Assuming your computer is on the same LAN segment, you should be able to connect to the Pi through kwcnc.local mDNS/Bonjour/Avahi.

You can ssh onto it:

```shell
ssh root@kwcnc.local
```

And open the [gSender WebUI](https://kwcnc.local)

## Joining a Wifi

Become root, and run:

```shell
nmtui
```

## gCode

### CLI cnc-console

For convinience, this setup comes with a basic console to send gcode:

```shell
cnc-console
```

It's equivalent to:

```shell
screen /dev/ttyACM0 115200
```

The board is exposed on `/dev/ttyACM0` at baud rate/speed of 115200 baud.

Alternatively, you can use the way too tiny console at the bottom right of gSender.

### Useful Troubleshooting GCode Commands

```bash
> $$      # List all settings
$0=5.0
$1=25
$2=0
$3=0
$4=7
[...]
ok
```

```bash
> $I      # Show system info
[VER:1.1f.20260520:KWCNC_20260616_2107]
[OPT:VNMSL2,100,1024,3,0]
[AXS:3:XYZ]
[NEWOPT:ENUMS,RT+,TC,SED,FS,TMC=7,SD]
[FIRMWARE:grblHAL]
[SIGNALS:P]
[NVS STORAGE:*FLASH 32K]
[FREE MEMORY:201K]
[DRIVER:STM32H723@480MHz]
[DRIVER VERSION:260517]
[BOARD:BTT SKR-3]
[AUX IO:4,2,0,0]
[PLUGIN:Bootloader Entry v0.02]
[PLUGIN:FS stream v1.11]
[PLUGIN:FS macro plugin v0.23]
[PLUGIN:Trinamic v0.33]
[PLUGIN:SDCARD v1.27]
ok
```

```bash
> ?       # Show status
<Idle|MPos:0.000,0.000,0.000|Bf:100,1024|FS:0,0|Pn:XYZP|Ov:100,100,100>
```

```bash
> $RST=*  # Reset every setting to factory
[MSG:Restoring defaults]
```

```bash
> $HELP   # halp!
Help topics:
 Commands
 Settings
 Aux ports
[...]
ok
```

```bash
> M122    # Trinamic Driver Status
[TRINAMIC]
                      X       Y       Z      X2      Y2
Driver          TMC5160 TMC5160 TMC5160 TMC5160 TMC5160
Set current        1000    1000    1000    1000    1000
RMS current         990     990     990     990     990
Peak current       1400    1400    1400    1400    1400
Run current       19/31   19/31   19/31   19/31   19/31
[...]
ok

```bash
> $338    # driver settings bitmask
$338=7
ok
```

### GCode Settings

**Current**:
```bash
$140=1200    # X axis current (mA)
$141=1200    # Y axis current
$142=1200    # Z axis current
$143=1200    # M3 axis current
$144=1200    # M4 axis current
```

**Steps per mm configured**:
```bash
$100=80      # X steps/mm
$101=80      # Y steps/mm
$102=400     # Z steps/mm (example for lead screw)
```

## Gotchas

* If you have even just one missing driver, SPI control stop working (M122 in `[MSG:Warning: Could not communicate with stepper driver!]` error). The drivers could actually be run without SPI... and some random current settings (smoky-smocky!).
* Settings are kind of stored on flash, including stuff like `BUILD_INFO`. A reset from time to time might be a good idea.
* For this setup, don't use `my_machine.h`. Only leverage `-D PARAM=VALUE` in platform.io
* grblhal documentation is a bit lacking.
