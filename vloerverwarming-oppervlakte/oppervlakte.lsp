;; ============================================================================
;; VLOERVERWARMING OPPERVLAKTE BEREKENING
;; ============================================================================
;; Beschrijving: Berekent de totale oppervlakte van vloerverwarming polylines
;;               - Selecteer alle vloerverwarming polylines
;;               - Berekent de oppervlakte van elke polyline
;;               - Toont totale oppervlakte in m²
;;
;; Gebruik: Type VVO in AutoCAD
;; ============================================================================

(defun C:VVO (/ ss count i ent obj total_area area_m2 area_mm2)

  (princ "\n=== VLOERVERWARMING OPPERVLAKTE BEREKENING ===")

  ;; ----------------------------------------------------------------------------
  ;; STAP 1: Selecteer polylines
  ;; ----------------------------------------------------------------------------
  (princ "\nSelecteer alle vloerverwarming polylines:")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))

  (if (null ss)
    (progn
      (princ "\nGeen polylines geselecteerd. Geannuleerd.")
      (exit)
    )
  )

  (setq count (sslength ss))
  (princ (strcat "\n" (itoa count) " polyline(s) geselecteerd."))

  ;; ----------------------------------------------------------------------------
  ;; STAP 2: Bereken oppervlakte van elke polyline
  ;; ----------------------------------------------------------------------------
  (princ "\n\nBerekening gestart...")
  (setq total_area 0.0)
  (setq i 0)

  (while (< i count)
    (setq ent (ssname ss i))
    (setq obj (vlax-ename->vla-object ent))

    ;; Controleer of polyline gesloten is
    (if (vlax-property-available-p obj 'Closed)
      (progn
        ;; Als polyline niet gesloten is, waarschuw gebruiker
        (if (not (vlax-get obj 'Closed))
          (princ (strcat "\nWaarschuwing: Polyline " (itoa (1+ i)) " is niet gesloten!"))
        )
      )
    )

    ;; Bereken area (in mm² als drawing units mm zijn)
    (setq area_mm2 (vlax-curve-getArea ent))
    (setq area_m2 (/ area_mm2 1000000.0))  ;; Converteer mm² naar m²

    (princ (strcat "\nPolyline " (itoa (1+ i)) ": " (rtos area_m2 2 2) " m²"))

    ;; Tel op bij totaal
    (setq total_area (+ total_area area_m2))

    (setq i (1+ i))
  )

  ;; ----------------------------------------------------------------------------
  ;; STAP 3: Toon resultaat
  ;; ----------------------------------------------------------------------------
  (princ "\n\n========================================")
  (princ (strcat "\nTOTAAL OPPERVLAKTE: " (rtos total_area 2 2) " m²"))
  (princ "\n========================================")
  (princ)
)

;; ============================================================================
(princ "\nVloerverwarming Oppervlakte script geladen. Type VVO om te gebruiken.")
(princ)
