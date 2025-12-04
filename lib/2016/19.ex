import AOC

aoc 2016, 19 do
  @moduledoc """
  https://adventofcode.com/2016/day/19
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    n = String.trim(input) |> String.to_integer()
    josephus_standard(n)
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    n = String.trim(input) |> String.to_integer()
    josephus_across(n)
  end

  # Standard Josephus problem - steal from left neighbor
  # Formula: J(n) = 2 * L + 1, where n = 2^m + L and 0 <= L < 2^m
  defp josephus_standard(n) do
    import Bitwise
    p = :math.log2(n) |> floor() |> then(&(1 <<< &1))
    l = n - p
    2 * l + 1
  end

  # Modified Josephus - steal from elf directly across
  defp josephus_across(n) do
    p = :math.log(n) / :math.log(3) |> floor() |> then(&(round(:math.pow(3, &1))))
    if n == p do
      n
    else
      if n <= 2 * p do
        n - p
      else
        2 * n - 3 * p
      end
    end
  end
end
