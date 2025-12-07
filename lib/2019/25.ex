import AOC

aoc 2019, 25 do
  @moduledoc """
  https://adventofcode.com/2019/day/25

  Day 25: Cryostasis - Text adventure using Intcode.
  Explore ship, collect items, find correct combination to pass security checkpoint.
  Part 2: Free star for completing all 49 other stars!
  """

  # Items that are dangerous and should NOT be picked up
  @dangerous_items MapSet.new(["molten lava", "giant electromagnet", "infinite loop", "escape pod", "photons"])

  @doc """
  Part 1: Play the text adventure to find the password.
  Automatically explores, collects safe items, and finds the correct combination.
  """
  def p1(input) do
    program = parse(input)
    vm = init_vm(program)
    {vm, initial_output} = run_vm(vm)

    # DFS to explore all rooms and collect items
    {vm, rooms, items, _visited} = explore_dfs(vm, initial_output, MapSet.new(), %{}, [])

    # Debug: show what we found
    # IO.inspect(Map.keys(rooms), label: "Rooms")
    # IO.inspect(items, label: "Items")

    # Find Security Checkpoint
    checkpoint_name = Enum.find(Map.keys(rooms), fn name ->
      String.contains?(name, "Security") or String.contains?(name, "Checkpoint")
    end)

    if checkpoint_name == nil do
      "Could not find Security Checkpoint. Rooms: #{inspect(Map.keys(rooms))}"
    else
      checkpoint_info = rooms[checkpoint_name]

      # Navigate to checkpoint
      # First figure out where we are - after DFS we're back at start
      path = find_path_to(rooms, "Hull Breach", checkpoint_name)
      vm = navigate(vm, path)

      # Find the direction to the pressure-sensitive floor (unexplored direction)
      pressure_dir = Enum.find(checkpoint_info.doors, fn dir ->
        not Map.has_key?(checkpoint_info.paths, dir)
      end)

      if pressure_dir == nil do
        "Could not find pressure floor direction"
      else
        # Try all combinations of items
        find_correct_weight(vm, items, pressure_dir)
      end
    end
  end

  def p2(_input) do
    "Merry Christmas! 🎄"
  end

  # Parse Intcode program
  defp parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new(fn {v, i} -> {i, v} end)
  end

  # Run VM with given input, return {new_vm, output_string}
  defp run_vm(vm, input_str \\ "") do
    input = input_str |> String.to_charlist()
    vm = %{vm | input: vm.input ++ input}
    vm = run_until_input_needed(vm)
    output = vm.output |> List.to_string()
    {%{vm | output: []}, output}
  end

  # Initialize VM
  defp init_vm(program) do
    %{
      mem: program,
      ip: 0,
      rb: 0,
      input: [],
      output: [],
      halted: false
    }
  end

  # Run until we need input or halted
  defp run_until_input_needed(vm) do
    if vm.halted do
      vm
    else
      opcode = rem(get_mem(vm, vm.ip), 100)

      cond do
        opcode == 99 ->
          %{vm | halted: true}

        opcode == 3 and vm.input == [] ->
          vm

        true ->
          run_until_input_needed(step(vm))
      end
    end
  end

  defp step(vm) do
    instruction = get_mem(vm, vm.ip)
    opcode = rem(instruction, 100)
    modes = div(instruction, 100)

    case opcode do
      1 -> # add
        a = get_param(vm, 1, modes)
        b = get_param(vm, 2, modes)
        addr = get_addr(vm, 3, modes)
        vm |> put_mem(addr, a + b) |> advance(4)

      2 -> # multiply
        a = get_param(vm, 1, modes)
        b = get_param(vm, 2, modes)
        addr = get_addr(vm, 3, modes)
        vm |> put_mem(addr, a * b) |> advance(4)

      3 -> # input
        [val | rest] = vm.input
        addr = get_addr(vm, 1, modes)
        vm |> Map.put(:input, rest) |> put_mem(addr, val) |> advance(2)

      4 -> # output
        val = get_param(vm, 1, modes)
        %{vm | output: vm.output ++ [val]} |> advance(2)

      5 -> # jump-if-true
        if get_param(vm, 1, modes) != 0 do
          %{vm | ip: get_param(vm, 2, modes)}
        else
          advance(vm, 3)
        end

      6 -> # jump-if-false
        if get_param(vm, 1, modes) == 0 do
          %{vm | ip: get_param(vm, 2, modes)}
        else
          advance(vm, 3)
        end

      7 -> # less than
        a = get_param(vm, 1, modes)
        b = get_param(vm, 2, modes)
        addr = get_addr(vm, 3, modes)
        val = if a < b, do: 1, else: 0
        vm |> put_mem(addr, val) |> advance(4)

      8 -> # equals
        a = get_param(vm, 1, modes)
        b = get_param(vm, 2, modes)
        addr = get_addr(vm, 3, modes)
        val = if a == b, do: 1, else: 0
        vm |> put_mem(addr, val) |> advance(4)

      9 -> # adjust relative base
        vm |> Map.update!(:rb, &(&1 + get_param(vm, 1, modes))) |> advance(2)
    end
  end

  defp get_mem(vm, addr), do: Map.get(vm.mem, addr, 0)
  defp put_mem(vm, addr, val), do: %{vm | mem: Map.put(vm.mem, addr, val)}
  defp advance(vm, n), do: %{vm | ip: vm.ip + n}

  defp get_param(vm, offset, modes) do
    mode = modes |> div(pow10(offset - 1)) |> rem(10)
    val = get_mem(vm, vm.ip + offset)
    case mode do
      0 -> get_mem(vm, val)
      1 -> val
      2 -> get_mem(vm, vm.rb + val)
    end
  end

  defp get_addr(vm, offset, modes) do
    mode = modes |> div(pow10(offset - 1)) |> rem(10)
    val = get_mem(vm, vm.ip + offset)
    case mode do
      0 -> val
      2 -> vm.rb + val
    end
  end

  defp pow10(0), do: 1
  defp pow10(n), do: 10 * pow10(n - 1)

  # Parse room output
  defp parse_room(output) do
    name = case Regex.run(~r/== (.+) ==/, output) do
      [_, n] -> n
      _ -> nil
    end

    doors = case Regex.run(~r/Doors here lead:\n((?:- \w+\n?)+)/, output) do
      [_, d] -> d |> String.split("\n", trim: true) |> Enum.map(&String.trim_leading(&1, "- "))
      _ -> []
    end

    items = case Regex.run(~r/Items here:\n((?:- [^\n]+\n?)+)/, output) do
      [_, i] -> i |> String.split("\n", trim: true) |> Enum.map(&String.trim_leading(&1, "- "))
      _ -> []
    end

    %{name: name, doors: doors, items: items}
  end

  # DFS exploration - returns {vm at last position, rooms map, collected items}
  defp explore_dfs(vm, current_output, visited, rooms, items) do
    room = parse_room(current_output)

    if room.name == nil or MapSet.member?(visited, room.name) do
      {vm, rooms, items}
    else
      visited = MapSet.put(visited, room.name)

      # Collect safe items
      {vm, new_items} = collect_safe_items(vm, room.items)
      items = items ++ new_items

      # Add room to map
      rooms = Map.put(rooms, room.name, %{doors: room.doors, paths: %{}})

      # Explore each direction
      {vm, rooms, items, visited} = Enum.reduce(room.doors, {vm, rooms, items, visited}, fn dir, {v, rs, its, vis} ->
        {new_vm, new_output} = run_vm(v, dir <> "\n")

        cond do
          String.contains?(new_output, "ejected back") ->
            # Checkpoint - can't pass yet, but record direction
            {v, rs, its, vis}

          String.contains?(new_output, "You can't go that way") ->
            {v, rs, its, vis}

          true ->
            new_room = parse_room(new_output)

            if new_room.name && not MapSet.member?(vis, new_room.name) do
              # Record path
              rs = put_in(rs, [room.name, :paths, dir], new_room.name)

              # Recursively explore
              {explored_vm, rs, its, vis} = explore_dfs(new_vm, new_output, vis, rs, its)

              # Go back
              {back_vm, _} = run_vm(explored_vm, opposite(dir) <> "\n")
              {back_vm, rs, its, vis}
            else
              # Already visited or couldn't parse, go back
              {back_vm, _} = run_vm(new_vm, opposite(dir) <> "\n")
              rs = if new_room.name, do: put_in(rs, [room.name, :paths, dir], new_room.name), else: rs
              {back_vm, rs, its, vis}
            end
        end
      end)

      {vm, rooms, items, visited}
    end
  end

  defp collect_safe_items(vm, room_items) do
    safe_items = Enum.reject(room_items, &MapSet.member?(@dangerous_items, &1))

    vm = Enum.reduce(safe_items, vm, fn item, v ->
      {new_v, _} = run_vm(v, "take #{item}\n")
      new_v
    end)

    {vm, safe_items}
  end

  defp opposite("north"), do: "south"
  defp opposite("south"), do: "north"
  defp opposite("east"), do: "west"
  defp opposite("west"), do: "east"

  # BFS to find path between rooms
  defp find_path_to(rooms, from, to) do
    if from == to do
      []
    else
      bfs_path(:queue.from_list([{from, []}]), rooms, to, MapSet.new([from]))
    end
  end

  defp bfs_path(queue, rooms, to, visited) do
    case :queue.out(queue) do
      {:empty, _} -> []
      {{:value, {current, path}}, queue} ->
        room = rooms[current]

        if room == nil do
          bfs_path(queue, rooms, to, visited)
        else
          # Check if any neighbor is target
          found = Enum.find(room.paths, fn {_dir, next} -> next == to end)

          if found do
            {dir, _} = found
            path ++ [dir]
          else
            # Add unvisited neighbors
            {queue, visited} = Enum.reduce(room.paths, {queue, visited}, fn {dir, next}, {q, vis} ->
              if MapSet.member?(vis, next) do
                {q, vis}
              else
                {:queue.in({next, path ++ [dir]}, q), MapSet.put(vis, next)}
              end
            end)

            bfs_path(queue, rooms, to, visited)
          end
        end
    end
  end

  # Navigate through a path
  defp navigate(vm, path) do
    Enum.reduce(path, vm, fn dir, v ->
      {new_v, _} = run_vm(v, dir <> "\n")
      new_v
    end)
  end

  # Try all combinations of items to find correct weight
  defp find_correct_weight(vm, items, direction) do
    # First, drop all items
    vm = Enum.reduce(items, vm, fn item, v ->
      {new_v, _} = run_vm(v, "drop #{item}\n")
      new_v
    end)

    # Try all 2^n combinations
    n = length(items)
    max_mask = trunc(:math.pow(2, n)) - 1

    Enum.find_value(0..max_mask, fn mask ->
      # Pick up items according to mask
      items_to_take = items
      |> Enum.with_index()
      |> Enum.filter(fn {_, i} -> Bitwise.band(mask, Bitwise.bsl(1, i)) != 0 end)
      |> Enum.map(&elem(&1, 0))

      vm_with_items = Enum.reduce(items_to_take, vm, fn item, v ->
        {new_v, _} = run_vm(v, "take #{item}\n")
        new_v
      end)

      # Try to pass the security checkpoint
      {_, output} = run_vm(vm_with_items, direction <> "\n")

      cond do
        String.contains?(output, "proceed") or String.contains?(output, "airlock") ->
          # Found password!
          extract_password(output)

        true ->
          nil
      end
    end)
  end

  defp extract_password(output) do
    case Regex.run(~r/(\d+)/, output) do
      [_, password] -> password
      _ -> "Could not find password"
    end
  end
end
