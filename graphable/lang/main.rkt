#lang racket/base

;; Correct imports for user and macro phases
(require
  (except-in racket/base #%module-begin)
  (for-syntax racket/base)
  racket/match
  syntax/parse/define
  json)

(provide
  (all-from-out racket/base)
  (all-defined-out))

;; Store schema of graphable structs
(define graph-schema (make-hasheq))

;; Counter for fresh IDs
(define (make-counter start)
  (let ([n (box start)])
    (lambda ()
      (begin0 (unbox n)
              (set-box! n (add1 (unbox n)))))))

(define-syntax-parser graphable-struct
  [(_ name (field:id ...))
   #'(begin
       (struct name (field ...) #:transparent)
       (hash-set! graph-schema 'name '(field ...)))])

;; Core graph extraction
(define (expr->graph expr)
  (define counter (make-counter 0))
  (define (new-id) (format "~a" (counter)))

  (define nodes '())
  (define edges '())

  (define (walk v)
    (define type-name (cond
                        [(struct? v) (symbol->string (object-name v))]
                        [(null? v) "null"]
                        [(list? v) "list"] ; TODO: Figure out how to handle lists?
                        [(symbol? v) "symbol"]
                        [(number? v) "number"]
                        [else "unknown"]))
    (define id (format "~a$~a" type-name (counter)))
    (cond
      [(struct? v)
       (define label id)
       (define node `((id . ,id) (label . ,label) (type . ,type-name)))
       (set! nodes (cons node nodes))

       (define name (object-name v))
       (define fields (hash-ref graph-schema name #f))
       (define field-values (cdr (vector->list (struct->vector v))))
       (for ([child field-values] [i (in-naturals)])
         (define label
           (if (and fields (< i (length fields)))
               (symbol->string (list-ref fields i))
               (format "~a~arg~a" name i)))
         (define child-id (walk child))
         (set! edges (cons `((src . ,id) (dst . ,child-id) (label . ,label)) edges)))
       id]

      [(null? v)
       (define node `((id . ,id) (label . "null") (type . "null")))
       (set! nodes (cons node nodes))
       id]

      [(list? v)
       (define node `((id . ,id) (label . "list") (type . "list")))
       (set! nodes (cons node nodes))
       (for ([elem v] [i (in-naturals)])
         (define child-id (walk elem))
         (set! edges (cons `((src . ,id) (dst . ,child-id) (label . ,(format "arg~a" i))) edges)))
       id]

      [(symbol? v)
       (define node `((id . ,id) (label . ,(symbol->string v)) (type . "symbol")))
       (set! nodes (cons node nodes))
       id]

      [(number? v)
       (define node `((id . ,id) (label . ,(format "~a" v)) (type . "number")))
       (set! nodes (cons node nodes))
       id]

      [(boolean? v)
       (define node `((id . ,id) (label . ,(if v "#t" "#f")) (type . "boolean")))
       (set! nodes (cons node nodes))
       id]

      [else
       (define node `((id . ,id) (label . "?") (type . "unknown")))
       (set! nodes (cons node nodes))
       id]))

  (walk expr)
  (values (reverse nodes) (reverse edges)))

;; Recursively convert all symbols in a jsexpr to strings
(define (symbol->string-jsexpr v)
  (cond
    [(symbol? v) (symbol->string v)]
    [(pair? v) (cons (symbol->string-jsexpr (car v)) (symbol->string-jsexpr (cdr v)))]
    [(vector? v) (list->vector (map symbol->string-jsexpr (vector->list v)))]
    [(list? v) (map symbol->string-jsexpr v)]
    [(hash? v)
     (for/hash ([(k val) (in-hash v)])
       (values (symbol->string-jsexpr k) (symbol->string-jsexpr val)))]
    [else v]))

;; Convert a list of dotted pairs to a hash table with symbol keys and string values
(define (alist->json-hash alist)
  (for/hash ([pr alist])
    (values (car pr)
            (let ([v (cdr pr)])
              (if (symbol? v) (symbol->string v) v)))))

(define (expr->graph-json expr)
  (define-values (nodes edges) (expr->graph expr))
  (define json-nodes (map alist->json-hash nodes))
  (define json-edges (map alist->json-hash edges))
  (jsexpr->string (hash 'atoms json-nodes 'relations json-edges)))
