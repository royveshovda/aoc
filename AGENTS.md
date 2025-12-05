# Advent of Code - Agent Instructions

## Project Overview

This is an Advent of Code workspace using Elixir with the `advent_of_code_utils` library for input fetching and boilerplate generation. The project uses `mise` for managing Elixir and Erlang versions.

## Solution Requirements

When solving Advent of Code problems, **ALWAYS** follow these requirements:

### For Each Day Solved (Single or Batch):
1. **Implement examples as doctests**: Extract examples from the puzzle description and implement them as doctests in the solution file
2. **Verify with tests**: Run `mix test test/YYYY/DD_test.exs` to ensure all doctests pass for both parts
3. **Document learnings**: After solving, save any reusable patterns, algorithms, or important insights to:
   - `AGENTS.md` (for tips, common patterns, and gotchas specific to this project)
   - `toolbox/` folder (for general algorithm implementations and comprehensive guides)

These requirements apply whether solving a single day or multiple days in the same session.

## About Advent of Code

Advent of Code is an Advent calendar of small programming puzzles for a variety of skill levels that can be solved in any programming language. Puzzles are released daily during December, unlocking at midnight EST (UTC-5). Each puzzle has two parts, with the second part unlocking after completing the first.

Key characteristics:
- Puzzles generally increase in difficulty over time
- Every problem has a solution that completes in at most 15 seconds on ten-year-old hardware
- Test against provided examples first before trying with actual input
- If stuck, re-read the description carefully and build test cases

## Project Structure

```
aoc/
├── lib/
│   └── YYYY/           # Solutions organized by year (e.g., 2024/)
│       └── DD.ex       # Daily solution files (e.g., 1.ex, 2.ex)
├── input/
│   ├── YYYY_DD.txt              # Actual puzzle input
│   └── YYYY_DD_example_N.txt    # Example inputs from puzzle descriptions
├── test/
│   └── YYYY/           # Test files matching solution structure
├── toolbox/            # Reusable algorithms and patterns (see below)
├── config/
│   └── config.exs      # Configuration including AoC session cookie
└── mix.exs             # Project dependencies
```

## Algorithm Toolbox

The `toolbox/` directory contains a comprehensive collection of algorithms, patterns, and code snippets extracted from all AoC solutions (2018-2025). This is your reference library for solving new problems.

**📚 Start here: [toolbox/README.md](toolbox/README.md)**

### Available Resources

#### Core Algorithm Categories
- **[BFS](toolbox/bfs.md)** - Breadth-first search for shortest paths
- **[DFS](toolbox/dfs.md)** - Depth-first search for all paths and components
- **[Dijkstra & A*](toolbox/dijkstra_astar.md)** - Weighted graph pathfinding
- **[Graph Algorithms](toolbox/graph_algorithms.md)** - Cliques, topological sort, min-cut
- **[Dynamic Programming](toolbox/dynamic_programming.md)** - Memoization and optimization
- **[Optimization & Search](toolbox/optimization_search.md)** - Branch & bound, greedy, pruning strategies
- **[Mathematical Algorithms](toolbox/mathematical_algorithms.md)** - GCD/LCM, geometry, linear systems
- **[Number Theory & Combinatorics](toolbox/number_theory.md)** - Sieves, modular arithmetic, partitions
- **[Cycle Detection](toolbox/cycle_detection.md)** - Optimizing long simulations
- **[Simulation & State](toolbox/simulation.md)** - Managing complex state evolution
- **[Grid Operations](toolbox/grid_operations.md)** - 2D/3D grid manipulation
- **[Parsing Patterns](toolbox/parsing.md)** - Input processing strategies
- **[String Algorithms](toolbox/string_algorithms.md)** - Substring operations, transformations, validation
- **[Interpreter Patterns](toolbox/interpreter_patterns.md)** - VMs, assembly interpreters, circuit evaluation
- **[Elixir Idioms](toolbox/elixir_idioms.md)** - Language-specific patterns

### When to Use the Toolbox

1. **Before Starting**: Check for similar problem types
2. **When Stuck**: Look for applicable algorithms
3. **For Optimization**: Find better approaches than brute force
4. **Learning**: See how patterns were used in past solutions

### Quick Problem Type → Algorithm Guide

