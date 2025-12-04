import AOC

aoc 2025, 4 do
  @moduledoc """
  https://adventofcode.com/2025/day/4
  """

  @doc """
      iex> p1(example_string(0))
      13
  """
  def p1(input) do
    grid = parse_grid(input)

    grid
    |> Map.filter(fn {_pos, char} -> char == "@" end)
    |> Map.keys()
    |> Enum.count(fn pos -> accessible?(pos, grid) end)
  end

  @doc """
      iex> p2(example_string(0))
      43
  """
  def p2(input) do
    grid = parse_grid(input)
    remove_all_accessible(grid, 0)
  end

  defp remove_all_accessible(grid, count) do
    # Find all accessible rolls
    accessible_rolls =
      grid
      |> Map.filter(fn {_pos, char} -> char == "@" end)
      |> Map.keys()
      |> Enum.filter(fn pos -> accessible?(pos, grid) end)

    if Enum.empty?(accessible_rolls) do
      count
    else
      # Remove all accessible rolls
      new_grid = Enum.reduce(accessible_rolls, grid, fn pos, g ->
        Map.put(g, pos, ".")
      end)

      remove_all_accessible(new_grid, count + length(accessible_rolls))
    end
  end

  defp parse_grid(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, char} end)
    end)
    |> Map.new()
  end

  defp accessible?(pos, grid) do
    count_adjacent_rolls(pos, grid) < 4
  end

  defp count_adjacent_rolls({x, y}, grid) do
    # Eight adjacent positions
    neighbors = [
      {x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1},
      {x - 1, y},                 {x + 1, y},
      {x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}
    ]

    neighbors
    |> Enum.count(fn pos -> Map.get(grid, pos) == "@" end)
  end
end
