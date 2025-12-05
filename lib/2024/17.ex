import AOC
import Bitwise

aoc 2024, 17 do
  @moduledoc """
  https://adventofcode.com/2024/day/17

  Chronospatial Computer - 3-bit computer VM.
  P1: Run program, return output.
  P2: Find initial A that makes program output itself (quine).
  """

  def p1(input) do
    {a, b, c, program} = parse(input)
    run(program, 0, a, b, c, [])
    |> Enum.reverse()
    |> Enum.join(",")
  end

  def p2(input) do
    {_a, _b, _c, program} = parse(input)
    # Work backwards - program outputs 3 bits at a time based on A
    # Each iteration: output depends on low 3 bits of A, then A = A >>> 3
    # So build A by finding each 3-bit chunk from the end
    find_a(program, Enum.reverse(program), 0)
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)

    a =
      Enum.at(lines, 0)
      |> String.split(": ")
      |> List.last()
      |> String.to_integer()

    b =
      Enum.at(lines, 1)
      |> String.split(": ")
      |> List.last()
      |> String.to_integer()

    c =
      Enum.at(lines, 2)
      |> String.split(": ")
      |> List.last()
      |> String.to_integer()

    program =
      Enum.at(lines, 3)
      |> String.split(": ")
      |> List.last()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    {a, b, c, program}
  end

  defp run(program, ip, a, b, c, output) do
    if ip >= length(program) do
      output
    else
      opcode = Enum.at(program, ip)
      operand = Enum.at(program, ip + 1)

      case opcode do
        0 ->
          # adv: A = A / 2^combo
          val = combo(operand, a, b, c)
          a = a >>> val
          run(program, ip + 2, a, b, c, output)

        1 ->
          # bxl: B = B XOR literal
          b = bxor(b, operand)
          run(program, ip + 2, a, b, c, output)

        2 ->
          # bst: B = combo mod 8
          val = combo(operand, a, b, c)
          b = rem(val, 8)
          run(program, ip + 2, a, b, c, output)

        3 ->
          # jnz: jump if A != 0
          if a != 0 do
            run(program, operand, a, b, c, output)
          else
            run(program, ip + 2, a, b, c, output)
          end

        4 ->
          # bxc: B = B XOR C
          b = bxor(b, c)
          run(program, ip + 2, a, b, c, output)

        5 ->
          # out: output combo mod 8
          val = combo(operand, a, b, c)
          out = rem(val, 8)
          run(program, ip + 2, a, b, c, [out | output])

        6 ->
          # bdv: B = A / 2^combo
          val = combo(operand, a, b, c)
          b = a >>> val
          run(program, ip + 2, a, b, c, output)

        7 ->
          # cdv: C = A / 2^combo
          val = combo(operand, a, b, c)
          c = a >>> val
          run(program, ip + 2, a, b, c, output)
      end
    end
  end

  defp combo(op, a, b, c) do
    case op do
      0 -> 0
      1 -> 1
      2 -> 2
      3 -> 3
      4 -> a
      5 -> b
      6 -> c
    end
  end

  # Find A that produces the program as output
  # Build from the last output digit backward
  defp find_a(_program, [], a), do: a

  defp find_a(program, [_target | rest], a) do
    # Try each 3-bit value (0-7) for the next chunk
    0..7
    |> Enum.find_value(fn candidate ->
      new_a = a * 8 + candidate
      output = run(program, 0, new_a, 0, 0, []) |> Enum.reverse()

      # Check if output matches the suffix we need
      expected = Enum.drop(program, length(rest))

      if output == expected do
        find_a(program, rest, new_a)
      end
    end)
  end
end
