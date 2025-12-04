import AOC

aoc 2016, 14 do
  use Memoize

  @moduledoc """
  https://adventofcode.com/2016/day/14
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    salt = String.trim(input)
    find_64th_key(salt, &hash_once/2)
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    salt = String.trim(input)
    find_64th_key(salt, &hash_stretched/2)
  end

  defmemo hash_once(salt, i) do
    :crypto.hash(:md5, salt <> Integer.to_string(i)) |> Base.encode16(case: :lower)
  end

  defmemo hash_stretched(salt, i) do
    Enum.reduce(1..2017, salt <> Integer.to_string(i), fn _, acc ->
      :crypto.hash(:md5, acc) |> Base.encode16(case: :lower)
    end)
  end

  defp find_64th_key(salt, hash_fn) do
    Stream.iterate(0, &(&1 + 1))
    |> Stream.map(fn i -> {i, hash_fn.(salt, i)} end)
    |> Stream.filter(fn {i, hash} ->
      case find_triplet(hash) do
        nil -> false
        char ->
          quintuplet = String.duplicate(char, 5)
          # Check next 1000 hashes
          Enum.any?((i + 1)..(i + 1000), fn j ->
            hash_fn.(salt, j) |> String.contains?(quintuplet)
          end)
      end
    end)
    |> Enum.take(64)
    |> List.last()
    |> elem(0)
  end

  defp find_triplet(hash) do
    hash
    |> String.graphemes()
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.find_value(fn [a, a, a] -> a; _ -> nil end)
  end
end
