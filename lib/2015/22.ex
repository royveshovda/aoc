import AOC

aoc 2015, 22 do
  @moduledoc """
  https://adventofcode.com/2015/day/22

  Day 22: Wizard Simulator 20XX

  Spell-based combat simulator. Find minimum mana to win.
  """

  @spells [
    {:magic_missile, 53, :instant, 4, 0, 0},
    {:drain, 73, :instant, 2, 2, 0},
    {:shield, 113, :effect, 0, 0, 6},
    {:poison, 173, :effect, 0, 0, 6},
    {:recharge, 229, :effect, 0, 0, 5}
  ]

  def p1(input) do
    boss = parse_input(input)
    find_min_mana_to_win(boss, false)
  end

  def p2(input) do
    boss = parse_input(input)
    find_min_mana_to_win(boss, true)
  end

  defp parse_input(input) do
    [hp, damage] =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line |> String.split(": ") |> List.last() |> String.to_integer()
      end)

    %{hp: hp, damage: damage}
  end

  defp find_min_mana_to_win(boss, hard_mode) do
    initial_state = %{
      player_hp: 50,
      player_mana: 500,
      boss_hp: boss.hp,
      boss_damage: boss.damage,
      effects: %{},
      mana_spent: 0,
      player_turn: true
    }

    # Use priority queue (min-heap) to explore cheapest paths first
    queue = :queue.from_list([initial_state])
    search(queue, hard_mode, :infinity)
  end

  defp search(queue, hard_mode, best_mana) do
    case :queue.out(queue) do
      {{:value, state}, queue} ->
        # Prune if already spent more than best solution
        if state.mana_spent >= best_mana do
          search(queue, hard_mode, best_mana)
        else
          case simulate_turn(state, hard_mode) do
            {:win, mana} ->
              # Found a winning path, update best
              search(queue, hard_mode, min(best_mana, mana))

            {:lose, _} ->
              # This path lost, skip it
              search(queue, hard_mode, best_mana)

            {:continue, states} ->
              # Add all possible next states to queue
              new_queue = Enum.reduce(states, queue, fn s, q -> :queue.in(s, q) end)
              search(new_queue, hard_mode, best_mana)
          end
        end

      {:empty, _} ->
        best_mana
    end
  end

  defp simulate_turn(state, hard_mode) do
    state = if state.player_turn and hard_mode do
      # Hard mode: player loses 1 HP at start of player turn
      %{state | player_hp: state.player_hp - 1}
    else
      state
    end

    # Check if player died from hard mode
    if state.player_hp <= 0 do
      {:lose, state.mana_spent}
    else
      # Apply effects at start of turn
      state = apply_effects(state)

      # Check if boss died from effects
      if state.boss_hp <= 0 do
        {:win, state.mana_spent}
      else
        if state.player_turn do
          # Player's turn - try all possible spells
          possible_states = try_all_spells(state)
          if Enum.empty?(possible_states) do
            {:lose, state.mana_spent}
          else
            {:continue, possible_states}
          end
        else
          # Boss's turn - attack
          boss_turn(state)
        end
      end
    end
  end

  defp apply_effects(state) do
    effects = state.effects

    # Apply poison damage
    boss_hp = if Map.has_key?(effects, :poison) do
      state.boss_hp - 3
    else
      state.boss_hp
    end

    # Apply recharge
    mana = if Map.has_key?(effects, :recharge) do
      state.player_mana + 101
    else
      state.player_mana
    end

    # Decrease timers
    new_effects = effects
    |> Enum.map(fn {name, timer} -> {name, timer - 1} end)
    |> Enum.reject(fn {_name, timer} -> timer <= 0 end)
    |> Map.new()

    %{state | boss_hp: boss_hp, player_mana: mana, effects: new_effects}
  end

  defp try_all_spells(state) do
    @spells
    |> Enum.filter(fn {name, cost, type, _, _, _} ->
      # Can afford and effect not already active
      state.player_mana >= cost and
      (type == :instant or not Map.has_key?(state.effects, name))
    end)
    |> Enum.map(fn spell -> cast_spell(state, spell) end)
    |> Enum.reject(&is_nil/1)
  end

  defp cast_spell(state, {name, cost, type, damage, heal, duration}) do
    new_state = %{state |
      player_mana: state.player_mana - cost,
      mana_spent: state.mana_spent + cost,
      player_turn: false
    }

    case type do
      :instant ->
        %{new_state |
          boss_hp: new_state.boss_hp - damage,
          player_hp: new_state.player_hp + heal
        }

      :effect ->
        %{new_state | effects: Map.put(new_state.effects, name, duration)}
    end
  end

  defp boss_turn(state) do
    armor = if Map.has_key?(state.effects, :shield), do: 7, else: 0
    damage = max(1, state.boss_damage - armor)
    new_hp = state.player_hp - damage

    if new_hp <= 0 do
      {:lose, state.mana_spent}
    else
      {:continue, [%{state | player_hp: new_hp, player_turn: true}]}
    end
  end
end
