import AOC

aoc 2016, 6 do
  @moduledoc """
  https://adventofcode.com/2016/day/6
  Day 6: Signals and Noise - error correction by frequency
  """

  @doc """
      iex> p1(example_string(0))
      "easter"
  """
  def p1(input) do
    input
    |> parse_columns()
    |> Enum.map(&most_common_char/1)
    |> Enum.join()
  end

  @doc """
      iex> p2(example_string(0))
      "advent"
  """
  def p2(input) do
    input
    |> parse_columns()
    |> Enum.map(&least_common_char/1)
    |> Enum.join()
  end

  defp parse_columns(input) do
    lines = input |> String.trim() |> String.split("\n", trim: true)

    lines
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp most_common_char(chars) do
    chars
    |> Enum.frequencies()
    |> Enum.max_by(fn {_, count} -> count end)
    |> elem(0)
  end

  defp least_common_char(chars) do
    chars
    |> Enum.frequencies()
    |> Enum.min_by(fn {_, count} -> count end)
    |> elem(0)
  end
end
