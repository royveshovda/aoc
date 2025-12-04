# Dynamic Programming & Memoization

## Overview
Dynamic Programming (DP) solves complex problems by breaking them down into simpler subproblems and storing their solutions to avoid redundant computation.

## When to Use
- Overlapping subproblems
- Optimal substructure
- Counting number of ways to achieve something
- Optimization problems (min/max)
- Sequence problems

## Used In
- 2024 Day 11 (Plutonian Pebbles - exponential growth with memoization)
- 2023 Day 19 (Pattern counting - ways to construct strings)
- 2023 Day 12 (Spring records - constraint satisfaction counting)
- 2022 Day 19 (Robot building - resource optimization with pruning)

## Memoization with `use Memoize`

```elixir
# Add to mix.exs: {:memoize, "~> 1.4"}
use Memoize

defmemo fibonacci(0), do: 0
defmemo fibonacci(1), do: 1
defmemo fibonacci(n) when n > 1 do
  fibonacci(n - 1) + fibonacci(n - 2)
end
```

## Bottom-Up DP with Map (2023 Day 19)

```elixir
def count_ways(pattern, available_pieces) do
  len = String.length(pattern)
  
  # dp[i] = number of ways to construct pattern[0..i-1]
  dp = %{0 => 1}  # Empty string has 1 way
  
  dp = Enum.reduce(1..len, dp, fn pos, dp_acc ->
    total = Enum.reduce(available_pieces, 0, fn piece, acc ->
      piece_len = String.length(piece)
      
      if pos >= piece_len and String.slice(pattern, pos - piece_len, piece_len) == piece do
        acc + Map.get(dp_acc, pos - piece_len, 0)
      else
        acc
      end
    end)
    
    Map.put(dp_acc, pos, total)
  end)
  
  Map.get(dp, len, 0)
end
```

## Memoization with Process Dictionary (2023 Day 12)

```elixir
def solve_with_cache(pattern, groups) do
  # Initialize cache in process dictionary
  Process.put(:cache, %{})
  result = solve(pattern, groups)
  Process.delete(:cache)
  result
end

defp solve(pattern, groups) do
  key = {pattern, groups}
  cache = Process.get(:cache)
  
  case Map.get(cache, key) do
    nil ->
      result = do_solve(pattern, groups)
      Process.put(:cache, Map.put(cache, key, result))
      result
    
    cached -> cached
  end
end

defp do_solve("", []), do: 1
defp do_solve("", _), do: 0
defp do_solve(pattern, []) do
  if String.contains?(pattern, "#"), do: 0, else: 1
end

defp do_solve("." <> rest, groups), do: solve(rest, groups)

defp do_solve("#" <> _rest, [group | remaining_groups] = groups) do
  len = String.length(pattern)
  
  if len >= group and 
     not String.contains?(String.slice(pattern, 0, group), ".") and
     (len == group or String.at(pattern, group) != "#") do
    
    next_pattern = String.slice(pattern, min(group + 1, len), len)
    solve(next_pattern, remaining_groups)
  else
    0
  end
end

defp do_solve("?" <> rest, groups) do
  # Try both '.' and '#'
  solve("." <> rest, groups) + solve("#" <> rest, groups)
end
```

## Memoization with Explicit Cache Threading (2024 Day 21)

```elixir
def solve(code, depth, cache \\ %{}) do
  key = {code, depth}
  
  case Map.get(cache, key) do
    nil ->
      {result, new_cache} = compute_result(code, depth, cache)
      {result, Map.put(new_cache, key, result)}
    
    cached ->
      {cached, cache}
  end
end

defp compute_result(code, 0, cache), do: {String.length(code), cache}

defp compute_result(code, depth, cache) do
  code
  |> String.graphemes()
  |> Enum.chunk_every(2, 1, [""])
  |> Enum.reduce({0, cache}, fn [prev, curr], {total, cache_acc} ->
    {sub_result, new_cache} = solve(get_moves(prev, curr), depth - 1, cache_acc)
    {total + sub_result, new_cache}
  end)
end
```

