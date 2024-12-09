import AOC

aoc 2024, 1 do
  @moduledoc """
  https://adventofcode.com/2024/day/1
  """

  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn line -> Enum.map(line, &String.to_integer/1) end)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.sort/1)
    |> Enum.zip()
    |> Enum.reduce(0, fn {a, b}, acc -> acc + abs(a - b) end)
  end

  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn line -> Enum.map(line, &String.to_integer/1) end)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> then(fn [a, b] -> {a, Enum.frequencies(b)} end)
    # Get how many times each number appears in the list b
    |> then(fn {a, b} -> Enum.map(a, fn x -> {x, Map.get(b, x, 0)} end) end)
    # Multiply the numbers and summarize
    |> Enum.map(fn {a, b} -> a * b end)
    |> Enum.sum()
  end
end
