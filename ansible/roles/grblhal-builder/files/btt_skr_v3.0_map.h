/*
  btt_skr_v3.0_map.h - BTT SKR 3 / SKR 3 EZ (machine options + pin map)

  Phase 1 (BTT_SKR_V30_MAP_PHASE_1): options that must appear before grbl/driver_opts.h
  Phase 2 (BTT_SKR_V30_MAP_PHASE_2): pin map (after driver_opts.h; uses N_ABC_MOTORS, DRIVER_SPINDLE_ENABLE, …)

  See Inc/driver.h for include order.
*/

#if defined(BTT_SKR_V30_MAP_PHASE_1)

// ============================================================================
// BOARD SELECTION
// ============================================================================

#ifndef BOARD_BTT_SKR_30
#define BOARD_BTT_SKR_30      // BTT SKR V3 board.
#endif

// ============================================================================
// CUSTOM BUILD INFO
// ============================================================================
// Builder number: set at build time for unique IDs, e.g. -DBUILD_EPOCH=$(date +%s)
#ifndef BUILD_EPOCH
#define BUILD_EPOCH 0
#endif
#define BUILD_STR_(x) #x
#define BUILD_STR(x) BUILD_STR_(x)
// Custom version string that appears in $I command
#define GRBL_BUILD_INFO "BTT-SKR3-TMC5160-SPI-XY-GANGED-YETITOOLCNC-" BUILD_STR(BUILD_EPOCH)

// ============================================================================
// MOTOR CONFIGURATION
// ============================================================================
// Ganged/dual motor axes (BTT SKR 3 supports up to 5 motors: X, Y, Z + 2 additional)
// NOTE: N_ABC_MOTORS is calculated automatically as (N_ABC_AXIS + N_GANGED)
//       where N_GANGED = X_GANGED + Y_GANGED + Z_GANGED
#define X_GANGED            1
#define X_AUTO_SQUARE       1
#define Y_GANGED            1
#define Y_AUTO_SQUARE       1

// Trinamic driver type (2209 vs 5160, SPI vs UART) comes from platformio.ini build_flags.

// Motor current settings (mA RMS)
// TMC5160 supports up to 3000mA per motor, but actual limit depends on:
// - Motor specifications (check motor datasheet)
// - Cooling (heatsinks required for high current)
// - Power supply capacity
// Typical values: 800-1500mA for NEMA 23, 1500-2500mA for NEMA 34
// OPTIMIZED FOR TORQUE: 2.5A current with SpreadCycle and lower microstepping
#define DEFAULT_X_CURRENT     2500.0f // X axis motor current (mA RMS)
#define DEFAULT_Y_CURRENT     2500.0f // Y axis motor current (mA RMS)
#define DEFAULT_Z_CURRENT     2000.0f // Z axis motor current (mA RMS)
#define DEFAULT_A_CURRENT     2500.0f // X2 ganged motor current (mA RMS)
#define DEFAULT_B_CURRENT     2500.0f // Y2 ganged motor current (mA RMS)

// Hold current percentage (0-100%)
// Higher percentage = more holding torque (important for vertical Z-axis)
// 75% = three-quarters power when holding position (optimized for torque)
#define TMC_X_HOLD_CURRENT_PCT 75
#define TMC_Y_HOLD_CURRENT_PCT 75
#define TMC_Z_HOLD_CURRENT_PCT 75
#define TMC_A_HOLD_CURRENT_PCT 75
#define TMC_B_HOLD_CURRENT_PCT 75

// Microstepping (1, 2, 4, 8, 16, 32, 64, 128, 256)
// Lower values = more torque per step (8 microsteps = 2x torque vs 16)
// Trade-off: slightly less smooth motion, but significantly more power
#define TRINAMIC_DEFAULT_MICROSTEPS 8

// Ganged axis direction invert: bit 0 = X ganged (M3), bit 1 = Y ganged (M4)
// 0x03 = X_AXIS_BIT | Y_AXIS_BIT (nuts_bolts.h not available in Phase 1)
#define DEFAULT_GANGED_DIRECTION_INVERT_MASK 0x03

// StealthChop mode (0 = SpreadCycle/CoolStep, 1 = StealthChop)
// SpreadCycle: Maximum torque at all speeds (louder but stronger)
// StealthChop: Silent but reduced torque
// OPTIMIZED FOR TORQUE: Using SpreadCycle (0)
#define TMC_STEALTHCHOP 0

// ============================================================================
// SPINDLE CONFIGURATION
// ============================================================================


// Up to four specific spindle drivers can be instantiated at a time.
// If none are specified the default PWM spindle is instantiated.
// More info: https://github.com/grblHAL/Plugins_spindle

