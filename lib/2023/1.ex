import AOC

aoc 2023, 1 do
  @moduledoc """
  https://adventofcode.com/2023/day/1
  """

  @doc """
      iex> p1(input_string())
      54968
  """
  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&extract_calibration_p1/1)
    |> Enum.sum()
  end

  @doc """
      iex> p2(input_string())
      54094
  """
  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&extract_calibration_p2/1)
    |> Enum.sum()
  end

  defp extract_calibration_p1(line) do
    digits = line |> String.graphemes() |> Enum.filter(&(&1 =~ ~r/\d/))
    String.to_integer(List.first(digits) <> List.last(digits))
  end

  defp extract_calibration_p2(line) do
    first = find_first_digit(line)
    last = find_last_digit(line)
    first * 10 + last
  end

  @words %{
    "one" => 1, "two" => 2, "three" => 3, "four" => 4, "five" => 5,
    "six" => 6, "seven" => 7, "eight" => 8, "nine" => 9
  }

  defp find_first_digit(line) do
    find_digit(line, 0, 1)
  end

  defp find_last_digit(line) do
    find_digit(line, String.length(line) - 1, -1)
  end

  defp find_digit(line, pos, step) do
    char = String.at(line, pos)
    cond do
      char =~ ~r/\d/ -> String.to_integer(char)
      word = find_word_at(line, pos) -> @words[word]
      true -> find_digit(line, pos + step, step)
    end
  end

  defp find_word_at(line, pos) do
    substring = String.slice(line, pos, 5)
    Enum.find(Map.keys(@words), fn word -> String.starts_with?(substring, word) end)
  end
end
