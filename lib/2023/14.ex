import AOC

aoc 2023, 14 do
  @moduledoc """
  https://adventofcode.com/2023/day/14
  """

  @doc """
      iex> p1(example_string())
      136

      iex> p1(input_string())
      102497
  """
  def p1(input) do
    input
    |> parse()
    |> tilt_north()
    #|> print_grid()
    |> calculate_weight()
  end

  @doc """
      iex> p2(example_string())
      64

      iex> p2(input_string())
      105008
  """
  def p2(input) do
    {grid, max_row, max_col} =
      input
      |> parse()

    {new_grid, tilt1, tilt2} = detect_cycle({grid, max_row, max_col}, 0)
    diff = tilt2 - tilt1
    remaining = 1000000000 - tilt1
    remaining = rem(remaining, diff) - 1
    {final_grid, _, _} =
      Enum.reduce(1..remaining, {new_grid, max_row, max_col}, fn _, {g, _, _} -> tilt_one_cycle({g, max_row, max_col}) end)

    #print_grid({final_grid, max_row, max_col})
    calculate_weight({final_grid, max_row, max_col})
  end

  defp detect_cycle({grid, max_row, max_col}, tilt_number) do
    if cached = Process.get(grid) do
      {new_grid, tilt1} = cached
      {new_grid, tilt1, tilt_number}
    else
      {new_grid, _, _} = tilt_one_cycle({grid, max_row, max_col})
      Process.put(grid, {new_grid, tilt_number})
      detect_cycle({new_grid, max_row, max_col}, tilt_number + 1)
    end
  end

  def tilt_one_cycle({grid, max_row, max_col}) do
    {grid, max_row, max_col}
    |> tilt_north()
    |> tilt_west()
    |> tilt_south()
    |> tilt_east()
  end

  def tilt_north({grid, max_row, max_col}) do
    columns =
      for col <- 0..max_col,
        into: [] do
          for row <- 0..max_row do
            grid[{row, col}]
          end
        end

    new_grid =
      columns
      |> Enum.map(fn col -> tilt(col, max_row) end)
      |> Enum.with_index()
      |> Enum.flat_map(fn {col, c} -> Enum.map(col, fn {r, v} -> {{r, c}, v} end) end)
      |> Enum.into(%{})
    {new_grid, max_row, max_col}
  end

  def tilt_south({grid, max_row, max_col}) do
    columns =
      for col <- 0..max_col,
        into: [] do
          for row <- max_row..0 do
            grid[{row, col}]
          end
        end

    new_grid =
      columns
      |> Enum.map(fn col -> tilt(col, max_row) end)
      |> Enum.with_index()
      |> Enum.flat_map(fn {col, c} -> Enum.map(col, fn {r, v} -> {{max_row - r, c}, v} end) end)
      |> Enum.into(%{})

    {new_grid, max_row, max_col}
  end

  def tilt_west({grid, max_row, max_col}) do
    rows =
      for row <- 0..max_row,
        into: [] do
          for col <- 0..max_col do
            grid[{row, col}]
          end
        end

    new_grid =
      rows
      |> Enum.map(fn col -> tilt(col, max_row) end)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, r} -> Enum.map(row, fn {c, v} -> {{r, c}, v} end) end)
      |> Enum.into(%{})

    {new_grid, max_row, max_col}
  end

  def tilt_east({grid, max_row, max_col}) do
    rows =
      for row <- 0..max_row,
        into: [] do
          for col <- max_col..0 do
            grid[{row, col}]
          end
        end

    new_grid =
      rows
      |> Enum.map(fn col -> tilt(col, max_row) end)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, r} -> Enum.map(row, fn {c, v} -> {{r, max_col - c}, v} end) end)
      |> Enum.into(%{})

    {new_grid, max_row, max_col}
  end

  def tilt(line, max_row) do
    l2 = Enum.with_index(line) |> Enum.map(fn {p, i} -> {i, p} end) |> Enum.into(%{})
    do_tilt(l2, 1, max_row)
  end

  def do_tilt(line, position_to_evaluate, max_row) when position_to_evaluate > max_row do
    line
  end

  def do_tilt(line, position_to_evaluate, max_row) do
    case line[position_to_evaluate] do
      "O" ->
        new_line = roll(line, position_to_evaluate)
        do_tilt(new_line, position_to_evaluate + 1, max_row)
      _ -> do_tilt(line, position_to_evaluate + 1, max_row)
    end
  end

  def roll(line, position_to_evaluate) do
    line
    #|> Enum.filter(fn {i, _} -> i < position_to_evaluate end)
    case can_roll?(line, position_to_evaluate - 1) do
      false -> line
      {true, to_pos} ->
        %{line | position_to_evaluate => ".", to_pos => "O"}
    end
  end

  def can_roll?(_line, -1), do: false
  def can_roll?(line, position_to_evaluate) do
    case line[position_to_evaluate] do
      "." ->
        case(line[position_to_evaluate - 1]) do
          "." -> can_roll?(line, position_to_evaluate - 1)
          _ -> {true, position_to_evaluate}
        end
      _ -> false
    end
  end

  def print_grid({grid, max_row, max_col}) do
    IO.puts("")
    for row <- 0..max_row do
      for col <- 0..max_col do
        IO.write(grid[{row, col}])
      end
      IO.puts("")
    end
    {grid, max_row, max_col}
  end

  def calculate_weight({grid, max_row, _max_col}) do
    grid
    |> Enum.filter(fn {{_r, _c}, v} -> v == "O" end)
    |> Enum.map(fn {{r, _c}, _v} -> max_row - r + 1 end)
    |> Enum.sum()
  end

  def parse(input) do
    grid =
      for {line, row} <- Enum.with_index(input |> String.split("\n")),
        {point, col} <- Enum.with_index(String.graphemes(line)),
        into: %{} do
          {{row, col}, point}
      end

    max_row = Enum.map(grid, fn {{r,_},_} -> r end) |> Enum.max()
    max_col = Enum.map(grid, fn {{_,c},_} -> c end) |> Enum.max()
    {grid, max_row, max_col}
  end
end
