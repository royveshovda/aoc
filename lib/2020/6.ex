import AOC

aoc 2020, 6 do
  @moduledoc """
  https://adventofcode.com/2020/day/6

  Custom Customs - Count yes answers in groups (union/intersection).
  """

  @doc """
  Count questions where anyone answered yes (union).

  ## Examples

      iex> p1("abcx\\nabcy\\nabcz")
      6

      iex> p1("abc\\n\\na\\nb\\nc\\n\\nab\\nac\\n\\na\\na\\na\\na\\n\\nb")
      11
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(&union_count/1)
    |> Enum.sum()
  end

  @doc """
  Count questions where everyone answered yes (intersection).

  ## Examples

      iex> p2("abc\\n\\na\\nb\\nc\\n\\nab\\nac\\n\\na\\na\\na\\na\\n\\nb")
      6
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.map(&intersection_count/1)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn group ->
      group
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(&MapSet.new/1)
    end)
  end

  defp union_count(group) do
    group
    |> Enum.reduce(&MapSet.union/2)
    |> MapSet.size()
  end

  defp intersection_count(group) do
    group
    |> Enum.reduce(&MapSet.intersection/2)
    |> MapSet.size()
  end
end
