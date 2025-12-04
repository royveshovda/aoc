import AOC

aoc 2015, 2 do
  @moduledoc """
  https://adventofcode.com/2015/day/2

  Day 2: I Was Told There Would Be No Math
  Calculate wrapping paper and ribbon needed for presents.
  """

  @doc """
  Part 1: Calculate total wrapping paper needed.

  Surface area = 2*l*w + 2*w*h + 2*h*l
  Plus slack = area of smallest side

  Examples:
  - 2x3x4 requires 2*6 + 2*12 + 2*8 = 52 square feet plus 6 slack = 58 total
  - 1x1x10 requires 2*1 + 2*10 + 2*10 = 42 square feet plus 1 slack = 43 total

      iex> p1("2x3x4")
      58

      iex> p1("1x1x10")
      43
  """
  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_dimensions/1)
    |> Enum.map(&calculate_paper/1)
    |> Enum.sum()
  end

  @doc """
  Part 2: Calculate total ribbon needed.

  Ribbon for wrapping = perimeter of smallest side
  Ribbon for bow = cubic volume (l * w * h)

  Examples:
  - 2x3x4 requires 2+2+3+3 = 10 feet for wrapping plus 2*3*4 = 24 for bow = 34 total
  - 1x1x10 requires 1+1+1+1 = 4 feet for wrapping plus 1*1*10 = 10 for bow = 14 total

      iex> p2("2x3x4")
      34

      iex> p2("1x1x10")
      14
  """
  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_dimensions/1)
    |> Enum.map(&calculate_ribbon/1)
    |> Enum.sum()
  end

  defp parse_dimensions(line) do
    line
    |> String.split("x")
    |> Enum.map(&String.to_integer/1)
  end

  defp calculate_paper([l, w, h]) do
    sides = [l * w, w * h, h * l]
    surface_area = Enum.sum(sides) * 2
    slack = Enum.min(sides)
    surface_area + slack
  end

  defp calculate_ribbon([l, w, h]) do
    # Sort dimensions to find two smallest
    [a, b, _c] = Enum.sort([l, w, h])

    # Perimeter of smallest side
    wrap = 2 * a + 2 * b

    # Cubic volume for bow
    bow = l * w * h

    wrap + bow
  end
end
