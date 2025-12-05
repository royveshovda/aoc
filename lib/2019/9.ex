import AOC

aoc 2019, 9 do
  @moduledoc """
  https://adventofcode.com/2019/day/9
  Complete Intcode with relative mode
  """

  def p1(input) do
    mem = parse(input)
    {_, outputs} = run(mem, [1])
    List.last(outputs)
  end

  def p2(input) do
    mem = parse(input)
    {_, outputs} = run(mem, [2])
    List.last(outputs)
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new(fn {v, i} -> {i, v} end)
  end

  defp run(mem, inputs), do: run(mem, 0, 0, inputs, [])

  defp run(mem, ip, rb, inputs, outputs) do
    instruction = Map.get(mem, ip, 0)
    opcode = rem(instruction, 100)

    case opcode do
      1 -> # add
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        run(Map.put(mem, c, a + b), ip + 4, rb, inputs, outputs)

      2 -> # multiply
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        run(Map.put(mem, c, a * b), ip + 4, rb, inputs, outputs)

      3 -> # input
        [input | rest_inputs] = inputs
        addr = get_addr(mem, ip, rb, 1)
        run(Map.put(mem, addr, input), ip + 2, rb, rest_inputs, outputs)

      4 -> # output
        val = get_param(mem, ip, rb, 1)
        run(mem, ip + 2, rb, inputs, outputs ++ [val])

      5 -> # jump-if-true
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        new_ip = if a != 0, do: b, else: ip + 3
        run(mem, new_ip, rb, inputs, outputs)

      6 -> # jump-if-false
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        new_ip = if a == 0, do: b, else: ip + 3
        run(mem, new_ip, rb, inputs, outputs)

      7 -> # less than
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        val = if a < b, do: 1, else: 0
        run(Map.put(mem, c, val), ip + 4, rb, inputs, outputs)

      8 -> # equals
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        val = if a == b, do: 1, else: 0
        run(Map.put(mem, c, val), ip + 4, rb, inputs, outputs)

      9 -> # adjust relative base
        val = get_param(mem, ip, rb, 1)
        run(mem, ip + 2, rb + val, inputs, outputs)

      99 -> # halt
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
      0 -> Map.get(mem, param, 0)           # position mode
      1 -> param                             # immediate mode
      2 -> Map.get(mem, rb + param, 0)       # relative mode
    end
  end

  defp get_addr(mem, ip, rb, offset) do
    mode = get_mode(mem, ip, offset)
    param = Map.get(mem, ip + offset, 0)

    case mode do
      0 -> param              # position mode
      2 -> rb + param         # relative mode
    end
  end
end
