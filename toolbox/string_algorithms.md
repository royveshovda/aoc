# String Algorithms & Patterns

## Overview
String manipulation is common in AoC, including searching, replacing, transforming, and pattern matching.

## 0. String Scrambling with Reversible Operations

**Problem:** Apply a sequence of operations to scramble a string, then reverse them to unscramble (2016 Day 21).

**When to Use:**
- String transformation puzzles with invertible operations
- Password scrambling/unscrambling
- Sequence reversal where each operation has an inverse

```elixir
# Define operations that work in both directions
defp apply_operation(str, operation, :forward) do
  case operation do
    {:swap_pos, x, y} ->
      # Swap positions x and y (self-inverse)
      swap_positions(str, x, y)
    
    {:swap_letter, a, b} ->
      # Swap all occurrences of letters a and b (self-inverse)
      String.replace(str, [a, b], fn
        ^a -> b
        ^b -> a
      end)
    
    {:rotate_left, steps} ->
      # Rotate list left
      rotate_list(str, -steps)
    
    {:rotate_right, steps} ->
      # Rotate list right
      rotate_list(str, steps)
    
    {:rotate_based, letter} ->
      # Rotate based on letter position
      idx = String.graphemes(str) |> Enum.find_index(&(&1 == letter))
      steps = 1 + idx + if(idx >= 4, do: 1, else: 0)
      rotate_list(str, steps)
    
    {:reverse, x, y} ->
      # Reverse substring (self-inverse)
      reverse_range(str, x, y)
    
    {:move, x, y} ->
      # Remove from x, insert at y
      move_position(str, x, y)
  end
end

defp apply_operation(str, operation, :reverse) do
  case operation do
    {:swap_pos, _, _} -> apply_operation(str, operation, :forward)  # Self-inverse
    {:swap_letter, _, _} -> apply_operation(str, operation, :forward)  # Self-inverse
    {:rotate_left, steps} -> apply_operation(str, {:rotate_right, steps}, :forward)
    {:rotate_right, steps} -> apply_operation(str, {:rotate_left, steps}, :forward)
    {:rotate_based, letter} ->
      # Reverse rotate_based by trying all possible starting positions
      chars = String.graphemes(str)
      Enum.find_value(0..(length(chars) - 1), fn try_pos ->
        test = rotate_list(str, -try_pos)
        if apply_operation(test, operation, :forward) == str, do: test
      end)
    {:reverse, _, _} -> apply_operation(str, operation, :forward)  # Self-inverse
    {:move, x, y} -> apply_operation(str, {:move, y, x}, :forward)  # Swap x and y
  end
end

# Helper functions
defp rotate_list(str, steps) do
  chars = String.graphemes(str)
  len = length(chars)
  steps = rem(rem(steps, len) + len, len)  # Normalize to positive
  {left, right} = Enum.split(chars, len - steps)
  Enum.join(right ++ left)
end

defp reverse_range(str, x, y) do
  chars = String.graphemes(str)
  {before, rest} = Enum.split(chars, x)
  {middle, after_part} = Enum.split(rest, y - x + 1)
  Enum.join(before ++ Enum.reverse(middle) ++ after_part)
end
```

**Key Patterns:**
- Identify self-inverse operations (swap, reverse)
- For non-invertible operations, either compute mathematical inverse or brute-force search
- `rotate_based` reversal requires trying all positions
- Store operations as data structures for bidirectional application

## 1. Hash Mining (MD5/SHA)

**Problem:** Find inputs that produce hashes matching specific criteria.

**When to Use:**
- Proof-of-work style problems (2015 Day 4, 2016 Day 5)
- Finding hashes with specific prefixes
- Password generation based on hash characteristics

