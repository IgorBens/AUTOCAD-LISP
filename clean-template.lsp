;; ============================================================================
;; CLEAN DWG TEMPLATE
;; ============================================================================
;; Beschrijving: Wist alle elementen behalve vloerverwarming, muren en collector
;;               Purge alle ongebruikte elementen
;;
;; Gebruik: Type CLEANTEMPLATE in AutoCAD
;; ============================================================================

(defun C:CLEANTEMPLATE (/ keep_layers all_layers layer_name ss i ent)

  (princ "\n=== CLEAN DWG TEMPLATE ===")

  ;; ----------------------------------------------------------------------------
  ;; STAP 1: Definieer welke layers je wilt BEHOUDEN
  ;; ----------------------------------------------------------------------------
  ;; PAS DEZE LIJST AAN MET JOUW LAYER NAMEN!
  (setq keep_layers (list
    "0"                    ; Default layer (altijd behouden)
    "VLOERVERWARMING"      ; Floor heating layer
    "MUREN"                ; Walls layer
    "WANDEN"               ; Alternative walls layer name
    "COLLECTOR"            ; Collector layer
    "LEIDINGEN"            ; Pipes layer
    "DEFPOINTS"            ; System layer (altijd behouden)
  ))

  (princ "\nLayers die BEHOUDEN worden:")
  (foreach lyr keep_layers
    (princ (strcat "\n  - " lyr))
  )

  ;; ----------------------------------------------------------------------------
  ;; STAP 2: Vraag bevestiging
  ;; ----------------------------------------------------------------------------
  (initget "Ja Nee")
  (setq answer (getkword "\n\nWil je ALLE andere elementen verwijderen? [Ja/Nee] <Nee>: "))

  (if (or (null answer) (equal answer "Nee"))
    (progn
      (princ "\nGeannuleerd.")
      (exit)
    )
  )

  ;; ----------------------------------------------------------------------------
  ;; STAP 3: Verwijder elementen van layers die NIET behouden worden
  ;; ----------------------------------------------------------------------------
  (princ "\n\nVerwijderen van elementen op niet-behouden layers...")

  ;; Selecteer ALLES in de tekening
  (setq ss (ssget "_X"))

  (if ss
    (progn
      (setq i 0)
      (setq delete_count 0)

      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq ent_data (entget ent))
        (setq layer_name (cdr (assoc 8 ent_data)))

        ;; Check of layer NIET in keep_layers lijst staat
        (if (not (member (strcase layer_name) (mapcar 'strcase keep_layers)))
          (progn
            ;; Verwijder dit element
            (entdel ent)
            (setq delete_count (1+ delete_count))
          )
        )

        (setq i (1+ i))
      )

      (princ (strcat "\n" (itoa delete_count) " elementen verwijderd."))
    )
    (progn
      (princ "\nGeen elementen gevonden in de tekening.")
    )
  )

  ;; ----------------------------------------------------------------------------
  ;; STAP 4: Verwijder lege/ongebruikte layers (behalve keep_layers)
  ;; ----------------------------------------------------------------------------
  (princ "\n\nVerwijderen van ongebruikte layers...")

  ;; Loop door alle layers
  (setq all_layers (tblnext "LAYER" T))
  (while all_layers
    (setq layer_name (cdr (assoc 2 all_layers)))

    ;; Als layer NIET in keep_layers lijst staat, probeer te verwijderen
    (if (not (member (strcase layer_name) (mapcar 'strcase keep_layers)))
      (progn
        (command "._-LAYER" "_Delete" layer_name "" "")
      )
    )

    (setq all_layers (tblnext "LAYER"))
  )

  (princ "\nOngebruikte layers verwijderd.")

  ;; ----------------------------------------------------------------------------
  ;; STAP 5: PURGE ALLES (meerdere keren voor nested items)
  ;; ----------------------------------------------------------------------------
  (princ "\n\nPurge tekening (dit kan even duren)...")

  ;; Purge blocks
  (command "._-PURGE" "_Blocks" "*" "_N")

  ;; Purge DimStyles
  (command "._-PURGE" "_DimStyles" "*" "_N")

  ;; Purge Layers
  (command "._-PURGE" "_LAyers" "*" "_N")

  ;; Purge LTypes
  (command "._-PURGE" "_LTypes" "*" "_N")

  ;; Purge Materials
  (command "._-PURGE" "_Materials" "*" "_N")

  ;; Purge MLineStyles
  (command "._-PURGE" "_MlineStyles" "*" "_N")

  ;; Purge Plotstyles
  (command "._-PURGE" "_Plotstyles" "*" "_N")

  ;; Purge Shapes
  (command "._-PURGE" "_SHapes" "*" "_N")

  ;; Purge Text styles
  (command "._-PURGE" "_Styles" "*" "_N")

  ;; Purge Table styles
  (command "._-PURGE" "_Tablestyles" "*" "_N")

  ;; Purge Visual styles
  (command "._-PURGE" "_Visualstyles" "*" "_N")

  ;; Purge ALL (meerdere keren)
  (command "._-PURGE" "_All" "*" "_N")
  (command "._-PURGE" "_All" "*" "_N")
  (command "._-PURGE" "_All" "*" "_N")

  (princ "\nPurge voltooid!")

  ;; ----------------------------------------------------------------------------
  ;; STAP 6: AUDIT de tekening
  ;; ----------------------------------------------------------------------------
  (princ "\n\nAudit tekening...")
  (command "._AUDIT" "_Y")

  ;; ----------------------------------------------------------------------------
  ;; Klaar!
  ;; ----------------------------------------------------------------------------
  (princ "\n\n=========================")
  (princ "\nTemplate is schoongemaakt!")
  (princ "\n=========================")
  (princ "\n\nVergeet niet om de tekening op te slaan als nieuwe template!")
  (princ)
)

;; ============================================================================
(princ "\nClean Template script geladen. Type CLEANTEMPLATE om te gebruiken.")
(princ)
