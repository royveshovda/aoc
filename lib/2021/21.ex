import AOC

aoc 2021, 21 do
  @moduledoc """
  Day 21: Dirac Dice

  Dice game with two players on circular board (1-10).
  Part 1: Deterministic die (1,2,3,4,...)
  Part 2: Quantum die splits into 27 universes per turn (3 rolls of 1-3)
  """

  @doc """
  Part 1: Play with deterministic die until someone reaches 1000.
  Return: losing score * number of die rolls.
  """
  def p1(input) do
    {p1_start, p2_start} = parse(input)
    play_deterministic(p1_start, p2_start, 0, 0, 1, 0)
  end

  @doc """
  Part 2: Play with quantum die, count universes where each player wins.
  Return: number of universes where the winning player wins more.
  """
  def p2(input) do
    {p1_start, p2_start} = parse(input)
    {wins1, wins2} = count_wins({p1_start, 0}, {p2_start, 0}, true, %{})
    max(wins1, wins2)
  end

  # Part 1: Deterministic game
  defp play_deterministic(p1_pos, p2_pos, p1_score, p2_score, die, rolls) do
    # Player 1's turn
    {move1, die} = roll_deterministic(die)
    p1_pos = wrap(p1_pos + move1)
    p1_score = p1_score + p1_pos

    if p1_score >= 1000 do
      p2_score * (rolls + 3)
    else
      # Player 2's turn
      {move2, die} = roll_deterministic(die)
      p2_pos = wrap(p2_pos + move2)
      p2_score = p2_score + p2_pos

      if p2_score >= 1000 do
        p1_score * (rolls + 6)
      else
        play_deterministic(p1_pos, p2_pos, p1_score, p2_score, die, rolls + 6)
      end
    end
  end

  defp roll_deterministic(die) do
    # Roll 3 times
    rolls = [die, wrap_die(die + 1), wrap_die(die + 2)]
    total = Enum.sum(rolls)
    {total, wrap_die(die + 3)}
  end

  defp wrap_die(n) when n > 100, do: n - 100
  defp wrap_die(n), do: n

  defp wrap(pos) when pos > 10, do: wrap(pos - 10)
  defp wrap(pos), do: pos

  # Part 2: Quantum game with memoization
  # Each turn, the die roll sums (3d3) have these frequencies:
  # 3: 1, 4: 3, 5: 6, 6: 7, 7: 6, 8: 3, 9: 1
  @roll_frequencies [{3, 1}, {4, 3}, {5, 6}, {6, 7}, {7, 6}, {8, 3}, {9, 1}]

  defp count_wins({_p1_pos, p1_score}, _p2, _p1_turn, _memo) when p1_score >= 21 do
    {1, 0}
  end

  defp count_wins(_p1, {_p2_pos, p2_score}, _p1_turn, _memo) when p2_score >= 21 do
    {0, 1}
  end

  defp count_wins(p1, p2, p1_turn, memo) do
    key = {p1, p2, p1_turn}

    case Map.get(memo, key) do
      nil ->
        {wins1, wins2, _memo} =
          Enum.reduce(@roll_frequencies, {0, 0, memo}, fn {roll, freq}, {w1, w2, m} ->
            {new_p1, new_p2} =
              if p1_turn do
                {pos, score} = p1
                new_pos = wrap(pos + roll)
                {{new_pos, score + new_pos}, p2}
              else
                {pos, score} = p2
                new_pos = wrap(pos + roll)
                {p1, {new_pos, score + new_pos}}
              end

            {sub_w1, sub_w2} = count_wins(new_p1, new_p2, not p1_turn, m)
            {w1 + sub_w1 * freq, w2 + sub_w2 * freq, m}
          end)

        {wins1, wins2}

      result ->
        result
    end
  end

  defp parse(input) do
    [line1, line2] = String.split(input, "\n", trim: true)
    p1 = Regex.run(~r/(\d+)$/, line1) |> List.last() |> String.to_integer()
    p2 = Regex.run(~r/(\d+)$/, line2) |> List.last() |> String.to_integer()
    {p1, p2}
  end
end
