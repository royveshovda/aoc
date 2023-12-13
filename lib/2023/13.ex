import AOC

aoc 2023, 13 do
  @moduledoc """
  https://adventofcode.com/2023/day/13
  """

  @doc """
      iex> p1(example_string())
      405

      #iex> p1(input_string())
      #123
  """
  def p1(input) do
    grids =
      input
      |> parse()

    {grid1, max_row1, max_col1} = grids |> Enum.at(0)
    {grid1, max_row1, max_col1}

    check_grid(grid1, max_row1, max_col1)
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

    lines_to_check = 1..(max_col-1) |> Enum.to_list()
    IO.inspect(lines_to_check)

    #IO.inspect(columns)
    0
  end

  def find_horizontal_reflections(grid, max_row, max_col) do
    0
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
      #iex> p2(example_string())
      #123

      #iex> p2(input_string())
      #123
  """
  def p2(input) do
    input
  end
end
