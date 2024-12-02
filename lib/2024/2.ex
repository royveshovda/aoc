import AOC

aoc 2024, 2 do
  @moduledoc """
  https://adventofcode.com/2024/day/2
  """

  @doc """
      iex> p1(example_string())
  """
  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn line -> Enum.map(line, &String.to_integer/1) end)
    |> Enum.filter(fn line -> safe_line?(line) end)
    |> Enum.count()
  end

  def safe_line?(line) do
    line
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> a - b end)
    |> then(fn l -> Enum.all?(l, fn x -> (x < 0 && x > -4) end) || Enum.all?(l, fn x -> (x > 0 && x < 4) end) end)
  end

  @doc """
      iex> p2(example_string())
  """
  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn line -> Enum.map(line, &String.to_integer/1) end)
    |> Enum.map(
      fn line ->
        line
        |> Enum.chunk_every(3, 1, :discard)
        |> Enum.map(fn [a, b, c] -> {a - b, b - c, a - c} end)
      end)
  end
end
