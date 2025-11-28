;;;; ========================================
;;;; SUMMARY TABLE MODULE
;;;; ========================================
;;;; Creates a summary table in AutoCAD with collected data
;;;; from floor heating commands (VV, FHAREA, etc.)
;;;; ========================================

;;; Global data collection list
;;; Structure: ((type data) (type data) ...)
;;; Types: "ZONE" "AREA" "MANIFOLD" "PROJECT"
(if (not *td-summary-data*)
  (setq *td-summary-data* (list))
)

;;;; ========================================
;;;; HELPER FUNCTIONS
;;;; ========================================

;;; Add zone data (from VV command)
;;; zone-name: string - name/identifier of the zone
;;; loop-count: integer - number of heating loops created
;;; pipe-spacing: real - distance between pipes in mm
(defun td-add-zone (zone-name loop-count pipe-spacing / entry)
  (setq entry (list "ZONE"
                    (list (cons "name" zone-name)
                          (cons "loops" loop-count)
                          (cons "spacing" pipe-spacing))))
  (setq *td-summary-data* (append *td-summary-data* (list entry)))
  (princ (strcat "\n[DATA] Zone added: " zone-name))
  (princ)
)

;;; Add area data (from FHAREA commands)
;;; room-name: string - name of the room
;;; area: real - calculated area in m²
;;; poly-count: integer - number of polylines measured
(defun td-add-area (room-name area poly-count / entry)
  (setq entry (list "AREA"
                    (list (cons "room" room-name)
                          (cons "area" area)
                          (cons "polylines" poly-count))))
  (setq *td-summary-data* (append *td-summary-data* (list entry)))
  (princ (strcat "\n[DATA] Area added: " room-name " = " (rtos area 2 2) " m²"))
  (princ)
)

;;; Add manifold data
;;; manifold-name: string - name/identifier of manifold
;;; location: point - insertion point of manifold
;;; circuit-count: integer - number of circuits connected
(defun td-add-manifold (manifold-name location circuit-count / entry)
  (setq entry (list "MANIFOLD"
                    (list (cons "name" manifold-name)
                          (cons "location" location)
                          (cons "circuits" circuit-count))))
  (setq *td-summary-data* (append *td-summary-data* (list entry)))
  (princ (strcat "\n[DATA] Manifold added: " manifold-name))
  (princ)
)

