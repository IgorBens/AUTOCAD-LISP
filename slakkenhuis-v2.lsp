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
                contour_obj all_rings retour_rings ring_count current_ring new_retour)

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

  ;; ----------------------------------------------------------------------------
  ;; STAP 7: Maak RETOUR ringen (tussen aanvoer ringen in)
  ;; ----------------------------------------------------------------------------
  (princ "\n\nMaak RETOUR ringen (tussen aanvoer ringen)...")

  (setq retour_rings (list))
  (setq ring_count 0)

  ;; Loop door alle aanvoer ringen (behalve de laatste)
  (while (< ring_count (1- (length all_rings)))
    (setq current_ring (nth ring_count all_rings))
    (setq last_ent (entlast))

    ;; Offset met 1x legpatroon (dit valt precies tussen 2 aanvoer ringen)
    (command "_.OFFSET" legpatroon current_ring center_pt "")
    (setq new_retour (entlast))

    (if (not (equal new_retour last_ent))
      (progn
        (setq retour_rings (append retour_rings (list new_retour)))
        (princ (strcat "\nRetour ring " (itoa (1+ ring_count)) " gemaakt."))
      )
      (progn
        (princ "\nKon geen retour ring maken (te klein?).")
      )
    )

    (setq ring_count (1+ ring_count))
  )

  (princ (strcat "\n\nTotaal " (itoa (length retour_rings)) " retour ringen gemaakt."))

  ;; ----------------------------------------------------------------------------
  ;; STAP 8: KLEUR de retour ringen BLAUW
  ;; ----------------------------------------------------------------------------
  (princ "\nKleur retour ringen blauw...")

  (foreach ring retour_rings
    (command "_.CHPROP" ring "" "C" "5" "")  ;; Kleur 5 = Blauw
  )

  (princ "\n\n=== DUBBELE SPIRAAL TEST KLAAR ===")
  (princ "\nWat je nu ziet:")
  (princ "\n- ROOD = Aanvoer (van buiten naar binnen)")
  (princ "\n- BLAUW = Retour (van binnen naar buiten)")
  (princ (strcat "\n- Afstand tussen elke lijn: " (rtos legpatroon 2 0) "mm"))
  (princ "\n\nCheck:")
  (princ "\n1. Zie je ROOD-BLAUW-ROOD-BLAUW-ROOD patroon?")
  (princ "\n2. Is de afstand tussen alle lijnen ongeveer gelijk?")
  (princ "\n3. Is dit het juiste patroon voor vloerverwarming?")
  (princ "\n\nAls dit goed is, kan ik ze verbinden tot 1 doorlopende lijn!")

  (princ "\n=========================")
  (princ)
)

;; ============================================================================
(princ "\nSlakkenhuis V2 geladen. Type VVS2 om te gebruiken.")
(princ)
