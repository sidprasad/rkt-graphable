#lang s-exp "graphable/lang/main.rkt"

(require racket/pretty)

(graphable-struct redblack (color value left right))

(define my-rbtree
  (redblack 'black 10
    (redblack 'red 5
      (redblack 'black 2 '() '())
      (redblack 'black 7 '() '()))
    (redblack 'red 15
      (redblack 'black 12 '() '())
      (redblack 'black 20 '() '()))))

#(pretty-print (expr->graph-str my-rbtree))
(pretty-print (expr->graph-json my-rbtree))