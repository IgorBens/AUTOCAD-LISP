;; Floor Heating Area Calculator
;; This script calculates the total area covered by floor heating polylines
;; The floor heating consists of polylines that go out and come back, forming loops

(defun c:FHAREA (/ ss i ent obj total-area pline-area)
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
            ;; Get area of closed polyline
            (setq pline-area (vlax-get-property obj 'Area))
            (setq total-area (+ total-area pline-area))
            (princ (strcat "\nPolyline " (itoa (1+ i)) " area: "
                          (rtos pline-area 2 2) " sq units"))
          )
          (progn
            ;; For open polylines, calculate approximate area
            (princ (strcat "\nWarning: Polyline " (itoa (1+ i))
                          " is not closed. Skipping area calculation."))
          )
        )
        (setq i (1+ i))
      )

      ;; Display total area
      (princ (strcat "\n\n================================="))
      (princ (strcat "\nTotal Floor Heating Area: "
                    (rtos total-area 2 2) " sq units"))
      (princ (strcat "\n=================================\n"))
    )
    (princ "\nNo polylines selected.")
  )

  (princ)
)

;; Function to calculate area including both outgoing and return paths
(defun c:FHAREA2 (/ ss i ent obj total-area width length pline-length)
  ;; Initialize total area
  (setq total-area 0.0)

  ;; Prompt user to select floor heating polylines
  (princ "\nSelect floor heating polylines: ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))

  ;; Get width between outgoing and return paths
  (setq width (getreal "\nEnter distance between outgoing and return paths (mm): "))

  (if (and ss width)
    (progn
      ;; Loop through all selected polylines
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq obj (vlax-ename->vla-object ent))

        ;; Get length of polyline
        (setq pline-length (vlax-get-property obj 'Length))

        ;; Calculate area as length * width (for one side)
        ;; Multiply by 2 if counting both outgoing and return
        (setq pline-area (* pline-length width))
        (setq total-area (+ total-area pline-area))

        (princ (strcat "\nPolyline " (itoa (1+ i))
                      " - Length: " (rtos pline-length 2 2)
                      " - Area: " (rtos pline-area 2 2) " sq units"))

        (setq i (1+ i))
      )

      ;; Display total area
      (princ (strcat "\n\n================================="))
      (princ (strcat "\nTotal Floor Heating Area: "
                    (rtos total-area 2 2) " sq units"))
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
