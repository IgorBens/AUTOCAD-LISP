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
;;   length       - Real: Length of the loop polyline
;;   loop-ent     - Entity name: The polyline entity representing the loop
;; Returns: The updated *td-loops* list
(defun td-add-loop-record (room-name collector index loop-name length loop-ent / loop-record)
  (setq loop-record
    (list
      (cons 'ROOM room-name)
      (cons 'COLLECTOR collector)
      (cons 'INDEX index)
      (cons 'NAME loop-name)
      (cons 'LENGTH length)
      (cons 'ENTITY loop-ent)
    )
  )
  ;; Add the new loop record to the global list
  (setq *td-loops* (append *td-loops* (list loop-record)))
  *td-loops*
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
  ;; Create a list of (entity . x-coordinate) pairs
  (setq loop-data
    (mapcar
      '(lambda (ent)
        (cons ent (car (td-get-polyline-center ent)))
      )
      loop-ents
    )
  )

  ;; Sort by X coordinate (second element of each pair)
  (setq sorted-data
    (vl-sort loop-data
      (function (lambda (a b)
        (< (cdr a) (cdr b))
      ))
    )
  )

  ;; Extract just the entity names
  (setq sorted-ents (mapcar 'car sorted-data))
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
(defun C:TD_LOOPDEF ( / room-name room-record collector loop-ents sorted-ents
                       index loop-ent length loop-name new-loops)
  (princ "\n=== Thermoduct Tools: Define Loops ===")

  ;; Step 1: Get the room (for v1, just ask for room name)
  (setq room-name (getstring T "\nEnter room name: "))
  (setq room-record (td-find-room-by-name room-name))

  (if (not room-record)
    (progn
      (princ "\nWarning: Room not found in database. Continuing anyway...")
      (setq collector (getint "\nEnter collector number: "))
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
      (setq loop-count (sslength ss))
      (setq i 0)
      (repeat loop-count
        (setq loop-ents (cons (ssname ss i) loop-ents))
        (setq i (1+ i))
      )
      (setq loop-ents (reverse loop-ents))

      ;; Step 3: Sort loops from left to right (by X coordinate)
      (setq sorted-ents (td-sort-loops-by-x loop-ents))

      ;; Step 4: Process each loop
      (setq index 1)
      (setq new-loops '())

      (foreach loop-ent sorted-ents
        ;; Generate loop name
        (setq loop-name (strcat (itoa collector) "-" (itoa index)))

        ;; Calculate length
        (setq length (td-get-polyline-length loop-ent))

        (if length
          (progn
            ;; Add loop record
            (td-add-loop-record room-name collector index loop-name length loop-ent)
            (setq new-loops (append new-loops (list (last *td-loops*))))
            (setq index (1+ index))
          )
          (princ (strcat "\nWarning: Could not calculate length for one loop."))
        )
      )

      ;; Step 5: Print summary
      (if (> (length new-loops) 0)
        (td-print-loops-summary room-name new-loops)
        (princ "\nNo loops were successfully processed.")
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
(princ "\n   TD_LISTROOMS - List all defined rooms")
(princ "\n   TD_LISTLOOPS - List all defined loops")
(princ "\n   TD_CLEARALL  - Clear all data")
(princ "\n========================================")
(princ)

;;;============================================================================
;;; END OF FILE
;;;============================================================================
