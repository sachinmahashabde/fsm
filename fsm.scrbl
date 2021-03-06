; FSM Library Version 1.0
; Copyright (C) 2015 by Marco T. Morazan and Rosario Antunez
; Written by: Marco T. Morazan and Rosario Antunez, 2015

#lang scribble/manual

@(require (for-label racket))

@title{FSM: A Library for the Automata Theory Classroom}

@;Welcome to my documentation: @racket[(list 'testing 1 2 3)]

@table-of-contents[]

@defmodule[fsm]

@section{Constants}

@defidform[ARROW]
The symbol used to separate the lefthand side from the righthand side
of a grammar rule.

@defidform[BLANK]
In a Turing machine tape, this symbol denotes a blank space.

@defidform[BRANCH]
In a ctm description, this symbol denotes conditional branch.

@defidform[EMP]
The symbol denoting the empty string or character. It cannot be in 
the alphabet of a state machine or grammar.

@defidform[DEAD]
The symbol denoting the default dead state. This is the state 
reached when no transition rules applies to the current 
configuration of a state machine.

@defidform[GOTO]
In a ctm description, this symbol denotes an unconditional branch.

@defidform[LEFT]
In a Turing machine transition rule, this symbol denotes moving the 
head to the left.

@defidform[LM]
In a Turing machine tape, this symbol denotes the left end marker.


@defidform[RIGHT]
In a Turing machine transition rule, this symbol denotes moving the 
head to the right.

@defidform[START]
The seed symbol used to generate a new start state.

@defidform[VAR]
In a ctm description, this symbol denotes the introduction of a
variable to abstract over the currently read symbol.


@section{Data Definitions}



@defidform[alphabet] A list of lowercase symbols not including EMP.

@defidform[word] 
A (listof symbol). Each symbol is a member of the same alphabet.

@defidform[state]  
An uppercase letter (e.g., A) or a symbol comprised of an uppercase 
letter, dash, and number (e.g., A-72431).

@defidform[dfa-rule] 
A (list state symbol state) representing a transition in a 
deterministic finite-state automaton. The symbol must be in the 
alphabet of the machine.

@defidform[ndfa-rule] 
A (list state symbol state) representing a transition in a 
nondeterministic finite-state automaton. The symbol must either be 
in the alphabet of the machine or be EMP.

@defidform[pda-rule] 
A (list (list state symbol pop) (list state push)) denoting a 
transition in a pushdown automaton. The symbol must be in the 
alphabet of the machine. The elements to remove from the 
top of the stack are denoted by pop which is either EMP or
a list of symbols where the leftmost is first element to pop. 
The elements to place onto the top of the stack 
are denoted by push which is either EMP or a list of symbols where 
the leftmost symbol is the last element to push.

@defidform[tm-action] 
If an alphabet symbol, it denotes the symbol written to the tape of a Turing
machine. Otherwise, it is the direction in which to move the head:
RIGHT or LEFT.

@defidform[tm-rule] 
A (list (list state symbol) (list state tm-action)) representing a 
transition in a nondeterministic Turing machine. The symbol must
either be in the alphabet of the machine or be EMP.


@defidform[dfa-configuration] 
A list containing a state and a word. The word is the unread part of 
the input and the state is the current state of the machine.

@defidform[ndfa-configuration] 
A list containing a state and a word. The word is the unread part of 
the input and the state is the current state of the machine.

@defidform[pda-configuration] 
A list containing a state, a word, and a list of symbols. The state 
is the current state of the machine. The word is the unread part of 
the input. The list of symbols is the contents of the stack where
the leftmost symbol is the top of the stack.

@defidform[tm-configuration] 
A list containing a state, a batural number, and a list of symbols. 
The state is the current state of the machine. The natural number is
the head's position. The list of symbols is the contents of the tape
up to the rightmost position reached, so far, by the machine.

@defidform[regexp] A regular expression. That is, strings over an 
alphabet, E, and {(, ), (), U, *} defined as follows:
@itemlist[@item{() and each element of E is a reg-exp.}
           @item{If A and B are reg-exp, so is (AB).}
           @item{If A and B are reg-exp, so is (A U B).}
           @item{If A is a reg-exp, so is (A*).}
           @item{Nothing else is a reg-exp.}]

@defidform[terms] Lowercase letters.

@defidform[nts]  
Uppercase letters (e.g., A) or a symbols comprised of an uppercase 
letter, a dash, and a number (e.g., A-72431).

@defidform[rrule] A regular grammar rule is a list of 
the following form:
@itemlist[@item{(S ARROW EMP)}
           @item{(N ARROW a)}
           @item{(N ARROW aB)}]
S is the starting nonterminal, N and B are nonterminal symbols, and 
a is a terminal symbol.

@defidform[cfrule] A context-free grammar rule is a list of the
form (A ARROW J), where A is a nonterminal symbol and J is either
EMP or a an aggregate symbol of terminals and nonterminals.

@defidform[csrule] A context-sensitive grammar rule is a list of the
form (H ARROW K), where H is an aggregate symbol of terminals and
at least one nonterminal and J is either
EMP or a an aggregate symbol of terminals and nonterminals.

@defidform[sm]  
A state machine is either a deterministic finite-state automaton (dfa),
a nondeterministic finite-state automaton (ndfa), a nondeterministic
pushdown automaton (ndpda), or a nondeterministic Turing Machine (tm).

@defidform[smrule]  
A state machine rule is either a dfa-rule, an ndfa-rule, a 
ndpda-rule, or a tm-rule.

@defidform[grammar]  
A grammar is either a regular grammar, a context-free grammar, or
a context-sensitive grammar.

@defidform[grule]  
A grammar rule is either a rrule, a cfrule, or csrule.

@defidform[Derivation]  
A derivation is either a (list nts ARROW nts) or 
a (append (list ARROW nts) Derivation).

@defidform[ctmd]  
A combined Turing machine description is either:
@itemlist[@item{empty}
          @item{(cons tm ctmd)}
          @item{(cons LABEL ctmd)}
          @item{(cons symbol ctmd}
          @item{(cons BRANCH (listof (list symbol ctmd)))}
          @item{(cons (GOTO LABEL) ctm)}
          @item{(cons ((VAR symbol) ctm) ctm)}]
A LABEL is a natnum.

@section{State Machine Constructors}


@defproc[(make-dfa [sts (listof state)] 
                    [sigma alphabet] 
                    [start state] 
                    [finals (listof state)] 
                    [delta (listof dfa-rule)])
         dfa]{Builds a deterministic finite-state automaton. @italic{delta} is a transition function.}


@defproc[(make-ndfa [sts (listof state)] 
                     [sigma alphabet] 
                     [start state] 
                     [finals (listof state)] 
                     [delta (listof ndfa-rule)])
         ndfa]{Builds a nondeterministic finite-state automaton. @italic{delta} is a transition relation.}

@defproc[(make-ndpda [sts (listof state)] 
                     [sigma alphabet] 
                     [gamma (listof symbol)]
                     [start state] 
                     [finals (listof state)] 
                     [delta (listof pda-rule)])
         ndpda]{Builds a nondeterministic pushdown automaton from the
                given list of states, alphabet, list of stack symbols,
                statr state, list of final states, and list of
                pda-rule. @italic{delta} is a transition relation.}

@defproc[(make-tm    [sts (listof state)] 
                     [sigma alphabet] 
                     [start state] 
                     [finals (listof state)] 
                     [delta (listof ndfa-rule)]
                     (accept state))
         tm]{Builds a nondeterministic Turing machine. 
                @italic{delta} is a transition relation. If the
                optional accept argument is given then the resulting
                Turing machine is as a language recognizer.}

@defproc[(ndfa->dfa [m ndfa])
         dfa]{Builds a @italic{deterministic} finite-state 
                       automaton equivalent to the given ndfa.}

@defproc[(regexp->ndfa [r regexp])
         ndfa]{Builds a ndfa for the language of the given
                regular expression.}

@defproc[(sm-rename-states [sts (listof state)] [m1 sm])
         sm]{Builds a state machine that is excatly the same as
             the given machine except that its states are renamed
             as to not have a name in common with the given list
             of states.}

@defproc[(sm-union [m1 sm] [m2 sm])
         sm]{Builds a state machine for the language obtained
             from the union of the languages of the two given
             state machines. If the inputs are Turing machines then
             they must be language recognizers. The given machines 
             must have the same type.}

@defproc[(sm-concat [m1 sm] [m2 sm])
         sm]{Builds a state machine for the language obtained
             from the concatenation of the languages of the two given
             state machines. If the inputs are Turing machines then
             they must be language recognizers. The given machines 
             must have the same type.}

@defproc[(sm-kleenestar [m1 sm])
         sm]{Builds a state machine for the language obtained
             from the Kleene star of the given machine's language.
             If the input is a Turing machine then
             it must be language recognizer.}

@defproc[(sm-complement [m1 sm])
         sm]{Builds a state machine for the language obtained
             from the complement of the given machine's language.
             The given machine can not be a ndpda. If the inputs are 
             Turing machines then they must be language recognizers.}

@defproc[(sm-intersection [m1 sm] [m2 sm])
         sm]{Builds a state machine for the language obtained
             from the intersection of the languages of the two given
             state machines. If the inputs are Turing machines then
             they must be language recognizers. The given machines 
             must have the same type.}

@defproc[(grammar->sm [g grammar])
         sm]{Builds a state machine for the language of the given
             regular or context-free grammar.}

@section{State Machine Observers}

@defproc[(sm-getstates [m sm])
         (listof state)]{Returns the states of the given state 
                         machine.}

@defproc[(sm-getalphabet [m sm])
         alphabet]{Returns the alphabet of the given state 
                   machine.}

@defproc[(sm-getrules [m sm])
         (listof smrule)]{Returns the rules of the given state 
                          machine.}

@defproc[(sm-getstart [m sm])
         state]{Returns the start state of the given state machine.}

@defproc[(sm-getfinals [m sm])
         (listof state)]{Returns the final states of the given state 
                         machine.}

@defproc[(sm-getstackalphabet [m ndpda])
         (listof symbol)]{Returns the stack alphabet of the given pushdown
                          automaton.}

@defproc[(sm-type [m sm])
         symbol]{Returns a symbol indicating the type of the given
                 machine: dfa, ndfa, ndpda, tm, or 
                 tm-language-recognizer.}

@defproc[(sm-apply [m sm] [w word] [n natnum])
         symbol]{Applies the given state machine to the given word
                 and returns either 'accept or 'reject for a dfa, a
                 ndfa, a ndpa, or a Turing machine language 
                 recognizer. If the given machine is a Turing machine,
                 but not a language recognizer, a (list 'Halt: S) is
                 returned where S is a state. The optional natural 
                 number is only used for the initial position of a 
                 Turing machine head (the default position is zero).}

@defproc[(sm-showtransitions [m sm] [w word] [n natnum])
         (or (listof smconfig) 'reject)]{Applies the given state machine to the given word
                                         and returns a list of configurations if the machine
                                         reaches halting state and 'reject otherwise. The 
                                         optional natural 
                                         number is only used for the initial position of a 
                                         Turing machine head (the default position is zero)}

@section{State Machine Testers}

@defproc[(sm-test [m1 sm] [n natnum])
         (listof (list word symbol))]{Applies the given machine to
                                      100 randomly generated words 
                                      and returns a list of words and
                                      the obtained result. If the given
                                      machine is a Turing machine, it
                                      must be a language recognizer. The
                                      optional natural number specifies
                                      the number of tests.}

@defproc[(sm-sameresult? [m1 sm] [m2 sm] [w word])
         boolean]{Tests if the two given machines return the same
                  result when applied to the given word.}

@defproc[(sm-testequiv? [m1 sm] [m2 sm] [n natnum])
         (or boolean (listof word))]{Tests if the two given machines 
                                     return the same result when
                                     applied to the same 100 randomly
                                     generated words. Returns true
                                     if all results are the same. 
                                     Otherwise, a list of words for
                                     which different results were
                                     obtained is returned.}

@section{Grammar Constructors}

@defproc[(make-rg   [nt (listof nts)] 
                    [sigma alphabet] 
                    [delta (listof rrule)]
                    [start nts])
         rg]{Builds a regular grammar.}

@defproc[(make-cfg  [nt (listof nts)] 
                    [sigma alphabet] 
                    [delta (listof cfrule)]
                    [start nts])
         cfg]{Builds a context-free grammar.}

@defproc[(make-csg  [nt (listof nts)] 
                    [sigma alphabet] 
                    [delta (listof csrule)]
                    [start nts])
         csg]{Builds a context-sensitive grammar.}

@defproc[(grammar-union  [g1 grammar] 
                         [g2 grammar])
         grammar]{Builds a grammar for the language obtained from
                  the union of the languages of the given grammars.
                  The given grammars must have the same type.}

@defproc[(grammar-concat [g1 grammar] 
                         [g2 grammar])
         grammar]{Builds a grammar for the language obtained from
                  the concatenation of the languages of the given grammars.
                  The given grammars must have the same type.}

@defproc[(sm->grammar [m sm])
         grammar]{Builds a grammar for the language of the given
                  dfa, ndfa, or ndpda.}

@defproc[(grammar-rename-nts [g grammar])
         grammar]{Renames the nonterminals of the given grammar.}


@section{Grammar Observers}

@defproc[(grammar-getnts [g grammar])
         (listof nts)]{Returns the nonterminals of the given 
                       grammar.}

@defproc[(grammar-getalphabet [g grammar])
         alphabet]{Returns the alphabet of the given 
                       grammar.}

@defproc[(grammar-getrules [g grammar])
         (listof grule)]{Returns the rules of the given 
                       grammar.}

@defproc[(grammar-getstart [g grammar])
         nts]{Returns the starting nonterminal of the given 
                       grammar.}

@defproc[(grammar-gettype [g grammar])
         symbol]{Returns a symbol for the type of the given 
                       grammar: 'rg, 'cfg, or 'csg.}

@defproc[(grammar-derive [g grammar] [w word])
         (or Derivation string)]{If the given word is in the language of the
                     given grammar, a derivation is for it is 
                     returned. Otherwise, a string is returned
                     indicating the word is not in the language.}

@section{Grammar Testers}

@defproc[(both-derive [g1 grammar] [g2 grammar] [w word])
         boolean]{Tests if both of the given grammars obtain
                  the same result when trying to derive the given
                  word.}

@defproc[(both-testequiv [g1 grammar] [g2 grammar] [natnum n])
         (or true (listof word))]{Tests in the given grammars obtain
                                  the same results when deriving 100
                                  (or the given optional numner)
                                  randomly generated words. If all tests
                                  give the same result true is returned.
                                  Otherwise, a list or words that
                                  produce different results is 
                                  returned.}

@defproc[(grammar-test [g1 grammar] [natnum n])
         (listof (cons word (Derivation or string)))]{Tests the given grammar with 100 (or the given 
                  optional number) randomly generated words.
                  A list of pairs containing a word and the result
                  of attemting to derive the word are returned.}


@section{Combined Turing Machines}

@defproc[(combine-tms [d ctmd] [sigma alphabet])
         ctm]{Builds a (combined) Turing machine from the given
              ctmd and the given tape alphabet union {BLANK}.}

@defproc[(ctm-run [m ctm] [w tmtape] [i natnum])
         list]{Runs the given machine on the given tape with the
               head starting at position i (which must be a valid)
               index into w (without exceeding the length of w).
               A list containing the state the machine halts in, the
               position of the head, and the tape is returned.}

@section{Regular Expression Constructors}

@defproc[(empty-regexp)
         regexp]{Builds the regular expression for the empty string.}

@defproc[(singleton-regexp [a letter])
         regexp]{Builds the regular expression for a single
                 letter string.}

@defproc[(union-regexp [r1 regexp] [r2 regexp])
         regexp]{Builds a union regular expression from the given
                 regular expressions.}

@defproc[(concat-regexp [r1 regexp] [r2 regexp])
         regexp]{Builds a concatenation regular expression from the 
                 given regular expressions.}

@defproc[(kleenestar-regexp [r regexp])
         regexp]{Builds a Kleene star regular expression from the 
                 given regular expression.}


@defproc[(ndfa->regexp [m ndfa])
         reg-exp]{Returns a regular expression for the language of
                  the given ndfa.}


@section{Regular Expression Observers}

@defproc[(printable-regexp [r regexp])
         string]{Converts the given regular expression to a string.}

@section{Some Useful Functions}

@defproc[(los->symbol [l (listof symbol)])
         symbol]{Converts a list of symbols into a symbol by
                 concatenating the symbols in the list from
                 left to right.}

@defproc[(symbol->list [s symbol])
         (listof symbol)]{Converts the given symbol into a list of 
                 one-character symbols.}

@defproc[(symbol->fsmlos [s symbol])
         (listof symbol)]{Converts the given symbol into a list of 
                 FSM symbols symbols. For example, 
                 (symbol->fsmlos 'aS-1243b) returns '(a S-1243 b).}

@defproc[(generate-symbol [seed symbol] [l (listof symbol)])
         symbol]{Generates a random symbol that starts with seed
                 and that is not in the given list of symbols.}

@defproc[(symbol-upcase [s symbol])
         symbol]{Builds a symbol that is the same as the given symbol,
                 but with all characters in uppercase.}