;;; Set project information
;;; project-num: string - project number
;;; project-name: string - project name (optional)
(defun td-set-project (project-num project-name / entry)
  ;; Remove any existing project info
  (setq *td-summary-data*
        (vl-remove-if '(lambda (x) (equal (car x) "PROJECT")) *td-summary-data*))

  ;; Add new project info
  (setq entry (list "PROJECT"
                    (list (cons "number" project-num)
                          (cons "name" project-name))))
  (setq *td-summary-data* (append *td-summary-data* (list entry)))
  (princ (strcat "\n[DATA] Project set: " project-num))
  (princ)
)

;;; Clear all collected data
(defun td-clear-data ()
  (setq *td-summary-data* (list))
  (princ "\n[DATA] All data cleared")
  (princ)
)

;;;; ========================================
;;;; DATA EXTRACTION FUNCTIONS
;;;; ========================================

;;; Get all entries of a specific type
(defun td-get-entries (entry-type / result)
  (setq result (list))
  (foreach entry *td-summary-data*
    (if (equal (car entry) entry-type)
      (setq result (append result (list (cadr entry))))
    )
  )
  result
)

;;; Get project info
(defun td-get-project (/ entries)
  (setq entries (td-get-entries "PROJECT"))
  (if entries
    (car entries)
    nil
  )
)

;;; Calculate total area from all AREA entries
(defun td-calc-total-area (/ entries total)
  (setq entries (td-get-entries "AREA"))
  (setq total 0.0)
  (foreach entry entries
    (setq total (+ total (cdr (assoc "area" entry))))
  )
  total
)

;;; Count total zones
(defun td-count-zones ()
  (length (td-get-entries "ZONE"))
)

;;; Count total manifolds
(defun td-count-manifolds ()
  (length (td-get-entries "MANIFOLD"))
)

;;; Calculate total loops across all zones
(defun td-calc-total-loops (/ entries total)
  (setq entries (td-get-entries "ZONE"))
  (setq total 0)
  (foreach entry entries
    (setq total (+ total (cdr (assoc "loops" entry))))
  )
  total
)

;;;; ========================================
;;;; TABLE CREATION FUNCTIONS
;;;; ========================================

;;; Create or get SUMMARY layout
(defun td-create-summary-layout (/ layouts layout-obj)
  (vl-load-com)

  ;; Check if layout exists
  (if (not (tblsearch "LAYOUT" "SUMMARY"))
    (progn
      (princ "\n[TABLE] Creating SUMMARY layout...")
      (command "_.LAYOUT" "_New" "SUMMARY")
      (princ "\n[TABLE] SUMMARY layout created")
    )
    (princ "\n[TABLE] SUMMARY layout already exists")
  )
  (princ)
)

;;; Format text for table cell
(defun td-format-text (value decimals / )
  (cond
    ((numberp value)
     (rtos value 2 decimals))
    ((null value)
     "-")
    (T
     (vl-princ-to-string value))
  )
)

;;; Create summary table as MText
(defun td-create-mtext-summary (insert-point / text-content project-info zones areas manifolds)
  (vl-load-com)

  (setq project-info (td-get-project))
  (setq zones (td-get-entries "ZONE"))
  (setq areas (td-get-entries "AREA"))
  (setq manifolds (td-get-entries "MANIFOLD"))

  ;; Build text content
  (setq text-content "")

  ;; Header
  (setq text-content (strcat text-content "{\\H2.0;\\C1;FLOOR HEATING SUMMARY}\\P\\P"))

  ;; Project info
  (if project-info
    (progn
      (setq text-content (strcat text-content "{\\C2;PROJECT INFORMATION}\\P"))
      (setq text-content (strcat text-content "Project Number: "
                                (td-format-text (cdr (assoc "number" project-info)) 0) "\\P"))
      (if (cdr (assoc "name" project-info))
        (setq text-content (strcat text-content "Project Name: "
                                  (cdr (assoc "name" project-info)) "\\P"))
      )
      (setq text-content (strcat text-content "\\P"))
    )
  )

  ;; Summary statistics
  (setq text-content (strcat text-content "{\\C2;SUMMARY}\\P"))
  (setq text-content (strcat text-content "Total Zones: "
                            (itoa (td-count-zones)) "\\P"))
  (setq text-content (strcat text-content "Total Heating Loops: "
                            (itoa (td-calc-total-loops)) "\\P"))
  (setq text-content (strcat text-content "Total Area: "
                            (rtos (td-calc-total-area) 2 2) " m²\\P"))
  (setq text-content (strcat text-content "Total Manifolds: "
                            (itoa (td-count-manifolds)) "\\P"))
  (setq text-content (strcat text-content "\\P"))

  ;; Zones detail
  (if zones
    (progn
      (setq text-content (strcat text-content "{\\C2;ZONES DETAIL}\\P"))
      (foreach zone zones
        (setq text-content (strcat text-content
                                  "• " (cdr (assoc "name" zone))
                                  " - Loops: " (itoa (cdr (assoc "loops" zone)))
                                  " - Spacing: " (rtos (cdr (assoc "spacing" zone)) 2 0) "mm"
                                  "\\P"))
      )
      (setq text-content (strcat text-content "\\P"))
    )
  )

  ;; Areas detail
  (if areas
    (progn
      (setq text-content (strcat text-content "{\\C2;AREAS DETAIL}\\P"))
      (foreach area areas
        (setq text-content (strcat text-content
                                  "• " (cdr (assoc "room" area))
                                  " - " (rtos (cdr (assoc "area" area)) 2 2) " m²"
                                  " (" (itoa (cdr (assoc "polylines" area))) " polylines)"
                                  "\\P"))
      )
      (setq text-content (strcat text-content "\\P"))
    )
  )

  ;; Manifolds detail
  (if manifolds
    (progn
      (setq text-content (strcat text-content "{\\C2;MANIFOLDS}\\P"))
      (foreach manifold manifolds
        (setq text-content (strcat text-content
                                  "• " (cdr (assoc "name" manifold))
                                  " - Circuits: " (itoa (cdr (assoc "circuits" manifold)))
                                  "\\P"))
      )
    )
  )

  ;; Create MText object
  (command "_.MTEXT" insert-point "J" "TL" "W" "500" text-content "")

  (princ "\n[TABLE] Summary MText created")
  (princ)
)

;;;; ========================================
;;;; MAIN COMMAND: TD_SUMTAB
;;;; ========================================

(defun C:TD_SUMTAB (/ current-layout insert-point)
  (vl-load-com)

  (princ "\n========================================")
  (princ "\n  FLOOR HEATING SUMMARY TABLE")
  (princ "\n========================================")

  ;; Check if there's data to display
  (if (null *td-summary-data*)
    (progn
      (princ "\n** WARNING: No data collected yet **")
      (princ "\nUse commands like VV, FHAREA to collect data first")
      (princ "\n")
      (exit)
    )
  )

  (princ (strcat "\n\nCollected " (itoa (length *td-summary-data*)) " data entries"))
  (princ (strcat "\n  - Zones: " (itoa (td-count-zones))))
  (princ (strcat "\n  - Areas: " (itoa (length (td-get-entries "AREA")))))
  (princ (strcat "\n  - Manifolds: " (itoa (td-count-manifolds))))
  (princ "\n")

  ;; Save current layout
  (setq current-layout (getvar "CTAB"))

  ;; Create and switch to SUMMARY layout
  (td-create-summary-layout)
  (command "_.LAYOUT" "_Set" "SUMMARY")

  ;; Prompt for insertion point
  (princ "\nClick insertion point for summary table: ")
  (setq insert-point (getpoint))

  (if insert-point
    (progn
      ;; Create the summary table
      (td-create-mtext-summary insert-point)
      (princ "\n\n** Summary table created successfully! **")
      (princ (strcat "\nLayout: SUMMARY"))
    )
    (progn
      (princ "\n** Cancelled **")
      (command "_.LAYOUT" "_Set" current-layout)
    )
  )

  (princ "\n========================================")
  (princ)
)

;;;; ========================================
;;;; HELPER COMMAND: TD_SHOWDATA
;;;; ========================================
;;; Display collected data in command line

(defun C:TD_SHOWDATA (/ )
  (princ "\n========================================")
  (princ "\n  COLLECTED DATA")
  (princ "\n========================================")

  (if (null *td-summary-data*)
    (princ "\nNo data collected yet")
    (progn
      (princ (strcat "\nTotal entries: " (itoa (length *td-summary-data*))))
      (princ "\n")
      (foreach entry *td-summary-data*
        (princ "\n")
        (princ (car entry))
        (princ ": ")
        (princ (cadr entry))
      )
    )
  )

  (princ "\n========================================")
  (princ)
)

;;;; ========================================
;;;; HELPER COMMAND: TD_CLEARDATA
;;;; ========================================
;;; Clear all collected data

(defun C:TD_CLEARDATA ()
  (princ "\n========================================")
  (princ "\n  CLEAR COLLECTED DATA")
  (princ "\n========================================")

  (if (null *td-summary-data*)
    (princ "\nNo data to clear")
    (progn
      (princ (strcat "\nClearing " (itoa (length *td-summary-data*)) " entries..."))
      (td-clear-data)
      (princ "\n** Data cleared successfully **")
    )
  )

  (princ "\n========================================")
  (princ)
)

;;;; ========================================
;;;; HELPER COMMAND: TD_PROJECT
;;;; ========================================
;;; Set project information

(defun C:TD_PROJECT (/ proj-num proj-name)
  (princ "\n========================================")
  (princ "\n  SET PROJECT INFORMATION")
  (princ "\n========================================")

  (setq proj-num (getstring T "\nEnter project number: "))

  (if (and proj-num (> (strlen proj-num) 0))
    (progn
      (setq proj-name (getstring T "\nEnter project name (optional, press Enter to skip): "))
      (if (= (strlen proj-name) 0)
        (setq proj-name nil)
      )
      (td-set-project proj-num proj-name)
      (princ "\n** Project information set **")
    )
    (princ "\n** Cancelled **")
  )

  (princ "\n========================================")
  (princ)
)

(princ "\n========================================")
(princ "\n  Summary Table Module Loaded")
(princ "\n========================================")
(princ "\nCommands available:")
(princ "\n  TD_PROJECT   - Set project information")
(princ "\n  TD_SUMTAB    - Create summary table")
(princ "\n  TD_SHOWDATA  - Show collected data")
(princ "\n  TD_CLEARDATA - Clear all data")
(princ "\n========================================")
(princ)
