;; ============================================================================
;; SLAKKENHUIS V4 - AUTOMATISCH VERBINDEN MET FILLET
;; ============================================================================
;; Test om automatisch segmenten te identificeren en te verbinden
;;
;; Strategie:
;;   1. Maak 2 rode ringen (aanvoer)
;;   2. Explode beide ringen
;;   3. Verzamel alle nieuwe segmenten
;;   4. Identificeer welke segmenten waar zijn (top/right/bottom/left)
;;   5. Verbind de juiste segmenten met FILLET
;;
;; Gebruik: Type VVS4 in AutoCAD
;; ============================================================================

(defun C:VVS4 (/ obj legpatroon offset_dist obj_data minx miny maxx maxy pt
               center_pt last_ent item ring1 ring2
               ents_before ents_after segments1 segments2 all_ents
               seg1 seg2)

  (princ "\n=== SLAKKENHUIS V4 - AUTO FILLET TEST ===")

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
  ;; STAP 3: Explode ring 1 - simpele test zonder verzamelen
  ;; ----------------------------------------------------------------------------
  (princ "\n\nExplode ring 1...")
  (command "_.EXPLODE" ring1)
  (princ "\nRing 1 geëxplodeerd!")

  ;; ----------------------------------------------------------------------------
  ;; STAP 4: Explode ring 2
  ;; ----------------------------------------------------------------------------
  (princ "\nExplode ring 2...")
  (command "_.EXPLODE" ring2)
  (princ "\nRing 2 geëxplodeerd!")

  ;; ----------------------------------------------------------------------------
  ;; STAP 5: JOIN alle losse segmenten tot 1 lijn
  ;; ----------------------------------------------------------------------------
  (princ "\n\nProbeer alle segmenten te joinen...")

  ;; Simpele methode: selecteer ALLES en probeer te joinen
  ;; Dit werkt alleen als de segmenten al verbonden zijn of elkaar raken

  (princ "\n\nTest: gebruik JOIN om alles te verbinden...")
  (princ "\n\nProbeer nu handmatig:")
  (princ "\n1. Type: JOIN")
  (princ "\n2. Selecteer alle rode lijnen (window selectie)")
  (princ "\n3. Druk op ENTER")
  (princ "\n\nWat gebeurt er?")
  (princ "\n- Worden ze 1 polyline?")
  (princ "\n- Of blijven het losse lijnen?")
  (princ "\n\nAls ze NIET verbinden, dan moeten we eerst de segmenten")
  (princ "\nop de juiste plek 'knippen' zodat ze elkaar raken.")

  (princ "\n=========================")
  (princ)
)

;; ============================================================================
(princ "\nSlakkenhuis V4 geladen. Type VVS4 om te gebruiken.")
(princ)
