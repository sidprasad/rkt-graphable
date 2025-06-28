# Graphable Language

A minimal Racket DSL for extracting graph structures from user-defined data types.

## Features
- Define custom structs with `graphable-struct`.
- Extract graph representations (nodes and edges) from any value.
- Output as S-expressions or JSON for visualization or further processing.
- Unique, type-prefixed node IDs (e.g., `redblack$n0`, `symbol$n1`, `null$n2`).
- Handles built-in types (lists, numbers, symbols, empty list) as graph nodes.

## Directory Structure
```
graphable/
  lang/
    main.rkt         ; Language implementation
example.rkt          ; Example usage
```

## Quick Start

### 1. Define a struct and build a tree
```racket
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

(pretty-print (expr->graph-str my-rbtree))   ; S-expression output
(pretty-print (expr->graph-json my-rbtree))  ; JSON output
```

### 2. Output
- `expr->graph-str` prints a readable S-expression of nodes and edges.
- `expr->graph-json` prints a JSON string suitable for graph visualization tools.

## API
- `graphable-struct`: Macro to define a struct and register its schema.
- `expr->graph`: Returns `(values nodes edges)` as lists.
- `expr->graph-str`: Returns a string representation of the graph.
- `expr->graph-json`: Returns a JSON string of the graph.

## Notes
- Node IDs are unique and prefixed by type (e.g., `redblack$n0`).
- The empty list `'()` is represented as its own node type: `null`.
- Edge labels use field names or fallback to `<type>~arg#`.
- Built-in types (list, symbol, number, null) are always included as nodes.

## License
MIT


### TODO:

- Guards for loops?
- Make all `struct`s graphable (that is , graphable-struct should override struct)