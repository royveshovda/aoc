import AOC

aoc 2023, 2 do
  @moduledoc """
  https://adventofcode.com/2023/day/2
  """

  @doc """
      iex> p1(example_string())
      8

      iex> p1(input_string())
      2348
  """
  def p1(input) do
    limits = %{"red" => 12, "green" => 13, "blue" => 14}
    
    input
    |> parse()
    |> Enum.filter(fn {_id, rounds} -> valid_game?(rounds, limits) end)
    |> Enum.map(fn {id, _} -> id end)
    |> Enum.sum()
  end

  @doc """
      iex> p2(example_string())
      2286

      iex> p2(input_string())
      76008
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.map(fn {_id, rounds} -> power(rounds) end)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_game/1)
  end

  defp parse_game(line) do
    [game_part, rounds_part] = String.split(line, ": ")
    id = game_part |> String.replace("Game ", "") |> String.to_integer()
    
    rounds = rounds_part
    |> String.split("; ")
    |> Enum.map(&parse_round/1)
    
    {id, rounds}
  end

  defp parse_round(round) do
    round
    |> String.split(", ")
    |> Enum.map(fn cube ->
      [count, color] = String.split(cube, " ")
      {color, String.to_integer(count)}
    end)
    |> Map.new()
  end

  defp valid_game?(rounds, limits) do
    Enum.all?(rounds, fn round ->
      Enum.all?(round, fn {color, count} ->
        count <= Map.get(limits, color, 0)
      end)
    end)
  end

  defp power(rounds) do
    mins = Enum.reduce(rounds, %{"red" => 0, "green" => 0, "blue" => 0}, fn round, acc ->
      Enum.reduce(round, acc, fn {color, count}, acc2 ->
        Map.update(acc2, color, count, &max(&1, count))
      end)
    end)
    mins["red"] * mins["green"] * mins["blue"]
  end
end
