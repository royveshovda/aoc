# Elixir Idioms & Patterns for AoC

## Overview
Common Elixir patterns that appear frequently in AoC solutions.

## Enum Patterns

### Frequencies (2024 Day 1, many others)
```elixir
# Count occurrences
list |> Enum.frequencies()
# => %{1 => 3, 2 => 1, 3 => 2}

# Use with scoring
numbers
|> Enum.frequencies()
|> Enum.map(fn {num, count} -> num * count end)
|> Enum.sum()
```

### Chunk Every
```elixir
# Sliding window
[1, 2, 3, 4, 5]
|> Enum.chunk_every(2, 1, :discard)
# => [[1, 2], [2, 3], [3, 4], [4, 5]]

# Non-overlapping chunks
[1, 2, 3, 4, 5, 6]
|> Enum.chunk_every(2)
# => [[1, 2], [3, 4], [5, 6]]

# Pairwise differences (2024 Day 2)
numbers
|> Enum.chunk_every(2, 1, :discard)
|> Enum.map(fn [a, b] -> b - a end)
```

### Zip and Unzip (2024 Day 1)
```elixir
# Separate two columns
[[1, 2], [3, 4], [5, 6]]
|> Enum.zip()
|> Enum.map(&Tuple.to_list/1)
# => [[1, 3, 5], [2, 4, 6]]

# Transpose manually
[list1, list2]
|> Enum.zip()
|> Enum.map(&Tuple.to_list/1)
```

### Scan (Accumulating Results)
```elixir
# Running sum
[1, 2, 3, 4]
|> Enum.scan(&+/2)
# => [1, 3, 6, 10]

# Rope physics (2022 Day 9)
segments
|> Enum.scan(head, fn segment, prev ->
  follow(segment, prev)
end)
```

### Find Value (Early Exit)
```elixir
# Find first truthy result
collection
|> Enum.find_value(fn item ->
  if condition?(item), do: compute(item), else: nil
end)

# With default
collection
|> Enum.find_value(:default, fn item ->
  if condition?(item), do: compute(item)
end)
```

### Group By
```elixir
# Group items by key
items
|> Enum.group_by(&key_function/1)

# Group with value transformation
items
|> Enum.group_by(&key_function/1, &value_function/1)
```

### Reduce While (Early Termination)
```elixir
numbers
|> Enum.reduce_while(initial, fn num, acc ->
  if condition?(num, acc) do
    {:halt, acc}  # Stop early
  else
    {:cont, new_acc}  # Continue
  end
end)
```

## Pipeline Patterns

### then/2 for Custom Logic
```elixir
# When you need complex intermediate step
data
|> parse()
|> then(fn parsed ->
  if complex_condition?(parsed) do
    transform_a(parsed)
  else
    transform_b(parsed)
  end
end)
|> finalize()
```

### tap/2 for Side Effects (Debugging)
```elixir
data
|> transform()
|> tap(&IO.inspect(&1, label: "After transform"))
|> process()
```

## Pattern Matching

### Function Heads
```elixir
def process([]), do: []
def process([head | tail]), do: [transform(head) | process(tail)]

def solve(:easy, input), do: easy_solution(input)
def solve(:hard, input), do: hard_solution(input)
```

### Case Statements
```elixir
case result do
  {:ok, value} -> process(value)
  {:error, reason} -> handle_error(reason)
  _ -> default_action()
end
```

### With Expressions (Error Handling)
```elixir
with {:ok, data} <- fetch_data(id),
     {:ok, parsed} <- parse(data),
     {:ok, validated} <- validate(parsed) do
  process(validated)
else
  {:error, reason} -> handle_error(reason)
end
```

## Map Patterns

### Update with Default
```elixir
# Increment counter
map |> Map.update(key, 1, &(&1 + 1))

# Add to list
map |> Map.update(key, [value], &[value | &1])
```

### Get with Default
```elixir
Map.get(map, key, default_value)

# Or using pattern matching
%{^key => value} = map
```

### Merge for Updates
```elixir
# Update multiple keys
base_map
|> Map.merge(%{key1: value1, key2: value2})
```

### put_new vs put
```elixir
# Only set if not exists
Map.put_new(map, key, value)

# Always set
Map.put(map, key, value)
```

## List Patterns

