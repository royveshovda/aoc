import AOC

aoc 2019, 17 do
  @moduledoc """
  https://adventofcode.com/2019/day/17
  Set and Forget - scaffold robot with ASCII Intcode
  """

  def p1(input) do
    mem = parse(input)
    {_mem, outputs} = run_intcode(mem, [])

    # Convert output to grid
    grid = build_grid(outputs)

    # Find intersections (scaffold with 4 scaffold neighbors)
    grid
    |> find_intersections()
    |> Enum.map(fn {x, y} -> x * y end)
    |> Enum.sum()
  end

  def p2(input) do
    mem = parse(input)

    # First get the map to determine the path
    {_mem, outputs} = run_intcode(mem, [])
    grid = build_grid(outputs)

    # Find the path as sequence of moves
    path = find_path(grid)

    # Compress path into main routine + functions A, B, C
    {main, a, b, c} = compress_path(path)

    # Wake up the robot by setting mem[0] = 2
    mem = Map.put(mem, 0, 2)

    # Convert commands to ASCII input
    input_chars =
      [main, a, b, c, "n"]
      |> Enum.map(&String.to_charlist/1)
      |> Enum.intersperse([?\n])
      |> List.flatten()
      |> Kernel.++([?\n])

    # Run with inputs
    {_mem, outputs} = run_intcode(mem, input_chars)

    # Last output is the dust collected
    List.last(outputs)
  end

  defp build_grid(outputs) do
    outputs
    |> Enum.map(&<<&1::utf8>>)
    |> Enum.join()
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, char} end)
    end)
    |> Map.new()
  end

  defp find_intersections(grid) do
    grid
    |> Enum.filter(fn {{x, y}, char} ->
      is_scaffold?(char) and
        is_scaffold?(Map.get(grid, {x-1, y})) and
        is_scaffold?(Map.get(grid, {x+1, y})) and
        is_scaffold?(Map.get(grid, {x, y-1})) and
        is_scaffold?(Map.get(grid, {x, y+1}))
    end)
    |> Enum.map(fn {pos, _} -> pos end)
  end

  defp is_scaffold?(char), do: char in ["#", "^", "v", "<", ">"]

  defp find_path(grid) do
    # Find robot position and direction
    {robot_pos, robot_char} = Enum.find(grid, fn {_pos, char} -> char in ["^", "v", "<", ">"] end)
    robot_dir = char_to_dir(robot_char)

    # Follow the scaffold, recording turns and distances
    follow_scaffold(grid, robot_pos, robot_dir, [])
    |> Enum.reverse()
    |> Enum.join(",")
  end

  defp char_to_dir("^"), do: {0, -1}
  defp char_to_dir("v"), do: {0, 1}
  defp char_to_dir("<"), do: {-1, 0}
  defp char_to_dir(">"), do: {1, 0}

  defp follow_scaffold(grid, {x, y}, {dx, dy}, path) do
    # Try to go forward
    forward_pos = {x + dx, y + dy}

    if is_scaffold?(Map.get(grid, forward_pos)) do
      # Count how far we can go straight
      {end_pos, count} = go_straight(grid, {x, y}, {dx, dy}, 0)
      follow_scaffold(grid, end_pos, {dx, dy}, [Integer.to_string(count) | path])
    else
      # Need to turn - check left and right
      left_dir = turn_left({dx, dy})
      right_dir = turn_right({dx, dy})
      {lx, ly} = left_dir
      {rx, ry} = right_dir
      left_pos = {x + lx, y + ly}
      right_pos = {x + rx, y + ry}

      cond do
        is_scaffold?(Map.get(grid, left_pos)) ->
          follow_scaffold(grid, {x, y}, left_dir, ["L" | path])
        is_scaffold?(Map.get(grid, right_pos)) ->
          follow_scaffold(grid, {x, y}, right_dir, ["R" | path])
        true ->
          # End of path
          path
      end
    end
  end

  defp go_straight(grid, {x, y}, {dx, dy}, count) do
    next_pos = {x + dx, y + dy}
    if is_scaffold?(Map.get(grid, next_pos)) do
      go_straight(grid, next_pos, {dx, dy}, count + 1)
    else
      {{x, y}, count}
    end
  end

  defp turn_left({0, -1}), do: {-1, 0}   # up -> left
  defp turn_left({-1, 0}), do: {0, 1}    # left -> down
  defp turn_left({0, 1}), do: {1, 0}     # down -> right
  defp turn_left({1, 0}), do: {0, -1}    # right -> up

  defp turn_right({0, -1}), do: {1, 0}   # up -> right
  defp turn_right({1, 0}), do: {0, 1}    # right -> down
  defp turn_right({0, 1}), do: {-1, 0}   # down -> left
  defp turn_right({-1, 0}), do: {0, -1}  # left -> up

  defp compress_path(path) do
    # Try all possible function lengths to find a valid compression
    segments = String.split(path, ",")

    # Try to find A, B, C that compress the path
    find_compression(segments)
  end

  defp find_compression(segments) do
    # Try different lengths for A
    for a_len <- 2..10,
        a_start = Enum.take(segments, a_len),
        a_str = Enum.join(a_start, ","),
        String.length(a_str) <= 20,
        # Remove all A occurrences and try B
        remaining_after_a = remove_prefix_occurrences(segments, a_start),
        remaining_after_a != nil,
        b_len <- 2..10,
        b_start = Enum.take(remaining_after_a, b_len),
        b_str = Enum.join(b_start, ","),
        String.length(b_str) <= 20,
        # Remove all B occurrences and try C
        remaining_after_b = remove_all_occurrences(remaining_after_a, a_start, b_start),
        remaining_after_b != nil,
        c_len <- 2..10,
        c_start = Enum.take(remaining_after_b, c_len),
        c_str = Enum.join(c_start, ","),
        String.length(c_str) <= 20,
        # Check if A, B, C cover everything
        main = build_main(segments, a_start, b_start, c_start),
        main != nil,
        String.length(main) <= 20 do
      {main, a_str, b_str, c_str}
    end
    |> List.first()
  end

  defp remove_prefix_occurrences(segments, pattern) do
    if starts_with?(segments, pattern) do
      remaining = Enum.drop(segments, length(pattern))
      if remaining == [] do
        []
      else
        case remove_prefix_occurrences(remaining, pattern) do
          nil -> remaining
          result -> result
        end
      end
    else
      if segments == [], do: [], else: segments
    end
  end

  defp remove_all_occurrences(segments, a, b) do
    cond do
      segments == [] -> []
      starts_with?(segments, a) -> remove_all_occurrences(Enum.drop(segments, length(a)), a, b)
      starts_with?(segments, b) -> remove_all_occurrences(Enum.drop(segments, length(b)), a, b)
      true -> segments
    end
  end

  defp starts_with?(list, prefix) do
    Enum.take(list, length(prefix)) == prefix
  end

  defp build_main(segments, a, b, c) do
    build_main_helper(segments, a, b, c, [])
  end

  defp build_main_helper([], _a, _b, _c, acc), do: acc |> Enum.reverse() |> Enum.join(",")
  defp build_main_helper(segments, a, b, c, acc) do
    cond do
      starts_with?(segments, a) ->
        build_main_helper(Enum.drop(segments, length(a)), a, b, c, ["A" | acc])
      starts_with?(segments, b) ->
        build_main_helper(Enum.drop(segments, length(b)), a, b, c, ["B" | acc])
      starts_with?(segments, c) ->
        build_main_helper(Enum.drop(segments, length(c)), a, b, c, ["C" | acc])
      true ->
        nil
    end
  end

  # Intcode VM
  defp parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new(fn {v, i} -> {i, v} end)
  end

  defp run_intcode(mem, inputs), do: run_intcode(mem, 0, 0, inputs, [])

  defp run_intcode(mem, ip, rb, inputs, outputs) do
    instruction = Map.get(mem, ip, 0)
    opcode = rem(instruction, 100)

    case opcode do
      1 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        run_intcode(Map.put(mem, c, a + b), ip + 4, rb, inputs, outputs)

      2 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        run_intcode(Map.put(mem, c, a * b), ip + 4, rb, inputs, outputs)

      3 ->
        case inputs do
          [input | rest] ->
            addr = get_addr(mem, ip, rb, 1)
            run_intcode(Map.put(mem, addr, input), ip + 2, rb, rest, outputs)
          [] ->
            {:need_input, mem, ip, rb, outputs}
        end

      4 ->
        val = get_param(mem, ip, rb, 1)
        run_intcode(mem, ip + 2, rb, inputs, outputs ++ [val])

      5 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        new_ip = if a != 0, do: b, else: ip + 3
        run_intcode(mem, new_ip, rb, inputs, outputs)

      6 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        new_ip = if a == 0, do: b, else: ip + 3
        run_intcode(mem, new_ip, rb, inputs, outputs)

      7 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        val = if a < b, do: 1, else: 0
        run_intcode(Map.put(mem, c, val), ip + 4, rb, inputs, outputs)

      8 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        val = if a == b, do: 1, else: 0
        run_intcode(Map.put(mem, c, val), ip + 4, rb, inputs, outputs)

      9 ->
        val = get_param(mem, ip, rb, 1)
        run_intcode(mem, ip + 2, rb + val, inputs, outputs)

      99 ->
        {mem, outputs}
    end
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
