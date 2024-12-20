import AOC

aoc 2024, 20 do
  @moduledoc """
  https://adventofcode.com/2024/day/20
  """

  def p1(input) do
    RaceCondition.run(input)
  end

  def p2(input) do
    RaceConditionPart2.run(input)
  end
end

defmodule RaceCondition do
  def run(input) do
    map = input
          |> String.split("\n", trim: true)
          |> Enum.map(&String.graphemes/1)

    # Parse the map
    {grid, start_pos, end_pos} = parse_map(map)

    if start_pos == nil or end_pos == nil do
      IO.puts "Start (S) or End (E) not found in map!"
      IO.puts "Number of cheats saving >= 100 picoseconds: 0"
      System.halt(0)
    end

    # Compute shortest distance from every cell to E without cheating
    dist_to_end = bfs_all_distances(grid, end_pos)

    # Compute shortest path from S to E without cheating
    normal_dist = Map.get(dist_to_end, start_pos, :infinity)
    if normal_dist == :infinity do
      IO.puts "No path from S to E without cheating!"
      IO.puts "Number of cheats saving >= 100 picoseconds: 0"
      System.halt(0)
    end

    # Compute distances from S as well
    dist_from_start = bfs_all_distances(grid, start_pos)

    normal_path_time = normal_dist

    # Gather all reachable track cells
    reachable_cells = dist_to_end
                      |> Enum.filter(fn {_pos, d} -> d != :infinity end)
                      |> Enum.map(fn {pos, _} -> pos end)

    # Attempt cheats:
    # Given the map size, this may take a very long time.
    # This brute force checks all pairs of reachable cells as start/end for the cheat.
    IO.puts "Computing cheats... (This might take a long time)"
    cheats =
      for start_cell <- reachable_cells,
          end_cell <- reachable_cells,
          start_cell != end_cell,
          dist_from_start[start_cell] != :infinity,
          dist_to_end[end_cell] != :infinity,
          saving = try_cheat(grid, dist_from_start, dist_to_end, normal_path_time, start_cell, end_cell),
          saving > 0,
          do: {saving, start_cell, end_cell}

    cheats_100_or_more = Enum.count(cheats, fn {saving, _, _} -> saving >= 100 end)

    IO.puts "Number of cheats saving >= 100 picoseconds: #{cheats_100_or_more}"
  end

  defp parse_map(map) do
    grid =
      map
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        Enum.with_index(row)
        |> Enum.map(fn {cell, x} -> {{x, y}, cell} end)
      end)
      |> Enum.into(%{})

    start_pos = Enum.find_value(grid, fn {pos, val} -> val == "S" && pos end)
    IO.puts("Start: #{inspect(start_pos)}")
    end_pos = Enum.find_value(grid, fn {pos, val} -> val == "E" && pos end)
    IO.puts("End: #{inspect(end_pos)}")
    {grid, start_pos, end_pos}
  end

  defp bfs_all_distances(grid, start) do
    neighbors_fun = fn {x, y} ->
      [{x+1,y},{x-1,y},{x,y+1},{x,y-1}]
      |> Enum.filter(fn p -> passable?(grid, p) end)
    end

    queue = :queue.from_list([{start, 0}])
    visited = Map.new([{start, 0}])

    bfs_loop(queue, visited, neighbors_fun)
  end

  defp bfs_loop(queue, visited, neighbors_fun) do
    case :queue.out(queue) do
      {{:value, {pos, dist}}, rest} ->
        new_visited =
          neighbors_fun.(pos)
          |> Enum.reduce(visited, fn npos, acc ->
            if Map.has_key?(acc, npos) do
              acc
            else
              Map.put(acc, npos, dist+1)
            end
          end)

        new_queue =
          neighbors_fun.(pos)
          |> Enum.reject(&Map.has_key?(visited, &1))
          |> Enum.reduce(rest, fn npos, q -> :queue.in({npos, dist+1}, q) end)

        bfs_loop(new_queue, new_visited, neighbors_fun)

      {:empty, _} ->
        visited
    end
  end

  defp passable?(grid, pos) do
    case Map.get(grid, pos, "#") do
      "#" -> false
      _ -> true
    end
  end

  defp track?(grid, pos) do
    case Map.get(grid, pos, "#") do
      "#" -> false
      _ -> true
    end
  end

  defp try_cheat(grid, dist_from_start, dist_to_end, normal_path_time, start_cell, end_cell) do
    directions = [{1,0},{-1,0},{0,1},{0,-1}]

    two_step_paths =
      for {dx1, dy1} <- directions,
          {dx2, dy2} <- directions do
        step1 = {elem(start_cell,0)+dx1, elem(start_cell,1)+dy1}
        step2 = {elem(step1,0)+dx2, elem(step1,1)+dy2}
        {step1, step2}
      end

    valid_paths = Enum.filter(two_step_paths, fn {_s1, s2} -> s2 == end_cell end)

    if not track?(grid, end_cell) do
      0
    else
      possible_cheats =
        Enum.filter(valid_paths, fn {s1, s2} ->
          c1 = Map.get(grid, s1, "#")
          c2 = Map.get(grid, s2, "#")
          # Must pass through at least one wall, and end on track:
          (c1 == "#" or c2 == "#") and c2 != "#"
        end)

      if possible_cheats == [] do
        0
      else
        dist_s_start = Map.get(dist_from_start, start_cell, :infinity)
        dist_end_e = Map.get(dist_to_end, end_cell, :infinity)
        if dist_s_start == :infinity or dist_end_e == :infinity do
          0
        else
          cheated_time = dist_s_start + 2 + dist_end_e
          saving = normal_path_time - cheated_time
          if saving > 0, do: saving, else: 0
        end
      end
    end
  end
