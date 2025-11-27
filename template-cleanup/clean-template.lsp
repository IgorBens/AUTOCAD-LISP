;; ============================================================================
;; CLEAN DWG TEMPLATE - Interactieve Selectie
;; ============================================================================
;; Beschrijving: Selecteer wat je wilt BEHOUDEN, rest wordt verwijderd
;;               - Verwijdert alle niet-geselecteerde elementen
;;               - Verwijdert ALLE layout tabs (behalve Model)
;;               - Purge alle ongebruikte elementen
;;
;; Gebruik: Type CLEANTEMPLATE in AutoCAD
;; ============================================================================

(defun C:CLEANTEMPLATE (/ keep_ss all_ss keep_list ent i delete_count
                          layout_name layout_num all_layers layer_name)

  (princ "\n=== CLEAN DWG TEMPLATE ===")
  (princ "\n")

  ;; ----------------------------------------------------------------------------
  ;; STAP 1: Selecteer elementen die je wilt BEHOUDEN
  ;; ----------------------------------------------------------------------------
  (princ "\nSelecteer alle elementen die je wilt BEHOUDEN:")
  (princ "\n  - Vloerverwarming")
  (princ "\n  - Muren/Wanden")
  (princ "\n  - Collectors")
  (princ "\n  - Alles wat je wilt behouden")
  (princ "\n")

  (setq keep_ss (ssget))

  (if (null keep_ss)
    (progn
      (princ "\nGeen elementen geselecteerd. Geannuleerd.")
      (exit)
    )
  )

  (princ (strcat "\n" (itoa (sslength keep_ss)) " elementen geselecteerd om te BEHOUDEN."))

  ;; ----------------------------------------------------------------------------
  ;; STAP 2: Bevestiging
  ;; ----------------------------------------------------------------------------
  (initget "Ja Nee")
  (setq answer (getkword "\n\nWil je ALLE ANDERE elementen verwijderen? [Ja/Nee] <Nee>: "))

  (if (or (null answer) (equal answer "Nee"))
    (progn
      (princ "\nGeannuleerd.")
      (exit)
    )
  )

  ;; ----------------------------------------------------------------------------
  ;; STAP 3: Maak lijst van entity names die behouden moeten worden
  ;; ----------------------------------------------------------------------------
  (setq keep_list (list))
  (setq i 0)
  (repeat (sslength keep_ss)
    (setq ent (ssname keep_ss i))
    (setq keep_list (cons ent keep_list))
    (setq i (1+ i))
  )

  (princ "\n\nStart met verwijderen van niet-geselecteerde elementen...")

  ;; ----------------------------------------------------------------------------
  ;; STAP 4: Selecteer ALLE elementen in de tekening
  ;; ----------------------------------------------------------------------------
  (setq all_ss (ssget "_X"))

  (if (null all_ss)
    (progn
      (princ "\nGeen elementen gevonden in de tekening.")
      (exit)
    )
  )

  ;; ----------------------------------------------------------------------------
  ;; STAP 5: Verwijder alle elementen die NIET in keep_list staan
  ;; ----------------------------------------------------------------------------
  (setq delete_count 0)
  (setq i 0)

  (repeat (sslength all_ss)
    (setq ent (ssname all_ss i))

    ;; Check of dit element NIET in keep_list staat
    (if (not (member ent keep_list))
      (progn
        ;; Verwijder dit element
        (entdel ent)
        (setq delete_count (1+ delete_count))
      )
    )

    (setq i (1+ i))
  )

  (princ (strcat "\n" (itoa delete_count) " elementen verwijderd."))

  ;; ----------------------------------------------------------------------------
  ;; STAP 6: Verwijder ALLE LAYOUT TABS (behalve Model)
  ;; ----------------------------------------------------------------------------
  (princ "\n\nVerwijderen van layout tabs...")

  (setq layout_num 1)

  ;; Probeer Layout1 t/m Layout50 te verwijderen
  (repeat 50
    (setq layout_name (strcat "Layout" (itoa layout_num)))

    ;; Gebruik (vl-catch-all-error? ...) om errors te negeren
    (if (not (vl-catch-all-error-p
               (vl-catch-all-apply
                 '(lambda ()
                    (command "._-LAYOUT" "_Delete" layout_name)
                    (while (> (getvar "CMDACTIVE") 0) (command))
                  )
                 nil
               )
             ))
      (princ (strcat "\n  Layout verwijderd: " layout_name))
    )

    (setq layout_num (1+ layout_num))
  )

  (princ "\nLayout tabs opgeschoond.")

  ;; ----------------------------------------------------------------------------
  ;; STAP 7: Verwijder lege layers
  ;; ----------------------------------------------------------------------------
  (princ "\n\nVerwijderen van lege layers...")

  ;; Loop door alle layers en probeer ze te verwijderen
  (setq all_layers (tblnext "LAYER" T))
  (while all_layers
    (setq layer_name (cdr (assoc 2 all_layers)))

    ;; Probeer layer te verwijderen (alleen lege layers worden verwijderd)
    ;; Layer 0 en DEFPOINTS kunnen niet verwijderd worden (dat is goed)
    (if (not (vl-catch-all-error-p
               (vl-catch-all-apply
                 '(lambda () (command "._-LAYER" "_Delete" layer_name "" ""))
                 nil
               )
             ))
      (princ (strcat "\n  Layer verwijderd: " layer_name))
    )

    (setq all_layers (tblnext "LAYER"))
  )

  (princ "\nLege layers verwijderd.")

  ;; ----------------------------------------------------------------------------
  ;; STAP 8: PURGE ALLES (meerdere keren voor nested items)
  ;; ----------------------------------------------------------------------------
  (princ "\n\nPurge tekening (dit kan even duren)...")

  ;; BELANGRIJK: Gebruik "_Y" (YES) om echt te purgen!
  ;; Purge ALL meerdere keren (voor nested references)
  (command "._-PURGE" "_All" "*" "_N")
  (command "._-PURGE" "_All" "*" "_N")
  (command "._-PURGE" "_All" "*" "_N")

  ;; Specifieke purges met verificatie
  (command "._-PURGE" "_Blocks" "*" "_N")
  (command "._-PURGE" "_DimStyles" "*" "_N")
  (command "._-PURGE" "_LAyers" "*" "_N")
  (command "._-PURGE" "_LTypes" "*" "_N")
  (command "._-PURGE" "_Materials" "*" "_N")
  (command "._-PURGE" "_MlineStyles" "*" "_N")
  (command "._-PURGE" "_Plotstyles" "*" "_N")
  (command "._-PURGE" "_SHapes" "*" "_N")
  (command "._-PURGE" "_Styles" "*" "_N")
  (command "._-PURGE" "_Tablestyles" "*" "_N")
  (command "._-PURGE" "_Visualstyles" "*" "_N")
  (command "._-PURGE" "_Regapps" "*" "_N")

  ;; Laatste keer alles purgen (3x voor nested items)
  (command "._-PURGE" "_All" "*" "_N")
  (command "._-PURGE" "_All" "*" "_N")
  (command "._-PURGE" "_All" "*" "_N")

  (princ "\nPurge voltooid!")

  ;; ----------------------------------------------------------------------------
  ;; STAP 9: AUDIT de tekening
  ;; ----------------------------------------------------------------------------
  (princ "\n\nAudit tekening...")
  (command "._AUDIT" "_Y")

  ;; ----------------------------------------------------------------------------
  ;; Klaar!
  ;; ----------------------------------------------------------------------------
  (princ "\n\n=========================")
  (princ "\nTemplate is schoongemaakt!")
  (princ "\n=========================")
  (princ (strcat "\n  - " (itoa (sslength keep_ss)) " elementen behouden"))
  (princ (strcat "\n  - " (itoa delete_count) " elementen verwijderd"))
  (princ "\n  - Layout tabs verwijderd")
  (princ "\n  - Lege layers verwijderd")
  (princ "\n  - Volledig gepurged")
  (princ "\n\nVergeet niet om de tekening op te slaan!")
  (princ)
)

;; ============================================================================
(princ "\nClean Template script geladen. Type CLEANTEMPLATE om te gebruiken.")
(princ)
