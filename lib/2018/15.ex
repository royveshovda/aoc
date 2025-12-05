import AOC

aoc 2018, 15 do
  @moduledoc """
  https://adventofcode.com/2018/day/15

  Day 15: Beverage Bandits - Combat simulation between Elves and Goblins
  """

  @doc """
  Part 1: Calculate the outcome of combat (full rounds × total HP remaining)

  ## Examples

      iex> input = "#######\\n#.G...#\\n#...EG#\\n#.#.#G#\\n#..G#E#\\n#.....#\\n#######"
      iex> p1(input)
      27730

      iex> input = "#######\\n#G..#E#\\n#E#E.E#\\n#G.##.#\\n#...#E#\\n#...E.#\\n#######"
      iex> p1(input)
      36334

      iex> input = "#######\\n#E..EG#\\n#.#G.E#\\n#E.##E#\\n#G..#.#\\n#..E#.#\\n#######"
      iex> p1(input)
      39514

      iex> input = "#######\\n#E.G#.#\\n#.#G..#\\n#G.#.G#\\n#G..#.#\\n#...E.#\\n#######"
      iex> p1(input)
      27755

      iex> input = "#######\\n#.E...#\\n#.#..G#\\n#.###.#\\n#E#G#G#\\n#...#G#\\n#######"
      iex> p1(input)
      28944

      iex> input = "#########\\n#G......#\\n#.E.#...#\\n#..##..G#\\n#...##..#\\n#...#...#\\n#.G...G.#\\n#.....G.#\\n#########"
      iex> p1(input)
      18740
  """
  def p1(input) do
    {grid, units} = parse_input(input)
    {rounds, remaining_units} = simulate_combat(grid, units, 3)
    total_hp = remaining_units |> Map.values() |> Enum.map(& &1.hp) |> Enum.sum()
    rounds * total_hp
  end

  @doc """
  Part 2: Find minimum elf attack power where no elves die

  ## Examples

      iex> input = "#######\\n#.G...#\\n#...EG#\\n#.#.#G#\\n#..G#E#\\n#.....#\\n#######"
      iex> p2(input)
      4988

      iex> input = "#######\\n#E..EG#\\n#.#G.E#\\n#E.##E#\\n#G..#.#\\n#..E#.#\\n#######"
      iex> p2(input)
      31284

      iex> input = "#######\\n#E.G#.#\\n#.#G..#\\n#G.#.G#\\n#G..#.#\\n#...E.#\\n#######"
      iex> p2(input)
      3478

      iex> input = "#######\\n#.E...#\\n#.#..G#\\n#.###.#\\n#E#G#G#\\n#...#G#\\n#######"
      iex> p2(input)
      6474

      iex> input = "#########\\n#G......#\\n#.E.#...#\\n#..##..G#\\n#...##..#\\n#...#...#\\n#.G...G.#\\n#.....G.#\\n#########"
      iex> p2(input)
      1140
  """
  def p2(input) do
    {grid, units} = parse_input(input)
    elf_count = units |> Map.values() |> Enum.count(&(&1.type == :elf))

    find_min_attack_power(grid, units, elf_count, 4)
  end

  defp find_min_attack_power(grid, units, elf_count, attack_power) do
    case simulate_combat_check_elves(grid, units, attack_power, elf_count) do
      {:success, rounds, remaining_units} ->
        total_hp = remaining_units |> Map.values() |> Enum.map(& &1.hp) |> Enum.sum()
        rounds * total_hp
      :elf_died ->
        find_min_attack_power(grid, units, elf_count, attack_power + 1)
    end
  end

  defp simulate_combat_check_elves(grid, units, elf_attack_power, elf_count) do
    case do_combat(grid, units, 0, elf_attack_power, {:check_elves, elf_count}) do
      {:elf_died, _rounds, _units} -> :elf_died
      {rounds, remaining_units} -> {:success, rounds, remaining_units}
    end
  end

  defp parse_input(input) do
    lines = input |> String.split("\n", trim: true)

    {grid, units} =
      lines
      |> Enum.with_index()
      |> Enum.reduce({%{}, %{}}, fn {line, y}, {grid_acc, units_acc} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce({grid_acc, units_acc}, fn {char, x}, {g, u} ->
          pos = {x, y}
          case char do
            "#" -> {Map.put(g, pos, :wall), u}
            "." -> {Map.put(g, pos, :open), u}
            " " -> {g, u}  # Skip spaces (from formatted examples)
            "E" -> {Map.put(g, pos, :open), Map.put(u, pos, %{type: :elf, hp: 200})}
            "G" -> {Map.put(g, pos, :open), Map.put(u, pos, %{type: :goblin, hp: 200})}
            _ -> {g, u}  # Skip any other characters (numbers, etc from examples)
          end
        end)
      end)

    {grid, units}
  end

  defp simulate_combat(grid, units, elf_attack_power) do
    do_combat(grid, units, 0, elf_attack_power, :no_limit)
  end

  defp do_combat(grid, units, rounds, elf_attack_power, elf_limit) do
    # Get units in turn order (reading order)
    turn_order = units |> Map.keys() |> Enum.sort_by(fn {x, y} -> {y, x} end)

    case take_turns(grid, units, turn_order, elf_attack_power, elf_limit) do
      {:continue, new_units} -> do_combat(grid, new_units, rounds + 1, elf_attack_power, elf_limit)
      {:end_combat, new_units} -> {rounds, new_units}
      {:elf_died, new_units} -> {:elf_died, rounds, new_units}
    end
  end

  defp take_turns(_grid, units, [], _elf_attack_power, _elf_limit), do: {:continue, units}

  defp take_turns(grid, units, [pos | rest], elf_attack_power, elf_limit) do
    # Check if this unit is still alive
    case Map.get(units, pos) do
      nil -> take_turns(grid, units, rest, elf_attack_power, elf_limit)
      unit ->
        # Check if there are any targets
        targets = get_targets(units, unit.type)
        if Enum.empty?(targets) do
          {:end_combat, units}
        else
          # Take turn: move (if needed) and attack (if possible)
          {_new_pos, new_units} = take_turn(grid, units, pos, unit, elf_attack_power)

          # Check if an elf died (for part 2)
          case elf_limit do
            {:check_elves, expected_count} ->
              current_elf_count = new_units |> Map.values() |> Enum.count(&(&1.type == :elf))
              if current_elf_count < expected_count do
                {:elf_died, new_units}
              else
                take_turns(grid, new_units, rest, elf_attack_power, elf_limit)
              end
            _ ->
              take_turns(grid, new_units, rest, elf_attack_power, elf_limit)
          end
        end
    end
  end

  defp get_targets(units, unit_type) do
    enemy_type = if unit_type == :elf, do: :goblin, else: :elf
    units
    |> Enum.filter(fn {_pos, u} -> u.type == enemy_type end)
    |> Enum.map(fn {pos, _u} -> pos end)
  end

  defp take_turn(grid, units, pos, unit, elf_attack_power) do
    # Check if already in range to attack
    targets = get_targets(units, unit.type)
    adjacent = get_adjacent(pos)

    # Check if any adjacent position has an enemy
    in_range = Enum.any?(adjacent, fn adj_pos ->
      case Map.get(units, adj_pos) do
        nil -> false
        u -> u.type != unit.type
      end
    end)

    {new_pos, units_after_move} =
      if in_range do
        {pos, units}
      else
        # Try to move
        move_unit(grid, units, pos, unit, targets)
      end

    # Try to attack
    units_after_attack = attack(units_after_move, new_pos, unit, elf_attack_power)

    {new_pos, units_after_attack}
  end

  defp move_unit(grid, units, pos, unit, targets) do
    # Remove the moving unit from the units map for pathfinding
    units_without_self = Map.delete(units, pos)

    # Find all in-range positions (open squares adjacent to targets)
    in_range_positions =
      targets
      |> Enum.flat_map(&get_adjacent/1)
      |> Enum.filter(fn p -> is_open?(grid, units_without_self, p) end)
      |> Enum.uniq()

    if Enum.empty?(in_range_positions) do
      {pos, units}
    else
      # Find closest in-range position using BFS
      case find_closest_position(grid, units_without_self, pos, in_range_positions) do
        nil -> {pos, units}
        target_pos ->
          # Find the first step toward target
          next_pos = find_first_step(grid, units_without_self, pos, target_pos)
          # Move the unit
          units_moved = units |> Map.delete(pos) |> Map.put(next_pos, unit)
          {next_pos, units_moved}
      end
    end
  end

  defp find_closest_position(grid, units, start, targets) do
    # BFS to find the closest target (in reading order for ties)
    queue = :queue.from_list([{start, 0}])
    visited = MapSet.new([start])

    find_closest_bfs(grid, units, queue, visited, targets, nil, nil)
  end

  defp find_closest_bfs(grid, units, queue, visited, targets, best_dist, best_pos) do
    case :queue.out(queue) do
      {:empty, _} ->
        best_pos
      {{:value, {pos, dist}}, new_queue} ->
        cond do
          # If we've found a target and this distance is greater, stop
          best_dist != nil and dist > best_dist ->
            best_pos

          # If this position is a target
          pos in targets ->
            # Keep searching at this distance for better reading order
            new_best = if best_pos == nil or reading_order(pos) < reading_order(best_pos) do
              pos
            else
              best_pos
            end
            find_closest_bfs(grid, units, new_queue, visited, targets, dist, new_best)

          true ->
            # Add adjacent positions
            adjacent = get_adjacent(pos)
            {updated_queue, updated_visited} =
              adjacent
              |> Enum.filter(fn p -> is_open?(grid, units, p) and not MapSet.member?(visited, p) end)
              |> Enum.reduce({new_queue, visited}, fn p, {q, v} ->
                {:queue.in({p, dist + 1}, q), MapSet.put(v, p)}
              end)

            find_closest_bfs(grid, units, updated_queue, updated_visited, targets, best_dist, best_pos)
        end
    end
  end

  defp find_first_step(grid, units, start, target) do
    # BFS from target backward to find distances to all positions
    queue = :queue.from_list([{target, 0}])
    visited = %{target => 0}

    # Find distances from target to all reachable positions
    distances = bfs_distances_from_target(grid, units, queue, visited)

    if Map.has_key?(distances, start) do
      # Find which adjacent cell is closest to target (reading order for ties)
      start
      |> get_adjacent()
      |> Enum.filter(fn p -> Map.has_key?(distances, p) end)
      |> Enum.sort_by(fn p -> {Map.get(distances, p), reading_order(p)} end)
      |> List.first()
      |> Kernel.||(start)
    else
      start
    end
  end

  defp bfs_distances_from_target(grid, units, queue, distances) do
    case :queue.out(queue) do
      {:empty, _} ->
        distances
      {{:value, {pos, dist}}, new_queue} ->
        adjacent = get_adjacent(pos)
        {updated_queue, updated_distances} =
          adjacent
          |> Enum.filter(fn p -> is_open?(grid, units, p) and not Map.has_key?(distances, p) end)
          |> Enum.reduce({new_queue, distances}, fn p, {q, d} ->
            {:queue.in({p, dist + 1}, q), Map.put(d, p, dist + 1)}
          end)

        bfs_distances_from_target(grid, units, updated_queue, updated_distances)
    end
  end


  defp attack(units, pos, unit, elf_attack_power) do
    adjacent = get_adjacent(pos)
    enemy_type = if unit.type == :elf, do: :goblin, else: :elf

    # Find adjacent enemies
    adjacent_enemies =
      adjacent
      |> Enum.filter(fn p ->
        case Map.get(units, p) do
          nil -> false
          u -> u.type == enemy_type
        end
      end)

    if Enum.empty?(adjacent_enemies) do
      units
    else
      # Select target: lowest HP, then reading order
      target_pos =
        adjacent_enemies
        |> Enum.min_by(fn p ->
          u = Map.get(units, p)
          {u.hp, reading_order(p)}
        end)

      target = Map.get(units, target_pos)
      attack_power = if unit.type == :elf, do: elf_attack_power, else: 3
      new_hp = target.hp - attack_power

      if new_hp <= 0 do
        Map.delete(units, target_pos)
      else
        Map.put(units, target_pos, %{target | hp: new_hp})
      end
    end
  end

  defp is_open?(grid, units, pos) do
    Map.get(grid, pos) == :open and not Map.has_key?(units, pos)
  end

  defp get_adjacent({x, y}) do
    [{x, y - 1}, {x - 1, y}, {x + 1, y}, {x, y + 1}]
  end

  defp reading_order({x, y}), do: {y, x}
end
