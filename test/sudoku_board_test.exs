defmodule SudokuBoardTest do
  use ExUnit.Case
  doctest SudokuBoard

  test "create a sudoku board" do
    grid = [0, 0, 1, 2, 0, 0, 0, 0, 1, 2, 3, 4, 0, 0, 0, 0]
    board = SudokuBoard.new(grid)
    assert board.size == 4
    assert board.grid == grid
  end

  test "parse a valid sudoku board" do
    expected_board = SudokuBoard.new([0, 0, 1, 2, 0, 0, 0, 0, 1, 2, 3, 4, 0, 0, 0, 0])
    test_string = "0,0,1,2,0,0,0,0,1,2,3,4,0,0,0,0"
    assert {:ok, expected_board} == SudokuBoard.parse(test_string)
  end

  test "parse a sudoku board with invalid number" do
    test_string = "0,0,1,2,0,0,0,0,1,2,3,4,0,0,0,9"
    assert {:error, "Invalid board"} == SudokuBoard.parse(test_string)
  end

  test "parse a sudoku board with invalid size" do
    test_string = "0,0,1,2,0,0,0,0,1,2,3,4,0,0,0"
    assert {:error, "Invalid board"} == SudokuBoard.parse(test_string)
  end

  test "test valid partial_solution?" do
    valid_partial = SudokuBoard.new([0, 0, 1, 2, 0, 0, 0, 0, 1, 2, 3, 4, 0, 0, 0, 0])
    assert true == SudokuBoard.partial_solution?(valid_partial)
  end

  test "test invalid double columns partial_solution?" do
    invalid_partial = SudokuBoard.new([1, 2, 3, 4, 0, 0, 0, 0, 1, 2, 3, 4, 0, 0, 0, 0])
    assert false == SudokuBoard.partial_solution?(invalid_partial)
  end

  test "test invalid double rows partial_solution?" do
    invalid_partial = SudokuBoard.new([0, 1, 1, 0, 0, 0, 0, 0, 1, 2, 3, 4, 0, 0, 0, 0])
    assert false == SudokuBoard.partial_solution?(invalid_partial)
  end

  test "test invalid double box partial_solution?" do
    invalid_partial = SudokuBoard.new([0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 0, 1, 0, 0])
    assert false == SudokuBoard.partial_solution?(invalid_partial)
  end

  test "test read file" do
    input = SudokuBoard.read_file("./test/valid_4x4.txt")
    expected = SudokuBoard.new([1, 2, 3, 4, 3, 4, 1, 2, 4, 1, 2, 3, 2, 3, 4, 1])
    assert input == {:ok, expected}
  end

  test "test read invalid file with invalid sudokup board" do
    input = SudokuBoard.read_file("./test/invalid_4x4.txt")
    assert input == {:error, "Invalid board"}
  end

  test "test read nonexistant file " do
    input = SudokuBoard.read_file("./test/no_such_file.txt")
    assert input == {:error, "File error: enoent"}
  end

  test "test place_number" do
    input_board = SudokuBoard.new([0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 0, 1, 0, 0])
    expected_board = SudokuBoard.new([0, 3, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 0, 1, 0, 0])
    assert expected_board == SudokuBoard.place_number(input_board, 1, 3)
  end

  test "test validating a solved board" do
    solved = SudokuBoard.new([1, 2, 3, 4, 3, 4, 1, 2, 4, 1, 2, 3, 2, 3, 4, 1])
    assert true == SudokuBoard.solved?(solved)
  end

  test "test validating a not solved board" do
    not_solved = SudokuBoard.new([0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 0, 1, 0, 0])
    assert false == SudokuBoard.solved?(not_solved)
  end

  test "test that a board is valid" do
    valid = SudokuBoard.new([0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 0, 1, 0, 0])
    assert true == SudokuBoard.valid?(valid)
  end

  test "test that a board is not valid when grid is wrong size" do
    not_valid = SudokuBoard.new([0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 0])
    assert false == SudokuBoard.valid?(not_valid)
  end

  test "test that a board is not valid when grid is contains improper values" do
    not_valid = SudokuBoard.new([0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 0, 1, 0, 9999])
    assert false == SudokuBoard.valid?(not_valid)
  end
end
