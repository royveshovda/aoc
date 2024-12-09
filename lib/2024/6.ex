import AOC

aoc 2024, 6 do
  @moduledoc """
  https://adventofcode.com/2024/day/6
  """

  def p1(input) do
    grid = Utils.Grid.input_to_map(input)
    {start_pos, _dir} = Enum.find(grid, fn {_, v} -> v == "^" end)
    start = {start_pos, :north}

    patched_grid = Map.put(grid, start_pos, ".")

    {_pos, visited} = move(start, patched_grid, [start_pos])
    visited
    |> Enum.uniq()
    |> Enum.count()
  end

  def move({{x, y}, :north}, grid, visited) do
    case grid[{x, y - 1}] do
      "." -> move({{x, y - 1}, :north}, grid, visited ++ [{x, y - 1}])
      "#" -> move({{x, y}, :east}, grid, visited)
      _ -> {{{x, y}, :north}, visited}
    end
  end

  def move({{x, y}, :east}, grid, visited) do
    case grid[{x + 1, y}] do
      "." -> move({{x + 1, y}, :east}, grid, visited ++ [{x + 1, y}])
      "#" -> move({{x, y}, :south}, grid, visited)
      _ -> {{{x, y}, :east}, visited}
    end
  end

  def move({{x, y}, :south}, grid, visited) do
    case grid[{x, y + 1}] do
      "." -> move({{x, y + 1}, :south}, grid, visited ++ [{x, y + 1}])
      "#" -> move({{x, y}, :west}, grid, visited)
      _ -> {{{x, y}, :south}, visited}
    end
  end

  def move({{x, y}, :west}, grid, visited) do
    case grid[{x - 1, y}] do
      "." -> move({{x - 1, y}, :west}, grid, visited ++ [{x - 1, y}])
      "#" -> move({{x, y}, :north}, grid, visited)
      _ -> {{{x, y}, :west}, visited}
    end
  end

  def p2(input) do
    map =
      input
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, i} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {char, j} -> {{i, j}, char} end)
      end)
      |> Map.new()

    start = find_guard(map)
    {path, _} = guard_path(map, start)

    possible_obstructions(path, map, start)
  end


  def find_guard(map) do
    map |> Enum.find_value(fn {k, v} -> if v == "^", do: k end)
  end

  def guard_path(map, {i, j}, dir \\ {-1, 0}, path \\ MapSet.new()) do
    next_pos = next_position(map, {i, j}, dir)
    next_path = MapSet.put(path, {i, j, dir})

    cond do
      MapSet.member?(path, {i, j, dir}) ->
        path = distinct_positions(next_path)
        {path, true}

      next_pos == nil ->
        path = distinct_positions(next_path)
        {path, false}

      true ->
        {ni, nj, ndir} = next_pos
        guard_path(map, {ni, nj}, ndir, next_path)
    end
  end

  def possible_obstructions(path, map, start) do
    path |> Enum.count(fn pos -> Map.put(map, pos, "#") |> path_loops?(start) end)
  end

  def path_loops?(map, start) do
    {_, loops} = guard_path(map, start)
    loops
  end

  def distinct_positions(path) do
    path |> Enum.map(fn {i, j, _} -> {i, j} end) |> Enum.uniq()
  end

  def next_position(map, {i, j}, {di, dj}) do
    ni = i + di
    nj = j + dj

    case Map.get(map, {ni, nj}) do
      nil -> nil
      "#" -> {i, j, rotate_right({di, dj})}
      _ -> {ni, nj, {di, dj}}
    end
  end

  def rotate_right({di, dj}) do
    case {di, dj} do
      {-1, 0} -> {0, 1}
      {0, 1} -> {1, 0}
      {1, 0} -> {0, -1}
      {0, -1} -> {-1, 0}
    end
  end
end
