# Graph Algorithms

## Overview
Graph problems are common in AoC. This covers graph representation and key algorithms beyond BFS/DFS.

## When to Use
- Network/connection problems
- Pathfinding with constraints
- Finding cliques, components
- Dependency resolution

## Used In
- 2024 Day 23 (LAN Party - cliques)
- 2023 Day 8 (Network traversal with LCM)
- 2023 Day 25 (Min-cut problem)
- 2023 Day 23 (Longest path, graph collapse)

## Graph Representation

```elixir
# Adjacency List (most common)
def build_adjacency_list(edges) do
  edges
  |> Enum.reduce(%{}, fn {from, to}, acc ->
    acc
    |> Map.update(from, [to], &[to | &1])
    |> Map.update(to, [from], &[from | &1])  # For undirected
  end)
end

# Adjacency List with MapSet (for fast membership)
def build_adjacency_mapset(edges) do
  edges
  |> Enum.reduce(%{}, fn {from, to}, acc ->
    acc
    |> Map.update(from, MapSet.new([to]), &MapSet.put(&1, to))
    |> Map.update(to, MapSet.new([from]), &MapSet.put(&1, from))
  end)
end

# Weighted graph
def build_weighted_graph(edges) do
  edges
  |> Enum.reduce(%{}, fn {from, to, weight}, acc ->
    acc
    |> Map.update(from, [{to, weight}], &[{to, weight} | &1])
  end)
end
```

## Finding Connected Components

```elixir
def find_components(graph) do
  nodes = Map.keys(graph)
  find_components_helper(nodes, graph, [], MapSet.new())
end

defp find_components_helper([], _graph, components, _visited), do: components

defp find_components_helper([node | rest], graph, components, visited) do
  if MapSet.member?(visited, node) do
    find_components_helper(rest, graph, components, visited)
  else
    component = explore_component(node, graph, MapSet.new())
    visited = MapSet.union(visited, component)
    find_components_helper(rest, graph, [component | components], visited)
  end
end

defp explore_component(node, graph, visited) do
  if MapSet.member?(visited, node) do
    visited
  else
    visited = MapSet.put(visited, node)
    neighbors = Map.get(graph, node, [])
    
    Enum.reduce(neighbors, visited, fn neighbor, v ->
      explore_component(neighbor, graph, v)
    end)
  end
end
```

## Bron-Kerbosch Algorithm (Maximum Clique) - 2024 Day 23

```elixir
def find_maximum_clique(graph) do
  nodes = Map.keys(graph) |> MapSet.new()
  
  bron_kerbosch(MapSet.new(), nodes, MapSet.new(), graph, [])
  |> Enum.max_by(&MapSet.size/1)
end

defp bron_kerbosch(r, p, x, graph, cliques) do
  if MapSet.size(p) == 0 and MapSet.size(x) == 0 do
    # Found maximal clique
    [r | cliques]
  else
    # Choose pivot (optimization)
    pivot = pick_pivot(p, x)
    non_neighbors = MapSet.difference(p, Map.get(graph, pivot, MapSet.new()))
    
    Enum.reduce(non_neighbors, {p, x, cliques}, fn v, {p_acc, x_acc, cliques_acc} ->
      neighbors = Map.get(graph, v, MapSet.new())
      
      new_cliques = bron_kerbosch(
        MapSet.put(r, v),
        MapSet.intersection(p_acc, neighbors),
        MapSet.intersection(x_acc, neighbors),
        graph,
        cliques_acc
      )
      
      {MapSet.delete(p_acc, v), MapSet.put(x_acc, v), new_cliques}
    end)
    |> elem(2)
  end
end

defp pick_pivot(p, x) do
  MapSet.union(p, x) |> Enum.at(0)
end
```

## Finding All Triangles (3-Cliques) - 2024 Day 23

```elixir
def find_triangles(adjacency_map) do
  nodes = Map.keys(adjacency_map) |> Enum.sort()
  
  for a <- nodes,
      neighbors_a = adjacency_map[a],
      b <- neighbors_a,
      b > a,
      neighbors_b = adjacency_map[b],
      c <- neighbors_b,
      c > b,
      MapSet.member?(neighbors_a, c) do
    [a, b, c]
  end
end
```

## Topological Sort

