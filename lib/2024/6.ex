import AOC

aoc 2024, 6 do
  @moduledoc """
  https://adventofcode.com/2024/day/6
  """

  @doc """
      iex> p1(example_string())
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



  @doc """
      iex> p2(example_string())
  """
  def p2(input) do
    grid = Utils.Grid.input_to_map(input)
    {start_pos, _dir} = Enum.find(grid, fn {_, v} -> v == "^" end)
    start = {start_pos, :north}

    patched_grid = Map.put(grid, start_pos, ".")
    {_exit, turns} = find_turns(start, patched_grid, [])
    turns

    find_grid_with_ne(turns, patched_grid)

  end

  def find_grid_with_ne(turns, grid) do
    turns
    |> Enum.filter(fn {{x, y}, dir} -> dir == :ne end)
    |> Enum.map(fn {{x, y}, dir} -> check_ne({{x, y}, dir}, turns, grid) end)



  end

  def check_ne({{x, y}, _dir}, turns, grid) do
    es = Enum.filter(turns, fn {{x2, y2}, dir2} -> dir2 == :es && y2 == y && Enum.all?(Enum.to_list(x + 1..x2 - 1), fn xx -> IO.inspect({xx, y2, grid[{xx, y2}]}); grid[{xx, y2}] == "." end) end)
    wn = Enum.filter(turns, fn {{x2, y2}, dir2} -> dir2 == :wn && x2 == x && Enum.all?(Enum.to_list(y + 1..y2 - 1), fn yy -> IO.inspect({x2, yy, grid[{x2, yy}]}); grid[{x2, yy}] == "." end) end)
    wn

  end

  def find_turns({{x, y}, :north}, grid, turns) do
    case grid[{x, y - 1}] do
      "." -> find_turns({{x, y - 1}, :north}, grid, turns)
      "#" -> find_turns({{x, y}, :east}, grid, turns ++ [{{x, y}, :ne}])
      _ -> {{{x, y}, :north}, turns}
    end
  end

  def find_turns({{x, y}, :east}, grid, turns) do
    case grid[{x + 1, y}] do
      "." -> find_turns({{x + 1, y}, :east}, grid, turns)
      "#" -> find_turns({{x, y}, :south}, grid, turns ++ [{{x,y}, :es}])
      _ -> {{{x, y}, :east}, turns}
    end
  end

  def find_turns({{x, y}, :south}, grid, turns) do
    case grid[{x, y + 1}] do
      "." -> find_turns({{x, y + 1}, :south}, grid, turns)
      "#" -> find_turns({{x, y}, :west}, grid, turns ++ [{{x,y}, :sw}])
      _ -> {{{x, y}, :south}, turns}
    end
  end

  def find_turns({{x, y}, :west}, grid, turns) do
    case grid[{x - 1, y}] do
      "." -> find_turns({{x - 1, y}, :west}, grid, turns)
      "#" -> find_turns({{x, y}, :north}, grid, turns ++ [{{x,y}, :wn}])
      _ -> {{{x, y}, :west}, turns}
    end
  end
end