- **Shortest path** → BFS (unweighted) or Dijkstra (weighted)
- **Count ways** → Dynamic Programming
- **Large iterations** → Cycle Detection or Math formulas
- **Grid problems** → Grid Operations + BFS/DFS
- **Graph networks** → Graph Algorithms
- **State evolution** → Simulation patterns
- **String manipulation** → String Algorithms (replacement, transformation)
- **Number properties** → Number Theory (sieves, modular arithmetic)
- **Optimization with constraints** → Optimization & Search (branch & bound, greedy)
- **Assembly/VM simulation** → Interpreter Patterns
- **Partitioning items** → Combinatorics (incremental search by size)

## Dependencies

Core libraries used in this project:
- `advent_of_code_utils` (~> 5.0.2) - Input fetching and boilerplate generation
- `nimble_parsec` (~> 1.4.2) - Parser combinator library
- `arrays` (~> 2.1.1) - Array data structures
- `heap` (~> 3.0) - Priority queue implementations
- `qex` (~> 0.5) - Queue data structures
- `memoize` (~> 1.4.4) - Function memoization

## Environment Management

This project uses `mise` to manage Elixir and Erlang versions. Before starting work:

```bash
# Ensure mise is installed and up to date
mise self-update -y

# Install/activate project versions
mise install
```

## Typical Workflow

### 1. Starting a New Puzzle

Use the `mix aoc` task to generate boilerplate for today's puzzle:

```bash
mix aoc
# Or specify year and day:
mix aoc -y 2024 -d 1
```

This will:
- Create `lib/YYYY/DD.ex` with boilerplate code
- Download input to `input/YYYY_DD.txt`
- Download example inputs to `input/YYYY_DD_example_N.txt`
- Print the puzzle URL

### 2. Solution File Structure

Each solution file follows this pattern:

```elixir
import AOC

aoc YYYY, DD do
  @moduledoc """
  https://adventofcode.com/YYYY/day/DD
  """

  def p1(input) do
    # Part 1 solution
    input
  end

  def p2(input) do
    # Part 2 solution
    input
  end
end
```

The `aoc` macro from `advent_of_code_utils` handles:
- Module definition (creates module named `YYYYY.DDD` - e.g., `Y2025.D1`)
- Input parsing
- Integration with IEx helpers

**IMPORTANT: Module Naming Convention**
- The `aoc YYYY, DD` macro creates a module named `YYYYY.DDD`
- Example: `aoc 2025, 1` creates module `Y2025.D1`
- Example: `aoc 2024, 15` creates module `Y2024.D15`
- When calling solutions programmatically, use the correct module name:
  ```elixir
  # Correct
  Y2025.D1.p1(input)
  
  # Incorrect
  AOC.Y2025.D1.p1(input)  # This won't work!
  ```

### 3. Testing Solutions in IEx

Start IEx with the project loaded:

```bash
iex -S mix
```

Use the provided helpers (imported with `import AOC.IEx` in `.iex.exs`):

```elixir
# Test with example input
p1e(2024, 1)        # Run part 1 with example input
p2e(2024, 1, 1)     # Run part 2 with example input #1

# Run with actual puzzle input
p1i(2024, 1)        # Run part 1 with puzzle input
p2i(2024, 1)        # Run part 2 with puzzle input

# Or use shorthand for current day
p1e()               # Part 1 with example
p1i()               # Part 1 with input
```

Configuration options in `config/config.exs`:
- `auto_compile?: true` - Auto-recompile when using IEx helpers
- `time_calls?: true` - Show runtime for solutions
- `gen_tests?: true` - Generate unit test boilerplate

### 4. Solution Development Tips

#### Input Parsing
Common patterns:

```elixir
# Split into lines
input |> String.split("\n", trim: true)

# Parse integers
input |> String.split("\n", trim: true) |> Enum.map(&String.to_integer/1)

# Handle multi-line input that should be single line (e.g., wrapped for display)
input |> String.trim() |> String.replace("\n", "")

# Parse grid/matrix
input 
|> String.split("\n", trim: true)
|> Enum.map(&String.graphemes/1)
|> Enum.with_index()
|> Enum.flat_map(fn {row, y} ->
  row |> Enum.with_index() |> Enum.map(fn {cell, x} -> {{x, y}, cell} end)
end)
|> Map.new()
```

