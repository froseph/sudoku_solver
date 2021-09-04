defmodule SudokuSolver.CPSCandidates do
  @moduledoc """
  Implements  SudokuSolver using continuation passing style
  """

  @behaviour SudokuSolver

  @doc """
  Solve a soduku
  """
  @impl SudokuSolver
  @spec solve(SudokuBoardCandidates.t()) :: SudokuBoardCandidates.t() | nil
  def solve(%SudokuBoardCandidates{size: size} = board) do
    max_index = size * size - 1
    board = SudokuBoardCandidates.eliminate_candidates(board)
    solve_helper(board, max_index, fn -> nil end)
  end

  # Solves sudoku by attempting to populate cells starting at the end of the board and moving
  # to the front. Solve helper keps track of which cell we are currently trying.
  # It calls the failure continuation `fc` when needs to backtrack.
  @spec solve_helper(SudokuBoardCandidates.t(), integer(), fun()) ::
          SudokuBoardCandidates.t() | any()
  defp solve_helper(%SudokuBoardCandidates{} = board, -1, fc) do
    if SudokuBoardCandidates.solved?(board), do: board, else: fc.()
  end

  defp solve_helper(%SudokuBoardCandidates{} = board, idx, fc) do
    candidates = SudokuBoardCandidates.get_candidates(board, idx)

    if Enum.count(candidates) == 1 do
      solve_helper(board, idx - 1, fc)
    else
      try_solve(board, idx, MapSet.to_list(candidates), fc)
    end
  end

  # try_solve attempts to solve a board by populating a cell from a list of suggestions
  defp try_solve(%SudokuBoardCandidates{}, _idx, [], fc), do: fc.()

  defp try_solve(%SudokuBoardCandidates{} = board, idx, [suggestion | other_suggestions], fc) do
    position = SudokuBoardCandidates.index_to_position(board, idx)
    {:ok, new_board} = SudokuBoardCandidates.place_number(board, position, suggestion)
    new_board = SudokuBoardCandidates.eliminate_candidates(new_board)

    if SudokuBoardCandidates.partial_solution?(new_board) do
      solve_helper(new_board, idx - 1, fn -> try_solve(board, idx, other_suggestions, fc) end)
    else
      try_solve(board, idx, other_suggestions, fc)
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
    find_all_solutions_helper(board, max_index, fn -> [] end)
  end

  defp find_all_solutions_helper(board, -1, continuation) do
    if SudokuBoardCandidates.solved?(board) do
      [board | continuation.()]
    else
      continuation.()
    end
  end

  defp find_all_solutions_helper(board, idx, continuation) do
    candidates = SudokuBoardCandidates.get_candidates(board, idx)

    if Enum.count(candidates) == 1 do
      find_all_solutions_helper(board, idx - 1, continuation)
    else
      try_find_all_solutions(board, idx, MapSet.to_list(candidates), continuation)
    end
  end

  defp try_find_all_solutions(_board, _idx, [], continuation), do: continuation.()

  defp try_find_all_solutions(board, idx, [suggestion | other_suggestions], continuation) do
    position = SudokuBoardCandidates.index_to_position(board, idx)
    {:ok, new_board} = SudokuBoardCandidates.place_number(board, position, suggestion)
    new_board = SudokuBoardCandidates.eliminate_candidates(new_board)

    if SudokuBoardCandidates.partial_solution?(new_board) do
      find_all_solutions_helper(new_board, idx - 1, fn ->
        try_find_all_solutions(board, idx, other_suggestions, continuation)
      end)
    else
      try_find_all_solutions(board, idx, other_suggestions, continuation)
    end
  end
end
