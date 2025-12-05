# Cycle Detection

## Overview
Cycle detection finds repeating patterns in sequences. Critical for optimization when simulating long iterations.

## When to Use
- Simulations with large iteration counts (billions)
- Repeating patterns in state evolution
- Memory-based problems (configurations repeat)
- State machines with finite states

## Used In
- 2023 Day 14 (Parabolic Reflector - grid tilting cycles)
- 2022 Day 17 (Pyroclastic Flow - falling blocks pattern)
- 2018 Day 1 (Frequency - first repeat detection)
- 2018 Day 12 (Plant Growth - detect stable offset pattern)
- 2017 Day 6 (Memory Reallocation - detect when redistribution repeats)
- 2024 Day 11 (would benefit from cycle detection for some inputs)

## Basic Cycle Detection with Cache (2023 Day 14)

```elixir
def simulate_with_cycle_detection(initial_state, target_iterations) do
  # Use process dictionary to cache seen states
  Process.put(:seen_states, %{})
  
  detect_cycle(initial_state, 0, target_iterations)
end

defp detect_cycle(state, iteration, target) do
  cache = Process.get(:seen_states)
  
  case Map.get(cache, state) do
    nil ->
      # First time seeing this state
      Process.put(:seen_states, Map.put(cache, state, iteration))
      new_state = simulate_one_step(state)
      detect_cycle(new_state, iteration + 1, target)
    
    first_seen_at ->
      # Found a cycle!
      cycle_length = iteration - first_seen_at
      remaining = target - iteration
      
      # Skip complete cycles
      after_skip = rem(remaining, cycle_length)
      
      # Simulate the remaining iterations
      final_state = Enum.reduce(1..after_skip, state, fn _, s ->
        simulate_one_step(s)
      end)
      
      final_state
  end
end
```

## Floyd's Cycle Detection (Tortoise and Hare)

```elixir
def floyd_cycle_detection(start) do
  # Phase 1: Find if cycle exists
  {tortoise, hare} = {start, start}
  {tortoise, hare} = find_meeting_point(tortoise, hare)
  
  case hare do
    nil -> 
      {:no_cycle}
    
    _ ->
      # Phase 2: Find cycle start
      tortoise = start
      {cycle_start, _} = find_cycle_start(tortoise, hare)
      
      # Phase 3: Find cycle length
      cycle_length = find_cycle_length(next(cycle_start))
      
      {:cycle, cycle_start, cycle_length}
  end
end

defp find_meeting_point(tortoise, hare) do
  tortoise = next(tortoise)
  hare = next(next(hare))
  
  cond do
    hare == nil -> {tortoise, nil}
    tortoise == hare -> {tortoise, hare}
    true -> find_meeting_point(tortoise, hare)
  end
end

defp find_cycle_start(tortoise, hare) do
  if tortoise == hare do
    {tortoise, hare}
  else
    find_cycle_start(next(tortoise), next(hare))
  end
end

defp find_cycle_length(start, count \\ 1) do
  current = next(start)
  if current == start do
    count
  else
    find_cycle_length(start, count + 1)
  end
end
```

## Hash-Based Cycle Detection (2017 Day 6)

Track both when cycles occur and their length for problems requiring both values:

```elixir
def find_cycle_with_hash(state) do
  find_cycle_helper(state, %{}, 0)
end

defp find_cycle_helper(state, seen, count) do
  # Use erlang hash for complex state structures
  key = :erlang.phash2(state)
  
  case Map.get(seen, key) do
    nil ->
      new_state = transform(state)
      find_cycle_helper(new_state, Map.put(seen, key, count), count + 1)
    
    first_seen ->
      # Return both total iterations and cycle length
      {count, count - first_seen}
  end
end

# Example: Memory bank redistribution (2017 Day 6)
defp redistribute(banks) do
  max_blocks = Enum.max(banks)
  idx = Enum.find_index(banks, &(&1 == max_blocks))
  
  banks
  |> List.replace_at(idx, 0)
  |> distribute_blocks(idx + 1, max_blocks)
end

defp distribute_blocks(banks, _pos, 0), do: banks
defp distribute_blocks(banks, pos, remaining) do
  idx = rem(pos, length(banks))
  new_banks = List.update_at(banks, idx, &(&1 + 1))
  distribute_blocks(new_banks, pos + 1, remaining - 1)
end
```

## Cycle Detection with ETS (2022 Day 17)

