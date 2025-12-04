import AOC

aoc 2016, 23 do
  @moduledoc """
  https://adventofcode.com/2016/day/23
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    instructions = parse(input)
    registers = %{"a" => 7, "b" => 0, "c" => 0, "d" => 0}
    execute(instructions, registers, 0)["a"]
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    instructions = parse(input)
    registers = %{"a" => 12, "b" => 0, "c" => 0, "d" => 0}
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
        ["tgl", x] -> {:tgl, x}
      end
      {idx, instruction}
    end)
    |> Map.new()
  end

  defp execute(instructions, registers, pc) do
    # Optimization: detect multiplication pattern
    # Pattern: cpy b c / inc a / dec c / jnz c -2 / dec d / jnz d -5
    # This is: a = a + (b * d), c = 0, d = 0
    optimized = if pc + 5 < map_size(instructions) do
      case [instructions[pc], instructions[pc + 1], instructions[pc + 2],
            instructions[pc + 3], instructions[pc + 4], instructions[pc + 5]] do
        [{:cpy, b, c}, {:inc, a}, {:dec, c_dec}, {:jnz, c_jnz, "-2"}, {:dec, d}, {:jnz, d_jnz, "-5"}]
        when c == c_dec and c == c_jnz and d == d_jnz ->
          if is_register?(a) and is_register?(b) and is_register?(c) and is_register?(d) do
            # Multiply optimization
            b_val = Map.get(registers, b, 0)
            d_val = Map.get(registers, d, 0)
            new_registers = registers
                           |> Map.update!(a, &(&1 + b_val * d_val))
                           |> Map.put(c, 0)
                           |> Map.put(d, 0)
            {:ok, new_registers, pc + 6}
          else
            :none
          end

        _ ->
          :none
      end
    else
      :none
    end

    case optimized do
      {:ok, new_registers, new_pc} ->
        execute(instructions, new_registers, new_pc)
      :none ->
        execute_normal(instructions, registers, pc)
    end
  end

  defp execute_normal(instructions, registers, pc) do
    if Map.has_key?(instructions, pc) do
      {new_instructions, new_registers, new_pc} = case instructions[pc] do
        {:cpy, x, y} ->
          # Skip if y is not a register
          if is_register?(y) do
            value = get_value(x, registers)
            {instructions, Map.put(registers, y, value), pc + 1}
          else
            {instructions, registers, pc + 1}
          end

        {:inc, x} ->
          if is_register?(x) do
            {instructions, Map.update!(registers, x, &(&1 + 1)), pc + 1}
          else
            {instructions, registers, pc + 1}
          end

        {:dec, x} ->
          if is_register?(x) do
            {instructions, Map.update!(registers, x, &(&1 - 1)), pc + 1}
          else
            {instructions, registers, pc + 1}
          end

        {:jnz, x, y} ->
          value = get_value(x, registers)
          offset = get_value(y, registers)
          if value != 0 do
            {instructions, registers, pc + offset}
          else
            {instructions, registers, pc + 1}
          end

        {:tgl, x} ->
          offset = get_value(x, registers)
          target = pc + offset

          new_instructions = if Map.has_key?(instructions, target) do
            toggled = toggle_instruction(instructions[target])
            Map.put(instructions, target, toggled)
          else
            instructions
          end

          {new_instructions, registers, pc + 1}
      end

      execute(new_instructions, new_registers, new_pc)
    else
      registers
    end
  end

  defp is_register?(x) do
    x in ["a", "b", "c", "d"]
  end

  defp get_value(x, registers) do
    case Integer.parse(x) do
      {n, ""} -> n
      :error -> Map.get(registers, x, 0)
    end
  end

  defp toggle_instruction(instruction) do
    case instruction do
      {:inc, x} -> {:dec, x}
      {:dec, x} -> {:inc, x}
      {:tgl, x} -> {:inc, x}
      {:jnz, x, y} -> {:cpy, x, y}
      {:cpy, x, y} -> {:jnz, x, y}
    end
  end
end
