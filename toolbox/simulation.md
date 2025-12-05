# Simulation & State Management

## Overview
Many AoC problems involve simulating systems over time. Managing state efficiently is key.

## When to Use
- Turn-based systems
- Cellular automata
- Physics simulations
- Game-like scenarios

## Used In
- 2024 Days 6, 11, 14, 15 (Various simulations)
- 2023 Day 14 (Grid tilting)
- 2022 Days 9, 11, 14, 17, 23, 24 (Rope, monkeys, sand, rocks, elves, blizzards)
- 2018 Day 17 (Water flow with cascading fills)
- 2018 Day 15 (Combat simulation)

## Basic Simulation Loop

```elixir
def simulate(initial_state, steps) do
  Enum.reduce(1..steps, initial_state, fn _step, state ->
    simulate_one_step(state)
  end)
end

# With early termination
def simulate_until(initial_state, condition, max_steps \\ :infinity) do
  Stream.iterate({initial_state, 0}, fn {state, step} ->
    {simulate_one_step(state), step + 1}
  end)
  |> Enum.reduce_while(nil, fn {state, step}, _acc ->
    cond do
      condition.(state) -> {:halt, {state, step}}
      step >= max_steps -> {:halt, {:max_steps, state, step}}
      true -> {:cont, nil}
    end
  end)
end
```

## State as Map (2024 Day 15 - Warehouse)

```elixir
defmodule Warehouse do
  defstruct [:grid, :robot, :boxes]
  
  def new(input) do
    grid = parse_grid(input)
    robot = find_robot(grid)
    boxes = find_boxes(grid)
    
    %__MODULE__{grid: grid, robot: robot, boxes: boxes}
  end
  
  def simulate_move(%__MODULE__{} = state, move) do
    case can_move?(state, state.robot, move) do
      {:ok, positions_to_move} ->
        move_objects(state, positions_to_move, move)
      
      :blocked ->
        state
    end
  end
  
  defp move_objects(state, positions, direction) do
    # Update all positions
    new_boxes = Enum.map(positions, fn pos ->
      add(pos, direction)
    end)
    
    %{state | boxes: new_boxes, robot: add(state.robot, direction)}
  end
end
```

## Iterative State Updates (2025 Day 4)

```elixir
def iterate_until_stable(initial_state) do
  iterate_step(initial_state, 0)
end

defp iterate_step(state, count) do
  # Find items to process
  items_to_process = find_processable_items(state)
  
  if Enum.empty?(items_to_process) do
    # Stable state reached
    count
  else
    # Update state
    new_state = Enum.reduce(items_to_process, state, fn item, s ->
      process_item(s, item)
    end)
    
    iterate_step(new_state, count + length(items_to_process))
  end
end
```

## Using Stream.iterate (2022 Day 9)

```elixir
def simulate_rope(moves, rope_length) do
  initial_rope = List.duplicate({0, 0}, rope_length)
  
  moves
  |> Enum.flat_map(&expand_move/1)
  |> Enum.reduce({initial_rope, MapSet.new([{0, 0}])}, fn move, {rope, visited} ->
    new_rope = update_rope(rope, move)
    tail = List.last(new_rope)
    {new_rope, MapSet.put(visited, tail)}
  end)
  |> elem(1)
  |> MapSet.size()
end

defp update_rope([head | tail], move) do
  new_head = move_head(head, move)
  
  rope = Enum.scan(tail, new_head, fn segment, prev ->
    move_tail(segment, prev)
  end)
  
  [new_head | rope]
end
```

## State Machine Pattern (2022 Day 20)

```elixir
defmodule StateMachine do
  defstruct [:state, :transitions, :current]
  
  def new(initial_state, transitions) do
    %__MODULE__{
      state: initial_state,
      transitions: transitions,
      current: :start
    }
  end
  
  def step(%__MODULE__{} = machine, input) do
    transition = machine.transitions[{machine.current, input}]
    
    case transition do
      {next_state, action} ->
        new_state = action.(machine.state)
        %{machine | state: new_state, current: next_state}
      
      nil ->
        machine  # No transition, stay in current state
    end
  end
end
```

## Cellular Automaton (Conway's Game of Life Pattern)

