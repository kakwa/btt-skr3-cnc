%
(3D Spiral and Helix Test Pattern)
(Complex test combining circles with Z-axis movement)
(Tests coordinated 3-axis motion and circular interpolation)
(Work area: 60mm x 60mm x 20mm)
(Origin: Center of work area)
(Feed rates: 300-600mm/min)

G21         ; Metric units
G90         ; Absolute positioning
G17         ; XY plane selection
G94         ; Feed per minute mode

; Initialize
G92 X0 Y0 Z0    ; Set current position as work zero
G0 Z10.0        ; Safe height

M0          ; Pause - Ensure work area is clear

; ==========================================
; Test 1: Helical Descent (Circle while going down)
; ==========================================
(Helical descent - 20mm radius circle descending 10mm)
G0 X20.0 Y0     ; Position to start of circle
G0 Z5.0         ; Start height

; Helix down: Complete 5 circles while descending 10mm (2mm per circle)
G2 X20.0 Y0 Z3.0 I-20.0 J0 F400    ; Circle 1, descend to Z3
G2 X20.0 Y0 Z1.0 I-20.0 J0 F400    ; Circle 2, descend to Z1
G2 X20.0 Y0 Z-1.0 I-20.0 J0 F400   ; Circle 3, descend to Z-1
G2 X20.0 Y0 Z-3.0 I-20.0 J0 F400   ; Circle 4, descend to Z-3
G2 X20.0 Y0 Z-5.0 I-20.0 J0 F400   ; Circle 5, descend to Z-5

G0 Z10.0        ; Retract

; ==========================================
; Test 2: Multi-level Circles (Stacked circles at different Z heights)
; ==========================================
(Stacked circles - 15mm radius at different heights)
G0 X15.0 Y0 Z5.0

; Bottom level
G1 Z-5.0 F200
G2 X15.0 Y0 I-15.0 J0 F500
G0 Z-3.0

; Middle level
G2 X15.0 Y0 I-15.0 J0 F500
G0 Z-1.0

; Upper level
G2 X15.0 Y0 I-15.0 J0 F500
G0 Z1.0

; Top level
G2 X15.0 Y0 I-15.0 J0 F500

G0 Z10.0        ; Retract

; ==========================================
; Test 3: Expanding Spiral (Radius increases while going up)
; ==========================================
(Expanding spiral - radius grows from 5mm to 25mm over 10mm height)
G0 X5.0 Y0      ; Start at small radius
G1 Z-5.0 F200   ; Lower to start height

; Expanding spiral: each circle is larger and higher
G2 X8.0 Y0 Z-3.0 I-5.0 J0 F350     ; R=5mm->8mm, rise 2mm
G2 X12.0 Y0 Z-1.0 I-8.0 J0 F350    ; R=8mm->12mm, rise 2mm
G2 X17.0 Y0 Z1.0 I-12.0 J0 F350    ; R=12mm->17mm, rise 2mm
G2 X23.0 Y0 Z3.0 I-17.0 J0 F350    ; R=17mm->23mm, rise 2mm
G2 X25.0 Y0 Z5.0 I-23.0 J0 F350    ; R=23mm->25mm, rise 2mm

G0 Z10.0        ; Retract

; ==========================================
; Test 4: Conical Spiral (Cone shape)
; ==========================================
(Conical spiral - creates cone shape)
G0 X25.0 Y0     ; Start at widest point
G1 Z-8.0 F200   ; Lower to bottom

; Spiral up while radius decreases (cone shape)
G2 X22.0 Y0 Z-6.0 I-25.0 J0 F400   ; Circle, rise 2mm, shrink
G2 X19.0 Y0 Z-4.0 I-22.0 J0 F400   ; Circle, rise 2mm, shrink
G2 X16.0 Y0 Z-2.0 I-19.0 J0 F400   ; Circle, rise 2mm, shrink
G2 X13.0 Y0 Z0 I-16.0 J0 F400      ; Circle, rise 2mm, shrink
G2 X10.0 Y0 Z2.0 I-13.0 J0 F400    ; Circle, rise 2mm, shrink
G2 X7.0 Y0 Z4.0 I-10.0 J0 F400     ; Circle, rise 2mm, shrink
G2 X5.0 Y0 Z6.0 I-7.0 J0 F400      ; Circle, rise 2mm, shrink to point

