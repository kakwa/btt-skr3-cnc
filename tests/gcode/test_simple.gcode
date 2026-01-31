%
(Simple Movement Test - No cutting)
(Tests basic X, Y, Z movements in air)
(Moves 10mm in each direction from origin)

G21         ; Metric units
G90         ; Absolute positioning
G94         ; Feed per minute mode

; Initialize
G92 X0 Y0 Z0 ; Set current position as work zero

; Test each axis individually (in air, safe Z)
G0 Z10.0    ; Raise Z to safe height

; Test X axis (and ganged X2 motor)
G0 X0 Y0    ; Start position
G1 X10.0 F500  ; Move +X
G1 X0           ; Return to X0

; Test Y axis (and ganged Y2 motor)
G1 Y10.0    ; Move +Y
G1 Y0       ; Return to Y0

; Test Z axis
G1 Z15.0 F200  ; Move Z up
G1 Z10.0        ; Return to safe Z

; Test diagonal XY (tests ganged motors together)
G1 X10.0 Y10.0 F500  ; Diagonal move
G1 X0 Y0              ; Return to origin

; Test small square in air (5mm)
G1 X5.0 Y0
G1 X5.0 Y5.0
G1 X0 Y5.0
G1 X0 Y0

; Return to start
G0 X0 Y0 Z10.0

M2          ; Program end
%
