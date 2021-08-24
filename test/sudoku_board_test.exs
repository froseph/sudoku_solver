defmodule SudokuBoardTest do
  use ExUnit.Case
  doctest SudokuBoard

  test "create a sudoku board" do
    grid = [0,0,1,2,0,0,0,0,1,2,3,4,0,0,0,0]
    board = SudokuBoard.new(grid)
    assert board.size == 4
    assert board.grid == grid
  end
end
