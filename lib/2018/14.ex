import AOC

aoc 2018, 14 do
  @moduledoc """
  https://adventofcode.com/2018/day/14
  """

  @doc """
  Get 10 recipe scores after N recipes.

      iex> p1("9")
      "5158916779"
      iex> p1("5")
      "0124515891"
      iex> p1("18")
      "9251071085"
      iex> p1("2018")
      "5941429882"
  """
  def p1(input) do
    n = String.trim(input) |> String.to_integer()

    # Use ETS for efficient random access
    :ets.new(:recipes, [:set, :public, :named_table])
    :ets.insert(:recipes, {0, 3})
    :ets.insert(:recipes, {1, 7})

    generate_ets(2, 0, 1, n + 10)

    # Extract the 10 recipes after position n
    result = for i <- n..(n + 9) do
      [{^i, score}] = :ets.lookup(:recipes, i)
      score
    end
    |> Enum.join()

    :ets.delete(:recipes)
    result
  end

  @doc """
  Find how many recipes appear before the score sequence.

      iex> p2("51589")
      9
      iex> p2("01245")
      5
      iex> p2("92510")
      18
      iex> p2("59414")
      2018
  """
  def p2(input) do
    pattern = String.trim(input) |> String.graphemes() |> Enum.map(&String.to_integer/1)
    pattern_len = length(pattern)

    :ets.new(:recipes, [:set, :public, :named_table])
    :ets.insert(:recipes, {0, 3})
    :ets.insert(:recipes, {1, 7})

    result = find_pattern_ets(2, 0, 1, pattern, pattern_len)

    :ets.delete(:recipes)
    result
  end

  defp generate_ets(count, _elf1, _elf2, target) when count >= target do
    count
  end

  defp generate_ets(count, elf1, elf2, target) do
    [{_, score1}] = :ets.lookup(:recipes, elf1)
    [{_, score2}] = :ets.lookup(:recipes, elf2)
    sum = score1 + score2

    # Add new recipes
    new_count = if sum >= 10 do
      :ets.insert(:recipes, {count, 1})
      :ets.insert(:recipes, {count + 1, sum - 10})
      count + 2
    else
      :ets.insert(:recipes, {count, sum})
      count + 1
    end

    new_elf1 = rem(elf1 + 1 + score1, new_count)
    new_elf2 = rem(elf2 + 1 + score2, new_count)

    generate_ets(new_count, new_elf1, new_elf2, target)
  end

  defp find_pattern_ets(count, elf1, elf2, pattern, pattern_len) do
    # Check if pattern matches at current position or one before
    cond do
      count >= pattern_len and matches_pattern_at?(count - pattern_len, pattern) ->
        count - pattern_len

      count > pattern_len and matches_pattern_at?(count - pattern_len - 1, pattern) ->
        count - pattern_len - 1

      true ->
        [{_, score1}] = :ets.lookup(:recipes, elf1)
        [{_, score2}] = :ets.lookup(:recipes, elf2)
        sum = score1 + score2

        new_count = if sum >= 10 do
          :ets.insert(:recipes, {count, 1})
          :ets.insert(:recipes, {count + 1, sum - 10})
          count + 2
        else
          :ets.insert(:recipes, {count, sum})
          count + 1
        end

        new_elf1 = rem(elf1 + 1 + score1, new_count)
        new_elf2 = rem(elf2 + 1 + score2, new_count)

        find_pattern_ets(new_count, new_elf1, new_elf2, pattern, pattern_len)
    end
  end

  defp matches_pattern_at?(start, pattern) do
    pattern
    |> Enum.with_index()
    |> Enum.all?(fn {expected, offset} ->
      case :ets.lookup(:recipes, start + offset) do
        [{_, ^expected}] -> true
        _ -> false
      end
    end)
  end
end
