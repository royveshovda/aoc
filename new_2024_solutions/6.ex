import AOC

aoc 2024, 6 do
  @moduledoc """
  https://adventofcode.com/2024/day/6

  Guard Gallivant - Simulate guard path and find loop-causing positions.
  """

  def p1(input) do
    {grid, start, bounds} = parse(input)

    walk(grid, start, {0, -1}, bounds, MapSet.new())
    |> elem(1)
    |> MapSet.new(fn {pos, _dir} -> pos end)
    |> MapSet.size()
  end

  def p2(input) do
    {grid, start, bounds} = parse(input)

    # Get original path positions
    {_, visited} = walk(grid, start, {0, -1}, bounds, MapSet.new())
    path_positions = visited |> MapSet.new(fn {pos, _} -> pos end) |> MapSet.delete(start)

    # Try adding obstacle at each path position
    path_positions
    |> Enum.count(fn pos ->
      new_grid = MapSet.put(grid, pos)
      {result, _} = walk(new_grid, start, {0, -1}, bounds, MapSet.new())
      result == :loop
    end)
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)
    height = length(lines)
    width = String.length(hd(lines))

    {grid, start} =
      lines
      |> Enum.with_index()
      |> Enum.reduce({MapSet.new(), nil}, fn {row, y}, {grid, start} ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce({grid, start}, fn
          {"#", x}, {g, s} -> {MapSet.put(g, {x, y}), s}
          {"^", x}, {g, _} -> {g, {x, y}}
          _, acc -> acc
        end)
      end)

    {grid, start, {width, height}}
  end

  defp walk(grid, pos, dir, bounds, visited) do
    state = {pos, dir}

    cond do
      MapSet.member?(visited, state) ->
        {:loop, visited}

      not in_bounds?(pos, bounds) ->
        {:exit, visited}

      true ->
        visited = MapSet.put(visited, state)
        next_pos = move(pos, dir)

        if MapSet.member?(grid, next_pos) do
          walk(grid, pos, turn_right(dir), bounds, visited)
        else
          walk(grid, next_pos, dir, bounds, visited)
        end
    end
  end

  defp move({x, y}, {dx, dy}), do: {x + dx, y + dy}

  defp turn_right({0, -1}), do: {1, 0}
  defp turn_right({1, 0}), do: {0, 1}
  defp turn_right({0, 1}), do: {-1, 0}
  defp turn_right({-1, 0}), do: {0, -1}

  defp in_bounds?({x, y}, {w, h}), do: x >= 0 and x < w and y >= 0 and y < h
end
