import AOC

aoc 2023, 7 do
  @moduledoc """
  https://adventofcode.com/2023/day/7
  """

  @card_values_p1 %{"A" => 14, "K" => 13, "Q" => 12, "J" => 11, "T" => 10,
                    "9" => 9, "8" => 8, "7" => 7, "6" => 6, "5" => 5,
                    "4" => 4, "3" => 3, "2" => 2}
  
  @card_values_p2 %{"A" => 14, "K" => 13, "Q" => 12, "J" => 1, "T" => 10,
                    "9" => 9, "8" => 8, "7" => 7, "6" => 6, "5" => 5,
                    "4" => 4, "3" => 3, "2" => 2}

  @doc """
      iex> p1(example_string())
      6440

      iex> p1(input_string())
      246912307
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(fn {hand, bid} -> {hand_type(hand), card_values(hand, @card_values_p1), bid} end)
    |> Enum.sort_by(fn {type, values, _} -> {type, values} end)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, _, bid}, rank} -> bid * rank end)
    |> Enum.sum()
  end

  @doc """
      iex> p2(example_string())
      5905

      iex> p2(input_string())
      246894760
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.map(fn {hand, bid} -> {hand_type_with_jokers(hand), card_values(hand, @card_values_p2), bid} end)
    |> Enum.sort_by(fn {type, values, _} -> {type, values} end)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, _, bid}, rank} -> bid * rank end)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [hand, bid] = String.split(line)
      {String.graphemes(hand), String.to_integer(bid)}
    end)
  end

  defp card_values(hand, values_map) do
    Enum.map(hand, &Map.get(values_map, &1))
  end

  defp hand_type(hand) do
    counts = hand |> Enum.frequencies() |> Map.values() |> Enum.sort(:desc)
    
    case counts do
      [5] -> 7           # Five of a kind
      [4, 1] -> 6        # Four of a kind
      [3, 2] -> 5        # Full house
      [3, 1, 1] -> 4     # Three of a kind
      [2, 2, 1] -> 3     # Two pair
      [2, 1, 1, 1] -> 2  # One pair
      _ -> 1             # High card
    end
  end

  defp hand_type_with_jokers(hand) do
    joker_count = Enum.count(hand, &(&1 == "J"))
    
    if joker_count == 5 do
      7  # Five of a kind
    else
      non_joker_counts = hand
      |> Enum.reject(&(&1 == "J"))
      |> Enum.frequencies()
      |> Map.values()
      |> Enum.sort(:desc)
      
      # Add jokers to the highest count
      [highest | rest] = non_joker_counts
      counts = [highest + joker_count | rest]
      
      case counts do
        [5] -> 7
        [4, 1] -> 6
        [3, 2] -> 5
        [3, 1, 1] -> 4
        [2, 2, 1] -> 3
        [2, 1, 1, 1] -> 2
        _ -> 1
      end
    end
  end
end
