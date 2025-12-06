import AOC

aoc 2021, 6 do
  @moduledoc """
  Day 6: Lanternfish

  Model exponential fish population growth.
  Key insight: Track count of fish by timer value (0-8), not individual fish.
  """

  @doc """
  Part 1: Count fish after 80 days.

  ## Examples

      iex> p1("3,4,3,1,2")
      5934
  """
  def p1(input) do
    input
    |> parse()
    |> simulate(80)
    |> Map.values()
    |> Enum.sum()
  end

  @doc """
  Part 2: Count fish after 256 days.

  ## Examples

      iex> p2("3,4,3,1,2")
      26984457539
  """
  def p2(input) do
    input
    |> parse()
    |> simulate(256)
    |> Map.values()
    |> Enum.sum()
  end

  defp simulate(fish, 0), do: fish

  defp simulate(fish, days) do
    new_fish =
      for {timer, count} <- fish, reduce: %{} do
        acc ->
          case timer do
            0 ->
              # Fish at 0 reset to 6 and spawn new fish at 8
              acc
              |> Map.update(6, count, &(&1 + count))
              |> Map.update(8, count, &(&1 + count))

            n ->
              # Other fish decrement their timer
              Map.update(acc, n - 1, count, &(&1 + count))
          end
      end

    simulate(new_fish, days - 1)
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies()
  end
end