#### Common Patterns
- Use `Enum.frequencies/1` for counting occurrences
- Use `Enum.zip/1` or `Enum.zip/2` for pairing lists
- Use `Enum.chunk_every/2` for grouping
- Use pattern matching in function heads
- Use `then/2` for pipeline continuation with custom logic
- Consider memoization (via `memoize` library) for recursive solutions
- When checking if a string is composed of repeating patterns, try all divisors of the string length
- For maximization problems with selections, consider greedy algorithms over brute force combinations
- **Keypad/Grid navigation with boundary checking:**
  - Use `Map.has_key?(grid, new_pos)` to check if move is valid
  - Only update position if new position exists in map
  - Works well for irregular/shaped grids (like diamond keypads)
- **String replacement at all positions:**
  - Find all substring occurrences and generate all possible single replacements
  - Use `MapSet` to deduplicate
  - For reverse problems (generate target from seed), greedy may work if input has special structure
- **ETS for performance:**
  - Use `:ets.new/2` for mutable state in hot loops
  - `update_counter` is very efficient for accumulation
  - Always clean up with `:ets.delete/1` in `try/after` block
- **Assembly interpreters:**
  - Store instructions in a map indexed by position
  - Use pattern matching for instruction dispatch
  - Tail recursion for interpreter loop
  - Memoization for dependent evaluations (circuit wires)
  - **Self-modifying code:** When instructions can change (like `tgl` in 2016 Day 23), store as mutable map
  - **Optimization patterns:** Detect common loops (e.g., multiplication via nested inc/dec) and replace with direct calculation
  - **Output tracking:** For programs with output instructions, collect output in accumulator and detect patterns
- **Reverse-engineering opcodes (2018 Day 16):**
  - Build constraint sets: for each opcode number, find all possible matching operations
  - Use intersection to narrow possibilities across multiple samples
  - Iterative constraint satisfaction: find opcodes with single possibility, assign them, remove from other sets
  - Continue until all mappings resolved
  - Pattern applies to any problem where you need to determine mappings from observations
- **String scrambling with reversible operations:**
  - Some operations are self-inverse (swap, reverse) - same in both directions
  - For complex operations (rotate based on position), compute inverse or brute-force search all possibilities
  - Store operations as data structures to enable bidirectional application
- **Hexagonal grids (2017 Day 11):**
  - Use cube coordinates `{x, y, z}` where `x + y + z = 0`
  - Distance = `(|x| + |y| + |z|) / 2`
  - Six directions: adjust two coordinates by ±1 each
  - See [Grid Operations](toolbox/grid_operations.md) for full implementation
- **Concurrent programs with message passing (2017 Day 18):**
  - Run each program until it blocks (waiting for input or terminated)
  - Exchange messages between blocked programs
  - Deadlock = both blocked with no messages in flight
  - See [Interpreter Patterns](toolbox/interpreter_patterns.md) for full implementation
- **Circular buffer optimization (2017 Day 17):**
  - For spinlock-style problems, track only the position you care about
  - Value 0 always stays at index 0 in spinlocks
  - Optimize by tracking when insertions happen at target position
  - O(n) instead of O(n²) with full buffer maintenance
- **Particle simulations (2017 Day 20):**
  - Long-term behavior dominated by acceleration
  - Group particles by position each tick to find collisions
  - Use "no collisions for N ticks" as stopping condition
  - See [Simulation](toolbox/simulation.md) for implementation
- **Sliding puzzle problems:**
  - Model as state-space search: `{empty_position, goal_position}`
  - Moving empty to goal swaps them
  - BFS for shortest path; don't rely on heuristics without validation
  - Identify immovable obstacles (walls) based on properties (e.g., capacity threshold)
- **TSP variants (Traveling Salesman):**
  - Build distance matrix between all points using BFS/Dijkstra
  - For small sets (≤8 locations), generate all permutations
  - Path distance = sum of consecutive pair distances
  - Part 2 often adds "return to start" constraint
- **Modular arithmetic edge cases:**
  - When dealing with circular/wrap-around logic (like dial positions 0-99)
  - Pay special attention to operations starting from position 0
  - Test edge cases: what happens at position 0? At max position?
  - Verify that "counting passes through X" logic handles starting at X correctly
  - Example: Moving left from position 0 doesn't immediately count as passing through 0 again
- **Pattern matching with transformations (2017 Day 21):**
  - Generate all orientations (rotations + flips) during parsing, not during lookup
  - 8 possible orientations: 4 rotations × 2 (original + flipped)
  - Store all variants in lookup map for O(1) matching
  - For grid splitting/joining: extract blocks, transform, reassemble
  - See [Grid Operations](toolbox/grid_operations.md) for full implementation
