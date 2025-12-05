import AOC

aoc 2024, 20 do
  @moduledoc """
  https://adventofcode.com/2024/day/20

  Race Condition - maze with cheats that pass through walls.
  P1: 2-step cheats saving ≥100 picoseconds.
  P2: 20-step cheats saving ≥100 picoseconds.

  Optimized: precompute search area offsets, use path list for O(1) index access.
  """

  def p1(input) do
    solve(input, 2, 100)
  end

  def p2(input) do
    solve(input, 20, 100)
  end

  defp solve(input, max_cheat, min_save) do
    {grid, start, goal} = parse(input)
    # Build path as list from start to goal with distances
    path = build_path(start, goal, grid)
    path_map = Map.new(path)

    # Precompute search area offsets
    area = search_area(max_cheat)

    # For each position on path, check cheats using offsets
    path
    |> Enum.reduce(0, fn {{x, y}, time}, count ->
      area
      |> Enum.reduce(count, fn {{dx, dy}, cheat_dist}, acc ->
        target = {x + dx, y + dy}

        case Map.get(path_map, target) do
          nil ->
            acc

          target_time ->
            savings = target_time - time - cheat_dist

            if savings >= min_save do
              acc + 1
            else
              acc
            end
        end
      end)
    end)
  end

  defp search_area(n) do
    for dx <- -n..n,
        dy <- -n..n,
        dist = abs(dx) + abs(dy),
        dist > 0 and dist <= n,
        do: {{dx, dy}, dist}
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)

    {grid, start, goal} =
      lines
      |> Enum.with_index()
      |> Enum.reduce({%{}, nil, nil}, fn {row, y}, {g, s, e} ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce({g, s, e}, fn {c, x}, {g2, s2, e2} ->
          pos = {x, y}

          case c do
            "#" -> {g2, s2, e2}
            "S" -> {Map.put(g2, pos, "."), pos, e2}
            "E" -> {Map.put(g2, pos, "."), s2, pos}
            _ -> {Map.put(g2, pos, c), s2, e2}
          end
        end)
      end)

    {grid, start, goal}
  end

  # Build path from start to goal as list of {pos, time}
  defp build_path(start, goal, grid) do
    do_build_path(start, goal, grid, MapSet.new(), 0, [])
  end

  defp do_build_path(pos, goal, grid, visited, time, path) do
    path = [{pos, time} | path]

    if pos == goal do
      Enum.reverse(path)
    else
      visited = MapSet.put(visited, pos)
      {x, y} = pos

      next =
        [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
        |> Enum.find(fn p ->
          Map.has_key?(grid, p) and not MapSet.member?(visited, p)
        end)

      do_build_path(next, goal, grid, visited, time + 1, path)
    end
  end
end
