import AOC

aoc 2024, 5 do
  @moduledoc """
  https://adventofcode.com/2024/day/5
  """

  def p1(input) do
    [rules, prints] =
      input
      |> String.split("\n\n", trim: true)

    rules =
      rules
      |> String.split("\n")
      |> Enum.map(&String.split(&1, "|"))
      |> Enum.map(fn [a, b] -> {String.to_integer(a), String.to_integer(b)} end)

    prints =
      prints
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))

    prints
    |> Enum.filter(fn x -> valid_print(rules, x) end)
    |> Enum.map(&center_value/1)
    |> Enum.sum()
  end

  def center_value(list) do
    middle_index = div(length(list), 2)
    Enum.at(list, middle_index)
  end

  def valid_print(rules, print) do
    actual_rules =
      rules
      |> Enum.filter(fn {a, b} -> a in print && b in print end)

    actual_rules
    |> Enum.all?(fn {a, b} -> Enum.find_index(print, fn x -> x == a end) < Enum.find_index(print, fn x -> x == b end) end)

  end

  def p2(input) do
    [rules, prints] =
      input
      |> String.split("\n\n", trim: true)

    rules =
      rules
      |> String.split("\n")
      |> Enum.map(&String.split(&1, "|"))
      |> Enum.map(fn [a, b] -> {String.to_integer(a), String.to_integer(b)} end)

    prints =
      prints
      |> String.split("\n")
      |> Enum.map(&String.split(&1, ",", trim: true))
      |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))

    invalid_prints =
      prints
      |> Enum.filter(fn x -> valid_print(rules, x) == false end)

    Enum.map(invalid_prints, fn p -> fix_print(rules, p) end)
    |> Enum.map(&center_value/1)
    |> Enum.sum()
  end

  def fix_print(rules, print) do
    {swapped, new_print} = apply_all_rules(rules, print)

    Stream.iterate({swapped, new_print}, fn {_, print} -> apply_all_rules(rules, print) end)
    |> Stream.drop_while(fn {swapped, _} -> swapped end)
    |> Enum.at(0)
    |> elem(1)
  end

  def apply_all_rules(rules, print) do
    actual_rules =
      rules
      |> Enum.filter(fn {a, b} -> a in print && b in print end)

    Enum.reduce(actual_rules, {false, print}, fn rule, {swapped, print} ->
      {current, new_print} = apply_rule(rule, print)
      {swapped || current, new_print}
    end)
  end

  def apply_rule({a, b} = _rule, print) do
    i_a = Enum.find_index(print, fn x -> x == a end)
    i_b = Enum.find_index(print, fn x -> x == b end)
    ordered = i_a < i_b
    case ordered do
      true -> {false, print}
      false ->
        {true,
          List.replace_at(print, i_a, b)
          |> List.replace_at(i_b, a)}
    end
  end
end
