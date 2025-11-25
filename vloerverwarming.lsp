;; ============================================================================
;; VLOERVERWARMING KRINGEN - VERBETERD
;; ============================================================================
;; Beschrijving: Maakt automatisch vloerverwarming kringen
;;               1. Selecteer een object (rechthoek, polyline, etc.)
;;               2. Maakt 50mm contour naar BINNEN (als rand)
;;               3. Offset vanaf die contour verder naar binnen zoveel mogelijk keer
;;
;; Layers:
;;   - Zone Contour: 0_14 TD - Zone Contour
;;   - Vloerverwarming: 0_05 TD - Vloerverwarming
;;
;; Gebruik: Type VV in AutoCAD
;; ============================================================================

;; ----------------------------------------------------------------------------
;; HELPER FUNCTIE: Maak layer aan als die niet bestaat
;; ----------------------------------------------------------------------------
(defun make-layer (layer-name / layer-list)
  (if (not (tblsearch "LAYER" layer-name))
    (progn
      (command "_.LAYER" "M" layer-name "")
      (princ (strcat "\nLayer '" layer-name "' aangemaakt."))
    )
  )
)

;; ----------------------------------------------------------------------------
;; HELPER FUNCTIE: Zet entity naar specifieke layer
;; ----------------------------------------------------------------------------
(defun set-entity-layer (ent layer-name / ent-data)
  (setq ent-data (entget ent))
  (setq ent-data (subst (cons 8 layer-name) (assoc 8 ent-data) ent-data))
  (entmod ent-data)
)

;; ----------------------------------------------------------------------------
;; HOOFDFUNCTIE
;; ----------------------------------------------------------------------------
(defun C:VV (/ obj offset_dist continue current_obj new_obj loop_count
              obj_data vert_list minx miny maxx maxy pt center_pt last_ent item
              contour_obj layer-zone layer-vv)

  (princ "\n=== VLOERVERWARMING KRINGEN ===")

  ;; ----------------------------------------------------------------------------
  ;; STAP 1: Definieer en maak layers aan
  ;; ----------------------------------------------------------------------------
  (setq layer-zone "0_14 TD - Zone Contour")
  (setq layer-vv "0_05 TD - Vloerverwarming")

  (make-layer layer-zone)
  (make-layer layer-vv)

  ;; ----------------------------------------------------------------------------
  ;; STAP 2: Selecteer object
  ;; ----------------------------------------------------------------------------
  (princ "\nSelecteer zone contour (rechthoek, polyline, etc.):")
  (setq obj (car (entsel)))

  (if (null obj)
    (progn
      (princ "\nGeen object geselecteerd. Geannuleerd.")
      (exit)
    )
  )

  (princ "\nZone geselecteerd!")

  ;; Zet geselecteerd object naar zone contour layer
  (set-entity-layer obj layer-zone)
  (princ (strcat "\nZone naar layer '" layer-zone "' verplaatst."))

  ;; ----------------------------------------------------------------------------
  ;; STAP 3: Bereken middenpunt van object
  ;; ----------------------------------------------------------------------------
  (setq obj_data (entget obj))

  ;; Verzamel alle vertices voor bounding box
  (setq vert_list (list))
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

  ;; Bereken middenpunt
  (setq center_pt (list (/ (+ minx maxx) 2.0) (/ (+ miny maxy) 2.0)))

  (princ "\nMiddenpunt berekend!")

  ;; ----------------------------------------------------------------------------
  ;; STAP 4: Maak 50mm contour naar BINNEN (blijft in zone layer)
  ;; ----------------------------------------------------------------------------
  (princ "\nMaak 50mm contour naar binnen...")

  (setq last_ent (entlast))

  ;; Offset 50mm naar binnen (gebruik middenpunt)
  (command "_.OFFSET" 50 obj center_pt "")

  ;; Check of contour is gemaakt
  (setq contour_obj (entlast))

  (if (equal contour_obj last_ent)
    (progn
      (princ "\nKon geen 50mm contour maken. Object te klein?")
      (exit)
    )
  )

  ;; Zet 50mm contour ook naar zone layer (dit is de rand van de zone)
  (set-entity-layer contour_obj layer-zone)

  (princ "\n50mm contour gemaakt (zone rand)!")

  ;; ----------------------------------------------------------------------------
  ;; STAP 5: Vraag offset afstand voor vloerverwarming kringen
  ;; ----------------------------------------------------------------------------
  (setq offset_dist (getdist "\nGeef offset afstand voor kringen (bijv. 100 of 150): "))

  (if (null offset_dist)
    (progn
      (princ "\nGeen afstand gegeven. Geannuleerd.")
      (exit)
    )
  )

  ;; ----------------------------------------------------------------------------
  ;; STAP 6: Offset naar binnen toe vanaf de 50mm contour
  ;; ----------------------------------------------------------------------------
  (princ "\nStart met offset van vloerverwarming kringen...")

  (setq current_obj contour_obj)
  (setq continue T)
  (setq loop_count 0)

  (while (and continue (< loop_count 100))
    (setq loop_count (1+ loop_count))

    ;; Bewaar huidige laatste entiteit
    (setq last_ent (entlast))

    ;; Offset naar binnen (gebruik middenpunt - dat is altijd binnen)
    (command "_.OFFSET" offset_dist current_obj center_pt "")

    ;; Check of er een nieuwe offset is gemaakt
    (setq new_obj (entlast))

    (if (not (equal new_obj last_ent))
      (progn
        ;; Succes - nieuwe offset gemaakt
        (setq current_obj new_obj)

        ;; Zet nieuwe kring naar vloerverwarming layer
        (set-entity-layer new_obj layer-vv)

        (princ (strcat "\nKring " (itoa loop_count) " gemaakt."))
      )
      (progn
        ;; Geen nieuwe offset - stop de loop
        (setq continue nil)
        (princ "\nGeen ruimte meer voor offset.")
      )
    )
  )

  (princ (strcat "\n\nKlaar! 50mm rand + " (itoa loop_count) " vloerverwarming kringen gemaakt."))
  (princ "\n=========================")
  (princ)
)

;; ============================================================================
(princ "\nVloerverwarming script geladen. Type VV om te gebruiken.")
(princ)
