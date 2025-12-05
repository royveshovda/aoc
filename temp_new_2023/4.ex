import AOC

aoc 2023, 4 do
  @moduledoc """
  https://adventofcode.com/2023/day/4
  """

  @doc """
      iex> p1(example_string())
      13

      iex> p1(input_string())
      23847
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  @doc """
      iex> p2(example_string())
      30

      iex> p2(input_string())
      8570000
  """
  def p2(input) do
    cards = parse(input)
    counts = cards |> Enum.with_index(1) |> Enum.map(fn {_, i} -> {i, 1} end) |> Map.new()
    
    cards
    |> Enum.with_index(1)
    |> Enum.reduce(counts, fn {card, idx}, acc ->
      matches = count_matches(card)
      card_count = acc[idx]
      
      if matches > 0 do
        Enum.reduce((idx + 1)..(idx + matches), acc, fn j, acc2 ->
          Map.update(acc2, j, card_count, &(&1 + card_count))
        end)
      else
        acc
      end
    end)
    |> Map.values()
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_card/1)
  end

  defp parse_card(line) do
    [_, numbers] = String.split(line, ": ")
    [winning, have] = String.split(numbers, " | ")
    
    winning_nums = winning |> String.split() |> Enum.map(&String.to_integer/1) |> MapSet.new()
    have_nums = have |> String.split() |> Enum.map(&String.to_integer/1) |> MapSet.new()
    
    {winning_nums, have_nums}
  end

  defp count_matches({winning, have}) do
    MapSet.intersection(winning, have) |> MapSet.size()
  end

  defp score(card) do
    matches = count_matches(card)
    if matches == 0, do: 0, else: Integer.pow(2, matches - 1)
  end
end
