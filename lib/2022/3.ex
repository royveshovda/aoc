import AOC

aoc 2022, 3 do
  @moduledoc """
  Day 3: Rucksack Reorganization

  Find common items in rucksack compartments.
  Priority: a-z = 1-26, A-Z = 27-52.
  Part 2: Find badge (common item) in groups of 3 elves.
  """

  @doc """
  Part 1: Sum priorities of items in both compartments.

  ## Examples

      iex> example = \"\"\"
      ...> vJrwpWtwJgWrhcsFMMfFFhFp
      ...> jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
      ...> PmmdzqPrVvPwwTWBwg
      ...> wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
      ...> ttgJtRGJQctTZtZT
      ...> CrZsJsPPZsGzwwsLwLmpwMDw
      ...> \"\"\"
      iex> p1(example)
      157
  """
  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&find_common_in_halves/1)
    |> Enum.map(&priority/1)
    |> Enum.sum()
  end

  @doc """
  Part 2: Sum priorities of badges (common items in groups of 3).

  ## Examples

      iex> example = \"\"\"
      ...> vJrwpWtwJgWrhcsFMMfFFhFp
      ...> jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
      ...> PmmdzqPrVvPwwTWBwg
      ...> wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
      ...> ttgJtRGJQctTZtZT
      ...> CrZsJsPPZsGzwwsLwLmpwMDw
      ...> \"\"\"
      iex> p2(example)
      70
  """
  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(&find_common_in_group/1)
    |> Enum.map(&priority/1)
    |> Enum.sum()
  end

  defp find_common_in_halves(line) do
    len = String.length(line)
    half = div(len, 2)
    {first, second} = String.split_at(line, half)

    first_set = first |> String.graphemes() |> MapSet.new()
    second_set = second |> String.graphemes() |> MapSet.new()

    MapSet.intersection(first_set, second_set)
    |> MapSet.to_list()
    |> hd()
  end

  defp find_common_in_group([a, b, c]) do
    set_a = a |> String.graphemes() |> MapSet.new()
    set_b = b |> String.graphemes() |> MapSet.new()
    set_c = c |> String.graphemes() |> MapSet.new()

    set_a
    |> MapSet.intersection(set_b)
    |> MapSet.intersection(set_c)
    |> MapSet.to_list()
    |> hd()
  end

  defp priority(<<char>>) when char >= ?a and char <= ?z, do: char - ?a + 1
  defp priority(<<char>>) when char >= ?A and char <= ?Z, do: char - ?A + 27
end