```elixir
# Finding hashes with specific prefix
def find_hash_with_prefix(base, prefix, start_index \\ 0) do
  Stream.iterate(start_index, &(&1 + 1))
  |> Enum.find(fn index ->
    hash = :crypto.hash(:md5, base <> Integer.to_string(index)) 
           |> Base.encode16(case: :lower)
    String.starts_with?(hash, prefix)
  end)
end

# Collecting multiple matching hashes
def find_n_hashes(base, prefix, count) do
  Stream.iterate(0, &(&1 + 1))
  |> Stream.filter(fn index ->
    hash = :crypto.hash(:md5, base <> Integer.to_string(index))
           |> Base.encode16(case: :lower)
    String.starts_with?(hash, prefix)
  end)
  |> Stream.map(fn index ->
    hash = :crypto.hash(:md5, base <> Integer.to_string(index))
           |> Base.encode16(case: :lower)
    {index, hash}
  end)
  |> Enum.take(count)
end

# Position-based hash mining (2016 Day 5 Part 2)
def mine_hash_by_position(base, target_prefix, positions) do
  Stream.iterate(0, &(&1 + 1))
  |> Enum.reduce_while(%{}, fn index, acc ->
    if map_size(acc) == positions do
      {:halt, acc}
    else
      hash = :crypto.hash(:md5, base <> Integer.to_string(index))
             |> Base.encode16(case: :lower)
      
      if String.starts_with?(hash, target_prefix) do
        pos = String.at(hash, String.length(target_prefix))
        val = String.at(hash, String.length(target_prefix) + 1)
        
        case Integer.parse(pos) do
          {p, ""} when p in 0..(positions - 1) and not is_map_key(acc, p) ->
            {:cont, Map.put(acc, p, val)}
          _ ->
            {:cont, acc}
        end
      else
        {:cont, acc}
      end
    end
  end)
end
```

**Performance Tips:**
- Hash computation is expensive - minimize redundant calculations
- Use `Stream` for lazy evaluation
- Consider parallel processing for large searches (Task.async_stream)
- Cache hash values if needed multiple times

**Related:** Cycle detection, brute force search

## 1. Substring Replacement at All Positions

**Problem:** Generate all possible strings by replacing one substring occurrence.

**When to Use:**
- Generating variants/mutations (2015 Day 19)
- String transformation problems
- Finding all reachable states from a string

```elixir
defp find_all_positions(string, substring) do
  len = String.length(substring)
  
  0..(String.length(string) - len)
  |> Enum.filter(fn pos ->
    String.slice(string, pos, len) == substring
  end)
end

defp replace_at_position(string, pos, old_len, new_substring) do
  before = String.slice(string, 0, pos)
  after_str = String.slice(string, (pos + old_len)..-1//1)
  before <> new_substring <> after_str
end

# Generate all possible one-step replacements
defp generate_all_replacements(string, replacements) do
  replacements
  |> Enum.flat_map(fn {from, to} ->
    find_all_positions(string, from)
    |> Enum.map(fn pos ->
      replace_at_position(string, pos, String.length(from), to)
    end)
  end)
  |> MapSet.new()  # Remove duplicates
end
```

**Example Usage (2015 Day 19):**
```elixir
# Find all distinct molecules after one replacement
def count_distinct_molecules(molecule, replacements) do
  generate_all_replacements(molecule, replacements)
  |> MapSet.size()
end
```

## 2. Greedy String Reduction

**Problem:** Reduce a string to a target by applying replacements (reverse generation).

**When to Use:**
- When working backwards is easier than forwards
- Special input properties guarantee greedy works
- Minimizing number of transformations

```elixir
defp greedy_reduce(string, replacements, target, steps \\ 0)
defp greedy_reduce(target, _replacements, target, steps), do: steps

defp greedy_reduce(current, replacements, target, steps) do
  # Try longest replacements first (greedy choice)
  case find_first_replacement(current, replacements) do
    nil -> :no_solution
    new_string -> greedy_reduce(new_string, replacements, target, steps + 1)
  end
end

defp find_first_replacement(string, replacements) do
  replacements
  |> Enum.sort_by(fn {from, _to} -> String.length(from) end, :desc)
  |> Enum.find_value(fn {from, to} ->
    if String.contains?(string, from) do
      String.replace(string, from, to, global: false)
    end
  end)
end
```

**Key Insight:** Greedy doesn't always work, but AoC problems with this pattern typically have specially crafted inputs where longest-match-first is optimal.

## 3. Look-and-Say / Run-Length Encoding

**Problem:** Transform string by describing consecutive runs of characters.

**When to Use:**
- Look-and-say sequences (2015 Day 10)
- Run-length encoding/decoding
- Pattern description problems

```elixir
defp look_and_say(string) do
  string
  |> String.graphemes()
  |> Enum.chunk_by(&(&1))
  |> Enum.map(fn group ->
    "#{length(group)}#{hd(group)}"
  end)
  |> Enum.join()
end

# Apply n iterations
defp iterate_look_and_say(string, 0), do: string
defp iterate_look_and_say(string, n) do
  iterate_look_and_say(look_and_say(string), n - 1)
end
```