// VFD spindle via Modbus/RS-485:
// To use Modbus, uncomment the lines below and rebuild
//#define MODBUS_RTU_STREAM       0 // 0 = SERIAL (TFT header), 1 = SERIAL1 (ESP-32 header)
//#define MODBUS_ENABLE           1 // Set to 1 for auto direction, 2 for direction signal on auxiliary output pin.
//#define SPINDLE0_ENABLE         SPINDLE_HUANYANG1 // VFD spindle via Modbus (requires MODBUS_ENABLE)
//
// MODBUS_RTU_STREAM options:
//   0 = Use SERIAL port (TFT header: PA9/PA10) - USB CDC will be disabled
//   1 = Use SERIAL1 port (ESP-32 header: PD8/PD9) - Keeps TFT header for debug
//
// MODBUS_ENABLE options:
//   1 = Auto direction (single RS-485 transceiver, switches TX/RX automatically)
//   2 = Manual direction (requires external direction control signal)

// ============================================================================
// Probe, LIMITS and FANS OPTIONS
// ============================================================================
#define PROBE_ENABLE   1
#define CONTROL_ENABLE 1

// Maximum axis travel (mm). Used for soft limits and homing.
#define DEFAULT_X_MAX_TRAVEL 2500.0f
#define DEFAULT_Y_MAX_TRAVEL 1250.0f
#define DEFAULT_Z_MAX_TRAVEL 130.0f

//#define FANS_ENABLE             1 // Enable fan control via M106/M107.
//#define SAFETY_DOOR_ENABLE      1  // Use the Safety Door Pin for the collision detection bar switch on PA7 (EXP2 pin 5)
// Safety door/collision input: Normally Open (NO) — invert so closed = trigger
// #define DEFAULT_CONTROL_SIGNALS_INVERT_MASK 8  // 8 = SIGNALS_SAFETYDOOR_BIT (bit 3)
//#define LIMITS_OVERRIDE_ENABLE  1
//#define ESTOP_ENABLE            0 // When enabled only real-time report requests will be executed when reset pin is asserted.

// ============================================================================
// OPTIONAL FEATURES (uncomment to enable)
// ============================================================================

// Communication options:
//#define USB_SERIAL_CDC          1 // Serial communication via native USB.
//#define BLUETOOTH_ENABLE        2 // Set to 2 for HC-05 module via UART.
//#define ESP_AT_ENABLE           1 // Enable Telnet/WiFi via ESP32 on SERIAL1_PORT.

// Networking (requires external modules):
//#define ETHERNET_ENABLE         1 // Ethernet streaming via external WizNet module (requires _WIZCHIP_ definition).
//#define _WIZCHIP_            5500 // WizNet W5500 via SPI. Set to 5500 for W5500, 5105 for W5100S.

// Storage:
//#define SDCARD_ENABLE           1 // Run gcode programs from SD card. Requires external SD card module via SPI.
//#define EEPROM_ENABLE          16 // I2C EEPROM/FRAM. Set to 16 for 2K, 32 for 4K, 64 for 8K, 128 for 16K, 256 for 32K capacity.
//#define EEPROM_IS_FRAM          1 // Uncomment when EEPROM is enabled and chip is FRAM.

// User interface:
//#define MPG_ENABLE              1 // Manual Pulse Generator. 1: handshake pin, 2: command character toggle.
//#define KEYPAD_ENABLE           1 // I2C keypad for input.
//#define DISPLAY_ENABLE          1 // Set to 9 for I2C display protocol, 17 for I2C LED protocol.

// Other plugins:
//#define ODOMETER_ENABLE         1 // Odometer plugin.
//#define EVENTOUT_ENABLE         1 // Enable binding events (triggers) to control auxiliary outputs.

#endif /* BTT_SKR_V30_MAP_PHASE_1 */

#if defined(BTT_SKR_V30_MAP_PHASE_2)

/*
  btt_skr_v3.0_map.h - Board map for BIGTREETECH SKR 3 / SKR 3 EZ

  Part of grblHAL

  Copyright (c) 2022-2023 Jon Escombe

  Grbl is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Grbl is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Grbl.  If not, see <http://www.gnu.org/licenses/>.
*/

#if N_ABC_MOTORS > 2
#error "BTT SKR-3 supports 5 motors max."
#endif

#if !(defined(STM32H743xx)|| defined(STM32H723xx)) || HSE_VALUE != 25000000
#error "This board has STM32H7xx processor with a 25MHz crystal, select a corresponding build!"
#endif

#define BOARD_NAME "BTT SKR-3"
#define BOARD_URL "https://github.com/bigtreetech/SKR-3"

#define SERIAL_PORT                 1   // TFT header, GPIOA: TX = 9, RX = 10
#define SERIAL1_PORT                32  // ESP-32,     GPIOD: TX = 8, RX = 9

#define COPROC_STREAM               1   // Use SERIAL1_PORT definition

