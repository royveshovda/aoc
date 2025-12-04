import AOC

aoc 2017, 4 do
  @moduledoc """
  https://adventofcode.com/2017/day/4
  """

  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.count(&valid_passphrase?/1)
  end

  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.count(&valid_passphrase_no_anagrams?/1)
  end

  defp valid_passphrase?(line) do
    words = String.split(line)
    length(words) == length(Enum.uniq(words))
  end

  defp valid_passphrase_no_anagrams?(line) do
    words = line |> String.split() |> Enum.map(&(String.graphemes(&1) |> Enum.sort() |> Enum.join()))
    length(words) == length(Enum.uniq(words))
  end
end
