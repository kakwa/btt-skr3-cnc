# grblHAL Settings Reference

## Table of Contents

- [Motion Control](#motion-control)
- [Spindle Control](#spindle-control)
- [Operational Settings](#operational-settings)
- [Homing & Limits](#homing--limits)
- [Parking](#parking)
- [Axis Configuration](#axis-configuration)
- [Trinamic Driver Settings](#trinamic-driver-settings)
- [Tool Change](#tool-change)
- [I/O Ports](#io-ports)
- [System Settings](#system-settings)

---

## Motion Control

### `$0` — Step pulse time (`µs`, min: 1.5)

Step pulse length in microseconds. Minimum depends on the processor, typically 1–2.5 µs.

> Reduce from the default of 5 when max step rate exceeds ~140 kHz.

---

### `$1` — Step idle delay (`ms`, max: 65535)

Short hold delay when stopping, to let dynamics settle before disabling steppers. Value `255` keeps motors enabled indefinitely.

---

### `$2` — Step pulse invert (`axismask`)

Inverts the step signals (active low).

---

### `$3` — Step direction invert (`axismask`)

Inverts the direction signals (active low).

---

### `$4` — Invert stepper enable output(s) (`axismask`)

Inverts the stepper driver enable signals. Most drivers use active-low enable and require inversion.

> If stepper drivers share the same enable signal, only X is used.

---

### `$29` — Pulse delay (`µs`, max: 20)

Step pulse delay. When set > 0 and < 2, the value is rounded up to 2 µs.

---

### `$37` — Steppers to keep enabled (`axismask`)

Specifies which steppers not to disable when stopped.

---

### `$39` — Enable legacy RT commands (`boolean`)

Enables normal processing of `?`, `!`, and `~` characters when part of a `$`-setting or comment. If disabled, they are added to the input string instead.

---

### `$40` — Limit jog commands (`boolean`)

Limits jog commands to machine workspace for homed axes.

---

### `$680` — Stepper enable delay (`ms`, max: 500)

Delay from stepper enable to first step output. The driver typically adds ~2 ms to this.

---

## Spindle Control

### `$9` — PWM spindle options (`bitfield`)

| Bit | Value | Description                        |
|-----|-------|------------------------------------|
| 0   | 1     | Enable PWM output                  |
| 1   | 2     | RPM controls spindle enable signal |
| 2   | 4     | Disable laser mode capability      |
| 3   | 8     | Enable ramping                     |

When *RPM controls spindle enable signal* is set and M3/M4 is active: S0 switches it off, S>0 switches it on.
When *Ramping enable* is set, spin-up/down time is calculated from `$394` and `$539`.

---

### `$16` — Invert spindle signals (`bitfield`)

| Bit | Value | Description       |
|-----|-------|-------------------|
| 0   | 1     | Spindle enable    |
| 1   | 2     | Spindle direction |
| 2   | 4     | PWM               |

> **Reboot required** after changing this setting.

---

### `$30` — Maximum spindle speed (`RPM`)

Maximum spindle speed. Can be overridden by spindle plugins.

---

### `$31` — Minimum spindle speed (`RPM`)

Minimum spindle speed. Can be overridden by spindle plugins. When set > 0, `$35` (PWM min value) may need to be adjusted to achieve the configured RPM.

---

### `$32` — Mode of operation

| Value | Mode       |
|-------|------------|
| 0     | Normal     |
| 1     | Laser mode |
| 2     | Lathe mode |

- **Laser mode**: consecutive G1/2/3 commands will not halt when spindle speed changes.
- **Lathe mode**: enables G7, G8, G96, and G97.

---

### `$33` — Spindle PWM frequency (`Hz`)

Spindle PWM frequency.

---

### `$34` — Spindle PWM off value (`%`, max: 100)

Spindle PWM off value (duty cycle percentage).

---

### `$35` — Spindle PWM min value (`%`, max: 100)

Spindle PWM minimum value (duty cycle percentage).

---

### `$36` — Spindle PWM max value (`%`, max: 100)

Spindle PWM maximum value (duty cycle percentage).

---

### `$392` — Spindle on delay (`s`, range: 0.5–20)

Delay to allow spindle to spin up after safety door closes or on resume from park.

---

### `$394` — Spindle on delay (`s`, range: 0.5–20)

Delay to allow spindle to spin up. If spindle supports "at speed" detection, this is the timeout before alarm 14 is raised.

---

### `$539` — Spindle off delay (`s`, range: 0.5–20)

Delay to allow spindle to spin down. If spindle supports "at speed" detection, this is the timeout before alarm 14 is raised.

---

## Operational Settings

### `$5` — Invert limit inputs (`axismask`)

Inverts the axis limit input signals.

---

### `$6` — Invert probe inputs (`bitfield`)

| Bit | Value | Description |
|-----|-------|-------------|
| 0   | 1     | Probe       |

Inverts the probe input signal(s).

---

### `$8` — Ganged axes direction invert (`bitfield`)

| Bit | Value | Description |
|-----|-------|-------------|
| 0   | 1     | X-Axis      |
| 1   | 2     | Y-Axis      |

Inverts direction signals for the second motor on ganged axes. Applied in addition to `$3`.

---

### `$10` — Status report options (`bitfield`)

| Bit | Value | Description                    |
|-----|-------|--------------------------------|
| 0   | 1     | Position in machine coordinate |
| 1   | 2     | Buffer state                   |
| 2   | 4     | Line numbers                   |
| 3   | 8     | Feed & speed                   |
| 4   | 16    | Pin state                      |
| 5   | 32    | Work coordinate offset         |
| 6   | 64    | Overrides                      |
| 7   | 128   | Probe coordinates              |
| 8   | 256   | Buffer sync on WCO change      |
| 9   | 512   | Parser state                   |
| 10  | 1024  | Alarm substatus                |
| 11  | 2048  | Run substatus                  |
| 12  | 4096  | Enable when homing             |
| 13  | 8192  | Distance-to-go                 |

> Parser state is sent separately after the status report and only on changes.
> Run substatus may be used for simple probe protection.

---

### `$11` — Junction deviation (`mm`)

Sets how fast grblHAL travels through consecutive motions. Lower value slows it down.

---

### `$12` — Arc tolerance (`mm`)

Sets the G2/G3 arc tracing accuracy based on radial error.

> Very small values may affect performance.

---

### `$13` — Report in inches (`boolean`)

Enables inch units when returning position and rate values (not settings values).

---

### `$15` — Invert coolant outputs (`bitfield`)

| Bit | Value | Description |
|-----|-------|-------------|
| 0   | 1     | Flood       |
| 1   | 2     | Mist        |

Inverts coolant and mist signals (active low).

---

### `$18` — Pullup disable limit inputs (`axismask`)

Disables limit signal pullup resistors. Potentially enables pulldown resistors if available.

---

### `$19` — Pullup disable probe inputs (`bitfield`)

| Bit | Value | Description |
|-----|-------|-------------|
| 0   | 1     | Probe       |

Disables probe signal pullup resistor(s). Potentially enables pulldown resistor(s) if available.

---

### `$20` — Soft limits enable (`boolean`)

Enables soft limit checks within machine travel. Triggers alarm when exceeded. Requires homing.

---

### `$21` — Hard limits enable (`bitfield`)

| Bit | Value | Description |
|-----|-------|-------------|
| 0   | 1     | Enable      |
| 1   | 2     | Strict mode |

When enabled, immediately halts motion and raises an alarm when a limit switch triggers. In strict mode, only homing is possible when a switch is engaged.

---

### `$60` — Restore overrides (`boolean`)

Restores overrides to default values at program end.

---

### `$61` — Safety door options (`bitfield`)

| Bit | Value | Description                     |
|-----|-------|---------------------------------|
| 1   | 2     | Keep coolant state on door open |

---

### `$62` — Sleep enable (`boolean`)

Enables sleep mode.

---

### `$63` — Feed hold actions (`bitfield`)

| Bit | Value | Description                                 |
|-----|-------|---------------------------------------------|
| 0   | 1     | Disable laser during hold                   |
| 1   | 2     | Restore spindle and coolant state on resume |

---

### `$64` — Force init alarm (`boolean`)

Start in alarm mode after a cold reset.

---

### `$65` — Probing options (`bitfield`)

| Bit | Value | Description         |
|-----|-------|---------------------|
| 0   | 1     | Allow feed override |
| 1   | 2     | Apply soft limits   |

Allow feed override during probing and/or limit probing to machine workspace for homed axes.

---

## Homing & Limits

### `$22` — Homing cycle (`bitfield`)

| Bit | Value | Description                                  |
|-----|-------|----------------------------------------------|
| 0   | 1     | Enable                                       |
| 1   | 2     | Enable single axis commands                  |
| 2   | 4     | Homing on startup required                   |
| 3   | 8     | Set machine origin to 0                      |
| 4   | 16    | Two switches share one input                 |
| 5   | 32    | Allow manual                                 |
| 6   | 64    | Override locks                               |
| 9   | 512   | Per axis feedrates                           |
| 10  | 1024  | Run startup scripts only on homing completed |

Enables the homing cycle. Requires limit switches on axes to be automatically homed.

- *Enable single axis commands*: allows `$H<axis>` commands for individual axis homing.
- *Allow manual*: axes not auto-homed may be homed manually via `$H` or `$H<axis>`.
- *Override locks*: allows a soft reset to disable "Homing on startup required".

---

### `$23` — Homing direction invert (`axismask`)

Homing searches in the positive direction by default. Set an axis bit to search in the negative direction.

---

### `$24` — Homing locate feed rate (`mm/min`)

Feed rate to slowly engage the limit switch to determine its location accurately.

---

### `$25` — Homing search seek rate (`mm/min`)

Seek rate to quickly find the limit switch before the slower locating phase.

---

### `$26` — Homing switch debounce delay (`ms`)

Short delay between homing cycle phases to let the switch debounce.

---

### `$27` — Homing switch pull-off distance (`mm`)

Retract distance after triggering the switch to disengage it. Homing will fail if the switch isn't cleared.

---

### `$43` — Homing passes (range: 1–128)

Number of homing passes.

---

### `$44` — Axes homing, first phase (`axismask`)

Axes to home in the first phase.

---

### `$45` — Axes homing, second phase (`axismask`)

Axes to home in the second phase.

---

### `$46` — Axes homing, third phase (`axismask`)

Axes to home in the third phase.

---

### `$338` — Trinamic driver (`axismask`)

Enable SPI or UART controlled Trinamic drivers for axes.

---

### `$339` — Sensorless homing (`axismask`)

Enable sensorless homing for axes. Requires SPI or UART controlled Trinamic drivers.

---

## Parking

### `$41` — Parking cycle (`bitfield`)

| Bit | Value | Description                    |
|-----|-------|--------------------------------|
| 0   | 1     | Enable                         |
| 1   | 2     | Deactivate upon init           |
| 2   | 4     | Enable parking override control|

Enables parking cycle. Requires parking axis to be homed.

---

### `$42` — Parking axis

| Value | Axis |
|-------|------|
| 0     | X    |
| 1     | Y    |
| 2     | Z    |

Defines which axis performs the parking motion.

---

### `$56` — Parking pull-out distance (`mm`)

Spindle pull-out and plunge distance (incremental).

---

### `$57` — Parking pull-out rate (`mm/min`)

Spindle pull-out/plunge slow feed rate.

---

### `$58` — Parking target (`mm`, min: -100000)

Parking axis target in machine coordinates `[-max_travel, 0]`.

---

### `$59` — Parking fast rate (`mm/min`)

Parking fast rate to target after pull-out.

---

## Axis Configuration

### Steps per mm

| Setting | Axis                                   |
|---------|----------------------------------------|
| `$100`  | X-axis travel resolution (`step/mm`)   |
| `$101`  | Y-axis travel resolution (`step/mm`)   |
| `$102`  | Z-axis travel resolution (`step/mm`)   |

---

### Maximum rate

| Setting | Axis                              |
|---------|-----------------------------------|
| `$110`  | X-axis maximum rate (`mm/min`)    |
| `$111`  | Y-axis maximum rate (`mm/min`)    |
| `$112`  | Z-axis maximum rate (`mm/min`)    |

Used as G0 rapid rate.

---

### Acceleration

| Setting | Axis                               |
|---------|------------------------------------|
| `$120`  | X-axis acceleration (`mm/sec²`)    |
| `$121`  | Y-axis acceleration (`mm/sec²`)    |
| `$122`  | Z-axis acceleration (`mm/sec²`)    |

Used for motion planning to avoid exceeding motor torque and losing steps.

---

### Maximum travel

| Setting | Axis                            |
|---------|---------------------------------|
| `$130`  | X-axis maximum travel (`mm`)    |
| `$131`  | Y-axis maximum travel (`mm`)    |
| `$132`  | Z-axis maximum travel (`mm`)    |

Maximum axis travel distance from homing switch. Determines valid machine space for soft limits and homing search distances.

---

### Dual axis offset

| Setting | Axis                           | Range     |
|---------|--------------------------------|-----------|
| `$170`  | X-axis dual axis offset (`mm`) | -10 – 10  |
| `$171`  | Y-axis dual axis offset (`mm`) | -10 – 10  |
| `$172`  | Z-axis dual axis offset (`mm`) | -10 – 10  |

Offset between sides to compensate for homing switch inaccuracies.

---

## Trinamic Driver Settings

### Motor current (RMS)

| Setting | Axis                        | Range   |
|---------|-----------------------------|---------|
| `$140`  | X-axis motor current (`mA`) | 0–3045  |
| `$141`  | Y-axis motor current (`mA`) | 0–3045  |
| `$142`  | Z-axis motor current (`mA`) | 0–3045  |

---

### Microsteps

| Setting | Axis                         | Range  |
|---------|------------------------------|--------|
| `$150`  | X-axis microsteps (`steps`)  | 1–256  |
| `$151`  | Y-axis microsteps (`steps`)  | 1–256  |
| `$152`  | Z-axis microsteps (`steps`)  | 1–256  |

Microsteps per full step.

---

### Hold current

| Setting | Axis                       | Range  |
|---------|----------------------------|--------|
| `$210`  | X-axis hold current (`%`)  | 5–100  |
| `$211`  | Y-axis hold current (`%`)  | 5–100  |
| `$212`  | Z-axis hold current (`%`)  | 5–100  |

Motor current at standstill as a percentage of full current.

---

### StallGuard2 — Fast threshold (seek phase)

| Setting | Axis                              | Range   |
|---------|-----------------------------------|---------|
| `$200`  | X-axis StallGuard2 fast threshold | -64–63  |
| `$201`  | Y-axis StallGuard2 fast threshold | -64–63  |
| `$202`  | Z-axis StallGuard2 fast threshold | -64–63  |

StallGuard threshold for the fast (seek) homing phase.

---

### StallGuard2 — Slow threshold (feed phase)

| Setting | Axis                              | Range   |
|---------|-----------------------------------|---------|
| `$220`  | X-axis StallGuard2 slow threshold | -64–63  |
| `$221`  | Y-axis StallGuard2 slow threshold | -64–63  |
| `$222`  | Z-axis StallGuard2 slow threshold | -64–63  |

StallGuard threshold for the slow (feed) homing phase.

---

## Tool Change

### `$341` — Tool change mode

| Value | Mode                          |
|-------|-------------------------------|
| 0     | Normal                        |
| 1     | Manual touch off              |
| 2     | Manual touch off @ G59.3      |
| 3     | Automatic touch off @ G59.3   |
| 4     | Ignore M6                     |

- **Normal**: allows jogging for manual touch off; set new position manually.
- **Manual touch off**: rapids to tool change position; use jogging or `$TPW` for touch off.
- **Manual touch off @ G59.3**: rapids to tool change position, then to G59.3 for manual touch off.
- **Automatic touch off @ G59.3**: rapids to tool change position, then to G59.3 for automatic touch off.

---

### `$342` — Tool change probing distance (`mm`)

Maximum probing distance for automatic or `$TPW` touch off.

---

### `$343` — Tool change locate feed rate (`mm/min`)

Feed rate to slowly engage the tool change sensor to determine offset accurately.

---

### `$344` — Tool change search seek rate (`mm/min`)

Seek rate to quickly find the tool change sensor before the slower locating phase.

---

### `$345` — Tool change probe pull-off rate (`mm/min`)

Pull-off rate for the retract move before the slower locating phase.

---

### `$346` — Tool change options (`bitfield`)

| Bit | Value | Description               |
|-----|-------|---------------------------|
| 0   | 1     | Restore position after M6 |
| 1   | 2     | Change tool at G30        |
| 2   | 4     | Fast probe pull off       |

- *Restore position after M6*: moves spindle so the tool tip returns to pre-M6 position; otherwise moves only to Z home.
- *Change tool at G30*: rapids to G30 position via tool axis home (requires homed axes).
- *Fast probe pull off*: uses G38.4-style probing for faster touch off.

---

### `$347` — Dual axis length fail (`%`, range: 0–100)

Dual axis length fail threshold as a percentage of axis max travel.

---

### `$348` — Dual axis length fail min (`mm`)

Dual axis length fail minimum distance.

---

### `$349` — Dual axis length fail max (`mm`)

Dual axis length fail maximum distance.

---

## I/O Ports

### `$370` — Invert I/O port inputs (`bitfield`)

| Bit | Value | Description |
|-----|-------|-------------|
| 0   | 1     | Aux 0       |
| 2   | 4     | Aux 2       |
| 3   | 8     | Aux 3       |
| 4   | 16    | Aux 4       |

---

### `$372` — Invert I/O port outputs (`bitfield`)

| Bit | Value | Description |
|-----|-------|-------------|
| 5   | 32    | Aux 5       |
| 6   | 64    | Aux 6       |

---

## System Settings

### `$28` — G73 Retract distance (`mm`)

G73 retract distance for chip-breaking drilling.

---

### `$384` — Disable G92 persistence (`boolean`)

Disables save/restore of G92 offset to non-volatile storage (NVS).

---

### `$393` — Coolant on delay (`s`, range: 0.5–20)

Delay to allow coolant to restart after safety door closes or on resume from park.

---

### `$398` — Planner buffer blocks (range: 30–1000)

Number of blocks in the planner buffer.

> **Reboot required** after changing this setting.

---

### `$481` — Autoreport interval (`ms`, range: 100–1000)

Interval at which the real-time report is sent. Set to `0` to disable.

> **Reboot required** after changing this setting.

---

### `$485` — Keep tool number over reboot (`boolean`)

Retains the current tool number across reboots.

---

### `$486` — Lock coordinate systems (`bitfield`)

| Bit | Value | Description |
|-----|-------|-------------|
| 0   | 1     | G59.1       |
| 1   | 2     | G59.2       |
| 2   | 4     | G59.3       |

Locks coordinate systems against accidental changes.

---

### `$650` — File system options (`bitfield`)

| Bit | Value | Description          |
|-----|-------|----------------------|
| 0   | 1     | Auto mount SD card   |
| 2   | 4     | Hierarchical listing |

Auto mount SD card on startup.

---

### `$673` — Coolant on delay (`s`, range: 0.5–20)

Delay to allow coolant to start (0 or 0.5–20 s).

---

### `$676` — Reset actions (`bitfield`)

| Bit | Value | Description                             |
|-----|-------|-----------------------------------------|
| 0   | 1     | Clear homed status if position was lost |
| 1   | 2     | Clear offsets (except G92)              |
| 2   | 4     | Clear rapids override                   |
| 3   | 8     | Clear feed override                     |

Controls actions taken on a soft reset.

---

### `$700` — Subroutine options (`bitfield`)

| Bit | Value | Description                          |
|-----|-------|--------------------------------------|
| 0   | 1     | Prescan for internal M98 subroutines |