// Define step pulse output pins.
#define X_STEP_PORT                 GPIOD
#define X_STEP_PIN                  4                   // X
#define Y_STEP_PORT                 GPIOA
#define Y_STEP_PIN                  15                  // Y
#define Z_STEP_PORT                 GPIOE
#define Z_STEP_PIN                  2                   // Z
#define STEP_OUTMODE                GPIO_SINGLE
//#define STEP_PINMODE                PINMODE_OD // Uncomment for open drain outputs

// Define step direction output pins.
#define X_DIRECTION_PORT            GPIOD
#define X_DIRECTION_PIN             3
#define Y_DIRECTION_PORT            GPIOA
#define Y_DIRECTION_PIN             8
#define Z_DIRECTION_PORT            GPIOE
#define Z_DIRECTION_PIN             3
#define DIRECTION_OUTMODE           GPIO_SINGLE
//#define DIRECTION_PINMODE           PINMODE_OD // Uncomment for open drain outputs

// Define stepper driver enable/disable output pin.
#define X_ENABLE_PORT               GPIOD
#define X_ENABLE_PIN                6
#define Y_ENABLE_PORT               GPIOD
#define Y_ENABLE_PIN                1
#define Z_ENABLE_PORT               GPIOE
#define Z_ENABLE_PIN                0
//#define STEPPERS_ENABLE_PINMODE   PINMODE_OD // Uncomment for open drain outputs

// Define homing/hard limit switch input pins.
#define X_LIMIT_PORT                GPIOC
#define X_LIMIT_PIN                 1                           // X- Limit
#define Y_LIMIT_PORT                GPIOC
#define Y_LIMIT_PIN                 3                           // Y- Limit
#define Z_LIMIT_PORT                GPIOC
#define Z_LIMIT_PIN                 0                           // Z- Limit
#define LIMIT_INMODE                GPIO_SINGLE

// Define ganged axis or A axis step pulse and step direction output pins.
#if N_ABC_MOTORS > 0
#define M3_AVAILABLE                // E0
#define M3_STEP_PORT                GPIOD
#define M3_STEP_PIN                 15
#define M3_DIRECTION_PORT           GPIOD
#define M3_DIRECTION_PIN            14
#define M3_LIMIT_PORT               GPIOC
#define M3_LIMIT_PIN                2
#define M3_ENABLE_PORT              GPIOC
#define M3_ENABLE_PIN               7
#endif

// Define ganged axis or B axis step pulse and step direction output pins.
#if N_ABC_MOTORS == 2
#define M4_AVAILABLE                // E1
#define M4_STEP_PORT                GPIOD
#define M4_STEP_PIN                 11
#define M4_DIRECTION_PORT           GPIOD
#define M4_DIRECTION_PIN            10
// The normal limit pin for E1 is PA0, but bit 0 already has an interrupt (Z_LIMIT_PIN).
// PC15 is normally used for PWRDET but is used for M4_LIMIT_PIN instead.
// If using TMC drivers, jumper from PWRDET connector pin 3 to DIAG pin on driver.
#define M4_LIMIT_PORT               GPIOC                       // orig GPIOA
#define M4_LIMIT_PIN                15                          // orig 0
#define M4_ENABLE_PORT              GPIOD
#define M4_ENABLE_PIN               13
#endif

#define AUXOUTPUT0_PORT             GPIOB                       // Spindle PWM - EXP1 - pin 9
#define AUXOUTPUT0_PIN              0
#define AUXOUTPUT1_PORT             GPIOB                       // Spindle direction - FAN2
#define AUXOUTPUT1_PIN              5
#define AUXOUTPUT2_PORT             GPIOB                       // Spindle enable - FAN1
#define AUXOUTPUT2_PIN              6
#define AUXOUTPUT3_PORT             GPIOB                       // Coolant flood - HEAT0
#define AUXOUTPUT3_PIN              3
#define AUXOUTPUT4_PORT             GPIOB                       // Coolant mist - HEAT1
#define AUXOUTPUT4_PIN              4
#define AUXOUTPUT5_PORT             GPIOB                       // ESP32 IO0
#define AUXOUTPUT5_PIN              10
#define AUXOUTPUT6_PORT             GPIOC                       // ESP32 RST
#define AUXOUTPUT6_PIN              14

// Define driver spindle pins.
#if DRIVER_SPINDLE_ENABLE & SPINDLE_ENA
#define SPINDLE_ENABLE_PORT         AUXOUTPUT2_PORT
#define SPINDLE_ENABLE_PIN          AUXOUTPUT2_PIN
#endif
#if DRIVER_SPINDLE_ENABLE & SPINDLE_PWM
#define SPINDLE_PWM_PORT            AUXOUTPUT0_PORT
#define SPINDLE_PWM_PIN             AUXOUTPUT0_PIN
#endif
#if DRIVER_SPINDLE_ENABLE & SPINDLE_DIR
#define SPINDLE_DIRECTION_PORT      AUXOUTPUT1_PORT
#define SPINDLE_DIRECTION_PIN       AUXOUTPUT1_PIN
#endif