### Comprehensions
```elixir
# Basic
for x <- 1..10, do: x * x

# With filter
for x <- 1..10, rem(x, 2) == 0, do: x

# Multiple generators (Cartesian product)
for x <- 1..3, y <- 1..3, do: {x, y}

# With pattern matching
for {key, value} <- map, value > 10, do: key
```

### List Operations
```elixir
# Flatten
[[1, 2], [3, 4]] |> List.flatten()

# Delete element
list |> List.delete(item)
list |> List.delete_at(index)

# Replace
list |> List.replace_at(index, new_value)
```

## MapSet Patterns

```elixir
# Create
MapSet.new([1, 2, 3])

# Operations
MapSet.union(set1, set2)
MapSet.intersection(set1, set2)
MapSet.difference(set1, set2)

# Membership
MapSet.member?(set, item)

# Add/remove
MapSet.put(set, item)
MapSet.delete(set, item)
```

## Stream Patterns

### Infinite Sequences
```elixir
# Cycle (2018 Day 1)
values
|> Stream.cycle()
|> Enum.reduce_while({0, seen}, fn val, {sum, seen} ->
  # Process until condition met
end)

# Iterate
Stream.iterate(initial, &next_function/1)
|> Enum.take(n)

# Unfold
Stream.unfold(initial, fn state ->
  if continue?(state) do
    {element, next_state}
  else
    nil
  end
end)
```

### Lazy Evaluation
```elixir
# Process large files efficiently
File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.filter(&valid?/1)
|> Enum.to_list()
```

## Range Patterns

```elixir
# Basic range
1..10

# Step (Elixir 1.12+)
1..10//2  # [1, 3, 5, 7, 9]

# Reverse
10..1

# Check membership
5 in 1..10  # true

# Enum over range
Enum.map(1..10, &(&1 * 2))
```

## String Patterns

```elixir
# Graphemes (individual characters)
"hello" |> String.graphemes()  # ["h", "e", "l", "l", "o"]

# Pattern matching
<<first::binary-size(1), rest::binary>> = "hello"
# first = "h", rest = "ello"

# Slicing
String.slice("hello", 0, 2)  # "he"

# Replace
String.replace("hello", "l", "L")
```

## Process Dictionary (Memoization Cache)

```elixir
# Initialize
Process.put(:cache, %{})

# Get/update
cache = Process.get(:cache)
Process.put(:cache, Map.put(cache, key, value))

# Cleanup
Process.delete(:cache)
```

## For Reduce Pattern

```elixir
# Powerful loop with accumulator
for item <- collection, reduce: initial_acc do
  acc ->
    new_acc = process(item, acc)
    new_acc
end
```

## Recursive Patterns

### Tail Recursion
```elixir
def sum(list), do: sum(list, 0)

defp sum([], acc), do: acc
defp sum([head | tail], acc), do: sum(tail, acc + head)
```

### Accumulator Pattern
```elixir
def reverse(list), do: reverse(list, [])

defp reverse([], acc), do: acc
defp reverse([head | tail], acc), do: reverse(tail, [head | acc])
```

## Guard Clauses

```elixir
def factorial(n) when n < 0, do: {:error, "negative number"}
def factorial(0), do: 1
def factorial(n) when n > 0, do: n * factorial(n - 1)

# Multiple guards
def process(x) when is_integer(x) and x > 0, do: :positive
def process(x) when is_integer(x) and x < 0, do: :negative
def process(0), do: :zero
```

## Keyword Lists vs Maps

```elixir
# Keyword list (when order matters or duplicate keys)
opts = [name: "Alice", age: 30, name: "Bob"]

# Map (unique keys, fast lookup)
data = %{name: "Alice", age: 30}
```

## Key Points
- **Pipeline Everything**: Makes code readable
- **Pattern Match Liberally**: Catches errors early
- **Use MapSet for Sets**: Much faster than list membership
- **Enum vs Stream**: Enum for small collections, Stream for large/infinite
- **Reduce is Powerful**: Can replace many loops
- **Immutability**: Everything returns new value, original unchanged
- **Tail Recursion**: For deep recursion, use accumulator pattern

## Performance Tips
- `MapSet.member?` is O(log n), much faster than `item in list` which is O(n)
- `Map` lookups are O(log n), very efficient
- Use `Stream` for large datasets to avoid building intermediate lists
- Pattern matching is often faster than conditionals
- `Enum.chunk_every` with `:discard` avoids keeping extra data
