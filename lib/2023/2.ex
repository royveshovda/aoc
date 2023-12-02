import AOC

aoc 2023, 2 do
  @moduledoc """
  https://adventofcode.com/2023/day/2
  """

  @doc """
      iex> p1(example_input())
  """
  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse/1)
  end

  @doc """
      iex> p2(example_input())
  """
  def p2(input) do
  end

  def parse(line) do
    [game, counts] = String.split(line, ": ", trim: true)
    [_, game_id] = String.split(game, " ", trim: true)
    rounds = parse_rounds(counts)

    %{game: String.to_integer(game_id), rounds: rounds}
  end

  # Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red

  def parse_rounds(counts) do
    counts
    |> String.split(";", trim: true)
    |> Enum.map(&parse_round/1)
  end

  def parse_round(round) do
    round
    |> String.split(",", trim: true)
    |> Enum.map(&parse_color/1)
  end

  def parse_color(color) do
    [count, color] = String.split(color, " ", trim: true)

    def parse_color(color) do
      [count, color] = String.split(color, " ", trim: true)
      [{String.to_atom(color), String.to_integer(color)}]
    end
  end
end
