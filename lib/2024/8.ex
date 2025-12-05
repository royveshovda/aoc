import AOC

aoc 2024, 8 do
  @moduledoc """
  https://adventofcode.com/2024/day/8

  Resonant Collinearity - Find antinodes from antenna pairs.
  """

  def p1(input) do
    {grid, bounds} = parse(input)

    grid
    |> group_by_freq()
    |> Enum.flat_map(fn {_freq, positions} -> antinodes_p1(positions) end)
    |> Enum.filter(&in_bounds?(&1, bounds))
    |> Enum.uniq()
    |> length()
  end

  def p2(input) do
    {grid, bounds} = parse(input)

    grid
    |> group_by_freq()
    |> Enum.flat_map(fn {_freq, positions} -> antinodes_p2(positions, bounds) end)
    |> Enum.uniq()
    |> length()
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)
    height = length(lines)
    width = String.length(hd(lines))

    grid =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.filter(fn {c, _} -> c != "." end)
        |> Enum.map(fn {c, x} -> {{x, y}, c} end)
      end)
      |> Map.new()

    {grid, {width, height}}
  end

  defp group_by_freq(grid) do
    grid
    |> Enum.group_by(fn {_, freq} -> freq end, fn {pos, _} -> pos end)
  end

  defp antinodes_p1(positions) do
    for {x1, y1} <- positions,
        {x2, y2} <- positions,
        {x1, y1} != {x2, y2} do
      dx = x2 - x1
      dy = y2 - y1
      {x2 + dx, y2 + dy}
    end
  end

  defp antinodes_p2(positions, {width, height}) do
    for {x1, y1} <- positions,
        {x2, y2} <- positions,
        {x1, y1} != {x2, y2},
        antinode <- line_points({x1, y1}, {x2, y2}, {width, height}) do
      antinode
    end
  end

  defp line_points({x1, y1}, {x2, y2}, {width, height}) do
    dx = x2 - x1
    dy = y2 - y1
    g = Integer.gcd(abs(dx), abs(dy))
    dx = div(dx, g)
    dy = div(dy, g)

    # Go both directions from first point
    forward = Stream.iterate({x1, y1}, fn {x, y} -> {x + dx, y + dy} end)
              |> Enum.take_while(&in_bounds?(&1, {width, height}))

    backward = Stream.iterate({x1 - dx, y1 - dy}, fn {x, y} -> {x - dx, y - dy} end)
               |> Enum.take_while(&in_bounds?(&1, {width, height}))

    forward ++ backward
  end

  defp in_bounds?({x, y}, {width, height}) do
    x >= 0 and x < width and y >= 0 and y < height
  end
end
