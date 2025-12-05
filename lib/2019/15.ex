import AOC

aoc 2019, 15 do
  @moduledoc """
  https://adventofcode.com/2019/day/15
  Oxygen System - maze exploration with Intcode droid
  """

  # Directions: north=1, south=2, west=3, east=4
  @directions %{
    1 => {0, -1},   # north
    2 => {0, 1},    # south
    3 => {-1, 0},   # west
    4 => {1, 0}     # east
  }
  @reverse %{1 => 2, 2 => 1, 3 => 4, 4 => 3}

  def p1(input) do
    mem = parse(input)
    {grid, oxygen_pos} = explore_map(mem)

    # BFS from origin to oxygen
    bfs_distance(grid, {0, 0}, oxygen_pos)
  end

  def p2(input) do
    mem = parse(input)
    {grid, oxygen_pos} = explore_map(mem)

    # BFS from oxygen to fill entire area
    fill_time(grid, oxygen_pos)
  end

  # Explore entire map using DFS with backtracking
  defp explore_map(mem) do
    vm = %{mem: mem, ip: 0, rb: 0}
    grid = %{{0, 0} => :open}

    {grid, _vm, oxygen_pos} = explore(vm, {0, 0}, grid, nil)
    {grid, oxygen_pos}
  end

  defp explore(vm, pos, grid, oxygen_pos) do
    # Try all 4 directions
    Enum.reduce([1, 2, 3, 4], {grid, vm, oxygen_pos}, fn dir, {g, v, oxy} ->
      {dx, dy} = @directions[dir]
      {x, y} = pos
      new_pos = {x + dx, y + dy}

      if Map.has_key?(g, new_pos) do
        # Already explored
        {g, v, oxy}
      else
        # Send movement command
        {v2, status} = step(v, dir)

        case status do
          0 ->
            # Hit wall - didn't move
            {Map.put(g, new_pos, :wall), v2, oxy}

          1 ->
            # Moved to open space
            g2 = Map.put(g, new_pos, :open)
            {g3, v3, oxy2} = explore(v2, new_pos, g2, oxy)
            # Backtrack
            {v4, _} = step(v3, @reverse[dir])
            {g3, v4, oxy2}

          2 ->
            # Found oxygen system
            g2 = Map.put(g, new_pos, :open)
            {g3, v3, _} = explore(v2, new_pos, g2, new_pos)
            # Backtrack
            {v4, _} = step(v3, @reverse[dir])
            {g3, v4, new_pos}
        end
      end
    end)
  end

  # Run VM with one input, get one output
  defp step(vm, input) do
    case run_until_output(vm.mem, vm.ip, vm.rb, [input]) do
      {:output, mem, ip, rb, output} ->
        {%{mem: mem, ip: ip, rb: rb}, output}
    end
  end

  # BFS from start to target
  defp bfs_distance(grid, start, target) do
    queue = :queue.from_list([{start, 0}])
    visited = MapSet.new([start])
    bfs_loop(queue, visited, grid, target)
  end

  defp bfs_loop(queue, visited, grid, target) do
    {{:value, {pos, dist}}, queue} = :queue.out(queue)

    if pos == target do
      dist
    else
      neighbors = get_neighbors(pos, grid, visited)
      new_visited = Enum.reduce(neighbors, visited, &MapSet.put(&2, &1))
      new_queue = Enum.reduce(neighbors, queue, fn n, q -> :queue.in({n, dist + 1}, q) end)
      bfs_loop(new_queue, new_visited, grid, target)
    end
  end

  # Find time to fill entire area from oxygen location
  defp fill_time(grid, oxygen_pos) do
    queue = :queue.from_list([{oxygen_pos, 0}])
    visited = MapSet.new([oxygen_pos])
    fill_loop(queue, visited, grid, 0)
  end

  defp fill_loop(queue, visited, grid, max_time) do
    case :queue.out(queue) do
      {:empty, _} ->
        max_time

      {{:value, {pos, time}}, queue} ->
        neighbors = get_neighbors(pos, grid, visited)
        new_visited = Enum.reduce(neighbors, visited, &MapSet.put(&2, &1))
        new_queue = Enum.reduce(neighbors, queue, fn n, q -> :queue.in({n, time + 1}, q) end)
        new_max = if neighbors != [], do: time + 1, else: max_time
        fill_loop(new_queue, new_visited, grid, max(max_time, new_max))
    end
  end

  defp get_neighbors({x, y}, grid, visited) do
    [{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]
    |> Enum.filter(fn pos ->
      Map.get(grid, pos) == :open and not MapSet.member?(visited, pos)
    end)
  end

  # Intcode VM with relative base support
  defp run_until_output(mem, ip, rb, inputs) do
    instruction = Map.get(mem, ip, 0)
    opcode = rem(instruction, 100)

    case opcode do
      1 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        run_until_output(Map.put(mem, c, a + b), ip + 4, rb, inputs)

      2 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        run_until_output(Map.put(mem, c, a * b), ip + 4, rb, inputs)

      3 ->
        [input | rest] = inputs
        addr = get_addr(mem, ip, rb, 1)
        run_until_output(Map.put(mem, addr, input), ip + 2, rb, rest)

      4 ->
        output = get_param(mem, ip, rb, 1)
        {:output, mem, ip + 2, rb, output}

      5 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        new_ip = if a != 0, do: b, else: ip + 3
        run_until_output(mem, new_ip, rb, inputs)

      6 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        new_ip = if a == 0, do: b, else: ip + 3
        run_until_output(mem, new_ip, rb, inputs)

      7 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        val = if a < b, do: 1, else: 0
        run_until_output(Map.put(mem, c, val), ip + 4, rb, inputs)

      8 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        val = if a == b, do: 1, else: 0
        run_until_output(Map.put(mem, c, val), ip + 4, rb, inputs)

      9 ->
        val = get_param(mem, ip, rb, 1)
        run_until_output(mem, ip + 2, rb + val, inputs)

      99 ->
        {:halt, mem, ip, rb}
    end
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new(fn {v, i} -> {i, v} end)
  end

  defp get_mode(mem, ip, offset) do
    instruction = Map.get(mem, ip, 0)
    div(instruction, round(:math.pow(10, offset + 1))) |> rem(10)
  end

  defp get_param(mem, ip, rb, offset) do
    mode = get_mode(mem, ip, offset)
    param = Map.get(mem, ip + offset, 0)

    case mode do
      0 -> Map.get(mem, param, 0)
      1 -> param
      2 -> Map.get(mem, rb + param, 0)
    end
  end

  defp get_addr(mem, ip, rb, offset) do
    mode = get_mode(mem, ip, offset)
    param = Map.get(mem, ip + offset, 0)

    case mode do
      0 -> param
      2 -> rb + param
    end
  end
end
