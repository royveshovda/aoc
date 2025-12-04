import AOC

aoc 2015, 10 do
  @moduledoc """
  https://adventofcode.com/2015/day/10

  Day 10: Elves Look, Elves Say
  Look-and-say sequence: replace each run of digits with count + digit.

  Examples:
  - 1 → 11 (one 1)
  - 11 → 21 (two 1s)
  - 21 → 1211 (one 2, one 1)
  - 1211 → 111221 (one 1, one 2, two 1s)
  - 111221 → 312211 (three 1s, two 2s, one 1)
  """

  @doc """
  Part 1: Apply look-and-say 40 times, return length of result.

      iex> look_and_say("1")
      "11"

      iex> look_and_say("11")
      "21"

      iex> look_and_say("21")
      "1211"

      iex> look_and_say("1211")
      "111221"

      iex> look_and_say("111221")
      "312211"
  """
  def p1(input) do
    input
    |> String.trim()
    |> apply_n_times(40)
    |> String.length()
  end

  @doc """
  Part 2: Apply look-and-say 50 times, return length of result.
  """
  def p2(input) do
    input
    |> String.trim()
    |> apply_n_times(50)
    |> String.length()
  end

  def look_and_say(string) do
    string
    |> String.graphemes()
    |> Enum.chunk_by(& &1)
    |> Enum.map(fn group ->
      count = length(group)
      digit = hd(group)
      "#{count}#{digit}"
    end)
    |> Enum.join()
  end

  defp apply_n_times(string, 0), do: string
  defp apply_n_times(string, n) do
    string
    |> look_and_say()
    |> apply_n_times(n - 1)
  end
end
