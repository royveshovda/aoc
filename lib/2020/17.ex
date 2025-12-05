import AOC

aoc 2020, 17 do
  @moduledoc """
  https://adventofcode.com/2020/day/17

  Conway Cubes - 3D/4D Game of Life.

  ## Examples

      iex> example = ".#.\\n..#\\n###"
      iex> Y2020.D17.p1(example)
      112

      iex> example = ".#.\\n..#\\n###"
      iex> Y2020.D17.p2(example)
      848
  """

  def p1(input) do
    active = parse_3d(input)
    run_cycles(active, 6, &neighbors_3d/1)
  end

  def p2(input) do
    active = parse_4d(input)
    run_cycles(active, 6, &neighbors_4d/1)
  end

  defp parse_3d(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {char, _x} -> char == "#" end)
      |> Enum.map(fn {_char, x} -> {x, y, 0} end)
    end)
    |> MapSet.new()
  end

  defp parse_4d(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {char, _x} -> char == "#" end)
      |> Enum.map(fn {_char, x} -> {x, y, 0, 0} end)
    end)
    |> MapSet.new()
  end

  defp run_cycles(active, 0, _neighbors_fn), do: MapSet.size(active)

  defp run_cycles(active, n, neighbors_fn) do
    new_active = step(active, neighbors_fn)
    run_cycles(new_active, n - 1, neighbors_fn)
  end

  defp step(active, neighbors_fn) do
    # Get all candidates (active cells and their neighbors)
    candidates =
      active
      |> Enum.flat_map(fn pos -> [pos | neighbors_fn.(pos)] end)
      |> MapSet.new()

    candidates
    |> Enum.filter(fn pos ->
      active? = MapSet.member?(active, pos)
      neighbor_count = count_active_neighbors(pos, active, neighbors_fn)

      cond do
        active? and neighbor_count in [2, 3] -> true
        not active? and neighbor_count == 3 -> true
        true -> false
      end
    end)
    |> MapSet.new()
  end

  defp count_active_neighbors(pos, active, neighbors_fn) do
    neighbors_fn.(pos)
    |> Enum.count(&MapSet.member?(active, &1))
  end

  defp neighbors_3d({x, y, z}) do
    for dx <- -1..1, dy <- -1..1, dz <- -1..1, {dx, dy, dz} != {0, 0, 0} do
      {x + dx, y + dy, z + dz}
    end
  end

  defp neighbors_4d({x, y, z, w}) do
    for dx <- -1..1, dy <- -1..1, dz <- -1..1, dw <- -1..1, {dx, dy, dz, dw} != {0, 0, 0, 0} do
      {x + dx, y + dy, z + dz, w + dw}
    end
  end
end
