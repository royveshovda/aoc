import AOC

aoc 2018, 12 do
  @moduledoc """
  https://adventofcode.com/2018/day/12
  """

  @doc """
  Sum of pot numbers containing plants after 20 generations.

      iex> p1(example_string(0))
      325
  """
  def p1(input) do
    {state, rules} = parse(input)

    final_state = Enum.reduce(1..20, state, fn _, st ->
      evolve(st, rules)
    end)

    sum_pot_numbers(final_state)
  end

  @doc """
  Sum of pot numbers after 50 billion generations.
  Uses cycle detection to find pattern.

      iex> p2(example_string(0))
      999999999374
  """
  def p2(input) do
    {state, rules} = parse(input)
    target = 50_000_000_000

    # Run until we find a stable pattern (state shifts but doesn't change)
    {gen, sum_at_gen, offset} = find_stable_pattern(state, rules, 0, 0, [])

    # Calculate remaining generations
    remaining = target - gen
    final_sum = sum_at_gen + remaining * offset

    final_sum
  end

  # Debug function to trace generations
  def debug_trace(input, num_gens) do
    {state, rules} = parse(input)

    Enum.reduce(1..num_gens, {state, 0}, fn gen, {st, prev_sum} ->
      new_state = evolve(st, rules)
      new_sum = sum_pot_numbers(new_state)
      offset = new_sum - prev_sum
      IO.puts("Gen #{gen}: sum=#{new_sum}, offset=#{offset}")
      {new_state, new_sum}
    end)
  end

  defp parse(input) do
    [initial_line | rule_lines] = String.split(input, "\n", trim: true)

    "initial state: " <> initial = initial_line
    state = initial
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {char, _} -> char == "#" end)
    |> Enum.map(fn {_, idx} -> idx end)
    |> MapSet.new()

    rules = rule_lines
    |> Enum.map(fn line ->
      [pattern, result] = String.split(line, " => ")
      {pattern, result}
    end)
    |> Enum.filter(fn {_, result} -> result == "#" end)
    |> Enum.map(fn {pattern, _} -> pattern end)
    |> MapSet.new()

    {state, rules}
  end

  defp evolve(state, rules) do
    min_pot = Enum.min(state) - 2
    max_pot = Enum.max(state) + 2

    for pot <- min_pot..max_pot,
        matches_rule?(pot, state, rules),
        into: MapSet.new() do
      pot
    end
  end

  defp matches_rule?(pot, state, rules) do
    pattern = for offset <- -2..2 do
      if MapSet.member?(state, pot + offset), do: "#", else: "."
    end
    |> Enum.join()

    MapSet.member?(rules, pattern)
  end

  defp sum_pot_numbers(state) do
    Enum.sum(state)
  end

  # Find when the pattern stabilizes (same relative positions each generation)
  # Changed to track multiple consecutive stable offsets
  defp find_stable_pattern(state, rules, gen, prev_sum, offset_history) do
    new_state = evolve(state, rules)
    new_sum = sum_pot_numbers(new_state)
    offset = new_sum - prev_sum

    # Keep track of last N offsets
    new_history = [offset | offset_history] |> Enum.take(10)

    # Check if we have 10 consecutive generations with the same offset
    if length(new_history) == 10 and Enum.uniq(new_history) == [offset] do
      {gen + 1, new_sum, offset}
    else
      find_stable_pattern(new_state, rules, gen + 1, new_sum, new_history)
    end
  end
end
