import AOC

aoc 2021, 5 do
  @moduledoc """
  Day 5: Hydrothermal Venture

  Map hydrothermal vents.
  Part 1: Only horizontal and vertical lines
  Part 2: Include diagonal lines (45 degrees)
  """

  @doc """
  Part 1: Count points where 2+ horizontal or vertical lines overlap.

  ## Examples

      iex> p1("0,9 -> 5,9\\n8,0 -> 0,8\\n9,4 -> 3,4\\n2,2 -> 2,1\\n7,0 -> 7,4\\n6,4 -> 2,0\\n0,9 -> 2,9\\n3,4 -> 1,4\\n0,0 -> 8,8\\n5,5 -> 8,2")
      5
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.filter(&horizontal_or_vertical?/1)
    |> count_overlaps()
  end

  @doc """
  Part 2: Count points where 2+ lines overlap (including diagonals).

  ## Examples

      iex> p2("0,9 -> 5,9\\n8,0 -> 0,8\\n9,4 -> 3,4\\n2,2 -> 2,1\\n7,0 -> 7,4\\n6,4 -> 2,0\\n0,9 -> 2,9\\n3,4 -> 1,4\\n0,0 -> 8,8\\n5,5 -> 8,2")
      12
  """
  def p2(input) do
    input
    |> parse()
    |> count_overlaps()
  end

  defp horizontal_or_vertical?({{x1, y1}, {x2, y2}}) do
    x1 == x2 or y1 == y2
  end

  defp count_overlaps(lines) do
    lines
    |> Enum.flat_map(&line_points/1)
    |> Enum.frequencies()
    |> Enum.count(fn {_, count} -> count >= 2 end)
  end

  defp line_points({{x1, y1}, {x2, y2}}) do
    dx = sign(x2 - x1)
    dy = sign(y2 - y1)
    steps = max(abs(x2 - x1), abs(y2 - y1))

    for i <- 0..steps do
      {x1 + i * dx, y1 + i * dy}
    end
  end

  defp sign(0), do: 0
  defp sign(n) when n > 0, do: 1
  defp sign(n) when n < 0, do: -1

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x1, y1, x2, y2] =
        Regex.scan(~r/\d+/, line)
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)

      {{x1, y1}, {x2, y2}}
    end)
  end
end
