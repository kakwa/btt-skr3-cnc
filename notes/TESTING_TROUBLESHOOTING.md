# Testing and Troubleshooting Guide

This guide covers testing procedures, troubleshooting common issues, and safety considerations for the BTT SKR 3 running grblHAL.

## Table of Contents

1. [Wiring Checklist](#wiring-checklist)
2. [Initial Testing Sequence](#initial-testing-sequence)
3. [Troubleshooting](#troubleshooting)
4. [Safety Notes](#safety-notes)
5. [Additional Resources](#additional-resources)

---

## Wiring Checklist

### Before Power-On

- [ ] All stepper motors connected to correct drivers
- [ ] TMC5160 drivers installed with correct orientation
- [ ] **UART jumpers (PDN_UART) installed on all 5 driver sockets**
- [ ] **SPI jumpers removed (if any were present)**
- [ ] E-STOP button wired (NC type, connected to EXP2 pin 7)
- [ ] Limit switches wired (NO type, one per axis minimum)
- [ ] Y2 limit switch on PWRDET pin 3 (or jumpered to E1 DIAG)
- [ ] Probe connected (if using)
- [ ] Spindle control wired (if using)
- [ ] Main power supply connected (12-24V)
- [ ] USB cable connected to computer/Raspberry Pi
- [ ] All ground connections secure
- [ ] No short circuits between power and ground
- [ ] Firmware built with TRINAMIC_UART_ENABLE=1

---

## Initial Testing Sequence

### Step 1: Power on with USB Only

**No main power connected yet**

- Board should enumerate as USB device
- Check `lsusb` - should show `0483:5740` (Virtual COM Port)
- Connect via serial terminal: `screen /dev/ttyACM0 115200`

**Expected:** grblHAL prompt appears

### Step 2: Add Main Power

**With E-STOP pressed (if wired)**

- Apply main power (12-24V)
- **Check immediately:**
  - No smoke or unusual smells
  - No excessive heat from board/drivers
  - Driver LEDs lit (if equipped)
  - No error sounds

**If anything seems wrong, disconnect power immediately**

### Step 3: Test E-STOP

**Release the E-STOP button**

- grblHAL should exit ESTOP state
- Send `?` status command
- Should show "Idle" or "Alarm" (not "ESTOP")

**If still showing ESTOP:**
- Check button wiring (should be NC type)
- Verify pin 7 connected to GND when button released

### Step 4: Test Basic Communication

**Verify grblHAL is responding:**

```bash
$$      # List all settings
$I      # Show system info
?       # Show status
```

**Expected output:**
- Settings list should appear
- System info shows firmware version
- Status shows current state

### Step 5: Verify TMC Driver UART Communication

**Check driver detection:**

```bash
$I      # Should list all 5 TMC5160 drivers detected
$338    # Check TMC driver settings bitmask
```

**Expected output:**
```
[MSG:grblHAL]
[MSG:STM32H723]
[MSG:TMC5160 drivers: X Y Z M3 M4]
...
```

**If no drivers detected:**
- Check UART jumpers on all 5 sockets
- Verify drivers are seated properly
- Check for SPI jumpers (should be removed)
- Power cycle the board

### Step 6: Test Motors Individually

**No mechanical load - motors should be free to move**

Test each axis with jog commands:

```bash
# Test X axis (10mm move at 100mm/min)
$J=G21G91X10F100

# Test Y axis
$J=G21G91Y10F100

# Test Z axis
$J=G21G91Z10F100
```

**For each motor check:**
- Motor makes sound and attempts to move
- No grinding or unusual noises
- Motor doesn't get excessively hot
- Direction is as expected

**If direction is wrong:**
```bash
$3=1    # Invert X direction
$4=1    # Invert Y direction
$5=1    # Invert Z direction
```

**If motor doesn't move at all:**
- Check driver enable pin
- Verify current settings ($140-$144)
- Check motor wiring
- Verify steps/mm settings ($100-$102)

### Step 7: Test Limit Switches

**Manually trigger each limit switch:**

```bash
# Send status query while triggering switch
?
```

**Expected behavior:**
- grblHAL enters ALARM state when switch triggered
- Status shows which limit was triggered
- Must reset with `$X` or cycle power

**Test all switches:**
- X limit (PC1)
- Y limit (PC3)
- Z limit (PC0)
- X2/M3 limit (PC2)
- Y2/M4 limit (PC15)

**Enable hard limits:**
```bash
$21=1   # Enable hard limits
```

### Step 8: Test Spindle (If Connected)

**PWM Spindle Control:**

```bash
M3 S1000    # Spindle CW at 1000 RPM
M5          # Spindle stop
M4 S1000    # Spindle CCW at 1000 RPM
M5          # Spindle stop
```

**Check:**
- Enable signal activates (FAN1 output)
- PWM signal present (EXP1 pin 9)
- Direction signal changes (FAN2 output)
- Spindle responds to commands

**Spindle configuration:**
```bash
$30=1000    # Max spindle RPM
$31=0       # Min RPM
$32=1000    # Max PWM value
```

### Step 9: Test Probe (If Connected)

**Touch probe test:**

```bash
?           # Check status
# Touch probe tip to GND
?           # Check status - should show probe triggered
```

**Or use probe command:**
```bash
G38.2 Z-10 F100     # Probe toward workpiece
```

**Expected:**
- Probe input detects contact
- Motion stops when probe triggers
- Position is recorded

---

## Troubleshooting

### E-STOP Asserted on Boot

**Symptom:** grblHAL immediately shows "ESTOP asserted" message

**Cause:** RESET pin (EXP2 pin 7) is floating

**Solutions:**
1. Wire NC E-STOP button from pin 7 to GND
2. Temporarily jumper pin 7 to GND
3. Disable `CONTROL_HALT` in `my_machine.h` and rebuild

**Verification:**
```bash
?           # Status should not show ESTOP
```

### Motor Not Moving

**Symptom:** Motor makes no sound or doesn't rotate

**Checks:**

1. **Driver installed correctly**
   - Check orientation (notch/marking aligned)
   - Firmly seated in socket
   - UART jumpers installed

2. **Motor wired correctly**
   - Check coil pairs (A+/A- and B+/B-)
   - Test with multimeter for continuity
   - Verify connections are tight

3. **Enable signal working**
   - Measure voltage on enable pin (should be LOW when enabled)
   - Check $4 setting for enable invert

4. **Driver not in thermal shutdown**
   - Touch driver heatsink - should be warm, not burning hot
   - Ensure adequate cooling
   - Reduce current if overheating

5. **Current setting appropriate**
   ```bash
   $140=1200    # X axis current (mA)
   $141=1200    # Y axis current
   $142=1200    # Z axis current
   $143=1200    # M3 axis current
   $144=1200    # M4 axis current
   ```

6. **Steps per mm configured**
   ```bash
   $100=80      # X steps/mm
   $101=80      # Y steps/mm
   $102=400     # Z steps/mm (example for lead screw)
   ```

### Motor Running Backwards

**Symptom:** Motor moves in opposite direction

**Solution:** Invert direction in settings

```bash
$3=1    # Invert X direction
$4=1    # Invert Y direction
$5=1    # Invert Z direction
```

Or physically swap motor coil wires (swap A+/A- pair or B+/B- pair, not individual wires)

### Limit Switch Not Working

**Symptom:** Limit switch doesn't trigger alarm

**Checks:**

1. **Switch wired correctly**
   - NO (Normally Open) type switch
   - Connected to correct pin and GND
   - Verify with multimeter

2. **Switch functioning**
   - Test continuity when triggered
   - Check for stuck or damaged switch

3. **Limit enable setting**
   ```bash
   $21=1       # Enable hard limits
   $22=1       # Enable homing cycle
   ```

4. **For Y2 limit on PC15**
   - Verify PWRDET pin 3 connection
   - Check jumper to E1 DIAG pin (if using)

5. **Test with status query**
   ```bash
   ?           # Trigger switch and check status
   ```

### TMC Driver Not Responding (UART Mode)

**Symptom:** Drivers not detected in `$I` command output

**Checks:**

1. **UART jumpers installed**
   - Check PDN_UART jumpers on all 5 driver sockets
   - Verify jumpers are properly seated

2. **SPI jumpers removed**
   - Ensure no SPI jumpers are installed
   - Check for conflicts

3. **Driver seated properly**
   - Remove and reseat driver
   - Check for bent pins
   - Verify correct orientation

4. **Check driver detection**
   ```bash
   $I          # List system info - should show TMC5160 drivers
   $338        # Check TMC driver settings
   $$          # List all settings
   ```

5. **UART pin configuration**
   - Verify `TRINAMIC_UART_ENABLE 1` in `my_machine.h`
   - Rebuild firmware if changed

6. **Power cycle**
   - Turn off main power
   - Disconnect USB
   - Wait 10 seconds
   - Reconnect and power on

7. **Test individual driver**
   - Install one driver at a time
   - Check detection for each

**Common UART Issues:**

| Issue | Symptom | Solution |
|-------|---------|----------|
| Missing PDN_UART jumpers | No drivers detected | Install jumpers on all sockets |
| SPI jumpers installed | Communication conflict | Remove all SPI jumpers |
| Wrong orientation | No communication | Check notch/marking alignment |
| Firmware not UART-enabled | No drivers detected | Rebuild with TRINAMIC_UART_ENABLE=1 |
| Bad driver | One driver missing | Replace driver |

### Ganged Axes Not Working

**Symptom:** Only one motor moves on ganged axis (X or Y)

**Checks:**

1. **Verify ganging is enabled in firmware**
   - Check `my_machine.h` has `X_GANGED 1` and `Y_GANGED 1`
   - Rebuild if changed

2. **Check secondary motor connections**
   - X2 on E0 driver socket
   - Y2 on E1 driver socket

3. **Verify drivers detected**
   ```bash
   $I          # Should show M3 and M4 drivers
   ```

4. **Test motors individually** (temporarily disable ganging in firmware)

5. **Check current settings**
   ```bash
   $143=1200   # M3/E0 current
   $144=1200   # M4/E1 current
   ```

### Auto-Squaring Issues

**Symptom:** Axes not squaring during homing

**Requirements:**
- Separate limit switches for both motors
- X_AUTO_SQUARE and Y_AUTO_SQUARE enabled
- Homing cycle enabled ($22=1)

**Checks:**

1. **Both limit switches working**
   - Test X and X2 limits separately
   - Test Y and Y2 limits separately

2. **Homing enabled**
   ```bash
   $22=1       # Enable homing
   $23=3       # Homing direction (adjust as needed)
   ```

3. **Run homing cycle**
   ```bash
   $H          # Home all axes
   ```

### Spindle Not Responding

**Symptom:** Spindle doesn't turn on or respond to speed commands

#### For PWM Spindle

**Checks:**

1. **PWM output enabled**
   ```bash
   $30=1000    # Max RPM (0 disables spindle)
   $31=0       # Min RPM
   $32=1000    # Max PWM value
   ```

2. **Enable signal working**
   - Check FAN1 output voltage
   - Should go HIGH when spindle enabled

3. **PWM signal present**
   - Use oscilloscope on EXP1 pin 9
   - Frequency should vary with speed

4. **Direction signal (if using)**
   - Check FAN2 output
   - Should change with M3 vs M4

5. **VFD/controller configured**
   - 0-10V or PWM input mode
   - Correct enable signal polarity
   - Parameters programmed correctly

#### For Modbus/RS-485 VFD

**Symptom:** VFD not responding to Modbus commands

**Checks:**

1. **Firmware compiled with Modbus support**
   - Verify `MODBUS_ENABLE` and `SPINDLE0_ENABLE` in `my_machine.h`
   - Rebuild and reflash if changed

2. **RS-485 hardware wiring**
   - TX (PA9) → RS-485 DI
   - RX (PA10) → RS-485 RO
   - A/B wiring correct (A to A+, B to B-)
   - Termination resistor if required (120Ω)

3. **VFD Modbus settings**
   - Modbus address matches (usually 1)
   - Baud rate configured (usually 9600 or 19200)
   - Communication parameters match (8N1, 8E1, etc.)
   - RS-485 mode enabled on VFD

4. **grblHAL Modbus settings**
   ```bash
   $384    # Modbus baud rate (default 19200)
   $385    # Modbus RX timeout
   $386    # Modbus slave address (default 1)
   ```

5. **Test Modbus communication**
   ```bash
   M3 S1000    # Start spindle
   ?           # Check status for errors
   ```

6. **Common Modbus issues:**
   - Wrong baud rate → No communication
   - Wrong address → VFD doesn't respond
   - A/B wires swapped → Garbled data
   - No termination → Communication errors
   - DE/RE not connected (if MODBUS_ENABLE=2) → No transmission

7. **Debug Modbus**
   - Check VFD display for communication errors
   - Use USB-RS485 adapter to monitor bus traffic
   - Verify TX/RX LEDs on RS-485 module blink during commands

### USB Connection Issues

**Symptom:** Board not appearing as USB device

**Checks:**

1. **USB cable**
   - Use data-capable cable (not charge-only)
   - Try different cable
   - Check for damage

2. **USB port**
   - Try different USB port on computer
   - Check for power (LED on board should light)

3. **Driver installation** (Windows only)
   - Install STM32 Virtual COM Port drivers
   - Check Device Manager

4. **Linux permissions**
   ```bash
   sudo usermod -a -G dialout $USER
   # Log out and back in
   ```

5. **Check USB enumeration**
   ```bash
   lsusb | grep 0483
   # Should show: 0483:5740 STMicroelectronics Virtual COM Port
   ```

### Firmware Upload Failed

**Symptom:** DFU flash fails or board won't enter DFU mode

**Solutions:**

1. **Enter DFU mode correctly**
   - Hold BOOT0
   - Press and release RESET
   - Release BOOT0
   - Check with `dfu-util -l`

2. **Wrong flash address**
   - Use `0x08020000` for 128KB bootloader
   - Not `0x08000000`

3. **DFU-util not installed**
   ```bash
   sudo apt install dfu-util
   ```

4. **USB connection issue**
   - Try different USB port/cable
   - Check power supply

See [BUILD_FLASH.md](BUILD_FLASH.md) for detailed flashing instructions.

---

## Safety Notes

⚠️ **WARNING: CNC machines can cause serious injury or death**

### Critical Safety Rules

1. **Always wire E-STOP first** and test before operation
   - Use proper NC (Normally Closed) button
   - Test that it immediately stops all motion
   - Keep E-STOP within easy reach

2. **Use proper cable management**
   - Secure all cables away from moving parts
   - Use cable chains/conduit where appropriate
   - Avoid pinch points and sharp edges

3. **Never bypass safety features**
   - Don't disable limits without good reason
   - Don't jumper out E-STOP permanently
   - Don't override safety interlocks

4. **Keep hands clear** of moving parts during testing
   - Use chicken stick or probe for test pieces
   - Never reach into machine while powered
   - Wait for all motion to stop

5. **Use proper motor current settings**
   - Don't exceed motor/driver ratings
   - Monitor temperatures during operation
   - Add cooling if needed

6. **Ensure spindle cannot start unexpectedly**
   - Test enable signal works correctly
   - Verify M5 stops spindle
   - Use spindle enable switch if available

7. **Double-check polarity** on all power connections
   - Wrong polarity can destroy components
   - Use multimeter to verify
   - Mark cables clearly

8. **Add thermal protection** if running motors at high current
   - Monitor driver/motor temperatures
   - Add heatsinks and cooling fans
   - Reduce current if overheating occurs

9. **Properly ground the machine** frame and enclosure
   - Connect mains earth to frame
   - Bond all metal parts together
   - Use proper earth ground, not just neutral

10. **Test in low-power/safe mode first** before full operation
    - Start with low feed rates
    - Reduce spindle speed initially
    - Verify limits and E-STOP work
    - Test with sacrificial material first

### Personal Protective Equipment (PPE)

- Safety glasses (mandatory)
- Hearing protection (for loud spindles)
- Dust mask or respirator (when cutting wood/composites)
- No loose clothing or jewelry
- Tie back long hair

### Before Each Operation

- [ ] Check E-STOP is accessible and working
- [ ] Verify workpiece is securely clamped
- [ ] Check tool is properly installed and tight
- [ ] Confirm correct G-code is loaded
- [ ] Clear work area of tools and obstacles
- [ ] Verify limit switches are functioning
- [ ] Check spindle rotates correctly
- [ ] Test feed rate with air cut first

### Emergency Procedures

**If something goes wrong:**

1. **Press E-STOP immediately**
2. Cut main power if fire/smoke
3. Never reach into moving machine
4. Wait for all motion to stop completely
5. Investigate cause before restarting

**Fire:**
- Use CO2 or ABC fire extinguisher
- Never use water on electrical fires
- Disconnect power first if safe to do so

**Injury:**
- Seek immediate medical attention
- Don't attempt to clear jammed material with body parts
- Keep first aid kit nearby

---

## Additional Resources

### Documentation

- [WIRING.md](WIRING.md) - Complete wiring guide
- [BUILD_FLASH.md](BUILD_FLASH.md) - Build and flash instructions
- [NOTES.md](NOTES.md) - Project notes and overview

### External Resources

- [BTT SKR 3 GitHub](https://github.com/bigtreetech/SKR-3)
- [BTT SKR 3 Pinout Diagram](https://github.com/bigtreetech/SKR-3#pinout)
- [BTT SKR 3 Manual (PDF)](https://github.com/bigtreetech/SKR-3/blob/master/Hardware/BTT%20SKR%203-Size.pdf)
- [grblHAL Documentation](https://github.com/grblHAL/core/wiki)
- [grblHAL Configuration](https://github.com/grblHAL/core/wiki/Configuration)
- [grblHAL Settings Reference](https://github.com/grblHAL/core/wiki/Settings)
- [TMC5160 Datasheet](https://www.trinamic.com/products/integrated-circuits/details/tmc5160/)
- [grblHAL Forum](https://github.com/grblHAL/core/discussions)

### Useful Commands Quick Reference

```bash
# Status and Info
?               # Current status
$$              # List all settings
$I              # System info
$G              # Parser state
$N              # Startup blocks

# Control
$X              # Kill alarm/unlock
$H              # Home all axes
~               # Cycle start (resume)
!               # Feed hold (pause)
Ctrl+X          # Soft reset

# Settings (common)
$21=1           # Enable hard limits
$22=1           # Enable homing
$30=1000        # Max spindle RPM
$100=80         # X steps/mm
$110=1000       # X max rate (mm/min)
$120=10         # X acceleration (mm/sec²)
$130=300        # X max travel (mm)
$140=1200       # X motor current (mA)

# Jogging
$J=G21G91X10F100    # Jog X+10mm at 100mm/min
$J=G21G91Y-5F100    # Jog Y-5mm at 100mm/min

# Spindle
M3 S1000        # Spindle CW at 1000 RPM
M4 S1000        # Spindle CCW at 1000 RPM  
M5              # Spindle stop

# Coolant
M8              # Flood coolant on
M7              # Mist coolant on
M9              # All coolant off
```

---

## Revision History

- 2026-01-28: Initial testing and troubleshooting documentation
