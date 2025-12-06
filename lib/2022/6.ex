import AOC

aoc 2022, 6 do
  @moduledoc """
  Day 6: Tuning Trouble

  Find start-of-packet/message marker (first position where N chars are unique).
  Part 1: 4 unique chars.
  Part 2: 14 unique chars.
  """

  @doc """
  Part 1: Find first position with 4 unique chars.

  ## Examples

      iex> p1("mjqjpqmgbljsphdztnvjfqwrcgsmlb")
      7

      iex> p1("bvwbjplbgvbhsrlpgdmjqwftvncz")
      5

      iex> p1("nppdvjthqldpwncqszvftbrmjlhg")
      6

      iex> p1("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg")
      10
  """
  def p1(input) do
    find_marker(input, 4)
  end

  @doc """
  Part 2: Find first position with 14 unique chars.

  ## Examples

      iex> p2("mjqjpqmgbljsphdztnvjfqwrcgsmlb")
      19

      iex> p2("bvwbjplbgvbhsrlpgdmjqwftvncz")
      23
  """
  def p2(input) do
    find_marker(input, 14)
  end

  defp find_marker(input, window_size) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.chunk_every(window_size, 1, :discard)
    |> Enum.find_index(fn window ->
      length(Enum.uniq(window)) == window_size
    end)
    |> Kernel.+(window_size)
  end
end
