import AOC

aoc 2018, 17 do
  @moduledoc """
  https://adventofcode.com/2018/day/17

  Day 17: Reservoir Research - Water flow simulation
  """

  @doc """
  Part 1: Count all tiles water can reach (flowing | and settled ~)

  ## Examples

      iex> input = "x=495, y=2..7\\ny=7, x=495..501\\nx=501, y=3..7\\nx=498, y=2..4\\nx=506, y=1..2\\nx=498, y=10..13\\nx=504, y=10..13\\ny=13, x=498..504"
      iex> p1(input)
      57
  """
  def p1(input) do
    {clay, min_y, max_y} = parse_input(input)
    water = simulate_water(clay, min_y, max_y)

    water
    |> Enum.count(fn {{_x, y}, _type} -> y >= min_y and y <= max_y end)
  end

  @doc """
  Part 2: Count only settled water (~)

  ## Examples

      iex> input = "x=495, y=2..7\\ny=7, x=495..501\\nx=501, y=3..7\\nx=498, y=2..4\\nx=506, y=1..2\\nx=498, y=10..13\\nx=504, y=10..13\\ny=13, x=498..504"
      iex> p2(input)
      29
  """
  def p2(input) do
    {clay, min_y, max_y} = parse_input(input)
    water = simulate_water(clay, min_y, max_y)

    water
    |> Enum.count(fn {{_x, y}, type} ->
      type == :settled and y >= min_y and y <= max_y
    end)
  end

  defp parse_input(input) do
    clay_positions =
      input
      |> String.split("\n", trim: true)
      |> Enum.flat_map(&parse_line/1)
      |> MapSet.new()

    ys = clay_positions |> Enum.map(fn {_x, y} -> y end)
    min_y = Enum.min(ys)
    max_y = Enum.max(ys)

    {clay_positions, min_y, max_y}
  end

  defp parse_line(line) do
    case Regex.run(~r/([xy])=(\d+), ([xy])=(\d+)\.\.(\d+)/, line) do
      [_, axis1, val1, _axis2, start2, end2] ->
        v1 = String.to_integer(val1)
        s2 = String.to_integer(start2)
        e2 = String.to_integer(end2)

        for v2 <- s2..e2 do
          if axis1 == "x", do: {v1, v2}, else: {v2, v1}
        end
    end
  end

  defp simulate_water(clay, _min_y, max_y) do
    # Start flowing from the spring
    pour(clay, %{}, {500, 0}, max_y)
  end

  defp pour(clay, water, {x, y} = pos, max_y) do
    cond do
      # Off the bottom
      y > max_y ->
        Map.put(water, pos, :flowing)

      # Already visited as settled - don't revisit
      Map.get(water, pos) == :settled ->
        water

      # Already visited as flowing - check if we can fill now
      Map.get(water, pos) == :flowing ->
        if has_floor?(clay, water, {x, y + 1}) do
          fill(clay, water, pos, max_y)
        else
          water
        end

      # New cell
      true ->
        # Mark as flowing
        water = Map.put(water, pos, :flowing)

        # Try to flow down
        water =
          if can_flow_to?(clay, water, {x, y + 1}) do
            pour(clay, water, {x, y + 1}, max_y)
          else
            water
          end

        # Check if we have floor below us now
        if has_floor?(clay, water, {x, y + 1}) do
          # Fill this row
          fill(clay, water, pos, max_y)
        else
          water
        end
    end
  end

  defp can_flow_to?(clay, water, pos) do
    not MapSet.member?(clay, pos) and not Map.has_key?(water, pos)
  end

  defp has_floor?(clay, water, pos) do
    MapSet.member?(clay, pos) or Map.get(water, pos) == :settled
  end

  defp fill(clay, water, {x, y}, max_y) do
    # Spread left and right
    left = spread_direction(clay, water, {x, y}, -1)
    right = spread_direction(clay, water, {x, y}, 1)

    left_bounded = elem(left, 1)
    right_bounded = elem(right, 1)
    left_x = elem(left, 0)
    right_x = elem(right, 0)

    # Mark all cells in this range
    water =
      for cx <- left_x..right_x, reduce: water do
        acc ->
          if left_bounded and right_bounded do
            # Settled water
            Map.put(acc, {cx, y}, :settled)
          else
            # Flowing water
            Map.put(acc, {cx, y}, :flowing)
          end
      end

    # Pour from unbounded edges (one row down from edge)
    water = if not left_bounded, do: pour(clay, water, {left_x, y + 1}, max_y), else: water
    water = if not right_bounded, do: pour(clay, water, {right_x, y + 1}, max_y), else: water

    # If we settled this row, try to fill the row above (water rises!)
    water = if left_bounded and right_bounded and y > 0 do
      # Try to fill each position in the settled row from above
      for cx <- left_x..right_x, reduce: water do
        acc ->
          above_pos = {cx, y - 1}
          if Map.get(acc, above_pos) == :flowing and has_floor?(clay, acc, {cx, y}) do
            fill(clay, acc, above_pos, max_y)
          else
            acc
          end
      end
    else
      water
    end

    water
  end

  defp spread_direction(clay, water, {x, y}, dx) do
    next_x = x + dx
    next_pos = {next_x, y}
    below_next = {next_x, y + 1}

    cond do
      # Hit a wall
      MapSet.member?(clay, next_pos) ->
        {x, true}

      # Floor disappeared
      not has_floor?(clay, water, below_next) ->
        {next_x, false}

      # Keep going
      true ->
        spread_direction(clay, water, next_pos, dx)
    end
  end
end