## 4. String Escape Sequences

**Problem:** Handle different string representations (literal vs. encoded).

**When to Use:**
- Parsing string literals (2015 Day 8)
- Encoding/decoding problems
- Character counting with escapes

```elixir
# Count characters in memory (decoded)
defp memory_length(string) do
  string
  |> String.slice(1..-2//1)  # Remove surrounding quotes
  |> String.replace(~r/\\\\/, "X")  # \\ -> single char
  |> String.replace(~r/\\"/, "X")   # \" -> single char
  |> String.replace(~r/\\x[0-9a-f]{2}/, "X")  # \xNN -> single char
  |> String.length()
end

# Count characters in encoded form
defp encoded_length(string) do
  2 +  # Add quotes
  String.length(string) +
  (string |> String.graphemes() |> Enum.count(&(&1 in ["\\", "\""])))
end
```

## 5. Pattern Matching with Divisors

**Problem:** Check if string is composed of repeating patterns.

**When to Use:**
- Finding repeated substrings
- Detecting cycles in string generation
- Compression/pattern detection

```elixir
defp find_repeating_pattern(string) do
  length = String.length(string)
  
  # Try all divisors of length
  divisors(length)
  |> Enum.find(fn pattern_length ->
    pattern = String.slice(string, 0, pattern_length)
    repeats = div(length, pattern_length)
    
    String.duplicate(pattern, repeats) == string
  end)
end

defp divisors(n) do
  1..(div(n, 2))
  |> Enum.filter(fn d -> rem(n, d) == 0 end)
end
```

## 6. String Validation Rules

**Problem:** Check if strings satisfy complex conditions.

**When to Use:**
- Input validation problems (2015 Day 5)
- Password/string rule checking
- Pattern matching with multiple criteria

```elixir
defp validate_string(string, rules) do
  Enum.all?(rules, fn rule -> rule.(string) end)
end

# Example rules
rules = [
  fn s -> String.match?(s, ~r/([aeiou].*){3}/) end,  # 3+ vowels
  fn s -> String.match?(s, ~r/(.)\1/) end,           # Double letter
  fn s -> !String.match?(s, ~r/(ab|cd|pq|xy)/) end   # No forbidden pairs
]

defp has_double_letter?(string) do
  string
  |> String.graphemes()
  |> Enum.chunk_every(2, 1, :discard)
  |> Enum.any?(fn [a, b] -> a == b end)
end

defp has_non_overlapping_pair?(string) do
  pairs = string
  |> String.graphemes()
  |> Enum.chunk_every(2, 1, :discard)
  |> Enum.map(&Enum.join/1)
  
  pairs
  |> Enum.with_index()
  |> Enum.any?(fn {pair, i} ->
    pairs
    |> Enum.drop(i + 2)  # Skip overlapping
    |> Enum.member?(pair)
  end)
end
```

## 7. String to Number Conversions

**Problem:** Parse numbers from strings with specific formats.

```elixir
# Extract all numbers from string
defp extract_numbers(string) do
  Regex.scan(~r/-?\d+/, string)
  |> List.flatten()
  |> Enum.map(&String.to_integer/1)
end

# Parse coordinate-like strings
defp parse_coordinate(string) do
  case Regex.run(~r/row (\d+), column (\d+)/, string) do
    [_, row, col] -> {String.to_integer(row), String.to_integer(col)}
    _ -> nil
  end
end
```

## Performance Tips

1. **Use binary pattern matching** for prefix/suffix checks when possible
2. **`String.contains?/2`** is faster than regex for simple substring checks
3. **Compile regex once** if used repeatedly: `@pattern ~r/...//`
4. **Use charlists** for character-by-character operations if faster
5. **Consider `IO.iodata_to_binary/1`** for building large strings

## 7. Pattern Detection with chunk_every

**Problem:** Find patterns like palindromes, ABBA sequences, or repeating n-grams.

**When to Use:**
- Finding palindromic subsequences (2016 Day 7)
- Detecting repeating patterns of fixed length
- Sliding window pattern matching

