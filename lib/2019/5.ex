import AOC

aoc 2019, 5 do
  @moduledoc """
  https://adventofcode.com/2019/day/5
  """

  def p1(input) do
    mem = parse(input)
    {_, outputs} = run(mem, [1])
    List.last(outputs)
  end

  def p2(input) do
    mem = parse(input)
    {_, outputs} = run(mem, [5])
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

  defp run(mem, inputs), do: run(mem, 0, inputs, [])

  defp run(mem, ip, inputs, outputs) do
    instruction = mem[ip]
    opcode = rem(instruction, 100)

    case opcode do
      1 -> # add
        {a, b, c} = {get_param(mem, ip, 1), get_param(mem, ip, 2), mem[ip + 3]}
        run(Map.put(mem, c, a + b), ip + 4, inputs, outputs)

      2 -> # multiply
        {a, b, c} = {get_param(mem, ip, 1), get_param(mem, ip, 2), mem[ip + 3]}
        run(Map.put(mem, c, a * b), ip + 4, inputs, outputs)

      3 -> # input
        [input | rest_inputs] = inputs
        addr = mem[ip + 1]
        run(Map.put(mem, addr, input), ip + 2, rest_inputs, outputs)

      4 -> # output
        val = get_param(mem, ip, 1)
        run(mem, ip + 2, inputs, outputs ++ [val])

      5 -> # jump-if-true
        {a, b} = {get_param(mem, ip, 1), get_param(mem, ip, 2)}
        new_ip = if a != 0, do: b, else: ip + 3
        run(mem, new_ip, inputs, outputs)

      6 -> # jump-if-false
        {a, b} = {get_param(mem, ip, 1), get_param(mem, ip, 2)}
        new_ip = if a == 0, do: b, else: ip + 3
        run(mem, new_ip, inputs, outputs)

      7 -> # less than
        {a, b, c} = {get_param(mem, ip, 1), get_param(mem, ip, 2), mem[ip + 3]}
        val = if a < b, do: 1, else: 0
        run(Map.put(mem, c, val), ip + 4, inputs, outputs)

      8 -> # equals
        {a, b, c} = {get_param(mem, ip, 1), get_param(mem, ip, 2), mem[ip + 3]}
        val = if a == b, do: 1, else: 0
        run(Map.put(mem, c, val), ip + 4, inputs, outputs)

      99 -> # halt
        {mem, outputs}
    end
  end

  defp get_param(mem, ip, offset) do
    instruction = mem[ip]
    mode = div(instruction, round(:math.pow(10, offset + 1))) |> rem(10)

    case mode do
      0 -> mem[mem[ip + offset]] # position mode
      1 -> mem[ip + offset]       # immediate mode
    end
  end
end
