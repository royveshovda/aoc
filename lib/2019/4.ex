import AOC

aoc 2019, 4 do
  @moduledoc """
  https://adventofcode.com/2019/day/4
  """

  def p1(input) do
    {min, max} = parse(input)

    min..max
    |> Enum.count(&valid_p1?/1)
  end

  def p2(input) do
    {min, max} = parse(input)

    min..max
    |> Enum.count(&valid_p2?/1)
  end

  defp parse(input) do
    [min, max] =
      input
      |> String.trim()
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)
    {min, max}
  end

  defp valid_p1?(n) do
    digits = Integer.digits(n)
    never_decreases?(digits) and has_adjacent_pair?(digits)
  end

  defp valid_p2?(n) do
    digits = Integer.digits(n)
    never_decreases?(digits) and has_exact_pair?(digits)
  end

  defp never_decreases?(digits) do
    digits == Enum.sort(digits)
  end

  defp has_adjacent_pair?(digits) do
    digits
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.any?(fn [a, b] -> a == b end)
  end

  defp has_exact_pair?(digits) do
    digits
    |> Enum.chunk_by(& &1)
    |> Enum.any?(fn group -> length(group) == 2 end)
  end
end
