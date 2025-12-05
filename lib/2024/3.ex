import AOC

aoc 2024, 3 do
  @moduledoc """
  https://adventofcode.com/2024/day/3

  Mull It Over - Extract mul(X,Y) from corrupted memory with do/don't toggles.
  """

  def p1(input) do
    ~r/mul\((\d{1,3}),(\d{1,3})\)/
    |> Regex.scan(input)
    |> Enum.map(fn [_, a, b] -> String.to_integer(a) * String.to_integer(b) end)
    |> Enum.sum()
  end

  def p2(input) do
    ~r/mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\)/
    |> Regex.scan(input)
    |> Enum.reduce({0, true}, fn
      ["do()"], {sum, _} -> {sum, true}
      ["don't()"], {sum, _} -> {sum, false}
      [_, a, b], {sum, true} -> {sum + String.to_integer(a) * String.to_integer(b), true}
      _, acc -> acc
    end)
    |> elem(0)
  end
end