```elixir
def simulate_ca(grid, rules, steps) do
  Enum.reduce(1..steps, grid, fn _, g ->
    update_grid(g, rules)
  end)
end

defp update_grid(grid, rules) do
  all_positions = MapSet.union(grid, get_neighbors_of_all(grid))
  
  Enum.reduce(all_positions, MapSet.new(), fn pos, new_grid ->
    neighbor_count = count_active_neighbors(pos, grid)
    is_active = MapSet.member?(grid, pos)
    
    if apply_rules(is_active, neighbor_count, rules) do
      MapSet.put(new_grid, pos)
    else
      new_grid
    end
  end)
end

defp apply_rules(true, neighbors, _rules) when neighbors in [2, 3], do: true
defp apply_rules(false, 3, _rules), do: true
defp apply_rules(_, _, _), do: false
```

## Round-Based Simulation with Ordering (2022 Day 23 - Elves)

```elixir
def simulate_rounds(initial_positions, num_rounds) do
  directions = [:north, :south, :west, :east]
  
  Enum.reduce(1..num_rounds, {initial_positions, directions}, fn round, {positions, dirs} ->
    # Propose moves
    proposals = Enum.map(positions, fn pos ->
      {pos, propose_move(pos, positions, dirs)}
    end)
    
    # Detect collisions
    proposed_positions = Enum.map(proposals, &elem(&1, 1))
    collisions = find_collisions(proposed_positions)
    
    # Execute non-colliding moves
    new_positions = Enum.map(proposals, fn {from, to} ->
      if to in collisions, do: from, else: to
    end)
    
    # Rotate direction priority
    new_dirs = rotate_list(dirs)
    
    {new_positions, new_dirs}
  end)
  |> elem(0)
end

defp find_collisions(positions) do
  positions
  |> Enum.frequencies()
  |> Enum.filter(fn {_, count} -> count > 1 end)
  |> Enum.map(&elem(&1, 0))
  |> MapSet.new()
end
```

## Physics Simulation (2022 Day 14 - Falling Sand)

```elixir
def simulate_sand(cave, source) do
  simulate_sand_grain(cave, source, 0)
end

defp simulate_sand_grain(cave, source, count) do
  case drop_grain(cave, source) do
    {:settled, pos, new_cave} ->
      simulate_sand_grain(new_cave, source, count + 1)
    
    :abyss ->
      count
    
    :blocked ->
      count
  end
end

defp drop_grain(cave, {x, y}) do
  cond do
    y > cave.max_y ->
      :abyss
    
    not obstacle?(cave, {x, y + 1}) ->
      drop_grain(cave, {x, y + 1})
    
    not obstacle?(cave, {x - 1, y + 1}) ->
      drop_grain(cave, {x - 1, y + 1})
    
    not obstacle?(cave, {x + 1, y + 1}) ->
      drop_grain(cave, {x + 1, y + 1})
    
    {x, y} == cave.source ->
      :blocked
    
    true ->
      {:settled, {x, y}, add_obstacle(cave, {x, y})}
  end
end
```

## Discrete Event Simulation

```elixir
defmodule EventSimulator do
  defstruct [:events, :time, :state]
  
  def new(initial_events, initial_state) do
    %__MODULE__{
      events: Enum.sort_by(initial_events, &elem(&1, 0)),
      time: 0,
      state: initial_state
    }
  end
  
  def run(%__MODULE__{events: []} = sim), do: sim
  
  def run(%__MODULE__{events: [{time, event} | rest]} = sim) do
    new_state = process_event(sim.state, event)
    new_events = generate_new_events(new_state, time)
    
    all_events = Enum.sort_by(rest ++ new_events, &elem(&1, 0))
    
    %{sim | events: all_events, time: time, state: new_state}
    |> run()
  end
end
```

## State Snapshots & Rollback

```elixir
defmodule Simulator do
  def simulate_with_history(initial_state, steps) do
    Enum.reduce(1..steps, {initial_state, [initial_state]}, fn step, {state, history} ->
      new_state = simulate_step(state)
      {new_state, [new_state | history]}
    end)
  end
  
  def rollback_to(history, step) do
    Enum.at(Enum.reverse(history), step)
  end
end
```

## Parallel Simulation (when states are independent)

```elixir
def simulate_parallel(initial_states, steps) do
  Task.async_stream(initial_states, fn state ->
    Enum.reduce(1..steps, state, fn _, s ->
      simulate_step(s)
    end)
  end)
  |> Enum.map(fn {:ok, result} -> result end)
end
```