end


defmodule RaceConditionPart2 do
  @max_cheat_steps 20

  def run(input) do
    map = input
          |> String.split("\n", trim: true)
          |> Enum.map(&String.graphemes/1)

    # Parse the map
    {grid, start_pos, end_pos} = parse_map(map)

    if start_pos == nil or end_pos == nil do
      IO.puts "Start (S) or End (E) not found!"
      IO.puts "Cheats >= 100 savings: 0"
      System.halt(0)
    end

    dist_from_start = bfs_all_distances(grid, start_pos)
    dist_to_end = bfs_all_distances(grid, end_pos)
    normal_dist = Map.get(dist_from_start, end_pos, :infinity)

    if normal_dist == :infinity do
      IO.puts "No normal path from S to E!"
      IO.puts "Cheats >= 100 savings: 0"
      System.halt(0)
    end

    # Get all reachable track cells
    reachable_cells = dist_from_start
      |> Enum.filter(fn {_pos, d} -> d != :infinity end)
      |> Enum.map(fn {pos,_} -> pos end)

    IO.puts "Enumerating cheats... (This may be very slow)"

    cheats =
      for start_cell <- reachable_cells,
          dist_from_start[start_cell] != :infinity,
          dist_s_start = Map.get(dist_from_start, start_cell),
          end_cell <- reachable_cells,
          start_cell != end_cell,
          dist_to_end[end_cell] != :infinity,
          dist_end_e = Map.get(dist_to_end, end_cell),
          # Attempt a cheat path up to 20 steps
          saving = try_cheat(grid, dist_s_start, dist_end_e, normal_dist, start_cell, end_cell),
          saving > 0,
          do: saving

    cheats_100_or_more = Enum.count(cheats, &(&1 >= 100))

    IO.puts "Number of cheats saving >= 100 picoseconds: #{cheats_100_or_more}"
  end

  defp parse_map(map) do
    grid =
      map
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        Enum.with_index(row)
        |> Enum.map(fn {cell, x} -> {{x, y}, cell} end)
      end)
      |> Enum.into(%{})

    start_pos = Enum.find_value(grid, fn {pos, val} -> val == "S" && pos end)
    end_pos = Enum.find_value(grid, fn {pos, val} -> val == "E" && pos end)

    {grid, start_pos, end_pos}
  end

  defp bfs_all_distances(grid, start) do
    neighbors_fun = fn {x,y} ->
      [{x+1,y},{x-1,y},{x,y+1},{x,y-1}]
      |> Enum.filter(&passable?(grid, &1))
    end

    queue = :queue.from_list([{start, 0}])
    visited = Map.new([{start, 0}])
    bfs_loop(queue, visited, neighbors_fun)
  end

  defp bfs_loop(queue, visited, neighbors_fun) do
    case :queue.out(queue) do
      {{:value, {pos, dist}}, rest} ->
        new_visited =
          neighbors_fun.(pos)
          |> Enum.reduce(visited, fn npos, acc ->
            if Map.has_key?(acc, npos) do
              acc
            else
              Map.put(acc, npos, dist+1)
            end
          end)

        new_queue =
          neighbors_fun.(pos)
          |> Enum.reject(&Map.has_key?(visited, &1))
          |> Enum.reduce(rest, fn npos, q -> :queue.in({npos, dist+1}, q) end)

        bfs_loop(new_queue, new_visited, neighbors_fun)
      {:empty, _} ->
        visited
    end
  end

  defp passable?(grid, pos) do
    case Map.get(grid, pos, "#") do
      "#" -> false
      _ -> true
    end
  end

  defp track?(grid, pos) do
    case Map.get(grid, pos, "#") do
      "#" -> false
      _ -> true
    end
  end

  # try_cheat: attempt to see if we can go from start_cell to end_cell with ≤20 steps, passing through walls if needed.
  # Returns how much time saved if successful, else 0.
  # cheated_time = dist(S->start) + cheat_steps + dist(end->E)
  # saving = normal_dist - cheated_time
  defp try_cheat(grid, dist_s_start, dist_end_e, normal_dist, start_cell, end_cell) do
    # We run a BFS that allows up to 20 steps and can pass through walls.
    # After BFS, if we can reach end_cell on track with ≤20 steps,
    # and at least one wall was passed, it's a valid cheat.
    #
    # State: {pos, steps_taken, passed_wall?}
    # Actually, we must remember we can pass through walls any number of times up to 20 steps total.
    # Wait, we can pass through any number of walls within these 20 steps. The problem states the cheat can last up to 20 picoseconds,
    # i.e., up to 20 moves total, not just walls. The difference from part 1 is that we can move through walls as if they were track,
    # for up to 20 steps, but we must still land on track at the end. We must confirm at least one wall was traversed to be considered a cheat.
    #
    # We'll do a BFS allowing moves in the 4 directions. Every step counts towards the 20 limit. We don't differentiate between passing track or wall here,
    # just that the cheat mode allows passing walls. But we must track if we passed at least one wall.
    #
    # We'll keep track of visited states as {pos, steps_taken, passed_wall}. We'll stop if steps_taken > 20.
    # At the end, if we reach end_cell with steps ≤ 20 and track?(end_cell) == true, and passed_wall == true, we have a cheat.

    # If start or end are not track, no valid cheat.
    unless track?(grid, start_cell) and track?(grid, end_cell) do
      return0()
    end

    directions = [{1,0},{-1,0},{0,1},{0,-1}]
    initial = {start_cell, 0, false}
    visited = MapSet.new([initial])
    queue = :queue.from_list([initial])

    found_steps = nil

    bfs_cheat = fn bfs_cheat, q, v ->
      case :queue.out(q) do
        {{:value, {pos, steps, passed_wall}}, rest} ->
          if pos == end_cell and track?(grid, pos) and steps <= @max_cheat_steps and passed_wall do
            # Found a valid cheat path
            steps_count = steps
            {steps_count, v, rest}
          else
            if steps == @max_cheat_steps do
              # Can't go further
              bfs_cheat.(bfs_cheat, rest, v)
            else
              next_states =
                for {dx,dy} <- directions do
                  next_pos = {elem(pos,0)+dx, elem(pos,1)+dy}
                  # We can pass walls here due to cheat mode.
                  # Check if this step is a wall:
                  cell = Map.get(grid, next_pos, "#")
                  # If wall:
                  passed = passed_wall or (cell == "#")
                  # We can still go through since cheating mode is on.
                  {next_pos, steps+1, passed}
                end

              {q2,v2} =
                Enum.reduce(next_states, {rest,v}, fn state, {acc_q, acc_v} ->
                  if MapSet.member?(acc_v, state) do
                    {acc_q, acc_v}
                  else
                    { :queue.in(state, acc_q), MapSet.put(acc_v, state) }
                  end
                end)

              bfs_cheat.(bfs_cheat, q2, v2)
            end
          end
        {:empty, _} ->
          {nil, v, q}
      end
    end

    {found_steps,_,_} = bfs_cheat.(bfs_cheat, queue, visited)

    if found_steps == nil do
      0
    else
      # Compute saving
      cheated_time = dist_s_start + found_steps + dist_end_e
      saving = normal_dist - cheated_time
      if saving > 0, do: saving, else: 0
    end
  end

  defp return0(), do: 0
end
