import AOC

aoc 2020, 22 do
  @moduledoc """
  https://adventofcode.com/2020/day/22

  Crab Combat - Card game with recursive sub-games.

  ## Examples

      iex> example = "Player 1:\\n9\\n2\\n6\\n3\\n1\\n\\nPlayer 2:\\n5\\n8\\n4\\n7\\n10"
      iex> Y2020.D22.p1(example)
      306

      iex> example = "Player 1:\\n9\\n2\\n6\\n3\\n1\\n\\nPlayer 2:\\n5\\n8\\n4\\n7\\n10"
      iex> Y2020.D22.p2(example)
      291
  """

  def p1(input) do
    {deck1, deck2} = parse(input)
    winner_deck = play_combat(deck1, deck2)
    score(winner_deck)
  end

  def p2(input) do
    {deck1, deck2} = parse(input)
    {_winner, winner_deck} = play_recursive_combat(deck1, deck2, MapSet.new())
    score(winner_deck)
  end

  defp parse(input) do
    [p1, p2] = String.split(input, "\n\n", trim: true)

    deck1 =
      p1
      |> String.split("\n", trim: true)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
      |> :queue.from_list()

    deck2 =
      p2
      |> String.split("\n", trim: true)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
      |> :queue.from_list()

    {deck1, deck2}
  end

  # Part 1: Regular Combat
  defp play_combat(deck1, deck2) do
    case {:queue.is_empty(deck1), :queue.is_empty(deck2)} do
      {true, false} -> deck2
      {false, true} -> deck1
      {false, false} ->
        {{:value, card1}, deck1} = :queue.out(deck1)
        {{:value, card2}, deck2} = :queue.out(deck2)

        if card1 > card2 do
          deck1 = :queue.in(card1, deck1)
          deck1 = :queue.in(card2, deck1)
          play_combat(deck1, deck2)
        else
          deck2 = :queue.in(card2, deck2)
          deck2 = :queue.in(card1, deck2)
          play_combat(deck1, deck2)
        end
    end
  end

  # Part 2: Recursive Combat
  defp play_recursive_combat(deck1, deck2, seen) do
    state = {:queue.to_list(deck1), :queue.to_list(deck2)}

    cond do
      MapSet.member?(seen, state) ->
        # Infinite game prevention: Player 1 wins
        {:p1, deck1}

      :queue.is_empty(deck1) ->
        {:p2, deck2}

      :queue.is_empty(deck2) ->
        {:p1, deck1}

      true ->
        seen = MapSet.put(seen, state)
        {{:value, card1}, deck1} = :queue.out(deck1)
        {{:value, card2}, deck2} = :queue.out(deck2)

        len1 = :queue.len(deck1)
        len2 = :queue.len(deck2)

        round_winner =
          if card1 <= len1 and card2 <= len2 do
            # Recursive game
            sub_deck1 = deck1 |> :queue.to_list() |> Enum.take(card1) |> :queue.from_list()
            sub_deck2 = deck2 |> :queue.to_list() |> Enum.take(card2) |> :queue.from_list()
            {winner, _} = play_recursive_combat(sub_deck1, sub_deck2, MapSet.new())
            winner
          else
            # Higher card wins
            if card1 > card2, do: :p1, else: :p2
          end

        case round_winner do
          :p1 ->
            deck1 = :queue.in(card1, deck1)
            deck1 = :queue.in(card2, deck1)
            play_recursive_combat(deck1, deck2, seen)

          :p2 ->
            deck2 = :queue.in(card2, deck2)
            deck2 = :queue.in(card1, deck2)
            play_recursive_combat(deck1, deck2, seen)
        end
    end
  end

  defp score(deck) do
    deck
    |> :queue.to_list()
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {card, mult} -> card * mult end)
    |> Enum.sum()
  end
end
