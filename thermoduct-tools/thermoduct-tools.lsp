;;;============================================================================
;;; Thermoduct Tools Library
;;;
;;; A structured AutoLISP library for floor heating design
;;;
;;; Features:
;;;   - Define rooms with floor heating parameters
;;;   - Attach loops (circuits) to rooms
;;;   - Measure lengths
;;;   - Generate summaries
;;;
;;; Author: AutoLISP Library
;;; Version: 1.0
;;;============================================================================

;;;============================================================================
;;; GLOBAL VARIABLES
;;;============================================================================

;; Global variable to store all room records
;; Each room is an association list with keys:
;;   NAME, COLLECTOR, DIAMETER, SPACING, FLOOR, AREA, CONTOUR
(if (not *td-rooms*)
  (setq *td-rooms* '())
)

;; Global variable to store all loop records
;; Each loop is an association list with keys:
;;   ROOM, COLLECTOR, INDEX, NAME, LENGTH, ENTITY
(if (not *td-loops*)
  (setq *td-loops* '())
)

;;;============================================================================
;;; TASK 1: ROOM DEFINITION - HELPER FUNCTIONS
;;;============================================================================

;; Function: td-add-room-record
;; Description: Adds a room record to the global *td-rooms* list
;; Arguments:
;;   room-name    - String: Name of the room
;;   collector    - Integer: Collector number
;;   diameter     - Integer: Pipe diameter (e.g., 16, 20)
;;   spacing      - Integer: Spacing in mm (e.g., 100, 150)
;;   floor-type   - String: Floor type (e.g., "tacker", "staalnet", "fermacell")
;;   area         - Real: Area in drawing units
;;   contour-ent  - Entity name: The polyline entity representing the room
;; Returns: The updated *td-rooms* list
(defun td-add-room-record (room-name collector diameter spacing floor-type area contour-ent / room-record)
  (setq room-record
    (list
      (cons 'NAME room-name)
      (cons 'COLLECTOR collector)
      (cons 'DIAMETER diameter)
      (cons 'SPACING spacing)
      (cons 'FLOOR floor-type)
      (cons 'AREA area)
      (cons 'CONTOUR contour-ent)
    )
  )
  ;; Add the new room record to the global list
  (setq *td-rooms* (append *td-rooms* (list room-record)))
  *td-rooms*
)

;; Function: td-get-polyline-area
;; Description: Calculates the area of a closed polyline
;; Arguments:
;;   ent - Entity name of the polyline
;; Returns: Area as a real number, or nil if failed
(defun td-get-polyline-area (ent / entdata area-val)
  (setq entdata (entget ent))
  ;; Check if it's a polyline (LWPOLYLINE or POLYLINE)
  (if (or (= (cdr (assoc 0 entdata)) "LWPOLYLINE")
          (= (cdr (assoc 0 entdata)) "POLYLINE"))
    (progn
      ;; Use the AREA command to calculate the polyline area
      (command "_.AREA" "_O" ent)
      (setq area-val (getvar "AREA"))
      area-val
    )
    nil
  )
)

;; Function: td-print-room-summary
;; Description: Prints a summary of the room to the command line
;; Arguments:
;;   room-record - Association list representing the room
;; Returns: nil
(defun td-print-room-summary (room-record / area-m2)
  ;; Convert area from mm² to m²
  (setq area-m2 (/ (cdr (assoc 'AREA room-record)) 1000000.0))

  (princ "\n========================================")
  (princ "\n Room Defined Successfully!")
  (princ "\n========================================")
  (princ (strcat "\n Room Name     : " (cdr (assoc 'NAME room-record))))
  (princ (strcat "\n Collector     : " (itoa (cdr (assoc 'COLLECTOR room-record)))))
  (princ (strcat "\n Diameter      : " (itoa (cdr (assoc 'DIAMETER room-record))) " mm"))
  (princ (strcat "\n Spacing       : " (itoa (cdr (assoc 'SPACING room-record))) " mm"))
  (princ (strcat "\n Floor Type    : " (cdr (assoc 'FLOOR room-record))))
  (princ (strcat "\n Area          : " (rtos area-m2 2 2) " m²"))
  (princ "\n========================================")
  (princ)
)

;;;============================================================================
;;; TASK 1: ROOM DEFINITION - USER COMMAND
;;;============================================================================

;; Command: C:TD_ROOMDEF
;; Description: Define a room with floor heating parameters
;; Usage: Type TD_ROOMDEF at the AutoCAD command line
(defun C:TD_ROOMDEF ( / contour-ent room-name collector diameter spacing floor-type area room-record)
  (princ "\n=== Thermoduct Tools: Define Room ===")

  ;; Step 1: Select the room contour polyline
  (princ "\nSelect the closed polyline representing the room contour:")
  (setq contour-ent (car (entsel "\nSelect polyline: ")))

  (if (not contour-ent)
    (progn
      (princ "\nNo polyline selected. Command cancelled.")
      (princ)
    )
    (progn
      ;; Step 2: Get room parameters from user
      (setq room-name (getstring T "\nEnter room name: "))
      (setq collector (getint "\nEnter collector number: "))
      (setq diameter (getint "\nEnter pipe diameter (mm, e.g., 16 or 20): "))
      (setq spacing (getint "\nEnter spacing (mm, e.g., 100 or 150): "))
      (setq floor-type (getstring T "\nEnter floor type (e.g., tacker, staalnet, fermacell): "))

      ;; Step 3: Calculate the area of the contour
      (setq area (td-get-polyline-area contour-ent))

      (if (not area)
        (progn
          (princ "\nError: Could not calculate area. Make sure you selected a closed polyline.")
          (princ)
        )
        (progn
          ;; Step 4: Add the room record to global storage
          (td-add-room-record room-name collector diameter spacing floor-type area contour-ent)

          ;; Step 5: Print summary
          (setq room-record (last *td-rooms*))
          (td-print-room-summary room-record)
        )
      )
    )
  )
  (princ)
)

;;;============================================================================
;;; TASK 2: LOOP DEFINITION - HELPER FUNCTIONS
;;;============================================================================

;; Function: td-add-loop-record
;; Description: Adds a loop record to the global *td-loops* list
;; Arguments:
;;   room-name    - String: Name of the associated room
;;   collector    - Integer: Collector number
;;   index        - Integer: Loop index (1-based)
;;   loop-name    - String: Loop name (e.g., "1-1")
;;   spacing      - Integer: Spacing in mm (e.g., 100, 150)
;;   length       - Real: Length of the loop polyline
;;   loop-ent     - Entity name: The polyline entity representing the loop
;; Returns: The updated *td-loops* list
(defun td-add-loop-record (room-name collector index loop-name spacing length loop-ent / loop-record)
  (setq loop-record
    (list
      (cons 'ROOM room-name)
      (cons 'COLLECTOR collector)
      (cons 'INDEX index)
      (cons 'NAME loop-name)
      (cons 'SPACING spacing)
      (cons 'LENGTH length)
      (cons 'ENTITY loop-ent)
    )
  )
  ;; Add the new loop record to the global list
  (setq *td-loops* (append *td-loops* (list loop-record)))
  *td-loops*
)

;; Function: td-next-index-for-collector
;; Description: Finds the next available index for a given collector
;;              by looking at existing loops in *td-loops* and returning
;;              the maximum INDEX + 1 for that collector
;; Arguments:
;;   collector-num - Integer: The collector number to check
;; Returns: Integer: The next available index (starts at 1 if no loops exist)
(defun td-next-index-for-collector (collector-num / max-index loop-record current-index)
  ;; Start with max index at 0 (so first loop will be 1)
  (setq max-index 0)

  ;; Loop through all existing loops
  (foreach loop-record *td-loops*
    ;; Check if this loop belongs to the same collector
    (if (= (cdr (assoc 'COLLECTOR loop-record)) collector-num)
      (progn
        ;; Get the index of this loop
        (setq current-index (cdr (assoc 'INDEX loop-record)))
        ;; Update max-index if this index is higher
        (if (> current-index max-index)
          (setq max-index current-index)
        )
      )
    )
  )

  ;; Return the next available index
  (+ max-index 1)
)

;; Function: td-find-loop-by-entity
;; Description: Finds a loop record by its entity name
;; Arguments:
;;   loop-entity - Entity name: The polyline entity to find
;; Returns: Loop record (association list) or nil if not found
(defun td-find-loop-by-entity (loop-entity / found-loop)
  (setq found-loop nil)
  (foreach loop-record *td-loops*
    (if (equal (cdr (assoc 'ENTITY loop-record)) loop-entity)
      (setq found-loop loop-record)
    )
  )
  found-loop
)

;; Function: td-find-room-by-name
;; Description: Finds a room record by name
;; Arguments:
;;   room-name - String: Name of the room to find
;; Returns: Room record (association list) or nil if not found
(defun td-find-room-by-name (room-name / found-room)
  (setq found-room nil)
  (foreach room *td-rooms*
    (if (= (strcase (cdr (assoc 'NAME room))) (strcase room-name))
      (setq found-room room)
    )
  )
  found-room
)

;; Function: td-find-room-by-contour
;; Description: Finds a room record by its contour entity
;; Arguments:
;;   contour-ent - Entity name: The contour polyline
;; Returns: Room record (association list) or nil if not found
(defun td-find-room-by-contour (contour-ent / found-room)
  (setq found-room nil)
  (foreach room *td-rooms*
    (if (= (cdr (assoc 'CONTOUR room)) contour-ent)
      (setq found-room room)
    )
  )
  found-room
)

;; Function: td-get-polyline-length
;; Description: Calculates the total length of a polyline
;; Arguments:
;;   ent - Entity name of the polyline
;; Returns: Length as a real number, or nil if failed
(defun td-get-polyline-length (ent / entdata length-val)
  (setq entdata (entget ent))
  ;; Check if it's a polyline (LWPOLYLINE or POLYLINE)
  (if (or (= (cdr (assoc 0 entdata)) "LWPOLYLINE")
          (= (cdr (assoc 0 entdata)) "POLYLINE"))
    (progn
      ;; Get the length using vlax
      (setq length-val (vlax-curve-getDistAtParam ent (vlax-curve-getEndParam ent)))
      length-val
    )
    nil
  )
)

;; Function: td-get-polyline-center
;; Description: Gets the geometric center (centroid) of a polyline
;; Arguments:
;;   ent - Entity name of the polyline
;; Returns: Point list (x y z) or nil if failed
(defun td-get-polyline-center (ent / bbox p1 p2 center-x center-y center-z)
  (if ent
    (progn
      ;; Get the bounding box of the polyline
      (vla-getBoundingBox
        (vlax-ename->vla-object ent)
        'p1
        'p2
      )
      (setq p1 (vlax-safearray->list p1))
      (setq p2 (vlax-safearray->list p2))

      ;; Calculate center
      (setq center-x (/ (+ (car p1) (car p2)) 2.0))
      (setq center-y (/ (+ (cadr p1) (cadr p2)) 2.0))
      (setq center-z (/ (+ (caddr p1) (caddr p2)) 2.0))

      (list center-x center-y center-z)
    )
    nil
  )
)

;; Function: td-sort-loops-by-x
;; Description: Sorts a list of loop entities by their X coordinate (left to right)
;; Arguments:
;;   loop-ents - List of entity names
;; Returns: Sorted list of entity names
(defun td-sort-loops-by-x (loop-ents / loop-data sorted-data sorted-ents)
  (princ "\n[DEBUG td-sort] Entering sort function...")
  (princ (strcat "\n[DEBUG td-sort] Input list length: " (itoa (length loop-ents))))

  ;; Create a list of (entity . x-coordinate) pairs
  (princ "\n[DEBUG td-sort] Creating entity-coordinate pairs...")
  (setq loop-data
    (mapcar
      (function (lambda (ent)
        (cons ent (car (td-get-polyline-center ent)))
      ))
      loop-ents
    )
  )
  (princ (strcat "\n[DEBUG td-sort] Pairs created, length: " (itoa (length loop-data))))

  ;; Print the first pair for debugging
  (if (> (length loop-data) 0)
    (princ (strcat "\n[DEBUG td-sort] First pair X-coord: " (rtos (cdar loop-data) 2 2)))
  )

  ;; Sort by X coordinate (second element of each pair)
  (princ "\n[DEBUG td-sort] About to call vl-sort...")
  (setq sorted-data
    (vl-sort loop-data
      (function (lambda (a b)
        (< (cdr a) (cdr b))
      ))
    )
  )
  (princ "\n[DEBUG td-sort] vl-sort completed successfully")

  ;; Extract just the entity names
  (princ "\n[DEBUG td-sort] Extracting entity names from sorted pairs...")
  (setq sorted-ents
    (mapcar
      (function (lambda (pair) (car pair)))
      sorted-data
    )
  )
  (princ (strcat "\n[DEBUG td-sort] Extraction complete, final length: " (itoa (length sorted-ents))))
  sorted-ents
)

;; Function: td-print-loops-summary
;; Description: Prints a summary of all created loops
;; Arguments:
;;   room-name - String: Name of the room
;;   loop-records - List of loop records
;; Returns: nil
(defun td-print-loops-summary (room-name loop-records / total-length length-m)
  (setq total-length 0.0)

  (princ "\n========================================")
  (princ "\n Loops Defined Successfully!")
  (princ "\n========================================")
  (princ (strcat "\n Room          : " room-name))
  (princ (strcat "\n Number of Loops: " (itoa (length loop-records))))
  (princ "\n----------------------------------------")

  (foreach loop loop-records
    ;; Convert length from mm to m
    (setq length-m (/ (cdr (assoc 'LENGTH loop)) 1000.0))
    (princ (strcat "\n Loop " (cdr (assoc 'NAME loop))
                   ": " (rtos length-m 2 2) " m"))
    (setq total-length (+ total-length (cdr (assoc 'LENGTH loop))))
  )

  (princ "\n----------------------------------------")
  (princ (strcat "\n Total Length  : " (rtos (/ total-length 1000.0) 2 2) " m"))
  (princ "\n========================================")
  (princ)
)

;;;============================================================================
;;; TASK 2: LOOP DEFINITION - USER COMMAND
;;;============================================================================

;; Command: C:TD_LOOPDEF
;; Description: Define loops (circuits) for a room
;; Usage: Type TD_LOOPDEF at the AutoCAD command line
(defun C:TD_LOOPDEF ( / room-name room-record collector spacing loop-ents sorted-ents
                       index loop-ent loop-length loop-name new-loops ss loop-count i use-default)
  (princ "\n=== Thermoduct Tools: Define Loops ===")

  ;; Step 1: Get the room (for v1, just ask for room name)
  (setq room-name (getstring T "\nEnter room name: "))
  (setq room-record (td-find-room-by-name room-name))

  (if (not room-record)
    (progn
      (princ "\nWarning: Room not found in database. Continuing anyway...")
      (setq collector (getint "\nEnter collector number: "))
      (setq spacing (getint "\nEnter spacing (mm, e.g., 100 or 150): "))
    )
    (progn
      ;; Use the collector from the room record, but allow override
      (princ (strcat "\nRoom found. Default collector: "
                     (itoa (cdr (assoc 'COLLECTOR room-record)))))
      (initget "Yes No")
      (setq use-default (getkword "\nUse default collector? [Yes/No] <Yes>: "))
      (if (or (not use-default) (= use-default "Yes"))
        (setq collector (cdr (assoc 'COLLECTOR room-record)))
        (setq collector (getint "\nEnter collector number: "))
      )
      ;; Get spacing from room record
      (setq spacing (cdr (assoc 'SPACING room-record)))
    )
  )

  ;; Step 2: Select loop polylines
  (princ "\nSelect loop polylines (one or more):")
  (setq loop-ents '())
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))

  (if (not ss)
    (progn
      (princ "\nNo polylines selected. Command cancelled.")
      (princ)
    )
    (progn
      ;; Convert selection set to list of entity names
      (princ "\n[DEBUG] Converting selection set to list...")
      (setq loop-count (sslength ss))
      (princ (strcat "\n[DEBUG] Number of polylines selected: " (itoa loop-count)))
      (setq i 0)
      (repeat loop-count
        (setq loop-ents (cons (ssname ss i) loop-ents))
        (setq i (1+ i))
      )
      (setq loop-ents (reverse loop-ents))
      (princ (strcat "\n[DEBUG] Entity list created, length: " (itoa (length loop-ents))))

      ;; Step 3: Sort loops from left to right (by X coordinate)
      (princ "\n[DEBUG] About to sort loops by X coordinate...")
      (setq sorted-ents (td-sort-loops-by-x loop-ents))
      (princ (strcat "\n[DEBUG] Sorting complete, sorted list length: " (itoa (length sorted-ents))))

      ;; Step 4: Process each loop
      (princ "\n[DEBUG] Starting to process each loop...")
      ;; Get the next available index for this collector (continues numbering from existing loops)
      (setq index (td-next-index-for-collector collector))
      (princ (strcat "\n[DEBUG] Starting index for collector " (itoa collector) ": " (itoa index)))
      (setq new-loops '())

      (foreach loop-ent sorted-ents
        (princ (strcat "\n[DEBUG] Processing loop " (itoa index) "..."))

        ;; Generate loop name
        (setq loop-name (strcat (itoa collector) "-" (itoa index)))
        (princ (strcat "\n[DEBUG] Loop name: " loop-name))

        ;; Calculate length
        (princ "\n[DEBUG] Calculating length...")
        (setq loop-length (td-get-polyline-length loop-ent))
        (princ (strcat "\n[DEBUG] Length calculated: " (if loop-length (rtos loop-length 2 2) "NIL")))

        (if loop-length
          (progn
            ;; Add loop record
            (princ "\n[DEBUG] Adding loop record...")
            (td-add-loop-record room-name collector index loop-name spacing loop-length loop-ent)
            (princ "\n[DEBUG] Loop record added successfully")
            (setq new-loops (append new-loops (list (last *td-loops*))))
            (setq index (1+ index))
          )
          (princ (strcat "\nWarning: Could not calculate length for one loop."))
        )
      )

      ;; Step 5: Print summary
      (princ "\n[DEBUG] About to print summary...")
      (if (> (length new-loops) 0)
        (td-print-loops-summary room-name new-loops)
        (princ "\nNo loops were successfully processed.")
      )
      (princ "\n[DEBUG] TD_LOOPDEF completed successfully")
    )
  )
  (princ)
)

;;;============================================================================
;;; TASK 3: LOOP TAGGING - USER COMMAND
;;;============================================================================

;; Command: C:TD_TAGLOOPS
;; Description: Insert loop tags (blocks) for selected loop polylines
;; Usage: Type TD_TAGLOOPS at the AutoCAD command line
(defun C:TD_TAGLOOPS ( / block-name layer-name ss loop-count i loop-ent loop-record
                        spacing lp-value collector-str index-str insert-point
                        block-obj att-obj)
  (princ "\n=== Thermoduct Tools: Tag Loops ===")

  (setq block-name "0_07 TD - NUMMERING [Projects]")
  (setq layer-name "0_20 TD - Nummering Kringen")

  ;; Step 1: Check if block exists
  (if (not (tblsearch "BLOCK" block-name))
    (progn
      (princ (strcat "\nError: Block '" block-name "' not found in drawing!"))
      (princ "\nPlease ensure the block definition exists before running this command.")
      (princ)
    )
    (progn
      ;; Step 2: Select loop polylines
      (princ "\nSelect loop polylines to tag:")
      (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))

      (if (not ss)
        (progn
          (princ "\nNo polylines selected. Command cancelled.")
          (princ)
        )
        (progn
          ;; Step 3: Process each selected polyline
          (setq loop-count (sslength ss))
          (princ (strcat "\n" (itoa loop-count) " polyline(s) selected."))
          (setq i 0)

          (repeat loop-count
            (setq loop-ent (ssname ss i))

            ;; Find the loop record for this entity
            (setq loop-record (td-find-loop-by-entity loop-ent))

            (if (not loop-record)
              (progn
                (princ (strcat "\nWarning: No loop data found for polyline #" (itoa (+ i 1)) ". Skipping."))
              )
              (progn
                ;; Extract data from loop record
                (setq spacing (cdr (assoc 'SPACING loop-record)))
                (setq collector-str (itoa (cdr (assoc 'COLLECTOR loop-record))))
                (setq index-str (itoa (cdr (assoc 'INDEX loop-record))))

                ;; Calculate LP value: spacing / 10
                (setq lp-value (strcat "LP " (itoa (/ spacing 10))))

                ;; Ask for insertion point
                (princ (strcat "\nLoop " (cdr (assoc 'NAME loop-record))
                              " (Spacing: " (itoa spacing) "mm, "
                              lp-value ")"))
                (setq insert-point (getpoint "\nSpecify insertion point for tag: "))

                (if insert-point
                  (progn
                    ;; Step 4: Insert the block with attributes
                    ;; Set current layer to VV_KRINGSYM
                    (setvar "CLAYER" layer-name)

                    ;; Insert the block (use -INSERT to suppress attribute prompts)
                    (command "_.-INSERT" block-name insert-point "" "" "")

                    ;; Get the inserted block
                    (setq block-obj (vlax-ename->vla-object (entlast)))

                    ;; Set attributes
                    (vlax-for att-obj (vlax-invoke block-obj 'GetAttributes)
                      (cond
                        ;; Attribute LP
                        ((= (strcase (vla-get-TagString att-obj)) "LP")
                         (vla-put-TextString att-obj lp-value))

                        ;; Attribute C (collector)
                        ((= (strcase (vla-get-TagString att-obj)) "C")
                         (vla-put-TextString att-obj collector-str))

                        ;; Attribute K (index)
                        ((= (strcase (vla-get-TagString att-obj)) "K")
                         (vla-put-TextString att-obj index-str))
                      )
                    )

                    (princ (strcat "\n  Tag inserted: LP=" lp-value
                                  ", C=" collector-str
                                  ", K=" index-str))
                  )
                  (princ "\n  No insertion point specified. Skipping.")
                )
              )
            )

            (setq i (1+ i))
          )

          (princ "\n========================================")
          (princ "\nLoop tagging complete!")
          (princ "\n========================================")
        )
      )
    )
  )
  (princ)
)

;;;============================================================================
;;; UTILITY COMMANDS
;;;============================================================================

;; Command: C:TD_LISTROOMS
;; Description: List all defined rooms
;; Usage: Type TD_LISTROOMS at the AutoCAD command line
(defun C:TD_LISTROOMS ( / area-m2)
  (princ "\n========================================")
  (princ "\n Defined Rooms")
  (princ "\n========================================")

  (if (= (length *td-rooms*) 0)
    (princ "\n No rooms defined yet.")
    (foreach room *td-rooms*
      ;; Convert area from mm² to m²
      (setq area-m2 (/ (cdr (assoc 'AREA room)) 1000000.0))
      (princ (strcat "\n " (cdr (assoc 'NAME room))
                     " - Collector: " (itoa (cdr (assoc 'COLLECTOR room)))
                     " - Area: " (rtos area-m2 2 2) " m²"))
    )
  )

  (princ "\n========================================")
  (princ)
)

;; Command: C:TD_LISTLOOPS
;; Description: List all defined loops
;; Usage: Type TD_LISTLOOPS at the AutoCAD command line
(defun C:TD_LISTLOOPS ( / length-m)
  (princ "\n========================================")
  (princ "\n Defined Loops")
  (princ "\n========================================")

  (if (= (length *td-loops*) 0)
    (princ "\n No loops defined yet.")
    (foreach loop *td-loops*
      ;; Convert length from mm to m
      (setq length-m (/ (cdr (assoc 'LENGTH loop)) 1000.0))
      (princ (strcat "\n Loop " (cdr (assoc 'NAME loop))
                     " - Room: " (cdr (assoc 'ROOM loop))
                     " - Length: " (rtos length-m 2 2) " m"))
    )
  )

  (princ "\n========================================")
  (princ)
)

;; Command: C:TD_CLEARALL
;; Description: Clear all room and loop data (reset)
;; Usage: Type TD_CLEARALL at the AutoCAD command line
(defun C:TD_CLEARALL ( / )
  (initget "Yes No")
  (setq confirm (getkword "\nClear all room and loop data? [Yes/No] <No>: "))

  (if (= confirm "Yes")
    (progn
      (setq *td-rooms* '())
      (setq *td-loops* '())
      (princ "\nAll data cleared successfully.")
    )
    (princ "\nOperation cancelled.")
  )
  (princ)
)

;;;============================================================================
;;; INITIALIZATION
;;;============================================================================

(princ "\n========================================")
(princ "\n Thermoduct Tools Library Loaded")
(princ "\n========================================")
(princ "\n Available Commands:")
(princ "\n   TD_ROOMDEF   - Define a room")
(princ "\n   TD_LOOPDEF   - Define loops for a room")
(princ "\n   TD_TAGLOOPS  - Insert loop tags (blocks) for loops")
(princ "\n   TD_LISTROOMS - List all defined rooms")
(princ "\n   TD_LISTLOOPS - List all defined loops")
(princ "\n   TD_CLEARALL  - Clear all data")
(princ "\n========================================")
(princ)

;;;============================================================================
;;; END OF FILE
;;;============================================================================
