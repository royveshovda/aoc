import AOC

aoc 2024, 2 do
  @moduledoc """
  https://adventofcode.com/2024/day/2
  """

  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn line -> Enum.map(line, &String.to_integer/1) end)
    |> Enum.count(fn line -> safe_line?(line) end)
  end

  def safe_line?(line) do
    line
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> a - b end)
    |> then(fn l -> Enum.all?(l, fn x -> (x < 0 && x > -4) end) || Enum.all?(l, fn x -> (x > 0 && x < 4) end) end)
  end

  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn line -> Enum.map(line, &String.to_integer/1) end)
    |> Enum.count(fn line -> safe_line?(line) || almost_safe?(line) end)
  end

  defp almost_safe?(report) do
    report
    |> Enum.with_index()
    |> Enum.any?(fn {_, idx} -> report |> List.delete_at(idx) |> safe_line?()
    end)
  end
end
