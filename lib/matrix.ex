defmodule Interpolation.Matrix do
  defstruct rows: []

  def new(rows, cols) do
    %__MODULE__{
      rows:
        Enum.map(1..rows, fn _ ->
          Enum.map(1..cols, fn _ -> 0 end)
        end)
    }
  end

  def elem(%__MODULE__{rows: rows}, row, col) do
    Enum.at(rows, row) |> Enum.at(col)
  end

  def set(%__MODULE__{rows: rows} = matrix, row, col, value) do
    struct(
      matrix,
      rows: List.replace_at(rows, row, List.replace_at(Enum.at(rows, row), col, value))
    )
  end
end
