# Troubleshooting & Gotchas

## Connecting to the Pi

The setup is network accessible. Join the Pi to a WiFi network, or plug it into an Ethernet network with DHCP
(see `misc/pi-dhcp-nat.sh` to temporarily turn your laptop into a router if needed).

Once on the same LAN, the Pi is reachable via mDNS at `kwcnc.local`:

| Service    | Address                    |
|------------|----------------------------|
| SSH        | `ssh root@kwcnc.local`     |
| gSender UI | http://kwcnc.local         |

### Joining a WiFi Network

```shell
nmtui
```

---

## Interacting with the CNC (gCode)

### Serial Console

Two equivalent ways to open an interactive gCode console:

```shell
cnc-console                  # convenience wrapper
screen /dev/ttyACM0 115200   # equivalent manual command
```

The board is on `/dev/ttyACM0` at 115200 baud. There is also a built-in (tiny) console in the bottom-right of gSender.

### Useful Diagnostic Commands

| Command   | Purpose                              |
|-----------|--------------------------------------|
| `$$`      | List all settings                    |
| `$I`      | Show firmware/system info            |
| `?`       | Show current status                  |
| `$RST=*`  | Reset all settings to factory        |
| `$HELP`   | List help topics                     |
| `M122`    | Trinamic driver status               |
| `$338`    | Driver settings bitmask              |

### Command Examples

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
```

```bash
> $338    # driver settings bitmask
$338=7
ok
```

---

## Current Settings

### Motor Current (mA)

```bash
$140=1200    # X axis current (mA)
$141=1200    # Y axis current
$142=1200    # Z axis current
$143=1200    # M3 axis current
$144=1200    # M4 axis current
```

### Steps per mm

```bash
$100=80.0    # X steps/mm
$101=53.33   # Y steps/mm (calibrated: 80 × 100/150)
$102=266.67  # Z steps/mm (calibrated: 400 × 100/150)
$103=80.0    # X2 steps/mm (ganged, same as X)
$104=53.33   # Y2 steps/mm (ganged, same as Y)
```

---

## Gotchas

* If you have even just one missing driver, SPI control stops working (M122 returns `[MSG:Warning: Could not communicate with stepper driver!]` error). The drivers could actually be run without SPI... and some random current settings (smoky-smocky!).
* Settings are kind of stored on flash, including stuff like `BUILD_INFO`. A reset from time to time might be a good idea.
* For this setup, don't use `my_machine.h`. Only leverage `-D PARAM=VALUE` in platformio.
* grblHAL documentation is a bit lacking.
* Bodge wires are the devil (I might have or have not burnt a board).
