import AOC

aoc 2023, 9 do
  @moduledoc """
  https://adventofcode.com/2023/day/9
  """

  @doc """
      iex> p1(example_string())
      114

      iex> p1(input_string())
      1731106378
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(fn l -> generate_levels(l, [l]) end)
    |> Enum.map(fn l -> calculate_next_value(l) end)
    |> Enum.sum()
  end

  def calculate_next_value(levels) do
    [_zeros | rest] = Enum.reverse(levels)
    Enum.reduce(rest, 0, fn level, acc ->
      previous_level_tail = Enum.at(level, -1) + acc
      previous_level_tail
    end)
  end

  def generate_levels(current_level, all_levels) do
    case all_zeros?(current_level) do
      true -> all_levels |> Enum.reverse()
      false ->
        new_level = new_level_down(current_level)
        generate_levels(new_level, [new_level | all_levels])
    end
  end

  def new_level_down(level) do
    Enum.chunk_every(level, 2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
  end

  def all_zeros?(level) do
    Enum.all?(level, fn x -> x == 0 end)
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn x -> String.split(x, " ") end)
    |> Enum.map(fn l -> Enum.map(l, fn x -> String.to_integer(x) end) end)
  end

  @doc """
      iex> p2(example_string())
      2

      iex> p2(input_string())
      1087
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.map(fn l -> generate_levels(l, [l]) end)
    |> Enum.map(fn l -> calculate_previous_value(l) end)
    |> Enum.sum()
  end

  def calculate_previous_value(levels) do
    [_zeros | rest] = Enum.reverse(levels)
    Enum.reduce(rest, 0, fn level, acc ->
      previous_level_head = Enum.at(level, 0) - acc
      previous_level_head
    end)
  end
end
