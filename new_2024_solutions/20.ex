import AOC

aoc 2024, 20 do
  @moduledoc """
  https://adventofcode.com/2024/day/20

  Race Condition - maze with cheats that pass through walls.
  P1: 2-step cheats saving ≥100 picoseconds.
  P2: 20-step cheats saving ≥100 picoseconds.

  For each pair of track positions, if Manhattan distance ≤ cheat_len
  and time saved ≥ 100, count it.
  """

  def p1(input) do
    solve(input, 2, 100)
  end

  def p2(input) do
    solve(input, 20, 100)
  end

  defp solve(input, max_cheat, min_save) do
    {grid, start, goal} = parse(input)
    # Get distances from start to all positions
    dist_from_start = bfs(start, grid)
    # Get distances from goal to all positions
    dist_from_goal = bfs(goal, grid)
    normal_dist = Map.get(dist_from_start, goal)

    # Find all valid cheats
    track_positions = Map.keys(dist_from_start)

    track_positions
    |> Enum.flat_map(fn pos1 ->
      dist1 = Map.get(dist_from_start, pos1)

      track_positions
      |> Enum.filter(fn pos2 ->
        manhattan(pos1, pos2) <= max_cheat
      end)
      |> Enum.map(fn pos2 ->
        cheat_dist = manhattan(pos1, pos2)
        dist2 = Map.get(dist_from_goal, pos2)
        total = dist1 + cheat_dist + dist2
        savings = normal_dist - total
        {pos1, pos2, savings}
      end)
    end)
    |> Enum.count(fn {_p1, _p2, savings} -> savings >= min_save end)
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

  defp bfs(start, grid) do
    queue = :queue.from_list([{start, 0}])
    do_bfs(queue, grid, %{start => 0})
  end

  defp do_bfs(queue, grid, distances) do
    case :queue.out(queue) do
      {:empty, _} ->
        distances

      {{:value, {{x, y}, dist}}, queue} ->
        neighbors = [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]

        {queue, distances} =
          Enum.reduce(neighbors, {queue, distances}, fn next, {q, d} ->
            if Map.has_key?(grid, next) and not Map.has_key?(d, next) do
              {:queue.in({next, dist + 1}, q), Map.put(d, next, dist + 1)}
            else
              {q, d}
            end
          end)

        do_bfs(queue, grid, distances)
    end
  end

  defp manhattan({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)
end