G0 Z10.0        ; Retract

; ==========================================
; Test 5: Wave Pattern (Sine wave in 3D)
; ==========================================
(3D wave - circular path with oscillating Z)
G0 X0 Y20.0     ; Start position
G1 Z-5.0 F200   ; Lower to start

; Quarter circles with Z oscillation creating wave pattern
G3 X20.0 Y0 Z-3.0 I0 J-20.0 F400   ; Quarter circle CCW, rise
G3 X0 Y-20.0 Z-1.0 I-20.0 J0 F400  ; Quarter circle CCW, rise
G3 X-20.0 Y0 Z1.0 I0 J20.0 F400    ; Quarter circle CCW, rise
G3 X0 Y20.0 Z3.0 I20.0 J0 F400     ; Quarter circle CCW, rise (complete circle)

; Continue wave (going down now)
G3 X20.0 Y0 Z1.0 I0 J-20.0 F400    ; Quarter circle CCW, descend
G3 X0 Y-20.0 Z-1.0 I-20.0 J0 F400  ; Quarter circle CCW, descend
G3 X-20.0 Y0 Z-3.0 I0 J20.0 F400   ; Quarter circle CCW, descend
G3 X0 Y20.0 Z-5.0 I20.0 J0 F400    ; Quarter circle CCW, descend

G0 Z10.0        ; Retract

; ==========================================
; Test 6: Figure-8 with Z variation
; ==========================================
(3D figure-8 pattern)
G0 X0 Y10.0     ; Start position
G1 Z-2.0 F200

; First loop (going up)
G2 X0 Y-10.0 Z0 I0 J-10.0 F500     ; Half circle CW, rise 2mm
; Second loop (going down)
G3 X0 Y10.0 Z-2.0 I0 J10.0 F500    ; Half circle CCW, descend 2mm

; Repeat figure-8 at different Z levels
G2 X0 Y-10.0 Z0 I0 J-10.0 F500
G3 X0 Y10.0 Z-2.0 I0 J10.0 F500

G2 X0 Y-10.0 Z0 I0 J-10.0 F500
G3 X0 Y10.0 Z-2.0 I0 J10.0 F500

G0 Z10.0        ; Retract

; ==========================================
; Test 7: Concentric Circles at Different Heights
; ==========================================
(Concentric circles stepping up)
G0 X5.0 Y0 Z-5.0

; Small to large circles, each at higher Z
G2 X5.0 Y0 I-5.0 J0 F600          ; 5mm radius at Z-5
G0 Z-3.0
G0 X10.0 Y0
G2 X10.0 Y0 I-10.0 J0 F600        ; 10mm radius at Z-3
G0 Z-1.0
G0 X15.0 Y0
G2 X15.0 Y0 I-15.0 J0 F600        ; 15mm radius at Z-1
G0 Z1.0
G0 X20.0 Y0
G2 X20.0 Y0 I-20.0 J0 F600        ; 20mm radius at Z1
G0 Z3.0
G0 X25.0 Y0
G2 X25.0 Y0 I-25.0 J0 F600        ; 25mm radius at Z3

G0 Z10.0        ; Retract

; ==========================================
; Test 8: Spherical Motion Test
; ==========================================
(Approximate sphere - arcs in different planes)
G0 X0 Y15.0 Z0

; XY plane arcs at different Z heights (dome shape)
G1 Z2.0 F300
G3 X0 Y-15.0 I0 J-15.0 F500       ; Top arc
G0 Z0
G0 Y15.0
G3 X0 Y-15.0 I0 J-15.0 F500       ; Middle arc
G0 Z-2.0
G0 Y15.0
G3 X0 Y-15.0 I0 J-15.0 F500       ; Bottom arc

G0 Z10.0        ; Retract

; ==========================================
; Return to origin
; ==========================================
G0 X0 Y0 Z10.0  ; Safe position
G0 Z0           ; Back to work zero

M2              ; Program end

; NOTES:
; - G2 = Clockwise circular motion (CW)
; - G3 = Counter-clockwise circular motion (CCW)
; - I,J = Circle center offset from current position
; - Z parameter in arc moves creates helical motion
; - All moves are in absolute coordinates (G90)
; - Test exercises X, Y, Z coordination simultaneously
; - Watch for smooth helical motion without stuttering
; - Check that Z movements are synchronized with circular motion
%
