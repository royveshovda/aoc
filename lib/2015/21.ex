import AOC

aoc 2015, 21 do
  @moduledoc """
  https://adventofcode.com/2015/day/21

  Day 21: RPG Simulator 20XX

  Find the minimum/maximum cost to win/lose against the boss.
  """

  # Shop items
  @weapons [
    {:dagger, 8, 4, 0},
    {:shortsword, 10, 5, 0},
    {:warhammer, 25, 6, 0},
    {:longsword, 40, 7, 0},
    {:greataxe, 74, 8, 0}
  ]

  @armor [
    {:none, 0, 0, 0},
    {:leather, 13, 0, 1},
    {:chainmail, 31, 0, 2},
    {:splintmail, 53, 0, 3},
    {:bandedmail, 75, 0, 4},
    {:platemail, 102, 0, 5}
  ]

  @rings [
    {:none1, 0, 0, 0},
    {:none2, 0, 0, 0},
    {:damage1, 25, 1, 0},
    {:damage2, 50, 2, 0},
    {:damage3, 100, 3, 0},
    {:defense1, 20, 0, 1},
    {:defense2, 40, 0, 2},
    {:defense3, 80, 0, 3}
  ]

  def p1(input) do
    boss = parse_input(input)

    # Find minimum cost to win
    all_loadouts()
    |> Enum.filter(fn {_cost, damage, armor} ->
      player_wins?(%{hp: 100, damage: damage, armor: armor}, boss)
    end)
    |> Enum.map(fn {cost, _damage, _armor} -> cost end)
    |> Enum.min()
  end

  def p2(input) do
    boss = parse_input(input)

    # Find maximum cost to lose
    all_loadouts()
    |> Enum.reject(fn {_cost, damage, armor} ->
      player_wins?(%{hp: 100, damage: damage, armor: armor}, boss)
    end)
    |> Enum.map(fn {cost, _damage, _armor} -> cost end)
    |> Enum.max()
  end

  defp parse_input(input) do
    [hp, damage, armor] =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line |> String.split(": ") |> List.last() |> String.to_integer()
      end)

    %{hp: hp, damage: damage, armor: armor}
  end

  defp all_loadouts do
    for weapon <- @weapons,
        armor <- @armor,
        ring1 <- @rings,
        ring2 <- @rings,
        # Can't equip same ring twice (unless it's "none")
        ring1 <= ring2 or elem(ring1, 0) in [:none1, :none2] or elem(ring2, 0) in [:none1, :none2] do
      {_wname, wcost, wdmg, warm} = weapon
      {_aname, acost, admg, aarm} = armor
      {_r1name, r1cost, r1dmg, r1arm} = ring1
      {_r2name, r2cost, r2dmg, r2arm} = ring2

      total_cost = wcost + acost + r1cost + r2cost
      total_damage = wdmg + admg + r1dmg + r2dmg
      total_armor = warm + aarm + r1arm + r2arm

      {total_cost, total_damage, total_armor}
    end
    |> Enum.uniq()
  end

  defp player_wins?(player, boss) do
    # Calculate damage per turn
    player_damage = max(1, player.damage - boss.armor)
    boss_damage = max(1, boss.damage - player.armor)

    # Calculate turns to kill
    player_turns_to_kill = div(boss.hp + player_damage - 1, player_damage)
    boss_turns_to_kill = div(player.hp + boss_damage - 1, boss_damage)

    # Player goes first, so wins if they kill boss in same or fewer turns
    player_turns_to_kill <= boss_turns_to_kill
  end
end