## Particle Simulation with Collision Detection

**Problem:** Simulate multiple particles with position, velocity, acceleration and detect collisions.

**When to Use:**
- Physics simulations (2017 Day 20)
- Projectile motion
- N-body problems
- Collision detection

**Used In**: 2017 Day 20 (Particle Swarm)

```elixir
def simulate_particles(particles) do
  # Store particles by ID
  particle_map = particles
  |> Enum.with_index()
  |> Map.new(fn {{pos, vel, acc}, id} -> {id, {pos, vel, acc}} end)
  
  simulate_with_collisions(particle_map, 0)
end

defp simulate_with_collisions(particles, ticks_no_change) do
  # Stop if no collisions for 100 ticks
  if ticks_no_change > 100 do
    map_size(particles)
  else
    # Update all particles: v' = v + a, p' = p + v'
    updated = Map.new(particles, fn {id, {{px, py, pz}, {vx, vy, vz}, {ax, ay, az}}} ->
      new_vel = {vx + ax, vy + ay, vz + az}
      {nvx, nvy, nvz} = new_vel
      new_pos = {px + nvx, py + nvy, pz + nvz}
      {id, {new_pos, new_vel, {ax, ay, az}}}
    end)
    
    # Group by position to find collisions
    by_position = Enum.group_by(updated, fn {_id, {pos, _v, _a}} -> pos end)
    
    # Find all particles at positions with multiple particles
    colliding_ids = by_position
    |> Enum.filter(fn {_pos, particles} -> length(particles) > 1 end)
    |> Enum.flat_map(fn {_pos, particles} -> Enum.map(particles, &elem(&1, 0)) end)
    |> MapSet.new()
    
    # Remove colliding particles
    remaining = Map.drop(updated, MapSet.to_list(colliding_ids))
    
    # Increment tick counter if no collisions
    new_ticks = if map_size(remaining) == map_size(particles), do: ticks_no_change + 1, else: 0
    simulate_with_collisions(remaining, new_ticks)
  end
end

# Find particle closest to origin in long term (based on acceleration)
def closest_long_term(particles) do
  particles
  |> Enum.with_index()
  |> Enum.min_by(fn {{pos, vel, acc}, _id} ->
    # Sort by: smallest acceleration, then velocity, then position
    {manhattan(acc), manhattan(vel), manhattan(pos)}
  end)
  |> elem(1)
end

defp manhattan({x, y, z}), do: abs(x) + abs(y) + abs(z)
```

**Key Insights**:
- Acceleration dominates long-term behavior
- Collisions are permanent (remove particles)
- Stop when system stabilizes (no collisions for N iterations)
- Group by position for efficient collision detection

## Circular Buffer Optimization (Spinlock)

**Problem:** Simulate circular buffer insertions, but tracking full buffer is too slow for large iterations.

**When to Use:**
- Circular buffer simulations (2017 Day 17)
- Only care about specific position(s) in buffer
- Millions of insertions needed

**Used In**: 2017 Day 17 (Spinlock)

```elixir
# Naive approach (works for small iterations)
def spinlock_naive(steps, iterations) do
  Enum.reduce(1..iterations, {[0], 0}, fn val, {buffer, pos} ->
    new_pos = rem(pos + steps, length(buffer)) + 1
    {List.insert_at(buffer, new_pos, val), new_pos}
  end)
end

# Optimized: Track only position after 0 (0 always stays at index 0)
def spinlock_optimized(steps, iterations) do
  Enum.reduce(1..iterations, {0, 0}, fn val, {pos, value_after_zero} ->
    buffer_len = val
    new_pos = rem(pos + steps, buffer_len) + 1
    
    # If inserting at position 1, update our tracked value
    new_value = if new_pos == 1, do: val, else: value_after_zero
    {new_pos, new_value}
  end)
  |> elem(1)
end
```

**Key Insight**: Value `0` always stays at position 0. We only care about position 1, so we don't need to maintain the full buffer—just track when we insert at position 1.

## Turn-Based Simulation with Strict Ordering (2018 Day 13 - Mine Carts)

When entities must move in specific order (top-to-bottom, left-to-right) and can collide:

