import AOC

aoc 2023, 11 do
  @moduledoc """
  https://adventofcode.com/2023/day/11
  """

  @doc """
      iex> p1(example_string())
      374

      iex> p1(input_string())
      9795148
  """
  def p1(input) do
    solve(input, 2)
  end

  @doc """
      iex> p2(example_string(), 10)
      1030

      iex> p2(example_string(), 100)
      8410

      iex> p2(input_string())
      650672493820
  """
  def p2(input, expansion_rate \\ 1_000_000) do
    solve(input, expansion_rate)
  end

  defp solve(input, expansion) do
    {galaxies, empty_rows, empty_cols} = parse(input)
    
    galaxies
    |> pairs()
    |> Enum.map(fn {g1, g2} -> distance(g1, g2, empty_rows, empty_cols, expansion) end)
    |> Enum.sum()
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)
    
    galaxies = for {line, y} <- Enum.with_index(lines),
                   {char, x} <- line |> String.graphemes() |> Enum.with_index(),
                   char == "#",
                   do: {x, y}
    
    max_y = length(lines) - 1
    max_x = (lines |> hd |> String.length()) - 1
    
    galaxy_xs = galaxies |> Enum.map(&elem(&1, 0)) |> MapSet.new()
    galaxy_ys = galaxies |> Enum.map(&elem(&1, 1)) |> MapSet.new()
    
    empty_rows = 0..max_y |> Enum.filter(&(not MapSet.member?(galaxy_ys, &1))) |> MapSet.new()
    empty_cols = 0..max_x |> Enum.filter(&(not MapSet.member?(galaxy_xs, &1))) |> MapSet.new()
    
    {galaxies, empty_rows, empty_cols}
  end

  defp pairs(list) do
    for {a, i} <- Enum.with_index(list),
        {b, j} <- Enum.with_index(list),
        i < j,
        do: {a, b}
  end

  defp distance({x1, y1}, {x2, y2}, empty_rows, empty_cols, expansion) do
    base_dist = abs(x2 - x1) + abs(y2 - y1)
    
    crossed_rows = empty_rows |> Enum.count(fn r -> r in min(y1, y2)..max(y1, y2) end)
    crossed_cols = empty_cols |> Enum.count(fn c -> c in min(x1, x2)..max(x1, x2) end)
    
    base_dist + (crossed_rows + crossed_cols) * (expansion - 1)
  end
end
