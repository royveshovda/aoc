import AOC

aoc 2016, 2 do
  @moduledoc """
  https://adventofcode.com/2016/day/2
  Day 2: Bathroom Security
  Follow keypad directions to find bathroom code.
  """

  @keypad1 %{
    {0, 0} => "1", {1, 0} => "2", {2, 0} => "3",
    {0, 1} => "4", {1, 1} => "5", {2, 1} => "6",
    {0, 2} => "7", {1, 2} => "8", {2, 2} => "9"
  }

  @keypad2 %{
    {2, 0} => "1",
    {1, 1} => "2", {2, 1} => "3", {3, 1} => "4",
    {0, 2} => "5", {1, 2} => "6", {2, 2} => "7", {3, 2} => "8", {4, 2} => "9",
    {1, 3} => "A", {2, 3} => "B", {3, 3} => "C",
    {2, 4} => "D"
  }

  @doc """
      iex> p1(example_string(0))
      "1985"
  """
  def p1(input) do
    input
    |> parse_lines()
    |> find_code(@keypad1, {1, 1})
  end

  @doc """
      iex> p2(example_string(0))
      "5DB3"
  """
  def p2(input) do
    input
    |> parse_lines()
    |> find_code(@keypad2, {0, 2})
  end

  defp parse_lines(input) do
    input
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  defp find_code(lines, keypad, start_pos) do
    {code, _} =
      Enum.reduce(lines, {[], start_pos}, fn line, {code, pos} ->
        final_pos = Enum.reduce(line, pos, fn dir, p -> move(p, dir, keypad) end)
        {[keypad[final_pos] | code], final_pos}
      end)

    code |> Enum.reverse() |> Enum.join()
  end

  defp move({x, y}, "U", keypad) do
    new_pos = {x, y - 1}
    if Map.has_key?(keypad, new_pos), do: new_pos, else: {x, y}
  end

  defp move({x, y}, "D", keypad) do
    new_pos = {x, y + 1}
    if Map.has_key?(keypad, new_pos), do: new_pos, else: {x, y}
  end

  defp move({x, y}, "L", keypad) do
    new_pos = {x - 1, y}
    if Map.has_key?(keypad, new_pos), do: new_pos, else: {x, y}
  end

  defp move({x, y}, "R", keypad) do
    new_pos = {x + 1, y}
    if Map.has_key?(keypad, new_pos), do: new_pos, else: {x, y}
  end
end
