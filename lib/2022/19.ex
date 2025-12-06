import AOC

aoc 2022, 19 do
  @moduledoc """
  Day 19: Not Enough Minerals

  Build robots to maximize geode collection.
  Part 1: Sum of quality levels (id * geodes in 24 min).
  Part 2: Product of geodes from first 3 blueprints in 32 min.

  Optimization: DFS with "time-to-build" - instead of deciding each minute,
  decide which robot to build next and skip to when we can afford it.
  """

  @doc """
  Part 1: Sum of quality levels across all blueprints.
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(fn bp -> bp.id * max_geodes(bp, 24) end)
    |> Enum.sum()
  end

  @doc """
  Part 2: Product of geodes from first 3 blueprints in 32 min.
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.take(3)
    |> Enum.map(fn bp -> max_geodes(bp, 32) end)
    |> Enum.product()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [id, ore_ore, clay_ore, obs_ore, obs_clay, geo_ore, geo_obs] =
        Regex.scan(~r/\d+/, line) |> List.flatten() |> Enum.map(&String.to_integer/1)

      # Store as tuples for faster access: {ore_cost, clay_cost, obsidian_cost}
      %{
        id: id,
        ore: {ore_ore, 0, 0},
        clay: {clay_ore, 0, 0},
        obsidian: {obs_ore, obs_clay, 0},
        geode: {geo_ore, 0, geo_obs},
        max_ore: Enum.max([ore_ore, clay_ore, obs_ore, geo_ore]),
        max_clay: obs_clay,
        max_obs: geo_obs
      }
    end)
  end

  defp max_geodes(bp, time_limit) do
    # State: {time, ore, clay, obsidian, geodes, ore_robots, clay_robots, obs_robots, geo_robots}
    initial = {time_limit, 0, 0, 0, 0, 1, 0, 0, 0}
    dfs(initial, bp, 0)
  end

  # DFS with pruning - decide which robot to build NEXT and skip to that time
  defp dfs({time, _ore, _clay, _obs, geo, _ore_r, _clay_r, _obs_r, geo_r} = state, bp, best) do
    # If no time left, return geodes collected
    if time <= 0 do
      max(best, geo)
    else
      # Upper bound: current geodes + geodes from existing robots + theoretical max new robots
      # If we built a geode robot every remaining minute
      upper_bound = geo + geo_r * time + div(time * (time - 1), 2)

      if upper_bound <= best do
        best
      else
        # Try building each robot type (decide what to build NEXT, skip to when we can afford it)
        best = try_build_robot(state, bp, :geode, best)
        best = try_build_robot(state, bp, :obsidian, best)
        best = try_build_robot(state, bp, :clay, best)
        best = try_build_robot(state, bp, :ore, best)

        # Also consider: don't build anything else, just collect with current robots
        final_geo = geo + geo_r * time
        max(best, final_geo)
      end
    end
  end

  defp try_build_robot({time, ore, clay, obs, geo, ore_r, clay_r, obs_r, geo_r}, bp, robot_type, best) do
    {ore_cost, clay_cost, obs_cost} = Map.get(bp, robot_type)

    # Check if we should even try building this robot
    should_build = case robot_type do
      :geode -> true  # Always want more geode robots
      :obsidian -> obs_r < bp.max_obs  # Don't build more than we can use
      :clay -> clay_r < bp.max_clay
      :ore -> ore_r < bp.max_ore
    end

    # Check if we CAN ever build this (have the right robot types)
    can_ever_build = case robot_type do
      :geode -> obs_r > 0  # Need obsidian robots
      :obsidian -> clay_r > 0  # Need clay robots
      :clay -> true
      :ore -> true
    end

    if not should_build or not can_ever_build do
      best
    else
      # Calculate time needed to afford this robot
      wait_time = time_to_afford(ore, clay, obs, ore_r, clay_r, obs_r, ore_cost, clay_cost, obs_cost)

      if wait_time >= time do
        # Can't build in time
        best
      else
        # Fast-forward: collect resources for wait_time, then build
        new_time = time - wait_time - 1
        new_ore = ore + ore_r * (wait_time + 1) - ore_cost
        new_clay = clay + clay_r * (wait_time + 1) - clay_cost
        new_obs = obs + obs_r * (wait_time + 1) - obs_cost
        new_geo = geo + geo_r * (wait_time + 1)

        {new_ore_r, new_clay_r, new_obs_r, new_geo_r} = case robot_type do
          :ore -> {ore_r + 1, clay_r, obs_r, geo_r}
          :clay -> {ore_r, clay_r + 1, obs_r, geo_r}
          :obsidian -> {ore_r, clay_r, obs_r + 1, geo_r}
          :geode -> {ore_r, clay_r, obs_r, geo_r + 1}
        end

        new_state = {new_time, new_ore, new_clay, new_obs, new_geo, new_ore_r, new_clay_r, new_obs_r, new_geo_r}
        dfs(new_state, bp, best)
      end
    end
  end

  # Calculate how many minutes until we can afford {ore_cost, clay_cost, obs_cost}
  defp time_to_afford(ore, clay, obs, ore_r, clay_r, obs_r, ore_cost, clay_cost, obs_cost) do
    ore_wait = if ore >= ore_cost, do: 0, else: div(ore_cost - ore + ore_r - 1, max(ore_r, 1))
    clay_wait = if clay >= clay_cost or clay_cost == 0, do: 0, else: div(clay_cost - clay + clay_r - 1, max(clay_r, 1))
    obs_wait = if obs >= obs_cost or obs_cost == 0, do: 0, else: div(obs_cost - obs + obs_r - 1, max(obs_r, 1))

    Enum.max([ore_wait, clay_wait, obs_wait])
  end
end
