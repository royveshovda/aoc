import AOC

aoc 2024, 1 do
  @moduledoc """
  https://adventofcode.com/2024/day/1
  
  Historian Hysteria - Sort two lists, compute distances and similarity.
  """

  def p1(input) do
    {left, right} = parse(input)
    
    left_sorted = Enum.sort(left)
    right_sorted = Enum.sort(right)
    
    Enum.zip(left_sorted, right_sorted)
    |> Enum.map(fn {l, r} -> abs(l - r) end)
    |> Enum.sum()
  end

  def p2(input) do
    {left, right} = parse(input)
    
    freq = Enum.frequencies(right)
    
    left
    |> Enum.map(fn n -> n * Map.get(freq, n, 0) end)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [l, r] = String.split(line, ~r/\s+/, trim: true)
      {String.to_integer(l), String.to_integer(r)}
    end)
    |> Enum.unzip()
  end
end
