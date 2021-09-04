defmodule SudokuSolverTest do
  use ExUnit.Case

  setup_all do
    [impls: [SudokuSolver.Recursive, SudokuSolver.CPS]]
  end

  test "solve sudoku", context do
    {_, input} = SudokuBoard.read_file("./test/s01a.txt")
    {_, expected} = SudokuBoard.read_file("./test/s01a_s.txt")

    for impl <- context[:impls] do
      solution = impl.solve(input)
      assert expected == solution, "#{impl} failed to solve board. Found: #{solution}"
    end
  end

  test "solve impossible sudoku", context do
    {_, input} = SudokuBoard.read_file("./test/unsolveable.txt")

    for impl <- context[:impls] do
      solution = impl.solve(input)
      assert nil == solution, "#{impl} solved impossible board"
    end
  end

  test "ensure that a sudoku with only 1 solution returns the exact solution", context do
    {_, input} = SudokuBoard.read_file("./test/s01a.txt")
    {_, expected} = SudokuBoard.read_file("./test/s01a_s.txt")

    for impl <- context[:impls] do
      solution = impl.all_solutions(input)

      assert [expected] == solution, "#{impl} found improper solutions."
    end
  end

  test "ensure that a sudoku with only 2 solutions returns only one solution", context do
    {_, input} = SudokuBoard.read_file("./test/multi.txt")
    {_, expected1} = SudokuBoard.read_file("./test/s01a_s.txt")
    {_, expected2} = SudokuBoard.read_file("./test/multi_s.txt")
    expected = MapSet.new([expected1, expected2])

    for impl <- context[:impls] do
      solution = MapSet.new(impl.all_solutions(input))

      assert expected == solution, "#{impl} found improper solutions."
    end
  end

  test "ensure that a sudoku with no solution returns empty list", context do
    {_, input} = SudokuBoard.read_file("./test/unsolveable.txt")

    for impl <- context[:impls] do
      solution = impl.all_solutions(input)
      assert [] == solution, "#{impl} found impossible solutions."
    end
  end
end
