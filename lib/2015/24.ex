import AOC

aoc 2015, 24 do
  @moduledoc """
  https://adventofcode.com/2015/day/24

  Day 24: It Hangs in the Balance

  Partition packages into groups of equal weight, minimizing the first group's size
  and quantum entanglement (product of weights).
  """

  def p1(input) do
    packages = parse_input(input)
    find_ideal_quantum_entanglement(packages, 3)
  end

  def p2(input) do
    packages = parse_input(input)
    find_ideal_quantum_entanglement(packages, 4)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp find_ideal_quantum_entanglement(packages, num_groups) do
    total_weight = Enum.sum(packages)
    target_weight = div(total_weight, num_groups)

    # Find smallest group size that can reach target weight
    # Then find minimum quantum entanglement for that size
    1..length(packages)
    |> Enum.find_value(fn size ->
      combinations = combinations(packages, size)

      valid_groups = combinations
      |> Enum.filter(fn combo -> Enum.sum(combo) == target_weight end)

      if Enum.empty?(valid_groups) do
        nil
      else
        # Return minimum quantum entanglement for this group size
        valid_groups
        |> Enum.map(&quantum_entanglement/1)
        |> Enum.min()
      end
    end)
  end

  defp quantum_entanglement(packages) do
    Enum.reduce(packages, 1, &(&1 * &2))
  end

  # Generate all combinations of size n from list
  defp combinations(_, 0), do: [[]]
  defp combinations([], _), do: []
  defp combinations([h | t], n) do
    (for combo <- combinations(t, n - 1), do: [h | combo]) ++ combinations(t, n)
  end
end
