import AOC

aoc 2020, 15 do
  @moduledoc """
  https://adventofcode.com/2020/day/15

  Rambunctious Recitation - Memory game simulation.
  """

  @doc """
  Find 2020th number spoken.

  ## Examples

      iex> p1("0,3,6")
      436

      iex> p1("1,3,2")
      1

      iex> p1("2,1,3")
      10
  """
  def p1(input) do
    play(input, 2020)
  end

  @doc """
  Find 30000000th number spoken.
  """
  def p2(input) do
    play(input, 30_000_000)
  end

  defp play(input, target) do
    starting = parse(input)
    initial_turn = length(starting)

    # Build initial state: number -> last turn spoken
    history =
      starting
      |> Enum.with_index(1)
      |> Enum.drop(-1)
      |> Map.new(fn {num, turn} -> {num, turn} end)

    last_spoken = List.last(starting)

    play_turns(history, last_spoken, initial_turn + 1, target)
  end

  defp play_turns(_history, last_spoken, turn, target) when turn > target do
    last_spoken
  end

  defp play_turns(history, last_spoken, turn, target) do
    next_num =
      case Map.get(history, last_spoken) do
        nil -> 0
        prev_turn -> turn - 1 - prev_turn
      end

    new_history = Map.put(history, last_spoken, turn - 1)
    play_turns(new_history, next_num, turn + 1, target)
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
