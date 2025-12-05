import AOC

aoc 2019, 21 do
  @moduledoc """
  https://adventofcode.com/2019/day/21

  Springdroid Adventure - Program a robot to jump over holes using boolean logic.

  Springscript:
  - Registers: T (temp), J (jump)
  - Sensors: A-D (1-4 tiles, WALK) or A-I (1-9 tiles, RUN)
  - Instructions: AND X Y, OR X Y, NOT X Y
  - Jump lands 4 tiles ahead
  """

  def p1(input) do
    mem = parse(input)

    # Logic: Jump if there's a hole ahead AND landing is safe
    # (!A || !B || !C) && D
    # = !(A && B && C) && D
    script = """
    NOT A J
    NOT B T
    OR T J
    NOT C T
    OR T J
    AND D J
    WALK
    """

    run_springscript(mem, script)
  end

  def p2(input) do
    mem = parse(input)

    # Extended logic for RUN mode (can see up to 9 tiles)
    # Need to ensure we can continue after landing at D
    # Jump if: hole ahead (A/B/C) AND D is ground AND (H is ground OR E is ground)
    # The (H || E) ensures we can either jump again from D+4 or walk from D
    #
    # (!A || !B || !C) && D && (H || E)
    script = """
    NOT A J
    NOT B T
    OR T J
    NOT C T
    OR T J
    AND D J
    NOT E T
    NOT T T
    OR H T
    AND T J
    RUN
    """

    run_springscript(mem, script)
  end

  defp run_springscript(mem, script) do
    input_chars =
      script
      |> String.trim()
      |> String.to_charlist()
      |> Kernel.++([?\n])

    {_mem, outputs} = run_intcode(mem, input_chars)

    # Last output is either ASCII (failed) or large int (success)
    last = List.last(outputs)

    if last > 127 do
      last
    else
      # Debug: print the failure view
      outputs |> Enum.map(&<<&1::utf8>>) |> Enum.join() |> IO.puts()
      nil
    end
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.map(fn {v, i} -> {i, v} end)
    |> Map.new()
  end

  # Intcode VM
  defp run_intcode(mem, inputs) do
    run_intcode(mem, 0, 0, inputs, [])
  end

  defp run_intcode(mem, ip, rb, inputs, outputs) do
    instruction = Map.get(mem, ip, 0)
    opcode = rem(instruction, 100)
    modes = div(instruction, 100)

    case opcode do
      99 ->
        {mem, Enum.reverse(outputs)}

      1 ->
        # Add
        a = get_param(mem, ip + 1, rem(modes, 10), rb)
        b = get_param(mem, ip + 2, rem(div(modes, 10), 10), rb)
        dest = get_addr(mem, ip + 3, rem(div(modes, 100), 10), rb)
        mem = Map.put(mem, dest, a + b)
        run_intcode(mem, ip + 4, rb, inputs, outputs)

      2 ->
        # Multiply
        a = get_param(mem, ip + 1, rem(modes, 10), rb)
        b = get_param(mem, ip + 2, rem(div(modes, 10), 10), rb)
        dest = get_addr(mem, ip + 3, rem(div(modes, 100), 10), rb)
        mem = Map.put(mem, dest, a * b)
        run_intcode(mem, ip + 4, rb, inputs, outputs)

      3 ->
        # Input
        [val | rest] = inputs
        dest = get_addr(mem, ip + 1, rem(modes, 10), rb)
        mem = Map.put(mem, dest, val)
        run_intcode(mem, ip + 2, rb, rest, outputs)

      4 ->
        # Output
        val = get_param(mem, ip + 1, rem(modes, 10), rb)
        run_intcode(mem, ip + 2, rb, inputs, [val | outputs])

      5 ->
        # Jump if non-zero
        a = get_param(mem, ip + 1, rem(modes, 10), rb)
        b = get_param(mem, ip + 2, rem(div(modes, 10), 10), rb)
        new_ip = if a != 0, do: b, else: ip + 3
        run_intcode(mem, new_ip, rb, inputs, outputs)

      6 ->
        # Jump if zero
        a = get_param(mem, ip + 1, rem(modes, 10), rb)
        b = get_param(mem, ip + 2, rem(div(modes, 10), 10), rb)
        new_ip = if a == 0, do: b, else: ip + 3
        run_intcode(mem, new_ip, rb, inputs, outputs)

      7 ->
        # Less than
        a = get_param(mem, ip + 1, rem(modes, 10), rb)
        b = get_param(mem, ip + 2, rem(div(modes, 10), 10), rb)
        dest = get_addr(mem, ip + 3, rem(div(modes, 100), 10), rb)
        mem = Map.put(mem, dest, if(a < b, do: 1, else: 0))
        run_intcode(mem, ip + 4, rb, inputs, outputs)

      8 ->
        # Equals
        a = get_param(mem, ip + 1, rem(modes, 10), rb)
        b = get_param(mem, ip + 2, rem(div(modes, 10), 10), rb)
        dest = get_addr(mem, ip + 3, rem(div(modes, 100), 10), rb)
        mem = Map.put(mem, dest, if(a == b, do: 1, else: 0))
        run_intcode(mem, ip + 4, rb, inputs, outputs)

      9 ->
        # Adjust relative base
        a = get_param(mem, ip + 1, rem(modes, 10), rb)
        run_intcode(mem, ip + 2, rb + a, inputs, outputs)
    end
  end

  defp get_param(mem, addr, mode, rb) do
    val = Map.get(mem, addr, 0)

    case mode do
      0 -> Map.get(mem, val, 0)
      1 -> val
      2 -> Map.get(mem, rb + val, 0)
    end
  end

  defp get_addr(mem, addr, mode, rb) do
    val = Map.get(mem, addr, 0)

    case mode do
      0 -> val
      2 -> rb + val
    end
  end
end
