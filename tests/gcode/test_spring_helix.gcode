%
(Spring/DNA Helix Pattern)
(Beautiful 3D helical pattern - like a spring or DNA strand)
(Tests smooth coordinated circular and Z motion)
(Work area: 40mm diameter x 60mm height)
(Origin: Center bottom of pattern)

G21         ; Metric units
G90         ; Absolute positioning
G17         ; XY plane selection
G94         ; Feed per minute mode

; Initialize
G92 X0 Y0 Z0    ; Set current position as work zero
G0 Z5.0         ; Safe height

M0          ; Pause - Clear work area and verify settings

; ==========================================
; SPRING HELIX - Single strand going up
; ==========================================
(Single helix spring - 20mm radius, 10 turns, 60mm height)

G0 X20.0 Y0 Z0  ; Move to start position
F450            ; Set feed rate

; Helix: 10 complete circles while rising 60mm (6mm per revolution)
G2 X20.0 Y0 Z6.0 I-20.0 J0     ; Turn 1
G2 X20.0 Y0 Z12.0 I-20.0 J0    ; Turn 2
G2 X20.0 Y0 Z18.0 I-20.0 J0    ; Turn 3
G2 X20.0 Y0 Z24.0 I-20.0 J0    ; Turn 4
G2 X20.0 Y0 Z30.0 I-20.0 J0    ; Turn 5
G2 X20.0 Y0 Z36.0 I-20.0 J0    ; Turn 6
G2 X20.0 Y0 Z42.0 I-20.0 J0    ; Turn 7
G2 X20.0 Y0 Z48.0 I-20.0 J0    ; Turn 8
G2 X20.0 Y0 Z54.0 I-20.0 J0    ; Turn 9
G2 X20.0 Y0 Z60.0 I-20.0 J0    ; Turn 10

G0 Z65.0        ; Lift off top

; ==========================================
; COMPRESSED SPRING - Tight coils
; ==========================================
(Compressed spring - tighter pitch)

G0 X15.0 Y0 Z0  ; Smaller radius, start at bottom
F500

; 10 turns in only 30mm height (3mm per revolution)
G2 X15.0 Y0 Z3.0 I-15.0 J0
G2 X15.0 Y0 Z6.0 I-15.0 J0
G2 X15.0 Y0 Z9.0 I-15.0 J0
G2 X15.0 Y0 Z12.0 I-15.0 J0
G2 X15.0 Y0 Z15.0 I-15.0 J0
G2 X15.0 Y0 Z18.0 I-15.0 J0
G2 X15.0 Y0 Z21.0 I-15.0 J0
G2 X15.0 Y0 Z24.0 I-15.0 J0
G2 X15.0 Y0 Z27.0 I-15.0 J0
G2 X15.0 Y0 Z30.0 I-15.0 J0

G0 Z35.0

; ==========================================
; VARIABLE PITCH HELIX - Spring under tension
; ==========================================
(Variable pitch - simulates spring being stretched)

G0 X18.0 Y0 Z0
F400

; Starts tight, gradually increases spacing
G2 X18.0 Y0 Z2.0 I-18.0 J0     ; 2mm spacing
G2 X18.0 Y0 Z5.0 I-18.0 J0     ; 3mm spacing
G2 X18.0 Y0 Z9.0 I-18.0 J0     ; 4mm spacing
G2 X18.0 Y0 Z14.0 I-18.0 J0    ; 5mm spacing
G2 X18.0 Y0 Z20.0 I-18.0 J0    ; 6mm spacing
G2 X18.0 Y0 Z27.0 I-18.0 J0    ; 7mm spacing
G2 X18.0 Y0 Z35.0 I-18.0 J0    ; 8mm spacing
G2 X18.0 Y0 Z44.0 I-18.0 J0    ; 9mm spacing
G2 X18.0 Y0 Z54.0 I-18.0 J0    ; 10mm spacing
G2 X18.0 Y0 Z65.0 I-18.0 J0    ; 11mm spacing

G0 Z70.0

; ==========================================
; DOUBLE HELIX - DNA style pattern
; ==========================================
(Double helix - two intertwined strands)

; Strand 1 (starts at 0 degrees)
G0 X12.0 Y0 Z0
F350

; Go up with first strand (5 turns)
G2 X12.0 Y0 Z12.0 I-12.0 J0    ; Turn 1
G2 X12.0 Y0 Z24.0 I-12.0 J0    ; Turn 2
G2 X12.0 Y0 Z36.0 I-12.0 J0    ; Turn 3
G2 X12.0 Y0 Z48.0 I-12.0 J0    ; Turn 4
G2 X12.0 Y0 Z60.0 I-12.0 J0    ; Turn 5

