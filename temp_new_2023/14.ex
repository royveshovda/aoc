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
    |> calculate_load()
  end

  @doc """
      iex> p2(example_string())
      64

      iex> p2(input_string())
      105008
  """
  def p2(input) do
    grid = parse(input)
    target = 1_000_000_000
    
    {grid, cycle_start, cycle_length} = find_cycle(grid)
    
    remaining = rem(target - cycle_start, cycle_length)
    
    final_grid = Enum.reduce(1..remaining, grid, fn _, g -> spin_cycle(g) end)
    calculate_load(final_grid)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, char} end)
    end)
    |> Map.new()
  end

  defp tilt_north(grid) do
    max_y = grid |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()
    max_x = grid |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()
    
    Enum.reduce(0..max_y, grid, fn y, g ->
      Enum.reduce(0..max_x, g, fn x, g2 ->
        if g2[{x, y}] == "O" do
          new_y = find_north_position(g2, x, y)
          g2 |> Map.put({x, y}, ".") |> Map.put({x, new_y}, "O")
        else
          g2
        end
      end)
    end)
  end

  defp find_north_position(grid, x, y) do
    Enum.reduce_while((y - 1)..0//-1, y, fn new_y, best ->
      case grid[{x, new_y}] do
        "." -> {:cont, new_y}
        _ -> {:halt, best}
      end
    end)
  end

  defp spin_cycle(grid) do
    grid |> tilt_north() |> tilt_west() |> tilt_south() |> tilt_east()
  end

  defp tilt_west(grid) do
    max_y = grid |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()
    max_x = grid |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()
    
    Enum.reduce(0..max_x, grid, fn x, g ->
      Enum.reduce(0..max_y, g, fn y, g2 ->
        if g2[{x, y}] == "O" do
          new_x = find_west_position(g2, x, y)
          g2 |> Map.put({x, y}, ".") |> Map.put({new_x, y}, "O")
        else
          g2
        end
      end)
    end)
  end

  defp find_west_position(grid, x, y) do
    Enum.reduce_while((x - 1)..0//-1, x, fn new_x, best ->
      case grid[{new_x, y}] do
        "." -> {:cont, new_x}
        _ -> {:halt, best}
      end
    end)
  end

  defp tilt_south(grid) do
    max_y = grid |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()
    max_x = grid |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()
    
    Enum.reduce(max_y..0//-1, grid, fn y, g ->
      Enum.reduce(0..max_x, g, fn x, g2 ->
        if g2[{x, y}] == "O" do
          new_y = find_south_position(g2, x, y, max_y)
          g2 |> Map.put({x, y}, ".") |> Map.put({x, new_y}, "O")
        else
          g2
        end
      end)
    end)
  end

  defp find_south_position(grid, x, y, max_y) do
    Enum.reduce_while((y + 1)..max_y, y, fn new_y, best ->
      case grid[{x, new_y}] do
        "." -> {:cont, new_y}
        _ -> {:halt, best}
      end
    end)
  end

  defp tilt_east(grid) do
    max_y = grid |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()
    max_x = grid |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()
    
    Enum.reduce(max_x..0//-1, grid, fn x, g ->
      Enum.reduce(0..max_y, g, fn y, g2 ->
        if g2[{x, y}] == "O" do
          new_x = find_east_position(g2, x, y, max_x)
          g2 |> Map.put({x, y}, ".") |> Map.put({new_x, y}, "O")
        else
          g2
        end
      end)
    end)
  end

  defp find_east_position(grid, x, y, max_x) do
    Enum.reduce_while((x + 1)..max_x, x, fn new_x, best ->
      case grid[{new_x, y}] do
        "." -> {:cont, new_x}
        _ -> {:halt, best}
      end
    end)
  end

  defp find_cycle(grid) do
    find_cycle(grid, %{}, 0)
  end

  defp find_cycle(grid, seen, iteration) do
    key = grid_key(grid)
    
    case Map.get(seen, key) do
      nil ->
        new_grid = spin_cycle(grid)
        find_cycle(new_grid, Map.put(seen, key, iteration), iteration + 1)
      prev_iteration ->
        {grid, prev_iteration, iteration - prev_iteration}
    end
  end

  defp grid_key(grid) do
    grid
    |> Enum.filter(fn {_, v} -> v == "O" end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sort()
  end

  defp calculate_load(grid) do
    max_y = grid |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()
    
    grid
    |> Enum.filter(fn {_, v} -> v == "O" end)
    |> Enum.map(fn {{_, y}, _} -> max_y - y + 1 end)
    |> Enum.sum()
  end
end
