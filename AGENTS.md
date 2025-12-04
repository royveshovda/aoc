# Advent of Code - Agent Instructions

## Project Overview

This is an Advent of Code workspace using Elixir with the `advent_of_code_utils` library for input fetching and boilerplate generation. The project uses `mise` for managing Elixir and Erlang versions.

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
├── config/
│   └── config.exs      # Configuration including AoC session cookie
└── mix.exs             # Project dependencies
```

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
- Module definition
- Input parsing
- Integration with IEx helpers

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

#### Performance Considerations
- Solutions should complete in < 15 seconds
- For BFS/DFS: Consider using `:queue` or `qex` library
- For priority queues: Use `heap` library
- For large grids: Consider using flat maps with `{x, y}` keys
- Use `Stream` for lazy evaluation when appropriate
- Cache/memoize expensive recursive computations

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

## Problem-Solving Strategy

1. **Read carefully**: Understand the problem completely before coding
2. **Start with examples**: Verify solution works with provided examples
3. **Test edge cases**: Build test cases you can verify by hand
4. **Incremental development**: 
   - Parse input first
   - Solve part 1
   - Test with examples
   - Submit part 1
   - Adapt for part 2
5. **Debug systematically**:
   - Use `IO.inspect/2` with labels
   - Test with smaller inputs
   - Verify intermediate results
6. **Refactor after solving**: Clean up code once both parts work

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

### Input Issues
- Ensure session cookie is set in `config/config.exs`
- Input files are cached; delete and re-run `mix aoc.get` to re-download
- Check that input doesn't have trailing newline issues

### Performance Issues
- Profile with `:timer.tc/1` or `:eprof`
- Consider algorithmic improvements before micro-optimizations
- Use tail recursion for large iterations
- Consider parallel processing with `Task.async_stream/3` if appropriate

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

## Quick Command Reference

```bash
# Start new day
mix aoc

# Start IEx
iex -S mix

# Run tests
mix test

# Fetch input only
mix aoc.get

# Update mise
mise self-update -y

# Install dependencies
mix deps.get

# Compile project
mix compile
```
