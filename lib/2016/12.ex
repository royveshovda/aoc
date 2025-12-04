import AOC

aoc 2016, 12 do
  @moduledoc """
  https://adventofcode.com/2016/day/12
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    instructions = parse(input)
    registers = %{"a" => 0, "b" => 0, "c" => 0, "d" => 0}
    execute(instructions, registers, 0)["a"]
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    instructions = parse(input)
    registers = %{"a" => 0, "b" => 0, "c" => 1, "d" => 0}
    execute(instructions, registers, 0)["a"]
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {line, idx} ->
      parts = String.split(line)
      instruction = case parts do
        ["cpy", x, y] -> {:cpy, x, y}
        ["inc", x] -> {:inc, x}
        ["dec", x] -> {:dec, x}
        ["jnz", x, y] -> {:jnz, x, y}
      end
      {idx, instruction}
    end)
    |> Map.new()
  end

  defp execute(instructions, registers, pc) do
    if Map.has_key?(instructions, pc) do
      {new_registers, new_pc} = case instructions[pc] do
        {:cpy, x, y} ->
          value = get_value(x, registers)
          {Map.put(registers, y, value), pc + 1}

        {:inc, x} ->
          {Map.update!(registers, x, &(&1 + 1)), pc + 1}

        {:dec, x} ->
          {Map.update!(registers, x, &(&1 - 1)), pc + 1}

        {:jnz, x, y} ->
          value = get_value(x, registers)
          offset = get_value(y, registers)
          if value != 0 do
            {registers, pc + offset}
          else
            {registers, pc + 1}
          end
      end

      execute(instructions, new_registers, new_pc)
    else
      registers
    end
  end

  defp get_value(x, registers) do
    case Integer.parse(x) do
      {n, ""} -> n
      :error -> Map.get(registers, x, 0)
    end
  end
end
