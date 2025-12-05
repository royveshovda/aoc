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
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse/1)
    |> Enum.filter(fn g -> valid_game?(g, 12, 13, 14) end)
    |> Enum.map(fn g -> g.game end)
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
    |> String.split("\n", trim: true)
    |> Enum.map(&parse/1)
    |> Enum.map(&calculate_minimum_per_game/1)
    |> Enum.map(fn %{red: red, green: green, blue: blue} -> red * green * blue end)
    |> Enum.sum()
  end

  def calculate_minimum_per_game(%{game: _game, rounds: rounds}) do
    Enum.reduce(rounds, %{red: 0, green: 0, blue: 0}, fn %{red: red, green: green, blue: blue}, acc ->
      %{red: [red, acc.red] |> Enum.max(), green: [green, acc.green] |> Enum.max(), blue: [blue, acc.blue] |> Enum.max()}
    end)
  end

  def valid_game?(%{game: _game, rounds: rounds}, max_red, max_green, max_blue) do
    Enum.all?(rounds, fn r -> valid_round?(r, max_red, max_green, max_blue) end)
  end

  def valid_round?(%{red: red, green: green, blue: blue}, max_red, max_green, max_blue) do
    red <= max_red and green <= max_green and blue <= max_blue
  end

  def parse(line) do
    [game, counts] = String.split(line, ": ", trim: true)
    [_, game_id] = String.split(game, " ", trim: true)
    rounds = parse_rounds(counts)

    %{game: String.to_integer(game_id), rounds: rounds}
  end

  def parse_rounds(counts) do
    counts
    |> String.split(";", trim: true)
    |> Enum.map(&parse_round/1)
  end

  def parse_round(round) do
    raw_colors =
      round
      |> String.split(",", trim: true)
      |> Enum.map(&parse_color/1)
    Enum.reduce(raw_colors, %{red: 0, green: 0, blue: 0}, fn {color, count}, acc ->
      Map.update(acc, color, count, &(&1 + count))
    end)
  end

  def parse_color(color) do
    [count, color] = String.split(color, " ", trim: true)
    {String.to_atom(color), String.to_integer(count)}
  end
end
