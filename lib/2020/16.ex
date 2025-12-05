import AOC

aoc 2020, 16 do
  @moduledoc """
  https://adventofcode.com/2020/day/16

  Ticket Translation - Field validation and constraint satisfaction.

  ## Examples

      iex> example = "class: 1-3 or 5-7\\nrow: 6-11 or 33-44\\nseat: 13-40 or 45-50\\n\\nyour ticket:\\n7,1,14\\n\\nnearby tickets:\\n7,3,47\\n40,4,50\\n55,2,20\\n38,6,12"
      iex> Y2020.D16.p1(example)
      71
  """

  def p1(input) do
    {rules, _my_ticket, nearby} = parse(input)

    nearby
    |> List.flatten()
    |> Enum.filter(&(!valid_for_any_rule?(&1, rules)))
    |> Enum.sum()
  end

  def p2(input) do
    {rules, my_ticket, nearby} = parse(input)

    # Filter out invalid tickets
    valid_tickets =
      Enum.filter(nearby, fn ticket ->
        Enum.all?(ticket, &valid_for_any_rule?(&1, rules))
      end)

    # Find which fields could match which columns
    num_fields = length(my_ticket)

    # For each column, find which rules it could satisfy
    possible =
      for col <- 0..(num_fields - 1), into: %{} do
        values = Enum.map(valid_tickets, &Enum.at(&1, col))

        matching_rules =
          rules
          |> Enum.filter(fn {_name, ranges} ->
            Enum.all?(values, &matches_rule?(&1, ranges))
          end)
          |> Enum.map(fn {name, _} -> name end)
          |> MapSet.new()

        {col, matching_rules}
      end

    # Eliminate to find unique assignments
    assignments = eliminate(possible, %{})

    # Multiply values for fields starting with "departure"
    assignments
    |> Enum.filter(fn {_col, name} -> String.starts_with?(name, "departure") end)
    |> Enum.map(fn {col, _name} -> Enum.at(my_ticket, col) end)
    |> Enum.product()
  end

  defp parse(input) do
    [rules_section, my_section, nearby_section] = String.split(input, "\n\n", trim: true)

    rules =
      rules_section
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_rule/1)

    my_ticket =
      my_section
      |> String.split("\n", trim: true)
      |> Enum.at(1)
      |> parse_ticket()

    nearby =
      nearby_section
      |> String.split("\n", trim: true)
      |> Enum.drop(1)
      |> Enum.map(&parse_ticket/1)

    {rules, my_ticket, nearby}
  end

  defp parse_rule(line) do
    [name, ranges] = String.split(line, ": ")

    ranges =
      Regex.scan(~r/(\d+)-(\d+)/, ranges)
      |> Enum.map(fn [_, a, b] ->
        {String.to_integer(a), String.to_integer(b)}
      end)

    {name, ranges}
  end

  defp parse_ticket(line) do
    line
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp valid_for_any_rule?(value, rules) do
    Enum.any?(rules, fn {_name, ranges} -> matches_rule?(value, ranges) end)
  end

  defp matches_rule?(value, ranges) do
    Enum.any?(ranges, fn {min, max} -> value >= min and value <= max end)
  end

  defp eliminate(possible, assignments) when map_size(possible) == 0, do: assignments

  defp eliminate(possible, assignments) do
    # Find a column with only one possible rule
    {col, rules} = Enum.find(possible, fn {_col, rules} -> MapSet.size(rules) == 1 end)
    [rule_name] = MapSet.to_list(rules)

    # Remove this column and this rule from all others
    new_possible =
      possible
      |> Map.delete(col)
      |> Map.new(fn {c, r} -> {c, MapSet.delete(r, rule_name)} end)

    eliminate(new_possible, Map.put(assignments, col, rule_name))
  end
end
