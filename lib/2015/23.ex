import AOC

aoc 2015, 23 do
  @moduledoc """
  https://adventofcode.com/2015/day/23

  Day 23: Opening the Turing Lock

  Simple assembly language interpreter with two registers (a, b) and six instructions.
  """

  def p1(input) do
    instructions = parse_input(input)
    execute(instructions, %{a: 0, b: 0})
  end

  def p2(input) do
    instructions = parse_input(input)
    execute(instructions, %{a: 1, b: 0})
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction/1)
    |> Enum.with_index()
    |> Map.new(fn {inst, idx} -> {idx, inst} end)
  end

  defp parse_instruction(line) do
    case String.split(line, [" ", ", "], trim: true) do
      ["hlf", reg] -> {:hlf, String.to_atom(reg)}
      ["tpl", reg] -> {:tpl, String.to_atom(reg)}
      ["inc", reg] -> {:inc, String.to_atom(reg)}
      ["jmp", offset] -> {:jmp, String.to_integer(offset)}
      ["jie", reg, offset] -> {:jie, String.to_atom(reg), String.to_integer(offset)}
      ["jio", reg, offset] -> {:jio, String.to_atom(reg), String.to_integer(offset)}
    end
  end

  defp execute(instructions, registers, pc \\ 0) do
    case Map.get(instructions, pc) do
      nil ->
        # Program terminated
        registers.b

      {:hlf, reg} ->
        new_registers = Map.update!(registers, reg, &div(&1, 2))
        execute(instructions, new_registers, pc + 1)

      {:tpl, reg} ->
        new_registers = Map.update!(registers, reg, &(&1 * 3))
        execute(instructions, new_registers, pc + 1)

      {:inc, reg} ->
        new_registers = Map.update!(registers, reg, &(&1 + 1))
        execute(instructions, new_registers, pc + 1)

      {:jmp, offset} ->
        execute(instructions, registers, pc + offset)

      {:jie, reg, offset} ->
        value = Map.get(registers, reg)
        new_pc = if rem(value, 2) == 0, do: pc + offset, else: pc + 1
        execute(instructions, registers, new_pc)

      {:jio, reg, offset} ->
        value = Map.get(registers, reg)
        new_pc = if value == 1, do: pc + offset, else: pc + 1
        execute(instructions, registers, new_pc)
    end
  end
end
