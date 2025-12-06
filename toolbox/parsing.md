# Parsing Patterns & Input Processing

## Overview
AoC inputs come in many formats. Having robust parsing patterns saves time and reduces errors.

## Used In
- Every single day! Input parsing is always the first step

## Line-by-Line Parsing

```elixir
def parse_lines(input) do
  input
  |> String.split("\n", trim: true)
  |> Enum.map(&parse_line/1)
end

# With integer conversion
def parse_integers(input) do
  input
  |> String.split("\n", trim: true)
  |> Enum.map(&String.to_integer/1)
end

# With string splitting
def parse_space_separated(input) do
  input
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, " ", trim: true))
end
```

## Multi-Section Input (2024 Day 5)

```elixir
def parse_sections(input) do
  input
  |> String.split("\n\n", trim: true)
  |> Enum.map(&parse_section/1)
end

# Example: rules and data
def parse_rules_and_data(input) do
  [rules_section, data_section] = String.split(input, "\n\n", trim: true)
  
  rules = rules_section
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    [a, b] = String.split(line, "|")
    {String.to_integer(a), String.to_integer(b)}
  end)
  
  data = data_section
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    line
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end)
  
  {rules, data}
end
```

## Regex-Based Parsing (2024 Day 3)

```elixir
def parse_with_regex(input) do
  pattern = ~r/mul\((\d{1,3}),(\d{1,3})\)/
  
  Regex.scan(pattern, input)
  |> Enum.map(fn [_, a, b] -> 
    {String.to_integer(a), String.to_integer(b)}
  end)
end

# Multiple patterns
def parse_multiple_patterns(input) do
  pattern = ~r/mul\((\d+),(\d+)\)|do\(\)|don't\(\)/
  
  Regex.scan(pattern, input)
  |> Enum.map(fn match ->
    case match do
      ["do()"] -> :do
      ["don't()"] -> :dont
      [_, a, b] -> {:mul, String.to_integer(a), String.to_integer(b)}
    end
  end)
end
```

## Parsing with Pattern Matching

```elixir
defp parse_line("forward " <> n), do: {:forward, String.to_integer(n)}
defp parse_line("down " <> n), do: {:down, String.to_integer(n)}
defp parse_line("up " <> n), do: {:up, String.to_integer(n)}

# More complex patterns
defp parse_instruction(line) do
  case String.split(line, " ") do
    ["turn", "on", coords] -> {:on, parse_coords(coords)}
    ["turn", "off", coords] -> {:off, parse_coords(coords)}
    ["toggle", coords] -> {:toggle, parse_coords(coords)}
  end
end
```

## Nested Structure Parsing (2024 Day 5)

```elixir
def parse_nested(input) do
  input
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    [key, values] = String.split(line, ":", trim: true)
    values = values
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    
    {String.to_integer(key), values}
  end)
  |> Map.new()
end
```

## Coordinate Parsing (2023 Day 18)

```elixir
def parse_coordinates(input) do
  input
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    [dir, dist, color] = String.split(line, " ")
    {
      parse_direction(dir),
      String.to_integer(dist),
      String.trim(color, "()")
    }
  end)
end

defp parse_direction("R"), do: :right
defp parse_direction("L"), do: :left
defp parse_direction("U"), do: :up
defp parse_direction("D"), do: :down
```

## Range Parsing (2025 Day 2)

```elixir
def parse_ranges(input) do
  input
  |> String.trim()
  |> String.replace("\n", "")  # Handle wrapped lines
  |> String.split(",", trim: true)
  |> Enum.flat_map(&parse_range/1)
end

defp parse_range(range_str) do
  [first, last] = String.split(range_str, "-") |> Enum.map(&String.to_integer/1)
  first..last
end
```

## Parsing with NimbleParsec (2023 Day 5)

```elixir
# Add to mix.exs: {:nimble_parsec, "~> 1.4"}
import NimbleParsec

number = integer(min: 1)
whitespace = ignore(repeat(ascii_char([?\s, ?\t])))

line = 
  number
  |> ignore(whitespace)
  |> concat(number)
  |> ignore(whitespace)
  |> concat(number)
  |> tag(:line)

defparsec :parse_line, line

def parse_with_nimble(input) do
  input
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    {:ok, [line: values], _, _, _, _} = parse_line(line)
    values
  end)
end
```

