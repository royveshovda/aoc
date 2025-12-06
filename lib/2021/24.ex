import AOC

aoc 2021, 24 do
  @moduledoc """
  Day 24: Arithmetic Logic Unit

  Reverse-engineer ALU program (MONAD) to find valid 14-digit model numbers.
  The program has 14 similar blocks that either push or pop from a stack (z register).
  Key insight: Analyze the mathematical structure, don't brute force.
  """

  @doc """
  Part 1: Find the largest valid model number.
  """
  def p1(input) do
    constraints = analyze_program(input)
    solve_constraints(constraints, :max)
  end

  @doc """
  Part 2: Find the smallest valid model number.
  """
  def p2(input) do
    constraints = analyze_program(input)
    solve_constraints(constraints, :min)
  end

  # Analyze the program to extract the key parameters from each of 14 blocks
  # Each block has the pattern:
  # - If div z 1: push (w + add2) onto stack (z = z*26 + w + add2)
  # - If div z 26: pop, check if (popped + add1) == w
  defp analyze_program(input) do
    blocks =
      input
      |> String.split("inp w\n", trim: true)
      |> Enum.map(&parse_block/1)

    # Build constraints by tracking the stack
    {constraints, _stack} =
      Enum.with_index(blocks)
      |> Enum.reduce({[], []}, fn {{div_z, add1, add2}, index}, {constraints, stack} ->
        if div_z == 1 do
          # Push operation
          {constraints, [{index, add2} | stack]}
        else
          # Pop operation - creates a constraint
          [{push_index, push_add2} | rest_stack] = stack
          # Constraint: digit[push_index] + push_add2 + add1 = digit[index]
          # i.e., digit[index] - digit[push_index] = push_add2 + add1
          diff = push_add2 + add1
          {[{push_index, index, diff} | constraints], rest_stack}
        end
      end)

    constraints
  end

  defp parse_block(block) do
    lines = String.split(block, "\n", trim: true)

    # Line 4 (index 3): "div z N" where N is 1 or 26
    div_z = lines |> Enum.at(3) |> String.split() |> List.last() |> String.to_integer()

    # Line 5 (index 4): "add x N" where N is add1
    add1 = lines |> Enum.at(4) |> String.split() |> List.last() |> String.to_integer()

    # Line 15 (index 14): "add y N" where N is add2
    add2 = lines |> Enum.at(14) |> String.split() |> List.last() |> String.to_integer()

    {div_z, add1, add2}
  end

  defp solve_constraints(constraints, mode) do
    # Initialize digits array with nils
    digits = :array.new(14, default: nil)

    # Apply each constraint to find valid digit pairs
    digits =
      Enum.reduce(constraints, digits, fn {i, j, diff}, acc ->
        # diff = digit[j] - digit[i]
        # digit[j] = digit[i] + diff
        # Both must be in 1..9

        {di, dj} =
          case mode do
            :max ->
              # Maximize: try highest digit[i] such that digit[j] is valid
              if diff >= 0 do
                # digit[j] = digit[i] + diff, maximize digit[i]
                # digit[j] <= 9, so digit[i] <= 9 - diff
                di = min(9, 9 - diff)
                {di, di + diff}
              else
                # diff < 0, so digit[j] = digit[i] + diff < digit[i]
                # digit[i] <= 9, digit[j] >= 1
                # digit[i] + diff >= 1, so digit[i] >= 1 - diff
                di = 9
                {di, di + diff}
              end

            :min ->
              # Minimize: try lowest digit[i] such that digit[j] is valid
              if diff >= 0 do
                # digit[j] = digit[i] + diff >= 1 + diff
                # Need digit[j] <= 9, digit[i] >= 1
                di = 1
                {di, di + diff}
              else
                # diff < 0, digit[j] = digit[i] + diff
                # digit[j] >= 1, so digit[i] >= 1 - diff
                di = max(1, 1 - diff)
                {di, di + diff}
              end
          end

        acc
        |> :array.set(i, di)
        |> :array.set(j, dj)
      end)

    digits
    |> :array.to_list()
    |> Enum.join()
    |> String.to_integer()
  end
end
