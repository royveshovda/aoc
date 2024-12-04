import AOC

aoc 2024, 4 do
  @moduledoc """
  https://adventofcode.com/2024/day/4
  """

  @doc """
      iex> p1(example_string())
  """
  def p1(input) do
    grid =
      input
      |> Utils.Grid.input_to_map()

    starts =
      grid
      |> Enum.filter(fn {{x, y}, el} -> el == "X" end)

    starts
    |> Enum.map(fn {pos, _el} -> find_xmas(grid, pos) end)
    |> Enum.sum()
  end

  def find_xmas(grid, {x,y}) do
    # -x,+y(NW)  +y(N)  +x,+y(NE)
    # -x(W)       X      +x (E)
    # -x,-y(SW)  -y(S)  +x,-y(SE)
    l_e = grid[{x + 1, y}] == "M" && grid[{x + 2, y}] == "A" && grid[{x + 3, y}] == "S"
    l_w = grid[{x - 1, y}] == "M" && grid[{x - 2, y}] == "A" && grid[{x - 3, y}] == "S"
    l_n = grid[{x, y + 1}] == "M" && grid[{x, y + 2}] == "A" && grid[{x, y + 3}] == "S"
    l_s = grid[{x, y - 1}] == "M" && grid[{x, y - 2}] == "A" && grid[{x, y - 3}] == "S"
    l_ne = grid[{x + 1, y + 1}] == "M" && grid[{x + 2, y + 2}] == "A" && grid[{x + 3, y + 3}] == "S"
    l_nw = grid[{x - 1, y + 1}] == "M" && grid[{x - 2, y + 2}] == "A" && grid[{x - 3, y + 3}] == "S"
    l_se = grid[{x + 1, y - 1}] == "M" && grid[{x + 2, y - 2}] == "A" && grid[{x + 3, y - 3}] == "S"
    l_sw = grid[{x - 1, y - 1}] == "M" && grid[{x - 2, y - 2}] == "A" && grid[{x - 3, y - 3}] == "S"
    # count number of true
    [l_e, l_w, l_n, l_s, l_ne, l_nw, l_se, l_sw]
    |> Enum.count(& &1)
  end

  @doc """
      iex> p2(example_string())
  """
  def p2(input) do
    grid =
      input
      |> Utils.Grid.input_to_map()

    starts =
      grid
      |> Enum.filter(fn {_pos, el} -> el == "A" end)

    starts
    |> Enum.count(fn {pos, _el} -> find_x_mas(grid, pos) end)
  end

  def find_x_mas(grid, {x,y}) do
    # -x,+y(NW)  +y(N)  +x,+y(NE)
    # -x(W)       X      +x (E)
    # -x,-y(SW)  -y(S)  +x,-y(SE)

    # M M
    #  A
    # S S
    l1 = grid[{x - 1, y + 1}] == "M"
      && grid[{x + 1, y + 1}] == "M"
      && grid[{x - 1, y - 1}] == "S"
      && grid[{x + 1, y - 1}] == "S"

    # M S
    #  A
    # M S
    l2 = grid[{x - 1, y + 1}] == "M"
      && grid[{x + 1, y + 1}] == "S"
      && grid[{x - 1, y - 1}] == "M"
      && grid[{x + 1, y - 1}] == "S"

    # S S
    #  A
    # M M
    l3 = grid[{x - 1, y + 1}] == "S"
      && grid[{x + 1, y + 1}] == "S"
      && grid[{x - 1, y - 1}] == "M"
      && grid[{x + 1, y - 1}] == "M"

    # S M
    #  A
    # S M
    l4 = grid[{x - 1, y + 1}] == "S"
      && grid[{x + 1, y + 1}] == "M"
      && grid[{x - 1, y - 1}] == "S"
      && grid[{x + 1, y - 1}] == "M"
    l1 || l2 || l3 || l4
  end
end
