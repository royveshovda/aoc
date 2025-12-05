import AOC

aoc 2019, 13 do
  @moduledoc """
  https://adventofcode.com/2019/day/13
  Arcade cabinet - breakout game
  """

  def p1(input) do
    mem = parse(input)
    outputs = run_to_halt(mem, [])

    outputs
    |> Enum.chunk_every(3)
    |> Enum.count(fn [_x, _y, tile] -> tile == 2 end)
  end

  def p2(input) do
    mem = parse(input)
    # Insert quarters: set memory address 0 to 2
    mem = Map.put(mem, 0, 2)

    # First run to get initial screen state
    {status, mem, ip, rb, outputs} = run_until_input_or_halt(mem, 0, 0, [])

    {ball_x, paddle_x, score} = extract_game_state(outputs, 0, 0, 0)

    game_loop(status, mem, ip, rb, ball_x, paddle_x, score)
  end

  defp game_loop(:halt, _mem, _ip, _rb, _ball_x, _paddle_x, score), do: score
  defp game_loop(:need_input, mem, ip, rb, ball_x, paddle_x, score) do
    # Move paddle toward ball
    joystick = cond do
      ball_x < paddle_x -> -1
      ball_x > paddle_x -> 1
      true -> 0
    end

    # Provide input and run until next input needed or halt
    addr = get_addr(mem, ip, rb, 1)
    new_mem = Map.put(mem, addr, joystick)

    {status, mem2, ip2, rb2, outputs} = run_until_input_or_halt(new_mem, ip + 2, rb, [])

    {new_ball, new_paddle, new_score} = extract_game_state(outputs, ball_x, paddle_x, score)

    game_loop(status, mem2, ip2, rb2, new_ball, new_paddle, new_score)
  end

  defp extract_game_state(outputs, ball_x, paddle_x, score) do
    outputs
    |> Enum.chunk_every(3)
    |> Enum.reduce({ball_x, paddle_x, score}, fn [x, y, tile], {bx, px, sc} ->
      cond do
        x == -1 and y == 0 -> {bx, px, tile}  # score update
        tile == 4 -> {x, px, sc}               # ball position
        tile == 3 -> {bx, x, sc}               # paddle position
        true -> {bx, px, sc}
      end
    end)
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new(fn {v, i} -> {i, v} end)
  end

  defp run_until_input_or_halt(mem, ip, rb, outputs) do
    instruction = Map.get(mem, ip, 0)
    opcode = rem(instruction, 100)

    case opcode do
      1 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        run_until_input_or_halt(Map.put(mem, c, a + b), ip + 4, rb, outputs)

      2 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        run_until_input_or_halt(Map.put(mem, c, a * b), ip + 4, rb, outputs)

      3 ->
        # Input instruction - return to get joystick input
        {:need_input, mem, ip, rb, outputs}

      4 ->
        val = get_param(mem, ip, rb, 1)
        run_until_input_or_halt(mem, ip + 2, rb, outputs ++ [val])

      5 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        new_ip = if a != 0, do: b, else: ip + 3
        run_until_input_or_halt(mem, new_ip, rb, outputs)

      6 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        new_ip = if a == 0, do: b, else: ip + 3
        run_until_input_or_halt(mem, new_ip, rb, outputs)

      7 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        val = if a < b, do: 1, else: 0
        run_until_input_or_halt(Map.put(mem, c, val), ip + 4, rb, outputs)

      8 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        val = if a == b, do: 1, else: 0
        run_until_input_or_halt(Map.put(mem, c, val), ip + 4, rb, outputs)

      9 ->
        val = get_param(mem, ip, rb, 1)
        run_until_input_or_halt(mem, ip + 2, rb + val, outputs)

      99 ->
        {:halt, mem, ip, rb, outputs}
    end
  end

  defp run_to_halt(mem, inputs), do: run_intcode(mem, 0, 0, inputs, [])

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
