import AOC

aoc 2020, 11 do
  @moduledoc """
  https://adventofcode.com/2020/day/11

  Seating System - Cellular automaton with seating rules.

  ## Examples

      iex> example = "L.LL.LL.LL\\nLLLLLLL.LL\\nL.L.L..L..\\nLLLL.LL.LL\\nL.LL.LL.LL\\nL.LLLLL.LL\\n..L.L.....\\nLLLLLLLLLL\\nL.LLLLLL.L\\nL.LLLLL.LL"
      iex> Y2020.D11.p1(example)
      37

      iex> example = "L.LL.LL.LL\\nLLLLLLL.LL\\nL.L.L..L..\\nLLLL.LL.LL\\nL.LL.LL.LL\\nL.LLLLL.LL\\n..L.L.....\\nLLLLLLLLLL\\nL.LLLLLL.L\\nL.LLLLL.LL"
      iex> Y2020.D11.p2(example)
      26
  """

  @directions [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]

  def p1(input) do
    grid = parse(input)
    simulate_until_stable(grid, &count_adjacent_occupied/2, 4)
  end

  def p2(input) do
    grid = parse(input)
    simulate_until_stable(grid, &count_visible_occupied/2, 5)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, char} end)
    end)
    |> Map.new()
  end

  defp simulate_until_stable(grid, neighbor_fn, threshold) do
    new_grid = step(grid, neighbor_fn, threshold)

    if new_grid == grid do
      count_occupied(grid)
    else
      simulate_until_stable(new_grid, neighbor_fn, threshold)
    end
  end

  defp step(grid, neighbor_fn, threshold) do
    grid
    |> Enum.map(fn {pos, cell} ->
      {pos, next_cell(grid, pos, cell, neighbor_fn, threshold)}
    end)
    |> Map.new()
  end

  defp next_cell(grid, pos, cell, neighbor_fn, threshold) do
    case cell do
      "." ->
        "."

      "L" ->
        if neighbor_fn.(grid, pos) == 0, do: "#", else: "L"

      "#" ->
        if neighbor_fn.(grid, pos) >= threshold, do: "L", else: "#"
    end
  end

  defp count_adjacent_occupied(grid, {x, y}) do
    @directions
    |> Enum.count(fn {dx, dy} ->
      Map.get(grid, {x + dx, y + dy}) == "#"
    end)
  end

  defp count_visible_occupied(grid, {x, y}) do
    @directions
    |> Enum.count(fn dir ->
      first_visible_seat(grid, {x, y}, dir) == "#"
    end)
  end

  defp first_visible_seat(grid, {x, y}, {dx, dy}) do
    new_pos = {x + dx, y + dy}

    case Map.get(grid, new_pos) do
      nil -> nil
      "." -> first_visible_seat(grid, new_pos, {dx, dy})
      seat -> seat
    end
  end

  defp count_occupied(grid) do
    grid
    |> Map.values()
    |> Enum.count(&(&1 == "#"))
  end
end
