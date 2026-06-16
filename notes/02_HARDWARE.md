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
6. [Coolant](#coolant)
7. [Power](#power)
8. [Pin Reference Tables](#pin-reference-tables)

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
