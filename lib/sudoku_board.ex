defmodule SudokuBoard do
  defstruct size: 9, grid: List.duplicate(0, 81)
  @type t :: %SudokuBoard{}

  @spec valid?(SudokuBoard.t) :: boolean
  def valid?(%SudokuBoard{size: size, grid: grid}) do
    square?(size) and
      Enum.count(grid) == size * size and
      Enum.all?(grid, fn element -> 0 <= element and element <= size end)
  end

  @spec load_sudoku(String.t) :: {:ok, SudokuBoard.t} | {:error, String.t}
  def load_sudoku(path) do
    case File.read(path) do
      {:ok, data} ->
        board = parse_board(data)

        if valid?(board) do
          {:ok, board}
        else
          {:error, "Invalid board"}
        end
      {:error, reason} -> {:error, "File error:" <> reason}
    end
  end

  @spec parse_board(String.t) :: SudokuBoard.t
  defp parse_board(str) do
    grid = str
      |> String.split(",")
      |> Enum.map( fn elt -> elt |> String.trim |> Integer.parse |> elem(0) end)

    size = grid
      |> Enum.count
      |> :math.sqrt
      |> trunc

    %SudokuBoard{size: size, grid: grid}
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
