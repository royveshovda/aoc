import AOC

aoc 2015, 5 do
  @moduledoc """
  https://adventofcode.com/2015/day/5

  Day 5: Doesn't He Have Intern-Elves For This?
  Determine which strings are "nice" based on specific rules.
  """

  @doc """
  Part 1: Count strings that are "nice" according to these rules:
  - Contains at least 3 vowels (aeiou only)
  - Contains at least one letter that appears twice in a row
  - Does NOT contain: ab, cd, pq, or xy

  Examples:
  - "ugknbfddgicrmopn" is nice (3+ vowels, double letter, no forbidden strings)
  - "aaa" is nice (3 vowels, double letter)
  - "jchzalrnumimnmhp" is naughty (no double letter)
  - "haegwjzuvuyypxyu" is naughty (contains "xy")
  - "dvszwmarrgswjxmb" is naughty (only 1 vowel)

      iex> p1("ugknbfddgicrmopn")
      1

      iex> p1("aaa")
      1

      iex> p1("jchzalrnumimnmhp")
      0

      iex> p1("haegwjzuvuyypxyu")
      0

      iex> p1("dvszwmarrgswjxmb")
      0
  """
  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.count(&nice_v1?/1)
  end

  @doc """
  Part 2: Count strings that are "nice" according to NEW rules:
  - Contains a pair of any two letters that appears at least twice without overlapping
    (e.g., "xyxy" has "xy" twice, "aabcdefgaa" has "aa" twice)
  - Contains at least one letter which repeats with exactly one letter between them
    (e.g., "xyx", "abcdefeghi" has "efe", "aaa" has "aa" with "a" between)

  Examples:
  - "qjhvhtzxzqqjkmpb" is nice (has "qj" twice and "zxz")
  - "xxyxx" is nice (has "xx" twice and "xyx")
  - "uurcxstgmygtbstg" is naughty (has "tg" twice but no repeat with one between)
  - "ieodomkazucvgmuy" is naughty (has repeat with one between but no pair twice)

      iex> p2("qjhvhtzxzqqjkmpb")
      1

      iex> p2("xxyxx")
      1

      iex> p2("uurcxstgmygtbstg")
      0

      iex> p2("ieodomkazucvgmuy")
      0
  """
  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.count(&nice_v2?/1)
  end

  # Part 1 validation
  defp nice_v1?(string) do
    has_three_vowels?(string) and
    has_double_letter?(string) and
    not has_forbidden_substring?(string)
  end

  defp has_three_vowels?(string) do
    string
    |> String.graphemes()
    |> Enum.count(&(&1 in ["a", "e", "i", "o", "u"]))
    |> Kernel.>=(3)
  end

  defp has_double_letter?(string) do
    string
    |> String.graphemes()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.any?(fn [a, b] -> a == b end)
  end

  defp has_forbidden_substring?(string) do
    String.contains?(string, ["ab", "cd", "pq", "xy"])
  end

  # Part 2 validation
  defp nice_v2?(string) do
    has_pair_twice?(string) and has_repeat_with_gap?(string)
  end

  defp has_pair_twice?(string) do
    chars = String.graphemes(string)

    chars
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.with_index()
    |> Enum.any?(fn {pair, idx} ->
      pair_str = Enum.join(pair)
      # Check if this pair appears again later (non-overlapping)
      rest = Enum.drop(chars, idx + 2) |> Enum.join()
      String.contains?(rest, pair_str)
    end)
  end

  defp has_repeat_with_gap?(string) do
    string
    |> String.graphemes()
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.any?(fn [a, _b, c] -> a == c end)
  end
end
