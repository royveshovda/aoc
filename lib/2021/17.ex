import AOC

aoc 2021, 17 do
  @moduledoc """
  Day 17: Trick Shot

  Fire probe into target area.
  Part 1: Find maximum height achievable
  Part 2: Count all valid initial velocities
  """

  @doc """
  Part 1: Find maximum height that still lands in target area.
  Math insight: max y velocity is |y_min| - 1, max height is n*(n+1)/2

  ## Examples

      iex> p1("target area: x=20..30, y=-10..-5")
      45
  """
  def p1(input) do
    {_x_range, y_range} = parse(input)
    y_min = Enum.min(y_range)

    # Max upward velocity that won't overshoot when falling back
    # When falling back, velocity at y=0 is -vy_initial-1
    # To hit target, need -vy_initial-1 >= y_min
    # So vy_max = |y_min| - 1
    vy_max = abs(y_min) - 1

    # Max height = sum of 1..vy_max = vy_max*(vy_max+1)/2
    div(vy_max * (vy_max + 1), 2)
  end

  @doc """
  Part 2: Count all initial velocities that land in target.

  ## Examples

      iex> p2("target area: x=20..30, y=-10..-5")
      112
  """
  def p2(input) do
    {x_range, y_range} = parse(input)
    x_min = Enum.min(x_range)
    x_max = Enum.max(x_range)
    y_min = Enum.min(y_range)
    y_max = Enum.max(y_range)

    # x velocity range: min is when dx reaches 0 at x_min
    # vx*(vx+1)/2 >= x_min, so vx >= sqrt(2*x_min) - 1
    # max is x_max (reach target in one step)
    vx_min = floor(:math.sqrt(2 * x_min)) - 1
    vx_max = x_max

    # y velocity range: min is y_min (reach bottom in one step)
    # max is |y_min| - 1 (as computed in part 1)
    vy_min = y_min
    vy_max = abs(y_min) - 1

    for vx <- vx_min..vx_max,
        vy <- vy_min..vy_max,
        hits_target?(vx, vy, x_range, y_range) do
      {vx, vy}
    end
    |> length()
  end

  defp hits_target?(vx, vy, x_range, y_range) do
    simulate(0, 0, vx, vy, x_range, y_range)
  end

  defp simulate(x, y, vx, vy, x_range, y_range) do
    cond do
      x in x_range and y in y_range ->
        true

      x > Enum.max(x_range) or y < Enum.min(y_range) ->
        false

      true ->
        # Update position
        x = x + vx
        y = y + vy
        # Update velocity
        vx = if vx > 0, do: vx - 1, else: if(vx < 0, do: vx + 1, else: 0)
        vy = vy - 1
        simulate(x, y, vx, vy, x_range, y_range)
    end
  end

  defp parse(input) do
    [x_min, x_max, y_min, y_max] =
      Regex.scan(~r/-?\d+/, input)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)

    {x_min..x_max, y_min..y_max}
  end
end
