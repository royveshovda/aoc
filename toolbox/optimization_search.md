# Optimization & Search Strategies

## Overview
Strategies for finding optimal solutions in large search spaces, including pruning, greedy algorithms, and state space exploration.

## 0. Sliding Puzzle State Space Search

**Problem:** Move data through a grid like a sliding puzzle to reach a goal configuration (2016 Day 22).

**When to Use:**
- Grid-based puzzles with one empty space
- Moving objects through constrained spaces
- Pathfinding where obstacles move with you

```elixir
# State: {empty_position, goal_data_position}
defp solve_sliding_puzzle(grid, initial_empty, initial_goal) do
  initial_state = {initial_empty, initial_goal}
  queue = :queue.from_list([{initial_state, 0}])
  visited = MapSet.new([initial_state])
  
  bfs_solve(queue, visited, grid, walls)
end

defp bfs_solve(queue, visited, grid, walls) do
  case :queue.out(queue) do
    {{:value, {{empty_pos, goal_pos}, steps}}, queue} ->
      # Check if goal reached target
      if goal_pos == target_position do
        steps
      else
        # Try moving empty to adjacent positions
        neighbors = get_neighbors(empty_pos)
                   |> Enum.filter(&valid_position?(&1, grid))
                   |> Enum.reject(&wall?(&1, walls))
        
        # Generate new states
        new_states = Enum.map(neighbors, fn new_empty ->
          # If empty moves to goal position, they swap
          new_goal = if new_empty == goal_pos, do: empty_pos, else: goal_pos
          {new_empty, new_goal}
        end)
        
        # Filter and enqueue unvisited states
        unvisited = Enum.reject(new_states, &MapSet.member?(visited, &1))
        new_queue = Enum.reduce(unvisited, queue, fn state, q ->
          :queue.in({state, steps + 1}, q)
        end)
        new_visited = Enum.reduce(unvisited, visited, &MapSet.put(&2, &1))
        
        bfs_solve(new_queue, new_visited, grid, walls)
      end
    {:empty, _} -> nil
  end
end
```

**Key Features:**
- State captures both empty position and goal data position
- Moving empty to goal position swaps them
- Identify immovable walls (e.g., nodes with very large capacity)
- BFS guarantees shortest path
- Can optimize with A* heuristic (Manhattan distance to target)

**Common Mistake:**
- Don't use heuristic formulas without validating against actual constraints
- Wall positions may not be regular - use actual state search

## 1. Branch and Bound with Pruning

**Problem:** Find optimal solution while exploring state space, pruning suboptimal branches.

**When to Use:**
- Minimization/maximization problems (2015 Day 22)
- Game tree search
- Combinatorial optimization

```elixir
defp branch_and_bound(initial_state, best_so_far \\ :infinity) do
  queue = :queue.from_list([initial_state])
  search(queue, best_so_far)
end

defp search(queue, best) do
  case :queue.out(queue) do
    {{:value, state}, queue} ->
      # Prune if this path can't beat current best
      if state.cost >= best do
        search(queue, best)
      else
        case evaluate_state(state) do
          {:win, cost} ->
            # Found better solution
            search(queue, min(best, cost))
          
          {:lose, _} ->
            # Dead end, prune
            search(queue, best)
          
          {:continue, next_states} ->
            # Expand this branch
            new_queue = Enum.reduce(next_states, queue, &:queue.in/2)
            search(new_queue, best)
        end
      end
    
    {:empty, _} ->
      best
  end
end
```

**Key Features:**
- Track best solution found so far
- Prune branches that can't improve on best
- Priority: try most promising paths first

## 3. State Normalization for BFS

**Problem:** Reduce state space by recognizing equivalent states (2016 Day 11).

**Pattern:** RTG Elevator Puzzle - moving paired items where specific element identity doesn't matter.

```elixir
# Instead of tracking which specific element is on which floor,
# track the pattern of generator-chip pairs
defp normalize(state) do
  # Group items by element
  pairs =
    state.floors
    |> Enum.flat_map(fn {floor, items} ->
      items |> Enum.map(fn item ->
        element = extract_element(item)
        type = extract_type(item)  # :gen or :chip
        {element, type, floor}
      end)
    end)
    |> Enum.group_by(fn {element, _, _} -> element end)
    |> Enum.map(fn {_element, items} ->
      # For each element, record where its gen and chip are
      gen_floor = find_floor(items, :gen)
      chip_floor = find_floor(items, :chip)
      {gen_floor, chip_floor}
    end)
    |> Enum.sort()  # Sort to make equivalent states identical
  
  {state.elevator, pairs}
end
```

**Key Insight:** States are equivalent if:
- Elevator is on same floor
- Pattern of paired items is same (e.g., `{0,1}, {0,2}` = `{0,1}, {0,2}` regardless of which element is which)

