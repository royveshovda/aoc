import AOC

aoc 2015, 17 do
  @moduledoc """
  https://adventofcode.com/2015/day/17

  Day 17: No Such Thing as Too Much

  Find how many different combinations of containers can exactly fit 150 liters.

  ## Example
      iex> input = "20\\n15\\n10\\n5\\n5"
      iex> Y2015.D17.p1(input, 25)
      4
  """

  def p1(input, target \\ 150) do
    containers = parse_input(input)

    # Generate all possible combinations and count those that sum to target
    count_combinations(containers, target)
  end

  def p2(input, target \\ 150) do
    containers = parse_input(input)

    # Find all valid combinations
    valid_combinations = find_all_combinations(containers, target)

    # Find the minimum number of containers used
    min_containers = valid_combinations
    |> Enum.map(&length/1)
    |> Enum.min()

    # Count how many combinations use the minimum number of containers
    valid_combinations
    |> Enum.count(fn combo -> length(combo) == min_containers end)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp count_combinations(containers, target) do
    find_all_combinations(containers, target)
    |> length()
  end

  defp find_all_combinations(containers, target) do
    # Generate all possible subsets and filter those that sum to target
    containers
    |> power_set()
    |> Enum.filter(fn subset ->
      Enum.sum(subset) == target
    end)
  end

  # Generate all subsets (power set) of a list
  defp power_set([]), do: [[]]
  defp power_set([h | t]) do
    rest = power_set(t)
    rest ++ Enum.map(rest, fn subset -> [h | subset] end)
  end
end
