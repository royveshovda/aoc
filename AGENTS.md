# Advent of Code - Agent Instructions

## Project Overview

Elixir AoC workspace using `advent_of_code_utils` for input fetching/boilerplate. Uses `mise` for version management.

## Solution Requirements

For each day solved:
1. **Implement examples as doctests** in solution file
2. **Verify with tests**: `mix test test/YYYY/DD_test.exs`
3. **Document learnings**: Save patterns to `toolbox/` folder

## Project Structure

```
aoc/
├── lib/YYYY/DD.ex      # Solutions by year
├── input/YYYY_DD.txt   # Puzzle inputs
├── test/YYYY/          # Tests
├── toolbox/            # Algorithm reference library
└── config/config.exs   # Session cookie config
```

## Algorithm Toolbox

**📚 See [toolbox/README.md](toolbox/README.md)** for comprehensive algorithms.

Quick guide:
- **Shortest path** → BFS (unweighted) or Dijkstra (weighted)
- **Count ways** → Dynamic Programming
- **Large iterations** → Cycle Detection or Math
- **Grid problems** → Grid Operations + BFS/DFS
- **Assembly/VM** → [Interpreter Patterns](toolbox/interpreter_patterns.md)
- **Modular arithmetic** → [Number Theory](toolbox/number_theory.md) (linear functions, modular inverse)
- **Day-specific gotchas** → [Day Patterns](toolbox/day_specific_patterns.md)

## Quick Start

```bash
# Generate boilerplate for today
mix aoc
# Or specific day
mix aoc -y 2024 -d 1

# Test in IEx
iex -S mix
p1e(2024, 1)  # Part 1 with example
p1i(2024, 1)  # Part 1 with input

# Run tests
mix test test/2024/1_test.exs

# Run solution from CLI
mix run -e 'input = File.read!("input/2024_1.txt"); IO.puts(Y2024.D1.p1(input))'
```

## Module Naming

`aoc YYYY, DD` creates module `YYYYY.DDD`:
- `aoc 2025, 1` → `Y2025.D1`
- Use `Y2025.D1.p1(input)`, NOT `AOC.Y2025.D1.p1(input)`

## Input Parsing Patterns

```elixir
# Lines
input |> String.split("\n", trim: true)

# Integers
input |> String.split("\n", trim: true) |> Enum.map(&String.to_integer/1)

# Grid to map
input |> String.split("\n", trim: true)
|> Enum.with_index()
|> Enum.flat_map(fn {row, y} ->
  row |> String.graphemes() |> Enum.with_index()
  |> Enum.map(fn {c, x} -> {{x, y}, c} end)
end) |> Map.new()

# Regex extract
~r/(\d+)/ |> Regex.scan(input) |> List.flatten() |> Enum.map(&String.to_integer/1)
```

## Key Elixir Idioms

```elixir
# BFS with :queue
queue = :queue.from_list([start])
{{:value, item}, queue} = :queue.out(queue)
queue = :queue.in(next, queue)

# Priority queue with Heap
heap = Heap.new(fn {a,_}, {b,_} -> a < b end) |> Heap.push({0, start})
{min, heap} = {Heap.root(heap), Heap.pop(heap)}

# Frequencies, zip, chunk
Enum.frequencies(list)
Enum.zip(list1, list2)
Enum.chunk_every(list, n)
```

## Performance Tips

- Solutions should complete in < 15 seconds
- Use `Heap` for priority queues, `:queue` for BFS
- Maps with `{x,y}` keys for grids
- **Avoid `list ++ list`** - use ETS for O(1) access
- **Cycle detection** for huge iterations
- **Memoize** expensive recursive computations

```bash
# Timeout for slow solutions
timeout 30 mix run -e 'YourModule.solve(input)'
```

## Part 2 Notes

- **Cannot fetch Part 2 until Part 1 submitted**
- Fetch description: `source .env && curl -s -H "Cookie: session=$AOC_TOKEN" https://adventofcode.com/YYYY/day/D | grep -A 200 "Part Two" | head -100`
- Common patterns: larger scale, count differently, additional rules

## Troubleshooting

```bash
# Clean rebuild
mix clean && mix compile

# Erlang version issues
mix deps.clean --all && mix deps.get && mix deps.compile && mix clean && mix compile

# Hex issues
mix local.hex --force
```

## Quick Commands

```bash
mix aoc                    # New day
mix aoc -y 2024 -d 1       # Specific day
iex -S mix                 # Interactive
mix test                   # All tests
mix run run_days.exs 2019 1 25  # Run year
```

## Resources

- [advent_of_code_utils](https://hexdocs.pm/advent_of_code_utils/)
- [Elixir docs](https://hexdocs.pm/elixir/)
- [r/adventofcode](https://www.reddit.com/r/adventofcode/)