**Example:**
- State A: Polonium-gen floor 0, Polonium-chip floor 1, Thulium-gen floor 0, Thulium-chip floor 2
- State B: Thulium-gen floor 0, Thulium-chip floor 1, Polonium-gen floor 0, Polonium-chip floor 2
- Normalized: Both become `{{0,1}, {0,2}}` - equivalent!

**Massive Optimization:** Reduces state space from exponential in number of elements to exponential in number of pairs. For 10 items (5 pairs), this can reduce states by factor of 10! = 3,628,800.

**When to Use:**
- Puzzle/game states with symmetry
- Problems where specific identities don't matter, only patterns
- States with interchangeable components

**Key Features:**
- Maintain "best so far" bound
- Prune any path that can't improve the bound
- Use BFS or priority queue for systematic exploration

### With Priority Queue (Best-First Search)

```elixir
defp priority_search(initial_state) do
  # Use heap for priority queue
  queue = Heap.new(&(&1.cost <= &2.cost))
  |> Heap.push(initial_state)
  
  search_priority(queue, :infinity)
end

defp search_priority(queue, best) do
  case Heap.pop(queue) do
    {nil, _} -> best
    
    {state, queue} ->
      if state.cost >= best do
        search_priority(queue, best)
      else
        case evaluate_state(state) do
          {:win, cost} -> search_priority(queue, min(best, cost))
          {:lose, _} -> search_priority(queue, best)
          {:continue, next_states} ->
            new_queue = Enum.reduce(next_states, queue, &Heap.push(&2, &1))
            search_priority(new_queue, best)
        end
      end
  end
end
```

## 2. Greedy Algorithms

**Problem:** Make locally optimal choices hoping for global optimum.

**When to Use:**
- Problems with matroid structure
- Special input properties guarantee greedy works
- When complete search is too expensive

### Greedy Pattern

```elixir
defp greedy_solution(items, goal) do
  items
  |> Enum.sort_by(&score/1, :desc)  # Sort by greedy criterion
  |> Enum.reduce_while({[], 0}, fn item, {selected, current} ->
    new_value = current + value(item)
    
    cond do
      new_value == goal -> {:halt, {:ok, [item | selected]}}
      new_value < goal -> {:cont, {[item | selected], new_value}}
      new_value > goal -> {:cont, {selected, current}}
    end
  end)
end
```

### When Greedy Works

Greedy is optimal when the problem has:
1. **Greedy choice property** - Local optimum leads to global optimum
2. **Optimal substructure** - Optimal solution contains optimal subsolutions

**Example (2015 Day 19):** String reduction by always choosing longest replacement works because:
- Each replacement strictly reduces length
- No dependencies between replacement choices
- Input crafted to have unique optimal path

**Warning:** Most problems don't have greedy solutions! Always verify with examples.

## 3. Incremental Search by Size

**Problem:** Find minimum-size solution satisfying constraints.

**When to Use:**
- Minimizing number of items (2015 Days 17, 24)
- Finding smallest valid subset
- Partition problems

```elixir
defp find_minimum_size_solution(items, constraint) do
  # Try increasing sizes
  1..length(items)
  |> Enum.find_value(fn size ->
    candidates = combinations(items, size)
    
    valid = Enum.filter(candidates, constraint)
    
    unless Enum.empty?(valid) do
      # Found solutions of this size - return best
      {:ok, optimize(valid)}
    end
  end)
end

# Example: Find smallest group that sums to target
defp find_smallest_group(items, target) do
  1..length(items)
  |> Enum.find_value(fn size ->
    combinations(items, size)
    |> Enum.filter(fn combo -> Enum.sum(combo) == target end)
    |> case do
      [] -> nil
      valid -> Enum.min_by(valid, &product/1)
    end
  end)
end
```

**Key Insight:** Stop at first size with valid solutions - no need to check larger sizes.

## 4. State Space Reduction

### Canonical State Representation

```elixir
# Reduce equivalent states to single representation
defp canonicalize(state) do
  state
  |> Map.update!(:items, &Enum.sort/1)
  |> Map.update!(:effects, &normalize_effects/1)
end

# Hash states for deduplication
defp state_hash(state) do
  canonical = canonicalize(state)
  :erlang.phash2(canonical)
end

# Track visited states
defp explore_with_dedup(initial) do
  explore([initial], MapSet.new(), [])
end

defp explore([], _visited, results), do: results

defp explore([state | queue], visited, results) do
  hash = state_hash(state)
  
  if MapSet.member?(visited, hash) do
    explore(queue, visited, results)
  else
    new_visited = MapSet.put(visited, hash)
    
    case process_state(state) do
      {:solution, result} ->
        explore(queue, new_visited, [result | results])
      
      {:expand, next_states} ->
        explore(next_states ++ queue, new_visited, results)
    end
  end
end
```

