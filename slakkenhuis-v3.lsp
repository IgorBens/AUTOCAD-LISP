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
  ;; STAP 3: EXPLODE de eerste ring (TEST)
  ;; ----------------------------------------------------------------------------
  (princ "\n\nTEST: Explode eerste ring...")

  ;; Bewaar entity voor explode
  (setq last_ent (entlast))

  ;; Explode ring1
  (command "_.EXPLODE" ring1)

  ;; Na explode zijn er meerdere nieuwe entities
  (princ "\nRing geëxplodeerd!")

  ;; ----------------------------------------------------------------------------
  ;; VRAAG AAN GEBRUIKER
  ;; ----------------------------------------------------------------------------
  (princ "\n\n=== TEST RESULTAAT ===")
  (princ "\nIk heb de EERSTE rode ring geëxplodeerd.")
  (princ "\n\nWat zie je?")
  (princ "\n1. Is de ring nu uit losse lijnen?")
  (princ "\n2. Hoeveel segmenten zie je? (4 voor rechthoek?)")
  (princ "\n\nAls dit werkt, kan ik:")
  (princ "\n- Beide ringen exploderen")
  (princ "\n- Het rechtsboven segment van beide verwijderen")
  (princ "\n- De uiteinden verbinden met een lijntje")
  (princ "\n- Alles joinen tot 1 lijn")

  (princ "\n=========================")
  (princ)
)

;; ============================================================================
(princ "\nSlakkenhuis V3 test geladen. Type VVS3 om te gebruiken.")
(princ)