```elixir
def simulate_carts(tracks, carts) do
  # Sort carts by position for proper turn order
  sorted_carts = Enum.sort_by(carts, fn {x, y, _dir, _state} -> {y, x} end)
  
  case tick(tracks, sorted_carts, []) do
    {:crash, x, y} -> {:part1, {x, y}}
    {:ok, new_carts} -> simulate_carts(tracks, new_carts)
  end
end

# Process carts one at a time in order
defp tick(_tracks, [], processed) do
  {:ok, Enum.reverse(processed)}
end

defp tick(tracks, [cart | remaining], processed) do
  {x, y, dir, state} = cart
  {new_x, new_y} = move(x, y, dir)
  
  # Check collision with both remaining and already-processed carts
  collision_remaining = Enum.any?(remaining, fn {cx, cy, _, _} -> 
    cx == new_x and cy == new_y 
  end)
  collision_processed = Enum.any?(processed, fn {cx, cy, _, _} -> 
    cx == new_x and cy == new_y 
  end)
  
  if collision_remaining or collision_processed do
    {:crash, new_x, new_y}
  else
    track = Map.get(tracks, {new_x, new_y})
    {new_dir, new_state} = update_direction(dir, track, state)
    new_cart = {new_x, new_y, new_dir, new_state}
    tick(tracks, remaining, [new_cart | processed])
  end
end

# Part 2: Remove crashed carts and continue
defp tick_remove_crashed(tracks, [cart | remaining], processed) do
  {x, y, dir, state} = cart
  {new_x, new_y} = move(x, y, dir)
  
  # Find collision indices
  collision_remaining_idx = Enum.find_index(remaining, fn {cx, cy, _, _} -> 
    cx == new_x and cy == new_y 
  end)
  collision_processed_idx = Enum.find_index(processed, fn {cx, cy, _, _} -> 
    cx == new_x and cy == new_y 
  end)
  
  cond do
    collision_remaining_idx != nil ->
      # Remove both: current cart and the one it hit
      new_remaining = List.delete_at(remaining, collision_remaining_idx)
      tick_remove_crashed(tracks, new_remaining, processed)
    
    collision_processed_idx != nil ->
      # Remove both: don't add current, remove from processed
      new_processed = List.delete_at(processed, collision_processed_idx)
      tick_remove_crashed(tracks, remaining, new_processed)
    
    true ->
      # No collision, move cart
      track = Map.get(tracks, {new_x, new_y})
      {new_dir, new_state} = update_direction(dir, track, state)
      new_cart = {new_x, new_y, new_dir, new_state}
      tick_remove_crashed(tracks, remaining, [new_cart | processed])
  end
end

# Direction updates for curves and intersections
defp update_direction(dir, track, turn_count) do
  case track do
    "|" -> {dir, turn_count}
    "-" -> {dir, turn_count}
    "/" ->
      new_dir = case dir do
        :up -> :right
        :down -> :left
        :left -> :down
        :right -> :up
      end
      {new_dir, turn_count}
    "\\" ->
      new_dir = case dir do
        :up -> :left
        :down -> :right
        :left -> :up
        :right -> :down
      end
      {new_dir, turn_count}
    "+" ->
      # Turn left, straight, right in sequence
      new_dir = case rem(turn_count, 3) do
        0 -> turn_left(dir)
        1 -> dir
        2 -> turn_right(dir)
      end
      {new_dir, turn_count + 1}
  end
end
```

**Key Patterns**:
- **Strict Ordering**: Sort entities by position (row, then column) each tick
- **Two-Phase Checking**: Check collisions against both unprocessed and processed entities
- **State Threading**: Each entity carries internal state (turn counter for intersections)
- **Collision Variants**:
  - Part 1: Stop on first collision
  - Part 2: Remove both colliding entities and continue

**When to Use**:
- Entities move on fixed tracks/paths
- Order of movement matters
- Mid-tick collisions possible
- Each entity has internal state independent of position

## Key Points
- **Immutable State**: Each step returns new state
- **Reduce Pattern**: Natural fit for simulations
- **Early Termination**: Use `reduce_while` or `take_while`
- **Cycle Detection**: For long simulations, detect repeating patterns
- **State Representation**:
  - Maps for complex state
  - Structs for typed state
  - MapSets for sparse grids
  - Lists for ordered sequences
  - Tuples for entity state (position + internal state)
- **Performance**: 
  - Minimize state copying
  - Use MapSet for membership tests
  - Consider ETS for very large state
  - Sort once per tick rather than searching
