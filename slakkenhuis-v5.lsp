;; ============================================================================
;; SLAKKENHUIS V5 - INTERACTIEVE FILLET TEST
;; ============================================================================
;; Test: Explode, JOIN, en dan interactief FILLET laten selecteren
;;
;; Workflow:
;;   1. Maak 2 rode ringen (aanvoer)
;;   2. Explode beide ringen
;;   3. JOIN alle segmenten → 2 polylines
;;   4. FILLET tussen de 2 polylines (interactief)
;;
;; Gebruik: Type VVS5 in AutoCAD
;; ============================================================================

(defun C:VVS5 (/ obj legpatroon offset_dist obj_data minx miny maxx maxy pt
               center_pt last_ent item ring1 ring2
               seg1 seg2)

  (princ "\n=== SLAKKENHUIS V5 - INTERACTIEVE FILLET ===")

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
  ;; STAP 2: Maak 2 rode ringen
  ;; ----------------------------------------------------------------------------
  (princ "\nMaak 2 rode ringen...")

  (setq last_ent (entlast))
  (command "_.OFFSET" 50 obj center_pt "")
  (setq ring1 (entlast))
  (command "_.CHPROP" ring1 "" "C" "1" "")

  (setq last_ent (entlast))
  (command "_.OFFSET" offset_dist ring1 center_pt "")
  (setq ring2 (entlast))
  (command "_.CHPROP" ring2 "" "C" "1" "")

  (princ "\n2 rode ringen gemaakt!")

  ;; ----------------------------------------------------------------------------
  ;; STAP 3: Explode beide ringen
  ;; ----------------------------------------------------------------------------
  (princ "\nExplode ring 1...")
  (command "_.EXPLODE" ring1)

  (princ "\nExplode ring 2...")
  (command "_.EXPLODE" ring2)

  (princ "\nBeide ringen geëxplodeerd!")

  ;; ----------------------------------------------------------------------------
  ;; STAP 4: Selecteer alle rode segmenten en JOIN
  ;; ----------------------------------------------------------------------------
  (princ "\n\nSelecteer nu ALLE rode segmenten om te joinen...")
  (princ "\nDruk op een toets om verder te gaan...")
  (getstring)

  ;; Laat gebruiker alle segmenten selecteren
  (princ "\nSelecteer alle rode segmenten (window selectie):")
  (command "_.JOIN")
  (pause)  ;; Wacht op gebruiker selectie
  (command "")  ;; Bevestig selectie

  (princ "\nJOIN uitgevoerd!")

  ;; ----------------------------------------------------------------------------
  ;; STAP 5: FILLET tussen 2 polylines (interactief)
  ;; ----------------------------------------------------------------------------
  (princ "\n\nNu gaan we de 2 polylines verbinden met FILLET...")
  (princ "\n\nSelecteer eerst een segment van de BUITENSTE polyline:")
  (setq seg1 (car (entsel)))

  (princ "\nSelecteer nu een segment van de BINNENSTE polyline:")
  (setq seg2 (car (entsel)))

  (if (and seg1 seg2)
    (progn
      (princ "\nVerbind met FILLET (radius 0)...")

      ;; Set fillet radius to 0
      (command "_.FILLET" "R" 0)

      ;; Fillet the 2 segments
      (command "_.FILLET" seg1 seg2)

      (princ "\n\nFILLET uitgevoerd!")
      (princ "\nZijn de 2 polylines nu verbonden?")
      (princ "\nAls JA: super! Dan kunnen we dit automatiseren.")
      (princ "\nAls NEE: vertel me wat er gebeurde.")
    )
    (progn
      (princ "\nGeen segmenten geselecteerd.")
    )
  )

  (princ "\n=========================")
  (princ)
)

;; ============================================================================
(princ "\nSlakkenhuis V5 geladen. Type VVS5 om te gebruiken.")
(princ)
