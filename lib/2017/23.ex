import AOC

aoc 2017, 23 do
  @moduledoc """
  https://adventofcode.com/2017/day/23
  """

  def p1(input) do
    instructions = parse(input)
    registers = %{"a" => 0, "b" => 0, "c" => 0, "d" => 0, "e" => 0, "f" => 0, "g" => 0, "h" => 0}
    {_registers, mul_count} = execute(instructions, registers, 0, 0)
    mul_count
  end

  def p2(_input) do
    # The program counts non-prime numbers between b and c (inclusive) in steps of 17
    # For part 2, a=1, which sets b=107900 and c=124900
    b = 107900
    c = 124900

    Enum.count(b..c//17, fn n -> not is_prime?(n) end)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {line, idx} ->
      parts = String.split(line)
      {idx, parse_instruction(parts)}
    end)
    |> Map.new()
  end

  defp parse_instruction(["set", x, y]), do: {:set, x, y}
  defp parse_instruction(["sub", x, y]), do: {:sub, x, y}
  defp parse_instruction(["mul", x, y]), do: {:mul, x, y}
  defp parse_instruction(["jnz", x, y]), do: {:jnz, x, y}

  defp execute(instructions, registers, pc, mul_count) do
    case Map.get(instructions, pc) do
      nil ->
        {registers, mul_count}

      {:set, x, y} ->
        val = get_value(registers, y)
        execute(instructions, Map.put(registers, x, val), pc + 1, mul_count)

      {:sub, x, y} ->
        val = get_value(registers, y)
        current = Map.get(registers, x, 0)
        execute(instructions, Map.put(registers, x, current - val), pc + 1, mul_count)

      {:mul, x, y} ->
        val = get_value(registers, y)
        current = Map.get(registers, x, 0)
        execute(instructions, Map.put(registers, x, current * val), pc + 1, mul_count + 1)

      {:jnz, x, y} ->
        x_val = get_value(registers, x)
        if x_val != 0 do
          offset = get_value(registers, y)
          execute(instructions, registers, pc + offset, mul_count)
        else
          execute(instructions, registers, pc + 1, mul_count)
        end
    end
  end

  defp get_value(registers, val) do
    case Integer.parse(val) do
      {n, ""} -> n
      _ -> Map.get(registers, val, 0)
    end
  end

  defp is_prime?(n) when n < 2, do: false
  defp is_prime?(2), do: true
  defp is_prime?(n) when rem(n, 2) == 0, do: false
  defp is_prime?(n) do
    limit = :math.sqrt(n) |> trunc()
    not Enum.any?(3..limit//2, fn d -> rem(n, d) == 0 end)
  end
end
