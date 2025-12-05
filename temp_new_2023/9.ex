import AOC

aoc 2023, 9 do
  @moduledoc """
  https://adventofcode.com/2023/day/9
  """

  @doc """
      iex> p1(example_string())
      114

      iex> p1(input_string())
      1731106378
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(&extrapolate_next/1)
    |> Enum.sum()
  end

  @doc """
      iex> p2(example_string())
      2

      iex> p2(input_string())
      1087
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.map(&extrapolate_prev/1)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.split() |> Enum.map(&String.to_integer/1)
    end)
  end

  defp extrapolate_next(sequence) do
    if Enum.all?(sequence, &(&1 == 0)) do
      0
    else
      diffs = differences(sequence)
      List.last(sequence) + extrapolate_next(diffs)
    end
  end

  defp extrapolate_prev(sequence) do
    if Enum.all?(sequence, &(&1 == 0)) do
      0
    else
      diffs = differences(sequence)
      List.first(sequence) - extrapolate_prev(diffs)
    end
  end

  defp differences(sequence) do
    sequence
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
  end
end
