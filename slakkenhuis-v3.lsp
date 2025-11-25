;; ============================================================================
;; SLAKKENHUIS V3 - VERBINDEN TEST
;; ============================================================================
;; Test om ringen te verbinden tot doorlopende spiraal
;;
;; Methode:
;;   1. Maak RODE ringen (aanvoer)
;;   2. Maak BLAUWE ringen (retour)
;;   3. EXPLODE alle ringen
;;   4. Verwijder segment rechtsboven van elke ring
;;   5. Verbind: ROOD (buiten→binnen) → BLAUW (binnen→buiten)
;;   6. JOIN tot 1 polyline
;;
;; TEST: Begin simpel met 2 rode ringen
;;
;; Gebruik: Type VVS3 in AutoCAD
;; ============================================================================

(defun C:VVS3 (/ obj legpatroon offset_dist obj_data minx miny maxx maxy pt
               center_pt last_ent item contour_obj ring1 ring2
               exploded_segments all_segments)

  (princ "\n=== SLAKKENHUIS V3 - VERBINDEN TEST ===")

  ;; ----------------------------------------------------------------------------
  ;; STAP 1: Selecteer object en bereken middenpunt
  ;; ----------------------------------------------------------------------------
  (princ "\nSelecteer een object:")
  (setq obj (car (entsel)))

  (if (null obj)
    (progn
      (princ "\nGeen object geselecteerd.")
      (exit)
    )
  )

  (setq legpatroon (getdist "\nGeef legpatroon (bijv. 100): "))
  (setq offset_dist (* 2 legpatroon))

  ;; Bereken middenpunt
  (setq obj_data (entget obj))
  (setq minx nil) (setq miny nil) (setq maxx nil) (setq maxy nil)

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
  ;; STAP 2: Maak 50mm contour + 1 extra ring (2 ringen totaal)
  ;; ----------------------------------------------------------------------------
  (princ "\nMaak 2 rode ringen...")

  (setq last_ent (entlast))
  (command "_.OFFSET" 50 obj center_pt "")
  (setq ring1 (entlast))
  (command "_.CHPROP" ring1 "" "C" "1" "")  ;; Rood

  (setq last_ent (entlast))
  (command "_.OFFSET" offset_dist ring1 center_pt "")
  (setq ring2 (entlast))
  (command "_.CHPROP" ring2 "" "C" "1" "")  ;; Rood

  (princ "\n2 rode ringen gemaakt!")

  ;; ----------------------------------------------------------------------------
  ;; STAP 3: EXPLODE BEIDE ringen
  ;; ----------------------------------------------------------------------------
  (princ "\n\nExplode beide ringen...")

  ;; Explode ring1
  (command "_.EXPLODE" ring1)
  (princ "\nRing 1 geëxplodeerd!")

  ;; Explode ring2
  (command "_.EXPLODE" ring2)
  (princ "\nRing 2 geëxplodeerd!")

  ;; ----------------------------------------------------------------------------
  ;; STAP 4: Test - probeer segmenten te vinden
  ;; ----------------------------------------------------------------------------
  (princ "\n\nBeide ringen zijn nu losse segmenten.")
  (princ "\n\nVoor automatische verbinding moet ik weten:")
  (princ "\n1. Op welke plek moeten de ringen 'open' zijn? (bijv. rechtsboven)")
  (princ "\n2. Moeten we een segment verwijderen of kan fillet direct verbinden?")
  (princ "\n3. Welke fillet radius? (0 = rechte hoek)")

  ;; Test: teken een lijntje tussen geschatte punten
  (princ "\n\n=== HANDMATIG TESTEN ===")
  (princ "\nProbeer nu handmatig:")
  (princ "\n1. Zoom in op de ringen")
  (princ "\n2. Type FILLET")
  (princ "\n3. Selecteer een segment van ring 1")
  (princ "\n4. Selecteer een segment van ring 2")
  (princ "\n5. Vertel me wat er gebeurt!")

  (princ "\n=========================")
  (princ)
)

;; ============================================================================
(princ "\nSlakkenhuis V3 test geladen. Type VVS3 om te gebruiken.")
(princ)
