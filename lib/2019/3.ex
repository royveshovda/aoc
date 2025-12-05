import AOC

aoc 2019, 3 do
  @moduledoc """
  https://adventofcode.com/2019/day/3
  """

  def p1(input) do
    [wire1, wire2] = parse(input)

    path1 = trace_path(wire1)
    path2 = trace_path(wire2)

    coords1 = MapSet.new(Map.keys(path1))
    coords2 = MapSet.new(Map.keys(path2))

    intersections = MapSet.intersection(coords1, coords2)

    intersections
    |> MapSet.delete({0, 0})
    |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.min()
  end

  def p2(input) do
    [wire1, wire2] = parse(input)

    path1 = trace_path(wire1)
    path2 = trace_path(wire2)

    coords1 = MapSet.new(Map.keys(path1))
    coords2 = MapSet.new(Map.keys(path2))

    intersections = MapSet.intersection(coords1, coords2)

    intersections
    |> MapSet.delete({0, 0})
    |> Enum.map(fn coord -> path1[coord] + path2[coord] end)
    |> Enum.min()
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&parse_move/1)
    end)
  end

  defp parse_move(<<dir::binary-size(1), dist::binary>>) do
    {dir, String.to_integer(dist)}
  end

  defp trace_path(moves) do
    {_, _, path} = Enum.reduce(moves, {{0, 0}, 0, %{}}, fn {dir, dist}, {pos, steps, path} ->
      delta = direction(dir)
      Enum.reduce(1..dist, {pos, steps, path}, fn _, {{x, y}, s, p} ->
        {dx, dy} = delta
        new_pos = {x + dx, y + dy}
        new_steps = s + 1
        # Only record first visit
        new_path = Map.put_new(p, new_pos, new_steps)
        {new_pos, new_steps, new_path}
      end)
    end)
    path
  end

  defp direction("U"), do: {0, 1}
  defp direction("D"), do: {0, -1}
  defp direction("L"), do: {-1, 0}
  defp direction("R"), do: {1, 0}
end
