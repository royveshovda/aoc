import AOC

aoc 2021, 3 do
  @moduledoc """
  Day 3: Binary Diagnostic

  Analyze binary diagnostic numbers.
  Part 1: Find most/least common bit in each position (gamma/epsilon)
  Part 2: Filter by bit criteria until one number remains (O2/CO2)
  """

  @doc """
  Part 1: Calculate gamma (most common bits) and epsilon (least common bits).
  Return: gamma * epsilon

  ## Examples

      iex> p1("00100\\n11110\\n10110\\n10111\\n10101\\n01111\\n00111\\n11100\\n10000\\n11001\\n00010\\n01010")
      198
  """
  def p1(input) do
    numbers = parse(input)
    width = numbers |> hd() |> length()

    gamma_bits =
      for pos <- 0..(width - 1) do
        most_common_bit(numbers, pos)
      end

    epsilon_bits = Enum.map(gamma_bits, &flip/1)

    gamma = bits_to_int(gamma_bits)
    epsilon = bits_to_int(epsilon_bits)

    gamma * epsilon
  end

  @doc """
  Part 2: Filter numbers by bit criteria.
  - O2: Keep numbers with most common bit (prefer 1 on tie)
  - CO2: Keep numbers with least common bit (prefer 0 on tie)
  Return: O2 * CO2

  ## Examples

      iex> p2("00100\\n11110\\n10110\\n10111\\n10101\\n01111\\n00111\\n11100\\n10000\\n11001\\n00010\\n01010")
      230
  """
  def p2(input) do
    numbers = parse(input)

    o2 = filter_by_criteria(numbers, 0, :most_common)
    co2 = filter_by_criteria(numbers, 0, :least_common)

    bits_to_int(o2) * bits_to_int(co2)
  end

  defp filter_by_criteria([number], _pos, _criteria), do: number

  defp filter_by_criteria(numbers, pos, criteria) do
    target_bit =
      case criteria do
        :most_common -> most_common_bit_with_tie(numbers, pos, 1)
        :least_common -> most_common_bit_with_tie(numbers, pos, 1) |> flip()
      end

    filtered = Enum.filter(numbers, fn bits -> Enum.at(bits, pos) == target_bit end)
    filter_by_criteria(filtered, pos + 1, criteria)
  end

  defp most_common_bit(numbers, pos) do
    bits = Enum.map(numbers, &Enum.at(&1, pos))
    ones = Enum.count(bits, &(&1 == 1))
    zeros = length(bits) - ones
    if ones >= zeros, do: 1, else: 0
  end

  defp most_common_bit_with_tie(numbers, pos, tie_value) do
    bits = Enum.map(numbers, &Enum.at(&1, pos))
    ones = Enum.count(bits, &(&1 == 1))
    zeros = length(bits) - ones

    cond do
      ones > zeros -> 1
      zeros > ones -> 0
      true -> tie_value
    end
  end

  defp flip(0), do: 1
  defp flip(1), do: 0

  defp bits_to_int(bits) do
    bits
    |> Enum.join()
    |> String.to_integer(2)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
