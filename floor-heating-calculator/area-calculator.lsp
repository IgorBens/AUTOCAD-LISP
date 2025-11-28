;; Floor Heating Area Calculator
;; This script calculates the total area covered by floor heating polylines
;; The floor heating consists of polylines that go out and come back, forming loops

(defun c:FHAREA (/ ss i ent obj total-area pline-area area-m2)
  ;; Initialize total area
  (setq total-area 0.0)

  ;; Prompt user to select floor heating polylines
  (princ "\nSelect floor heating polylines: ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))

  (if ss
    (progn
      ;; Loop through all selected polylines
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq obj (vlax-ename->vla-object ent))

        ;; Check if polyline is closed
        (if (= (vlax-get-property obj 'Closed) :vlax-true)
          (progn
            ;; Get area of closed polyline (in mm²)
            (setq pline-area (vlax-get-property obj 'Area))
            ;; Convert mm² to m² (divide by 1,000,000)
            (setq area-m2 (/ pline-area 1000000.0))
            (setq total-area (+ total-area area-m2))
            (princ (strcat "\nPolyline " (itoa (1+ i)) " area: "
                          (rtos area-m2 2 2) " m²"))
          )
          (progn
            ;; For open polylines, cannot calculate area
            (princ (strcat "\nWarning: Polyline " (itoa (1+ i))
                          " is not closed. Skipping area calculation."))
          )
        )
        (setq i (1+ i))
      )

      ;; Display total area
      (princ (strcat "\n\n================================="))
      (princ (strcat "\nTotal Floor Heating Area: "
                    (rtos total-area 2 2) " m²"))
      (princ (strcat "\n=================================\n"))
    )
    (princ "\nNo polylines selected.")
  )

  (princ)
)

;; Function to calculate area including both outgoing and return paths
(defun c:FHAREA2 (/ ss i ent obj total-area width pline-length pline-area length-m area-m2)
  ;; Initialize total area
  (setq total-area 0.0)

  ;; Prompt user to select floor heating polylines
  (princ "\nSelect floor heating polylines: ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))

  ;; Get width between outgoing and return paths (in mm)
  (setq width (getreal "\nEnter width of heating path (mm): "))

  (if (and ss width)
    (progn
      ;; Loop through all selected polylines
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq obj (vlax-ename->vla-object ent))

        ;; Get length of polyline (in mm)
        (setq pline-length (vlax-get-property obj 'Length))
        ;; Convert length from mm to m
        (setq length-m (/ pline-length 1000.0))

        ;; Calculate area as length * width (in mm²)
        (setq pline-area (* pline-length width))
        ;; Convert area from mm² to m²
        (setq area-m2 (/ pline-area 1000000.0))
        (setq total-area (+ total-area area-m2))

        (princ (strcat "\nPolyline " (itoa (1+ i))
                      " - Length: " (rtos length-m 2 2) " m"
                      " - Area: " (rtos area-m2 2 2) " m²"))

        (setq i (1+ i))
      )

      ;; Display total area
      (princ (strcat "\n\n================================="))
      (princ (strcat "\nTotal Floor Heating Area: "
                    (rtos total-area 2 2) " m²"))
      (princ (strcat "\n=================================\n"))
    )
    (princ "\nOperation cancelled or invalid input.")
  )

  (princ)
)

(princ "\nFloor Heating Area Calculator loaded.")
(princ "\nCommands available:")
(princ "\n  FHAREA  - Calculate area from closed polylines")
(princ "\n  FHAREA2 - Calculate area from polyline length and width")
(princ "\n")