## Top-Down DP with Memoize (2024 Day 11)

```elixir
use Memoize

def count_stones(stones, blinks) do
  stones
  |> Enum.map(&count_single_stone(&1, blinks))
  |> Enum.sum()
end

defmemo count_single_stone(_stone, 0), do: 1

defmemo count_single_stone(0, n) do
  count_single_stone(1, n - 1)
end

defmemo count_single_stone(stone, n) do
  digits = Integer.to_string(stone)
  len = String.length(digits)
  
  if rem(len, 2) == 0 do
    half = div(len, 2)
    left = String.slice(digits, 0, half) |> String.to_integer()
    right = String.slice(digits, half, half) |> String.to_integer()
    
    count_single_stone(left, n - 1) + count_single_stone(right, n - 1)
  else
    count_single_stone(stone * 2024, n - 1)
  end
end
```

## ETS for Persistent Cache (2022 Day 17, 19)

```elixir
def solve_with_ets(input) do
  # Create ETS table
  :ets.new(:dp_cache, [:set, :public, :named_table])
  
  result = solve_recursive(input, 0)
  
  # Clean up
  :ets.delete(:dp_cache)
  
  result
end

defp solve_recursive(state, step) do
  case :ets.lookup(:dp_cache, {state, step}) do
    [{_, cached_result}] ->
      cached_result
    
    [] ->
      result = compute_result(state, step)
      :ets.insert(:dp_cache, {{state, step}, result})
      result
  end
end
```

## Interval DP (2023 Day 5)

```elixir
def transform_ranges(ranges, mapping) do
  Enum.flat_map(ranges, fn {start, length} ->
    transform_single_range({start, length}, mapping, [])
  end)
end

defp transform_single_range({start, len}, [], acc), do: [{start, len} | acc]

defp transform_single_range({start, len}, [map | rest], acc) do
  {src, dest, map_len} = map
  
  cond do
    # Range completely before mapping
    start + len <= src ->
      transform_single_range({start, len}, rest, acc)
    
    # Range completely after mapping
    start >= src + map_len ->
      transform_single_range({start, len}, rest, acc)
    
    # Range overlaps mapping
    start < src ->
      # Split range: before and overlapping parts
      before_len = src - start
      transform_single_range({start, before_len}, rest, acc)
      transform_single_range({src, len - before_len}, [map | rest], acc)
    
    true ->
      # Range starts in mapping
      overlap_len = min(len, src + map_len - start)
      new_start = dest + (start - src)
      
      remaining = len - overlap_len
      if remaining > 0 do
        transform_single_range({start + overlap_len, remaining}, rest, [{new_start, overlap_len} | acc])
      else
        [{new_start, overlap_len} | acc]
      end
  end
end
```

## Key Points
- **Identify Subproblems**: What smaller problems can you solve?
- **Recurrence Relation**: How do subproblems relate?
- **Base Cases**: What are the simplest cases?
- **Memoization vs Tabulation**:
  - Top-down (memoization): Recursive with caching
  - Bottom-up (tabulation): Iterative, build solution from base cases
- **Cache Key**: Must uniquely identify subproblem state
- **Space Optimization**: Sometimes can reduce space by only keeping last few states

## Choosing Memoization Strategy
- **`use Memoize`**: Simplest, clean syntax, good for pure functions
- **Process Dictionary**: Quick and dirty, single process only
- **Explicit Cache Parameter**: More control, can inspect cache
- **ETS**: Shared across processes, persistent cache

## Common DP Patterns
- **Counting paths**: Number of ways to reach state
- **Min/max cost**: Optimal value achievable
- **Subsequence problems**: LCS, LIS, etc.
- **Knapsack variants**: Item selection with constraints
- **String matching**: Edit distance, pattern matching
- **Range queries**: Segment trees, interval DP

## Optimization Tips
- Identify overlapping subproblems early
- Choose right data structure for cache (Map vs ETS)
- Consider space optimization (do you need full DP table?)
- Add pruning for impossible states
- For very deep recursion, consider iterative bottom-up approach
