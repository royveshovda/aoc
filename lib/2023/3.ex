import AOC

aoc 2023, 3 do
  @moduledoc """
  https://adventofcode.com/2023/day/3
  """

  @doc """
      iex> p1(example_string())
      4361

      iex> p1(input_string())
      527364
  """
  def p1(input) do
    grid =
      input
      |> parse()

    {_grid, _visited, numbers} =
      Enum.reduce(grid, {grid, [], []}, fn {coord, _value}, {grid, visited, parts} ->
        expand_pos(grid, coord, visited, parts)
      end)

    Enum.sum(numbers)
  end

  @doc """
      iex> p2(example_string())
      467835

      iex> p2(input_string())
      79026871

  """
  def p2(input) do
    grid =
      input
      |> parse()

    {_grid, _visited, numbers} =
      Enum.reduce(grid, {grid, [], []}, fn {coord, _value}, {grid, visited, parts} ->
        expand_pos_for_gear(grid, coord, visited, parts)
      end)


    gear_list =
      Enum.filter(numbers, fn {_number, [g1], start_pos1} -> Enum.any?(numbers, fn {_number, [g2], start_pos2} -> g1 == g2 and start_pos1 != start_pos2 end) end)

    Enum.map(gear_list, fn {number1, [g1], start_pos1} ->
      {number2, [_g2], _start_pos2} = Enum.find(numbers, fn {_number2, [g2], start_pos2} -> g1 == g2 and start_pos1 != start_pos2 end)
      {g1, number1, number2} end)
    |> Enum.uniq_by(fn {g1, _number1, _number2} -> g1 end)
    |> Enum.map(fn {_g1, number1, number2} -> number1 * number2 end)
    |> Enum.sum()
  end

  def parse(input) do
    for {line, row} <- Enum.with_index(input |> String.split("\n")),
        {value, col} <- Enum.with_index(String.graphemes(line)),
        into: %{} do
      {{row, col}, value}
    end
  end

  def expand_pos_for_gear(grid, coord, visited, parts) do
    # check if number is in visited numbers
    case visited?(coord, visited) do
      true -> {grid, visited, parts} # do nothing
      false ->
        case (number?(grid[coord])) do
          true -> # add to visited and parts
            {new_visited, number} = expand_number_in_pos(grid, coord)
            case gear?(grid, new_visited) do
              {true, gear_symbols, start_pos} -> # add to parts
                v = visited ++ new_visited
                p = parts ++ [{number, gear_symbols, start_pos}]
                {grid, v, p}
              {false, _, _} -> # add to visited
                v = visited ++ new_visited
                {grid, v, parts}
            end
          false -> # add to visited and parts
            {grid, visited, parts}
        end
    end
  end

  def expand_pos(grid, coord, visited, parts) do
    # check if number is in visited numbers
    case visited?(coord, visited) do
      true -> {grid, visited, parts} # do nothing
      false ->
        case (number?(grid[coord])) do
          true -> # add to visited and parts
            {new_visited, number} = expand_number_in_pos(grid, coord)
            case part_number?(grid, new_visited) do
              true -> # add to parts
                v = visited ++ new_visited
                p = parts ++ [number]
                {grid, v, p}
              false -> # add to visited
                v = visited ++ new_visited
                {grid, v, parts}
            end
          false -> # add to visited and parts
            {grid, visited, parts}
        end
    end
  end

  def expand_number_in_pos(grid, coord) do
    number_positions = do_expand_number_in_pos(grid, [coord], [coord])

  number =
    number_positions
    |> Enum.sort(fn {_row1, col1}, {_row2, col2} -> col1 < col2 end)
    |> Enum.map(fn {row, col} -> grid[{row, col}] end)
    |> Enum.join()
    |> String.to_integer()
  {number_positions, number}
  end

  def do_expand_number_in_pos(grid, expand, visited) do
    next =
      expand
      |> Enum.flat_map(fn {row, col} ->
        [{row, col + 1}, {row, col - 1}]
        |> Enum.filter(&number?(grid[&1]))
        |> Enum.filter(&!visited?(&1, visited))
      end)

    case next do
      [] -> visited
      _ -> do_expand_number_in_pos(grid, next, visited ++ next)
    end
  end

  def part_number?(grid, coords_in_number) do
    # check if number has any adjacent symbols
    expanded_coords =
      Enum.flat_map(coords_in_number, fn {row, col} ->
        [{row-1, col-1}, {row-1, col}, {row-1, col+1},
        {row, col-1}, {row, col+1},
        {row+1, col-1}, {row+1, col}, {row+1, col+1}] end)
    Enum.any?(expanded_coords, fn coord -> symbol?(grid[coord]) end)
  end

  def gear?(grid, coords_in_number) do
    # check if number has any adjacent symbols
    expanded_coords =
      Enum.flat_map(coords_in_number, fn {row, col} ->
        [{row-1, col-1}, {row-1, col}, {row-1, col+1},
        {row, col-1}, {row, col+1},
        {row+1, col-1}, {row+1, col}, {row+1, col+1}] end)
    gear_symbols = Enum.filter(expanded_coords, fn coord -> gear_symbol?(grid[coord]) end) |> Enum.uniq()
    is_gear = Enum.any?(expanded_coords, fn coord -> gear_symbol?(grid[coord]) end)
    number_start_pos = Enum.min(coords_in_number, fn {_row1, col1}, {_row2, col2} -> col1 < col2 end)
    {is_gear, gear_symbols, number_start_pos}
  end

  defp visited?(coord, visited) do
    coord in visited
  end

  defp number?(char) do
    char in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
  end

  defp symbol?(char) do
    char in ["&", "*", "/", "-", "%", "=", "@", "$", "#", "+"]
  end

  defp gear_symbol?(char) do
    char == "*"
  end
end
