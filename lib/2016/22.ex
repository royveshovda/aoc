import AOC

aoc 2016, 22 do
  @moduledoc """
  https://adventofcode.com/2016/day/22
  """

  def p1(input) do
    nodes = parse(input)
    count_viable_pairs(nodes)
  end

  def p2(input) do
    nodes = parse(input)
    # Part 2: Move data from top-right to top-left
    # This is a sliding puzzle - find shortest path
    solve_grid(nodes)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.drop(2)  # Skip header lines
    |> Enum.map(fn line ->
      parts = String.split(line, ~r/\s+/, trim: true)
      [name, size, used, avail, _use_percent] = parts

      [[_, x, y]] = Regex.scan(~r/x(\d+)-y(\d+)/, name)

      %{
        pos: {String.to_integer(x), String.to_integer(y)},
        size: parse_size(size),
        used: parse_size(used),
        avail: parse_size(avail)
      }
    end)
  end

  defp parse_size(str) do
    str |> String.replace("T", "") |> String.to_integer()
  end

  defp count_viable_pairs(nodes) do
    for a <- nodes, b <- nodes,
        a.pos != b.pos,
        a.used > 0,
        a.used <= b.avail do
      {a, b}
    end
    |> length()
  end

  defp solve_grid(nodes) do
    # This is a sliding puzzle problem
    # We need to move the data from top-right (max_x, 0) to (0, 0)
    # State: {empty_pos, goal_pos}

    max_x = nodes |> Enum.map(& elem(&1.pos, 0)) |> Enum.max()

    # Find the empty node
    empty = Enum.find(nodes, &(&1.used == 0))
    empty_pos = empty.pos

    # Goal data starts at top-right
    goal_pos = {max_x, 0}

    # Find walls (nodes with capacity > 100T are unmovable)
    nodes_by_pos = Map.new(nodes, &{&1.pos, &1})
    walls = nodes
           |> Enum.filter(&(&1.size > 100))
           |> MapSet.new(&(&1.pos))

    # BFS to find shortest path
    initial_state = {empty_pos, goal_pos}
    queue = :queue.from_list([{initial_state, 0}])
    visited = MapSet.new([initial_state])

    bfs_solve(queue, visited, nodes_by_pos, walls)
  end

  defp bfs_solve(queue, visited, nodes_by_pos, walls) do
    case :queue.out(queue) do
      {{:value, {{empty_pos, goal_pos}, steps}}, queue} ->
        # Check if goal reached target
        if goal_pos == {0, 0} do
          steps
        else
          # Generate next states
          neighbors = get_neighbors_pos(empty_pos)
                     |> Enum.filter(&Map.has_key?(nodes_by_pos, &1))
                     |> Enum.reject(&MapSet.member?(walls, &1))

          new_states = Enum.map(neighbors, fn new_empty ->
            # If we move empty to where goal is, goal moves to old empty position
            new_goal = if new_empty == goal_pos, do: empty_pos, else: goal_pos
            {new_empty, new_goal}
          end)

          # Filter unvisited states
          unvisited = Enum.reject(new_states, &MapSet.member?(visited, &1))

          # Add to queue and visited
          new_queue = Enum.reduce(unvisited, queue, fn state, q ->
            :queue.in({state, steps + 1}, q)
          end)
          new_visited = Enum.reduce(unvisited, visited, &MapSet.put(&2, &1))

          bfs_solve(new_queue, new_visited, nodes_by_pos, walls)
        end
      {:empty, _} -> nil
    end
  end

  defp get_neighbors_pos({x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
  end
end
