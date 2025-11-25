;; ============================================================================
;; SLAKKENHUIS TEST - SIMPEL
;; ============================================================================
;; Dit is een eerste test om te kijken of we ringen kunnen verbinden
;; tot een doorlopende spiraal
;;
;; Gebruik: Type VVS in AutoCAD
;; ============================================================================

(defun C:VVS (/ obj offset_dist current_obj new_obj loop_count
               obj_data vert_list minx miny maxx maxy pt center_pt last_ent item
               contour_obj all_rings ring1 ring2)

  (princ "\n=== SLAKKENHUIS TEST ===")

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
  ;; STAP 2: Bereken middenpunt
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
  ;; STAP 3: Maak 50mm contour + vraag offset
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

  (setq offset_dist (getdist "\nGeef offset afstand (bijv. 150): "))

  ;; ----------------------------------------------------------------------------
  ;; STAP 4: Maak MAXIMAAL 3 extra ringen (om test simpel te houden)
  ;; ----------------------------------------------------------------------------
  (princ "\nMaak maximaal 3 ringen...")

  (setq all_rings (list contour_obj))  ;; Bewaar alle gemaakte ringen
  (setq current_obj contour_obj)
  (setq loop_count 0)

  (while (and (< loop_count 3))
    (setq loop_count (1+ loop_count))
    (setq last_ent (entlast))

    (command "_.OFFSET" offset_dist current_obj center_pt "")
    (setq new_obj (entlast))

    (if (not (equal new_obj last_ent))
      (progn
        (setq current_obj new_obj)
        (setq all_rings (append all_rings (list new_obj)))  ;; Voeg toe aan lijst
        (princ (strcat "\nKring " (itoa loop_count) " gemaakt."))
      )
      (progn
        (princ "\nGeen ruimte meer.")
        (setq loop_count 999)  ;; Stop loop
      )
    )
  )

  (princ (strcat "\n\nKlaar! " (itoa (length all_rings)) " ringen gemaakt."))

  ;; ----------------------------------------------------------------------------
  ;; STAP 5: SIMPELE TEST - verbind de EERSTE 2 ringen
  ;; ----------------------------------------------------------------------------
  (if (>= (length all_rings) 2)
    (progn
      (princ "\n\n=== START SLAKKENHUIS TEST ===")
      (princ "\nIk ga nu proberen de eerste 2 ringen te verbinden...")

      ;; Pak de eerste 2 ringen
      (setq ring1 (nth 0 all_rings))
      (setq ring2 (nth 1 all_rings))

      ;; TEST: probeer ze gewoon te joinen zonder iets te breken
      (princ "\nTest 1: Probeer direct te joinen (dit zal waarschijnlijk niet werken)...")
      (command "_.JOIN" ring1 ring2 "")

      (princ "\n\nWat gebeurde er? Zijn de 2 ringen nu 1 object of nog steeds 2 aparte ringen?")
      (princ "\n(Check in AutoCAD en vertel me wat je ziet!)")
    )
    (progn
      (princ "\n\nTe weinig ringen gemaakt voor slakkenhuis test.")
    )
  )

  (princ "\n=========================")
  (princ)
)

;; ============================================================================
(princ "\nSlakkenhuis test geladen. Type VVS om te gebruiken.")
(princ)
