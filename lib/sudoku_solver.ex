defmodule SudokuSolver do
  @moduledoc """
  Documentation for `SudokuSolver`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SudokuSolver.hello()
      :world

  """
  def hello do
    :world
  end

  @doc """
  Implements a sudoku solver using recursion
  """
  @spec solve_recursive(SudokuBoard.t) :: SudokuBoard.t | nil
  def solve_recursive(%SudokuBoard{size: size} = board) do
    max_index = size * size - 1
    solve_recursive_helper(board, max_index)
  end

  # Solves sudoku by starting at the end and moving to the start.
  defp solve_recursive_helper(%SudokuBoard{} = board, -1) do
    if SudokuBoard.solved?(board), do: board, else: nil
  end
  defp solve_recursive_helper(%SudokuBoard{size: size, grid: grid} = board, idx) do
    elt = Enum.at(grid, idx)
    if elt != 0 do
      solve_recursive_helper(board, idx - 1)
    else
      try_solve_recursive(board, idx, Enum.to_list(1..size))
    end
  end

  defp try_solve_recursive(%SudokuBoard{}, _idx, []), do: nil
  defp try_solve_recursive(%SudokuBoard{} = board, idx, [number | others]) do
    new_board = SudokuBoard.place_number(board, idx, number)
    if SudokuBoard.partial_solution?(new_board) do
      solution = solve_recursive_helper(new_board, idx - 1)
      if solution == nil do
        try_solve_recursive(board, idx, others)
      else
        solution
      end
    else
      try_solve_recursive(board, idx, others)
    end
  end

  @doc """
  Implements a sudoku solver using continuation passing style
  """
  @spec solve_cps(SudokuBoard.t) :: SudokuBoard.t | nil
  def solve_cps(%SudokuBoard{size: size} = board) do
    max_index = size * size - 1
    solve_cps_helper(board, max_index, fn () -> nil end)
  end

  # Solves sudoku by starting at the end and moving to the start.
  def solve_cps_helper(%SudokuBoard{} = board, -1, fc) do
    if SudokuBoard.solved?(board), do: board, else: fc.()
  end

  def solve_cps_helper(%SudokuBoard{size: size, grid: grid} = board, idx, fc) do
    elt = Enum.at(grid, idx)
    if elt != 0 do
      solve_cps_helper(board, idx - 1, fc)
    else
      try_solve_cps(board, idx, Enum.to_list(1..size), fc)
    end
  end

  defp try_solve_cps(%SudokuBoard{}, _idx, [], fc), do: fc.()
  defp try_solve_cps(%SudokuBoard{} = board, idx, [number | others], fc) do
    new_board = SudokuBoard.place_number(board, idx, number)
    if SudokuBoard.partial_solution?(new_board) do
      solve_cps_helper(new_board, idx - 1, fn -> try_solve_cps(board, idx, others, fc) end)
    else
      try_solve_cps(board, idx, others, fc)
    end
  end

end
