defmodule SudokuSolver.RecursiveCandidates do
  @moduledoc """
  Implementes SudokuSolver using recursion
  """
  @behaviour SudokuSolver

  @doc """
  Implements a sudoku solver using recursion
  """
  @impl SudokuSolver
  @spec solve(SudokuBoardCandidates.t()) :: SudokuBoardCandidates.t() | nil
  def solve(%SudokuBoardCandidates{size: size} = board) do
    max_index = size * size - 1
    board = SudokuBoardCandidates.eliminate_candidates(board)
    solve_helper(board, max_index)
  end

  # Solves sudoku by starting using backtracing starting at the end of the board
  # and moving to the front. solve_helper keeps track of which cell we are currently trying.
  @spec solve_helper(SudokuBoardCandidates.t(), integer()) :: SudokuBoardCandidates.t() | nil
  defp solve_helper(%SudokuBoardCandidates{} = board, -1) do
    if SudokuBoardCandidates.solved?(board), do: board, else: nil
  end

  defp solve_helper(%SudokuBoardCandidates{} = board, idx) do
    candidates = SudokuBoardCandidates.get_candidates(board, idx)

    if Enum.count(candidates) == 1 do
      solve_helper(board, idx - 1)
    else
      try_solve(board, idx, MapSet.to_list(candidates))
    end
  end

  # try_solve attempts to solve a board by populating a cell from a list of suggestions.
  defp try_solve(%SudokuBoardCandidates{}, _idx, []), do: nil

  defp try_solve(%SudokuBoardCandidates{} = board, idx, [suggestion | other_suggestions]) do
    position = SudokuBoardCandidates.index_to_position(board, idx)
    {:ok, new_board} = SudokuBoardCandidates.place_number(board, position, suggestion)
    new_board = SudokuBoardCandidates.eliminate_candidates(new_board)

    if SudokuBoardCandidates.partial_solution?(new_board) do
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

  @doc """
  Finds all possible solutions to a sudoku.

  ## Parameters

    - board: A sudoku board
  """
  @impl SudokuSolver
  @spec all_solutions(SudokuBoardCandidates.t()) :: [SudokuBoardCandidates.t()]
  def all_solutions(%SudokuBoardCandidates{} = board) do
    max_index = board.size * board.size - 1
    board = SudokuBoardCandidates.eliminate_candidates(board)
    find_all_solutions_helper(board, max_index, [])
  end

  # Fand all solutions to a sudoku boart starting at the the end of the board
  # It uses the acculumator `acc` to track the previously found solutions
  defp find_all_solutions_helper(board, -1, acc) do
    if SudokuBoardCandidates.solved?(board) do
      [board | acc]
    else
      acc
    end
  end

  defp find_all_solutions_helper(%SudokuBoardCandidates{} = board, idx, acc) do
    candidates = SudokuBoardCandidates.get_candidates(board, idx)

    if Enum.count(candidates) == 1 do
      find_all_solutions_helper(board, idx - 1, acc)
    else
      try_find_all_solutions(board, idx, MapSet.to_list(candidates), acc)
    end
  end

  # try_find_all_solutions attempts to find a solution to a board by populating a cell from
  # a list of suggestions. It will exhaust all possible solutions and store the results in the accumulator.
  defp try_find_all_solutions(_board, _idx, [], acc), do: acc

  defp try_find_all_solutions(
         %SudokuBoardCandidates{} = board,
         idx,
         [suggestion | other_suggestions],
         acc
       ) do
    position = SudokuBoardCandidates.index_to_position(board, idx)
    {:ok, new_board} = SudokuBoardCandidates.place_number(board, position, suggestion)
    new_board = SudokuBoardCandidates.eliminate_candidates(new_board)

    new_acc =
      if SudokuBoardCandidates.partial_solution?(board) do
        find_all_solutions_helper(new_board, idx - 1, acc)
      else
        acc
      end

    try_find_all_solutions(board, idx, other_suggestions, new_acc)
  end
end
