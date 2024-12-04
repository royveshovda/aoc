import AOC

aoc 2023, 7 do
  @moduledoc """
  https://adventofcode.com/2023/day/7
  """

  @doc """
      iex> p1(example_string())
      6440

      iex> p1(input_string())
      246912307
  """
  def p1(input) do
    hands =
      input
      |> parse()
      |> Enum.map(fn %{cards: cards, bid: bid} ->
        %{cards: cards, bid: bid, hand_type: get_hand_type(cards)}
      end)


    res =
      Enum.sort_by(hands, fn hand -> hand end, &left_hand_less_than_or_equal/2)
      |> Enum.with_index(1)
      |> Enum.map(fn {hand, index} -> hand.bid * index end)
      |> Enum.sum()

    res
  end

  def left_hand_less_than_or_equal(left_hand, right_hand) do
    case compare_types(left_hand.hand_type, right_hand.hand_type) do
      :left_hand_wins -> false
      :right_hand_wins -> true
      :tie ->
        case compare_cards(left_hand.cards, right_hand.cards) do
          :left_hand_wins -> false
          :right_hand_wins -> true
          :tie -> true
        end
    end
  end

  def compare_cards(left_hand_cards, right_hand_cards) do
    left_hand_cards
    |> Enum.map(fn {_pos, value} -> value end)
    |> Enum.zip(right_hand_cards |> Enum.map(fn {_pos, value} -> value end))
    |> Enum.reduce_while(:tie, fn {left_hand_card, right_hand_card}, acc ->
      case left_hand_card do
        _ when left_hand_card > right_hand_card -> {:halt, :left_hand_wins}
        _ when left_hand_card < right_hand_card -> {:halt, :right_hand_wins}
        _ -> {:cont, acc}
      end
    end)
  end

  def compare_types(left_hand_type, right_hand_type) do
    left_hand_type_rank = get_type_rank(left_hand_type)
    right_hand_type_rank = get_type_rank(right_hand_type)
    case left_hand_type_rank do
      _ when left_hand_type_rank < right_hand_type_rank -> :left_hand_wins
      _ when left_hand_type_rank > right_hand_type_rank -> :right_hand_wins
      _ -> :tie
    end
  end

  def get_type_rank(hand_type) do
    case hand_type do
      :five_of_a_kind -> 1
      :four_of_a_kind -> 2
      :full_house -> 3
      :three_of_a_kind -> 4
      :two_pairs -> 5
      :one_pair -> 6
      :high_card -> 7
    end
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [cards_s, bid] = String.split(line, " ", trim: true)
      [c1, c2, c3, c4, c5] = String.graphemes(cards_s)
      bid = String.to_integer(bid)
      %{cards: %{c1: get_card_value(c1), c2: get_card_value(c2), c3: get_card_value(c3), c4: get_card_value(c4), c5: get_card_value(c5)}, bid: bid}
    end)
  end

  def get_card_value(card) do
    case card do
      "A" -> 14
      "K" -> 13
      "Q" -> 12
      "J" -> 11
      "T" -> 10
      _ -> String.to_integer(card)
    end
  end

  def get_hand_type(cards) do
    cond do
      is_five_of_a_kind?(cards) -> :five_of_a_kind
      is_four_of_a_kind?(cards) -> :four_of_a_kind
      is_full_house?(cards) -> :full_house
      is_three_of_a_kind?(cards) -> :three_of_a_kind
      is_two_pairs?(cards) -> :two_pairs
      is_one_pair?(cards) -> :one_pair
      true -> :high_card
    end
  end

  def is_five_of_a_kind?(cards) do
    cards
    |> Enum.map(fn {_pos, value} -> value end)
    |> Enum.group_by(& &1)
    |> Enum.any?(fn {_, list} -> length(list) == 5 end)
  end

  def is_four_of_a_kind?(cards) do
    cards
    |> Enum.map(fn {_pos, value} -> value end)
    |> Enum.group_by(& &1)
    |> Enum.any?(fn {_, list} -> length(list) == 4 end)
  end

  def is_full_house?(cards) do
    cards
    |> Enum.map(fn {_pos, value} -> value end)
    |> Enum.group_by(& &1)
    |> Enum.any?(fn {_, list} -> length(list) == 3 end)
    and
    cards
    |> Enum.map(fn {_pos, value} -> value end)
    |> Enum.group_by(& &1)
    |> Enum.any?(fn {_, list} -> length(list) == 2 end)
  end

  def is_three_of_a_kind?(cards) do
    cards
    |> Enum.map(fn {_pos, value} -> value end)
    |> Enum.group_by(& &1)
    |> Enum.any?(fn {_, list} -> length(list) == 3 end)
  end

  def is_two_pairs?(cards) do
    cards
    |> Enum.map(fn {_pos, value} -> value end)
    |> Enum.group_by(& &1)
    |> Enum.filter(fn {_, list} -> length(list) == 2 end)
    |> length() == 2
  end

  def is_one_pair?(cards) do
    cards
    |> Enum.map(fn {_pos, value} -> value end)
    |> Enum.group_by(& &1)
    |> Enum.any?(fn {_, list} -> length(list) == 2 end)
  end

  @doc """
      iex> p2(example_string())
      5905

      iex> p2(input_string())
      246894760
  """
  def p2(input) do
    hands =
      input
      |> parse_p2()
      |> Enum.map(fn %{cards: cards, bid: bid} ->
        %{cards: cards, bid: bid, hand_type: get_hand_type_p2(cards)}
      end)

      res =
        Enum.sort_by(hands, fn hand -> hand end, &left_hand_less_than_or_equal/2)
        |> Enum.with_index(1)
        |> Enum.map(fn {hand, index} -> hand.bid * index end)
        |> Enum.sum()

      res

  end

  def parse_p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [cards_s, bid] = String.split(line, " ", trim: true)
      [c1, c2, c3, c4, c5] = String.graphemes(cards_s)
      bid = String.to_integer(bid)
      %{cards: %{c1: get_card_value_p2(c1), c2: get_card_value_p2(c2), c3: get_card_value_p2(c3), c4: get_card_value_p2(c4), c5: get_card_value_p2(c5)}, bid: bid}
    end)
  end

  def get_card_value_p2(card) do
    case card do
      "A" -> 14
      "K" -> 13
      "Q" -> 12
      "J" -> 1
      "T" -> 10
      _ -> String.to_integer(card)
    end
  end

  def get_hand_type_p2(cards) do
    versions =
      for c1 <- expand_card(cards.c1), c2 <- expand_card(cards.c2), c3 <- expand_card(cards.c3), c4 <- expand_card(cards.c4), c5 <- expand_card(cards.c5), do: %{c1: c1, c2: c2, c3: c3, c4: c4, c5: c5}

    [res] =
      versions
      |> Enum.map(fn crds ->
        %{cards: cards, hand_type: get_hand_type(crds)}
      end)
      |> Enum.sort_by(fn hand -> hand end, &left_hand_less_than_or_equal/2)
      |> Enum.reverse()
      |> Enum.take(1)

    res.hand_type
  end

  def expand_card(card) do
    case card do
      1 -> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14]
      2 -> [2]
      3 -> [3]
      4 -> [4]
      5 -> [5]
      6 -> [6]
      7 -> [7]
      8 -> [8]
      9 -> [9]
      10 -> [10]
      12 -> [12]
      13 -> [13]
      14 -> [14]
    end
  end
end
