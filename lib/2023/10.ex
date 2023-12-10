import AOC

aoc 2023, 10 do
  @moduledoc """
  https://adventofcode.com/2023/day/10
  """

  @doc """
      iex> p1(example_string())
      4

      #iex> p1(example_string_p1_2())
      #8

      #iex> p1(input_string())
      #123
  """
  def p1(input) do
    grid =
      for {line, row} <- Enum.with_index(input |> String.split("\n")),
          {point, col} <- Enum.with_index(String.graphemes(line)),
          into: %{} do
        {{row, col}, point}
      end

    start = Enum.find(grid, fn {_, point} -> point == "S" end)

    {{start_row, start_col}, "S"} = start

    step_north_must_be = ["|", "7", "F"]
    step_south_must_be = ["|", "L", "J"]
    step_west_must_be = ["-", "L", "F"]
    step_east_must_be = ["-", "7", "J"]
    north = Enum.find(grid, fn {{r,c},v} -> r == start_row-1 and c == start_col and v in step_north_must_be end)
    south = Enum.find(grid, fn {{r,c},v} -> r == start_row+1 and c == start_col and v in step_south_must_be end)
    east = Enum.find(grid, fn {{r,c},v} -> r == start_row and c == start_col+1 and v in step_east_must_be end)
    west = Enum.find(grid, fn {{r,c},v} -> r == start_row and c == start_col-1 and v in step_west_must_be end)

    first_step =
      [north, south, east, west]
      |> Enum.filter(fn x -> x != nil end)

    start_pos = {start_row, start_col}
    IO.inspect(start)
    IO.inspect(south)
    #first_step
    #step({start_row, start_col}, south)

  end

  # Step North
  def step({from_row, from_col}, {{row, col}, "|"}) when from_row + 1 == row and from_col == col, do: {row + 1, col}
  def step({from_row, from_col}, {{row, col}, "F"}) when from_row + 1 == row and from_col == col, do: {row, col + 1}
  def step({from_row, from_col}, {{row, col}, "7"}) when from_row + 1 == row and from_col == col, do: {row, col - 1}

  # Step South
  def step({from_row, from_col}, {{row, col}, "|"}) when from_row - 1 == row and from_col == col, do: {row - 1, col}
  def step({from_row, from_col}, {{row, col}, "L"}) when from_row - 1 == row and from_col == col, do: {row, col + 1}
  def step({from_row, from_col}, {{row, col}, "J"}) when from_row - 1 == row and from_col == col, do: {row, col - 1}

  # Step West
  def step({from_row, from_col}, {{row, col}, "-"}) when from_row == row and from_col - 1 == col, do: {row, col - 1}
  def step({from_row, from_col}, {{row, col}, "L"}) when from_row == row and from_col - 1 == col, do: {row + 1, col}
  def step({from_row, from_col}, {{row, col}, "F"}) when from_row == row and from_col - 1 == col, do: {row - 1, col}

  # Step East
  def step({from_row, from_col}, {{row, col}, "-"}) when from_row == row and from_col + 1 == col, do: {row, col + 1}
  def step({from_row, from_col}, {{row, col}, "J"}) when from_row == row and from_col + 1 == col, do: {row + 1, col}
  def step({from_row, from_col}, {{row, col}, "7"}) when from_row == row and from_col + 1 == col, do: {row - 1, col}

  def step({_from_row, _from_col}, {{_row, _col}, _pipe_element}), do: :not_supported

  def example_string_p1_2() do
    """
    ..F7.
    .FJ|.
    SJ.L7
    |F--J
    LJ...
    """
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
