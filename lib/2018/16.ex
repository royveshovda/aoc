import AOC

aoc 2018, 16 do
  @moduledoc """
  https://adventofcode.com/2018/day/16

  Day 16: Chronal Classification - Reverse engineering CPU opcodes
  """

  @doc """
  Part 1: Count samples that behave like 3 or more opcodes

  ## Examples

      iex> input = "Before: [3, 2, 1, 1]\\n9 2 1 2\\nAfter:  [3, 2, 2, 1]"
      iex> p1(input)
      1
  """
  def p1(input) do
    {samples, _program} = parse_input(input)

    samples
    |> Enum.count(fn sample ->
      count_matching_opcodes(sample) >= 3
    end)
  end

  @doc """
  Part 2: Determine opcode mappings and execute test program
  """
  def p2(input) do
    {samples, program} = parse_input(input)

    # Determine which opcode number corresponds to which operation
    opcode_map = determine_opcodes(samples)

    # Execute the test program
    execute_program(program, opcode_map)
  end

  defp parse_input(input) do
    parts = input |> String.split("\n\n\n", parts: 2)

    case parts do
      [samples_str, program_str] ->
        samples = parse_samples(samples_str)
        program = parse_program(program_str)
        {samples, program}
      [samples_str] ->
        samples = parse_samples(samples_str)
        {samples, []}
    end
  end

  defp parse_samples(samples_str) do
    samples_str
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_sample/1)
  end

  defp parse_sample(sample_str) do
    lines = String.split(sample_str, "\n", trim: true)

    case lines do
      [before, inst, after_line] ->
        before_regs = parse_registers(before)
        instruction = parse_instruction(inst)
        after_regs = parse_registers(after_line)
        {before_regs, instruction, after_regs}
      _ ->
        nil
    end
  end

  defp parse_registers(line) do
    Regex.scan(~r/\d+/, line)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp parse_instruction(line) do
    line
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp parse_program(program_str) do
    program_str
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction/1)
  end

  defp count_matching_opcodes({before, {_opcode, a, b, c}, after_regs}) do
    all_ops()
    |> Enum.count(fn op ->
      result = execute_op(op, a, b, c, before)
      result == after_regs
    end)
  end

  defp all_ops do
    [:addr, :addi, :mulr, :muli, :banr, :bani, :borr, :bori,
     :setr, :seti, :gtir, :gtri, :gtrr, :eqir, :eqri, :eqrr]
  end

  defp execute_op(op, a, b, c, registers) do
    result = case op do
      :addr -> elem(registers, a) + elem(registers, b)
      :addi -> elem(registers, a) + b
      :mulr -> elem(registers, a) * elem(registers, b)
      :muli -> elem(registers, a) * b
      :banr -> Bitwise.band(elem(registers, a), elem(registers, b))
      :bani -> Bitwise.band(elem(registers, a), b)
      :borr -> Bitwise.bor(elem(registers, a), elem(registers, b))
      :bori -> Bitwise.bor(elem(registers, a), b)
      :setr -> elem(registers, a)
      :seti -> a
      :gtir -> if a > elem(registers, b), do: 1, else: 0
      :gtri -> if elem(registers, a) > b, do: 1, else: 0
      :gtrr -> if elem(registers, a) > elem(registers, b), do: 1, else: 0
      :eqir -> if a == elem(registers, b), do: 1, else: 0
      :eqri -> if elem(registers, a) == b, do: 1, else: 0
      :eqrr -> if elem(registers, a) == elem(registers, b), do: 1, else: 0
    end

    put_elem(registers, c, result)
  end

  defp determine_opcodes(samples) do
    # Build a map of opcode number to possible operations
    possibilities =
      samples
      |> Enum.reduce(%{}, fn {before, {opcode, a, b, c}, after_regs}, acc ->
        matching_ops =
          all_ops()
          |> Enum.filter(fn op ->
            result = execute_op(op, a, b, c, before)
            result == after_regs
          end)
          |> MapSet.new()

        Map.update(acc, opcode, matching_ops, fn existing ->
          MapSet.intersection(existing, matching_ops)
        end)
      end)

    # Iteratively determine unique mappings
    resolve_opcodes(possibilities, %{})
  end

  defp resolve_opcodes(possibilities, resolved) do
    if map_size(possibilities) == 0 do
      resolved
    else
      # Find an opcode with only one possibility
      {opcode, ops} =
        possibilities
        |> Enum.find(fn {_opcode, ops} -> MapSet.size(ops) == 1 end)

      [op] = MapSet.to_list(ops)

      # Remove this operation from all other possibilities
      new_possibilities =
        possibilities
        |> Map.delete(opcode)
        |> Enum.map(fn {k, v} -> {k, MapSet.delete(v, op)} end)
        |> Map.new()

      resolve_opcodes(new_possibilities, Map.put(resolved, opcode, op))
    end
  end

  defp execute_program(program, opcode_map) do
    initial_registers = {0, 0, 0, 0}

    program
    |> Enum.reduce(initial_registers, fn {opcode, a, b, c}, registers ->
      op = Map.get(opcode_map, opcode)
      execute_op(op, a, b, c, registers)
    end)
    |> elem(0)  # Return value in register 0
  end
end
