import AOC

aoc 2023, 13 do
  @moduledoc """
  https://adventofcode.com/2023/day/13
  """

  @doc """
      iex> p1(example_string())
      405

      iex> p1(input_string())
      37975

      iex> p1(exmample_p1_1())
      14
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(fn {grid, max_row, max_col} ->
      check_grid(grid, max_row, max_col)
    end)
    |> Enum.sum()
  end

  def exmample_p1_1() do
    """
    .##.#####.##...
    .#.#.##..###.##
    .#.#.##..###.##
    .##.########...
    ###.##.#.##.###
    #####..#.#...##
    ....##...#.####
    .##.##.#.#.####
    #.#..#######.##
    """
  end

  def check_grid(grid, max_row, max_col) do
    vertical = find_vertical_reflections(grid, max_row, max_col)
    horizontal = find_horizontal_reflections(grid, max_row, max_col)
    vertical + (100 * horizontal)
  end

  def find_vertical_reflections(grid, max_row, max_col) do
    columns =
      for col <- 0..max_col,
        into: [] do
          for row <- 0..max_row do
            grid[{row, col}]
          end
        end

    columns =
      columns
      |> Enum.map(fn col ->
        col
        |> Enum.join()
      end)

    lines_to_check = 1..(max_col) |> Enum.to_list()

    res =
      lines_to_check
      |> Enum.map(fn l -> get_pairs_for_line(l, max_col) end)
      |> Enum.map(fn {n, pairs} -> {n, compare_pairs(pairs, columns)} end)
      |> Enum.filter(fn {_n, res} -> res end)

    case res do
      [] -> 0
      [{n, _}] -> n
    end
  end

  def get_pairs_for_line(n, max) do
    steps = min(max - n, n - 1)
    left = (n - steps - 1)..(n - 1) |> Enum.to_list()
    right = (n + steps)..n |> Enum.to_list()
    {n, Enum.zip(left, right)}
  end

  def compare_pairs(pairs, lines) do
    pairs
    |> Enum.map(fn {l, r} ->
      {Enum.at(lines, l), Enum.at(lines, r)}
    end)
    |> Enum.map(fn {l, r} ->
      if l == r do
        true
      else
        false
      end
    end)
    |> Enum.all?()
  end

  def find_horizontal_reflections(grid, max_row, max_col) do
    rows =
      for row <- 0..max_row,
        into: [] do
          for col <- 0..max_col do
            grid[{row, col}]
          end
        end

    rows =
      rows
      |> Enum.map(fn row ->
        row
        |> Enum.join()
      end)

    lines_to_check = 1..(max_row) |> Enum.to_list()

    res =
      lines_to_check
      |> Enum.map(fn l -> get_pairs_for_line(l, max_row) end)
      |> Enum.map(fn {n, pairs} -> {n, compare_pairs(pairs, rows)} end)
      |> Enum.filter(fn {_n, res} -> res end)

    case res do
      [] -> 0
      [{n, _}] -> n
    end
  end

  def parse(input) do
    grids =
      input
      |> String.split("\n\n")
      |> Enum.map(fn grid ->
        for {line, row} <- Enum.with_index(grid |> String.split("\n")),
          {point, col} <- Enum.with_index(String.graphemes(line)),
          into: %{} do
            {{row, col}, point}
        end
      end)

    Enum.map(grids, fn grid ->
      max_row = Enum.map(grid, fn {{r,_},_} -> r end) |> Enum.max()
      max_col = Enum.map(grid, fn {{_,c},_} -> c end) |> Enum.max()
      {grid, max_row, max_col}
    end)
  end

  @doc """
      iex> p2(example_string())
      400

      iex> p2(input_string())
      32497
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.map(fn {grid, max_row, max_col} ->
      check_grid_p2(grid, max_row, max_col)
    end)
    |> Enum.sum()
  end

  def check_grid_p2(grid, max_row, max_col) do
    vertical = find_vertical_reflections_p2(grid, max_row, max_col)
    horizontal = find_horizontal_reflections_p2(grid, max_row, max_col)
    vertical + (100 * horizontal)
  end

  def find_vertical_reflections_p2(grid, max_row, max_col) do
    columns =
      for col <- 0..max_col,
        into: [] do
          for row <- 0..max_row do
            grid[{row, col}]
          end
        end

    columns =
      columns
      |> Enum.map(fn col ->
        col
        |> Enum.join()
      end)

    lines_to_check = 1..(max_col) |> Enum.to_list()

    res =
      lines_to_check
      |> Enum.map(fn l -> get_pairs_for_line(l, max_col) end)
      |> Enum.map(fn {n, pairs} -> {n, compare_pairs_p2(pairs, columns)} end)
      |> Enum.filter(fn {_n, res} -> res == 1 end)

    case res do
      [] -> 0
      [{n, _}] -> n
    end
  end

  def find_horizontal_reflections_p2(grid, max_row, max_col) do
    rows =
      for row <- 0..max_row,
        into: [] do
          for col <- 0..max_col do
            grid[{row, col}]
          end
        end

    rows =
      rows
      |> Enum.map(fn row ->
        row
        |> Enum.join()
      end)

    lines_to_check = 1..(max_row) |> Enum.to_list()

    res =
      lines_to_check
      |> Enum.map(fn l -> get_pairs_for_line(l, max_row) end)
      |> Enum.map(fn {n, pairs} -> {n, compare_pairs_p2(pairs, rows)} end)
      |> Enum.filter(fn {_n, res} -> res == 1 end)

    case res do
      [] -> 0
      [{n, _}] -> n
    end
  end

  def compare_pairs_p2(pairs, lines) do
    pairs
    |> Enum.map(fn {l, r} ->
      {Enum.at(lines, l), Enum.at(lines, r)}
    end)
    |> Enum.map(fn {l, r} ->
      l = String.graphemes(l)
      r = String.graphemes(r)

      Enum.zip(l, r)
      |> Enum.map(fn {l1, r1} ->
        case l1 == r1 do
          true -> 0
          false -> 1
        end
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end
end
