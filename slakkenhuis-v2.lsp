;; ============================================================================
;; SLAKKENHUIS V2 - DUBBELE SPIRAAL (Aanvoer + Retour)
;; ============================================================================
;; Vloerverwarming werkt met dubbele spiraal:
;;   - Aanvoer: van buiten naar binnen (200mm stappen voor legpatroon 100mm)
;;   - Retour: van binnen naar buiten (tussen aanvoer ringen in)
;;
;; TEST: Simpele versie met rechte lijnen eerst
;;
;; Gebruik: Type VVS2 in AutoCAD
;; ============================================================================

(defun C:VVS2 (/ obj legpatroon offset_dist current_obj new_obj loop_count
                obj_data minx miny maxx maxy pt center_pt last_ent item
                contour_obj all_rings)

  (princ "\n=== SLAKKENHUIS V2 - DUBBELE SPIRAAL TEST ===")

  ;; ----------------------------------------------------------------------------
  ;; STAP 1: Selecteer object
  ;; ----------------------------------------------------------------------------
  (princ "\nSelecteer een object:")
  (setq obj (car (entsel)))

  (if (null obj)
    (progn
      (princ "\nGeen object geselecteerd.")
      (exit)
    )
  )

  ;; ----------------------------------------------------------------------------
  ;; STAP 2: Vraag legpatroon (dit bepaalt de uiteindelijke afstand)
  ;; ----------------------------------------------------------------------------
  (setq legpatroon (getdist "\nGeef legpatroon (bijv. 100 of 150): "))

  (if (null legpatroon)
    (progn
      (princ "\nGeen patroon gegeven.")
      (exit)
    )
  )

  ;; Voor dubbele spiraal: offset moet 2x het legpatroon zijn
  (setq offset_dist (* 2 legpatroon))

  (princ (strcat "\nLegpatroon: " (rtos legpatroon 2 0) "mm"))
  (princ (strcat "\nOffset afstand: " (rtos offset_dist 2 0) "mm (2x legpatroon)"))

  ;; ----------------------------------------------------------------------------
  ;; STAP 3: Bereken middenpunt
  ;; ----------------------------------------------------------------------------
  (setq obj_data (entget obj))
  (setq minx nil)
  (setq miny nil)
  (setq maxx nil)
  (setq maxy nil)

  (foreach item obj_data
    (if (equal (car item) 10)
      (progn
        (setq pt (cdr item))
        (if (or (null minx) (< (car pt) minx)) (setq minx (car pt)))
        (if (or (null maxx) (> (car pt) maxx)) (setq maxx (car pt)))
        (if (or (null miny) (< (cadr pt) miny)) (setq miny (cadr pt)))
        (if (or (null maxy) (> (cadr pt) maxy)) (setq maxy (cadr pt)))
      )
    )
  )

  (setq center_pt (list (/ (+ minx maxx) 2.0) (/ (+ miny maxy) 2.0)))

  ;; ----------------------------------------------------------------------------
  ;; STAP 4: Maak 50mm contour
  ;; ----------------------------------------------------------------------------
  (setq last_ent (entlast))
  (command "_.OFFSET" 50 obj center_pt "")
  (setq contour_obj (entlast))

  (if (equal contour_obj last_ent)
    (progn
      (princ "\nKon geen contour maken.")
      (exit)
    )
  )

  (princ "\n50mm contour gemaakt!")

  ;; ----------------------------------------------------------------------------
  ;; STAP 5: Maak AANVOER ringen (met 2x legpatroon afstand)
  ;; ----------------------------------------------------------------------------
  (princ "\nMaak AANVOER ringen (van buiten naar binnen)...")

  (setq all_rings (list contour_obj))
  (setq current_obj contour_obj)
  (setq loop_count 0)

  (while (and (< loop_count 10))  ;; Max 10 voor test
    (setq loop_count (1+ loop_count))
    (setq last_ent (entlast))

    (command "_.OFFSET" offset_dist current_obj center_pt "")
    (setq new_obj (entlast))

    (if (not (equal new_obj last_ent))
      (progn
        (setq current_obj new_obj)
        (setq all_rings (append all_rings (list new_obj)))
        (princ (strcat "\nAanvoer ring " (itoa loop_count) " gemaakt."))
      )
      (progn
        (princ "\nGeen ruimte meer voor aanvoer ringen.")
        (setq loop_count 999)
      )
    )
  )

  (princ (strcat "\n\nTotaal " (itoa (length all_rings)) " aanvoer ringen gemaakt."))

  ;; ----------------------------------------------------------------------------
  ;; STAP 6: KLEUR de ringen ROOD (voor visualisatie)
  ;; ----------------------------------------------------------------------------
  (princ "\nKleur aanvoer ringen rood...")

  (foreach ring all_rings
    (command "_.CHPROP" ring "" "C" "1" "")  ;; Kleur 1 = Rood
  )

  (princ "\n\n=== EERSTE TEST KLAAR ===")
  (princ "\nWat je nu ziet zijn de AANVOER ringen (rood).")
  (princ "\nZe staan op 2x het legpatroon van elkaar (dus 200mm als je 100mm opgaf).")
  (princ "\n\nVertel me:")
  (princ "\n1. Zie je rode ringen met grotere afstand ertussen?")
  (princ "\n2. Zijn er genoeg ringen gemaakt?")
  (princ "\n\nDan kan ik verder met stap 2: RETOUR ringen maken tussen de aanvoer in!")

  (princ "\n=========================")
  (princ)
)

;; ============================================================================
(princ "\nSlakkenhuis V2 geladen. Type VVS2 om te gebruiken.")
(princ)
