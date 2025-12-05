import AOC

aoc 2023, 19 do
  @moduledoc """
  https://adventofcode.com/2023/day/19

  Part sorting workflows. Part 1: sum ratings of accepted parts.
  Part 2: count all possible accepted combinations.
  """

  @doc """
      iex> p1(example_string())
      19114

      iex> p1(input_string())
      434147
  """
  def p1(input) do
    {workflows, parts} = parse(input)

    parts
    |> Enum.filter(&accepted?(&1, workflows, "in"))
    |> Enum.map(fn part -> part.x + part.m + part.a + part.s end)
    |> Enum.sum()
  end

  @doc """
      iex> p2(example_string())
      167409079868000

      iex> p2(input_string())
      136146366355609
  """
  def p2(input) do
    {workflows, _} = parse(input)

    # Start with all ranges 1..4000 for each category
    initial_ranges = %{x: {1, 4000}, m: {1, 4000}, a: {1, 4000}, s: {1, 4000}}
    count_accepted(workflows, "in", initial_ranges)
  end

  defp parse(input) do
    [workflows_str, parts_str] = String.split(input, "\n\n", trim: true)

    workflows =
      workflows_str
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_workflow/1)
      |> Map.new()

    parts =
      parts_str
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_part/1)

    {workflows, parts}
  end

  defp parse_workflow(line) do
    [name, rest] = String.split(line, "{")
    rules_str = String.trim_trailing(rest, "}")

    rules =
      rules_str
      |> String.split(",")
      |> Enum.map(&parse_rule/1)

    {name, rules}
  end

  defp parse_rule(str) do
    if String.contains?(str, ":") do
      [condition, target] = String.split(str, ":")
      {cat, op, val} = parse_condition(condition)
      {:cond, cat, op, val, target}
    else
      {:goto, str}
    end
  end

  defp parse_condition(condition) do
    cond do
      String.contains?(condition, "<") ->
        [cat, val] = String.split(condition, "<")
        {String.to_atom(cat), :<, String.to_integer(val)}

      String.contains?(condition, ">") ->
        [cat, val] = String.split(condition, ">")
        {String.to_atom(cat), :>, String.to_integer(val)}
    end
  end

  defp parse_part(line) do
    ~r/\{x=(\d+),m=(\d+),a=(\d+),s=(\d+)\}/
    |> Regex.run(line, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
    |> then(fn [x, m, a, s] -> %{x: x, m: m, a: a, s: s} end)
  end

  # Part 1: check if a part is accepted
  defp accepted?(_part, _workflows, "A"), do: true
  defp accepted?(_part, _workflows, "R"), do: false
  defp accepted?(part, workflows, workflow_name) do
    rules = Map.get(workflows, workflow_name)
    next = apply_rules(part, rules)
    accepted?(part, workflows, next)
  end

  defp apply_rules(_part, [{:goto, target} | _]), do: target
  defp apply_rules(part, [{:cond, cat, op, val, target} | rest]) do
    part_val = Map.get(part, cat)
    matches = case op do
      :< -> part_val < val
      :> -> part_val > val
    end
    if matches, do: target, else: apply_rules(part, rest)
  end

  # Part 2: count accepted combinations with range splitting
  defp count_accepted(_workflows, "A", ranges), do: range_combinations(ranges)
  defp count_accepted(_workflows, "R", _ranges), do: 0
  defp count_accepted(workflows, workflow_name, ranges) do
    rules = Map.get(workflows, workflow_name)
    count_with_rules(workflows, rules, ranges)
  end

  defp count_with_rules(workflows, [{:goto, target} | _], ranges) do
    count_accepted(workflows, target, ranges)
  end

  defp count_with_rules(workflows, [{:cond, cat, op, val, target} | rest], ranges) do
    {lo, hi} = Map.get(ranges, cat)

    case op do
      :< ->
        # Matching: lo..(val-1), Not matching: val..hi
        match_count = if lo < val do
          match_ranges = Map.put(ranges, cat, {lo, min(hi, val - 1)})
          count_accepted(workflows, target, match_ranges)
        else
          0
        end

        no_match_count = if hi >= val do
          no_match_ranges = Map.put(ranges, cat, {max(lo, val), hi})
          count_with_rules(workflows, rest, no_match_ranges)
        else
          0
        end

        match_count + no_match_count

      :> ->
        # Matching: (val+1)..hi, Not matching: lo..val
        match_count = if hi > val do
          match_ranges = Map.put(ranges, cat, {max(lo, val + 1), hi})
          count_accepted(workflows, target, match_ranges)
        else
          0
        end

        no_match_count = if lo <= val do
          no_match_ranges = Map.put(ranges, cat, {lo, min(hi, val)})
          count_with_rules(workflows, rest, no_match_ranges)
        else
          0
        end

        match_count + no_match_count
    end
  end

  defp range_combinations(ranges) do
    ranges
    |> Map.values()
    |> Enum.map(fn {lo, hi} -> max(0, hi - lo + 1) end)
    |> Enum.product()
  end
end
