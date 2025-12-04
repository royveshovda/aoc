# String Algorithms & Patterns

## Overview
String manipulation is common in AoC, including searching, replacing, transforming, and pattern matching.

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

## Common Pitfalls

- **Unicode handling:** Use `String.graphemes/1` not `String.codepoints/1` for user-perceived characters
- **Escape sequences:** Remember `\\` in regex needs double escaping in strings
- **Empty string edge cases:** Always test with `""`
- **Off-by-one:** Remember `String.slice` uses 0-based indexing

## Related Patterns
- [Parsing Patterns](parsing.md) - Input string processing
- [Cycle Detection](cycle_detection.md) - Finding repeated patterns
- [Simulation](simulation.md) - String transformation sequences