G0 Z65.0        ; Lift

; Strand 2 (starts at 180 degrees - opposite side)
G0 X-12.0 Y0 Z0
F350

; Go up with second strand (5 turns, opposite side)
G2 X-12.0 Y0 Z12.0 I12.0 J0    ; Turn 1
G2 X-12.0 Y0 Z24.0 I12.0 J0    ; Turn 2
G2 X-12.0 Y0 Z36.0 I12.0 J0    ; Turn 3
G2 X-12.0 Y0 Z48.0 I12.0 J0    ; Turn 4
G2 X-12.0 Y0 Z60.0 I12.0 J0    ; Turn 5

G0 Z65.0

; ==========================================
; CONE SPRING - Conical helix
; ==========================================
(Conical spring - radius decreases as it rises)

G0 X20.0 Y0 Z0
F400

; Start large, shrink as we go up
G2 X18.0 Y0 Z6.0 I-20.0 J0     ; Turn 1, shrink to R18
G2 X16.0 Y0 Z12.0 I-18.0 J0    ; Turn 2, shrink to R16
G2 X14.0 Y0 Z18.0 I-16.0 J0    ; Turn 3, shrink to R14
G2 X12.0 Y0 Z24.0 I-14.0 J0    ; Turn 4, shrink to R12
G2 X10.0 Y0 Z30.0 I-12.0 J0    ; Turn 5, shrink to R10
G2 X8.0 Y0 Z36.0 I-10.0 J0     ; Turn 6, shrink to R8
G2 X6.0 Y0 Z42.0 I-8.0 J0      ; Turn 7, shrink to R6
G2 X5.0 Y0 Z48.0 I-6.0 J0      ; Turn 8, shrink to R5

G0 Z55.0

; ==========================================
; REVERSE CONE - Expanding helix
; ==========================================
(Reverse cone - radius increases as it rises)

G0 X5.0 Y0 Z0
F400

; Start small, expand as we go up
G2 X7.0 Y0 Z6.0 I-5.0 J0       ; Turn 1, grow to R7
G2 X9.0 Y0 Z12.0 I-7.0 J0      ; Turn 2, grow to R9
G2 X11.0 Y0 Z18.0 I-9.0 J0     ; Turn 3, grow to R11
G2 X13.0 Y0 Z24.0 I-11.0 J0    ; Turn 4, grow to R13
G2 X15.0 Y0 Z30.0 I-13.0 J0    ; Turn 5, grow to R15
G2 X17.0 Y0 Z36.0 I-15.0 J0    ; Turn 6, grow to R17
G2 X19.0 Y0 Z42.0 I-17.0 J0    ; Turn 7, grow to R19
G2 X20.0 Y0 Z48.0 I-19.0 J0    ; Turn 8, grow to R20

G0 Z55.0

; ==========================================
; SINUSOIDAL HELIX - Wavy spring
; ==========================================
(Wavy helix - radius oscillates while rising)

G0 X10.0 Y0 Z0
F350

; Radius oscillates: 10->15->10->15->10 over 5 turns
G2 X15.0 Y0 Z6.0 I-10.0 J0     ; Expand
G2 X10.0 Y0 Z12.0 I-15.0 J0    ; Contract
G2 X15.0 Y0 Z18.0 I-10.0 J0    ; Expand
G2 X10.0 Y0 Z24.0 I-15.0 J0    ; Contract
G2 X15.0 Y0 Z30.0 I-10.0 J0    ; Expand
G2 X10.0 Y0 Z36.0 I-15.0 J0    ; Contract
G2 X15.0 Y0 Z42.0 I-10.0 J0    ; Expand
G2 X10.0 Y0 Z48.0 I-15.0 J0    ; Contract

G0 Z55.0

; ==========================================
; Return home
; ==========================================
G0 X0 Y0 Z10.0  ; Safe position above work
G0 Z0           ; Lower to work zero

M2              ; Program end

; TESTING NOTES:
; - This file tests smooth helical interpolation
; - Watch for consistent circular motion combined with Z
; - Should NOT see faceting or stepping in circles
; - Z movement should be smooth and synchronized
; - Good test for motion planning and look-ahead
; - Tests ganged X/Y motors in circular coordinated motion
; - All patterns are air moves (safe for testing)
%
