defmodule SudokuSolver.Recursive do
  @moduledoc """
  Implementes SudokuSolver using recursion
  """
  @behaviour SudokuSolver

  @doc """
  Implements a sudoku solver using recursion
  """
  @impl SudokuSolver
  @spec solve(SudokuBoard.t()) :: SudokuBoard.t() | nil
  def solve(%SudokuBoard{size: size} = board) do
    max_index = size * size - 1
    solve_helper(board, max_index)
  end

  # Solves sudoku by starting using backtracing starting at the end of the board
  # and moving to the front. solve_helper keeps track of which cell we are currently trying.
  @spec solve_helper(SudokuBoard.t(), integer()) :: SudokuBoard.t() | nil
  defp solve_helper(%SudokuBoard{} = board, -1) do
    if SudokuBoard.solved?(board), do: board, else: nil
  end

  defp solve_helper(%SudokuBoard{} = board, idx) do
    elt = Enum.at(board.grid, idx)

    if elt != 0 do
      solve_helper(board, idx - 1)
    else
      try_solve(board, idx, Enum.to_list(1..board.size))
    end
  end

  # try_solve attempts to solve a board by populating a cell from a list of suggestions.
  defp try_solve(%SudokuBoard{}, _idx, []), do: nil

  defp try_solve(%SudokuBoard{} = board, idx, [suggestion | other_suggestions]) do
    new_board = SudokuBoard.place_number(board, idx, suggestion)

    if SudokuBoard.partial_solution?(new_board) do
      solution = solve_helper(new_board, idx - 1)

      if solution == nil do
        try_solve(board, idx, other_suggestions)
      else
        solution
      end
    else
      try_solve(board, idx, other_suggestions)
    end
  end

  @impl SudokuSolver
  @spec all_solutions(SudokuBoard.t()) :: [SudokuBoard.t()]
  def all_solutions(%SudokuBoard{} = board) do
    max_index = board.size * board.size - 1
    find_all_solutions_helper(board, max_index, [])
  end

  # Fand all solutions to a sudoku boart starting at the the end of the board
  # It uses the acculumator `acc` to track the previously found solutions
  defp find_all_solutions_helper(board, -1, acc) do
    if SudokuBoard.solved?(board) do
      [board | acc]
    else
      acc
    end
  end

  defp find_all_solutions_helper(%SudokuBoard{} = board, idx, acc) do
    elt = Enum.at(board.grid, idx)

    if elt != 0 do
      find_all_solutions_helper(board, idx - 1, acc)
    else
      try_find_all_solutions(board, idx, Enum.to_list(1..board.size), acc)
    end
  end

  # try_find_all_solutions attempts to find a solution to a board by populating a cell from
  # a list of suggestions. It will exhaust all possible solutions and store the results in the accumulator.
  defp try_find_all_solutions(_board, _idx, [], acc), do: acc

  defp try_find_all_solutions(%SudokuBoard{} = board, idx, [suggestion | other_suggestions], acc) do
    new_board = SudokuBoard.place_number(board, idx, suggestion)

    new_acc =
      if SudokuBoard.partial_solution?(board) do
        find_all_solutions_helper(new_board, idx - 1, acc)
      else
        acc
      end

    try_find_all_solutions(board, idx, other_suggestions, new_acc)
  end
end
