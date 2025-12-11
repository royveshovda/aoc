import AOC

aoc 2017, 19 do
  @moduledoc """
  https://adventofcode.com/2017/day/19
  """

  def p1(input) do
    {grid, start} = parse(input)
    {letters, _steps} = follow_path(grid, start, {0, 1}, [])
    letters |> Enum.reverse() |> List.to_string()
  end

  def p2(input) do
    {grid, start} = parse(input)
    {_letters, steps} = follow_path(grid, start, {0, 1}, [])
    steps
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: false)
    grid = lines |> Enum.with_index() |> Enum.flat_map(fn {line, y} ->
      line |> String.graphemes() |> Enum.with_index() |> Enum.map(fn {char, x} -> {{x, y}, char} end)
    end) |> Enum.reject(fn {_pos, char} -> char == " " end) |> Map.new()
    start = Enum.find(grid, fn {{_x, y}, char} -> y == 0 and char == "|" end) |> elem(0)
    {grid, start}
  end

  defp follow_path(grid, pos, dir, letters, steps \\ 1) do
    {x, y} = pos
    {dx, dy} = dir
    next_pos = {x + dx, y + dy}
    case Map.get(grid, next_pos) do
      nil -> {letters, steps}
      "+" -> follow_path(grid, next_pos, find_turn(grid, next_pos, dir), letters, steps + 1)
      c when c in ["|", "-"] -> follow_path(grid, next_pos, dir, letters, steps + 1)
      letter -> follow_path(grid, next_pos, dir, [letter | letters], steps + 1)
    end
  end

  defp find_turn(grid, {x, y}, {dx, _dy}) do
    candidates = if dx == 0, do: [{1, 0}, {-1, 0}], else: [{0, 1}, {0, -1}]
    Enum.find(candidates, fn {ndx, ndy} -> Map.has_key?(grid, {x + ndx, y + ndy}) end)
  end
end
