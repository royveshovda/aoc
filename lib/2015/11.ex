import AOC

aoc 2015, 11 do
  @moduledoc """
  https://adventofcode.com/2015/day/11

  Day 11: Corporate Policy
  Generate valid passwords by incrementing strings.

  Password rules:
  1. Must include increasing straight of 3+ letters (abc, bcd, etc.)
  2. May not contain i, o, or l
  3. Must contain at least two different non-overlapping pairs (aa, bb, etc.)
  """

  @doc """
  Part 1: Find the next valid password after the input.

  Examples:
  - "abcdefgh" → "abcdffaa"
  - "ghijklmn" → "ghjaabcc"
  """
  def p1(input) do
    input
    |> String.trim()
    |> next_password()
  end

  @doc """
  Part 2: Find the next valid password after the result from Part 1.
  """
  def p2(input) do
    input
    |> String.trim()
    |> next_password()
    |> next_password()
  end

  def next_password(password) do
    password
    |> increment()
    |> Stream.iterate(&increment/1)
    |> Enum.find(&valid_password?/1)
  end

  defp valid_password?(password) do
    has_straight?(password) and
    not has_forbidden_letters?(password) and
    has_two_pairs?(password)
  end

  # Check for increasing straight of at least 3 letters
  defp has_straight?(password) do
    password
    |> String.to_charlist()
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.any?(fn [a, b, c] ->
      b == a + 1 and c == b + 1
    end)
  end

  # Check if password contains i, o, or l
  defp has_forbidden_letters?(password) do
    String.contains?(password, ["i", "o", "l"])
  end

  # Check for at least two different non-overlapping pairs
  defp has_two_pairs?(password) do
    pairs =
      password
      |> String.graphemes()
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.with_index()
      |> Enum.filter(fn {[a, b], _idx} -> a == b end)
      |> Enum.map(fn {pair, idx} -> {pair, idx} end)

    # Find two non-overlapping pairs
    case pairs do
      [] -> false
      [_] -> false
      pairs ->
        # Check if we have at least two pairs that don't overlap
        pairs
        |> Enum.any?(fn {_pair1, idx1} ->
          Enum.any?(pairs, fn {_pair2, idx2} ->
            idx2 >= idx1 + 2
          end)
        end)
    end
  end

  # Increment password like base-26 number (wrapping z to a)
  defp increment(password) do
    password
    |> String.to_charlist()
    |> Enum.reverse()
    |> do_increment()
    |> Enum.reverse()
    |> List.to_string()
  end

  defp do_increment([?z | rest]) do
    [?a | do_increment(rest)]
  end

  defp do_increment([char | rest]) do
    [char + 1 | rest]
  end

  defp do_increment([]) do
    [?a]
  end
end