```elixir
def topological_sort(graph) do
  # Kahn's algorithm
  in_degree = calculate_in_degrees(graph)
  
  # Start with nodes that have no incoming edges
  queue = in_degree
  |> Enum.filter(fn {_, degree} -> degree == 0 end)
  |> Enum.map(&elem(&1, 0))
  |> :queue.from_list()
  
  topological_sort_loop(queue, [], graph, in_degree)
end

defp topological_sort_loop(queue, sorted, graph, in_degree) do
  case :queue.out(queue) do
    {{:value, node}, queue} ->
      sorted = [node | sorted]
      
      # Reduce in-degree of neighbors
      neighbors = Map.get(graph, node, [])
      {queue, in_degree} = Enum.reduce(neighbors, {queue, in_degree}, fn neighbor, {q, deg} ->
        new_degree = Map.get(deg, neighbor) - 1
        deg = Map.put(deg, neighbor, new_degree)
        
        if new_degree == 0 do
          {:queue.in(neighbor, q), deg}
        else
          {q, deg}
        end
      end)
      
      topological_sort_loop(queue, sorted, graph, in_degree)
    
    {:empty, _} ->
      Enum.reverse(sorted)
  end
end

defp calculate_in_degrees(graph) do
  nodes = Map.keys(graph)
  
  Enum.reduce(nodes, %{}, fn node, acc ->
    neighbors = Map.get(graph, node, [])
    acc = Map.put_new(acc, node, 0)
    
    Enum.reduce(neighbors, acc, fn neighbor, a ->
      Map.update(a, neighbor, 1, &(&1 + 1))
    end)
  end)
end
```

## Graph Collapse/Simplification (2023 Day 23)

```elixir
def collapse_corridors(graph, start, goal) do
  # Find junction nodes (more than 2 neighbors)
  junctions = find_junctions(graph) ++ [start, goal]
  
  # Build simplified graph with edge weights
  Enum.reduce(junctions, %{}, fn junction, collapsed ->
    edges = find_edges_from_junction(junction, graph, junctions)
    Map.put(collapsed, junction, edges)
  end)
end

defp find_junctions(graph) do
  graph
  |> Enum.filter(fn {_node, neighbors} -> length(neighbors) > 2 end)
  |> Enum.map(&elem(&1, 0))
end

defp find_edges_from_junction(start, graph, junctions) do
  initial_neighbors = Map.get(graph, start, [])
  
  Enum.map(initial_neighbors, fn neighbor ->
    {end_node, distance} = follow_corridor(neighbor, start, graph, junctions, 1)
    {end_node, distance}
  end)
end

defp follow_corridor(current, previous, graph, junctions, distance) do
  if current in junctions do
    {current, distance}
  else
    neighbors = Map.get(graph, current, [])
    [next] = neighbors -- [previous]  # Only one way to go
    follow_corridor(next, current, graph, junctions, distance + 1)
  end
end
```

## Shortest Path - All Pairs (Floyd-Warshall)

```elixir
def floyd_warshall(graph) do
  nodes = Map.keys(graph)
  
  # Initialize distances
  dist = initialize_distances(nodes, graph)
  
  # Floyd-Warshall algorithm
  Enum.reduce(nodes, dist, fn k, dist_k ->
    Enum.reduce(nodes, dist_k, fn i, dist_ik ->
      Enum.reduce(nodes, dist_ik, fn j, dist_ikj ->
        d_ik = Map.get(dist_ikj, {i, k}, :infinity)
        d_kj = Map.get(dist_ikj, {k, j}, :infinity)
        d_ij = Map.get(dist_ikj, {i, j}, :infinity)
        
        if d_ik != :infinity and d_kj != :infinity do
          new_dist = d_ik + d_kj
          if new_dist < d_ij do
            Map.put(dist_ikj, {i, j}, new_dist)
          else
            dist_ikj
          end
        else
          dist_ikj
        end
      end)
    end)
  end)
end

defp initialize_distances(nodes, graph) do
  # Distance to self is 0
  base = Enum.map(nodes, fn n -> {{n, n}, 0} end) |> Map.new()
  
  # Direct edges
  Enum.reduce(graph, base, fn {from, neighbors}, acc ->
    Enum.reduce(neighbors, acc, fn {to, weight}, a ->
      Map.put(a, {from, to}, weight)
    end)
  end)
end
```

