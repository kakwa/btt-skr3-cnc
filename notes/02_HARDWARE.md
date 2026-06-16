# BTT SKR 3 Wiring Guide for grblHAL

This document describes the complete wiring for the BTT SKR 3 board running grblHAL with TMC5160 drivers and dual ganged X/Y axes.

**After wiring, see [TESTING_TROUBLESHOOTING.md](TESTING_TROUBLESHOOTING.md) for testing procedures and troubleshooting.**

## Configuration Overview

- **Board:** BTT SKR 3 (STM32H723VG)
- **Firmware:** grblHAL
- **Drivers:** TMC5160 (UART mode)
- **Axes:** X (ganged), Y (ganged), Z
- **Total Motors:** 5 (X, X2 on E0, Y, Y2 on E1, Z)

## Table of Contents

1. [Stepper Motors & Drivers](#stepper-motors--drivers)
2. [Limit Switches](#limit-switches)
3. [Control Buttons](#control-buttons)
4. [Probe](#probe)
5. [Spindle](#spindle)
6. [Pin Reference Tables](#pin-reference-tables)
7. [grblHAL Pin Function Reference](#grblhal-pin-function-reference)

---

## Stepper Motors & Drivers

### Motor Assignments

| Axis | Driver Socket | grblHAL Name | Motor Function |
|------|---------------|--------------|----------------|
| X    | X             | X            | Primary X motor |
| X2   | E0            | M3           | Ganged X motor (auto-squaring) |
| Y    | Y             | Y            | Primary Y motor |
| Y2   | E1            | M4           | Ganged Y motor (auto-squaring) |
| Z    | Z             | Z            | Z axis motor |

### TMC5160 Driver Installation

**UART Mode Configuration:**

The BTT SKR 3 must be configured for UART mode to communicate with TMC5160 drivers:

1. **Install jumpers for UART mode:**
   - Place jumpers on the UART pins (PDN_UART) for each driver socket
   - Remove any SPI jumpers if present
   - Check BTT SKR 3 documentation for exact jumper positions

2. **Driver orientation:**
   - Install drivers with correct orientation (check silkscreen/notch)
   - Ensure good contact in socket

3. **Driver address configuration:**
   - TMC5160 in UART mode: drivers share same UART line
   - Address is selected via MS1/MS2 pins (handled by board)
   - Each socket has unique address configuration

**UART Jumper Settings (BTT SKR 3):**

Each TMC driver socket has jumper positions near it. For UART mode:

```
UART Mode Configuration:
========================

For each driver socket (X, Y, Z, E0, E1):

   [PDN_UART]     ← Install jumper HERE for UART mode
   [  ]  [  ]     ← Remove SPI jumpers (if any)
   
Where to find jumpers:
- Located next to each driver socket
- Usually labeled "UART" or "PDN_UART"
- May be under or next to the driver itself
- Check board silkscreen for exact positions

Jumper Installation:
1. X socket:  Install PDN_UART jumper
2. Y socket:  Install PDN_UART jumper
3. Z socket:  Install PDN_UART jumper
4. E0 socket: Install PDN_UART jumper
5. E1 socket: Install PDN_UART jumper

All 5 driver sockets must have UART jumpers installed!
```

**Important:** The BTT SKR 3 board may have different jumper configurations depending on revision. Consult the [BTT SKR 3 manual](https://github.com/bigtreetech/SKR-3/blob/master/Hardware/BTT%20SKR%203-Size.pdf) for your specific board version.

**Current Settings:**
Configure via grblHAL settings (not via driver potentiometers in UART mode):
```
$140 = X axis current (mA)
$141 = Y axis current (mA) 
$142 = Z axis current (mA)
$143 = M3/E0 axis current (mA)
$144 = M4/E1 axis current (mA)
```

**Motor Connections:**
Standard 4-wire stepper motors connect directly to the driver sockets. Ensure proper wire pairing (A+/A- and B+/B-).

### TMC5160 UART Wiring (Internal)

These connections are handled by the board PCB - no user wiring needed:

| Driver Socket | UART Pin | MCU Pin | Notes |
|---------------|----------|---------|-------|
| X             | PDN_UART | GPIOD pin 5 (PD5) | Single wire UART |
| Y             | PDN_UART | GPIOD pin 0 (PD0) | Single wire UART |
| Z             | PDN_UART | GPIOE pin 1 (PE1) | Single wire UART |
| E0 (M3)       | PDN_UART | GPIOC pin 6 (PC6) | Single wire UART |
| E1 (M4)       | PDN_UART | GPIOD pin 12 (PD12) | Single wire UART |

**How UART Mode Works:**
- Single-wire bidirectional communication
- MCU can read/write driver registers
- Allows advanced features: StallGuard, CoolStep, etc.
- Lower CPU overhead than SPI for basic operation

### TMC5160 Advanced Features (UART Mode)

With UART mode enabled, you can access advanced TMC5160 features via grblHAL settings:

**StallGuard (Sensorless Homing):**
- Detect motor stall without limit switches
- Configure threshold via grblHAL settings
- Can replace or supplement physical limit switches

**CoolStep (Automatic Current Reduction):**
- Reduces current when motor load is low
- Saves power and reduces heat
- Automatically adjusts in real-time

**SpreadCycle vs StealthChop:**
- SpreadCycle: Higher torque, audible noise
- StealthChop: Silent operation, lower torque
- Configurable per axis via grblHAL

**Driver Monitoring:**
- Read driver temperature
- Monitor motor load
- Detect stall conditions
- Check for driver errors

**Configuration via grblHAL:**
```
$338 = TMC driver settings (bitmask)
$339 = TMC StallGuard threshold
$340-$344 = Per-axis TMC configuration
```

---

## Limit Switches

### Switch Type

Use **Normally Open (NO)** limit switches for all axes.

### Wiring

Each limit switch connects between the limit pin and GND:

```
Limit Switch (NO)
┌─────────┐
│    NO   │──── Limit Input Pin
│         │
│   COM   │──── GND
└─────────┘
```

### Limit Switch Connections

| Axis | Connector/Terminal | MCU Pin | Notes |
|------|-------------------|---------|-------|
| X-   | X-MIN             | GPIOC pin 1 (PC1) | Primary X limit |
| X2-  | E0-DIAG           | GPIOC pin 2 (PC2) | Ganged X limit (for auto-squaring) |
| Y-   | Y-MIN             | GPIOC pin 3 (PC3) | Primary Y limit |
| Y2-  | **PWRDET pin 3**  | GPIOC pin 15 (PC15) | Ganged Y limit (see note below) |
| Z-   | Z-MIN             | GPIOC pin 0 (PC0) | Z axis limit |

**Important Note for Y2 Limit (E1):**
The E1 limit switch uses PC15 instead of the normal PA0 (pin conflict). You must connect a jumper wire from **PWRDET connector pin 3** to the **DIAG pin on the E1 TMC driver** if using TMC driver DIAG output. Otherwise, wire your limit switch directly to PWRDET pin 3.

### Auto-Squaring

With X_AUTO_SQUARE and Y_AUTO_SQUARE enabled:
- X and X2 motors can be independently controlled during homing
- Y and Y2 motors can be independently controlled during homing
- System will automatically square the axes if they're misaligned

**Homing sequence:**
1. Both motors move together toward limits
2. First motor to hit limit stops
3. Second motor continues until it hits its limit
4. System records any offset and compensates during operation

---

## Control Buttons

All control inputs should use **Normally Closed (NC)** buttons/switches.

### E-STOP (Reset/Halt)

**Location:** EXP2 connector, pin 7 (GPIOA pin 4)

**Wiring:**
```
E-STOP Button (NC)
┌─────────┐
│    NC   │──── EXP2 pin 7 (PA4)
│         │
│   COM   │──── GND
└─────────┘
```

**Operation:**
- Normal: Button closed → Pin connected to GND → System runs
- Emergency: Button pressed → Opens circuit → System halts immediately

### Feed Hold (Optional)

**Location:** EXP2 connector, pin 9 (GPIOA pin 5)

**Wiring:** Same as E-STOP (NC button to GND)

**Note:** Currently commented out in `my_machine.h`. Uncomment `CONTROL_FEED_HOLD` to enable.

### Cycle Start (Optional)

**Location:** EXP2 connector, pin 10 (GPIOA pin 6)

**Wiring:** Same as E-STOP (NC button to GND)

**Note:** Currently commented out in `my_machine.h`. Uncomment `CONTROL_CYCLE_START` to enable.

### EXP2 Connector Pinout

```
EXP2 Pinout (common control connector):
┌─────────────────┐
│ 1  2  3  4  5   │
│ 6  7  8  9  10  │
└─────────────────┘

Pin 5:  Safety Door (PA7) - not configured
Pin 7:  E-STOP/Reset (PA4) ✓ ENABLED
Pin 9:  Feed Hold (PA5) - not configured
Pin 10: Cycle Start (PA6) - not configured
```

---

## Probe

### Z Probe Connection

**Location:** Dedicated probe input (GPIOC pin 13)

**Wiring:**
```
Touch Probe (NO)
┌─────────┐
│    NO   │──── Probe Input (PC13)
│         │
│   COM   │──── GND
└─────────┘
```

**Probe Input Pin:** Check the board silkscreen for "PROBE" or "Z-PROBE" connector

**Operation:**
- Use a normally open (NO) probe
- When probe touches workpiece, it connects to GND
- grblHAL detects the connection and stops Z motion

**Common Probe Types:**
- Touch probe with NC/NO contacts
- Tool length sensor
- Bed probe/3D printer style probe

---

## Spindle

### Spindle Control Method Selection

**Two spindle control methods available:**

| Method | Pros | Cons | Best For |
|--------|------|------|----------|
| **PWM** (current) | Simple wiring, works with most controllers, no additional hardware | Less precise speed control, no spindle feedback | Basic spindles, AC routers, simple VFDs |
| **Modbus RS-485** | Precise speed control, spindle status/errors feedback, advanced features | Requires RS-485 hardware, disables USB CDC debug, VFD-specific config | Professional VFD spindles, closed-loop control |

### PWM Spindle Control (Current Configuration)

Your configuration uses PWM spindle control with enable and direction signals.

| Function | Connector | MCU Pin | Notes |
|----------|-----------|---------|-------|
| PWM      | EXP1 pin 9 | GPIOB pin 0 (PB0) | Speed control (0-100%) |
| Enable   | FAN1       | GPIOB pin 6 (PB6) | On/Off control |
| Direction | FAN2      | GPIOB pin 5 (PB5) | CW/CCW (M3/M4) |

### PWM Spindle Wiring

**For VFD Spindle:**
```
BTT SKR 3          →  VFD/Spindle Controller
─────────────────────────────────────────────
PWM (EXP1 pin 9)   →  0-10V or PWM input
Enable (FAN1)      →  Enable/Run input
Direction (FAN2)   →  Forward/Reverse input
GND                →  Common ground
```

**For Relay-Controlled Spindle:**
```
BTT SKR 3          →  Relay Module
─────────────────────────────────────────────
Enable (FAN1)      →  Relay trigger
GND                →  Relay GND
```

### VFD via Modbus/RS-485 (Alternative)

To use VFD control via Modbus/RS-485, you can use either UART port on the BTT SKR 3.

**Serial Port Options:**

| Port | Location | Pins | Trade-off |
|------|----------|------|-----------|
| **SERIAL (option 0)** | TFT header | PA9/PA10 | Disables USB CDC debug on TFT header |
| **SERIAL1 (option 1)** | ESP-32 header | PD8/PD9 | Preferred - keeps TFT header for debug |

**Hardware Required:**
- RS-485 transceiver module (e.g., MAX485, MAX3485)
- Connect to chosen UART header on BTT SKR 3

**Firmware Configuration:**

Uncomment in `my_machine.h`:
```c
#define MODBUS_RTU_STREAM   1                   // 0 = TFT header, 1 = ESP-32 header (recommended)
#define MODBUS_ENABLE       1                   // 1 = auto direction, 2 = manual
#define SPINDLE0_ENABLE     SPINDLE_HUANYANG1   // Or SPINDLE_HUANYANG2, SPINDLE_GS20, etc.
```

**Recommendation:** Use `MODBUS_RTU_STREAM 1` (ESP-32 header) to keep the TFT header available for debugging.

**RS-485 Wiring:**

**Option 1: Using TFT Header (MODBUS_RTU_STREAM = 0)**
```
BTT SKR 3 (TFT Header)    →    RS-485 Transceiver    →    VFD
────────────────────────────────────────────────────────────────
PA9 (TX)                  →    DI (Data In)
PA10 (RX)                 →    RO (Receiver Out)
GND                       →    GND                    →    GND
                               A                      →    A/D+
                               B                      →    B/D-
```

**Option 2: Using ESP-32 Header (MODBUS_RTU_STREAM = 1, Recommended)**
```
BTT SKR 3 (ESP-32 Header) →    RS-485 Transceiver    →    VFD
────────────────────────────────────────────────────────────────
PD8 (TX)                  →    DI (Data In)
PD9 (RX)                  →    RO (Receiver Out)
GND                       →    GND                    →    GND
                               A                      →    A/D+
                               B                      →    B/D-
```

**RS-485 Transceiver Connections:**

| BTT SKR 3 | RS-485 Module | VFD Terminal | Notes |
|-----------|---------------|--------------|-------|
| TX (PA9 or PD8) | DI      | -            | Transmit data |
| RX (PA10 or PD9) | RO     | -            | Receive data |
| GND       | GND           | RS-485 GND   | Common ground |
| (optional)| DE/RE         | -            | Only if MODBUS_ENABLE=2 |
| -         | A             | RS485+ / D+  | Data line A |
| -         | B             | RS485- / D-  | Data line B |

**MODBUS_ENABLE Options:**

- **Mode 1 (Auto Direction):** RS-485 transceiver automatically switches between TX/RX
  - Use with modules that have automatic direction control
  - Most common and simplest setup
  
- **Mode 2 (Manual Direction):** Requires external direction control signal
  - Need to wire DE/RE pins to auxiliary output
  - Use if transceiver requires manual TX/RX enable

**Supported VFD Protocols:**
- `SPINDLE_HUANYANG1` / `SPINDLE_HUANYANG2` - Huanyang VFDs (common Chinese VFDs)
- `SPINDLE_GS20` - GS20 VFD
- `SPINDLE_YL620` - Yalang YL620 VFD
- `SPINDLE_MODVFD` - Generic Modbus VFD (configurable via settings)
- `SPINDLE_H100` - H-100 VFD
- `SPINDLE_NOWFOREVER` - NowForever VFD

**Complete Configuration Example:**

Edit `my_machine.h`:
```c
// Use ESP-32 header for Modbus (recommended)
#define MODBUS_RTU_STREAM   1                   // 1 = ESP-32 header (PD8/PD9)
#define MODBUS_ENABLE       1                   // 1 = auto direction
#define SPINDLE0_ENABLE     SPINDLE_HUANYANG1   // Huanyang VFD

// Disable PWM spindle (can't use both)
// Comment out or remove these:
// #define DRIVER_SPINDLE_ENABLE 1
// #define SPINDLE_PWM           1
```

Then rebuild and reflash:
```bash
skr3-build
skr3-flash
```

After flashing, configure VFD settings via grblHAL:
```bash
$384=19200      # Modbus baud rate (match your VFD)
$386=1          # Modbus slave address (usually 1)
$30=24000       # Max spindle RPM
```

See grblHAL documentation for VFD-specific configuration and parameters.

---

### Control Inputs

| Function | Port/Pin | Connector | Type | Notes |
|----------|----------|-----------|------|-------|
| E-STOP   | PA4      | EXP2 pin 7 | NC to GND | **ACTIVE** - must be wired |
| Feed Hold | PA5     | EXP2 pin 9 | NC to GND | Not configured |
| Cycle Start | PA6   | EXP2 pin 10 | NC to GND | Not configured |
| Safety Door | PA7   | EXP2 pin 5 | NC to GND | Not configured |
| Probe    | PC13     | Probe connector | NO to GND | Touch probe input |

### Output Pins

| Function | Port/Pin | Connector | Usage |
|----------|----------|-----------|-------|
| Spindle PWM | PB0   | EXP1 pin 9 | Speed control |
| Spindle Enable | PB6 | FAN1 | On/Off |
| Spindle Dir | PB5   | FAN2 | CW/CCW |
| Coolant Flood | PB3 | HEAT0 | M8/M9 |
| Coolant Mist | PB4  | HEAT1 | M7/M9 |

### Communication Ports

| Port | Stream ID | TX Pin | RX Pin | Connector | Default Usage | Modbus Option |
|------|-----------|--------|--------|-----------|---------------|---------------|
| SERIAL  | 0 | PA9  | PA10   | TFT header | USB CDC / Debug | `MODBUS_RTU_STREAM 0` (disables USB CDC) |
| SERIAL1 | 1 | PD8  | PD9    | ESP-32 header | WiFi module (optional) | `MODBUS_RTU_STREAM 1` (recommended for Modbus) |

**Modbus Configuration Notes:**
- Set `MODBUS_RTU_STREAM` to the Stream ID of the port you want to use
- **Stream 0 (TFT header):** Disables USB CDC debug when Modbus is enabled
- **Stream 1 (ESP-32 header):** Recommended - keeps TFT header available for debugging
- When `MODBUS_ENABLE` is set without specifying `MODBUS_RTU_STREAM`, the default behavior is undefined

---

## Testing and Troubleshooting

For complete testing procedures, troubleshooting guides, and safety information, see:

**[TESTING_TROUBLESHOOTING.md](TESTING_TROUBLESHOOTING.md)**

This separate guide includes:
- Pre-power-on wiring checklist
- Step-by-step initial testing sequence
- Comprehensive troubleshooting for common issues
- Safety notes and emergency procedures
- Additional resources and command reference

---

## Quick Reference

### Essential Before First Power-On

- [ ] **UART jumpers installed** on all 5 driver sockets
- [ ] **E-STOP wired** (NC button, EXP2 pin 7 to GND)
- [ ] **Firmware flashed** with TRINAMIC_UART_ENABLE=1
- [ ] All motors and switches connected
- [ ] Power polarity verified

### First Commands to Run

```bash
?       # Check status (should not show ESTOP)
$$      # List all settings
$I      # Verify TMC5160 drivers detected
$X      # Unlock if in alarm state
```

See [TESTING_TROUBLESHOOTING.md](TESTING_TROUBLESHOOTING.md) for complete testing procedures.

---

## grblHAL Pin Function Reference

Logical pin ids (`pin_function_t`), display names (`pin_names[]` in [`grbl/crossbar.h`](../grbl/crossbar.h)), and typical board symbols. Map: [`Inc/driver.h`](../Inc/driver.h) → `boards/*_map.h`; features: [`my_machine.h`](../my_machine.h), [`grbl/driver_opts.h`](../grbl/driver_opts.h). **`PREFIX_*`** means `PREFIX_PORT` + `PREFIX_PIN` (GPIO port + pin number). **scan** = claims a free digital aux in at runtime ([`grbl/pin_bits_masks.h`](../grbl/pin_bits_masks.h) `add_aux_input_scan`). **STM32** = this repo [`Src/driver.c`](../Src/driver.c) / [`Src/driver_spindles.c`](../Src/driver_spindles.c); **—** = not in STM32 `inputpin[]`/`outputpin[]` here (other port, plugin, or `motor_pins.h` only).

`PIN_ISINPUT`: value `< 98` (`Output_StepX`). `PIN_ISOUTPUT`: `98…214`. `PIN_ISBIDIRECTIONAL`: `≥ 215`. Boundaries: `Outputs` = 98, `Multipin` = 193, `Bidirectional` = 215. The **Motor** section still includes ids **8–9** and **215–222** (they are inputs or bidirectional by those macros).

| Macro                      | Condition                               |
|:---------------------------|:----------------------------------------|
| `PIN_ISINPUT(pin)`         | `pin < Outputs`                         |
| `PIN_ISOUTPUT(pin)`        | `pin >= Outputs && pin < Bidirectional` |
| `PIN_ISBIDIRECTIONAL(pin)` | `pin >= Bidirectional`                  |

The first `Input_*` through `Input_Probe` match `control_signals_t` in [`grbl/nuts_bolts.h`](../grbl/nuts_bolts.h) ([`xbar_fn_to_signals_mask()`](../grbl/crossbar.c)).

Below, **`pin_function_t` is split by role** (enum order is not contiguous across sections). Values **193–214** are listed under **Inputs** when they are input roles, even though they appear after spindle/aux outputs in the enum.

---

### Inputs

Control, limits, homes, probes, aux, and bus pins that are read as GPIO (plus `Virtual_Pin`).

| Val   | Identifier                   | Display name          | Typical `#define` / note                                                           |
|------:|:-----------------------------|:----------------------|:-----------------------------------------------------------------------------------|
|     0 | `Input_Reset`                | Reset                 | `RESET_*`; `CONTROL_RESET`                                                         |
|     1 | `Input_FeedHold`             | Feed hold             | `FEED_HOLD_*`                                                                      |
|     2 | `Input_CycleStart`           | Cycle start           | `CYCLE_START_*`                                                                    |
|     3 | `Input_SafetyDoor`           | Safety door           | `SAFETY_DOOR_*`                                                                    |
|     4 | `Input_BlockDelete`          | Block delete          | scan; `BLOCK_DELETE_ENABLE`                                                        |
|     5 | `Input_StopDisable`          | Stop disable          | scan; `STOP_DISABLE_ENABLE`                                                        |
|     6 | `Input_EStop`                | Emergency stop        | `RESET_*`; `CONTROL_ESTOP`                                                         |
|     7 | `Input_ProbeDisconnect`      | Probe disconnect      | scan; `PROBE_DISCONNECT_ENABLE`                                                    |
|    10 | `Input_LimitsOverride`       | Limits override       | scan; `LIMITS_OVERRIDE_ENABLE`                                                     |
|    11 | `Input_SingleBlock`          | Single block          | scan; `SINGLE_BLOCK_ENABLE`                                                        |
|    12 | `Input_ToolsetterOvertravel` | Toolsetter overtravel | scan; `TLS_OVERTRAVEL_ENABLE`                                                      |
|    13 | `Input_ProbeOvertravel`      | Probe overtravel      | plugin / feature                                                                   |
|    14 | `Input_Probe`                | Probe                 | `PROBE_*`; `PROBE_ENABLE`                                                          |
|    27 | `Input_Probe2`               | Probe 2               | `PROBE2_*` or aux pool; `PROBE2_ENABLE`                                            |
|    28 | `Input_Probe2Overtravel`     | Probe 2 overtravel    | plugin / feature                                                                   |
|    29 | `Input_Toolsetter`           | Toolsetter            | `TOOLSETTER_*` or aux pool                                                         |
|    30 | `Input_MPGSelect`            | MPG mode select       | `MPG_MODE_*`; `MPG_ENABLE==1`                                                      |
|    31 | `Input_LimitX`               | X limit min           | `X_LIMIT_*` or `LIMIT_PORT`+`X_LIMIT_PIN` ([`motor_pins.h`](../grbl/motor_pins.h)) |
|    32 | `Input_LimitX2`              | X limit min 2         | `X2_LIMIT_*`                                                                       |
|    33 | `Input_LimitX_Max`           | X limit max           | `X_LIMIT_*_MAX`                                                                    |
|    34 | `Input_HomeX`                | X home                | `X_HOME_*`; — STM32 `inputpin[]`                                                   |
|    35 | `Input_HomeX_2`              | X home 2              | `X2_HOME_*`; —                                                                     |
|    36 | `Input_LimitY`               | Y limit min           | `Y_LIMIT_*`                                                                        |
|    37 | `Input_LimitY2`              | Y limit min 2         | `Y2_LIMIT_*`                                                                       |
|    38 | `Input_LimitY_Max`           | Y limit max           | `Y_LIMIT_*_MAX`                                                                    |
|    39 | `Input_HomeY`                | Y home                | `Y_HOME_*`; —                                                                      |
|    40 | `Input_HomeY_2`              | Y home 2              | `Y2_HOME_*`; —                                                                     |
|    41 | `Input_LimitZ`               | Z limit min           | `Z_LIMIT_*`                                                                        |
|    42 | `Input_LimitZ2`              | Z limit min 2         | `Z2_LIMIT_*`                                                                       |
|    43 | `Input_LimitZ_Max`           | Z limit max           | `Z_LIMIT_*_MAX`                                                                    |
|    44 | `Input_HomeZ`                | Z home                | `Z_HOME_*`; —                                                                      |
|    45 | `Input_HomeZ_2`              | Z home 2              | `Z2_HOME_*`; —                                                                     |
|    46 | `Input_LimitA`               | A limit min           | `A_LIMIT_*`                                                                        |
|    47 | `Input_LimitA_Max`           | A limit max           | `A_LIMIT_*_MAX`                                                                    |
|    48 | `Input_HomeA`                | A home                | `A_HOME_*`; —                                                                      |
|    49 | `Input_LimitB`               | B limit min           | `B_LIMIT_*`                                                                        |
|    50 | `Input_LimitB_Max`           | B limit max           | `B_LIMIT_*_MAX`                                                                    |
|    51 | `Input_HomeB`                | B home                | `B_HOME_*`; —                                                                      |
|    52 | `Input_LimitC`               | C limit min           | `C_LIMIT_*`                                                                        |
|    53 | `Input_LimitC_Max`           | C limit max           | `C_LIMIT_*_MAX`                                                                    |
|    54 | `Input_HomeC`                | C home                | `C_HOME_*`; —                                                                      |
|    55 | `Input_LimitU`               | U limit min           | `U_LIMIT_*`                                                                        |
|    56 | `Input_LimitU_Max`           | U limit max           | `U_LIMIT_*_MAX`                                                                    |
|    57 | `Input_HomeU`                | U home                | `U_HOME_*`; —                                                                      |
|    58 | `Input_LimitV`               | V limit min           | `V_LIMIT_*`                                                                        |
|    59 | `Input_LimitV_Max`           | V limit max           | `V_LIMIT_*_MAX`                                                                    |
|    60 | `Input_HomeV`                | V home                | `V_HOME_*`; —                                                                      |
|    61 | `Input_LimitW`               | W limit min           | `W_LIMIT_*`                                                                        |
|    62 | `Input_LimitW_Max`           | W limit max           | `W_LIMIT_*_MAX`                                                                    |
|    63 | `Input_HomeW`                | W home                | `W_HOME_*`; —                                                                      |
|    64 | `Input_SpindleIndex`         | Spindle index         | `SPINDLE_INDEX_*`; `SPINDLE_SYNC_ENABLE`                                           |
|    65 | `Input_SpindlePulse`         | Spindle pulse         | `SPINDLE_PULSE_*`; timer AF; `SPINDLE_ENCODER_ENABLE`                              |
| 66–89 | `Input_Aux0`…`Input_Aux23`   | Aux in 0…23           | `AUXINPUTn_*` (STM32 table: **0–11** only); 12–23 need map+driver                  |
| 90–97 | `Input_Analog_Aux0`…7        | Aux analog in 0…7     | `AUXINPUTn_ANALOG_*` (STM32: **0–2** in `inputpin[]`)                              |
|   193 | `Input_MISO`                 | MISO                  | `SPI_PORT` / SPI pin macros                                                        |
|   199 | `Input_SdCardDetect`         | SD card detect        | `SD_DETECT_*`; `SDCARD_ENABLE`                                                     |
|   201 | `Input_SPIIRQ`               | SPI IRQ               | `SPI_IRQ_*`                                                                        |
|   204 | `Input_KeypadStrobe`         | Keypad strobe         | legacy                                                                             |
|   205 | `Input_I2CStrobe`            | I2C strobe            | `I2C_STROBE_*`                                                                     |
|   206 | `Input_RX`                   | RX                    | `SERIAL_PORT` / `SERIALn_*`                                                        |
|   210 | `Input_QEI_A`                | QEI A                 | encoder plugin                                                                     |
|   211 | `Input_QEI_B`                | QEI B                 | encoder plugin                                                                     |
|   212 | `Input_QEI_Select`           | QEI select            | `QEI_SELECT_*`                                                                     |
|   213 | `Input_QEI_Index`            | QEI index             | `QEI_INDEX_*`                                                                      |
|   214 | `Virtual_Pin`                | Virtual               | no GPIO                                                                            |

---

### Motor

Per-axis driver fault inputs, stepper motion outputs (step / dir / enable / power), driver chip-select, and single-wire **bidirectional** TMC UART (enum `≥ 215`).

| Val | Identifier                  | Display name    | Typical `#define` / note               |
|----:|:----------------------------|:----------------|:---------------------------------------|
|   8 | `Input_MotorFault`          | Motor fault     | `MOTOR_FAULT_*`                        |
|   9 | `Input_MotorWarning`        | Motor warning   | `MOTOR_WARNING_*`                      |
|  15 | `Input_MotorFaultX`         | X motor fault   | —; map e.g. `M3_MOTOR_FAULT_*`         |
|  16 | `Input_MotorFaultY`         | Y motor fault   | —                                      |
|  17 | `Input_MotorFaultZ`         | Z motor fault   | —                                      |
|  18 | `Input_MotorFaultA`         | A motor fault   | —                                      |
|  19 | `Input_MotorFaultB`         | B motor fault   | —                                      |
|  20 | `Input_MotorFaultC`         | C motor fault   | —                                      |
|  21 | `Input_MotorFaultU`         | U motor fault   | —                                      |
|  22 | `Input_MotorFaultV`         | V motor fault   | —                                      |
|  23 | `Input_MotorFaultW`         | W motor fault   | —                                      |
|  24 | `Input_MotorFaultX_2`       | X motor fault 2 | —                                      |
|  25 | `Input_MotorFaultY_2`       | Y motor fault 2 | —                                      |
|  26 | `Input_MotorFaultZ_2`       | Z motor fault 2 | —                                      |
|  98 | `Output_StepX`              | X step          | `X_STEP_*`                             |
|  99 | `Output_StepX2`             | X2 step         | `X2_STEP_*`                            |
| 100 | `Output_StepY`              | Y step          | `Y_STEP_*`                             |
| 101 | `Output_StepY2`             | Y2 step         | `Y2_STEP_*`                            |
| 102 | `Output_StepZ`              | Z step          | `Z_STEP_*`                             |
| 103 | `Output_StepZ2`             | Z2 step         | `Z2_STEP_*`                            |
| 104 | `Output_StepA`              | A step          | `A_STEP_*`; `#ifdef A_AXIS`            |
| 105 | `Output_StepB`              | B step          | `B_STEP_*`                             |
| 106 | `Output_StepC`              | C step          | `C_STEP_*`                             |
| 107 | `Output_StepU`              | U step          | `U_STEP_*`                             |
| 108 | `Output_StepV`              | V step          | `V_STEP_*`                             |
| 109 | `Output_StepW`              | W step          | `W_STEP_*`                             |
| 110 | `Output_DirX`               | X dir           | `X_DIRECTION_*`                        |
| 111 | `Output_DirX2`              | X2 dir          | `X2_DIRECTION_*`                       |
| 112 | `Output_DirY`               | Y dir           | `Y_DIRECTION_*`                        |
| 113 | `Output_DirY2`              | Y2 dir          | `Y2_DIRECTION_*`                       |
| 114 | `Output_DirZ`               | Z dir           | `Z_DIRECTION_*`                        |
| 115 | `Output_DirZ2`              | Z2 dir          | `Z2_DIRECTION_*`                       |
| 116 | `Output_DirA`               | A dir           | `A_DIRECTION_*`                        |
| 117 | `Output_DirB`               | B dir           | `B_DIRECTION_*`                        |
| 118 | `Output_DirC`               | C dir           | `C_DIRECTION_*`                        |
| 119 | `Output_DirU`               | U dir           | `U_DIRECTION_*`                        |
| 120 | `Output_DirV`               | V dir           | `V_DIRECTION_*`                        |
| 121 | `Output_DirW`               | W dir           | `W_DIRECTION_*`                        |
| 122 | `Output_MotorChipSelect`    | Motor CS        | `MOTOR_CS_*`                           |
| 123 | `Output_MotorChipSelectX`   | Motor CSX       | `MOTOR_CSX_*`                          |
| 124 | `Output_MotorChipSelectY`   | Motor CSY       | `MOTOR_CSY_*`                          |
| 125 | `Output_MotorChipSelectZ`   | Motor CSZ       | `MOTOR_CSZ_*`                          |
| 126 | `Output_MotorChipSelectM3`  | Motor CSM3      | `MOTOR_CSM3_*`                         |
| 127 | `Output_MotorChipSelectM4`  | Motor CSM4      | `MOTOR_CSM4_*`                         |
| 128 | `Output_MotorChipSelectM5`  | Motor CSM5      | `MOTOR_CSM5_*`                         |
| 129 | `Output_MotorChipSelectM6`  | Motor CSM6      | `MOTOR_CSM6_*`                         |
| 130 | `Output_MotorChipSelectM7`  | Motor CSM7      | `MOTOR_CSM7_*`                         |
| 131 | `Output_StepperPower`       | Stepper power   | `STEPPERS_POWER_*`                     |
| 132 | `Output_StepperEnable`      | Steppers enable | `STEPPERS_ENABLE_*`                    |
| 133 | `Output_StepperEnableX`     | X enable        | `X_ENABLE_*` / `X2_ENABLE_*` → same id |
| 134 | `Output_StepperEnableY`     | Y enable        | `Y_ENABLE_*` / `Y2_ENABLE_*`           |
| 135 | `Output_StepperEnableZ`     | Z enable        | `Z_ENABLE_*` / `Z2_ENABLE_*`           |
| 136 | `Output_StepperEnableA`     | A enable        | `A_ENABLE_*`                           |
| 137 | `Output_StepperEnableB`     | B enable        | `B_ENABLE_*`                           |
| 138 | `Output_StepperEnableC`     | C enable        | `C_ENABLE_*`                           |
| 139 | `Output_StepperEnableU`     | U enable        | `U_ENABLE_*`                           |
| 140 | `Output_StepperEnableV`     | V enable        | `V_ENABLE_*`                           |
| 141 | `Output_StepperEnableW`     | W enable        | `W_ENABLE_*`                           |
| 142 | `Output_StepperEnableXY`    | XY enable       | `XY_ENABLE_*`                          |
| 143 | `Output_StepperEnableAB`    | AB enable       | `AB_ENABLE_*`                          |
| 215 | `Bidirectional_MotorUARTX`  | UART X          | `MOTOR_UARTX_*`                        |
| 216 | `Bidirectional_MotorUARTY`  | UART Y          | `MOTOR_UARTY_*`                        |
| 217 | `Bidirectional_MotorUARTZ`  | UART Z          | `MOTOR_UARTZ_*`                        |
| 218 | `Bidirectional_MotorUARTM3` | UART M3         | `MOTOR_UARTM3_*`                       |
| 219 | `Bidirectional_MotorUARTM4` | UART M4         | `MOTOR_UARTM4_*`                       |
| 220 | `Bidirectional_MotorUARTM5` | UART M5         | `MOTOR_UARTM5_*`                       |
| 221 | `Bidirectional_MotorUARTM6` | UART M6         | — in STM32 `driver.c` (crossbar only)  |
| 222 | `Bidirectional_MotorUARTM7` | UART M7         | —                                      |

---

### Outputs

Spindle, coolant, general-purpose aux, LEDs, coprocessor, and bus pins driven out (or I2C SDA).

| Val     | Identifier               | Display name          | Typical `#define` / note                    |
|--------:|:-------------------------|:----------------------|:--------------------------------------------|
|     144 | `Output_SpindleOn`       | Spindle on            | `SPINDLE_ENABLE_*`                          |
|     145 | `Output_SpindleDir`      | Spindle direction     | `SPINDLE_DIRECTION_*`                       |
|     146 | `Output_SpindlePWM`      | Spindle PWM           | `SPINDLE_PWM_*`                             |
|     147 | `Output_Spindle1On`      | Spindle 2 on          | `SPINDLE1_ENABLE_*`                         |
|     148 | `Output_Spindle1Dir`     | Spindle 2 direction   | `SPINDLE1_DIRECTION_*`                      |
|     149 | `Output_Spindle1PWM`     | Spindle 2 PWM         | `SPINDLE1_PWM_*`                            |
|     150 | `Output_CoolantMist`     | Mist                  | `COOLANT_MIST_*`                            |
|     151 | `Output_CoolantFlood`    | Flood                 | `COOLANT_FLOOD_*`                           |
| 152–175 | `Output_Aux0`…23         | Aux out 0…23          | `AUXOUTPUTn_*` (STM32 table: **0–10**)      |
| 176–183 | `Output_Analog_Aux0`…7   | Aux analog out…       | `AUXOUTPUTn_ANALOG_*` or `AUXOUTPUTn_PWM_*` |
|     184 | `Output_LED`             | LED                   | board / plugin                              |
|     185 | `Output_LED_R`           | LED R                 | board / plugin                              |
|     186 | `Output_LED_G`           | LED G                 | board / plugin                              |
|     187 | `Output_LED_B`           | LED B                 | board / plugin                              |
|     188 | `Output_LED_W`           | LED W                 | board / plugin                              |
|     189 | `Output_LED_Adressable`  | LED adressable        | board / plugin                              |
|     190 | `Output_LED1_Adressable` | LED adressable 1      | board / plugin                              |
|     191 | `Output_CoProc_Reset`    | CoProc Reset          | board / plugin                              |
|     192 | `Output_CoProc_Boot0`    | CoProc Boot0          | board / plugin                              |
|     194 | `Output_MOSI`            | MOSI                  | SPI init                                    |
|     195 | `Output_SPICLK`          | SPI CLK               | SPI init                                    |
|     196 | `Output_SPICS`           | SPI CS                | `SPI_CS_*`                                  |
|     197 | `Output_FlashCS`         | Flash CS              | board                                       |
|     198 | `Output_SdCardCS`        | SD card CS            | `SD_CS_*`                                   |
|     200 | `Output_SPIRST`          | SPI reset             | `SPI_RST_*`                                 |
|     202 | `Output_SCK`             | I2C SCK               | `I2C_PORT`; alias `Output_I2CSCK`           |
|     203 | `Bidirectional_SDA`      | I2C SDA               | I2C driver; alias `Bidirectional_I2CSDA`    |
|     207 | `Output_TX`              | TX                    | serial driver                               |
|     208 | `Output_RTS`             | RTS                   | serial                                      |
|     209 | `Output_RS485_Direction` | RS485 RX/TX direction | `RS485_DIR_*`; Modbus                       |

#### Spindle: PWM vs RS485 (Modbus VFD)

The controller can drive a spindle either from **GPIO** (PWM or simple on/off on ids **144–146**, second spindle **147–149**) or over **Modbus RTU on RS485** to a VFD. Encoder / sync uses **64** (`Input_SpindleIndex`) and **65** (`Input_SpindlePulse`) when enabled in the map.

**PWM (or on/off) — compile time**

- In [`Inc/my_machine.h`](../Inc/my_machine.h), use `SPINDLE0_ENABLE` = `SPINDLE_PWM0`, `SPINDLE_PWM0_NODIR`, `SPINDLE_ONOFF0`, or `SPINDLE_ONOFF0_DIR` (see [`grbl/spindle_control.h`](../grbl/spindle_control.h)).
- [`grbl/driver_opts.h`](../grbl/driver_opts.h) sets `DRIVER_SPINDLE_ENABLE` from `SPINDLE_ENABLE`; with `SPINDLE_PWM0`, the driver expects **`SPINDLE_ENABLE_*`**, **`SPINDLE_PWM_*`**, and optionally **`SPINDLE_DIRECTION_*`** in the board map (`SPINDLE1_*` for the second spindle).
- If **no** local PWM/on-off spindle is compiled in (`DRIVER_SPINDLE_ENABLE == 0`), outputs **144–146** are not claimed; a VFD-only build does not use those pins.

**RS485 / VFD — compile time**

- Set `SPINDLE0_ENABLE` (and optionally `SPINDLE1_ENABLE` … `SPINDLE3_ENABLE`) to a VFD type, e.g. `SPINDLE_HUANYANG1`, `SPINDLE_GS20`, `SPINDLE_YL620A`, `SPINDLE_MODVFD` (`SPINDLE_ALL_VFD` in [`grbl/spindle_control.h`](../grbl/spindle_control.h) lists them).
- [`grbl/driver_opts.h`](../grbl/driver_opts.h) turns on **`VFD_ENABLE`** and, unless you override it, **`MODBUS_ENABLE`** for RTU.
- **`MODBUS_ENABLE`** in `my_machine.h`: **`1`** = RTU on (auto direction if the serial backend supports it; otherwise Modbus may claim a direction output — see [`grbl/modbus_rtu.c`](../grbl/modbus_rtu.c) `modbus_rtu_init()`). **`2`** is normalized to RTU + explicit DE/RE via **`MODBUS_DIR_AUX`** or the last free digital aux output.
- **`MODBUS_RTU_STREAM`** in the **board map**: which UART index carries Modbus ([`grbl/plugins_init.h`](../grbl/plugins_init.h): `0` ≈ main `SERIAL_PORT`, `1` ≈ `SERIAL1_PORT`, …). Define it if Modbus must not use the default stream (not all maps set it; e.g. SKR V3 map here may need it added).
- **DE/RE pin:** define **`RS485_DIR_PORT`** / **`RS485_DIR_PIN`** for that UART in [`Src/serial.c`](../Src/serial.c); the STM32 driver registers crossbar **`Output_RS485_Direction`** (**209**) in [`Src/driver.c`](../Src/driver.c).

**RS485 — wiring:** MCU TX/RX and GND to an RS485 transceiver; A/B to the VFD per the drive manual. Match **baud**, **parity**, and **slave address** to the VFD using runtime settings below.

**Runtime `$` settings** (ids from [`grbl/settings.h`](../grbl/settings.h); use `$$=<id>` for enumerations)

| Setting                      | Id      | Role                                                                                               |
|:-----------------------------|--------:|:---------------------------------------------------------------------------------------------------|
| Modbus baud rate             | 374     | 2400 … 115200 (index; default `DEFAULT_MODBUS_STREAM_BAUD` in [`grbl/config.h`](../grbl/config.h)) |
| Modbus RX timeout            | 375     | RTU character timing                                                                               |
| Default spindle              | 395     | Startup / binding when multiple spindles; reboot may be required                                   |
| VFD Modbus address (one VFD) | **460** | Slave address (not `$360`; older docs were wrong)                                                  |
| VFD addresses (multi)        | 476–479 | Per spindle slot when multiple VFDs                                                                |
| RPM ↔ Hz (GS20 / YL-620)     | 461     | Often default 60                                                                                   |
| MODVFD registers             | 462–471 | See [`spindle/README.md`](../spindle/README.md)                                                    |
| Spindle enable / binding     | 510–517 | Spindle-select plugin when `N_SPINDLE > 1`                                                         |
| Tool range per spindle       | 520–527 | With tool-based spindle selection                                                                  |

M-codes, dual-spindle behavior, and plugin details: [`spindle/README.md`](../spindle/README.md). Init order: Modbus RTU then VFD ([`grbl/plugins_init.h`](../grbl/plugins_init.h)).

**Aliases:** `Input_ModeSelect`→`Input_MPGSelect`; `Input_LimitX_2`→`Input_LimitX2` (Y/Z same); `Outputs`→`Output_StepX`; `Output_StepX_2`→`Output_StepX2` (step/dir Y/Z same); `Output_StepperEnableSTEPPERS`→`Output_StepperEnable`; `Output_StepperEnableX2`→X enable; `Input_AuxMax`→`Input_Aux23`; `Input_Analog_AuxMax`→`Input_Analog_Aux7`; `Output_AuxMax`→`Output_Aux23`; `Output_Analog_AuxMax`→`Output_Analog_Aux7`; `Output_LED0_Adressable`→`Output_LED_Adressable`; `Multipin`→`Input_MISO`; `Output_I2CSCK`→`Output_SCK`; `Bidirectional_I2CSDA`→`Bidirectional_SDA`; `Bidirectional`→`Bidirectional_MotorUARTX`.

---

### `pin_group_t`

| Val   | Identifier                         |
|------:|:-----------------------------------|
|     0 | `PinGroup_SpindleControl`          |
|     1 | `PinGroup_SpindlePWM`              |
|     2 | `PinGroup_Coolant`                 |
|     3 | `PinGroup_SpindlePulse`            |
|     4 | `PinGroup_SpindleIndex`            |
|     5 | `PinGroup_StepperPower`            |
|     6 | `PinGroup_StepperEnable`           |
|     7 | `PinGroup_StepperStep`             |
|     8 | `PinGroup_StepperDir`              |
|     9 | `PinGroup_AuxOutput`               |
|    10 | `PinGroup_AuxInputAnalog`          |
|    11 | `PinGroup_AuxOutputAnalog`         |
|    12 | `PinGroup_MotorChipSelect`         |
|    13 | `PinGroup_MotorUART`               |
|    14 | `PinGroup_I2C`                     |
|    15 | `PinGroup_SPI`                     |
|    16 | `PinGroup_UART1` (`PinGroup_UART`) |
| 17–19 | `PinGroup_UART2` … `UART4`         |
|    20 | `PinGroup_USB`                     |
|    21 | `PinGroup_CAN`                     |
|    22 | `PinGroup_LED`                     |
|    23 | `PinGroup_Home`                    |
|    24 | `PinGroup_Virtual`                 |

| Bit | Val     | Identifier               |
|:----|--------:|:-------------------------|
| 8   |     256 | `PinGroup_Control`       |
| 9   |     512 | `PinGroup_Limit`         |
| 10  |    1024 | `PinGroup_LimitMax`      |
| 11  |    2048 | `PinGroup_Probe`         |
| 12  |    4096 | `PinGroup_Keypad`        |
| 13  |    8192 | `PinGroup_MPG`           |
| 14  |   16384 | `PinGroup_QEI`           |
| 15  |   32768 | `PinGroup_QEI_Select`    |
| 16  |   65536 | `PinGroup_QEI_Index`     |
| 17  |  131072 | `PinGroup_Motor_Warning` |
| 18  |  262144 | `PinGroup_Motor_Fault`   |
| 19  |  524288 | `PinGroup_SdCard`        |
| 20  | 1048576 | `PinGroup_AuxInput`      |

---

### Notes

- Control / probe / scan rows: [`grbl/pin_bits_masks.h`](../grbl/pin_bits_masks.h) `aux_ctrl[]` + `systemGetState()` in `driver.c`. Optional `CONTROL_PORT` sets default ports for several `*_PORT` names.
- Display names from `crossbar.h` (`pin_names[]`); duplicate `Output_Aux15` key in C favors last match; no `pin_names` row for `Output_Aux23`.
- Regenerate values if `pin_function_t` enum order changes.
