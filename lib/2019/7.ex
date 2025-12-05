import AOC

aoc 2019, 7 do
  @moduledoc """
  https://adventofcode.com/2019/day/7
  Amplification Circuit - chain 5 Intcode computers
  """

  def p1(input) do
    mem = parse(input)

    # Try all permutations of phase settings 0-4
    permutations([0, 1, 2, 3, 4])
    |> Enum.map(fn phases -> run_serial_chain(mem, phases) end)
    |> Enum.max()
  end

  def p2(input) do
    mem = parse(input)

    # Try all permutations of phase settings 5-9 with feedback loop
    permutations([5, 6, 7, 8, 9])
    |> Enum.map(fn phases -> run_feedback_loop(mem, phases) end)
    |> Enum.max()
  end

  # Part 1: Run amplifiers in series (each runs to completion)
  defp run_serial_chain(mem, [pa, pb, pc, pd, pe]) do
    {_, [out_a]} = run_to_halt(mem, 0, [pa, 0], [])
    {_, [out_b]} = run_to_halt(mem, 0, [pb, out_a], [])
    {_, [out_c]} = run_to_halt(mem, 0, [pc, out_b], [])
    {_, [out_d]} = run_to_halt(mem, 0, [pd, out_c], [])
    {_, [out_e]} = run_to_halt(mem, 0, [pe, out_d], [])
    out_e
  end

  # Part 2: Run amplifiers in feedback loop
  defp run_feedback_loop(mem, phases) do
    # Initialize all 5 amplifiers with their phase settings
    amps = phases
    |> Enum.map(fn phase ->
      # Each amp starts with phase as first input, suspended at first input instruction
      %{mem: mem, ip: 0, inputs: [phase], halted: false}
    end)

    # Run feedback loop starting with signal 0 to amp A
    feedback_loop(amps, 0, 0)
  end

  defp feedback_loop(amps, current_amp, signal) do
    amp = Enum.at(amps, current_amp)

    if amp.halted do
      # If amp E halted, return the last signal it produced
      signal
    else
      # Add signal to this amp's inputs and run until output or halt
      inputs = amp.inputs ++ [signal]

      case run_until_output_or_halt(amp.mem, amp.ip, inputs, []) do
        {:output, mem, ip, remaining_inputs, output} ->
          # Update this amp's state
          updated_amp = %{amp | mem: mem, ip: ip, inputs: remaining_inputs}
          updated_amps = List.replace_at(amps, current_amp, updated_amp)

          # Move to next amp with this output as signal
          next_amp = rem(current_amp + 1, 5)
          feedback_loop(updated_amps, next_amp, output)

        {:halt, _mem, _ip, _remaining_inputs} ->
          # This amp halted
          if current_amp == 4 do
            # Amp E halted, return the last signal (which was the input to E)
            signal
          else
            # Mark this amp as halted and continue
            updated_amp = %{amp | halted: true}
            updated_amps = List.replace_at(amps, current_amp, updated_amp)
            next_amp = rem(current_amp + 1, 5)
            feedback_loop(updated_amps, next_amp, signal)
          end
      end
    end
  end

  # Run until we produce an output or halt
  defp run_until_output_or_halt(mem, ip, inputs, _outputs) do
    instruction = Map.get(mem, ip, 0)
    opcode = rem(instruction, 100)

    case opcode do
      1 ->
        {a, b} = {get_param(mem, ip, 1), get_param(mem, ip, 2)}
        c = mem[ip + 3]
        run_until_output_or_halt(Map.put(mem, c, a + b), ip + 4, inputs, [])

      2 ->
        {a, b} = {get_param(mem, ip, 1), get_param(mem, ip, 2)}
        c = mem[ip + 3]
        run_until_output_or_halt(Map.put(mem, c, a * b), ip + 4, inputs, [])

      3 ->
        [input | rest] = inputs
        addr = mem[ip + 1]
        run_until_output_or_halt(Map.put(mem, addr, input), ip + 2, rest, [])

      4 ->
        output = get_param(mem, ip, 1)
        {:output, mem, ip + 2, inputs, output}

      5 ->
        {a, b} = {get_param(mem, ip, 1), get_param(mem, ip, 2)}
        new_ip = if a != 0, do: b, else: ip + 3
        run_until_output_or_halt(mem, new_ip, inputs, [])

      6 ->
        {a, b} = {get_param(mem, ip, 1), get_param(mem, ip, 2)}
        new_ip = if a == 0, do: b, else: ip + 3
        run_until_output_or_halt(mem, new_ip, inputs, [])

      7 ->
        {a, b} = {get_param(mem, ip, 1), get_param(mem, ip, 2)}
        c = mem[ip + 3]
        val = if a < b, do: 1, else: 0
        run_until_output_or_halt(Map.put(mem, c, val), ip + 4, inputs, [])

      8 ->
        {a, b} = {get_param(mem, ip, 1), get_param(mem, ip, 2)}
        c = mem[ip + 3]
        val = if a == b, do: 1, else: 0
        run_until_output_or_halt(Map.put(mem, c, val), ip + 4, inputs, [])

      99 ->
        {:halt, mem, ip, inputs}
    end
  end

  # Run to completion (for Part 1)
  defp run_to_halt(mem, ip, inputs, outputs) do
    instruction = Map.get(mem, ip, 0)
    opcode = rem(instruction, 100)

    case opcode do
      1 ->
        {a, b} = {get_param(mem, ip, 1), get_param(mem, ip, 2)}
        c = mem[ip + 3]
        run_to_halt(Map.put(mem, c, a + b), ip + 4, inputs, outputs)

      2 ->
        {a, b} = {get_param(mem, ip, 1), get_param(mem, ip, 2)}
        c = mem[ip + 3]
        run_to_halt(Map.put(mem, c, a * b), ip + 4, inputs, outputs)

      3 ->
        [input | rest] = inputs
        addr = mem[ip + 1]
        run_to_halt(Map.put(mem, addr, input), ip + 2, rest, outputs)

      4 ->
        output = get_param(mem, ip, 1)
        run_to_halt(mem, ip + 2, inputs, outputs ++ [output])

      5 ->
        {a, b} = {get_param(mem, ip, 1), get_param(mem, ip, 2)}
        new_ip = if a != 0, do: b, else: ip + 3
        run_to_halt(mem, new_ip, inputs, outputs)

      6 ->
        {a, b} = {get_param(mem, ip, 1), get_param(mem, ip, 2)}
        new_ip = if a == 0, do: b, else: ip + 3
        run_to_halt(mem, new_ip, inputs, outputs)

      7 ->
        {a, b} = {get_param(mem, ip, 1), get_param(mem, ip, 2)}
        c = mem[ip + 3]
        val = if a < b, do: 1, else: 0
        run_to_halt(Map.put(mem, c, val), ip + 4, inputs, outputs)

      8 ->
        {a, b} = {get_param(mem, ip, 1), get_param(mem, ip, 2)}
        c = mem[ip + 3]
        val = if a == b, do: 1, else: 0
        run_to_halt(Map.put(mem, c, val), ip + 4, inputs, outputs)

      99 ->
        {mem, outputs}
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

  defp get_param(mem, ip, offset) do
    instruction = Map.get(mem, ip, 0)
    mode = div(instruction, round(:math.pow(10, offset + 1))) |> rem(10)

    case mode do
      0 -> Map.get(mem, Map.get(mem, ip + offset, 0), 0)
      1 -> Map.get(mem, ip + offset, 0)
    end
  end

  defp permutations([]), do: [[]]
  defp permutations(list) do
    for elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest]
  end
end
