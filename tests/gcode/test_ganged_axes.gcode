%
(Ganged Axes Test Pattern)
(Specifically tests X and Y ganged motor coordination)
(Tests for racking, squareness, and synchronized movement)
(Safe height movements only - no cutting)

G21         ; Metric units
G90         ; Absolute positioning
G94         ; Feed per minute mode

; Set work zero
G92 X0 Y0 Z0

; Safe height
G0 Z10.0

M0          ; Pause - Check that gantry is square before continuing

; Test 1: X-axis ganged motor test (Y constant)
; Long X moves at different Y positions test X motor sync
G0 X0 Y0 F1000
G1 X100.0       ; Long X move at Y0
G0 X0

G0 Y50.0        ; Move to Y50
G1 X100.0       ; Long X move at Y50
G0 X0

G0 Y100.0       ; Move to Y100  
G1 X100.0       ; Long X move at Y100
G0 X0 Y0

; Test 2: Y-axis ganged motor test (X constant)
; Long Y moves at different X positions test Y motor sync
G0 X0 Y0
G1 Y100.0 F1000 ; Long Y move at X0
G0 Y0

G0 X50.0        ; Move to X50
G1 Y100.0       ; Long Y move at X50
G0 Y0

G0 X100.0       ; Move to X100
G1 Y100.0       ; Long Y move at X100
G0 X0 Y0

; Test 3: Diagonal moves (tests both ganged pairs simultaneously)
G0 X0 Y0
G1 X100.0 Y100.0 F800  ; Diagonal corner to corner
G1 X0 Y0                ; Return diagonal

G1 X100.0 Y0            ; Bottom right
G1 X0 Y100.0            ; Cross diagonal to top left
G1 X100.0 Y100.0        ; Top right
G1 X0 Y0                ; Back to origin

; Test 4: Square pattern at different speeds
; Slower speeds may reveal sync issues
G0 X10.0 Y10.0

G1 X90.0 Y10.0 F200     ; Slow speed
G1 X90.0 Y90.0
G1 X10.0 Y90.0
G1 X10.0 Y10.0

G1 X90.0 Y10.0 F1000    ; Fast speed
G1 X90.0 Y90.0
G1 X10.0 Y90.0
G1 X10.0 Y10.0

; Test 5: Auto-squaring test pattern
; Rapid direction changes test auto-squaring capability
G0 X20.0 Y20.0 F2000
G1 X80.0 Y20.0
G1 X80.0 Y80.0
G1 X20.0 Y80.0
G1 X20.0 Y20.0

G1 X50.0 Y50.0          ; To center
G1 X80.0 Y80.0          ; To corner
G1 X20.0 Y20.0          ; To opposite corner
G1 X50.0 Y50.0          ; Back to center

; Return home and check squareness
G0 X0 Y0 Z10.0

M0          ; Pause - Check if gantry is still square

; Final return
G0 X0 Y0 Z0

M2          ; Program end

; NOTES FOR TESTING:
; - Watch for any racking or skewing during long moves
; - Listen for unusual motor sounds indicating sync issues  
; - Verify corners are square after completion
; - Check that X and Y axes return to exact zero
; - If auto-squaring is enabled, dual limit switches should correct any drift
%
