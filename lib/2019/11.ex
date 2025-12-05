import AOC

aoc 2019, 11 do
  @moduledoc """
  https://adventofcode.com/2019/day/11
  Hull painting robot
  """

  def p1(input) do
    mem = parse(input)
    panels = run_robot(mem, %{})
    map_size(panels)
  end

  def p2(input) do
    mem = parse(input)
    # Start on a white panel
    panels = run_robot(mem, %{{0, 0} => 1})
    render(panels)
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new(fn {v, i} -> {i, v} end)
  end

  defp run_robot(mem, panels) do
    state = %{
      mem: mem,
      ip: 0,
      rb: 0,
      pos: {0, 0},
      dir: :up,
      panels: panels,
      output_mode: :paint
    }
    robot_loop(state)
  end

  defp robot_loop(state) do
    current_color = Map.get(state.panels, state.pos, 0)

    case step_intcode(state.mem, state.ip, state.rb, [current_color]) do
      {:halt, _mem, _outputs} ->
        state.panels

      {:output, mem, ip, rb, color} ->
        # First output is color to paint
        new_panels = Map.put(state.panels, state.pos, color)

        # Continue to get turn instruction
        case step_intcode(mem, ip, rb, []) do
          {:halt, _mem, _outputs} ->
            new_panels

          {:output, mem2, ip2, rb2, turn} ->
            # Second output is turn direction
            new_dir = turn(state.dir, turn)
            new_pos = move(state.pos, new_dir)

            robot_loop(%{state |
              mem: mem2,
              ip: ip2,
              rb: rb2,
              pos: new_pos,
              dir: new_dir,
              panels: new_panels
            })
        end
    end
  end

  defp turn(:up, 0), do: :left
  defp turn(:up, 1), do: :right
  defp turn(:left, 0), do: :down
  defp turn(:left, 1), do: :up
  defp turn(:down, 0), do: :right
  defp turn(:down, 1), do: :left
  defp turn(:right, 0), do: :up
  defp turn(:right, 1), do: :down

  defp move({x, y}, :up), do: {x, y - 1}
  defp move({x, y}, :down), do: {x, y + 1}
  defp move({x, y}, :left), do: {x - 1, y}
  defp move({x, y}, :right), do: {x + 1, y}

  defp step_intcode(mem, ip, rb, inputs) do
    instruction = Map.get(mem, ip, 0)
    opcode = rem(instruction, 100)

    case opcode do
      1 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        step_intcode(Map.put(mem, c, a + b), ip + 4, rb, inputs)

      2 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        step_intcode(Map.put(mem, c, a * b), ip + 4, rb, inputs)

      3 ->
        case inputs do
          [input | rest] ->
            addr = get_addr(mem, ip, rb, 1)
            step_intcode(Map.put(mem, addr, input), ip + 2, rb, rest)
          [] ->
            {:need_input, mem, ip, rb}
        end

      4 ->
        val = get_param(mem, ip, rb, 1)
        {:output, mem, ip + 2, rb, val}

      5 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        new_ip = if a != 0, do: b, else: ip + 3
        step_intcode(mem, new_ip, rb, inputs)

      6 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        new_ip = if a == 0, do: b, else: ip + 3
        step_intcode(mem, new_ip, rb, inputs)

      7 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        val = if a < b, do: 1, else: 0
        step_intcode(Map.put(mem, c, val), ip + 4, rb, inputs)

      8 ->
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        val = if a == b, do: 1, else: 0
        step_intcode(Map.put(mem, c, val), ip + 4, rb, inputs)

      9 ->
        val = get_param(mem, ip, rb, 1)
        step_intcode(mem, ip + 2, rb + val, inputs)

      99 ->
        {:halt, mem, []}
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

  defp render(panels) do
    white_panels = panels |> Enum.filter(fn {_, v} -> v == 1 end) |> Enum.map(&elem(&1, 0))

    if Enum.empty?(white_panels) do
      ""
    else
      {min_x, max_x} = white_panels |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
      {min_y, max_y} = white_panels |> Enum.map(&elem(&1, 1)) |> Enum.min_max()

      for y <- min_y..max_y do
        for x <- min_x..max_x do
          if Map.get(panels, {x, y}, 0) == 1, do: "#", else: " "
        end
        |> Enum.join()
      end
      |> Enum.join("\n")
    end
  end
end