- **Component/bridge building problems (2017 Day 24):**
  - Recursive DFS with backtracking through available components
  - Track used components by removing from available set
  - Base case: no matching components for current port
  - Part 2 often asks for longest instead of strongest
- **Grid power/sum optimization (2018 Day 11):**
  - Use summed area table for O(1) rectangle sum queries
  - Preprocessing: O(N²), each query: O(1)
  - Critical for finding optimal squares of variable size
  - See [Grid Operations - Summed Area Table](toolbox/grid_operations.md)
- **Turn-based simulation with collision (2018 Day 13):**
  - Sort entities by position (top-to-bottom, left-to-right) each tick
  - Process one entity at a time, checking collisions with both processed and unprocessed
  - Each entity can carry internal state (e.g., turn counter)
  - See [Simulation - Turn-Based with Ordering](toolbox/simulation.md)
- **Combat simulation with movement and targeting (2018 Day 15):**
  - Units take turns in reading order (top-to-bottom, left-to-right by starting position)
  - Each turn: identify targets → move toward nearest → attack if in range
  - **Critical pathfinding bug**: Remove moving unit from units map during pathfinding!
    - Otherwise unit's current position blocks adjacent square exploration
    - Use `units_without_self = Map.delete(units, current_pos)` for BFS
  - **Movement algorithm**: BFS from TARGET backward, then pick adjacent cell with min distance
  - **Reading order tiebreaking**: For equidistant targets/moves, choose first in reading order
  - **Early termination for optimization**: In part 2, stop combat immediately when condition fails (e.g., elf dies)
  - Combat ends when a unit finds no targets during its turn (not at round end)
  - See [Simulation - Combat Systems](toolbox/simulation.md)
- **Reverse-engineering opcodes (2018 Day 16):**
  - Build constraint sets: for each opcode number, find all possible matching operations
  - Use intersection to narrow possibilities across multiple samples
  - Iterative constraint satisfaction: find opcodes with single possibility, assign them, remove from other sets
  - Continue until all mappings resolved
  - Pattern applies to any problem where you need to determine mappings from observations
- **Water flow simulation (2018 Day 17):**
  - Recursive flood-fill with two water states: flowing (|) and settled (~)
  - Water flows down when possible, spreads horizontally when blocked
  - Key insight: separate flow-down from spread-horizontally logic
  - When spreading: find left/right extent, check if bounded on both sides
  - If bounded: water settles (~), otherwise: water flows (|) and continues down from unbounded edges
  - **CRITICAL: Water rises!** When water settles in a row, check the row above - if positions there are flowing and now have support, fill them too
    - This creates cascading effect where containers fill layer by layer from bottom up
    - Without this, you'll massively undercount (e.g., 3369 vs 41027)
  - Important: mark flowing water at current position before recursing down from edges
  - Count only water tiles within min_y to max_y range
  - Part 2 counts only settled water (~), not flowing (|)
- **Cellular automaton with cycle detection (2018 Day 18):**
  - Classic Game of Life variant: each cell transforms based on 8-neighbor counts
  - Simultaneous updates: use current state to compute next state for all cells
  - Rules: open → trees (3+ tree neighbors), trees → lumber (3+ lumber neighbors), lumber → open (unless ≥1 lumber AND ≥1 tree neighbor)
  - Part 2 requires huge iteration count (1 billion): use cycle detection
  - Track seen states with serialized grid as key
  - Once cycle found: `offset = rem(target - cycle_start, cycle_length)`
  - Return state at `cycle_start + offset`
  - See [Cycle Detection](toolbox/cycle_detection.md) for full pattern
- **VM with instruction pointer binding (2018 Day 19):**
  - Extends basic VM by binding instruction pointer to a register
  - **Execution model:** Write IP to bound register before each instruction, read it back after
  - Allows program to manipulate control flow (jumps, loops) via register operations
  - **Part 2 pattern recognition:** Program may implement known algorithm (e.g., sum of divisors)
  - Run limited iterations to identify target values, then apply mathematical formula
  - Example: If program computes sum of divisors, run ~100 iterations to find target number, then use `divisors(n) |> Enum.sum()`
  - Reuse opcode implementations from Day 16 (16 opcodes: addr, addi, mulr, muli, etc.)
  - See [Interpreter Patterns](toolbox/interpreter_patterns.md) for VM implementation details
