# Breadth-First Search (BFS)

## Overview
BFS is a graph traversal algorithm that explores nodes level by level. It's optimal for finding the shortest path in unweighted graphs.

## When to Use
- Finding shortest path in unweighted graphs or grids
- Level-order traversal
- Finding minimum number of steps/moves
- Exploring all reachable states

## Used In
- 2024 Day 18 (RAM Run - grid pathfinding)
- 2023 Day 21 (Step Counter - reachable positions)
- 2022 Day 12 (Hill Climbing - shortest path with constraints)
- 2022 Day 18 (Boiling Boulders - 3D flood fill)
- 2022 Day 24 (Blizzard Basin - time-varying obstacles)

## Basic Template

```elixir
def bfs(start, goal, grid) do
  queue = :queue.from_list([{start, 0}])  # {position, distance}
  visited = MapSet.new([start])
  
  bfs_loop(queue, visited, goal, grid)
end

defp bfs_loop(queue, visited, goal, grid) do
  case :queue.out(queue) do
    {{:value, {current, dist}}, queue} ->
      if current == goal do
        dist  # Found goal
      else
        neighbors = get_neighbors(current, grid)
        |> Enum.reject(&MapSet.member?(visited, &1))
        
        new_queue = Enum.reduce(neighbors, queue, fn n, q ->
          :queue.in({n, dist + 1}, q)
        end)
        new_visited = Enum.reduce(neighbors, visited, &MapSet.put(&2, &1))
        
        bfs_loop(new_queue, new_visited, goal, grid)
      end
    
    {:empty, _} ->
      nil  # No path found
  end
end

defp get_neighbors({x, y}, grid) do
  [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
  |> Enum.filter(fn pos -> Map.has_key?(grid, pos) and grid[pos] != "#" end)
end
```

## With MapSet for Current Level (2023 Day 21)

```elixir
def bfs_levels(starts, grid, max_steps) do
  Stream.iterate({starts, 0}, fn {current, step} ->
    next = current
    |> Enum.flat_map(&neighbors/1)
    |> Enum.filter(fn pos -> grid[pos] == "." end)
    |> MapSet.new()
    
    {next, step + 1}
  end)
  |> Enum.at(max_steps)
  |> elem(0)
  |> MapSet.size()
end
```

## 3D BFS (2022 Day 18)

```elixir
def bfs_3d(start, lava_cubes, bounds) do
  queue = :queue.from_list([start])
  found = MapSet.new([start])
  
  bfs_3d_loop(queue, found, lava_cubes, bounds)
end

defp bfs_3d_loop(queue, found, lava, {x_range, y_range, z_range}) do
  case :queue.out(queue) do
    {{:value, {x, y, z}}, queue} ->
      neighbors = [
        {x + 1, y, z}, {x - 1, y, z},
        {x, y + 1, z}, {x, y - 1, z},
        {x, y, z + 1}, {x, y, z - 1}
      ]
      |> Enum.filter(fn {nx, ny, nz} ->
        nx in x_range and ny in y_range and nz in z_range and
        not MapSet.member?(lava, {nx, ny, nz}) and
        not MapSet.member?(found, {nx, ny, nz})
      end)
      
      new_queue = Enum.reduce(neighbors, queue, &:queue.in/2)
      new_found = Enum.reduce(neighbors, found, &MapSet.put(&2, &1))
      
      bfs_3d_loop(new_queue, new_found, lava, {x_range, y_range, z_range})
    
    {:empty, _} ->
      found
  end
end
```

## BFS with Time-Varying State (2022 Day 24)

```elixir
def bfs_with_time(start, goal, blizzards, bounds) do
  queue = :queue.from_list([{start, 0}])
  visited = MapSet.new([{start, 0}])  # Track {position, time}
  
  bfs_time_loop(queue, visited, goal, blizzards, bounds)
end

defp bfs_time_loop(queue, visited, goal, blizzards, bounds) do
  case :queue.out(queue) do
    {{:value, {pos, time}}, queue} ->
      if pos == goal do
        time
      else
        # Calculate blizzard positions at time + 1
        next_blizzards = move_blizzards(blizzards, bounds)
        blocked = blizzard_positions(next_blizzards)
        
        neighbors = [{pos, time + 1}] ++  # Wait in place
                   (get_neighbors(pos) 
                    |> Enum.map(&{&1, time + 1})
                    |> Enum.reject(fn {p, _} -> MapSet.member?(blocked, p) end))
        
        new_neighbors = Enum.reject(neighbors, &MapSet.member?(visited, &1))
        new_queue = Enum.reduce(new_neighbors, queue, &:queue.in/2)
        new_visited = Enum.reduce(new_neighbors, visited, &MapSet.put(&2, &1))
        
        bfs_time_loop(new_queue, new_visited, goal, blizzards, bounds)
      end
    
    {:empty, _} -> nil
  end
end
```

## Key Points
- Use `:queue` module for efficient FIFO operations
- Track visited nodes with MapSet to avoid cycles
- Store distance/steps as part of queue element
- Can track additional state (direction, time, etc.) if needed
- For multi-start problems, initialize queue with all starting positions
- BFS guarantees shortest path in unweighted graphs

## Variations
- **Multi-source BFS**: Start from multiple positions simultaneously
- **Bidirectional BFS**: Search from both start and goal
- **0-1 BFS**: For graphs with edge weights 0 or 1 (use deque)
- **Level-order BFS**: Process entire level before moving to next
