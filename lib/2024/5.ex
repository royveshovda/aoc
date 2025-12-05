import AOC

aoc 2024, 5 do
  @moduledoc """
  https://adventofcode.com/2024/day/5

  Print Queue - Validate page ordering and fix invalid sequences.
  """

  def p1(input) do
    {rules, updates} = parse(input)

    updates
    |> Enum.filter(&valid?(&1, rules))
    |> Enum.map(&middle/1)
    |> Enum.sum()
  end

  def p2(input) do
    {rules, updates} = parse(input)

    updates
    |> Enum.reject(&valid?(&1, rules))
    |> Enum.map(&fix_order(&1, rules))
    |> Enum.map(&middle/1)
    |> Enum.sum()
  end

  defp parse(input) do
    [rules_section, updates_section] = String.split(input, "\n\n", trim: true)

    rules =
      rules_section
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [a, b] = String.split(line, "|")
        {String.to_integer(a), String.to_integer(b)}
      end)
      |> MapSet.new()

    updates =
      updates_section
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line |> String.split(",") |> Enum.map(&String.to_integer/1)
      end)

    {rules, updates}
  end

  defp valid?(update, rules) do
    indexed = update |> Enum.with_index() |> Map.new()

    Enum.all?(rules, fn {a, b} ->
      case {Map.get(indexed, a), Map.get(indexed, b)} do
        {nil, _} -> true
        {_, nil} -> true
        {ia, ib} -> ia < ib
      end
    end)
  end

  defp fix_order(update, rules) do
    Enum.sort(update, fn a, b ->
      MapSet.member?(rules, {a, b})
    end)
  end

  defp middle(list), do: Enum.at(list, div(length(list), 2))
end
