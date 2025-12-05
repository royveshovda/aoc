import AOC
import Bitwise

aoc 2024, 22 do
  @moduledoc """
  https://adventofcode.com/2024/day/22

  Monkey Market - PRNG simulation and finding best price sequence.
  Optimized with parallel Task.async and on-the-fly pattern building.
  """

  def p1(input) do
    input
    |> parse()
    |> Enum.map(fn seed -> nth_secret(seed, 2000) end)
    |> Enum.sum()
  end

  def p2(input) do
    seeds = parse(input)

    # Process buyers in parallel
    tasks = Enum.map(seeds, fn seed ->
      Task.async(fn -> price_sequences_optimized(seed) end)
    end)

    buyer_maps = Enum.map(tasks, &Task.await/1)

    # Merge all buyer maps
    buyer_maps
    |> Enum.reduce(%{}, fn map, acc ->
      Map.merge(acc, map, fn _k, v1, v2 -> v1 + v2 end)
    end)
    |> Map.values()
    |> Enum.max()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp next_secret(s) do
    s = bxor(s, s * 64) |> rem(16_777_216)
    s = bxor(s, div(s, 32)) |> rem(16_777_216)
    bxor(s, s * 2048) |> rem(16_777_216)
  end

  defp nth_secret(s, 0), do: s
  defp nth_secret(s, n), do: nth_secret(next_secret(s), n - 1)

  # On-the-fly pattern building - more memory efficient
  defp price_sequences_optimized(seed) do
    do_price_sequences(seed, rem(seed, 10), [], %{}, 2000)
  end

  defp do_price_sequences(_secret, _last_price, _changes, pattern_map, 0), do: pattern_map

  defp do_price_sequences(secret, last_price, changes, pattern_map, steps) do
    new_secret = next_secret(secret)
    new_price = rem(new_secret, 10)
    change = new_price - last_price

    # Keep last 4 changes (as a list, newest first for efficiency)
    changes = [change | Enum.take(changes, 3)]

    pattern_map =
      if length(changes) == 4 do
        # Build pattern tuple (oldest to newest)
        pattern = changes |> Enum.reverse() |> List.to_tuple()
        # Only record first occurrence
        Map.put_new(pattern_map, pattern, new_price)
      else
        pattern_map
      end

    do_price_sequences(new_secret, new_price, changes, pattern_map, steps - 1)
  end
end
