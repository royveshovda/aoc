import AOC

aoc 2023, 1 do
  @moduledoc """
  https://adventofcode.com/2023/day/1

  Trebuchet?! - Extract calibration values from strings.
  Part 1: Find first/last digit, combine to two-digit number
  Part 2: Include spelled-out numbers (one, two, ... nine)
  """

  @doc """
      iex> p1(input_string())
      54968
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(&extract_digits_p1/1)
    |> Enum.map(&calibration_value/1)
    |> Enum.sum()
  end

  @doc """
      iex> p2(input_string())
      54094
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.map(&extract_digits_p2/1)
    |> Enum.map(&calibration_value/1)
    |> Enum.sum()
  end

  defp parse(input) do
    input |> String.split("\n", trim: true)
  end

  defp extract_digits_p1(line) do
    # TODO: Extract only numeric digits
    []
  end

  defp extract_digits_p2(line) do
    # TODO: Extract digits including spelled out (one, two, etc.)
    # Watch for overlapping: "twone" = [2, 1]
    []
  end

  defp calibration_value(digits) do
    first = List.first(digits)
    last = List.last(digits)
    first * 10 + last
  end
end