## Strongly Connected Components (Tarjan's Algorithm)

```elixir
def tarjan_scc(graph) do
  nodes = Map.keys(graph)
  
  initial_state = %{
    index: 0,
    stack: [],
    indices: %{},
    lowlinks: %{},
    on_stack: MapSet.new(),
    sccs: []
  }
  
  Enum.reduce(nodes, initial_state, fn node, state ->
    if Map.has_key?(state.indices, node) do
      state
    else
      strongconnect(node, graph, state)
    end
  end)
  |> Map.get(:sccs)
end

defp strongconnect(v, graph, state) do
  state = %{state |
    index: state.index + 1,
    indices: Map.put(state.indices, v, state.index),
    lowlinks: Map.put(state.lowlinks, v, state.index),
    stack: [v | state.stack],
    on_stack: MapSet.put(state.on_stack, v)
  }
  
  neighbors = Map.get(graph, v, [])
  
  state = Enum.reduce(neighbors, state, fn w, s ->
    cond do
      not Map.has_key?(s.indices, w) ->
        s = strongconnect(w, graph, s)
        lowlink_v = min(s.lowlinks[v], s.lowlinks[w])
        %{s | lowlinks: Map.put(s.lowlinks, v, lowlink_v)}
      
      MapSet.member?(s.on_stack, w) ->
        lowlink_v = min(s.lowlinks[v], s.indices[w])
        %{s | lowlinks: Map.put(s.lowlinks, v, lowlink_v)}
      
      true ->
        s
    end
  end)
  
  # If v is a root node, pop the stack and generate an SCC
  if state.lowlinks[v] == state.indices[v] do
    {scc, stack, on_stack} = pop_scc(v, state.stack, state.on_stack, [])
    %{state | stack: stack, on_stack: on_stack, sccs: [scc | state.sccs]}
  else
    state
  end
end

defp pop_scc(v, [w | stack], on_stack, scc) do
  on_stack = MapSet.delete(on_stack, w)
  scc = [w | scc]
  
  if w == v do
    {scc, stack, on_stack}
  else
    pop_scc(v, stack, on_stack, scc)
  end
end
```

## Minimum Spanning Tree (Kruskal's)

```elixir
def kruskal_mst(edges) do
  # Sort edges by weight
  sorted_edges = Enum.sort_by(edges, fn {_, _, weight} -> weight end)
  
  # Union-Find data structure
  nodes = Enum.flat_map(edges, fn {a, b, _} -> [a, b] end) |> Enum.uniq()
  uf = UnionFind.new(nodes)
  
  Enum.reduce(sorted_edges, {[], uf}, fn {a, b, weight}, {mst, uf} ->
    if UnionFind.find(uf, a) != UnionFind.find(uf, b) do
      uf = UnionFind.union(uf, a, b)
      {[{a, b, weight} | mst], uf}
    else
      {mst, uf}
    end
  end)
  |> elem(0)
  |> Enum.reverse()
end

# Simple Union-Find implementation
defmodule UnionFind do
  def new(elements) do
    Map.new(elements, fn e -> {e, e} end)
  end
  
  def find(uf, x) do
    parent = uf[x]
    if parent == x, do: x, else: find(uf, parent)
  end
  
  def union(uf, x, y) do
    root_x = find(uf, x)
    root_y = find(uf, y)
    Map.put(uf, root_x, root_y)
  end
end
```

## Key Points
- **Adjacency List**: Most flexible representation
- **MapSet for Neighbors**: Fast membership testing
- **Graph Collapse**: Simplify before pathfinding
- **Choose Right Algorithm**:
  - Single source shortest path: Dijkstra/BFS
  - All pairs shortest path: Floyd-Warshall
  - Maximum clique: Bron-Kerbosch
  - Connected components: DFS/BFS
  - Topological sort: Kahn's algorithm
- **Undirected vs Directed**: Add edges in both directions for undirected
- **Optimization**: For sparse graphs, adjacency list >> matrix

## Common Graph Patterns in AoC
1. **Network analysis**: Finding connections, communities
2. **Shortest paths**: With various constraints
3. **Dependency graphs**: Topological ordering
4. **Cycle detection**: In state machines or processes
5. **Maximum flow**: Resource allocation problems