```elixir
def simulate_with_ets(initial_state, target) do
  :ets.new(:cycle_cache, [:set, :public, :named_table])
  
  result = detect_cycle_ets(initial_state, 0, target)
  
  :ets.delete(:cycle_cache)
  result
end

defp detect_cycle_ets(state, iteration, target) when iteration >= target do
  state
end

defp detect_cycle_ets(state, iteration, target) do
  # Use state fingerprint as key (e.g., top of stack + indices)
  key = fingerprint(state)
  
  case :ets.lookup(:cycle_cache, key) do
    [] ->
      # Cache this state
      :ets.insert(:cycle_cache, {key, {iteration, height(state)}})
      new_state = simulate_step(state)
      detect_cycle_ets(new_state, iteration + 1, target)
    
    [{_, {prev_iteration, prev_height}}] ->
      # Found cycle!
      cycle_length = iteration - prev_iteration
      height_per_cycle = height(state) - prev_height
      
      # Calculate how many complete cycles we can skip
      remaining = target - iteration
      complete_cycles = div(remaining, cycle_length)
      leftover = rem(remaining, cycle_length)
      
      # Fast forward
      skipped_height = complete_cycles * height_per_cycle
      
      # Simulate remaining steps
      final_state = Enum.reduce(1..leftover, state, fn _, s ->
        simulate_step(s)
      end)
      
      add_height(final_state, skipped_height)
  end
end

defp fingerprint({stack, rock_idx, jet_idx}) do
  # Take top N rows of stack + current indices
  top_rows = Enum.take(stack, 20)
  {top_rows, rock_idx, jet_idx}
end
```

## Simple Repeat Detection (2018 Day 1)

```elixir
def find_first_repeat(values) do
  values
  |> Stream.cycle()
  |> Enum.reduce_while({0, MapSet.new([0])}, fn val, {sum, seen} ->
    new_sum = sum + val
    
    if MapSet.member?(seen, new_sum) do
      {:halt, new_sum}
    else
      {:cont, {new_sum, MapSet.put(seen, new_sum)}}
    end
  end)
end
```

## Brent's Cycle Detection

```elixir
def brent_cycle_detection(start) do
  power = 1
  cycle_length = 1
  tortoise = start
  hare = next(start)
  
  # Find cycle length
  {cycle_length, tortoise, hare} = find_cycle_length_brent(tortoise, hare, power, cycle_length)
  
  # Find cycle start
  tortoise = start
  hare = start
  hare = Enum.reduce(1..cycle_length, hare, fn _, h -> next(h) end)
  
  cycle_start = find_cycle_start_brent(tortoise, hare, 0)
  
  {cycle_start, cycle_length}
end

defp find_cycle_length_brent(tortoise, hare, power, cycle_length) do
  if tortoise == hare do
    {cycle_length, tortoise, hare}
  else
    if cycle_length == power do
      tortoise = hare
      power = power * 2
      cycle_length = 0
    end
    
    find_cycle_length_brent(tortoise, next(hare), power, cycle_length + 1)
  end
end

defp find_cycle_start_brent(tortoise, hare, position) do
  if tortoise == hare do
    position
  else
    find_cycle_start_brent(next(tortoise), next(hare), position + 1)
  end
end
```

## Pattern Matching with Signatures

```elixir
def detect_pattern_cycle(sequence, min_cycle_len \\ 3, max_cycle_len \\ 100) do
  min_cycle_len..max_cycle_len
  |> Enum.find_value(fn cycle_len ->
    if has_repeating_pattern?(sequence, cycle_len) do
      pattern = Enum.take(sequence, cycle_len)
      {cycle_len, pattern}
    end
  end)
end

defp has_repeating_pattern?(sequence, cycle_len) do
  # Check if pattern repeats at least twice
  if length(sequence) < cycle_len * 2 do
    false
  else
    pattern = Enum.take(sequence, cycle_len)
    next_pattern = Enum.slice(sequence, cycle_len, cycle_len)
    
    pattern == next_pattern and
      (length(sequence) < cycle_len * 3 or
       has_repeating_pattern?(Enum.drop(sequence, cycle_len), cycle_len))
  end
end
```

## Optimizing with Cycle Detection