## Parsing Grid Coordinates (2022 Day 14)

```elixir
def parse_line_segments(input) do
  input
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    line
    |> String.split(" -> ", trim: true)
    |> Enum.map(fn coord ->
      [x, y] = String.split(coord, ",") |> Enum.map(&String.to_integer/1)
      {x, y}
    end)
  end)
end

def fill_line_segments(segments) do
  Enum.flat_map(segments, fn coords ->
    coords
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.flat_map(fn [{x1, y1}, {x2, y2}] ->
      for x <- x1..x2, y <- y1..y2, do: {x, y}
    end)
  end)
  |> MapSet.new()
end
```

## Parsing with Code.eval_string (2022 Day 13)

```elixir
# Useful for parsing Elixir-compatible structures
def parse_list_structure(input) do
  input
  |> String.split("\n", trim: true)
  |> Enum.chunk_every(2)
  |> Enum.map(fn [left, right] ->
    {eval_string(left), eval_string(right)}
  end)
end

defp eval_string(str) do
  {result, _} = Code.eval_string(str)
  result
end
```

## Parsing Key-Value Pairs

```elixir
def parse_key_values(input, separator \\ ":") do
  input
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    [key, value] = String.split(line, separator, parts: 2)
    {String.trim(key), String.trim(value)}
  end)
  |> Map.new()
end
```

## Handling Wrapped Lines (2025 Day 2)

```elixir
def parse_unwrapped(input) do
  input
  |> String.trim()
  |> String.replace("\n", "")  # Remove newlines
  |> parse_single_line()
end
```

## Parsing Numbers with Validation

```elixir
def parse_integers_safe(input) do
  input
  |> String.split("\n", trim: true)
  |> Enum.map(&parse_integer_safe/1)
  |> Enum.reject(&is_nil/1)
end

defp parse_integer_safe(str) do
  case Integer.parse(str) do
    {num, ""} -> num
    _ -> nil
  end
end

# Check if valid integer string (2024 Day 3)
def integer_string?(str) do
  case Integer.parse(str) do
    {_, ""} -> true
    _ -> false
  end
end
```

## Parsing with Enum.chunk_every

```elixir
# Group lines into chunks
def parse_groups(input, size) do
  input
  |> String.split("\n", trim: true)
  |> Enum.chunk_every(size)
end

# Sliding window parsing
def parse_sliding(input, window_size) do
  input
  |> String.split("\n", trim: true)
  |> Enum.chunk_every(window_size, 1, :discard)
end
```

## Custom Separators

```elixir
def parse_custom_separator(input, separator) do
  input
  |> String.split(separator, trim: true)
  |> Enum.map(&String.trim/1)
end

# Multiple separators
def parse_multiple_seps(input) do
  input
  |> String.replace([",", ";", "|"], "\n")
  |> String.split("\n", trim: true)
end
```

## Extracting Numbers from Mixed Text

```elixir
def extract_all_numbers(text) do
  ~r/-?\d+/
  |> Regex.scan(text)
  |> List.flatten()
  |> Enum.map(&String.to_integer/1)
end

# With named captures
def extract_labeled_numbers(text) do
  ~r/(?<label>\w+):\s*(?<value>\d+)/
  |> Regex.scan(text, capture: :all_names)
  |> Enum.map(fn [label, value] -> 
    {label, String.to_integer(value)}
  end)
  |> Map.new()
end
```

## Parsing Hex Values (2023 Day 18)

```elixir
def parse_hex_color(color_str) do
  "#" <> hex = String.trim(color_str, "()")
  
  # Parse as base 16
  {value, ""} = Integer.parse(hex, 16)
  value
end

# Extract direction and distance from hex
def parse_hex_instruction("#" <> hex) do
  {distance, direction_digit} = String.split_at(hex, 5)
  
  distance = Integer.parse(distance, 16) |> elem(0)
  direction = case direction_digit do
    "0" -> :right
    "1" -> :down
    "2" -> :left
    "3" -> :up
  end
  
  {direction, distance}
end
```

