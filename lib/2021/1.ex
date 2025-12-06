import AOC

aoc 2021, 1 do
  @moduledoc """
  Day 1: Sonar Sweep

  Count how many times depth measurements increase.
  Part 1: Compare consecutive measurements
  Part 2: Use sliding window of 3 measurements
  """

  @doc """
  Part 1: Count how many measurements are larger than the previous measurement.

  ## Examples

      iex> p1("199\\n200\\n208\\n210\\n200\\n207\\n240\\n269\\n260\\n263")
      7
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.count(fn [a, b] -> b > a end)
  end

  @doc """
  Part 2: Count increases using a sliding window of 3 measurements.
  Insight: Comparing a+b+c vs b+c+d simplifies to comparing a vs d.

  ## Examples

      iex> p2("199\\n200\\n208\\n210\\n200\\n207\\n240\\n269\\n260\\n263")
      5
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.chunk_every(4, 1, :discard)
    |> Enum.count(fn [a, _, _, d] -> d > a end)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
