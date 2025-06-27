#lang s-exp "graphable/lang/main.rkt"

(require racket/pretty)

(graphable-struct tree (label children))

(define my-tree
  (tree 'root
        (list (tree 'left '())
              (tree 'right '()))))

(pretty-print (expr->graph-str my-tree))
