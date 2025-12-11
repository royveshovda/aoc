import AOC

aoc 2017, 18 do
  @moduledoc """
  https://adventofcode.com/2017/day/18
  """

  def p1(input) do
    instructions = parse(input)
    run_p1(instructions, %{}, 0, nil)
  end

  def p2(input) do
    instructions = parse(input)
    run_p2(instructions)
  end

  defp parse(input) do
    input |> String.trim() |> String.split("\n") |> Enum.map(&parse_line/1)
    |> Enum.with_index() |> Map.new(fn {inst, i} -> {i, inst} end)
  end

  defp parse_line(line) do
    case String.split(line) do
      ["snd", x] -> {:snd, parse_val(x)}
      ["set", x, y] -> {:set, x, parse_val(y)}
      ["add", x, y] -> {:add, x, parse_val(y)}
      ["mul", x, y] -> {:mul, x, parse_val(y)}
      ["mod", x, y] -> {:mod, x, parse_val(y)}
      ["rcv", x] -> {:rcv, x}
      ["jgz", x, y] -> {:jgz, parse_val(x), parse_val(y)}
    end
  end

  defp parse_val(s) do
    case Integer.parse(s) do
      {n, ""} -> n
      _ -> s
    end
  end

  defp get_val(_regs, val) when is_integer(val), do: val
  defp get_val(regs, val), do: Map.get(regs, val, 0)

  defp run_p1(instructions, regs, pc, last_sound) do
    case Map.get(instructions, pc) do
      nil -> last_sound
      {:snd, x} -> run_p1(instructions, regs, pc + 1, get_val(regs, x))
      {:set, x, y} -> run_p1(instructions, Map.put(regs, x, get_val(regs, y)), pc + 1, last_sound)
      {:add, x, y} -> run_p1(instructions, Map.update(regs, x, get_val(regs, y), &(&1 + get_val(regs, y))), pc + 1, last_sound)
      {:mul, x, y} -> run_p1(instructions, Map.update(regs, x, 0, &(&1 * get_val(regs, y))), pc + 1, last_sound)
      {:mod, x, y} -> run_p1(instructions, Map.update(regs, x, 0, &(rem(&1, get_val(regs, y)))), pc + 1, last_sound)
      {:rcv, x} -> if get_val(regs, x) != 0, do: last_sound, else: run_p1(instructions, regs, pc + 1, last_sound)
      {:jgz, x, y} ->
        new_pc = if get_val(regs, x) > 0, do: pc + get_val(regs, y), else: pc + 1
        run_p1(instructions, regs, new_pc, last_sound)
    end
  end

  defp run_p2(instructions) do
    state0 = %{regs: %{"p" => 0}, pc: 0, queue: [], waiting: false}
    state1 = %{regs: %{"p" => 1}, pc: 0, queue: [], waiting: false}
    execute_programs(instructions, state0, state1, 0)
  end

  defp execute_programs(instructions, state0, state1, send_count) do
    # Execute program 0 until it blocks
    {new_state0, msgs0, blocked0} = run_until_block(instructions, state0)

    # Add messages to program 1's queue
    new_state1 = %{state1 | queue: state1.queue ++ msgs0, waiting: false}

    # Execute program 1 until it blocks
    {final_state1, msgs1, blocked1} = run_until_block(instructions, new_state1)

    # Add messages to program 0's queue
    final_state0 = %{new_state0 | queue: new_state0.queue ++ msgs1, waiting: false}

    new_send_count = send_count + length(msgs1)

    # Both blocked and no messages exchanged = deadlock
    if blocked0 and blocked1 and Enum.empty?(msgs0) and Enum.empty?(msgs1) do
      new_send_count
    else
      execute_programs(instructions, final_state0, final_state1, new_send_count)
    end
  end

  defp run_until_block(instructions, state, sent \\ []) do
    case Map.get(instructions, state.pc) do
      nil ->
        {state, sent, true}

      {:snd, x} ->
        val = get_val(state.regs, x)
        run_until_block(instructions, %{state | pc: state.pc + 1}, sent ++ [val])

      {:rcv, x} ->
        case state.queue do
          [] -> {%{state | waiting: true}, sent, true}
          [val | rest] ->
            new_regs = Map.put(state.regs, x, val)
            run_until_block(instructions, %{state | regs: new_regs, pc: state.pc + 1, queue: rest}, sent)
        end

      {:set, x, y} ->
        new_regs = Map.put(state.regs, x, get_val(state.regs, y))
        run_until_block(instructions, %{state | regs: new_regs, pc: state.pc + 1}, sent)

      {:add, x, y} ->
        new_regs = Map.update(state.regs, x, get_val(state.regs, y), &(&1 + get_val(state.regs, y)))
        run_until_block(instructions, %{state | regs: new_regs, pc: state.pc + 1}, sent)

      {:mul, x, y} ->
        new_regs = Map.put(state.regs, x, get_val(state.regs, x) * get_val(state.regs, y))
        run_until_block(instructions, %{state | regs: new_regs, pc: state.pc + 1}, sent)

      {:mod, x, y} ->
        new_regs = Map.put(state.regs, x, rem(get_val(state.regs, x), get_val(state.regs, y)))
        run_until_block(instructions, %{state | regs: new_regs, pc: state.pc + 1}, sent)

      {:jgz, x, y} ->
        new_pc = if get_val(state.regs, x) > 0, do: state.pc + get_val(state.regs, y), else: state.pc + 1
        run_until_block(instructions, %{state | pc: new_pc}, sent)
    end
  end
end
