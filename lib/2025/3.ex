import AOC

aoc 2025, 3 do
  @moduledoc """
  https://adventofcode.com/2025/day/3
  """

  @doc """
      iex> p1(example_string(0))
      357
  """
  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&find_max_joltage/1)
    |> Enum.sum()
  end

  defp find_max_joltage(bank) do
    digits = String.graphemes(bank) |> Enum.map(&String.to_integer/1)

    # Try all pairs of positions (i, j) where i < j
    # Calculate the 2-digit number formed by digits[i] and digits[j]
    for i <- 0..(length(digits) - 2),
        j <- (i + 1)..(length(digits) - 1) do
      first = Enum.at(digits, i)
      second = Enum.at(digits, j)
      first * 10 + second
    end
    |> Enum.max()
  end

  @doc """
      iex> p2(example_string(0))
      3121910778619
  """
  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&find_max_joltage_12/1)
    |> Enum.sum()
  end

  defp find_max_joltage_12(bank) do
    digits = String.graphemes(bank) |> Enum.map(&String.to_integer/1)

    # Greedy approach: for each position in the 12-digit result,
    # pick the largest digit from the remaining batteries
    # ensuring we can still pick enough batteries for the remaining positions

    selected = select_batteries_greedy(digits, 12)
    Integer.undigits(selected)
  end

  defp select_batteries_greedy(digits, target_count) do
    do_select_greedy(digits, target_count, 0, [])
  end

  defp do_select_greedy(_digits, 0, _pos, acc), do: Enum.reverse(acc)
  defp do_select_greedy(digits, remaining, pos, acc) do
    available = length(digits) - pos

    # We need to leave at least (remaining - 1) batteries after this choice
    # So we can look ahead at most (available - remaining + 1) positions
    max_lookahead = available - remaining + 1

    # Find the best digit within our lookahead window
    {best_digit, best_offset} =
      0..(max_lookahead - 1)
      |> Enum.map(fn offset -> {Enum.at(digits, pos + offset), offset} end)
      |> Enum.max_by(fn {digit, _offset} -> digit end)

    # Move to the position after the selected battery
    do_select_greedy(digits, remaining - 1, pos + best_offset + 1, [best_digit | acc])
  end
end
