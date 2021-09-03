defmodule SudokuBoard do
  @moduledoc """
  Implements a Sudoku board
  """
  defstruct size: 9, grid: List.duplicate(0, 81)
  @type t :: %SudokuBoard{size: integer, grid: list(integer)}

  @spec equals?(SudokuBoard.t(), SudokuBoard.t()) :: boolean
  def equals?(board1, board2) do
    board1.size == board2.size and board1.grid == board2.grid
  end

  @doc """
  Creates a sudokuboard from a list. No validation checking is done.

  ## Parameters

    - grid: A integer list representing a board. Element 0 is at top left, n is at bottom right.
  """
  @spec new(list(integer)) :: SudokuBoard.t()
  def new(grid) do
    size =
      grid
      |> Enum.count()
      |> integer_sqrt

    %SudokuBoard{grid: grid, size: size}
  end

  @doc """
  Parses a string representation of a sudoku board.

  Each board is a CSV containing digits 0-n where `n` x `n` is the size of the board.
  Zeros represent empty spaces.

  ## Parameters

    - board_string: A string representing a board

  ## Examples

    iex> SudokuBoard.parse("0,0,1,2,0,0,0,0,1,2,3,4,0,0,0,0")
    {:ok,
     %SudokuBoard{grid: [0, 0, 1, 2, 0, 0, 0, 0, 1, 2, 3, 4, 0, 0, 0, 0], size: 4}}

    iex> SudokuBoard.parse("0,0,1")
    {:error, "Invalid board"}

  """
  @spec parse(String.t()) :: {:ok, SudokuBoard.t()} | {:error, String.t()}
  def parse(str) do
    try do
      grid =
        str
        |> String.split(",")
        |> Enum.map(fn elt -> elt |> String.trim() |> Integer.parse() |> elem(0) end)

      size =
        grid
        |> Enum.count()
        |> integer_sqrt

      board = %SudokuBoard{size: size, grid: grid}

      if valid?(board) do
        {:ok, board}
      else
        {:error, "Invalid board"}
      end
    rescue
      _ -> {:error, "Parsing error"}
    end
  end

  # assumes a valid sudoku board
  @doc """
  Validates if a board is a partial solution

  ## Parameters

    - board: A sudoku board
  """
  @spec partial_solution?(SudokuBoard.t()) :: boolean
  def partial_solution?(%SudokuBoard{} = board) do
    rows = get_rows(board)
    cols = get_columns(board)
    boxes = get_boxes(board)

    Enum.all?(rows, &unique_list?/1) and Enum.all?(cols, &unique_list?/1) and
      Enum.all?(boxes, &unique_list?/1)
  end

  @doc """
  Reads a sudoku board from a file

  ## Parameters

    - file_path: string representing the file path of the file to be loaded
  """
  @spec read_file(String.t()) :: {:ok, SudokuBoard.t()} | {:error, String.t()}
  def read_file(path) do
    case File.read(path) do
      {:ok, data} -> parse(data)
      {:error, reason} -> {:error, "File error: " <> Atom.to_string(reason)}
    end
  end

  @doc """
  Place a number into the sudoku board. Does not ensure that the square is empty.

  ## Parameters

    - board: A sudoku board
    - index: An index into the board
    - number: The number to be placed into the board
  """
  @spec place_number(SudokuBoard.t(), integer, integer) :: SudokuBoard.t()
  def place_number(%SudokuBoard{size: size, grid: grid}, idx, number) do
    new_grid = List.replace_at(grid, idx, number)
    %SudokuBoard{size: size, grid: new_grid}
  end

  @doc """
  Tests if the board is solved

  ## Parameters

    - board: A Sudokuboard.t representing a board

  ## Examples


    iex> SudokuBoard.new([1,2,3,4,
    ...> 3,4,1,2,
    ...> 4,1,2,3,
    ...> 2,3,4,1]) |> SudokuBoard.solved?
    true

  """
  @spec solved?(SudokuBoard.t()) :: boolean
  def solved?(%SudokuBoard{} = board) do
    valid?(board) and filled?(board) and partial_solution?(board)
  end

  @doc """
  Checks if a sudoku board is well formed.

  ## Parameters

    - board: A SudokuBoard.t representing a board
  """
  @spec valid?(SudokuBoard.t()) :: boolean
  def valid?(%SudokuBoard{size: size, grid: grid}) do
    square?(size) and
      Enum.count(grid) == size * size and
      Enum.all?(grid, fn element -> 0 <= element and element <= size end)
  end

  ## Private methods

  # true if all squares in the board are populated
  defp filled?(%SudokuBoard{grid: grid}) do
    Enum.all?(grid, fn x -> x != 0 end)
  end

  @spec unique_list?(list(integer)) :: boolean
  defp unique_list?(l) do
    filled_values = Enum.filter(l, fn x -> x > 0 end)
    Enum.count(filled_values) == MapSet.new(filled_values) |> Enum.count()
  end

  @spec square?(integer) :: boolean
  defp square?(i) do
    j = integer_sqrt(i)
    j * j == i
  end

  @spec integer_sqrt(integer) :: integer
  defp integer_sqrt(i), do: trunc(:math.sqrt(i))

  @spec get_rows(SudokuBoard.t()) :: list(list(integer))
  defp get_rows(%SudokuBoard{size: size, grid: grid}) do
    Enum.chunk_every(grid, size)
  end

  @spec get_columns(SudokuBoard.t()) :: list(list(integer))
  defp get_columns(%SudokuBoard{size: size, grid: grid}) do
    grid
    |> Enum.with_index()
    |> Enum.sort(fn {_, idx_1}, {_, idx_2} ->
      get_col_index(idx_1, size) <= get_col_index(idx_2, size)
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.chunk_every(size)
  end

  @spec get_boxes(SudokuBoard.t()) :: list(list(integer))
  defp get_boxes(%SudokuBoard{size: size, grid: grid}) do
    grid
    |> Enum.with_index()
    |> Enum.sort(fn {_, idx_1}, {_, idx_2} ->
      get_box_index(idx_1, size) <= get_box_index(idx_2, size)
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.chunk_every(size)
  end

  defp get_row_index(idx, sudoku_size) do
    div(idx, sudoku_size)
  end

  defp get_col_index(idx, sudoku_size) do
    rem(idx, sudoku_size)
  end

  defp get_box_index(idx, sudoku_size) do
    box_size = integer_sqrt(sudoku_size)
    row = get_row_index(idx, sudoku_size)
    col = get_col_index(idx, sudoku_size)
    div(row, box_size) * box_size + div(col, box_size)
  end
end

defimpl String.Chars, for: SudokuBoard do
  @spec to_string(SudokuBoard.t()) :: binary()
  def to_string(%SudokuBoard{size: size, grid: grid}) do
    chunk_size =
      size
      |> :math.sqrt()
      |> trunc

    board_string =
      grid
      |> Enum.map(fn elem -> "#{elem}," end)
      |> Enum.chunk_every(size)
      |> Enum.with_index()
      |> Enum.reduce("", fn {row, idx}, acc ->
        extra_rows =
          if rem(idx, chunk_size) == 0 do
            "\n"
          else
            ""
          end

        "#{acc}#{extra_rows}\n\t    #{format_row(row, chunk_size)}"
      end)
      |> String.trim()

    ~s/%SudokuBoard{
      size: #{size},
      grid: #{board_string}
}/
  end

  defp format_row(row, chunk_size) do
    row
    |> Enum.chunk_every(chunk_size)
    |> Enum.reduce("", fn x, acc -> "#{acc}  #{x}" end)
    |> String.trim()
  end
end