### Symmetry Breaking

```elixir
# For problems with symmetries, explore only one representative
defp break_symmetry(states) do
  states
  |> Enum.map(&{canonical_form(&1), &1})
  |> Enum.uniq_by(&elem(&1, 0))
  |> Enum.map(&elem(&1, 1))
end

# Example: TSP with rotational symmetry
defp canonical_tour(tour) do
  # Always start from smallest city
  min_city = Enum.min(tour)
  idx = Enum.find_index(tour, &(&1 == min_city))
  
  Enum.drop(tour, idx) ++ Enum.take(tour, idx)
end
```

## 5. Constraint Propagation

**Problem:** Reduce search space by eliminating invalid options early.

```elixir
defp solve_with_constraints(state, constraints) do
  # Propagate constraints
  case propagate_constraints(state, constraints) do
    {:invalid, _} -> nil
    {:solved, solution} -> solution
    {:partial, new_state} ->
      # Choose variable and try values
      {var, values} = select_unassigned(new_state)
      
      values
      |> Enum.find_value(fn value ->
        new_state
        |> assign(var, value)
        |> solve_with_constraints(constraints)
      end)
  end
end

defp propagate_constraints(state, constraints) do
  Enum.reduce_while(constraints, state, fn constraint, acc ->
    case apply_constraint(acc, constraint) do
      {:ok, new_state} -> {:cont, new_state}
      {:invalid, reason} -> {:halt, {:invalid, reason}}
    end
  end)
end
```

## 6. Beam Search

**Problem:** Limit memory in large state spaces by keeping only top-K states.

```elixir
defp beam_search(initial_state, beam_width, max_depth) do
  beam_search_helper([initial_state], beam_width, 0, max_depth)
end

defp beam_search_helper(beam, _width, depth, max_depth) when depth >= max_depth do
  Enum.find_value(beam, fn state ->
    if is_solution?(state), do: state
  end)
end

defp beam_search_helper(beam, width, depth, max_depth) do
  # Expand all states in beam
  expanded = beam
  |> Enum.flat_map(&expand_state/1)
  
  # Keep only top-K by score
  new_beam = expanded
  |> Enum.sort_by(&score/1, :desc)
  |> Enum.take(width)
  
  # Check for solutions
  case Enum.find(new_beam, &is_solution?/1) do
    nil -> beam_search_helper(new_beam, width, depth + 1, max_depth)
    solution -> solution
  end
end
```

## 7. Meet in the Middle

**Problem:** Search space is too large (2^N), but can be split.

```elixir
defp meet_in_middle(items, target) do
  {left, right} = Enum.split(items, div(length(items), 2))
  
  # Generate all sums from left half
  left_sums = all_subset_sums(left)
  |> Map.new(fn {sum, subset} -> {sum, subset} end)
  
  # For each right half sum, check if complement exists in left
  right_sums = all_subset_sums(right)
  
  Enum.find_value(right_sums, fn {r_sum, r_subset} ->
    complement = target - r_sum
    
    if Map.has_key?(left_sums, complement) do
      {:ok, Map.get(left_sums, complement) ++ r_subset}
    end
  end)
end

defp all_subset_sums(items) do
  power_set(items)
  |> Enum.map(fn subset -> {Enum.sum(subset), subset} end)
end
```

**Complexity:** Reduces O(2^N) to O(2^(N/2))

## 8. Dynamic Programming with Memoization

```elixir
defp solve_with_memo(state, memo \\ %{}) do
  key = state_key(state)
  
  if Map.has_key?(memo, key) do
    {Map.get(memo, key), memo}
  else
    {result, new_memo} = compute_solution(state, memo)
    {result, Map.put(new_memo, key, result)}
  end
end
```

See [Dynamic Programming](dynamic_programming.md) for more details.

## Performance Tips

1. **Pruning is crucial** - Good bounds can reduce search by orders of magnitude
2. **State representation matters** - Smaller states = more fits in memory
3. **Canonical forms** prevent exploring equivalent states multiple times
4. **Early termination** - Return as soon as solution found (if any solution works)
5. **Memoization** - Essential for overlapping subproblems
6. **Choose right data structure** - Heap for priority queue, MapSet for visited tracking

## Common Pitfalls

- **Greedy doesn't always work** - Verify with examples first
- **Forgetting to prune** - Makes search intractable
- **Wrong heuristic** - Can miss optimal solution in A*
- **State explosion** - Need to limit or deduplicate states
- **Memory vs. time tradeoff** - Sometimes better to recompute than memoize

## Related Patterns
- [BFS](bfs.md) - Systematic exploration
- [Dynamic Programming](dynamic_programming.md) - Memoization strategies
- [Graph Algorithms](graph_algorithms.md) - Network flow, matching problems
