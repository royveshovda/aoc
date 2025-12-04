# Depth-First Search (DFS)

## Overview
DFS explores as far as possible along each branch before backtracking. Useful for pathfinding, connected components, and exhaustive search.

## When to Use
- Finding all paths (not just shortest)
- Connected component detection
- Cycle detection
- Topological sorting
- Exploring all possible solutions

## Used In
- 2024 Day 10 (Hoof It - path counting with constraints)
- 2024 Day 12 (Garden Groups - region finding with flood fill)
- 2023 Day 23 (A Long Walk - finding longest path)
- 2023 Day 3 (Grid processing - number expansion)

## Basic Recursive DFS

```elixir
def dfs(current, goal, grid, visited \\ MapSet.new()) do
  cond do
    current == goal ->
      {:found, [current]}
    
    MapSet.member?(visited, current) ->
      nil
    
    true ->
      visited = MapSet.put(visited, current)
      neighbors = get_neighbors(current, grid)
      
      Enum.find_value(neighbors, fn neighbor ->
        case dfs(neighbor, goal, grid, visited) do
          {:found, path} -> {:found, [current | path]}
          nil -> nil
        end
      end)
  end
end
```

## DFS for All Paths (2024 Day 10)

```elixir
def count_all_paths(grid, start, target_value) do
  dfs_all_paths(grid, start, 0, target_value)
end

defp dfs_all_paths(grid, pos, current_value, target_value) do
  if current_value == target_value do
    1  # Found one path
  else
    {x, y} = pos
    next_value = current_value + 1
    
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
    |> Enum.filter(fn p -> grid[p] == next_value end)
    |> Enum.map(fn p -> dfs_all_paths(grid, p, next_value, target_value) end)
    |> Enum.sum()
  end
end
```

## DFS for Unique Endpoints (2024 Day 10)

```elixir
def find_reachable_endpoints(grid, start, target_value) do
  dfs_endpoints(grid, start, 0, target_value)
  |> Enum.uniq()
  |> length()
end

defp dfs_endpoints(grid, pos, current_value, target_value) do
  if current_value == target_value do
    [pos]  # Return this endpoint
  else
    {x, y} = pos
    next_value = current_value + 1
    
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
    |> Enum.filter(fn p -> grid[p] == next_value end)
    |> Enum.flat_map(fn p -> dfs_endpoints(grid, p, next_value, target_value) end)
  end
end
```

## Flood Fill / Connected Component (2024 Day 12)

```elixir
def find_regions(grid) do
  grid
  |> Enum.reduce({[], grid}, fn {pos, value}, {regions, remaining} ->
    if Map.has_key?(remaining, pos) do
      {region, new_remaining} = flood_fill(remaining, pos, value)
      {[region | regions], new_remaining}
    else
      {regions, remaining}
    end
  end)
  |> elem(0)
end

defp flood_fill(grid, pos, target_value, acc \\ []) do
  if grid[pos] == target_value do
    grid = Map.delete(grid, pos)
    acc = [pos | acc]
    
    neighbors = get_neighbors(pos)
    
    Enum.reduce(neighbors, {acc, grid}, fn neighbor, {acc, grid} ->
      flood_fill(grid, neighbor, target_value, acc)
    end)
  else
    {acc, grid}
  end
end
```

## DFS with Map-based State (2023 Day 3)

```elixir
def expand_number(grid, start_pos, visited \\ []) do
  do_expand_number(grid, [start_pos], visited)
end

defp do_expand_number(grid, [], visited), do: visited

defp do_expand_number(grid, [pos | rest], visited) do
  {row, col} = pos
  
  neighbors = [{row, col - 1}, {row, col + 1}]
  |> Enum.filter(fn coord ->
    is_digit?(grid[coord]) and coord not in visited and coord not in rest
  end)
  
  do_expand_number(grid, neighbors ++ rest, [pos | visited])
end

defp is_digit?(nil), do: false
defp is_digit?(char), do: char in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
```

## DFS for Maximum Path Length (2023 Day 23)

```elixir
def find_longest_path(graph, start, goal) do
  dfs_max_path(graph, start, goal, 0, MapSet.new())
end

defp dfs_max_path(graph, current, goal, cost, seen) do
  if current == goal do
    cost
  else
    seen = MapSet.put(seen, current)
    
    graph[current]
    |> Enum.reject(fn {next, _} -> MapSet.member?(seen, next) end)
    |> Enum.map(fn {next, path_cost} ->
      dfs_max_path(graph, next, goal, cost + path_cost, seen)
    end)
    |> Enum.max(fn -> 0 end)  # Return 0 if no valid paths
  end
end
```

## DFS with Backtracking for Exhaustive Search

```elixir
def find_all_solutions(state, constraints) do
  dfs_search(state, constraints, [])
end

defp dfs_search(state, constraints, solutions) do
  cond do
    complete?(state) and valid?(state, constraints) ->
      [state | solutions]
    
    not promising?(state, constraints) ->
      solutions  # Prune this branch
    
    true ->
      state
      |> generate_next_states()
      |> Enum.reduce(solutions, fn next_state, acc ->
        dfs_search(next_state, constraints, acc)
      end)
  end
end
```

## Iterative DFS with Stack

```elixir
def dfs_iterative(start, goal, grid) do
  stack = [{start, [start]}]  # {current, path}
  visited = MapSet.new()
  
  dfs_loop(stack, visited, goal, grid)
end

defp dfs_loop([], _visited, _goal, _grid), do: nil

defp dfs_loop([{current, path} | stack], visited, goal, grid) do
  cond do
    current == goal ->
      path
    
    MapSet.member?(visited, current) ->
      dfs_loop(stack, visited, goal, grid)
    
    true ->
      visited = MapSet.put(visited, current)
      neighbors = get_neighbors(current, grid)
      new_stack = Enum.map(neighbors, fn n -> {n, [n | path]} end) ++ stack
      dfs_loop(new_stack, visited, goal, grid)
  end
end
```

## Key Points
- DFS uses less memory than BFS for deep graphs
- Natural fit for recursive problems
- Does NOT guarantee shortest path (use BFS for that)
- Easy to track paths by maintaining path in recursion
- Use visited set to avoid infinite loops
- Can be implemented recursively or with explicit stack
- Tail call optimization possible with accumulator pattern

## When to Choose DFS Over BFS
- Need to find ALL paths, not just shortest
- Looking for any solution, not optimal one  
- Graph is very wide (BFS would use too much memory)
- Need to detect cycles
- Implementing backtracking algorithms
