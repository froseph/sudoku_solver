defmodule SudokuSolver.CPS do
  @moduledoc """
  Implements  SudokuSolver using continuation passing style
  """

  @behaviour SudokuSolver

  @doc """
  Solve a soduku
  """
  @impl SudokuSolver
  @spec solve(SudokuBoard.t()) :: SudokuBoard.t() | nil
  def solve(%SudokuBoard{size: size} = board) do
    max_index = size * size - 1
    solve_helper(board, max_index, fn -> nil end)
  end

  # Solves sudoku by attempting to populate cells starting at the end of the board and moving
  # to the front. Solve helper keps track of which cell we are currently trying.
  # It calls the failure continuation `fc` when needs to backtrack.
  @spec solve_helper(SudokuBoard.t(), integer(), fun()) :: SudokuBoard.t() | any()
  defp solve_helper(%SudokuBoard{} = board, -1, fc) do
    if SudokuBoard.solved?(board), do: board, else: fc.()
  end

  defp solve_helper(%SudokuBoard{size: size, grid: grid} = board, idx, fc) do
    elt = Enum.at(grid, idx)

    if elt != 0 do
      solve_helper(board, idx - 1, fc)
    else
      try_solve(board, idx, Enum.to_list(1..size), fc)
    end
  end

  # try_solve attempts to solve a board by populating a cell from a list of suggestions
  defp try_solve(%SudokuBoard{}, _idx, [], fc), do: fc.()

  defp try_solve(%SudokuBoard{} = board, idx, [suggestion | other_suggestions], fc) do
    new_board = SudokuBoard.place_number(board, idx, suggestion)

    if SudokuBoard.partial_solution?(new_board) do
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
  @spec all_solutions(SudokuBoard.t()) :: [SudokuBoard.t()]
  def all_solutions(%SudokuBoard{} = board) do
    max_index = board.size * board.size - 1
    find_all_solutions_helper(board, max_index, fn -> [] end)
  end

  defp find_all_solutions_helper(board, -1, continuation) do
    if SudokuBoard.solved?(board), do: [board | continuation.()], else: continuation.()
  end

  defp find_all_solutions_helper(board, idx, continuation) do
    elt = Enum.at(board.grid, idx)

    if elt != 0 do
      find_all_solutions_helper(board, idx - 1, continuation)
    else
      try_find_all_solutions(board, idx, Enum.to_list(1..board.size), continuation)
    end
  end

  defp try_find_all_solutions(_board, _idx, [], continuation), do: continuation.()

  defp try_find_all_solutions(board, idx, [suggestion | other_suggestions], continuation) do
    new_board = SudokuBoard.place_number(board, idx, suggestion)

    if SudokuBoard.partial_solution?(new_board) do
      find_all_solutions_helper(new_board, idx - 1, fn ->
        try_find_all_solutions(board, idx, other_suggestions, continuation)
      end)
    else
      try_find_all_solutions(board, idx, other_suggestions, continuation)
    end
  end
end
