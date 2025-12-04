import AOC

aoc 2015, 19 do
  @moduledoc """
  https://adventofcode.com/2015/day/19

  Day 19: Medicine for Rudolph

  String replacement problem - count distinct molecules after one replacement.
  """

  def p1(input) do
    {replacements, molecule} = parse_input(input)

    generate_all_replacements(molecule, replacements)
    |> MapSet.size()
  end

  def p2(input) do
    {replacements, molecule} = parse_input(input)

    # Part 2: Find minimum steps to generate molecule from "e"
    # This is a reverse search - we go from molecule back to "e"
    find_steps_to_generate(molecule, replacements)
  end

  defp parse_input(input) do
    lines = String.split(input, "\n", trim: true)

    {replacement_lines, [molecule]} = Enum.split(lines, length(lines) - 1)

    replacements =
      replacement_lines
      |> Enum.map(fn line ->
        [from, to] = String.split(line, " => ")
        {from, to}
      end)

    {replacements, molecule}
  end

  defp generate_all_replacements(molecule, replacements) do
    replacements
    |> Enum.flat_map(fn {from, to} ->
      find_all_positions(molecule, from)
      |> Enum.map(fn pos ->
        replace_at_position(molecule, pos, String.length(from), to)
      end)
    end)
    |> MapSet.new()
  end

  defp find_all_positions(string, substring) do
    len = String.length(substring)

    0..(String.length(string) - len)
    |> Enum.filter(fn pos ->
      String.slice(string, pos, len) == substring
    end)
  end

  defp replace_at_position(string, pos, old_len, new_substring) do
    before = String.slice(string, 0, pos)
    after_str = String.slice(string, (pos + old_len)..-1//1)
    before <> new_substring <> after_str
  end

  # For Part 2, use a greedy approach working backwards
  # The input has special properties that make greedy work
  defp find_steps_to_generate(molecule, replacements) do
    # Reverse the replacements - we go from molecule to "e"
    reversed = Enum.map(replacements, fn {from, to} -> {to, from} end)

    # Greedy reduction: always try to replace the longest possible substring
    # This works for AoC 2015 Day 19 due to special input properties
    reduce_to_e(molecule, reversed, 0)
  end

  defp reduce_to_e("e", _replacements, steps), do: steps

  defp reduce_to_e(current, replacements, steps) do
    # Try each replacement and pick the first that works
    case find_first_replacement(current, replacements) do
      nil -> :error  # Should not happen with valid input
      new_molecule -> reduce_to_e(new_molecule, replacements, steps + 1)
    end
  end

  defp find_first_replacement(molecule, replacements) do
    # Sort by length descending to try longest replacements first
    replacements
    |> Enum.sort_by(fn {from, _to} -> String.length(from) end, :desc)
    |> Enum.find_value(fn {from, to} ->
      if String.contains?(molecule, from) do
        # Replace first occurrence
        String.replace(molecule, from, to, global: false)
      else
        nil
      end
    end)
  end
end
