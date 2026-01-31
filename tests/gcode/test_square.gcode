%
(Test Square Pattern - 50mm x 50mm)
(Tests X, Y, Z axes and ganged motor configuration)
(Origin: Lower left corner)
(Safe Z clearance: 5mm)
(Work Z depth: -2mm)
(Feedrate: 500mm/min)

G21         ; Metric units
G90         ; Absolute positioning
G17         ; XY plane selection
G94         ; Feed per minute mode

; Home and set work zero
G28         ; Home all axes (optional, comment out if not homed)
G92 X0 Y0 Z0 ; Set current position as zero

; Safety message
M0          ; Pause - Ensure work area is clear, then resume

; Raise to safe Z
G0 Z5.0     ; Rapid to 5mm above work

; Move to start position
G0 X0 Y0    ; Move to origin

; Lower to work surface
G1 Z-2.0 F200 ; Plunge to -2mm at 200mm/min

; Cut square pattern (50mm x 50mm)
G1 X50.0 Y0 F500     ; Cut to right
G1 X50.0 Y50.0       ; Cut up
G1 X0 Y50.0          ; Cut left
G1 X0 Y0             ; Cut back to origin

; Lift to safe Z
G0 Z5.0     ; Rapid up to safe height

; Return to origin
G0 X0 Y0    ; Move back to start

; Diagonal test (tests both axes moving simultaneously)
G1 Z-2.0 F200        ; Plunge to work depth
G1 X25.0 Y25.0 F500  ; Diagonal to center
G0 Z5.0              ; Lift

; Circle test (tests coordinated motion)
G0 X25.0 Y0          ; Position for circle center at 25,25
G1 Z-2.0 F200        ; Plunge
G2 X25.0 Y0 I0 J25.0 F400 ; Cut 25mm radius circle (CW)
G0 Z5.0              ; Lift

; Return home
G0 X0 Y0 Z10.0       ; Return to safe position

M2          ; Program end
%
