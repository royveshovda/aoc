import AOC

aoc 2015, 4 do
  @moduledoc """
  https://adventofcode.com/2015/day/4

  Day 4: The Ideal Stocking Stuffer
  Mine AdventCoins by finding MD5 hashes that start with leading zeroes.
  """

  @doc """
  Part 1: Find the lowest positive number that produces an MD5 hash
  starting with five zeroes when combined with the secret key.

  Examples:
  - "abcdef" → 609043 (abcdef609043 hashes to 000001dbbfa...)
  - "pqrstuv" → 1048970 (pqrstuv1048970 hashes to 000006136ef...)

      iex> p1("abcdef")
      609043

      iex> p1("pqrstuv")
      1048970
  """
  def p1(input) do
    secret_key = String.trim(input)
    find_hash_with_prefix(secret_key, "00000")
  end

  @doc """
  Part 2: Find the lowest positive number that produces an MD5 hash
  starting with six zeroes.
  """
  def p2(input) do
    secret_key = String.trim(input)
    find_hash_with_prefix(secret_key, "000000")
  end

  defp find_hash_with_prefix(secret_key, prefix) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.find(fn num ->
      hash = :crypto.hash(:md5, "#{secret_key}#{num}")
      |> Base.encode16(case: :lower)

      String.starts_with?(hash, prefix)
    end)
  end
end
