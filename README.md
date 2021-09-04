# SudokuSolver

Solves sudokus

This is a playing ground for learning elixir.

Current list of implementaions include:

## Different implementations of sudoku boards:
* Using lists
* Using maps

Maps appear fasater due to O(1) access vs O(n) for lists.

## Different implementations of backtracking
* Using recursion
* Using contiunuations

### Future Ideas:
Perhaps use additional processes? Spawn one for every candidate in backgtracking algo and merge.

Continuations appear to be faster-- perhaps due to stack size?

## Test different strategies:
* Naive
* Candidate elimination when numbers are determined
** Implements naked singles

### Future Ideas:
* Hidden pairs

## Additional Ideas to implement
* Implement benchmarking suite
* Determine which strategies slow things down and which speed things up
* Find additional optimizations.
** Remove work from candidate elimination by marking cells which have already propagted
* Test limiting propagation of candidates to 1 pass vs multiple passes

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sudoku_solver` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sudoku_solver, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sudoku_solver](https://hexdocs.pm/sudoku_solver).

