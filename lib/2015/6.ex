import AOC

aoc 2015, 6 do
  @moduledoc """
  https://adventofcode.com/2015/day/6

  Day 6: Probably a Fire Hazard
  Control a 1000x1000 grid of lights with instructions to turn on, turn off, or toggle.
  """

  @doc """
  Part 1: Follow instructions to control lights (on/off/toggle).
  Count how many lights are lit after all instructions.

  Instructions:
  - "turn on x1,y1 through x2,y2" - turn on all lights in rectangle
  - "turn off x1,y1 through x2,y2" - turn off all lights in rectangle
  - "toggle x1,y1 through x2,y2" - flip all lights in rectangle

  Examples:
  - "turn on 0,0 through 999,999" turns on all 1,000,000 lights
  - "toggle 0,0 through 999,0" toggles 1000 lights on first row
  - "turn off 499,499 through 500,500" turns off 4 lights in middle

      iex> p1("turn on 0,0 through 999,999")
      1000000

      iex> p1("toggle 0,0 through 999,0")
      1000

      iex> p1("turn on 0,0 through 999,999\\nturn off 499,499 through 500,500")
      999996
  """
  def p1(input) do
    input
    |> parse_instructions()
    |> Enum.reduce(MapSet.new(), fn instruction, lights ->
      apply_instruction_p1(lights, instruction)
    end)
    |> MapSet.size()
  end

  @doc """
  Part 2: Lights have brightness levels instead of just on/off.

  New interpretation:
  - "turn on" increases brightness by 1
  - "turn off" decreases brightness by 1 (minimum 0)
  - "toggle" increases brightness by 2

  What is the total brightness of all lights?

      iex> p2("turn on 0,0 through 0,0")
      1

      iex> p2("toggle 0,0 through 999,999")
      2000000
  """
  def p2(input) do
    input
    |> parse_instructions()
    |> Enum.reduce(%{}, fn instruction, lights ->
      apply_instruction_p2(lights, instruction)
    end)
    |> Map.values()
    |> Enum.sum()
  end

  defp parse_instructions(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    cond do
      String.starts_with?(line, "turn on") ->
        [x1, y1, x2, y2] = extract_coords(line)
        {:turn_on, x1, y1, x2, y2}

      String.starts_with?(line, "turn off") ->
        [x1, y1, x2, y2] = extract_coords(line)
        {:turn_off, x1, y1, x2, y2}

      String.starts_with?(line, "toggle") ->
        [x1, y1, x2, y2] = extract_coords(line)
        {:toggle, x1, y1, x2, y2}
    end
  end

  defp extract_coords(line) do
    ~r/(\d+),(\d+) through (\d+),(\d+)/
    |> Regex.run(line, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
  end

  # Part 1: Binary on/off state using MapSet
  defp apply_instruction_p1(lights, {:turn_on, x1, y1, x2, y2}) do
    get_coords(x1, y1, x2, y2)
    |> Enum.reduce(lights, fn coord, acc -> MapSet.put(acc, coord) end)
  end

  defp apply_instruction_p1(lights, {:turn_off, x1, y1, x2, y2}) do
    get_coords(x1, y1, x2, y2)
    |> Enum.reduce(lights, fn coord, acc -> MapSet.delete(acc, coord) end)
  end

  defp apply_instruction_p1(lights, {:toggle, x1, y1, x2, y2}) do
    get_coords(x1, y1, x2, y2)
    |> Enum.reduce(lights, fn coord, acc ->
      if MapSet.member?(acc, coord) do
        MapSet.delete(acc, coord)
      else
        MapSet.put(acc, coord)
      end
    end)
  end

  # Part 2: Brightness levels using Map
  defp apply_instruction_p2(lights, {:turn_on, x1, y1, x2, y2}) do
    get_coords(x1, y1, x2, y2)
    |> Enum.reduce(lights, fn coord, acc ->
      Map.update(acc, coord, 1, &(&1 + 1))
    end)
  end

  defp apply_instruction_p2(lights, {:turn_off, x1, y1, x2, y2}) do
    get_coords(x1, y1, x2, y2)
    |> Enum.reduce(lights, fn coord, acc ->
      case Map.get(acc, coord) do
        nil -> acc  # Light doesn't exist, stays at 0, don't add to map
        val when val <= 1 -> Map.delete(acc, coord)  # Will go to 0, remove from map
        val -> Map.put(acc, coord, val - 1)  # Decrease brightness
      end
    end)
  end

  defp apply_instruction_p2(lights, {:toggle, x1, y1, x2, y2}) do
    get_coords(x1, y1, x2, y2)
    |> Enum.reduce(lights, fn coord, acc ->
      Map.update(acc, coord, 2, &(&1 + 2))
    end)
  end

  defp get_coords(x1, y1, x2, y2) do
    for x <- x1..x2, y <- y1..y2, do: {x, y}
  end
end
