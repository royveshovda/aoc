import AOC

aoc 2018, 24 do
  @moduledoc """
  https://adventofcode.com/2018/day/24

  Day 24: Immune System Simulator 20XX - Combat between immune system and infection
  """

  defmodule Group do
    defstruct [:id, :army, :units, :hp, :attack_damage, :attack_type, :initiative, :weaknesses, :immunities]

    def effective_power(group) do
      group.units * group.attack_damage
    end

    def calculate_damage(attacker, defender) do
      base_damage = effective_power(attacker)

      cond do
        attacker.attack_type in defender.immunities -> 0
        attacker.attack_type in defender.weaknesses -> base_damage * 2
        true -> base_damage
      end
    end
  end

  def p1(input) do
    groups = parse_input(input)
    final_groups = simulate_battle(groups)

    final_groups
    |> Enum.map(& &1.units)
    |> Enum.sum()
  end

  def p2(input) do
    # Binary search for minimum boost that allows immune system to win
    find_minimum_boost(input, 0, 10000)
  end

  defp find_minimum_boost(input, low, high) when low == high do
    groups = parse_input(input)
    boosted_groups = apply_boost(groups, low)
    final_groups = simulate_battle(boosted_groups)

    final_groups
    |> Enum.map(& &1.units)
    |> Enum.sum()
  end

  defp find_minimum_boost(input, low, high) do
    mid = div(low + high, 2)

    groups = parse_input(input)
    boosted_groups = apply_boost(groups, mid)
    final_groups = simulate_battle(boosted_groups)

    # Check if immune system won completely (no infection groups remain)
    immune_won = Enum.all?(final_groups, &(&1.army == :immune))

    if immune_won do
      # Immune system won, try smaller boost
      if mid == low do
        # Found minimum
        final_groups |> Enum.map(& &1.units) |> Enum.sum()
      else
        find_minimum_boost(input, low, mid)
      end
    else
      # Infection won or stalemate, need larger boost
      find_minimum_boost(input, mid + 1, high)
    end
  end

  defp apply_boost(groups, boost) do
    Enum.map(groups, fn group ->
      if group.army == :immune do
        %{group | attack_damage: group.attack_damage + boost}
      else
        group
      end
    end)
  end

  defp parse_input(input) do
    [immune_section, infection_section] = String.split(input, "\n\n", trim: true)

    immune_groups = parse_army(immune_section, :immune)
    infection_groups = parse_army(infection_section, :infection)

    immune_groups ++ infection_groups
  end

  defp parse_army(section, army_type) do
    [_header | lines] = String.split(section, "\n", trim: true)

    # Join multi-line group descriptions into single lines
    group_text = lines |> Enum.join(" ") |> String.replace("  ", " ")

    # Split by pattern - match from "N units" to "initiative N"
    groups = Regex.scan(~r/(\d+ units each.*?initiative \d+)/, group_text)
            |> Enum.map(fn [_, g] -> g end)

    groups
    |> Enum.with_index(1)
    |> Enum.map(fn {line, id} -> parse_group(line, id, army_type) end)
  end

  defp parse_group(line, id, army_type) do
    # Parse: "337 units each with 6482 hit points (weak to radiation, fire; immune to cold, bludgeoning) with an attack that does 189 slashing damage at initiative 15"

    regex = ~r/(\d+) units each with (\d+) hit points(.*?)with an attack that does (\d+) (\w+) damage at initiative (\d+)/

    [_, units, hp, modifiers, attack_damage, attack_type, initiative] = Regex.run(regex, line)

    {weaknesses, immunities} = parse_modifiers(modifiers)

    %Group{
      id: {army_type, id},
      army: army_type,
      units: String.to_integer(units),
      hp: String.to_integer(hp),
      attack_damage: String.to_integer(attack_damage),
      attack_type: String.to_atom(attack_type),
      initiative: String.to_integer(initiative),
      weaknesses: weaknesses,
      immunities: immunities
    }
  end

  defp parse_modifiers(modifiers_str) do
    if String.trim(modifiers_str) == "" do
      {[], []}
    else
      # Extract content between parentheses
      case Regex.run(~r/\((.*?)\)/, modifiers_str) do
        nil -> {[], []}
        [_, content] ->
          parts = String.split(content, "; ", trim: true)

          weaknesses = extract_list(parts, "weak to")
          immunities = extract_list(parts, "immune to")

          {weaknesses, immunities}
      end
    end
  end

  defp extract_list(parts, prefix) do
    parts
    |> Enum.find_value([], fn part ->
      if String.starts_with?(part, prefix) do
        part
        |> String.replace_prefix(prefix <> " ", "")
        |> String.split(", ")
        |> Enum.map(&String.to_atom/1)
      end
    end)
  end

  defp simulate_battle(groups) do
    if battle_over?(groups) do
      groups
    else
      groups_after_round = execute_round(groups)

      # Check for stalemate (no units killed)
      if same_units?(groups, groups_after_round) do
        groups_after_round
      else
        simulate_battle(groups_after_round)
      end
    end
  end

  defp battle_over?(groups) do
    armies = groups |> Enum.map(& &1.army) |> Enum.uniq()
    length(armies) == 1
  end

  defp same_units?(groups1, groups2) do
    units1 = groups1 |> Enum.map(& &1.units) |> Enum.sum()
    units2 = groups2 |> Enum.map(& &1.units) |> Enum.sum()
    units1 == units2
  end

  defp execute_round(groups) do
    # Target selection phase
    targets = select_targets(groups)

    # Attack phase
    attack(groups, targets)
  end

  defp select_targets(groups) do
    # Groups choose targets in decreasing order of effective power, then initiative
    sorted_groups = Enum.sort_by(groups, fn g ->
      {-Group.effective_power(g), -g.initiative}
    end)

    select_targets_recursive(sorted_groups, %{}, groups)
  end

  defp select_targets_recursive([], targets, _all_groups), do: targets

  defp select_targets_recursive([attacker | rest], targets, all_groups) do
    # Find enemy groups not yet targeted
    enemy_army = if attacker.army == :immune, do: :infection, else: :immune
    available_enemies = all_groups
      |> Enum.filter(&(&1.army == enemy_army))
      |> Enum.reject(&(Map.values(targets) |> Enum.member?(&1.id)))

    # Choose target that would receive most damage
    target = choose_target(attacker, available_enemies)

    new_targets = if target, do: Map.put(targets, attacker.id, target.id), else: targets

    select_targets_recursive(rest, new_targets, all_groups)
  end

  defp choose_target(attacker, enemies) do
    enemies
    |> Enum.map(fn enemy ->
      damage = Group.calculate_damage(attacker, enemy)
      {enemy, damage}
    end)
    |> Enum.filter(fn {_enemy, damage} -> damage > 0 end)
    |> Enum.sort_by(fn {enemy, damage} ->
      {-damage, -Group.effective_power(enemy), -enemy.initiative}
    end)
    |> case do
      [] -> nil
      [{enemy, _damage} | _] -> enemy
    end
  end

  defp attack(groups, targets) do
    # Attack in decreasing order of initiative
    sorted_attackers = Enum.sort_by(groups, &(-&1.initiative))

    # Build a map of groups by ID for quick lookup
    groups_map = Map.new(groups, &{&1.id, &1})

    # Execute attacks
    final_map = Enum.reduce(sorted_attackers, groups_map, fn attacker, acc_map ->
      current_attacker = Map.get(acc_map, attacker.id)

      # Skip if attacker is dead
      if !current_attacker || current_attacker.units <= 0 do
        acc_map
      else
        case Map.get(targets, attacker.id) do
          nil -> acc_map
          target_id ->
            defender = Map.get(acc_map, target_id)

            if !defender || defender.units <= 0 do
              acc_map
            else
              damage = Group.calculate_damage(current_attacker, defender)
              units_killed = div(damage, defender.hp)
              new_units = max(0, defender.units - units_killed)

              updated_defender = %{defender | units: new_units}
              Map.put(acc_map, target_id, updated_defender)
            end
        end
      end
    end)

    # Return groups with non-zero units
    final_map
    |> Map.values()
    |> Enum.filter(&(&1.units > 0))
  end
end
