;; ============================================================================
;; SLAKKENHUIS V6 - AUTOMATISCH ALLE SEGMENTEN FILLET
;; ============================================================================
;; Simpele aanpak: Explode alles en FILLET alle segmenten achter elkaar
;;
;; Workflow:
;;   1. Maak 2 rode ringen (aanvoer)
;;   2. Explode beide ringen → alle losse segmenten
;;   3. FILLET alle segmenten automatisch tot 1 lijn
;;
;; Gebruik: Type VVS6 in AutoCAD
;; ============================================================================

(defun C:VVS6 (/ obj legpatroon offset_dist obj_data minx miny maxx maxy pt
               center_pt last_ent item ring1 ring2 all_segs seg_before count)

  (princ "\n=== SLAKKENHUIS V6 - AUTO FILLET ALLE SEGMENTEN ===")

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
  ;; STAP 4: Set FILLET radius to 0
  ;; ----------------------------------------------------------------------------
  (princ "\nSet FILLET radius to 0...")
  (command "_.FILLET" "R" 0)

  ;; ----------------------------------------------------------------------------
  ;; STAP 5: Selecteer ALLE segmenten en probeer ze te FILLET
  ;; ----------------------------------------------------------------------------
  (princ "\n\nSelecteer nu ALLE rode segmenten...")
  (princ "\n(We gaan proberen ze allemaal te FILLET)")

  ;; Vraag gebruiker om alle segmenten te selecteren
  (princ "\nSelecteer alle rode segmenten:")
  (setq all_segs (ssget))

  (if (null all_segs)
    (progn
      (princ "\nGeen segmenten geselecteerd.")
      (exit)
    )
  )

  (setq count (sslength all_segs))
  (princ (strcat "\n" (itoa count) " segmenten geselecteerd."))

  ;; ----------------------------------------------------------------------------
  ;; STAP 6: Loop door alle segmenten en FILLET met de volgende
  ;; ----------------------------------------------------------------------------
  (princ "\n\nProbeer segmenten te FILLET...")

  ;; Voor nu: test met eerste 2 segmenten
  (if (>= count 2)
    (progn
      (setq seg1 (ssname all_segs 0))
      (setq seg2 (ssname all_segs 1))

      (princ "\nTest: FILLET segment 1 met segment 2...")
      (command "_.FILLET" seg1 seg2)

      (princ "\n\nKijk wat er gebeurde!")
      (princ "\n- Zijn segment 1 en 2 nu verbonden?")
      (princ "\n\nAls dit werkt, kan ik een loop maken die ALLE segmenten fillet:")
      (princ "\n- seg 1 FILLET seg 2")
      (princ "\n- seg 2 FILLET seg 3")
      (princ "\n- seg 3 FILLET seg 4")
      (princ "\n- etc tot alle segmenten 1 lijn zijn!")
    )
    (progn
      (princ "\nTe weinig segmenten geselecteerd.")
    )
  )

  (princ "\n=========================")
  (princ)
)

;; ============================================================================
(princ "\nSlakkenhuis V6 geladen. Type VVS6 om te gebruiken.")
(princ)