- **Regex-based pathfinding (2018 Day 20):**
  - Parse regex-like direction strings with branches: `^N(E|W)S$` means north, then (east OR west), then south
  - **Recursive parsing with position tracking:** Each branch option starts from same positions, ends at potentially different positions
  - Track all possible positions after each segment (list of positions)
  - Branches `(A|B|C)` mean explore all alternatives from current positions
  - Empty branch `(NEWS|)` means can skip those directions (stay at current positions)
  - **Door representation:** Store doors as half-coordinates between rooms: `{(x1+x2)/2, (y1+y2)/2}`
  - After parsing, use BFS from origin to find distances to all rooms
  - Part 2: Count rooms beyond threshold distance
  - See [Parsing Patterns](toolbox/parsing.md) for recursive descent parsing
- **VM program analysis for halt conditions (2018 Day 21):**
  - Problem: Find register 0 value that causes program to halt with fewest/most instructions
  - Program contains equality check between register 0 and another register
  - **Part 1:** Run VM until first time the halt check is reached, return the comparison value
  - **Part 2:** Find last unique value before cycle repeats (longest execution before cycle)
  - **Optimization critical:** Direct implementation of program logic is 1000x faster than VM simulation
  - Reverse-engineer the assembly code to native Elixir for cycle detection
  - Use MapSet to track seen values and detect when cycle begins
  - Pattern: Programs with halt checks often generate sequence of values that eventually cycle
- **Dijkstra with state constraints (2018 Day 22):**
  - Cave system with region types (rocky, wet, narrow) determined by geologic index
  - **Geologic index calculation:** Depends on depth and erosion levels of adjacent cells
  - Compute erosion map row-by-row since each cell depends on left and above neighbors
  - **Part 2 pathfinding:** State is `{position, tool}` not just position
  - Three tools (torch, climbing_gear, neither) with region-specific validity
  - Moving costs 1 minute, switching tools costs 7 minutes
  - Dijkstra with priority queue (Heap library): pop minimum cost state, explore neighbors
  - **Key insight:** Need to extend map beyond target for optimal paths (target + 100 works well)
  - Rocky regions allow climbing_gear or torch; wet allows climbing_gear or neither; narrow allows torch or neither
- **3D optimization with octree search (2018 Day 23):**
  - Problem: Find position in range of most nanobots (3D spheres with Manhattan distance)
  - Part 1 simple: find strongest nanobot, count how many are in its range
  - Part 2 complex: find position in range of most nanobots, tie-break by distance to origin
  - **Octree subdivision approach:** Start with large cube, subdivide into 8 smaller cubes
  - Priority queue: `{-count, distance, region}` - maximize count, minimize distance
  - For each region, count nanobots that can reach it (distance from nanobot to closest point in cube ≤ radius)
  - Subdivide promising regions until reaching single points
  - Use power-of-2 sizes for clean subdivision, center initial cube around origin
  - **Distance to cube:** For each axis, if point outside cube, add distance to nearest edge; otherwise 0
- **Combat simulation with boosts (2018 Day 24):**
  - Two armies with multiple groups: immune system vs infection
  - Each group: units, HP, attack damage/type, initiative, weaknesses, immunities
  - **Combat phases:** Target selection (by effective power, then initiative) → Attack (by initiative)
  - **Damage calculation:** Base = attacker's effective power (units × attack damage), then 2× if weak, 0× if immune
  - **Parsing complexity:** Groups have optional modifiers in parentheses: "(weak to X, Y; immune to Z)"
  - Use regex with capture groups, join multi-line descriptions before parsing
  - Pattern: `~r/(\d+ units each.*?initiative \d+)/` to split concatenated group descriptions
  - **Part 2:** Binary search for minimum boost to immune system that lets them win
  - Boost applies to all immune system groups' attack damage
  - Watch for stalemates: if no units killed in a round, battle is stuck (return draw)
  - **Critical bug:** Check `Enum.all?(final_groups, &(&1.army == :immune))` not just `Enum.any?` - stalemates leave both armies with groups
  - See [Simulation - Combat Systems](toolbox/simulation.md)
- **4D constellation finding (2018 Day 25):**
  - Find connected components in 4D space where points within Manhattan distance 3 are connected
  - Manhattan distance in 4D: `abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2) + abs(w1 - w2)`
  - Build adjacency graph: for each point, find all points within distance 3
  - Count components using DFS/BFS with visited tracking
  - Classic union-find or connected components problem
  - Day 25 typically has no Part 2 - just return "Merry Christmas!"

