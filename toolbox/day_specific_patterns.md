# Day-Specific Patterns & Gotchas

Quick reference for patterns learned from specific AoC days. Organized by year.

## 2025

- **Columnar parsing (Day 6)**: Problems arranged vertically, separated by space columns. Transpose rows→columns, group by all-space separators. Part 2 twist: each column = digit, read numbers top-to-bottom, problems read right-to-left
- **Beam splitting (Day 7)**: Part 1 uses `MapSet` for positions (beams merge), Part 2 uses `Map` with counts (timelines are independent). Each splitter doubles timeline count = exponential growth
- **Linear Systems (Day 10)**: Gaussian Elimination for systems of equations. Part 1: GF(2) (XOR). Part 2: Rational numbers + ILP search over free variables for underdetermined systems.
- **Path counting (Day 11)**: Directed graph; parse `node: neighbors...`. Count distinct paths start→target with DFS + memoization; guard against cycles. For “must visit X/Y” constraints, add bitmask state to memo (e.g., 2 bits for required nodes).

## 2016

- **Keypad/Grid navigation**: Use `Map.has_key?(grid, new_pos)` for boundary checking on irregular grids

## 2017

- **Hexagonal grids (Day 11)**: Cube coords `{x,y,z}` where `x+y+z=0`, distance = `(|x|+|y|+|z|)/2`
- **Concurrent programs (Day 18)**: Run until blocked, exchange messages, deadlock = both blocked with empty queues
- **Circular buffer (Day 17)**: Track only target position, not full buffer. O(n) vs O(n²)
- **Particle simulations (Day 20)**: Long-term = acceleration dominates. Group by position for collisions
- **Pattern matching with transforms (Day 21)**: Pre-generate all 8 orientations during parsing
- **Component building (Day 24)**: DFS with backtracking, track used components

## 2018

- **Grid power/sums (Day 11)**: Summed area table for O(1) rectangle queries
- **Turn-based collision (Day 13)**: Sort by position each tick, check collisions during processing
- **Combat simulation (Day 15)**: Remove self from map during BFS! Reading order tiebreaks. BFS backward from target
- **Reverse-engineering opcodes (Day 16)**: Constraint sets + iterative satisfaction
- **Water flow (Day 17)**: Recursive flood-fill. **Water rises** - check row above when settling
- **Cellular automaton (Day 18)**: Cycle detection for huge iterations
- **VM with IP binding (Day 19)**: Reverse-engineer for Part 2 (e.g., sum of divisors)
- **Regex pathfinding (Day 20)**: Track all positions, branches split/merge
- **VM halt analysis (Day 21)**: Find comparison value, cycle detection for Part 2
- **Dijkstra with tools (Day 22)**: State = `{pos, tool}`, extend map beyond target
- **3D octree search (Day 23)**: Subdivide cubes, priority by count then distance
- **Combat with boosts (Day 24)**: Binary search boost. Watch for stalemates
- **4D constellations (Day 25)**: Connected components, Manhattan distance ≤ 3

## 2019

- **Intcode VM**: Map for memory, modes (0=pos, 1=imm, 2=rel), suspendable for I/O
- **Line of sight (Day 10)**: Normalize with GCD, `atan2(dx, -dy)` for clockwise angle
- **N-Body cycle (Day 12)**: Axes independent → LCM of individual cycles
- **Chemical reactions (Day 14)**: Work backwards, track surplus. Binary search for Part 2
- **Maze exploration (Day 15)**: DFS with backtracking, build map before pathfinding
- **FFT (Day 16)**: Part 2: offset in second half → cumulative sum from end
- **ASCII Intcode (Day 17)**: Path compression into A/B/C (max 20 chars). `mem[0]=2` to wake
- **Multi-robot keys (Day 18)**: Pre-compute distances, track required doors. State = `{positions, keys}`
- **Tractor beam (Day 19)**: Grid is monotonic - binary search in rows/cols. Part 2: track left edge
- **Recursive maze (Day 20)**: Portals have inner/outer variants. Part 2: depth as state dimension
- **Springdroid (Day 21)**: Boolean logic for jumping. Walk=4 tiles, Run=9 tiles lookahead
- **Card shuffle (Day 22)**: Linear functions under modular arithmetic. `f(x)=ax+b mod N`. Compose & invert with modular exponentiation
- **Network simulation (Day 23)**: 50 Intcode VMs. Non-blocking input returns -1. NAT monitors address 255
- **Recursive Game of Life (Day 24)**: Center tile is portal. Edge neighbors connect to outer level
- **Text adventure (Day 25)**: DFS exploration, collect safe items, try all 2^n combinations at checkpoint

## 2020

- **Bag containment rules (Day 7)**: Parse → graph. Reverse graph for "which can contain X", recursive count for "how many inside X"
- **Adapter chain DP (Day 10)**: Sort adapters, `ways[j] = sum(ways[i])` for valid predecessors
- **Seating cellular automaton (Day 11)**: Part 1=adjacent, Part 2=line-of-sight (skip floor until seat)
- **Bus schedule CRT (Day 13)**: Sieving approach - find t satisfying constraints one at a time, multiply step by modulus
- **Bitmask with floating bits (Day 14)**: Part 2 expands X→{0,1}, generates 2^n addresses
- **Grammar matching with recursion (Day 19)**: Parser returns all possible remainders. Handles ambiguous/recursive rules
- **Image tile assembly (Day 20)**: Match edges (8 orientations). Corners have 2 unmatched edges. Assemble by constraint propagation
- **Recursive card game (Day 22)**: Track seen states to prevent infinite loops. Sub-games use deck copies
- **Circular linked list with :array (Day 23)**: `array[cup] = next_cup` for O(1) operations. Critical for 10M moves
- **Hex grid with axial coords (Day 24)**: `{q, r}` coords, 6 directions. Game of Life on hex grid

## General Gotchas

- **Modular arithmetic**: Edge cases at 0 and max position
- **TSP variants**: Distance matrix + permutations for small sets
- **String replacement**: Generate all single replacements, deduplicate with MapSet
- **ETS for performance**: O(1) random access, always cleanup in `try/after`
- **Assembly interpreters**: Detect multiplication loops, replace with direct calculation
- **Self-modifying code**: Store instructions in mutable map
- **Parser with backtracking**: Return list of remainders, not single result. Check if any path consumes all input

```

## General Gotchas

- **Modular arithmetic**: Edge cases at 0 and max position
- **TSP variants**: Distance matrix + permutations for small sets
- **String replacement**: Generate all single replacements, deduplicate with MapSet
- **ETS for performance**: O(1) random access, always cleanup in `try/after`
- **Assembly interpreters**: Detect multiplication loops, replace with direct calculation
- **Self-modifying code**: Store instructions in mutable map
