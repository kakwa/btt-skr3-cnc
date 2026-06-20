# Configuration

## Quick Adjusting

Runtime settings are changed by sending `$N=value` to the board over serial — either via the gSender terminal or `cnc-console`. Each setting is written to flash (NVS) and survives reboots.

See the [grblHAL settings reference](99_SETTINGS.md) for the full list of paramters.

## Making It The Default

Runtime settings persist across power cycles, but a `$RST=*` (factory reset) reverts everything to compile-time defaults. To ensure calibrated values survive a firmware reset:

1. Edit the `grblhal_machine_build_flags` list in `ansible/pi-setup.yml`.
2. Re-run the Ansible playbook with `--tags grblhal` to redeploy `platformio.ini`.
3. Rebuild and reflash the firmware (`skr3-build` then `skr3-flash`).

The corresponding compile-time flags are `-D DEFAULT_X_STEPS_PER_MM=...` etc. They map directly to the `$100`/`$101`/`$102` defaults.

> grblHAL settings are stored in flash. A `$RST=*` is the only way they are lost — a normal reboot preserves them.

## Tuning Points

### Direction

Use `$3` to invert stepper direction for primary axes (bitmask: X=1, Y=2, Z=4).
For ganged axes, `$8` additionally inverts the direction of the second motor (bit 0 = X2, bit 1 = Y2), stacked on top of `$3`.

```bash
$3=0    # no primary axis direction inversion
$8=1    # invert X2 ganged motor only
$8=2    # invert Y2 ganged motor only
$8=3    # invert both ganged motors
```

> The ganged motor (X2/Y2) must turn in the **opposite** direction to its paired primary motor. If the machine racks (X or Y sides move in opposite directions during homing), flip the appropriate bit in `$8`.

### Step <-> Distance Relation

Steps per mm depends on motor full steps/rev (200 for 1.8°), driver microstepping (16 by default), and mechanical pitch.

| Axis | Setting | Nominal (steps/mm) |
|------|---------|--------------------|
| X    | `$100`  | 80.0               |
| Y    | `$101`  | 80.0               |
| Z    | `$102`  | 400.0              |
| X2   | `$103`  | 80.0               |
| Y2   | `$104`  | 80.0               |

#### Calibration Protocol

**Step 1 — move a known distance**

Home, then command a large relative move on the axis under test (larger = less measurement error):

> **Warning:** 500 mm is a large move. Jog the axis to roughly the **middle of its travel** before running the move, or it will crash into the far end.

```gcode
$H           ; home all axes
; jog to mid-travel first (e.g. via gSender), then:
G91          ; relative mode
G0 Y140      ; move Y 140 mm  (replace Y with X or Z as needed)
G90          ; back to absolute mode
```

**Step 2 — measure**

Use calipers to measure the actual distance traveled. Note it as `measured`.

**Step 3 — compute and apply**

```
new_steps = current_steps × (commanded / measured)
```

Then set the corrected value:

```gcode
$101=<new_steps>   ; Y axis
```

Repeat from step 1 until measured matches commanded within tolerance.

**Example** — Y commanded 140 mm, measured 210 mm, current `$101=80.0`:

```
new = 80.0 × (140 / 210) = 53.33
```

```gcode
$101=53.33
```

### End Stop

The build flags define the active endstop topology.

**Physical mapping** (from `btt_skr_v3.0_map.h` and build flags):

| Board label | Pin  | grblHAL signal | Purpose                        |
|-------------|------|----------------|--------------------------------|
| X- STOP     | PC1  | `X_LIMIT`      | X primary home switch          |
| E0DET       | PC2  | `M3_LIMIT`     | X2 auto-squaring switch        |
| Y- STOP     | PC3  | `Y_LIMIT`      | Y primary home switch          |
| PWRDET      | PC15 | `M4_LIMIT`     | Y2 auto-squaring switch        |
| Z- STOP     | PC0  | `Z_LIMIT`      | Z home switch                  |
| Probe       | PC13 | `PROBE`        | Z touch-off / tool length      |

**Key homing settings:**

```bash
$22=3     # Enable homing (bit 0) + single-axis $H<X|Y|Z> commands (bit 1)
$23=0     # Homing searches toward negative by default; set bits to reverse per axis
$24=100   # Locate feed rate (mm/min) — slow final approach
$25=1000  # Seek rate (mm/min) — fast initial search
$26=250   # Debounce delay (ms)
$27=5     # Pull-off distance (mm) — must fully clear the switch
$44=4     # Phase 1: home Z first (bitmask: Z=4)
$45=3     # Phase 2: home X and Y together (bitmask: X=1, Y=2)
```


TODO FIXME: currently max and min switch, need to rework that
> Auto-squaring requires **both** limit switches per ganged axis to be functional. If one switch is not triggering, homing will time out or produce a non-zero dual-axis offset in `$170`/`$171`.

### Safety

The collision switch on PA7 (EXP2 pin 5) is active as a **safety door** (`SAFETY_DOOR_ENABLE=1`): triggering it pauses motion and parks the spindle; clearing it allows a resume without a full reset.

Software safety:

```bash
$20=1       # Enable soft limits — requires homing first ($H)
$21=1       # Enable hard limits — alarm on unexpected switch trigger
$130=...    # X max travel (mm) — measure and set
$131=...    # Y max travel (mm)
$132=...    # Z max travel (mm)
```

#### Testing Limit Switches

The `Pn:` field of the `?` status report lists currently triggered inputs. Use this to verify each switch before homing.

1. Open `cnc-console` or the gSender terminal.
2. Send `?` — confirm `Pn:` is empty (no switches active at rest).
3. Manually press each switch one at a time and send `?` again.
4. Confirm the corresponding letter appears in `Pn:`.

| Switch       | Board label | Expected `Pn:` letter |
|--------------|-------------|----------------------|
| X- STOP      | PC1         | `X`                  |
| Y- STOP      | PC3         | `Y`                  |
| Z- STOP      | PC0         | `Z`                  |
| Probe        | PC13        | `P`                  |

If a switch does not appear, check wiring and the `$5` (invert limit inputs) setting.
