import AOC

aoc 2019, 20 do
  @moduledoc """
  https://adventofcode.com/2019/day/20

  Donut Maze - maze with portals that teleport you.
  Part 1: Find shortest path AA to ZZ using portals.
  Part 2: Recursive maze - outer portals go up a level, inner go down.
  """

  @doc """
  Part 1: Simple BFS with portal teleportation.

      iex> p1(example_string(0))
      23

      iex> p1(example_string(1))
      58
  """
  def p1(input) do
    {grid, portals, start, goal} = parse(input)
    bfs_simple(grid, portals, start, goal)
  end

  @doc """
  Part 2: Recursive maze - depth changes when using portals.
  Outer portals decrease depth (go up), inner increase (go down).
  Can only use AA/ZZ at depth 0.
  """
  def p2(input) do
    {grid, portals, start, goal, outer_positions} = parse_with_outer(input)
    bfs_recursive(grid, portals, start, goal, outer_positions)
  end

  # Parse the maze, find portals, start (AA) and goal (ZZ)
  defp parse(input) do
    lines = String.split(input, "\n")
    max_y = length(lines) - 1
    max_x = lines |> Enum.map(&String.length/1) |> Enum.max() |> Kernel.-(1)

    # Build grid as map of {x, y} => char
    grid =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {char, x} -> {{x, y}, char} end)
      end)
      |> Map.new()

    # Find all portals
    {portals, start, goal} = find_portals(grid, max_x, max_y)

    {grid, portals, start, goal}
  end

  defp parse_with_outer(input) do
    lines = String.split(input, "\n")
    max_y = length(lines) - 1
    max_x = lines |> Enum.map(&String.length/1) |> Enum.max() |> Kernel.-(1)

    grid =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {char, x} -> {{x, y}, char} end)
      end)
      |> Map.new()

    {portals, start, goal, outer_positions} = find_portals_with_outer(grid, max_x, max_y)

    {grid, portals, start, goal, outer_positions}
  end

  # Find all portal positions and their connections
  defp find_portals(grid, max_x, max_y) do
    # Find all 2-letter labels and their adjacent passage positions
    labels = find_labels(grid, max_x, max_y)

    # Group by label name
    by_name =
      labels
      |> Enum.group_by(fn {name, _pos} -> name end, fn {_name, pos} -> pos end)

    # Build portal map: position -> destination position
    portals =
      by_name
      |> Enum.filter(fn {_name, positions} -> length(positions) == 2 end)
      |> Enum.flat_map(fn {_name, [p1, p2]} ->
        [{p1, p2}, {p2, p1}]
      end)
      |> Map.new()

    start = by_name |> Map.get("AA") |> List.first()
    goal = by_name |> Map.get("ZZ") |> List.first()

    {portals, start, goal}
  end

  defp find_portals_with_outer(grid, max_x, max_y) do
    labels = find_labels_with_outer(grid, max_x, max_y)

    by_name =
      labels
      |> Enum.group_by(fn {name, _pos, _outer} -> name end, fn {_name, pos, outer} -> {pos, outer} end)

    portals =
      by_name
      |> Enum.filter(fn {_name, positions} -> length(positions) == 2 end)
      |> Enum.flat_map(fn {_name, [{p1, _}, {p2, _}]} ->
        [{p1, p2}, {p2, p1}]
      end)
      |> Map.new()

    outer_positions =
      labels
      |> Enum.filter(fn {_name, _pos, outer} -> outer end)
      |> Enum.map(fn {_name, pos, _outer} -> pos end)
      |> MapSet.new()

    start = by_name |> Map.get("AA") |> List.first() |> elem(0)
    goal = by_name |> Map.get("ZZ") |> List.first() |> elem(0)

    {portals, start, goal, outer_positions}
  end

  # Find all labels (2-letter sequences adjacent to passages)
  defp find_labels(grid, max_x, max_y) do
    for y <- 0..max_y,
        x <- 0..max_x,
        is_letter?(Map.get(grid, {x, y})),
        {name, passage_pos} <- get_label_info(grid, {x, y}),
        name != nil do
      {name, passage_pos}
    end
    |> Enum.uniq()
  end

  defp find_labels_with_outer(grid, max_x, max_y) do
    # Find bounds of the actual maze (where # and . are)
    maze_positions =
      grid
      |> Enum.filter(fn {_pos, char} -> char == "#" or char == "." end)
      |> Enum.map(fn {pos, _} -> pos end)

    {min_maze_x, max_maze_x} =
      maze_positions |> Enum.map(fn {x, _} -> x end) |> Enum.min_max()

    {min_maze_y, max_maze_y} =
      maze_positions |> Enum.map(fn {_, y} -> y end) |> Enum.min_max()

    for y <- 0..max_y,
        x <- 0..max_x,
        is_letter?(Map.get(grid, {x, y})),
        {name, passage_pos} <- get_label_info(grid, {x, y}),
        name != nil do
      {px, py} = passage_pos
      # Outer if on the edge of the maze
      outer =
        px == min_maze_x or px == max_maze_x or py == min_maze_y or py == max_maze_y

      {name, passage_pos, outer}
    end
    |> Enum.uniq_by(fn {name, pos, _} -> {name, pos} end)
  end

  defp is_letter?(nil), do: false
  defp is_letter?(char), do: char >= "A" and char <= "Z"

  # Get label name and passage position for a letter at {x, y}
  defp get_label_info(grid, {x, y}) do
    char = Map.get(grid, {x, y})

    # Check horizontal: this + right
    right = Map.get(grid, {x + 1, y})

    if is_letter?(right) do
      name = char <> right
      # Passage is either to the left of first letter or right of second
      left_of_first = Map.get(grid, {x - 1, y})
      right_of_second = Map.get(grid, {x + 2, y})

      cond do
        left_of_first == "." -> [{name, {x - 1, y}}]
        right_of_second == "." -> [{name, {x + 2, y}}]
        true -> []
      end
    else
      # Check vertical: this + below
      below = Map.get(grid, {x, y + 1})

      if is_letter?(below) do
        name = char <> below
        above_first = Map.get(grid, {x, y - 1})
        below_second = Map.get(grid, {x, y + 2})

        cond do
          above_first == "." -> [{name, {x, y - 1}}]
          below_second == "." -> [{name, {x, y + 2}}]
          true -> []
        end
      else
        []
      end
    end
  end

  # Simple BFS for Part 1
  defp bfs_simple(grid, portals, start, goal) do
    queue = :queue.from_list([{start, 0}])
    visited = MapSet.new([start])
    bfs_simple_loop(queue, visited, grid, portals, goal)
  end

  defp bfs_simple_loop(queue, visited, grid, portals, goal) do
    case :queue.out(queue) do
      {:empty, _} ->
        nil

      {{:value, {pos, dist}}, rest} ->
        if pos == goal do
          dist
        else
          # Get neighbors: adjacent passages + portal destination
          neighbors = get_neighbors_simple(pos, grid, portals)

          {new_queue, new_visited} =
            neighbors
            |> Enum.reject(&MapSet.member?(visited, &1))
            |> Enum.reduce({rest, visited}, fn n, {q, v} ->
              {:queue.in({n, dist + 1}, q), MapSet.put(v, n)}
            end)

          bfs_simple_loop(new_queue, new_visited, grid, portals, goal)
        end
    end
  end

  defp get_neighbors_simple({x, y}, grid, portals) do
    # Adjacent cells
    adjacent =
      [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
      |> Enum.filter(fn p -> Map.get(grid, p) == "." end)

    # Portal destination (if any)
    case Map.get(portals, {x, y}) do
      nil -> adjacent
      dest -> [dest | adjacent]
    end
  end

  # BFS for Part 2 with recursive depth
  defp bfs_recursive(grid, portals, start, goal, outer_positions) do
    # State: {position, depth}
    queue = :queue.from_list([{{start, 0}, 0}])
    visited = MapSet.new([{start, 0}])
    bfs_recursive_loop(queue, visited, grid, portals, goal, outer_positions)
  end

  defp bfs_recursive_loop(queue, visited, grid, portals, goal, outer_positions) do
    case :queue.out(queue) do
      {:empty, _} ->
        nil

      {{:value, {{pos, depth}, dist}}, rest} ->
        if pos == goal and depth == 0 do
          dist
        else
          neighbors = get_neighbors_recursive(pos, depth, grid, portals, outer_positions)

          {new_queue, new_visited} =
            neighbors
            |> Enum.reject(fn {_, d} -> d < 0 end)  # Can't go above depth 0
            |> Enum.reject(&MapSet.member?(visited, &1))
            |> Enum.reduce({rest, visited}, fn state, {q, v} ->
              {:queue.in({state, dist + 1}, q), MapSet.put(v, state)}
            end)

          bfs_recursive_loop(new_queue, new_visited, grid, portals, goal, outer_positions)
        end
    end
  end

  defp get_neighbors_recursive({x, y}, depth, grid, portals, outer_positions) do
    # Adjacent cells (same depth)
    adjacent =
      [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
      |> Enum.filter(fn p -> Map.get(grid, p) == "." end)
      |> Enum.map(fn p -> {p, depth} end)

    # Portal: outer portals go up (depth - 1), inner go down (depth + 1)
    portal_neighbors =
      case Map.get(portals, {x, y}) do
        nil ->
          []

        dest ->
          is_outer = MapSet.member?(outer_positions, {x, y})

          if is_outer do
            # Outer portal goes up (can't use at depth 0 - handled by filter)
            [{dest, depth - 1}]
          else
            # Inner portal goes down
            [{dest, depth + 1}]
          end
      end

    adjacent ++ portal_neighbors
  end
end