> **💡 For comprehensive algorithm patterns, see the [Toolbox](toolbox/README.md) - it contains detailed guides for all these patterns and more.**

#### Performance Considerations
- Solutions should complete in < 15 seconds
- **Always consider algorithmic complexity before implementing**
- **For combination problems (C(n,k)):**
  - Small k (≤5): Brute force combinations usually work
  - Large k (≥10): Consider greedy algorithms, dynamic programming, or mathematical optimizations
  - Generating all combinations of C(20,12) = 125,970 is feasible, but C(100,12) = 4.26e12 is not
  - **Partition problems:** Try smallest group sizes first - stop at first valid size
- **Use timeouts when testing potentially slow solutions:**
  ```bash
  timeout 30 mix run -e 'YourModule.solve(input)'
  ```
- **When optimizing with mathematical formulas:**
  - Start with brute force approach that generates all intermediate values
  - Verify brute force matches examples perfectly
  - Then optimize with formula
  - If formula gives wrong answer, compare outputs between brute force and formula to find edge cases
  - Sometimes brute force is fast enough and more reliable than complex formulas
- **State space search with pruning:**
  - Track "best solution so far" and prune paths that can't improve it
  - Use BFS/priority queue to explore state space systematically
  - Return early when impossible state reached
- For BFS/DFS: Consider using `:queue` or `qex` library
- For priority queues: Use `heap` library
- For large grids: Consider using flat maps with `{x, y}` keys
- Use `Stream` for lazy evaluation when appropriate
- Cache/memoize expensive recursive computations
- **Sieve algorithms:** Each number marks its multiples - very efficient for divisor problems
- **Avoid `list ++ list` for growing sequences:**
  - List concatenation is O(n) - extremely slow for large lists
  - Use ETS for efficient random access: O(1) insert/lookup by index
  - Example: 2018 Day 14 timed out with lists, succeeded with ETS
  - See [Elixir Idioms - Performance Tips](toolbox/elixir_idioms.md)
- **Cycle detection for huge iterations:**
  - For exactly repeating states: Use hash map to detect cycle
  - For stable growth patterns: Track 5-10 consecutive identical offsets
  - Don't assume pattern is stable after just 1-2 matches
  - See [Cycle Detection - Offset Pattern](toolbox/cycle_detection.md)

### 5. Running Tests

If `gen_tests?: true` is set, test boilerplate is generated. Run tests with:

```bash
mix test
# Or for specific file:
mix test test/2024/1_test.exs
```

### 6. Manual Input Fetching

If you only need to fetch input without generating code:

```bash
mix aoc.get -y 2024 -d 1
# Disable example fetching:
mix aoc.get --no-example
```

**Note:** The session cookie is required for fetching puzzle inputs and is loaded from the `.env` file via `config/config.exs`. Make sure the `AOC_TOKEN` environment variable is set in `.env`.

### 7. Working with Part 2

**⚠️ CRITICAL:** Part 2 cannot be fetched until Part 1 has been correctly submitted and accepted. The website will not show Part 2 content until you've completed Part 1.

After submitting Part 1, Part 2 becomes available. To fetch Part 2 content:

```bash
# Run the same command again to update puzzle data
mix aoc.get -y 2025 -d 1
```

**Important:** The `mix aoc.get` command won't show Part 2 in its output, but you can fetch the Part 2 description from the website using the session cookie:

```bash
# Fetch Part 2 description using session cookie from .env
source .env && curl -s -H "Cookie: session=$AOC_TOKEN" https://adventofcode.com/2025/day/1 | grep -A 200 "Part Two" | head -100
```

This is useful for agents that need to read the Part 2 puzzle description programmatically.

## Problem-Solving Strategy

1. **Read carefully**: Understand the problem completely before coding
2. **Start with examples**: Verify solution works with provided examples
3. **Test edge cases**: Build test cases you can verify by hand
4. **Incremental development**: 
   - Parse input first
   - Solve part 1
   - Test with examples
   - Submit part 1
   - Fetch Part 2 (use curl with session cookie if needed)
   - Adapt for part 2
5. **Debug systematically**:
   - Use `IO.inspect/2` with labels
   - Test with smaller inputs
   - Verify intermediate results
   - Trace through examples manually to validate logic
   - **When formulas don't match examples, implement brute force to verify correctness**
   - Compare optimized vs brute force approaches on small inputs to find discrepancies
