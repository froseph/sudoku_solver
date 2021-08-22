defmodule SudokuBoard do
  @moduledoc """
  Implements a Sudoku board
  """
  defstruct size: 9, grid: List.duplicate(0, 81)
  @type t :: %SudokuBoard{size: integer, grid: list(integer)}

  @doc """
  Checks if a sudoku board is well formed.

  ## Parameters

    - board: A SudokuBoard.t representing a board
  """
  @spec valid?(SudokuBoard.t) :: boolean
  def valid?(%SudokuBoard{size: size, grid: grid}) do
    square?(size) and
      Enum.count(grid) == size * size and
      Enum.all?(grid, fn element -> 0 <= element and element <= size end)
  end

  @doc """
  Reads a sudoku board from a file

  ## Parameters

    - file_path: string representing the file path of the file to be loaded
  """
  @spec read_file(String.t) :: {:ok, SudokuBoard.t} | {:error, String.t}
  def read_file(path) do
    case File.read(path) do
      {:ok, data} -> parse(data)
      {:error, reason} -> {:error, "File error: " <> Atom.to_string(reason)}
    end
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

    iex> SudokuBoard.parse("0,0,1,2,0,0,0,0,1,2,3,4,0,0,0,9")
    {:error, "Invalid board"}

    iex> SudokuBoard.parse("0,0,1,2,0,0,0,0,1,2,3,4,0,0,0")
    {:error, "Invalid board"}

  """
  @spec parse(String.t) :: {:ok, SudokuBoard.t} | {:error, String.t}
  def parse(str) do
    try do
      grid = str
        |> String.split(",")
        |> Enum.map( fn elt -> elt |> String.trim |> Integer.parse |> elem(0) end)

      size = grid
        |> Enum.count
        |> :math.sqrt
        |> trunc

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

  @spec square?(Integer) :: boolean
  defp square?(i) do
    j = trunc(:math.sqrt(i))
    j * j == i
  end
end

defimpl String.Chars, for: SudokuBoard do
  def to_string(%SudokuBoard{size: size, grid: grid}) do

    chunk_size = size
      |> :math.sqrt
      |> trunc

    board_string = grid
      |> Enum.map(fn elem -> "#{elem}," end)
      |> Enum.chunk_every(size)
      |> Enum.with_index
      |> Enum.reduce("", fn {row, idx}, acc ->
        extra_rows = if rem(idx, chunk_size) == 0 do
          "\n"
        else
          ""
        end
        "#{acc}#{extra_rows}\n\t    #{format_row(row, chunk_size)}" end)
      |> String.trim

    ~s/%SudokuBoard{
      size: #{size},
      grid: #{board_string}
}/
  end

  defp format_row(row, chunk_size) do
    row
      |> Enum.chunk_every(chunk_size)
      |> Enum.reduce("", fn x, acc -> "#{acc}  #{x}" end)
      |> String.trim
  end
end
