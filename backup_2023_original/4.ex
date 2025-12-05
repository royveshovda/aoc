
import AOC

aoc 2023, 4 do
  @moduledoc """
  https://adventofcode.com/2023/day/4
  """

  @doc """
      iex> p1(example_string())
      13

      iex> p1(input_string())
      23847
  """
  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.map(&sum_correct/1)
    |> Enum.filter(fn x -> x > 0 end)
    |> Enum.map(fn x -> :math.pow(2, x - 1) end)
    |> Enum.sum()
    |> round()

  end

  def calculate_score(correct_cards_count_left, current_value) do
    if correct_cards_count_left == 0 do
      current_value
    else
      calculate_score(correct_cards_count_left - 1, current_value * 2)
    end
  end

  @doc """
      iex> p2(example_string())
      30

      iex> p2(input_string())
      8570000
  """
  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.map(&sum_correct_with_id/1)
    |> Enum.map(fn {card_id, correct_count} -> {card_id, correct_count, 1} end)
    |> Map.new(fn {card_id, correct_count, multiplier} -> {card_id, {correct_count, multiplier}} end)
    |> update_multipliers()
    |> Enum.map(fn {_card_id, {_correct_count, multiplier}} -> multiplier end)
    |> Enum.sum()
  end

  def update_multipliers(map) do
    min_id = Map.keys(map) |> Enum.min()
    max_id = Map.keys(map) |> Enum.max()
    {min_id, max_id}
    do_update_multipliers(map, min_id, max_id)
  end

  def do_update_multipliers(map, current_id, max_id) do
    if current_id > max_id do
      map
    else
      {correct_count, multiplier} = map[current_id]
      new_map = update_forward(map, current_id + 1, correct_count, multiplier, max_id)
      #new_map = %{map | current_id => {correct_count, 99}}
      do_update_multipliers(new_map, current_id + 1, max_id)
    end
  end

  def update_forward(map, _id, 0, _multiplier, _max_id) do
    map
  end

  def update_forward(map, id, correct_count, multiplier, max_id) do
    if id > max_id do
      map
    else
      {count, this_multiplier} = map[id]
      new_map = %{map | id => {count, this_multiplier + multiplier}}
      update_forward(new_map, id + 1, correct_count - 1, multiplier, max_id)
    end
  end


  def sum_correct({_card_id, winners, my}) do
    Enum.map(my, fn x -> Enum.member?(winners, x) end) |> Enum.count(fn x -> x end)
  end

  def sum_correct_with_id({card_id, winners, my}) do
    {card_id, Enum.map(my, fn x -> Enum.member?(winners, x) end) |> Enum.count(fn x -> x end)}
  end

  def parse_line(line) do
    [card_string, points] = String.split(line, ":", trim: true)
    [_, card_id_raw] = String.split(card_string, " ", trim: true)
    card_id = String.to_integer(card_id_raw)

    [winners_raw, my_raw] = String.split(points, "|", trim: true)
    winners = String.split(winners_raw, " ", trim: true) |> Enum.map(&String.to_integer/1)
    my = String.split(my_raw, " ", trim: true) |> Enum.map(&String.to_integer/1)

    {card_id, winners, my}
  end
end
