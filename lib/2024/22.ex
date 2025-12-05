import AOC
use Bitwise

aoc 2024, 22 do
  @moduledoc """
  https://adventofcode.com/2024/day/22

  Monkey Market - PRNG simulation and finding best price sequence.
  """

  def p1(input) do
    input
    |> parse()
    |> Enum.map(fn seed -> nth_secret(seed, 2000) end)
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> parse()
    |> Enum.map(&price_sequences/1)
    |> merge_sequences()
    |> Map.values()
    |> Enum.max()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp next_secret(s) do
    s = mix_prune(s, s * 64)
    s = mix_prune(s, div(s, 32))
    mix_prune(s, s * 2048)
  end

  defp mix_prune(s, val), do: bxor(s, val) |> rem(16_777_216)

  defp nth_secret(s, 0), do: s
  defp nth_secret(s, n), do: nth_secret(next_secret(s), n - 1)

  defp price_sequences(seed) do
    # Generate 2001 prices (0 to 2000)
    prices =
      Stream.iterate(seed, &next_secret/1)
      |> Enum.take(2001)
      |> Enum.map(&rem(&1, 10))

    # Compute changes
    changes =
      prices
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [a, b] -> b - a end)

    # Map each 4-change sequence to first price it leads to
    changes
    |> Enum.chunk_every(4, 1, :discard)
    |> Enum.with_index(4)  # price index is 4 after start
    |> Enum.reduce(%{}, fn {seq, idx}, acc ->
      key = List.to_tuple(seq)
      # Only keep first occurrence
      Map.put_new(acc, key, Enum.at(prices, idx))
    end)
  end

  defp merge_sequences(seq_maps) do
    Enum.reduce(seq_maps, %{}, fn map, acc ->
      Map.merge(acc, map, fn _k, v1, v2 -> v1 + v2 end)
    end)
  end
end
