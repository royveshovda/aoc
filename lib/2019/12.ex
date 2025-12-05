import AOC

aoc 2019, 12 do
  @moduledoc """
  https://adventofcode.com/2019/day/12
  The N-Body Problem - moon gravity simulation
  """

  def p1(input) do
    moons = parse(input)

    moons
    |> simulate(1000)
    |> total_energy()
  end

  def p2(input) do
    moons = parse(input)

    # Key insight: x, y, z axes are independent!
    # Find cycle for each axis, then take LCM
    cycle_x = find_cycle(moons, 0)
    cycle_y = find_cycle(moons, 1)
    cycle_z = find_cycle(moons, 2)

    lcm(lcm(cycle_x, cycle_y), cycle_z)
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      [x, y, z] =
        Regex.scan(~r/-?\d+/, line)
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)

      # Each moon: {position, velocity}
      {{x, y, z}, {0, 0, 0}}
    end)
  end

  defp simulate(moons, 0), do: moons

  defp simulate(moons, steps) do
    moons
    |> apply_gravity()
    |> apply_velocity()
    |> simulate(steps - 1)
  end

  defp apply_gravity(moons) do
    Enum.map(moons, fn {pos, vel} ->
      new_vel =
        Enum.reduce(moons, vel, fn {other_pos, _}, acc_vel ->
          add_gravity(acc_vel, pos, other_pos)
        end)

      {pos, new_vel}
    end)
  end

  defp add_gravity({vx, vy, vz}, {px, py, pz}, {ox, oy, oz}) do
    {
      vx + gravity_delta(px, ox),
      vy + gravity_delta(py, oy),
      vz + gravity_delta(pz, oz)
    }
  end

  defp gravity_delta(p1, p2) when p1 < p2, do: 1
  defp gravity_delta(p1, p2) when p1 > p2, do: -1
  defp gravity_delta(_, _), do: 0

  defp apply_velocity(moons) do
    Enum.map(moons, fn {{px, py, pz}, {vx, vy, vz}} ->
      {{px + vx, py + vy, pz + vz}, {vx, vy, vz}}
    end)
  end

  defp total_energy(moons) do
    moons
    |> Enum.map(fn {{px, py, pz}, {vx, vy, vz}} ->
      potential = abs(px) + abs(py) + abs(pz)
      kinetic = abs(vx) + abs(vy) + abs(vz)
      potential * kinetic
    end)
    |> Enum.sum()
  end

  # Find cycle for a single axis
  defp find_cycle(moons, axis) do
    initial_state = axis_state(moons, axis)
    find_cycle_loop(moons, axis, initial_state, 0)
  end

  defp find_cycle_loop(moons, axis, initial_state, step) do
    new_moons =
      moons
      |> apply_gravity()
      |> apply_velocity()

    new_step = step + 1

    if axis_state(new_moons, axis) == initial_state do
      new_step
    else
      find_cycle_loop(new_moons, axis, initial_state, new_step)
    end
  end

  # Extract state for just one axis (positions and velocities)
  defp axis_state(moons, axis) do
    Enum.map(moons, fn {pos, vel} ->
      {elem(pos, axis), elem(vel, axis)}
    end)
  end

  defp gcd(a, 0), do: a
  defp gcd(a, b), do: gcd(b, rem(a, b))

  defp lcm(a, b), do: div(a * b, gcd(a, b))
end
