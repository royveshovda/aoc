# Dijkstra's Algorithm & A*

## Overview
Dijkstra's algorithm finds the shortest path in weighted graphs. A* is an optimized version that uses heuristics to guide the search.

## When to Use
- Shortest path in weighted graphs
- Minimum cost pathfinding
- When edges have different costs (movement, rotation, etc.)
- A* when you have a good heuristic (e.g., Manhattan distance to goal)

## Used In
- 2024 Day 16 (Reindeer Maze - pathfinding with rotation costs)
- 2023 Day 17 (Clumsy Crucible - A* with direction constraints)

## Dijkstra with Priority Queue (gb_sets)

```elixir
def dijkstra(grid, start, goal) do
  # Priority queue: {cost, position}
  queue = :gb_sets.singleton({0, start})
  costs = %{start => 0}
  
  dijkstra_loop(queue, costs, goal, grid)
end

defp dijkstra_loop(queue, costs, goal, grid) do
  case :gb_sets.is_empty(queue) do
    true -> nil  # No path found
    false ->
      {{cost, current}, queue} = :gb_sets.take_smallest(queue)
      
      if current == goal do
        cost
      else
        neighbors = get_neighbors(current, grid)
        
        {queue, costs} = 
          Enum.reduce(neighbors, {queue, costs}, fn {neighbor, edge_cost}, {q, c} ->
            new_cost = cost + edge_cost
            
            if new_cost < Map.get(c, neighbor, :infinity) do
              q = :gb_sets.add({new_cost, neighbor}, q)
              c = Map.put(c, neighbor, new_cost)
              {q, c}
            else
              {q, c}
            end
          end)
        
        dijkstra_loop(queue, costs, goal, grid)
      end
  end
end
```

## Dijkstra with State (Position + Direction) - 2024 Day 16

```elixir
def dijkstra_with_direction(grid, start, goal) do
  # State: {cost, position, direction, path}
  start_state = {0, start, {0, 1}, [start]}
  queue = :gb_sets.singleton(start_state)
  visited = MapSet.new()
  
  dijkstra_dir_loop(queue, visited, goal, grid)
end

defp dijkstra_dir_loop(queue, visited, goal, grid) do
  case :gb_sets.is_empty(queue) do
    true -> nil
    false ->
      {{cost, pos, dir, path}, queue} = :gb_sets.take_smallest(queue)
      
      if pos == goal do
        {cost, path}
      else
        if MapSet.member?(visited, {pos, dir}) do
          dijkstra_dir_loop(queue, visited, goal, grid)
        else
          visited = MapSet.put(visited, {pos, dir})
          
          # Generate neighbors with different costs
          neighbors = [
            # Move forward: cost + 1
            {cost + 1, move_forward(pos, dir), dir, [move_forward(pos, dir) | path]},
            # Rotate clockwise: cost + 1000
            {cost + 1000, pos, rotate_cw(dir), path},
            # Rotate counter-clockwise: cost + 1000
            {cost + 1000, pos, rotate_ccw(dir), path}
          ]
          |> Enum.filter(fn {_, new_pos, _, _} -> grid[new_pos] != "#" end)
          
          queue = Enum.reduce(neighbors, queue, fn state, q ->
            :gb_sets.add(state, q)
          end)
          
          dijkstra_dir_loop(queue, visited, goal, grid)
        end
      end
  end
end

defp rotate_cw({dx, dy}), do: {dy, -dx}
defp rotate_ccw({dx, dy}), do: {-dy, dx}
defp move_forward({x, y}, {dx, dy}), do: {x + dx, y + dy}
```

## A* with Manhattan Distance Heuristic - 2023 Day 17

```elixir
def a_star(grid, start, goal) do
  h = fn pos -> manhattan_distance(pos, goal) end
  
  # Priority queue: {f_score, g_score, position, direction}
  # f_score = g_score + h(position)
  start_state = {h.(start), 0, start, :horizontal}
  queue = Heap.new() |> Heap.push(start_state)
  costs = %{start => 0}
  
  a_star_loop(queue, costs, goal, grid, h)
end

defp a_star_loop(queue, costs, goal, grid, heuristic) do
  case Heap.empty?(queue) do
    true -> nil
    false ->
      {{_f, g, pos, dir}, queue} = Heap.split(queue)
      
      if pos == goal do
        g  # Return cost
      else
        neighbors = generate_neighbors(pos, dir, grid)
        
        {queue, costs} = 
          Enum.reduce(neighbors, {queue, costs}, fn {next_pos, next_dir, edge_cost}, {q, c} ->
            new_g = g + edge_cost
            
            if new_g < Map.get(c, {next_pos, next_dir}, :infinity) do
              new_f = new_g + heuristic.(next_pos)
              q = Heap.push(q, {new_f, new_g, next_pos, next_dir})
              c = Map.put(c, {next_pos, next_dir}, new_g)
              {q, c}
            else
              {q, c}
            end
          end)
        
        a_star_loop(queue, costs, goal, grid, heuristic)
      end
  end
end

defp manhattan_distance({x1, y1}, {x2, y2}) do
  abs(x1 - x2) + abs(y1 - y2)
end
```

