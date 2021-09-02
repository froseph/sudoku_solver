defmodule SudokuSolver do
  @moduledoc """
  Documentation for `SudokuSolver`.
  """

  @doc """
  Implements a sudoku solver using recursion
  """
  @spec solve_recursive(SudokuBoard.t()) :: SudokuBoard.t() | nil
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

  @spec find_all_solutions_recursive(SudokuBoard.t()) :: [SudokuBoard.t()]
  def find_all_solutions_recursive(%SudokuBoard{} = board) do
    max_index = board.size * board.size - 1
    find_all_solutions_recursive_helper(board, max_index, [])
  end

  defp find_all_solutions_recursive_helper(board, -1, acc) do
    if SudokuBoard.solved?(board) do
      [board | acc]
    else
      acc
    end
  end

  defp find_all_solutions_recursive_helper(%SudokuBoard{} = board, idx, acc) do
    elt = Enum.at(board.grid, idx)

    if elt != 0 do
      find_all_solutions_recursive_helper(board, idx - 1, acc)
    else
      try_find_all_solutions_recursive(board, idx, Enum.to_list(1..board.size), acc)
    end
  end

  defp try_find_all_solutions_recursive(_board, _idx, [], acc), do: acc

  defp try_find_all_solutions_recursive(
         %SudokuBoard{} = board,
         idx,
         [suggestion | other_suggestions],
         acc
       ) do
    new_board = SudokuBoard.place_number(board, idx, suggestion)

    new_acc =
      if SudokuBoard.partial_solution?(board) do
        find_all_solutions_recursive_helper(new_board, idx - 1, acc)
      else
        acc
      end

    try_find_all_solutions_recursive(board, idx, other_suggestions, new_acc)
  end

  @doc """
  Implements a sudoku solver using continuation passing style
  """
  @spec solve_cps(SudokuBoard.t()) :: SudokuBoard.t() | nil
  def solve_cps(%SudokuBoard{size: size} = board) do
    max_index = size * size - 1
    solve_cps_helper(board, max_index, fn -> nil end)
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

  @spec find_all_solutions_cps(SudokuBoard.t()) :: [SudokuBoard.t()]
  def find_all_solutions_cps(%SudokuBoard{} = board) do
    max_index = board.size * board.size - 1
    find_all_solutions_cps_helper(board, max_index, fn -> [] end)
  end

  defp find_all_solutions_cps_helper(board, -1, continuation) do
    if SudokuBoard.solved?(board), do: [board | continuation.()], else: continuation.()
  end

  defp find_all_solutions_cps_helper(board, idx, continuation) do
    elt = Enum.at(board.grid, idx)

    if elt != 0 do
      find_all_solutions_cps_helper(board, idx - 1, continuation)
    else
      try_find_all_solutions_cps(board, idx, Enum.to_list(1..board.size), continuation)
    end
  end

  defp try_find_all_solutions_cps(_board, _idx, [], continuation), do: continuation.()

  defp try_find_all_solutions_cps(board, idx, [suggestion | other_suggestions], continuation) do
    new_board = SudokuBoard.place_number(board, idx, suggestion)

    if SudokuBoard.partial_solution?(new_board) do
      find_all_solutions_cps_helper(new_board, idx - 1, fn ->
        try_find_all_solutions_cps(board, idx, other_suggestions, continuation)
      end)
    else
      try_find_all_solutions_cps(board, idx, other_suggestions, continuation)
    end
  end

  def find_all_solutions_cps2(%SudokuBoard{} = board) do
    max_index = board.size * board.size - 1
    find_all_solutions_cps_helper2(board, max_index, fn x -> x end, fn -> [] end)
  end

  defp find_all_solutions_cps_helper2(board, -1, sc, fc) do
    if SudokuBoard.solved?(board), do: sc.([board]), else: fc.()
  end

  defp find_all_solutions_cps_helper2(board, idx, sc, fc) do
    elt = Enum.at(board.grid, idx)

    if elt != 0 do
      find_all_solutions_cps_helper2(board, idx - 1, sc, fc)
    else
      try_find_all_solutions_cps2(board, idx, Enum.to_list(1..board.size), sc, fc)
    end
  end

  defp try_find_all_solutions_cps2(_board, _idx, [], _sc, fc), do: fc.()

  defp try_find_all_solutions_cps2(board, idx, [suggestion | other_suggestions], sc, fc) do
    new_board = SudokuBoard.place_number(board, idx, suggestion)

    if SudokuBoard.partial_solution?(new_board) do
      find_all_solutions_cps_helper2(
        new_board,
        idx - 1,
        fn success ->
          try_find_all_solutions_cps2(
            board,
            idx,
            other_suggestions,
            fn s -> sc.(s ++ success) end,
            fn -> success ++ fc.() end
          )
        end,
        fn -> try_find_all_solutions_cps2(board, idx, other_suggestions, sc, fc) end
      )
    else
      try_find_all_solutions_cps2(board, idx, other_suggestions, sc, fc)
    end
  end
end
