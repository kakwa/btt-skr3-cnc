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


#ifndef BOARD_BTT_SKR_30
#error "Wrong Board"
#endif

#define GRBL_BUILD_INFO "BTT-SKR3-TMC5160-SPI-XY-GANGED"
#define N_ABC_MOTORS 2

#define TRINAMIC_ENABLE     5160
#define TRINAMIC_SPI_ENABLE 1
#define X_GANGED            1
#define X_AUTO_SQUARE       1
#define Y_GANGED            1
#define Y_AUTO_SQUARE       1

#define DEFAULT_X_CURRENT     2500.0f // X axis motor current (mA RMS)
#define DEFAULT_Y_CURRENT     2500.0f // Y axis motor current (mA RMS)
#define DEFAULT_Z_CURRENT     2000.0f // Z axis motor current (mA RMS)
#define DEFAULT_A_CURRENT     2500.0f // X2 ganged motor current (mA RMS)
#define DEFAULT_B_CURRENT     2500.0f // Y2 ganged motor current (mA RMS)

#define TRINAMIC_DEFAULT_MICROSTEPS 16

// Ganged axis direction invert: bit 0 = X ganged (M3), bit 1 = Y ganged (M4)
// 0x03 = X_AXIS_BIT | Y_AXIS_BIT (nuts_bolts.h not available in Phase 1)
//#define DEFAULT_GANGED_DIRECTION_INVERT_MASK 0x03

//#define PROBE_ENABLE   1

// EXP2 pin 7 (PA4) uses an internal pull-up; NC E-stop must tie it to GND when wired.
// Until then, disable all control inputs or the floating pin triggers halt/estop at boot.
#define ESTOP_ENABLE   0
#define CONTROL_ENABLE 0

//#define SAFETY_DOOR_ENABLE      1  // Use the Safety Door Pin for the collision detection bar switch on PA7 (EXP2 pin 5)
