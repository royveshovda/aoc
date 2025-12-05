import AOC

aoc 2019, 18 do
  @moduledoc """
  https://adventofcode.com/2019/day/18

  Many-Worlds Interpretation - maze with keys and doors.
  Find shortest path to collect all keys.

  Part 1: Single robot starting at @
  Part 2: Split into 4 quadrants with 4 robots
  """

  @doc """
  Find shortest path to collect all keys with single robot.

      iex> p1(example_string(3))
      86

      iex> p1(example_string(9))
      136

      iex> p1(example_string(10))
      81
  """
  def p1(input) do
    {grid, start, keys} = parse(input)
    all_keys = keys |> Map.values() |> MapSet.new()

    # Build graph of distances between keys and start
    graph = build_graph(grid, [start | Map.keys(keys)])

    # BFS with state = {positions, collected_keys}
    search([start], all_keys, graph, keys)
  end

  @doc """
  Part 2: Split maze into 4 quadrants with 4 robots.
  """
  def p2(input) do
    {grid, start, keys} = parse(input)

    # Modify grid for part 2: replace center with walls and 4 starts
    {sx, sy} = start
    modified_grid =
      grid
      |> Map.put({sx, sy}, ?#)
      |> Map.put({sx - 1, sy}, ?#)
      |> Map.put({sx + 1, sy}, ?#)
      |> Map.put({sx, sy - 1}, ?#)
      |> Map.put({sx, sy + 1}, ?#)
      |> Map.put({sx - 1, sy - 1}, ?@)
      |> Map.put({sx + 1, sy - 1}, ?@)
      |> Map.put({sx - 1, sy + 1}, ?@)
      |> Map.put({sx + 1, sy + 1}, ?@)

    starts = [
      {sx - 1, sy - 1},
      {sx + 1, sy - 1},
      {sx - 1, sy + 1},
      {sx + 1, sy + 1}
    ]

    all_keys = keys |> Map.values() |> MapSet.new()

    # Build graph including all starts and keys
    graph = build_graph(modified_grid, starts ++ Map.keys(keys))

    # Search with 4 robots
    search(starts, all_keys, graph, keys)
  end

  # Parse grid, find start position and all keys
  defp parse(input) do
    lines = String.split(input, "\n", trim: true)

    grid =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.to_charlist()
        |> Enum.with_index()
        |> Enum.map(fn {char, x} -> {{x, y}, char} end)
      end)
      |> Map.new()

    start =
      grid
      |> Enum.find(fn {_, v} -> v == ?@ end)
      |> elem(0)

    keys =
      grid
      |> Enum.filter(fn {_, v} -> v >= ?a and v <= ?z end)
      |> Map.new()

    {grid, start, keys}
  end

  # Build graph of shortest distances between all important points (starts + keys)
  # Also track which doors are needed to reach each destination
  defp build_graph(grid, points) do
    points
    |> Enum.map(fn point -> {point, bfs_from(grid, point, points)} end)
    |> Map.new()
  end

  # BFS from a point to find distances and required doors to all other points
  defp bfs_from(grid, start, targets) do
    target_set = MapSet.new(targets) |> MapSet.delete(start)

    bfs_from_loop(
      :queue.from_list([{start, 0, MapSet.new()}]),
      grid,
      target_set,
      %{start => true},
      %{}
    )
  end

  defp bfs_from_loop(queue, grid, targets, visited, results) do
    case :queue.out(queue) do
      {:empty, _} ->
        results

      {{:value, {pos, dist, doors}}, rest} ->
        # Check if this is a target
        new_results =
          if MapSet.member?(targets, pos) do
            Map.put(results, pos, {dist, doors})
          else
            results
          end

        # Get neighbors
        neighbors =
          get_neighbors(pos)
          |> Enum.filter(fn p ->
            cell = Map.get(grid, p)
            cell != nil and cell != ?# and not Map.has_key?(visited, p)
          end)

        # Add neighbors to queue with updated doors
        {new_queue, new_visited} =
          Enum.reduce(neighbors, {rest, visited}, fn p, {q, v} ->
            cell = Map.get(grid, p)
            new_doors = if cell >= ?A and cell <= ?Z, do: MapSet.put(doors, cell + 32), else: doors
            {:queue.in({p, dist + 1, new_doors}, q), Map.put(v, p, true)}
          end)

        bfs_from_loop(new_queue, grid, targets, new_visited, new_results)
    end
  end

  defp get_neighbors({x, y}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
  end

  # Dijkstra search with state = {positions, collected_keys}
  defp search(starts, all_keys, graph, keys) do
    # Priority queue: {distance, positions, collected_keys}
    initial_state = {starts, MapSet.new()}
    heap = Heap.new(fn {d1, _, _}, {d2, _, _} -> d1 < d2 end)
    heap = Heap.push(heap, {0, starts, MapSet.new()})

    search_loop(heap, all_keys, graph, keys, %{initial_state => 0})
  end

  defp search_loop(heap, all_keys, graph, keys, visited) do
    case Heap.root(heap) do
      nil ->
        :no_solution

      {dist, positions, collected} ->
        heap = Heap.pop(heap)

        if MapSet.equal?(collected, all_keys) do
          dist
        else
          state = {positions, collected}

          if Map.get(visited, state, :infinity) < dist do
            # Already found a better path to this state
            search_loop(heap, all_keys, graph, keys, visited)
          else
            # Try moving each robot to each reachable key
            {new_heap, new_visited} =
              positions
              |> Enum.with_index()
              |> Enum.reduce({heap, visited}, fn {pos, idx}, {h, v} ->
                # Get reachable keys from this position
                reachable =
                  Map.get(graph, pos, %{})
                  |> Enum.filter(fn {dest, {_d, doors_needed}} ->
                    # Key not yet collected and all doors can be opened
                    key = Map.get(keys, dest)
                    key != nil and
                      not MapSet.member?(collected, key) and
                      MapSet.subset?(doors_needed, collected)
                  end)

                Enum.reduce(reachable, {h, v}, fn {dest, {d, _doors}}, {h2, v2} ->
                  new_dist = dist + d
                  new_key = Map.get(keys, dest)
                  new_collected = MapSet.put(collected, new_key)
                  new_positions = List.replace_at(positions, idx, dest)
                  new_state = {new_positions, new_collected}

                  if new_dist < Map.get(v2, new_state, :infinity) do
                    {Heap.push(h2, {new_dist, new_positions, new_collected}),
                     Map.put(v2, new_state, new_dist)}
                  else
                    {h2, v2}
                  end
                end)
              end)

            search_loop(new_heap, all_keys, graph, keys, new_visited)
          end
        end
    end
  end
end
