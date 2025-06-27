#lang s-exp "../graphable/lang/main.rkt"

(require racket/pretty)

;; Define constructors for Value
(graphable-struct v-num  (value))
(graphable-struct v-str  (value))
(graphable-struct v-bool (value))
(graphable-struct v-fun  (param body env))

;; Define constructors for Expr
(graphable-struct e-num  (value))
(graphable-struct e-str  (value))
(graphable-struct e-bool (value))
(graphable-struct e-op   (op left right))
(graphable-struct e-if   (cond consq altern))
(graphable-struct e-lam  (param body))
(graphable-struct e-app  (func arg))
(graphable-struct e-var  (name))

;; Sample expression: (if #t 42 (+ 1 2))
(define sample-expr
  (e-if
   (e-bool #t)
   (e-num 42)
   (e-op '+ (e-num 1) (e-num 2))))

;; Extract and pretty-print graph
(pretty-print (expr->graph-json sample-expr))
