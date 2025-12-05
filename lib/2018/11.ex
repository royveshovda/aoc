import AOC

aoc 2018, 11 do
  @moduledoc """
  https://adventofcode.com/2018/day/11
  """

  @doc """
  Calculate power level for a fuel cell at (x, y) with given serial number.

      iex> power_level(3, 5, 8)
      4
      iex> power_level(122, 79, 57)
      -5
      iex> power_level(217, 196, 39)
      0
      iex> power_level(101, 153, 71)
      4
  """
  def power_level(x, y, serial) do
    rack_id = x + 10
    power = rack_id * y
    power = power + serial
    power = power * rack_id
    hundreds_digit = div(power, 100) |> rem(10)
    hundreds_digit - 5
  end

  @doc """
  Find the 3x3 square with the largest total power.

      iex> p1("18")
      "33,45"
      iex> p1("42")
      "21,61"
  """
  def p1(input) do
    serial = String.trim(input) |> String.to_integer()

    # Build power grid
    grid = for x <- 1..300, y <- 1..300, into: %{} do
      {{x, y}, power_level(x, y, serial)}
    end

    # Find best 3x3 square
    {x, y, _power} = for x <- 1..298, y <- 1..298 do
      total = for dx <- 0..2, dy <- 0..2, reduce: 0 do
        acc -> acc + grid[{x + dx, y + dy}]
      end
      {x, y, total}
    end
    |> Enum.max_by(fn {_x, _y, power} -> power end)

    "#{x},#{y}"
  end

  @doc """
  Find the square (of any size) with the largest total power.

      iex> p2("18")
      "90,269,16"
      iex> p2("42")
      "232,251,12"
  """
  def p2(input) do
    serial = String.trim(input) |> String.to_integer()

    # Build power grid
    grid = for x <- 1..300, y <- 1..300, into: %{} do
      {{x, y}, power_level(x, y, serial)}
    end

    # Use summed area table for efficient square sum calculation
    sat = build_summed_area_table(grid)

    # Find best square of any size
    {x, y, size, _power} = for size <- 1..300,
                                x <- 1..(301 - size),
                                y <- 1..(301 - size) do
      total = square_sum(sat, x, y, size)
      {x, y, size, total}
    end
    |> Enum.max_by(fn {_x, _y, _size, power} -> power end)

    "#{x},#{y},#{size}"
  end

  # Build summed area table for O(1) rectangle sum queries
  defp build_summed_area_table(grid) do
    for x <- 1..300, y <- 1..300, reduce: %{} do
      sat ->
        value = grid[{x, y}]
        above = Map.get(sat, {x, y - 1}, 0)
        left = Map.get(sat, {x - 1, y}, 0)
        diagonal = Map.get(sat, {x - 1, y - 1}, 0)
        Map.put(sat, {x, y}, value + above + left - diagonal)
    end
  end

  # Calculate sum of square using summed area table
  defp square_sum(sat, x, y, size) do
    x2 = x + size - 1
    y2 = y + size - 1

    total = Map.get(sat, {x2, y2}, 0)
    above = Map.get(sat, {x2, y - 1}, 0)
    left = Map.get(sat, {x - 1, y2}, 0)
    diagonal = Map.get(sat, {x - 1, y - 1}, 0)

    total - above - left + diagonal
  end
end