```elixir
def solve_with_optimization(initial, target) do
  case find_cycle(initial, 0, %{}) do
    {:no_cycle, final_state} ->
      # No cycle found, simulate normally
      final_state
    
    {:cycle_found, cycle_start, cycle_length, state_at_cycle} ->
      if target < cycle_start do
        # Target before cycle starts
        simulate_n_steps(initial, target)
      else
        # Target is within or after cycle
        remaining = target - cycle_start
        position_in_cycle = rem(remaining, cycle_length)
        
        simulate_n_steps(state_at_cycle, position_in_cycle)
      end
  end
end

defp find_cycle(state, iteration, seen, max_iterations \\ 1_000_000) do
  if iteration >= max_iterations do
    {:no_cycle, state}
  else
    key = state_key(state)
    
    case Map.get(seen, key) do
      nil ->
        new_seen = Map.put(seen, key, {iteration, state})
        new_state = simulate_step(state)
        find_cycle(new_state, iteration + 1, new_seen, max_iterations)
      
      {first_seen, state_at_first_seen} ->
        cycle_length = iteration - first_seen
        {:cycle_found, first_seen, cycle_length, state}
    end
  end
end
```

## Key Points
- **State Fingerprinting**: Use small, representative subset of state as key
- **Cache Selection**: 
  - Process dictionary: Simple, single process
  - ETS: Shared across processes, persistent
  - Map parameter: Explicit threading, testable
- **When to Use**:
  - Target iterations >> 1 million
  - State space is finite
  - Pure functional transformations
- **Cycle Parameters**:
  - Cycle start (μ): Where cycle begins
  - Cycle length (λ): Length of repeating pattern
- **Skip Formula**: `final = start + skip * (target - start) / cycle_length`

## Permutation Cycles (Lists with Known Elements)

When working with permutations of a fixed set (like dance moves on fixed positions):

**Used In**: 2017 Day 16 (Permutation Promenade)

```elixir
def find_permutation_cycle(initial, transform_fn, target) do
  iterate(initial, transform_fn, 0, target, %{initial => 0})
end

defp iterate(state, transform_fn, step, target, seen) when step == target do
  state
end

defp iterate(state, transform_fn, step, target, seen) do
  next_state = transform_fn.(state)
  
  case Map.get(seen, next_state) do
    nil ->
      # New state, continue
      iterate(next_state, transform_fn, step + 1, target, Map.put(seen, next_state, step + 1))
    
    cycle_start ->
      # Found cycle!
      cycle_length = step + 1 - cycle_start
      remaining = target - step - 1
      skip_count = rem(remaining, cycle_length)
      
      # Apply transformation only for remaining iterations after skipping full cycles
      Enum.reduce(1..skip_count, next_state, fn _, s -> transform_fn.(s) end)
  end
end
```

**Key Difference**: Permutations often cycle quickly (factorial-bounded), making cache-based detection efficient.

## Offset-Based Cycle Detection (2018 Day 12)

When the actual state shifts but the pattern remains constant (e.g., plants growing rightward):

```elixir
def detect_stable_offset(initial_state, rules, target) do
  find_stable_offset(initial_state, rules, 0, 0, [])
end

defp find_stable_offset(state, rules, generation, prev_sum, offset_history) do
  new_state = evolve(state, rules)
  new_sum = calculate_sum(new_state)
  offset = new_sum - prev_sum
  
  # Track last N offsets to ensure stability
  new_history = [offset | offset_history] |> Enum.take(10)
  
  # Check if we have N consecutive generations with identical offset
  if length(new_history) == 10 and Enum.uniq(new_history) == [offset] do
    {generation + 1, new_sum, offset}
  else
    find_stable_offset(new_state, rules, generation + 1, new_sum, new_history)
  end
end

# Use the detected pattern
def solve_large_iteration(initial, rules, target) do
  {stable_gen, sum_at_stable, offset} = detect_stable_offset(initial, rules, target)
  
  remaining_generations = target - stable_gen
  final_sum = sum_at_stable + remaining_generations * offset
  
  final_sum
end
```

**Key Insight**: When state doesn't repeat exactly but the *difference* (offset) becomes constant, you can extrapolate linearly.

**When to Use**:
- State grows/shifts in one direction
- Pattern stabilizes to consistent growth rate
- Sum/count increases by fixed amount each iteration
- After enough iterations, randomness settles into deterministic growth

**Verification**: Track 5-10 consecutive identical offsets to ensure pattern is truly stable (not just temporary).

## Choosing Algorithm
- **Hash Table (Cache)**: Simplest, works for any cycle
- **Floyd's**: No extra space, but slower
- **Brent's**: Faster than Floyd's, still O(1) space
- **Pattern Matching**: When cycle is in sequence of values
- **Offset Detection**: When state shifts but pattern stabilizes

## Common Pitfalls
- Forgetting to handle case where target < cycle start
- Not normalizing state (equivalent states with different representations)
- Cache key too large (slow comparisons)
- Off-by-one errors in skip calculation
- **Detecting stability too early** - check multiple consecutive iterations
- Assuming offset is stable after just 1-2 matches (use 5-10 confirmations)
