defmodule SudokuSolverTest do
  use ExUnit.Case
  doctest SudokuSolver

  test "solve sudoku using recursion" do
    {_, input} = SudokuBoard.read_file("./test/s01a.txt")
    {_, expected} = SudokuBoard.read_file("./test/s01a_s.txt")

    solution = SudokuSolver.solve_recursive(input)
    assert expected == solution
  end

  test "solve impossible sudoku using recursion" do
    {_, input} = SudokuBoard.read_file("./test/unsolveable.txt")

    solution = SudokuSolver.solve_recursive(input)
    assert nil == solution
  end

  test "solve sudoku using cps" do
    {_, input} = SudokuBoard.read_file("./test/s01a.txt")
    {_, expected} = SudokuBoard.read_file("./test/s01a_s.txt")

    solution = SudokuSolver.solve_cps(input)
    assert expected == solution
  end

  test "solve impossible sudoku using cps" do
    {_, input} = SudokuBoard.read_file("./test/unsolveable.txt")

    solution = SudokuSolver.solve_cps(input)
    assert nil == solution
  end
end
