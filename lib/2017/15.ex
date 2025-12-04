import AOC

aoc 2017, 15 do
  @moduledoc """
  https://adventofcode.com/2017/day/15
  """

  def p1(input) do
    {a_start, b_start} = parse(input)

    Stream.unfold({a_start, b_start}, fn {a, b} ->
      a_next = rem(a * 16807, 2147483647)
      b_next = rem(b * 48271, 2147483647)
      {{a_next, b_next}, {a_next, b_next}}
    end)
    |> Stream.take(40_000_000)
    |> Enum.count(fn {a, b} -> Bitwise.band(a, 0xFFFF) == Bitwise.band(b, 0xFFFF) end)
  end

  def p2(input) do
    {a_start, b_start} = parse(input)

    a_stream =
      Stream.unfold(a_start, fn a ->
        a_next = rem(a * 16807, 2147483647)
        if rem(a_next, 4) == 0, do: {a_next, a_next}, else: {nil, a_next}
      end)
      |> Stream.reject(&is_nil/1)

    b_stream =
      Stream.unfold(b_start, fn b ->
        b_next = rem(b * 48271, 2147483647)
        if rem(b_next, 8) == 0, do: {b_next, b_next}, else: {nil, b_next}
      end)
      |> Stream.reject(&is_nil/1)

    Stream.zip(a_stream, b_stream)
    |> Stream.take(5_000_000)
    |> Enum.count(fn {a, b} -> Bitwise.band(a, 0xFFFF) == Bitwise.band(b, 0xFFFF) end)
  end

  defp parse(input) do
    [a, b] =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [_, num] = String.split(line, " starts with ")
        String.to_integer(num)
      end)

    {a, b}
  end
end