// Define flood and mist coolant enable output pins.
#if COOLANT_ENABLE & COOLANT_FLOOD
#define COOLANT_FLOOD_PORT          AUXOUTPUT3_PORT
#define COOLANT_FLOOD_PIN           AUXOUTPUT3_PIN
#endif
#if COOLANT_ENABLE & COOLANT_MIST
#define COOLANT_MIST_PORT           AUXOUTPUT4_PORT
#define COOLANT_MIST_PIN            AUXOUTPUT4_PIN
#endif

#if ESP_AT_ENABLE
#define COPROC_RESET_PORT           AUXOUTPUT6_PORT
#define COPROC_RESET_PIN            AUXOUTPUT6_PIN
#define COPROC_BOOT0_PORT           AUXOUTPUT5_PORT
#define COPROC_BOOT0_PIN            AUXOUTPUT5_PIN
#endif

#define AUXINPUT0_PORT              GPIOA                       // Safety door - EXP2 - pin 5
#define AUXINPUT0_PIN               7
#define AUXINPUT1_PORT              GPIOC                       // Z probe
#define AUXINPUT1_PIN               13
#define AUXINPUT2_PORT              GPIOA                       // Reset - EXP2 - pin 7
#define AUXINPUT2_PIN               4
#define AUXINPUT3_PORT              GPIOA                       // Feed hold - EXP2 - pin 9
#define AUXINPUT3_PIN               5
#define AUXINPUT4_PORT              GPIOA                       // Cycle start - EXP2 - pin 10
#define AUXINPUT4_PIN               6


// Define user-control controls (cycle start, reset, feed hold) input pins.
#if CONTROL_ENABLE & CONTROL_HALT
#define RESET_PORT                  AUXINPUT2_PORT
#define RESET_PIN                   AUXINPUT2_PIN
#endif
#if CONTROL_ENABLE & CONTROL_FEED_HOLD
#define FEED_HOLD_PORT              AUXINPUT3_PORT
#define FEED_HOLD_PIN               AUXINPUT3_PIN
#endif
#if CONTROL_ENABLE & CONTROL_CYCLE_START
#define CYCLE_START_PORT            AUXINPUT4_PORT
#define CYCLE_START_PIN             AUXINPUT4_PIN
#endif

#if SAFETY_DOOR_ENABLE
#define SAFETY_DOOR_PORT            AUXINPUT0_PORT
#define SAFETY_DOOR_PIN             AUXINPUT0_PIN
#endif

#if PROBE_ENABLE
#define PROBE_PORT                  AUXINPUT1_PORT
#define PROBE_PIN                   AUXINPUT1_PIN
#endif

#if TRINAMIC_UART_ENABLE

#define MOTOR_UARTX_PORT            GPIOD
#define MOTOR_UARTX_PIN             5
#define MOTOR_UARTY_PORT            GPIOD
#define MOTOR_UARTY_PIN             0
#define MOTOR_UARTZ_PORT            GPIOE
#define MOTOR_UARTZ_PIN             1

#ifdef  M3_AVAILABLE
#define MOTOR_UARTM3_PORT           GPIOC
#define MOTOR_UARTM3_PIN            6
#endif

#ifdef  M4_AVAILABLE
#define MOTOR_UARTM4_PORT           GPIOD
#define MOTOR_UARTM4_PIN            12
#endif

#elif TRINAMIC_SPI_ENABLE

// The BTT SKR-3 uses software SPI
#define TRINAMIC_SOFT_SPI

#define TRINAMIC_MOSI_PORT          GPIOE
#define TRINAMIC_MOSI_PIN           13
#define TRINAMIC_SCK_PORT           GPIOE
#define TRINAMIC_SCK_PIN            14
#define TRINAMIC_MISO_PORT          GPIOE
#define TRINAMIC_MISO_PIN           15

#define MOTOR_CSX_PORT              GPIOD
#define MOTOR_CSX_PIN               5
#define MOTOR_CSY_PORT              GPIOD
#define MOTOR_CSY_PIN               0
#define MOTOR_CSZ_PORT              GPIOE
#define MOTOR_CSZ_PIN               1

#ifdef  M3_AVAILABLE
#define MOTOR_CSM3_PORT             GPIOC
#define MOTOR_CSM3_PIN              6
#endif

#ifdef  M4_AVAILABLE
#define MOTOR_CSM4_PORT             GPIOD
#define MOTOR_CSM4_PIN              12
#endif

#endif

// EOF

#endif /* BTT_SKR_V30_MAP_PHASE_2 */
