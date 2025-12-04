import AOC

aoc 2016, 25 do
  @moduledoc """
  https://adventofcode.com/2016/day/25
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    instructions = parse(input)

    # Find the lowest positive integer that produces alternating 0,1,0,1... pattern
    Stream.iterate(0, &(&1 + 1))
    |> Enum.find(fn a ->
      output = execute(instructions, %{"a" => a, "b" => 0, "c" => 0, "d" => 0}, 0, [])
      is_clock_signal?(output)
    end)
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(_input) do
    "No Part 2 for Day 25!"
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {line, idx} ->
      case String.split(line) do
        ["cpy", x, y] -> {idx, {:cpy, x, y}}
        ["inc", x] -> {idx, {:inc, x}}
        ["dec", x] -> {idx, {:dec, x}}
        ["jnz", x, y] -> {idx, {:jnz, x, y}}
        ["out", x] -> {idx, {:out, x}}
      end
    end)
    |> Map.new()
  end

  defp execute(instructions, registers, pc, output) do
    # Limit output length to detect pattern
    if length(output) >= 50 do
      Enum.reverse(output)
    else
      if Map.has_key?(instructions, pc) do
        {new_registers, new_pc, new_output} = case instructions[pc] do
          {:cpy, x, y} ->
            if is_register?(y) do
              value = get_value(x, registers)
              {Map.put(registers, y, value), pc + 1, output}
            else
              {registers, pc + 1, output}
            end

          {:inc, x} ->
            if is_register?(x) do
              {Map.update!(registers, x, &(&1 + 1)), pc + 1, output}
            else
              {registers, pc + 1, output}
            end

          {:dec, x} ->
            if is_register?(x) do
              {Map.update!(registers, x, &(&1 - 1)), pc + 1, output}
            else
              {registers, pc + 1, output}
            end

          {:jnz, x, y} ->
            value = get_value(x, registers)
            offset = get_value(y, registers)
            if value != 0 do
              {registers, pc + offset, output}
            else
              {registers, pc + 1, output}
            end

          {:out, x} ->
            value = get_value(x, registers)
            {registers, pc + 1, [value | output]}
        end

        execute(instructions, new_registers, new_pc, new_output)
      else
        Enum.reverse(output)
      end
    end
  end

  defp get_value(x, registers) do
    case Integer.parse(x) do
      {num, ""} -> num
      _ -> Map.get(registers, x, 0)
    end
  end

  defp is_register?(x) do
    x in ["a", "b", "c", "d"]
  end

  defp is_clock_signal?(output) when length(output) < 10, do: false
  defp is_clock_signal?(output) do
    # Check if output is alternating 0,1,0,1...
    expected = Stream.cycle([0, 1]) |> Enum.take(length(output))
    output == expected
  end
end