## Character-by-Character with Escape Sequences (2017 Day 9)

For parsing with escape characters and nested structures:

```elixir
def parse_stream(input) do
  chars = input |> String.trim() |> String.graphemes()
  process(chars, 0, 0, false)
end

defp process([], score, garbage_count, _in_garbage), do: {score, garbage_count}

# Handle escape character - skip next char
defp process(["!" | rest], score, garbage_count, in_garbage) do
  [_ | rest2] = rest
  process(rest2, score, garbage_count, in_garbage)
end

# Start garbage section
defp process(["<" | rest], score, garbage_count, false) do
  process(rest, score, garbage_count, true)
end

# End garbage section
defp process([">" | rest], score, garbage_count, true) do
  process(rest, score, garbage_count, false)
end

# Count garbage characters
defp process([_ | rest], score, garbage_count, true) do
  process(rest, score, garbage_count + 1, true)
end

# Process groups when not in garbage
defp process(["{" | rest], score, garbage_count, false) do
  {new_score, new_garbage, rest2} = process_group(rest, score, garbage_count, 1)
  process(rest2, new_score, new_garbage, false)
end

# Skip other characters
defp process([_ | rest], score, garbage_count, false) do
  process(rest, score, garbage_count, false)
end

# Helper for nested groups
defp process_group(chars, score, garbage_count, depth) do
  # Add depth to score, then process inner content
  process_group_inner(chars, score + depth, garbage_count, depth)
end
```

**Key Insight**: State machine with boolean flags for mode (in_garbage, escaped, etc.). Pattern match on head of list for each character type.

## Key Points
- **String.split**: Most common tool, very flexible
- **Pattern Matching**: Elegant for structured text
- **Regex**: Powerful but can be overkill
- **trim: true**: Almost always want this with split
- **Multiple Sections**: Use `\n\n` to split on blank lines
- **Validation**: Check parse results, handle errors
- **NimbleParsec**: For complex grammars
- **Code.eval_string**: Quick for Elixir-compatible structures (use with caution)

## Column-Based Parsing (2025 Day 6)

**Problem:** Data arranged in vertical columns, separated by columns of spaces.

```elixir
# Parse vertical problems separated by all-space columns
def parse_columnar(input) do
  lines = String.split(input, "\n", trim: true)

  # Convert each line to charlists, pad to same length
  char_lines = Enum.map(lines, &String.to_charlist/1)
  max_len = char_lines |> Enum.map(&length/1) |> Enum.max()
  
  padded = Enum.map(char_lines, fn line ->
    line ++ List.duplicate(?\s, max_len - length(line))
  end)

  # Transpose to get columns
  columns = Enum.zip_with(padded, fn chars -> chars end)

  # Group columns by space-separator columns
  group_by_separator(columns, [], [])
end

defp group_by_separator([], [], acc), do: Enum.reverse(acc)
defp group_by_separator([], current, acc), do: Enum.reverse([Enum.reverse(current) | acc])
defp group_by_separator([col | rest], current, acc) do
  if Enum.all?(col, &(&1 == ?\s)) do
    if current == [], do: group_by_separator(rest, [], acc),
    else: group_by_separator(rest, [], [Enum.reverse(current) | acc])
  else
    group_by_separator(rest, [col | current], acc)
  end
end
```

**Used In:** 2025 Day 6 - parsing math problems arranged vertically

**Key Insight:** Transpose rows→columns first, then group by separator columns. Each group can be transposed back for row-wise processing, or processed column-by-column.

## Common Patterns Summary
1. Lines of integers: `String.split("\n") |> Enum.map(&String.to_integer/1)`
2. Space-separated: `String.split(" ")`
3. Multiple sections: `String.split("\n\n")`
4. Regex extraction: `Regex.scan(~r/pattern/, input)`
5. Pattern matching: Match on string prefixes/suffixes
6. Nested structures: Chain splits and maps
7. Coordinates: Parse pairs with comma separation
8. Ranges: Parse "a-b" format and create ranges