- **Debugging**: Add state snapshots/logging every N steps

## Common Patterns
1. **Fixed iterations**: Use `Enum.reduce` with range
2. **Until convergence**: Use `Stream.iterate` with `take_while`
3. **Event-driven**: Priority queue of events
4. **Turn-based**: Alternate between player actions
5. **Continuous**: Discrete time steps approximating continuous
6. **Cascading effects**: When one change triggers more changes (e.g., water rising)

## Water Flow Simulation (2018 Day 17)

**Pattern**: Flood-fill with state propagation and cascading effects.

```elixir
def simulate_water(clay, max_y) do
  pour(%{}, clay, {500, 0}, max_y)
end

defp pour(water, clay, {x, y} = pos, max_y) do
  cond do
    y > max_y ->
      Map.put(water, pos, :flowing)
    
    Map.get(water, pos) == :settled ->
      water
    
    Map.get(water, pos) == :flowing ->
      # Already flowing - check if we can fill now that support may exist
      if has_floor?(clay, water, {x, y + 1}) do
        fill(water, clay, pos, max_y)
      else
        water
      end
    
    true ->
      # New position - mark as flowing and try to flow down
      water = Map.put(water, pos, :flowing)
      
      water = if can_flow_to?(clay, water, {x, y + 1}) do
        pour(water, clay, {x, y + 1}, max_y)
      else
        water
      end
      
      # After flowing down, fill if there's support
      if has_floor?(clay, water, {x, y + 1}) do
        fill(water, clay, pos, max_y)
      else
        water
      end
  end
end

defp fill(water, clay, {x, y}, max_y) do
  # Find horizontal extent
  {left_x, left_bounded} = spread_direction(water, clay, {x, y}, -1)
  {right_x, right_bounded} = spread_direction(water, clay, {x, y}, 1)
  
  # Mark all cells in range
  water = 
    for cx <- left_x..right_x, reduce: water do
      acc ->
        if left_bounded and right_bounded do
          Map.put(acc, {cx, y}, :settled)
        else
          Map.put(acc, {cx, y}, :flowing)
        end
    end
  
  # Pour from unbounded edges
  water = if not left_bounded, do: pour(water, clay, {left_x, y + 1}, max_y), else: water
  water = if not right_bounded, do: pour(water, clay, {right_x, y + 1}, max_y), else: water
  
  # CRITICAL: Propagate upward when water settles
  # Water rises! Check row above for positions that can now fill
  if left_bounded and right_bounded and y > 0 do
    for cx <- left_x..right_x, reduce: water do
      acc ->
        above_pos = {cx, y - 1}
        if Map.get(acc, above_pos) == :flowing and has_floor?(clay, acc, {cx, y}) do
          fill(acc, clay, above_pos, max_y)
        else
          acc
        end
    end
  else
    water
  end
end

defp spread_direction(water, clay, {x, y}, dx) do
  next_x = x + dx
  next_pos = {next_x, y}
  below_next = {next_x, y + 1}
  
  cond do
    MapSet.member?(clay, next_pos) -> {x, true}
    not has_floor?(clay, water, below_next) -> {next_x, false}
    true -> spread_direction(water, clay, next_pos, dx)
  end
end

defp has_floor?(clay, water, pos) do
  MapSet.member?(clay, pos) or Map.get(water, pos) == :settled
end
```

**Key Insights**:
- Two water states: `:flowing` (|) and `:settled` (~)
- Water flows down first, then spreads horizontally
- When bounded on both sides, water settles
- **Critical**: After settling a row, propagate upward - check if rows above can now fill
- This creates cascading fill effect: containers fill layer by layer from bottom up
- Without upward propagation, you'll severely undercount (e.g., 3369 vs 41027)

**Why Upward Propagation Matters**:
1. Water flows down and marks positions as `:flowing`
2. Lower water settles in a container, creating new floor
3. Positions above now have support but are already marked `:flowing`
4. Must explicitly check and fill these positions
5. Each settled layer enables the layer above to potentially settle
6. Pattern continues upward until no more layers can settle

**Common Bugs**:
- Not revisiting `:flowing` positions when floor appears below them
- Not propagating settled water upward to enable higher layers to fill
- Overwriting settled water with flowing water
- Incorrect boundary detection in horizontal spreading

6. **Ordered simulation**: Sort entities by position, process one-by-one
