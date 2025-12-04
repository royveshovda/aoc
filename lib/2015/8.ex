import AOC

aoc 2015, 8 do
  @moduledoc """
  https://adventofcode.com/2015/day/8

  Day 8: Matchsticks
  Calculate differences between code representation and in-memory strings.

  Escape sequences:
  - \\\\ represents a single backslash
  - \\\" represents a double quote
  - \\xHH represents a single character (hex ASCII code)
  """

  @doc """
  Part 1: Count (code characters) - (in-memory characters)

  Examples:
  - "" → 2 code chars, 0 memory chars (difference: 2)
  - "abc" → 5 code chars, 3 memory chars (difference: 2)
  - "aaa\\"aaa" → 10 code chars, 7 memory chars (difference: 3)
  - "\\x27" → 6 code chars, 1 memory char (difference: 5)

      iex> p1(~S(""))
      2

      iex> p1(~S("abc"))
      2

      iex> p1(~S("aaa\\"aaa"))
      3

      iex> p1(~S("\\x27"))
      5
  """
  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      code_length = String.length(line)
      memory_length = memory_length(line)
      code_length - memory_length
    end)
    |> Enum.sum()
  end

  @doc """
  Part 2: Count (encoded characters) - (original code characters)

  Need to encode the strings by escaping quotes and backslashes.
  Also add surrounding quotes.

  Examples:
  - "" → "\\"\\"" (6 chars) - 2 original = 4
  - "abc" → "\\"abc\\"" (9 chars) - 5 original = 4
  - "aaa\\"aaa" → "\\"aaa\\\\\\"aaa\\"" (16 chars) - 10 original = 6
  - "\\x27" → "\\"\\\\x27\\"" (11 chars) - 6 original = 5

      iex> p2(~S(""))
      4

      iex> p2(~S("abc"))
      4

      iex> p2(~S("aaa\\"aaa"))
      6

      iex> p2(~S("\\x27"))
      5
  """
  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      encoded_length = encoded_length(line)
      code_length = String.length(line)
      encoded_length - code_length
    end)
    |> Enum.sum()
  end

  # Calculate the in-memory length by processing escape sequences
  defp memory_length(line) do
    # Remove surrounding quotes
    content = String.slice(line, 1..-2//1)
    count_memory_chars(content, 0)
  end

  defp count_memory_chars("", count), do: count

  defp count_memory_chars("\\\\" <> rest, count) do
    # \\\\ → one backslash
    count_memory_chars(rest, count + 1)
  end

  defp count_memory_chars("\\\"" <> rest, count) do
    # \\\" → one quote
    count_memory_chars(rest, count + 1)
  end

  defp count_memory_chars("\\x" <> <<_hex1, _hex2, rest::binary>>, count) do
    # \\xHH → one character
    count_memory_chars(rest, count + 1)
  end

  defp count_memory_chars(<<_char, rest::binary>>, count) do
    # Regular character
    count_memory_chars(rest, count + 1)
  end

  # Calculate the encoded length (escape quotes and backslashes, add surrounding quotes)
  defp encoded_length(line) do
    # Start with 2 for the surrounding quotes we'll add
    chars = String.graphemes(line)

    escaped_length = Enum.reduce(chars, 0, fn char, acc ->
      case char do
        "\\" -> acc + 2  # \ becomes \\\\
        "\"" -> acc + 2  # " becomes \\"
        _ -> acc + 1     # regular char stays as is
      end
    end)

    # Add 2 for the new surrounding quotes
    escaped_length + 2
  end
end