6. **Refactor after solving**: Clean up code once both parts work
7. **⚠️ IMPORTANT - Answer Formatting**: When displaying answers for submission, **NEVER use thousand separators** (commas, spaces, etc.) in numbers. Always output plain integers like `14110788`, not `14,110,788`. The AoC submission form only accepts raw numbers.

### Part 2 Considerations
- Part 2 often builds on Part 1 but with a twist
- Common patterns:
  - Same problem but count something different
  - Same problem but with larger constraints requiring optimization
  - Same problem but with additional rules or conditions
- Always test Part 2 with the example before running on actual input
- Part 2 may require rethinking the algorithm entirely (not just tweaking Part 1)

## Common Elixir Idioms for AoC

### Parsing
```elixir
# Regex matching
~r/(\d+)/
|> Regex.scan(input)
|> List.flatten()
|> Enum.map(&String.to_integer/1)

# Pattern matching
[a, b, c] = String.split(line)
```

### Data Structures
```elixir
# Maps for grids
grid = %{{0, 0} => "#", {1, 0} => "."}

# MapSet for unique collections
visited = MapSet.new()

# List as stack
[head | rest] = list

# :queue for BFS
queue = :queue.from_list([start])
{{:value, item}, queue} = :queue.out(queue)
queue = :queue.in(next_item, queue)
```

### Algorithms
```elixir
# BFS template
defp bfs(queue, visited, goal) do
  case :queue.out(queue) do
    {{:value, current}, queue} ->
      if current == goal do
        # Found solution
      else
        neighbors = get_neighbors(current)
        new_items = neighbors |> Enum.reject(&MapSet.member?(visited, &1))
        new_queue = Enum.reduce(new_items, queue, &:queue.in/2)
        new_visited = Enum.reduce(new_items, visited, &MapSet.put(&2, &1))
        bfs(new_queue, new_visited, goal)
      end
    {:empty, _} -> nil
  end
end

# BFS backward (from target) for pathfinding - useful when you need to find
# the best first step toward a target from a starting position
defp bfs_from_target(grid, units, target) do
  queue = :queue.from_list([{target, 0}])
  distances = %{target => 0}
  
  bfs_distances(queue, distances, grid, units)
end

defp bfs_distances(queue, distances, grid, units) do
  case :queue.out(queue) do
    {:empty, _} -> distances
    {{:value, {pos, dist}}, new_queue} ->
      adjacent = get_adjacent(pos)
      {updated_queue, updated_distances} =
        adjacent
        |> Enum.filter(&is_open?(grid, units, &1))
        |> Enum.reject(&Map.has_key?(distances, &1))
        |> Enum.reduce({new_queue, distances}, fn p, {q, d} ->
          {:queue.in({p, dist + 1}, q), Map.put(d, p, dist + 1)}
        end)
      
      bfs_distances(updated_queue, updated_distances, grid, units)
  end
end

# DFS template
defp dfs(current, visited, goal) do
  if current == goal do
    # Found solution
  else
    current
    |> get_neighbors()
    |> Enum.reject(&MapSet.member?(visited, &1))
    |> Enum.find_value(fn neighbor ->
      dfs(neighbor, MapSet.put(visited, neighbor), goal)
    end)
  end
end

# Iterative state modification until convergence
defp iterate_until_stable(state, count) do
  # Find items matching some condition
  items = find_removable_items(state)
  
  if Enum.empty?(items) do
    count
  else
    # Modify state by removing/changing items
    new_state = Enum.reduce(items, state, &modify_state/2)
    iterate_until_stable(new_state, count + length(items))
  end
end

# 8-neighbor adjacency check (for grids)
defp get_8_neighbors({x, y}) do
  [
    {x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1},
    {x - 1, y},                 {x + 1, y},
    {x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}
  ]
end
```

## Troubleshooting

### Compilation Issues
```bash
# Clean build
mix clean
mix compile

# Check for syntax errors
mix compile --force --warnings-as-errors
```

### Erlang/OTP Version Compatibility Issues
If you see errors like "please re-compile this module with an Erlang/OTP 28 compiler":
```bash
# Clean all dependencies and recompile with current Erlang/OTP version
mix deps.clean --all
mix deps.get
mix deps.compile

# Then clean and recompile your project
mix clean
mix compile
```

This happens when dependencies were compiled with a different Erlang/OTP version than the one currently active.

**For Hex-specific errors** (like "The module Hex.State was given as a child to a supervisor but it does not exist"):
```bash
# Reinstall Hex archive for current Erlang/OTP version
mix local.hex --force
```