## Using Heap Library for Priority Queue

```elixir
# Add to mix.exs: {:heap, "~> 3.0"}

def dijkstra_with_heap(grid, start, goal) do
  queue = Heap.new() |> Heap.push({0, start})
  costs = %{start => 0}
  
  dijkstra_heap_loop(queue, costs, goal, grid)
end

defp dijkstra_heap_loop(queue, costs, goal, grid) do
  case Heap.empty?(queue) do
    true -> nil
    false ->
      {{cost, current}, queue} = Heap.split(queue)
      
      if current == goal do
        cost
      else
        # Skip if we've found a better path already
        if cost > Map.get(costs, current, :infinity) do
          dijkstra_heap_loop(queue, costs, goal, grid)
        else
          neighbors = get_neighbors(current, grid)
          
          {queue, costs} = 
            Enum.reduce(neighbors, {queue, costs}, fn {neighbor, edge_cost}, {q, c} ->
              new_cost = cost + edge_cost
              
              if new_cost < Map.get(c, neighbor, :infinity) do
                q = Heap.push(q, {new_cost, neighbor})
                c = Map.put(c, neighbor, new_cost)
                {q, c}
              else
                {q, c}
              end
            end)
          
          dijkstra_heap_loop(queue, costs, goal, grid)
        end
      end
  end
end
```

## Path Reconstruction

```elixir
def dijkstra_with_path(grid, start, goal) do
  queue = :gb_sets.singleton({0, start, [start]})
  costs = %{start => 0}
  
  dijkstra_path_loop(queue, costs, goal, grid)
end

defp dijkstra_path_loop(queue, costs, goal, grid) do
  case :gb_sets.is_empty(queue) do
    true -> {:error, :no_path}
    false ->
      {{cost, current, path}, queue} = :gb_sets.take_smallest(queue)
      
      if current == goal do
        {:ok, cost, Enum.reverse(path)}
      else
        neighbors = get_neighbors(current, grid)
        
        {queue, costs} = 
          Enum.reduce(neighbors, {queue, costs}, fn {neighbor, edge_cost}, {q, c} ->
            new_cost = cost + edge_cost
            
            if new_cost < Map.get(c, neighbor, :infinity) do
              q = :gb_sets.add({new_cost, neighbor, [neighbor | path]}, q)
              c = Map.put(c, neighbor, new_cost)
              {q, c}
            else
              {q, c}
            end
          end)
        
        dijkstra_path_loop(queue, costs, goal, grid)
      end
  end
end
```

## Key Points
- **Dijkstra**: Guarantees shortest path in weighted graphs (non-negative weights)
- **A***: Faster than Dijkstra when good heuristic available
- **Priority Queue**: Essential for performance
  - `:gb_sets` (Erlang balanced tree) - good for most cases
  - `Heap` library - cleaner API, similar performance
- **State Representation**: Can include position, direction, constraints, etc.
- **Heuristic Requirements** (A*): Must be admissible (never overestimate) and consistent
- **Visited Set**: Track explored states to avoid redundant work
- **Cost Tracking**: Maintain best-known cost to each state

## Common Heuristics
- **Manhattan Distance**: `|x1 - x2| + |y1 - y2|` (grid with 4-directional movement)
- **Euclidean Distance**: `sqrt((x1-x2)² + (y1-y2)²)` (free movement)
- **Chebyshev Distance**: `max(|x1-x2|, |y1-y2|)` (grid with 8-directional movement)
- **Zero Heuristic**: A* becomes Dijkstra

## Optimization Tips
- Skip states already processed with lower cost
- Use efficient priority queue implementation
- Consider bidirectional search for long paths
- Precompute heuristic values if possible
- For grid-based problems, can optimize with corridor detection (2024 Day 16)
