import AOC

aoc 2023, 10 do
  @moduledoc """
  https://adventofcode.com/2023/day/10
  """

  @doc """
      iex> p1(example_string())
      4

      iex> p1(example_string_p1_2())
      8

      iex> p1(input_string())
      6875
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

    first_steps =
      [north, south, east, west]
      |> Enum.filter(fn x -> x != nil end)

    start_pos = {start_row, start_col}
    first_step = Enum.at(first_steps, 0)



    steps = p1_step_forward(grid, start_pos, first_step, 1)
    trunc(steps / 2)
  end

  def p1_step_forward(_, _, {_, "S"}, steps) do
    steps
  end

  def p1_step_forward(grid, from, {pos, _pipe} = current, steps) do
    next_pos = step(from, current)
    next_val = grid[next_pos]
    next = {next_pos, next_val}
    p1_step_forward(grid, pos, next, steps + 1)
  end

  # Step North
  def step({from_row, from_col}, {{row, col}, "|"}) when from_row - 1 == row and from_col == col, do: {row - 1, col}
  def step({from_row, from_col}, {{row, col}, "F"}) when from_row - 1 == row and from_col == col, do: {row, col + 1}
  def step({from_row, from_col}, {{row, col}, "7"}) when from_row - 1 == row and from_col == col, do: {row, col - 1}

  # Step South
  def step({from_row, from_col}, {{row, col}, "|"}) when from_row + 1 == row and from_col == col, do: {row + 1, col}
  def step({from_row, from_col}, {{row, col}, "L"}) when from_row + 1 == row and from_col == col, do: {row, col + 1}
  def step({from_row, from_col}, {{row, col}, "J"}) when from_row + 1 == row and from_col == col, do: {row, col - 1}

  # Step West
  def step({from_row, from_col}, {{row, col}, "-"}) when from_row == row and from_col - 1 == col, do: {row, col - 1}
  def step({from_row, from_col}, {{row, col}, "L"}) when from_row == row and from_col - 1 == col, do: {row - 1, col}
  def step({from_row, from_col}, {{row, col}, "F"}) when from_row == row and from_col - 1 == col, do: {row + 1, col}

  # Step East
  def step({from_row, from_col}, {{row, col}, "-"}) when from_row == row and from_col + 1 == col, do: {row, col + 1}
  def step({from_row, from_col}, {{row, col}, "J"}) when from_row == row and from_col + 1 == col, do: {row - 1, col}
  def step({from_row, from_col}, {{row, col}, "7"}) when from_row == row and from_col + 1 == col, do: {row + 1, col}

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

  def example_string_p2_1() do
    """
    ...........
    .S-------7.
    .|F-----7|.
    .||.....||.
    .||.....||.
    .|L-7.F-J|.
    .|..|.|..|.
    .L--J.L--J.
    ...........
    """
  end

  def example_string_p2_2 do
    """
    .F----7F7F7F7F-7....
    .|F--7||||||||FJ....
    .||.FJ||||||||L7....
    FJL7L7LJLJ||LJ.L-7..
    L--J.L7...LJS7F-7L7.
    ....F-J..F7FJ|L7L7L7
    ....L7.F7||L7|.L7L7|
    .....|FJLJ|FJ|F7|.LJ
    ....FJL-7.||.||||...
    ....L---J.LJ.LJLJ...
    """
  end

  def example_string_p2_3 do
    """
    FF7FSF7F7F7F7F7F---7
    L|LJ||||||||||||F--J
    FL-7LJLJ||||||LJL-77
    F--JF--7||LJLJ7F7FJ-
    L---JF-JLJ.||-FJLJJ7
    |F|F-JF---7F7-L7L|7|
    |FFJF7L7F-JF7|JL---7
    7-L-JL7||F7|L7F-7F7|
    L.L7LFJ|||||FJL7||LJ
    L7JLJL-JLJLJL--JLJ.L
    """
  end

  @doc """
      iex> p2(example_string())
      1

      iex> p2(example_string_p2_1())
      4

      iex> p2(example_string_p2_2())
      8

      iex> p2(example_string_p2_3())
      10

      iex> p2(input_string())
      471
  """
  def p2(input) do
    grid =
      for {line, row} <- Enum.with_index(input |> String.split("\n")),
          {point, col} <- Enum.with_index(String.graphemes(line)),
          into: %{} do
        {{row, col}, point}
      end

    {pipe, start_pipe_element, start_pos} = get_pipe(grid)
    clean_grid = %{grid | start_pos => start_pipe_element}

    pipe_with_values =
      pipe
      |> Enum.map(fn {r,c} -> {{r,c}, clean_grid[{r,c}]} end)

    non_pipe =
      grid
      |> Enum.filter(fn {{r,c}, _v} -> {r,c} not in pipe end)
      |> Enum.map(fn {{r,c}, _v} -> {r,c} end)

    Enum.filter(non_pipe, fn {r,c} -> inside?(pipe_with_values, {r,c}) end)
    |> Enum.count()
  end

  def inside?(_pipe, {_row, 0}), do: false

  def inside?(pipe, {row, col}) do
    potential_passes_cols = for c <- 0..col - 1, do: {row, c}

    passes_cols =
      potential_passes_cols
      |> Enum.filter(fn {r,c} -> Enum.any?(pipe, fn {{r2,c2},_v} -> r==r2 and c==c2 end) end)
      |> Enum.map(fn {r,c} -> Enum.find(pipe, fn {{r2,c2},_v} -> r==r2 and c==c2 end) end)

    elements_count = count_line_segments(passes_cols)
    rem(elements_count, 2) == 1
  end

  def count_line_segments(slice) do
    vert = Enum.filter(slice, fn {{_r,_c}, v} -> v == "|" end) |> Enum.count()
    l7_count = count_l7_line_segments(slice)
    fj_count = count_fj_line_segments(slice)

    vert + l7_count + fj_count
  end

  def count_l7_line_segments(slice) do
    slice
    |> Enum.filter(fn {_, v} -> v == "L" end)
    |> Enum.map(fn {pos, _v} -> verify_l7_segment(pos, slice) end)
    |> Enum.filter(fn x -> x == true end)
    |> Enum.count()
  end

  def count_fj_line_segments(slice) do
    slice
    |> Enum.filter(fn {_, v} -> v == "F" end)
    |> Enum.map(fn {pos, _v} -> verify_fj_segment(pos, slice) end)
    |> Enum.filter(fn x -> x == true end)
    |> Enum.count()
  end

  def verify_fj_segment({row,col}, slice) do
    next = Enum.find(slice, fn {{r,c}, _v} -> r == row and c == col + 1  end)
    {_, next_val} = next
    case next_val do
      "J" -> true
      "-" -> verify_fj_segment({row,col+1}, slice)
      _ -> false
    end
  end


  def verify_l7_segment({row,col}, slice) do
    next = Enum.find(slice, fn {{r,c}, _v} -> r == row and c == col + 1  end)
    {_, next_val} = next
    case next_val do
      "7" -> true
      "-" -> verify_l7_segment({row,col+1}, slice)
      _ -> false
    end
  end


  def get_pipe(grid) do
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

    first_steps =
      [north, south, east, west]
      |> Enum.filter(fn x -> x != nil end)

    start_pos = {start_row, start_col}
    first_step = Enum.at(first_steps, 0)
    pipe = build_pipe(grid, start_pos, first_step, [start_pos])

    start_pipe_element = get_start_pipe_type(north, south, east, west)
    {pipe, start_pipe_element, start_pos}
  end

  def get_start_pipe_type(north, south, east, west) do
    case {north, south, east, west} do
      {_north,_south, nil, nil} -> "|"
      {_north,nil, _west, nil} -> "J"
      {_north,nil, nil, _east} -> "L"
      {nil,_south, _east, nil} -> "F"
      {nil,_south, nil, _west} -> "7"
    end
  end

  def build_pipe(_, _, {_, "S"}, pipe) do
    pipe
  end

  def build_pipe(grid, from, {pos, _pipe} = current, pipe) do
    next_pos = step(from, current)
    next_val = grid[next_pos]
    next = {next_pos, next_val}
    build_pipe(grid, pos, next, [pos | pipe])
  end
end
