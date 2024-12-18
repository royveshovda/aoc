import AOC
import Bitwise

aoc 2024, 17 do
  @moduledoc """
  https://adventofcode.com/2024/day/17
  """

  def p1(input) do
    [registers_raw, program_raw] =
      input
      |> String.split("\n\n", trim: true)

    [reg_a, _reg_b, _reg_c] =
      registers_raw
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ": ", trim: true))
      |> Enum.map(fn [_k, v] -> String.to_integer(v) end)


    [_, program_raw] =
      program_raw
      |> String.trim()
      |> String.split(": ", trim: true)

    program =
      program_raw
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)


    result = run(program, reg_a)
    Enum.join(result, ",")
  end

  def p2(input) do
    [registers_raw, program_raw] =
      input
      |> String.split("\n\n", trim: true)

    [reg_a, _reg_b, _reg_c] =
      registers_raw
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ": ", trim: true))
      |> Enum.map(fn [_k, v] -> String.to_integer(v) end)


    [_, program_raw] =
      program_raw
      |> String.trim()
      |> String.split(": ", trim: true)

    program =
      program_raw
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    target = Enum.reverse(program)
    find_a(program, target)
  end

  def run(prog, a) do
    process(prog, a, 0, 0, 0, [])
  end

  defp process(prog, _a, _b, _c, ip, out) when ip < 0 or ip >= length(prog), do: out
  # Process instructions with a state machine
  defp process(prog, a, b, c, ip, out) do
    table = [0, 1, 2, 3, a, b, c]
    operand = Enum.at(prog, ip + 1, 0)
    combo = Enum.at(table, operand, 0)

    case Enum.at(prog, ip) do
      0 -> process(prog, a >>> combo, b, c, ip + 2, out)
      1 -> process(prog, a, Bitwise.bxor(b, operand), c, ip + 2, out)
      2 -> process(prog, a, rem(combo, 8), c, ip + 2, out)
      3 -> process(prog, a, b, c, if(a == 0, do: ip + 2, else: operand), out)
      4 -> process(prog, a, Bitwise.bxor(b, c), c, ip + 2, out)
      5 -> process(prog, a, b, c, ip + 2, List.insert_at(out, -1, rem(combo, 8)))
      6 -> process(prog, a, a >>> combo, c, ip + 2, out)
      7 -> process(prog, a, b, a >>> combo, ip + 2, out)
      _ -> out
    end
  end

  # Part 2 - Recursive search for finding A
  def find_a(prog, target) do
    search_a(prog, target, 0, 0)
  end

  defp search_a(_prog, target, a, depth) when depth == length(target), do: a

  defp search_a(prog, target, a, depth) do
    Enum.find_value(0..7, fn i ->
      output = run(prog, a * 8 + i)
      if output != [] and hd(output) == Enum.at(target, depth) do
        result = search_a(prog, target, a * 8 + i, depth + 1)
        if result != 0, do: result, else: nil
      else
        nil
      end
    end) || nil
  end
end
