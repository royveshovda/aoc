import AOC

aoc 2018, 22 do
  @moduledoc """
  https://adventofcode.com/2018/day/22

  Day 22: Mode Maze - Cave system with geologic indices and risk levels
  """

  @doc """
  Part 1: Calculate total risk level for rectangle from 0,0 to target

  ## Examples

      iex> p1("depth: 510\\ntarget: 10,10")
      114
  """
  def p1(input) do
    {depth, target} = parse_input(input)
    {tx, ty} = target

    # Build erosion levels for the rectangle
    erosion_map = build_erosion_map(depth, target)

    # Calculate risk level (sum of types in rectangle)
    for x <- 0..tx, y <- 0..ty do
      erosion = Map.get(erosion_map, {x, y})
      rem(erosion, 3)
    end
    |> Enum.sum()
  end

  def p2(input) do
    {depth, target} = parse_input(input)

    # Build erosion map - need extra space beyond target for pathfinding
    {tx, ty} = target
    erosion_map = build_extended_erosion_map(depth, target, tx + 100, ty + 100)

    # Find shortest path using Dijkstra with state = {position, tool}
    # Tools: :torch, :climbing_gear, :neither
    # Start: {0, 0} with :torch
    # End: target with :torch
    find_shortest_path(erosion_map, target)
  end

  defp parse_input(input) do
    [depth_line, target_line] = String.split(input, "\n", trim: true)

    "depth: " <> depth_str = depth_line
    depth = String.to_integer(depth_str)

    "target: " <> target_str = target_line
    [x, y] = String.split(target_str, ",") |> Enum.map(&String.to_integer/1)

    {depth, {x, y}}
  end

  # Build erosion level map for all positions up to and including target
  defp build_erosion_map(depth, {tx, ty}) do
    # We need to compute in order since each cell depends on previous cells
    for y <- 0..ty, x <- 0..tx, reduce: %{} do
      acc ->
        geologic_index = calc_geologic_index({x, y}, {tx, ty}, acc)
        erosion_level = rem(geologic_index + depth, 20183)
        Map.put(acc, {x, y}, erosion_level)
    end
  end

  # Build extended map for pathfinding (need space beyond target)
  defp build_extended_erosion_map(depth, target, max_x, max_y) do
    {tx, ty} = target
    for y <- 0..max_y, x <- 0..max_x, reduce: %{} do
      acc ->
        geologic_index = calc_geologic_index({x, y}, {tx, ty}, acc)
        erosion_level = rem(geologic_index + depth, 20183)
        Map.put(acc, {x, y}, erosion_level)
    end
  end

  # Calculate geologic index based on position
  defp calc_geologic_index({0, 0}, _target, _map), do: 0
  defp calc_geologic_index(pos, target, _map) when pos == target, do: 0
  defp calc_geologic_index({x, 0}, _target, _map), do: x * 16807
  defp calc_geologic_index({0, y}, _target, _map), do: y * 48271
  defp calc_geologic_index({x, y}, _target, map) do
    erosion_left = Map.get(map, {x - 1, y})
    erosion_above = Map.get(map, {x, y - 1})
    erosion_left * erosion_above
  end

  # Get region type from erosion level
  defp region_type(erosion), do: rem(erosion, 3)

  # Get valid tools for a region type
  # 0 (rocky): climbing_gear, torch
  # 1 (wet): climbing_gear, neither
  # 2 (narrow): torch, neither
  defp valid_tools(0), do: [:climbing_gear, :torch]
  defp valid_tools(1), do: [:climbing_gear, :neither]
  defp valid_tools(2), do: [:torch, :neither]

  # Dijkstra's algorithm to find shortest path
  defp find_shortest_path(erosion_map, target) do
    start_state = {{0, 0}, :torch}
    end_state = {target, :torch}

    # Priority queue: {cost, state}
    pq = Heap.new() |> Heap.push({0, start_state})
    distances = %{start_state => 0}

    dijkstra(pq, distances, erosion_map, end_state)
  end

  defp dijkstra(pq, distances, erosion_map, target_state) do
    if Heap.empty?(pq) do
      # No path found
      nil
    else
      {cost, state} = Heap.root(pq)
      rest_pq = Heap.pop(pq)

      if state == target_state do
        # Reached target
        cost
      else
        # Skip if we've already found a better path to this state
        if cost > Map.get(distances, state, :infinity) do
          dijkstra(rest_pq, distances, erosion_map, target_state)
        else
          # Explore neighbors
          {new_pq, new_distances} = explore_neighbors(state, cost, rest_pq, distances, erosion_map)
          dijkstra(new_pq, new_distances, erosion_map, target_state)
        end
      end
    end
  end

  defp explore_neighbors({pos, tool}, cost, pq, distances, erosion_map) do
    {x, y} = pos

    # Get current region type
    current_erosion = Map.get(erosion_map, pos)
    current_type = region_type(current_erosion)

    # Option 1: Switch tool (cost +7)
    other_tools = valid_tools(current_type) -- [tool]

    switch_states = for new_tool <- other_tools do
      {{pos, new_tool}, cost + 7}
    end

    # Option 2: Move to adjacent region (cost +1) if tool is valid there
    adjacent = [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]

    move_states = for new_pos <- adjacent,
                      Map.has_key?(erosion_map, new_pos),
                      {nx, ny} = new_pos,
                      nx >= 0 and ny >= 0 do
      new_erosion = Map.get(erosion_map, new_pos)
      new_type = region_type(new_erosion)

      if tool in valid_tools(new_type) do
        {{new_pos, tool}, cost + 1}
      else
        nil
      end
    end
    |> Enum.reject(&is_nil/1)

    # Update priority queue and distances
    all_neighbors = switch_states ++ move_states

    Enum.reduce(all_neighbors, {pq, distances}, fn {next_state, next_cost}, {acc_pq, acc_dist} ->
      current_best = Map.get(acc_dist, next_state, :infinity)

      if next_cost < current_best do
        {
          Heap.push(acc_pq, {next_cost, next_state}),
          Map.put(acc_dist, next_state, next_cost)
        }
      else
        {acc_pq, acc_dist}
      end
    end)
  end
end
