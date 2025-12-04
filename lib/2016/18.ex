import AOC

aoc 2016, 18 do
  @moduledoc """
  https://adventofcode.com/2016/day/18
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    first_row = String.trim(input) |> String.graphemes()
    count_safe_tiles(first_row, 40)
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    first_row = String.trim(input) |> String.graphemes()
    count_safe_tiles(first_row, 400000)
  end

  defp count_safe_tiles(first_row, total_rows) do
    safe_in_row = fn row -> Enum.count(row, &(&1 == ".")) end

    1..(total_rows - 1)
    |> Enum.reduce({first_row, safe_in_row.(first_row)}, fn _, {row, safe_count} ->
      next_row = next_row(row)
      {next_row, safe_count + safe_in_row.(next_row)}
    end)
    |> elem(1)
  end

  defp next_row(row) do
    width = length(row)

    for i <- 0..(width - 1) do
      left = if i > 0, do: Enum.at(row, i - 1), else: "."
      center = Enum.at(row, i)
      right = if i < width - 1, do: Enum.at(row, i + 1), else: "."

      case {left, center, right} do
        {"^", "^", "."} -> "^"
        {".", "^", "^"} -> "^"
        {"^", ".", "."} -> "^"
        {".", ".", "^"} -> "^"
        _ -> "."
      end
    end
  end
end
