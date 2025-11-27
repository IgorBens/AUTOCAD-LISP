;; ============================================================================
;; CLEAN DWG TEMPLATE - Interactieve Selectie met Auto-Copy
;; ============================================================================
;; Beschrijving: Maakt automatisch een kopie met "_clean" suffix en ruimt op
;;               - Maakt kopie van huidige file met "_clean" achter naam
;;               - Selecteer wat je wilt BEHOUDEN, rest wordt verwijderd
;;               - Verwijdert ALLE layout tabs (behalve Model)
;;               - Purge alle ongebruikte elementen
;;               - Origineel blijft intact!
;;
;; Gebruik: Type CLEANTEMPLATE in AutoCAD
;; ============================================================================

(defun C:CLEANTEMPLATE (/ dwg_name dwg_prefix dwg_titled base_name new_name new_path original_path
                          original_path_fixed keep_ss all_ss keep_list ent i delete_count
                          layout_name layout_list layout_count all_layers layer_name answer
                          text_pt text_height)

  (princ "\n=== CLEAN DWG TEMPLATE ===")
  (princ "\n")

  ;; ----------------------------------------------------------------------------
  ;; STAP 1: Check of bestand is opgeslagen
  ;; ----------------------------------------------------------------------------
  (setq dwg_titled (getvar "DWGTITLED"))

  (if (= dwg_titled 0)
    (progn
      (princ "\nERROR: Bestand is nog niet opgeslagen!")
      (princ "\nSave eerst je bestand voordat je CLEANTEMPLATE gebruikt.")
      (princ "\n")
      (exit)
    )
  )

  ;; ----------------------------------------------------------------------------
  ;; STAP 2: Haal bestandsnaam en pad op
  ;; ----------------------------------------------------------------------------
  (setq dwg_name (getvar "DWGNAME"))      ; bijv. "template.dwg"
  (setq dwg_prefix (getvar "DWGPREFIX"))  ; bijv. "C:/projecten/"
  (setq original_path (strcat dwg_prefix dwg_name)) ; volledig pad naar origineel

  (princ (strcat "\nHuidige file: " dwg_prefix dwg_name))

  ;; ----------------------------------------------------------------------------
  ;; STAP 3: Maak nieuwe bestandsnaam met "_clean" suffix
  ;; ----------------------------------------------------------------------------
  ;; Verwijder ".dwg" extensie en voeg "_clean.dwg" toe
  (setq base_name (vl-filename-base dwg_name))  ; "template"
  (setq new_name (strcat base_name "_clean.dwg")) ; "template_clean.dwg"
  (setq new_path (strcat dwg_prefix new_name))   ; "C:/projecten/template_clean.dwg"

  (princ (strcat "\nNieuwe file: " new_path))

  ;; ----------------------------------------------------------------------------
  ;; STAP 4: Check of nieuwe file al bestaat
  ;; ----------------------------------------------------------------------------
  (if (findfile new_path)
    (progn
      (princ "\n")
      (princ (strcat "\nWAARSCHUWING: " new_name " bestaat al!"))
      (initget "Ja Nee")
      (setq answer (getkword "\nOverschrijven? [Ja/Nee] <Nee>: "))

      (if (or (null answer) (equal answer "Nee"))
        (progn
          (princ "\nGeannuleerd.")
          (exit)
        )
      )
    )
  )

  ;; ----------------------------------------------------------------------------
  ;; STAP 5: Vraag bevestiging om kopie te maken
  ;; ----------------------------------------------------------------------------
  (princ "\n")
  (initget "Ja Nee")
  (setq answer (getkword "\nKopie maken en cleanen? [Ja/Nee] <Ja>: "))

  (if (equal answer "Nee")
    (progn
      (princ "\nGeannuleerd.")
      (exit)
    )
  )

  ;; ----------------------------------------------------------------------------
  ;; STAP 6: SAVEAS naar nieuwe file (je zit nu in de kopie!)
  ;; ----------------------------------------------------------------------------
  (princ "\n\nKopie wordt gemaakt...")
  (command "._SAVEAS" "" new_path)

  (princ (strcat "\n✓ Kopie gemaakt: " new_name))
  (princ "\n✓ Je zit nu in de nieuwe file")

  ;; ----------------------------------------------------------------------------
  ;; STAP 7: Selecteer elementen die je wilt BEHOUDEN
  ;; ----------------------------------------------------------------------------
  (princ "\n")
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
      (princ "\n(Kopie blijft bestaan, maar is niet opgeschoond)")
      (exit)
    )
  )

  (princ (strcat "\n" (itoa (sslength keep_ss)) " elementen geselecteerd om te BEHOUDEN."))

  ;; ----------------------------------------------------------------------------
  ;; STAP 8: Bevestiging cleanup
  ;; ----------------------------------------------------------------------------
  (initget "Ja Nee")
  (setq answer (getkword "\n\nWil je ALLE ANDERE elementen verwijderen? [Ja/Nee] <Nee>: "))

  (if (or (null answer) (equal answer "Nee"))
    (progn
      (princ "\nCleanup geannuleerd.")
      (princ "\n(Kopie blijft bestaan, maar is niet opgeschoond)")
      (exit)
    )
  )

  ;; ----------------------------------------------------------------------------
  ;; STAP 9: Maak lijst van entity names die behouden moeten worden
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
  ;; STAP 10: Selecteer ALLE elementen in de tekening
  ;; ----------------------------------------------------------------------------
  (setq all_ss (ssget "_X"))

  (if (null all_ss)
    (progn
      (princ "\nGeen elementen gevonden in de tekening.")
      (exit)
    )
  )

  ;; ----------------------------------------------------------------------------
  ;; STAP 11: Verwijder alle elementen die NIET in keep_list staan
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
  ;; STAP 12: Verwijder ALLE LAYOUT TABS (behalve Model)
  ;; ----------------------------------------------------------------------------
  (princ "\n\nVerwijderen van layout tabs...")

  ;; Loop door alle layouts in de tekening
  (setq layout_list (layoutlist))
  (setq layout_count 0)

  ;; Verwijder elke layout behalve "Model"
  (foreach layout_name layout_list
    (if (and layout_name
             (not (equal (strcase layout_name) "MODEL")))
      (progn
        ;; Probeer layout te verwijderen
        (if (not (vl-catch-all-error-p
                   (vl-catch-all-apply
                     '(lambda ()
                        (command "._-LAYOUT" "_Delete" layout_name)
                        (while (> (getvar "CMDACTIVE") 0) (command))
                      )
                     nil
                   )
                 ))
          (progn
            (princ (strcat "\n  Layout verwijderd: " layout_name))
            (setq layout_count (1+ layout_count))
          )
        )
      )
    )
  )

  (princ (strcat "\n" (itoa layout_count) " layout tabs verwijderd."))

  ;; ----------------------------------------------------------------------------
  ;; STAP 13: Verwijder lege layers
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
  ;; STAP 14: PURGE ALLES (meerdere keren voor nested items)
  ;; ----------------------------------------------------------------------------
  (princ "\n\nPurge tekening (dit kan even duren)...")

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
  ;; STAP 15: AUDIT de tekening
  ;; ----------------------------------------------------------------------------
  (princ "\n\nAudit tekening...")
  (command "._AUDIT" "_Y")

  ;; ----------------------------------------------------------------------------
  ;; STAP 16: Voeg "CLEAN DWG" watermark tekst toe
  ;; ----------------------------------------------------------------------------
  (princ "\n\nTekst 'CLEAN DWG' toevoegen...")
  (princ "\nKlik waar je de 'CLEAN DWG' tekst wilt plaatsen:")

  (setq text_pt (getpoint "\nKlik locatie voor tekst (of ENTER voor 0,0): "))

  ;; Als geen punt geselecteerd, gebruik 0,0
  (if (null text_pt)
    (setq text_pt (list 0.0 0.0 0.0))
  )

  ;; Gebruik altijd hoogte 500
  (setq text_height 500.0)

  ;; Maak tekst met ENTMAKE (direct entity maken, geen command prompts!)
  ;; Dit voorkomt problemen met text styles en spaties in tekst
  (entmake
    (list
      (cons 0 "TEXT")               ; Entity type
      (cons 10 text_pt)             ; Insertion point
      (cons 40 text_height)         ; Text height
      (cons 1 "CLEAN DWG")          ; Text string
      (cons 50 0.0)                 ; Rotation angle (0 degrees)
      (cons 62 1)                   ; Color number (1 = red)
      (cons 72 1)                   ; Horizontal justification (1 = center)
      (cons 73 2)                   ; Vertical justification (2 = middle)
      (cons 11 text_pt)             ; Alignment point (for justified text)
    )
  )

  (princ "\n✓ Watermark toegevoegd (hoogte 500)")

  ;; ----------------------------------------------------------------------------
  ;; STAP 17: SAVE de cleaned tekening
  ;; ----------------------------------------------------------------------------
  (princ "\n\nOpslaan clean versie...")
  (command "._QSAVE")

  ;; Wacht tot save klaar is
  (while (> (getvar "CMDACTIVE") 0) (command))

  ;; ----------------------------------------------------------------------------
  ;; STAP 18: Open origineel bestand opnieuw (beide open!)
  ;; ----------------------------------------------------------------------------
  (princ "\n\nOrigineel bestand openen...")

  ;; Converteer backslashes naar forward slashes (AutoCAD accepteert beide)
  (setq original_path_fixed (vl-string-translate "\\" "/" original_path))

  ;; Open origineel bestand - GEEN quotes toevoegen, command doet dat zelf!
  (command "._OPEN" original_path_fixed)

  ;; Wacht tot open klaar is
  (while (> (getvar "CMDACTIVE") 0) (command))

  ;; ----------------------------------------------------------------------------
  ;; Klaar!
  ;; ----------------------------------------------------------------------------
  (princ "\n\n=========================")
  (princ "\n✓ Template is schoongemaakt!")
  (princ "\n=========================")
  (princ (strcat "\n  - " (itoa (sslength keep_ss)) " elementen behouden"))
  (princ (strcat "\n  - " (itoa delete_count) " elementen verwijderd"))
  (princ (strcat "\n  - " (itoa layout_count) " layout tabs verwijderd"))
  (princ "\n  - Lege layers verwijderd")
  (princ "\n  - Volledig gepurged")
  (princ "\n  - 'CLEAN DWG' watermark toegevoegd")
  (princ "\n")
  (princ (strcat "\n✓ Origineel geopend: " dwg_name))
  (princ (strcat "\n✓ Cleaned versie opgeslagen: " new_name))
  (princ "\n✓ Beide bestanden zijn nu open!")
  (princ "\n")
  (princ "\nTip: Gebruik Ctrl+Tab of Window menu om te wisselen tussen bestanden")
  (princ "\n")
  (princ)
)

;; ============================================================================
(princ "\nClean Template script geladen. Type CLEANTEMPLATE om te gebruiken.")
(princ)
