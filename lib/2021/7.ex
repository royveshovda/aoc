import AOC

aoc 2021, 7 do
  @moduledoc """
  Day 7: The Treachery of Whales

  Align crab submarines with minimum fuel.
  Part 1: Constant fuel cost (1 per step)
  Part 2: Increasing fuel cost (1+2+3+... = triangular number)
  """

  @doc """
  Part 1: Minimize fuel with constant cost.
  Optimal position is the median.

  ## Examples

      iex> p1("16,1,2,0,4,2,7,1,2,14")
      37
  """
  def p1(input) do
    positions = parse(input)
    target = median(positions)

    positions
    |> Enum.map(&abs(&1 - target))
    |> Enum.sum()
  end

  @doc """
  Part 2: Minimize fuel with triangular number cost.
  Optimal position is near the mean.

  ## Examples

      iex> p2("16,1,2,0,4,2,7,1,2,14")
      168
  """
  def p2(input) do
    positions = parse(input)
    min_pos = Enum.min(positions)
    max_pos = Enum.max(positions)

    # Try all positions and find minimum
    min_pos..max_pos
    |> Enum.map(fn target ->
      positions
      |> Enum.map(fn pos ->
        n = abs(pos - target)
        # Triangular number: n*(n+1)/2
        div(n * (n + 1), 2)
      end)
      |> Enum.sum()
    end)
    |> Enum.min()
  end

  defp median(list) do
    sorted = Enum.sort(list)
    len = length(sorted)
    Enum.at(sorted, div(len, 2))
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