```elixir
# Find all ABBA patterns (palindromes of length 4)
defp has_abba?(string) do
  string
  |> String.graphemes()
  |> Enum.chunk_every(4, 1, :discard)
  |> Enum.any?(fn [a, b, c, d] -> a == d and b == c and a != b end)
end

# Find all ABA patterns (palindromes of length 3)
defp find_all_abas(string) do
  string
  |> String.graphemes()
  |> Enum.chunk_every(3, 1, :discard)
  |> Enum.filter(fn [a, b, c] -> a == c and a != b end)
  |> Enum.map(&Enum.join/1)
end

# General n-gram extraction
defp extract_ngrams(string, n) do
  string
  |> String.graphemes()
  |> Enum.chunk_every(n, 1, :discard)
  |> Enum.map(&Enum.join/1)
end
```

**Key Points:**
- `Enum.chunk_every(list, n, step, leftover)` - `step` controls overlap
- `:discard` drops incomplete final chunks
- Use pattern matching in anonymous functions for clean filtering

## 8. Recursive Length Calculation (No Materialization)

**Problem:** Calculate length of expanded/decompressed string without building it.

**When to Use:**
- Decompression problems where output is huge (2016 Day 9)
- Expansion problems where only length matters
- Memory-constrained scenarios

```elixir
# Example: Calculate decompressed length without building string
defp decompress_length("", _recursive), do: 0

defp decompress_length("(" <> rest, recursive) do
  # Parse marker like (10x2)
  [marker, remainder] = String.split(rest, ")", parts: 2)
  [len, times] = marker |> String.split("x") |> Enum.map(&String.to_integer/1)
  
  # Extract the data section
  {data, after_data} = String.split_at(remainder, len)
  
  # Calculate data length (recursively if needed)
  data_length = if recursive do
    decompress_length(data, true)
  else
    String.length(data)
  end
  
  # Return: (data_length * times) + remaining length
  data_length * times + decompress_length(after_data, recursive)
end

defp decompress_length(<<_char, rest::binary>>, recursive) do
  # Regular character: length 1 + rest
  1 + decompress_length(rest, recursive)
end
```

**Performance Benefits:**
- O(1) space instead of O(n) for massive expansions
- Tail-recursive for large inputs
- Can handle results too large to store in memory

**Pattern:** When problem asks "how long" not "what is", calculate don't build.

## 7. Dragon Curve & Fractal Generation

**Problem:** Generate strings using recursive fractal patterns (2016 Day 16).

**Dragon Curve Pattern:**
1. Start with string `a`
2. Create reversed copy and flip bits: `b = reverse(flip(a))`
3. Result: `a + "0" + b`
4. Repeat until reaching target length

```elixir
defp generate_dragon_curve(data, target_length) do
  if String.length(data) >= target_length do
    String.slice(data, 0, target_length)
  else
    # Create reversed, flipped copy
    reversed_flipped = data
                      |> String.reverse()
                      |> String.graphemes()
                      |> Enum.map(&flip_bit/1)
                      |> Enum.join()
    
    generate_dragon_curve(data <> "0" <> reversed_flipped, target_length)
  end
end

defp flip_bit("0"), do: "1"
defp flip_bit("1"), do: "0"

# Generate checksum (recursive until odd length)
defp checksum(data) do
  result = data
          |> String.graphemes()
          |> Enum.chunk_every(2)
          |> Enum.map(fn
            [a, a] -> "1"  # Matching pair
            _ -> "0"       # Different pair
          end)
          |> Enum.join()
  
  # Checksum must have odd length
  if rem(String.length(result), 2) == 0 do
    checksum(result)
  else
    result
  end
end
```

**Key Properties:**
- Exponential growth: each iteration roughly doubles size
- Deterministic: same input always produces same output
- Self-similar: contains copies of itself at different scales

**When to Use:**
- Fractal/recursive string generation
- Binary string expansion
- Problems requiring data to fill specific length

## Common Pitfalls

- **Unicode handling:** Use `String.graphemes/1` not `String.codepoints/1` for user-perceived characters
- **Escape sequences:** Remember `\\` in regex needs double escaping in strings
- **Empty string edge cases:** Always test with `""`
- **Off-by-one:** Remember `String.slice` uses 0-based indexing

## Related Patterns
- [Parsing Patterns](parsing.md) - Input string processing
- [Cycle Detection](cycle_detection.md) - Finding repeated patterns
- [Simulation](simulation.md) - String transformation sequences
