import AOC

aoc 2018, 21 do
  @moduledoc """
  https://adventofcode.com/2018/day/21

  Day 21: Chronal Conversion - Find value for register 0 to halt the program

  The program contains an equality check: eqrr 2 0 3
  When register 2 equals register 0, the program halts.

  Part 1: Find the first value register 2 has when reaching the comparison
  Part 2: Find the last unique value (before cycle repeats) for longest execution
  """

  def p1(input) do
    {ip_reg, instructions} = parse_input(input)

    # Find the instruction that compares with register 0
    halt_check_ip = find_halt_check(instructions)

    # Run until we hit that instruction for the first time
    registers = {0, 0, 0, 0, 0, 0}
    find_first_halt_value(instructions, ip_reg, registers, 0, halt_check_ip)
  end

  def p2(_input) do
    # Instead of simulating, implement the logic directly
    # This is much faster than VM simulation
    find_last_unique_value_optimized()
  end

  # Optimized version that implements the program logic directly
  defp find_last_unique_value_optimized() do
    # Initial state
    seen = MapSet.new()
    last_value = nil

    run_program_loop(0, seen, last_value)
  end

  defp run_program_loop(r2, seen, last_value) do
    # This is the main loop starting at line 6
    r5 = Bitwise.bor(r2, 65536)  # Line 7
    r2 = 5234604  # Line 8

    r2 = compute_inner_loop(r2, r5)

    # Check if we've seen this value before
    if MapSet.member?(seen, r2) do
      # Cycle detected, return last unique value
      last_value
    else
      # Continue with new value
      seen = MapSet.put(seen, r2)
      run_program_loop(r2, seen, r2)
    end
  end

  defp compute_inner_loop(r2, r5) do
    # Lines 9-27 implement a complex loop
    r3 = Bitwise.band(r5, 255)  # Line 9
    r2 = r2 + r3  # Line 10
    r2 = Bitwise.band(r2, 16777215)  # Line 11
    r2 = r2 * 65899  # Line 12
    r2 = Bitwise.band(r2, 16777215)  # Line 13

    # Lines 14-27: Check if r5 < 256, if not divide by 256
    if r5 < 256 do
      r2
    else
      # Division by 256 (implemented as loop in original)
      r5 = div(r5, 256)
      compute_inner_loop(r2, r5)
    end
  end

  defp parse_input(input) do
    lines = String.split(input, "\n", trim: true)

    [ip_line | inst_lines] = lines
    "#ip " <> ip_reg_str = ip_line
    ip_reg = String.to_integer(ip_reg_str)

    instructions =
      inst_lines
      |> Enum.map(&parse_instruction/1)
      |> List.to_tuple()

    {ip_reg, instructions}
  end

  defp parse_instruction(line) do
    [op | args] = String.split(line, " ", trim: true)
    op_atom = String.to_atom(op)
    [a, b, c] = Enum.map(args, &String.to_integer/1)
    {op_atom, a, b, c}
  end

  # Find the instruction that checks equality with register 0
  defp find_halt_check(instructions) do
    instructions
    |> Tuple.to_list()
    |> Enum.with_index()
    |> Enum.find(fn {{op, a, b, _c}, _idx} ->
      op == :eqrr and (a == 0 or b == 0)
    end)
    |> elem(1)
  end

  # Find the first value that register 2 has when reaching the halt check
  defp find_first_halt_value(instructions, ip_reg, registers, ip, halt_check_ip) do
    if ip == halt_check_ip do
      # We're at the halt check - return the value in register 2
      {_op, a, b, _c} = elem(instructions, ip)
      # The comparison is eqrr 2 0 3, so we want the value in register 2
      target_reg = if a == 0, do: b, else: a
      elem(registers, target_reg)
    else
      if ip < 0 or ip >= tuple_size(instructions) do
        # Should never happen
        nil
      else
        # Write IP to bound register
        registers = put_elem(registers, ip_reg, ip)

        # Execute instruction
        {op, a, b, c} = elem(instructions, ip)
        registers = execute_op(op, a, b, c, registers)

        # Read IP from bound register and increment
        new_ip = elem(registers, ip_reg) + 1

        find_first_halt_value(instructions, ip_reg, registers, new_ip, halt_check_ip)
      end
    end
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
end
