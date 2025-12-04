import AOC

aoc 2017, 3 do
  @moduledoc """
  https://adventofcode.com/2017/day/3
  """

  def p1(input) do
    n = input |> String.trim() |> String.to_integer()

    # Find which ring the number is on
    ring = ceil((:math.sqrt(n) - 1) / 2)

    # Max number in this ring
    max_in_ring = (2 * ring + 1) * (2 * ring + 1)

    # Side length of this ring
    side_length = 2 * ring

    # Position in ring (0-indexed from start of ring)
    pos_in_ring = max_in_ring - n

    # Find offset from middle of side
    offset = rem(pos_in_ring, side_length)
    offset_from_middle = abs(offset - ring)

    ring + offset_from_middle
  end

  def p2(input) do
    n = input |> String.trim() |> String.to_integer()

    # Start at origin, move right
    grid = %{{0, 0} => 1}
    {x, y} = {1, 0}

    find_first_larger(grid, x, y, n)
  end

  defp find_first_larger(grid, x, y, target) do
    # Sum all 8 neighbors
    sum =
      [{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}]
      |> Enum.reduce(0, fn {dx, dy}, acc ->
        acc + Map.get(grid, {x + dx, y + dy}, 0)
      end)

    if sum > target do
      sum
    else
      new_grid = Map.put(grid, {x, y}, sum)
      {next_x, next_y} = get_next_pos(x, y, new_grid)
      find_first_larger(new_grid, next_x, next_y, target)
    end
  end

  defp get_next_pos(x, y, grid) do
    # Spiral pattern: R, U, L, D with increasing steps
    # Turn left if possible (empty cell to the left of current direction)
    right = {x + 1, y}
    up = {x, y - 1}
    left = {x - 1, y}
    down = {x, y + 1}

    cond do
      # If we can turn left (counterclockwise), do so
      not Map.has_key?(grid, right) and Map.has_key?(grid, down) -> right
      not Map.has_key?(grid, up) and Map.has_key?(grid, right) -> up
      not Map.has_key?(grid, left) and Map.has_key?(grid, up) -> left
      not Map.has_key?(grid, down) and Map.has_key?(grid, left) -> down
      # Otherwise keep going in the same direction
      not Map.has_key?(grid, right) -> right
      not Map.has_key?(grid, up) -> up
      not Map.has_key?(grid, left) -> left
      true -> down
    end
  end
end
