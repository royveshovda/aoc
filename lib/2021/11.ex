import AOC

aoc 2021, 11 do
  @moduledoc """
  Day 11: Dumbo Octopus

  Simulate flashing octopuses on a 10x10 grid.
  Part 1: Count total flashes after 100 steps
  Part 2: Find first step where all octopuses flash simultaneously
  """

  @doc """
  Part 1: Count flashes after 100 steps.

  ## Examples

      iex> p1("5483143223\\n2745854711\\n5264556173\\n6141336146\\n6357385478\\n4167524645\\n2176841721\\n6882881134\\n4846848554\\n5283751526")
      1656
  """
  def p1(input) do
    grid = parse(input)

    {_grid, total_flashes} =
      Enum.reduce(1..100, {grid, 0}, fn _, {grid, flashes} ->
        {new_grid, step_flashes} = step(grid)
        {new_grid, flashes + step_flashes}
      end)

    total_flashes
  end

  @doc """
  Part 2: Find first step where all 100 octopuses flash.

  ## Examples

      iex> p2("5483143223\\n2745854711\\n5264556173\\n6141336146\\n6357385478\\n4167524645\\n2176841721\\n6882881134\\n4846848554\\n5283751526")
      195
  """
  def p2(input) do
    grid = parse(input)
    find_sync(grid, 1)
  end

  defp find_sync(grid, step) do
    {new_grid, flashes} = step(grid)

    if flashes == 100 do
      step
    else
      find_sync(new_grid, step + 1)
    end
  end

  defp step(grid) do
    # First, increment all by 1
    grid = Map.new(grid, fn {pos, energy} -> {pos, energy + 1} end)

    # Then, process flashes
    {grid, flashed} = flash_loop(grid, MapSet.new())

    # Reset flashed octopuses to 0
    grid = Enum.reduce(flashed, grid, fn pos, g -> Map.put(g, pos, 0) end)

    {grid, MapSet.size(flashed)}
  end

  defp flash_loop(grid, flashed) do
    # Find positions with energy > 9 that haven't flashed
    to_flash =
      grid
      |> Enum.filter(fn {pos, energy} -> energy > 9 and not MapSet.member?(flashed, pos) end)
      |> Enum.map(&elem(&1, 0))

    if to_flash == [] do
      {grid, flashed}
    else
      # Flash each one: increment all neighbors
      {grid, flashed} =
        Enum.reduce(to_flash, {grid, flashed}, fn pos, {g, f} ->
          g = increment_neighbors(g, pos)
          f = MapSet.put(f, pos)
          {g, f}
        end)

      flash_loop(grid, flashed)
    end
  end

  defp increment_neighbors(grid, {x, y}) do
    neighbors =
      for dx <- -1..1, dy <- -1..1, {dx, dy} != {0, 0} do
        {x + dx, y + dy}
      end

    Enum.reduce(neighbors, grid, fn pos, g ->
      if Map.has_key?(g, pos) do
        Map.update!(g, pos, &(&1 + 1))
      else
        g
      end
    end)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, String.to_integer(char)} end)
    end)
    |> Map.new()
  end
end
