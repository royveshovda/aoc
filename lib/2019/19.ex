import AOC

aoc 2019, 19 do
  @moduledoc """
  https://adventofcode.com/2019/day/19
  Tractor Beam - scan grid to find beam pattern
  """

  def p1(input) do
    mem = parse(input)

    # Scan 50x50 grid
    for x <- 0..49, y <- 0..49, reduce: 0 do
      acc -> acc + check_point(mem, x, y)
    end
  end

  def p2(input) do
    mem = parse(input)

    # For a 100x100 square to fit, we need:
    # - Top-left (x, y) in beam
    # - Top-right (x+99, y) in beam
    # - Bottom-left (x, y+99) in beam
    #
    # The beam is a cone starting from origin. We track the leftmost x in beam
    # for each row. When the leftmost x at row y can have x+99 still in beam at row y,
    # AND x is still in beam at row y+99, we found it.
    #
    # Key insight: track left edge of beam as we go down. The left edge at y+99
    # determines if bottom-left is valid. The width at row y determines if top-right is valid.

    # Start simple: iterate rows, tracking x position
    search_rows(mem, 10, 0)
  end

  defp search_rows(mem, y, prev_x) do
    # Find leftmost x in beam at row y (start from prev_x since beam moves right)
    x = find_left_edge(mem, prev_x, y)

    # Find rightmost x in beam at row y (start from x)
    right = find_right_edge(mem, x, y)

    # Width of beam at this row
    width = right - x + 1

    if width >= 100 do
      # Beam is wide enough. Check if bottom-left (x, y+99) is in beam.
      # First find left edge at y+99
      left_at_bottom = find_left_edge(mem, 0, y + 99)

      # For square to fit: x >= left_at_bottom (top-left must be at or right of bottom-left-edge)
      # But we want the leftmost valid position, which is left_at_bottom
      # And we need x + 99 <= right (top-right must be in beam at row y)

      # Actually, the constraint is:
      # - We place top-left at x
      # - Bottom-left is (x, y+99), must be in beam: x >= left_at_bottom
      # - Top-right is (x+99, y), must be in beam: x+99 <= right

      if left_at_bottom + 99 <= right do
        # A square fits! The top-left is at (left_at_bottom, y)
        left_at_bottom * 10000 + y
      else
        search_rows(mem, y + 1, x)
      end
    else
      search_rows(mem, y + 1, x)
    end
  end

  defp find_left_edge(mem, start_x, y) do
    if check_point(mem, start_x, y) == 1 do
      start_x
    else
      find_left_edge(mem, start_x + 1, y)
    end
  end

  defp find_right_edge(mem, x, y) do
    if check_point(mem, x + 1, y) == 0 do
      x
    else
      find_right_edge(mem, x + 1, y)
    end
  end

  defp check_point(mem, x, y) do
    [result] = run_intcode(mem, 0, 0, [x, y], [])
    result
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new(fn {v, i} -> {i, v} end)
  end

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
        [input | rest] = inputs
        addr = get_addr(mem, ip, rb, 1)
        run_intcode(Map.put(mem, addr, input), ip + 2, rb, rest, outputs)

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
        outputs
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
