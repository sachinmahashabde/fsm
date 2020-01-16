#lang racket
#|
Created by Joshua Schappel on 12/19/19
  This fild contains the runPorgam function. That checks a given machine and determins if the program should run
|#


(require "../../fsm-main.rkt" "../structs/world.rkt" "../structs/state.rkt" "../structs/machine.rkt"
         "../structs/posn.rkt" "../structs/msgWindow.rkt" "../globals.rkt")


(provide runProgram)

;; runProgram: world -> world
;; Purpose: Calles sm-showtransitons on the world machine. If it is valid then the next and prev buttons will work and the user can use the program
(define runProgram(lambda (w)
                    (let (
                          ;; The world fsm-machine
                          (fsm-machine (world-fsm-machine w))
                          ;; A condensed list of just the state-name symbols
                          (state-list (map (lambda (x) (fsm-state-name x)) (machine-state-list (world-fsm-machine w)))))

                  
                      (cond
                        [(isValidMachine? state-list fsm-machine)
                         (letrec (
                                  ;; The passing machine
                                  (m (case (machine-type fsm-machine)
                                       ['dfa (make-unchecked-dfa state-list
                                                                 (machine-alpha-list (world-fsm-machine w))
                                                                 (machine-start-state (world-fsm-machine w))
                                                                 (machine-final-state-list (world-fsm-machine w))
                                                                 (machine-rule-list (world-fsm-machine w)))]
                                       ['ndfa (make-unchecked-ndfa state-list
                                                                   (machine-alpha-list (world-fsm-machine w))
                                                                   (machine-start-state (world-fsm-machine w))
                                                                   (machine-final-state-list (world-fsm-machine w))
                                                                   (machine-rule-list (world-fsm-machine w)))]
                                       ['pda (make-unchecked-ndpda state-list
                                                                   (machine-alpha-list (world-fsm-machine w))
                                                                   (pda-machine-stack-alpha-list (world-fsm-machine w))
                                                                   (machine-start-state (world-fsm-machine w))
                                                                   (machine-final-state-list (world-fsm-machine w))
                                                                   (machine-rule-list (world-fsm-machine w)))]
                                       [else println("TODO")])))
                           (begin
                             (define unprocessed-list (sm-showtransitions m (machine-sigma-list (world-fsm-machine w)))) ;; Unprocessed transitions
                             (define new-list (remove-duplicates (append (sm-getstates m) state-list))) ;; new-list: checks for any fsm state add-ons (ie. 'ds)
                             (world
                              (constructWorldMachine new-list fsm-machine m)
                              (world-tape-position w)
                              CURRENT-RULE
                              (machine-start-state (world-fsm-machine w))
                              (world-button-list w)
                              (world-input-list w)
                                    
                              (if (list? unprocessed-list)
                                  (list (car unprocessed-list))
                                  '())
                                    
                              (if (list? unprocessed-list)
                                  (cdr unprocessed-list)
                                  '())
                                    
                              (if (list? unprocessed-list)
                                  (msgWindow "The machine was sucessfuly Built. Press Next and Prev to show the machine's transitions" "Success"
                                             (posn (/ WIDTH 2) (/ HEIGHT 2)) MSG-SUCCESS)
                                  (msgWindow "The Input was rejected" "Warning"
                                             (posn (/ WIDTH 2) (/ HEIGHT 2)) MSG-CAUTION))
                              0)))]
                        [else
                         (redraw-world-with-msg w "The Machine failed to build. Please see the cmd for more info" "Error" MSG-ERROR)]))))


;; isValidMachine?: list-of-states machine -> boolean
;; Purpose: Determins if the given input is a valid machine
(define (isValidMachine? state-list fsm-machine)
  (case MACHINE-TYPE
    [(pda) (check-machine
            state-list
            (machine-alpha-list fsm-machine)
            (machine-final-state-list fsm-machine)
            (machine-rule-list fsm-machine)
            (machine-start-state fsm-machine)
            (machine-type fsm-machine)
            (pda-machine-stack-alpha-list fsm-machine))]
    [(tm) (println "TODO")]
    [else
     (check-machine
      state-list
      (machine-alpha-list fsm-machine)
      (machine-final-state-list fsm-machine)
      (machine-rule-list fsm-machine)
      (machine-start-state fsm-machine)
      (machine-type fsm-machine))]))


;; constructworldMachine: list-of-states sigma-list machine -> machine/pda-machine
;; Purpose: cunstructs the proper machine based on the type needed
(define (constructWorldMachine state-list worldMachine newMachine)
  (case MACHINE-TYPE
    [(pda)
     (pda-machine
      (addTrueFunctions state-list worldMachine)
      (sm-getstart newMachine)
      (sm-getfinals newMachine)
      (sm-getrules newMachine)
      (machine-sigma-list worldMachine)
      (sm-getalphabet newMachine)
      (sm-type newMachine)
      (sm-getstackalphabet newMachine))]
    [(tm) (println "TODO")]
    [else
     (machine
      (addTrueFunctions state-list worldMachine)
      (sm-getstart newMachine)
      (sm-getfinals newMachine)
      (sm-getrules newMachine)
      (machine-sigma-list worldMachine)
      (sm-getalphabet newMachine)
      (sm-type newMachine))]))
      

    ;; addTrueFunctions: list-of-states -> list-of-states
    ;; Adds the default true function to every state in the list if it doesnt have a function
    (define (addTrueFunctions los m)
      (letrec (
               ;; in-cur-state-list: symbol machine-state-list -> boolean/state-struct
               ;; Purpose: Returns a state-struct if its name is the same as the symbol, otherwise
               ;;   it returns false.
               (in-cur-state-list (lambda (s msl)
                                    (cond
                                      [(empty? msl) #f]
                                      [(equal? s (fsm-state-name (car msl))) (car msl)]
                                      [else (in-cur-state-list s (cdr msl))]))))
        (map (lambda (x)
               (let (
                     (state (in-cur-state-list x (machine-state-list m))))
                 (cond
                   [(not (equal? #f state)) state]
                   [else
                    (fsm-state x TRUE-FUNCTION (posn 0 0))])))
             los)))
  



    