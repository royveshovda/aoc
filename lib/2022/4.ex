import AOC

aoc 2022, 4 do
  @moduledoc """
  Day 4: Camp Cleanup

  Find overlapping section assignment ranges.
  Part 1: Count pairs where one fully contains other.
  Part 2: Count pairs with any overlap.
  """

  @doc """
  Part 1: Count pairs where one range fully contains the other.

  ## Examples

      iex> example = \"\"\"
      ...> 2-4,6-8
      ...> 2-3,4-5
      ...> 5-7,7-9
      ...> 2-8,3-7
      ...> 6-6,4-6
      ...> 2-6,4-8
      ...> \"\"\"
      iex> p1(example)
      2
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.count(&fully_contains?/1)
  end

  @doc """
  Part 2: Count pairs with any overlap.

  ## Examples

      iex> example = \"\"\"
      ...> 2-4,6-8
      ...> 2-3,4-5
      ...> 5-7,7-9
      ...> 2-8,3-7
      ...> 6-6,4-6
      ...> 2-6,4-8
      ...> \"\"\"
      iex> p2(example)
      4
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.count(&overlaps?/1)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [a, b, c, d] =
        Regex.scan(~r/\d+/, line)
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)

      {{a, b}, {c, d}}
    end)
  end

  # Check if one range fully contains the other
  defp fully_contains?({{a1, a2}, {b1, b2}}) do
    (a1 <= b1 and a2 >= b2) or (b1 <= a1 and b2 >= a2)
  end

  # Check if ranges have any overlap
  defp overlaps?({{a1, a2}, {b1, b2}}) do
    not (a2 < b1 or b2 < a1)
  end
end
