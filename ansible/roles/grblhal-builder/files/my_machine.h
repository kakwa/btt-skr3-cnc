/*
  my_machine.h - configuration for STM32H7xx processors

  Part of grblHAL

  Copyright (c) 2021-2025 Terje Io

  grblHAL is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  grblHAL is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with grblHAL. If not, see <http://www.gnu.org/licenses/>.
*/

// ============================================================================
// BOARD SELECTION
// ============================================================================
#define BOARD_BTT_SKR_30      // BTT SKR V3 board.

// ============================================================================
// CUSTOM BUILD INFO
// ============================================================================
// Custom version string that appears in $I command
#define GRBL_BUILD_INFO "BTT-SKR3-TMC5160-SPI-XY-GANGED"

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

// Trinamic TMC5160 stepper drivers
#define TRINAMIC_ENABLE       5160 // Trinamic TMC5160 stepper driver support.
#define TRINAMIC_R_SENSE      75  // R sense resistance in milliohms. 5160 default is 75.
#define TRINAMIC_SPI_ENABLE   1   // Use SPI mode (BTT SKR-3 uses software SPI)

#define PROBE_ENABLE          1

// ============================================================================
// SPINDLE CONFIGURATION
// ============================================================================


// Up to four specific spindle drivers can be instantiated at a time.
// If none are specified the default PWM spindle is instantiated.
// More info: https://github.com/grblHAL/Plugins_spindle

#define PROBE_ENABLE          1
#define DRIVER_SPINDLE_ENABLE 1
#define SPINDLE_PWM           1

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
#define CONTROL_HALT   1
//#define FANS_ENABLE             1 // Enable fan control via M106/M107.
//#define SAFETY_DOOR_ENABLE      1
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