This fixes Hex compatibility issues with the current Erlang/OTP version, which can affect tools like Credo in VS Code.

### Dependency Compatibility Issues

**type_check incompatibility with Elixir 1.19+:**

The `type_check` library (transitive dependency from `arrays`) has compatibility issues with Elixir 1.19. If you encounter errors like:

```
** (Kernel.TypespecError) undefined field :re_version on struct Regex
```

Workaround: Temporarily disable the `arrays` dependency in `mix.exs`:

```elixir
defp deps do
  [
    # {:arrays, "~> 2.1.1"}, # Temporarily disabled due to type_check incompatibility
    # ... other deps
  ]
end
```

Then run:
```bash
mix deps.get
mix compile
```

**Note:** Solutions that don't use Arrays will still work. For solutions requiring array functionality, consider alternative data structures or wait for library updates.

### Input Issues
- Ensure session cookie is set in `config/config.exs`
- Input files are cached; delete and re-run `mix aoc.get` to re-download
- Check that input doesn't have trailing newline issues

### Performance Issues
- Profile with `:timer.tc/1` or `:eprof`
- Consider algorithmic improvements before micro-optimizations
- Use tail recursion for large iterations
- Consider parallel processing with `Task.async_stream/3` if appropriate

### Running Solutions from Command Line
To run a solution programmatically (useful for testing):
```bash
# Correct way to run a solution
mix run -e 'input = File.read!("input/2025_1.txt"); result = Y2025.D1.p1(input); IO.puts("Answer: #{result}")'

# Run example input
mix run -e 'input = File.read!("input/2025_1_example_0.txt"); result = Y2025.D1.p1(input); IO.puts("Answer: #{result}")'

# Run tests
mix test test/2025/1_test.exs
```

Note: Remember the module naming convention - use `Y2025.D1`, not `AOC.Y2025.D1`.

## Resources

- **Advent of Code**: https://adventofcode.com
- **advent_of_code_utils docs**: https://hexdocs.pm/advent_of_code_utils/
- **Cheatsheet**: https://hexdocs.pm/advent_of_code_utils/cheatsheet.html
- **Elixir docs**: https://hexdocs.pm/elixir/
- **Subreddit**: https://www.reddit.com/r/adventofcode/

## Best Practices

1. **Keep solutions in version control** but don't commit input files (add `input/` to `.gitignore`)
2. **Document complex logic** with comments or moduledocs
3. **Extract helper functions** for clarity and reusability
4. **Write tests** for edge cases and examples
5. **Focus on correctness first**, optimize only if needed
6. **Learn from others** after solving (check solution threads on Reddit)
7. **Don't use AI to solve puzzles** - this defeats the purpose of the learning exercise

## Configuration Reference

Example `config/config.exs`:

```elixir
import Config

config :advent_of_code_utils,
  session: "your_session_cookie_here",
  auto_compile?: true,
  time_calls?: true,
  gen_tests?: true,
  time_zone: :aoc,
  fetch_example?: true

config :iex,
  inspect: [charlists: :as_lists]
```

**Session Cookie Setup:**
The session cookie is loaded from `.env` file. Create a `.env` file in the project root with:
```
AOC_TOKEN=your_session_cookie_here
```

To get your session cookie:
1. Log in to https://adventofcode.com
2. Open browser developer tools (F12)
3. Go to Application/Storage → Cookies → https://adventofcode.com
4. Copy the value of the `session` cookie
5. Add it to your `.env` file

## Quick Command Reference

```bash
# Start new day
mix aoc

# Start IEx
iex -S mix

# Run tests
mix test

# Run multiple days at once (universal script)
mix run run_days.exs                  # Defaults to 2015 days 1-25
mix run run_days.exs 2017 1 5         # Run 2017 days 1-5
mix run run_days.exs 2024 1 25        # Run all of 2024
# Note: Script automatically handles day 25 (single part) - shows ⭐ for part 2

# Fetch input only
mix aoc.get

# Fetch Part 2 description (after submitting Part 1)
source .env && curl -s -H "Cookie: session=$AOC_TOKEN" https://adventofcode.com/2025/day/1 | grep -A 200 "Part Two" | head -100

# Update mise
mise self-update -y

# Install dependencies
mix deps.get

# Compile project
mix compile

# Clean and recompile everything (useful after Erlang/OTP version changes)
mix deps.clean --all && mix deps.get && mix deps.compile && mix clean && mix compile
```
