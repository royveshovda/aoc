import AOC

aoc 2017, 25 do
  @moduledoc """
  https://adventofcode.com/2017/day/25
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    {start_state, steps, rules} = parse(input)
    tape = %{}
    final_tape = run_turing(tape, 0, start_state, steps, rules)
    Enum.count(final_tape, fn {_pos, val} -> val == 1 end)
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(_input) do
    "No Part 2 for Day 25!"
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)

    # Parse first two lines
    [start_line, steps_line | rule_lines] = lines

    start_state = start_line |> String.split(" ") |> Enum.at(3) |> String.trim_trailing(".")
    steps = steps_line |> String.split(" ") |> Enum.at(5) |> String.to_integer()

    # Parse rules in chunks of 9 lines
    rules = parse_rules(rule_lines, %{})

    {start_state, steps, rules}
  end

  defp parse_rules([], rules), do: rules
  defp parse_rules(lines, rules) do
    {chunk, rest} = Enum.split(lines, 9)

    if length(chunk) >= 9 do
      [state_line | action_lines] = chunk
      state = state_line |> String.split(" ") |> Enum.at(2) |> String.trim_trailing(":")

      # Parse actions for value 0 (lines 1-3)
      write_0 = action_lines |> Enum.at(1) |> String.split(" ") |> List.last() |> String.trim_trailing(".") |> String.to_integer()
      move_0 = if String.contains?(Enum.at(action_lines, 2), "right"), do: 1, else: -1
      next_0 = action_lines |> Enum.at(3) |> String.split(" ") |> List.last() |> String.trim_trailing(".")

      # Parse actions for value 1 (lines 4-6)
      write_1 = action_lines |> Enum.at(5) |> String.split(" ") |> List.last() |> String.trim_trailing(".") |> String.to_integer()
      move_1 = if String.contains?(Enum.at(action_lines, 6), "right"), do: 1, else: -1
      next_1 = action_lines |> Enum.at(7) |> String.split(" ") |> List.last() |> String.trim_trailing(".")

      new_rules = Map.put(rules, {state, 0}, {write_0, move_0, next_0})
      new_rules = Map.put(new_rules, {state, 1}, {write_1, move_1, next_1})

      parse_rules(rest, new_rules)
    else
      rules
    end
  end

  defp run_turing(tape, _pos, _state, 0, _rules), do: tape
  defp run_turing(tape, pos, state, steps, rules) do
    current_value = Map.get(tape, pos, 0)
    {write_value, move, next_state} = Map.fetch!(rules, {state, current_value})

    new_tape = if write_value == 0 do
      Map.delete(tape, pos)
    else
      Map.put(tape, pos, write_value)
    end

    new_pos = pos + move
    run_turing(new_tape, new_pos, next_state, steps - 1, rules)
  end
end
