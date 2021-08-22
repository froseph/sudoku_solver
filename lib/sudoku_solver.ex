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

  def solve_recusive(%SudokuBoard{size: size} = board) do
    max_index = size * size - 1
    solve_recursive_helper(board, max_index)
  end

  defp solve_recursive_helper(%SudokuBoard{} = board, -1) do
    if SudokuBoard.solved?(board), do: board, else: nil
  end
  defp solve_recursive_helper(%SudokuBoard{size: size, grid: grid} = board, idx) do
    elt = Enum.at(grid, idx)
    if elt != 0 do
      solve_recursive_helper(board, idx-1)
    else
      try_solve_recursive(board, idx, Enum.to_list(1..size))
    end
  end

  defp try_solve_recursive(%SudokuBoard{}, idx, []), do: nil
  defp try_solve_recursive(%SudokuBoard{grid: grid} = board, idx, [number | others]) do
    new_board = SudokuBoard.place_number(board, idx, number)
    if SudokuBoard.partial_solution?(new_board) do
      solution = solve_recursive_helper(new_board, idx + 1)
      if solution == nil do
        try_solve_recursive(board, idx, others)
      else
        solution
      end
    else
      try_solve_recursive(board, idx, others)
    end
  end

  def solve_cps do
    nil
  end
end
