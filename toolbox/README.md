# AoC Algorithm Toolbox - Index

## Overview
This toolbox contains reusable algorithms, patterns, and code snippets extracted from Advent of Code solutions (2018-2025). Each file includes explanations, code examples, and references to specific problems where the pattern was used.

## Core Algorithms

### Graph & Search Algorithms
- **[BFS (Breadth-First Search)](bfs.md)** - Shortest path in unweighted graphs, level-order traversal
  - 2024 Days: 18, 2023 Days: 21, 2022 Days: 12, 18, 24
- **[DFS (Depth-First Search)](dfs.md)** - All paths, connected components, exhaustive search
  - 2024 Days: 10, 12, 2023 Days: 3, 23
- **[Dijkstra & A*](dijkstra_astar.md)** - Shortest path in weighted graphs
  - 2024 Day: 16, 2023 Day: 17
- **[Graph Algorithms](graph_algorithms.md)** - Cliques, topological sort, min-cut, graph collapse
  - 2024 Day: 23, 2023 Days: 8, 23, 25

### Dynamic Programming & Optimization
- **[Dynamic Programming & Memoization](dynamic_programming.md)** - Overlapping subproblems, optimization
  - 2024 Days: 11, 21, 2023 Days: 12, 19, 2022 Days: 16, 17, 19
- **[Optimization & Search Strategies](optimization_search.md)** - Branch & bound, greedy, pruning, beam search
  - 2015 Days: 13, 15, 17, 22, 24

### Geometric & Mathematical
- **[Mathematical Algorithms](mathematical_algorithms.md)** - GCD/LCM, linear systems, geometry formulas
  - 2024 Day: 13, 2023 Days: 6, 8, 11, 18, 21, 2022 Day: 11
- **[Number Theory & Combinatorics](number_theory.md)** - Sieves, modular arithmetic, triangular numbers, partitions
  - 2015 Days: 17, 20, 24, 25

### State & Simulation
- **[Cycle Detection](cycle_detection.md)** - Finding repeating patterns for optimization
  - 2023 Day: 14, 2022 Day: 17, 2018 Day: 1
- **[Simulation & State Management](simulation.md)** - Managing complex state evolution
  - 2024 Days: 6, 14, 15, 2022 Days: 9, 11, 14, 17, 23, 24

## Data Structures & Operations

- **[Grid Representation & Operations](grid_operations.md)** - 2D/3D grids, navigation, transformations
  - Used in nearly every year: 2024 Days: 4, 6, 8, 12, 15, 16, 18, 20, 25
  - 2023 Days: 3, 10, 13, 14, 16, 17, 18, 21, 23
  - 2022 Days: 8, 9, 12, 14, 17, 22, 23, 24

- **[Parsing Patterns](parsing.md)** - Input processing strategies
  - Every problem requires parsing! Common patterns for all input types

- **[String Algorithms](string_algorithms.md)** - Substring search, replacement, transformations, validation
  - 2015 Days: 5, 8, 10, 11, 19

## Language-Specific

- **[Elixir Idioms & Patterns](elixir_idioms.md)** - Elixir-specific patterns for AoC
  - Enum patterns, pipelines, pattern matching, MapSets, Streams

- **[Interpreter & VM Patterns](interpreter_patterns.md)** - Assembly interpreters, circuit evaluation, game state machines
  - 2015 Days: 7, 21, 22, 23

## Quick Reference by Problem Type

### Pathfinding Problems
→ [BFS](bfs.md) for unweighted, [Dijkstra](dijkstra_astar.md) for weighted

### Counting Problems  
→ [Dynamic Programming](dynamic_programming.md), [Mathematical](mathematical_algorithms.md)

### Grid Problems
→ [Grid Operations](grid_operations.md), [BFS](bfs.md), [DFS](dfs.md)

### Large Iteration Counts
→ [Cycle Detection](cycle_detection.md), [Mathematical](mathematical_algorithms.md)

### State Evolution
→ [Simulation](simulation.md), [Cycle Detection](cycle_detection.md)

### Graph/Network Problems
→ [Graph Algorithms](graph_algorithms.md), [BFS](bfs.md), [DFS](dfs.md)

## Algorithm Selection Guide

### "Find shortest path"
- Unweighted graph? → **BFS**
- Weighted graph? → **Dijkstra or A***
- All pairs? → **Floyd-Warshall** (see Graph Algorithms)

### "Count number of ways"
- Overlapping subproblems? → **Dynamic Programming**
- Small search space? → **DFS with counting**
- Mathematical formula? → **Combinatorics** (see Mathematical)

### "Simulate N steps where N is huge"
- Look for **Cycle Detection**
- Try to find mathematical formula

### "Find connected regions"
- → **DFS or BFS** (flood fill pattern)

### "Optimize/maximize/minimize"
- Constraints allow brute force? → **DFS with pruning**
- Overlapping subproblems? → **Dynamic Programming**
- Graph problem? → **Dijkstra** or **specialized graph algorithm**

### "Parse complex input"
- → Check **Parsing Patterns** for similar format

## Common AoC Patterns by Year

### 2024 Highlights
- Day 11: Memoization for exponential growth
- Day 13: Cramer's rule for linear systems  
- Day 16: Dijkstra with complex state (position + direction)
- Day 23: Bron-Kerbosch for maximum clique

### 2023 Highlights
- Day 12: DP with string constraints
- Day 14: Cycle detection for grid simulation
- Day 17: A* with movement constraints
- Day 18: Shoelace formula + Pick's theorem
- Day 21: Lagrange interpolation for quadratic growth
- Day 25: Randomized min-cut

### 2022 Highlights
- Day 11: Modular arithmetic optimization
- Day 12: BFS with height constraints
- Day 16: Floyd-Warshall + state pruning
- Day 17: Cycle detection for Tetris simulation
- Day 23: Cellular automaton with collision detection

## Tips for Using This Toolbox

1. **Start with Problem Type**: Identify what kind of problem you're solving
2. **Check Similar Problems**: Look at the "Used In" section of relevant algorithms
3. **Adapt, Don't Copy**: Understand the pattern and adapt to your specific problem
4. **Combine Techniques**: Many problems require multiple algorithms
5. **Read Examples**: Code snippets show actual usage patterns

## Contributing Your Own Patterns

When you solve a problem with an interesting technique:
1. Note the algorithm/pattern used
2. Add reference to the relevant toolbox file
3. Consider creating new file for novel patterns

## Performance Considerations

- **MapSet** for set operations (much faster than lists)
- **Maps** for key-value lookups (O(log n))
- **Streams** for large/infinite sequences
- **Memoization** when subproblems repeat
- **Cycle detection** for huge iteration counts
- **Mathematical formulas** over simulation when possible

---

Remember: The best solution is the one that works correctly first, optimize only if needed!
