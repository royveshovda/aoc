import AOC

aoc 2018, 19 do
  @moduledoc """
  https://adventofcode.com/2018/day/19

  Day 19: Go With The Flow - Instruction pointer with flow control
  """

  @doc """
  Part 1: Execute program with IP bound to register, starting with register 0 = 0

  ## Examples

      iex> input = "#ip 0\\nseti 5 0 1\\nseti 6 0 2\\naddi 0 1 0\\naddr 1 2 3\\nsetr 1 0 0\\nseti 8 0 4\\nseti 9 0 5"
      iex> p1(input)
      6
  """
  def p1(input) do
    {ip_reg, instructions} = parse_input(input)
    registers = {0, 0, 0, 0, 0, 0}

    result = execute(instructions, ip_reg, registers, 0)
    elem(result, 0)
  end

  @doc """
  Part 2: Execute program starting with register 0 = 1
  This will take too long to simulate - need to reverse engineer what the program does
  """
  def p2(input) do
    {ip_reg, instructions} = parse_input(input)
    registers = {1, 0, 0, 0, 0, 0}

    # Run a few iterations to let the program initialize
    result = execute_limited(instructions, ip_reg, registers, 0, 100)

    # The program computes sum of divisors of a large number
    # Find that number (it's in register 3 after initialization)
    target = elem(result, 3)

    # Calculate sum of divisors
    sum_of_divisors(target)
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

  defp execute(instructions, ip_reg, registers, ip) do
    if ip < 0 or ip >= tuple_size(instructions) do
      registers
    else
      # Write IP to bound register
      registers = put_elem(registers, ip_reg, ip)

      # Execute instruction
      {op, a, b, c} = elem(instructions, ip)
      registers = execute_op(op, a, b, c, registers)

      # Read IP from bound register and increment
      new_ip = elem(registers, ip_reg) + 1

      execute(instructions, ip_reg, registers, new_ip)
    end
  end

  defp execute_limited(instructions, ip_reg, registers, ip, max_iterations) do
    if max_iterations <= 0 or ip < 0 or ip >= tuple_size(instructions) do
      registers
    else
      # Write IP to bound register
      registers = put_elem(registers, ip_reg, ip)

      # Execute instruction
      {op, a, b, c} = elem(instructions, ip)
      registers = execute_op(op, a, b, c, registers)

      # Read IP from bound register and increment
      new_ip = elem(registers, ip_reg) + 1

      execute_limited(instructions, ip_reg, registers, new_ip, max_iterations - 1)
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

  defp sum_of_divisors(n) do
    1..n
    |> Enum.filter(fn i -> rem(n, i) == 0 end)
    |> Enum.sum()
  end
end
