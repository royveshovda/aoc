# Mathematical Algorithms & Formulas

## Overview
Many AoC problems have mathematical solutions that are more efficient than simulation.

## Used In
- 2024 Day 13 (Cramer's rule for linear systems)
- 2023 Days 6, 8, 11, 18, 21 (Various mathematical optimizations)
- 2022 Day 11 (Modular arithmetic)

## Greatest Common Divisor (GCD)

```elixir
def gcd(a, 0), do: a
def gcd(a, b), do: gcd(b, rem(a, b))

# Using Erlang's built-in
def gcd(a, b), do: Integer.gcd(a, b)
```

## Least Common Multiple (LCM)

```elixir
def lcm(a, b), do: div(a * b, gcd(a, b))

# For multiple numbers
def lcm_list(numbers) do
  Enum.reduce(numbers, 1, &lcm/2)
end
```

## LCM for Cycle Synchronization (2023 Day 8)

```elixir
def find_sync_point(cycles) do
  # Each cycle has a length, find when they all align
  cycles
  |> Enum.map(&cycle_length/1)
  |> lcm_list()
end
```

## Solving Linear Systems (Cramer's Rule) - 2024 Day 13

```elixir
def solve_2x2_system({x1, y1}, {x2, y2}, {target_x, target_y}) do
  # Solving: a * x1 + b * x2 = target_x
  #          a * y1 + b * y2 = target_y
  
  # Using Cramer's rule
  determinant = x1 * y2 - y1 * x2
  
  if determinant == 0 do
    nil  # No unique solution
  else
    a_numerator = target_x * y2 - target_y * x2
    b_numerator = target_y * x1 - target_x * y1
    
    # Check if solutions are integers
    if rem(a_numerator, determinant) == 0 and rem(b_numerator, determinant) == 0 do
      a = div(a_numerator, determinant)
      b = div(b_numerator, determinant)
      
      # Verify solution (due to integer division)
      if a * x1 + b * x2 == target_x and a * y1 + b * y2 == target_y do
        {a, b}
      else
        nil
      end
    else
      nil
    end
  end
end
```

## Manhattan Distance

```elixir
def manhattan_distance({x1, y1}, {x2, y2}) do
  abs(x1 - x2) + abs(y1 - y2)
end

# 3D version
def manhattan_distance_3d({x1, y1, z1}, {x2, y2, z2}) do
  abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
end
```

## Euclidean Distance

```elixir
def euclidean_distance({x1, y1}, {x2, y2}) do
  :math.sqrt(:math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2))
end

# Squared distance (avoids sqrt, useful for comparisons)
def squared_distance({x1, y1}, {x2, y2}) do
  (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
end
```

## Modular Arithmetic (2022 Day 11)

```elixir
# Keep numbers manageable in simulation
def modular_optimization(values, divisors) do
  # Product of all divisors gives us the modulus
  modulus = Enum.product(divisors)
  
  # Keep values mod modulus
  Enum.map(values, &rem(&1, modulus))
end

# Positive modulo (handles negatives correctly)
def positive_mod(a, b) do
  rem = rem(a, b)
  if rem < 0, do: rem + b, else: rem
end
```

## Shoelace Formula for Polygon Area (2023 Day 18)

```elixir
def shoelace_area(vertices) do
  n = length(vertices)
  
  sum = 0..(n - 1)
  |> Enum.map(fn i ->
    {x1, y1} = Enum.at(vertices, i)
    {x2, y2} = Enum.at(vertices, rem(i + 1, n))
    x1 * y2 - x2 * y1
  end)
  |> Enum.sum()
  
  abs(sum) / 2
end
```

## Pick's Theorem (2023 Day 18)

```elixir
# Relates area, interior points, and boundary points
# Area = interior_points + boundary_points/2 - 1
# Therefore: interior_points = Area - boundary_points/2 + 1

def picks_theorem(area, boundary_points) do
  # Interior points
  interior = area - boundary_points / 2 + 1
  
  # Total points
  floor(interior + boundary_points)
end
```

## Combinatorics - Combinations (2023 Day 11)

```elixir
def combinations(list, 0), do: [[]]
def combinations([], _), do: []
def combinations([head | tail], n) do
  # Include head in combination
  with_head = Enum.map(combinations(tail, n - 1), fn combo -> [head | combo] end)
  # Don't include head
  without_head = combinations(tail, n)
  
  with_head ++ without_head
end

# More efficient iterative version
def combinations_count(n, k) when k > n, do: 0
def combinations_count(n, 0), do: 1
def combinations_count(n, k) do
  # C(n, k) = n! / (k! * (n-k)!)
  # But we can optimize: C(n, k) = C(n, n-k)
  k = min(k, n - k)
  
  Enum.reduce(1..k, 1, fn i, acc ->
    div(acc * (n - i + 1), i)
  end)
end
```

## Permutations

```elixir
def permutations([]), do: [[]]
def permutations(list) do
  for head <- list,
      tail <- permutations(list -- [head]),
      do: [head | tail]
end
```

## Quadratic Formula

```elixir
def solve_quadratic(a, b, c) do
  discriminant = b * b - 4 * a * c
  
  cond do
    discriminant < 0 ->
      {:no_real_solutions}
    
    discriminant == 0 ->
      {:one_solution, -b / (2 * a)}
    
    true ->
      sqrt_disc = :math.sqrt(discriminant)
      x1 = (-b + sqrt_disc) / (2 * a)
      x2 = (-b - sqrt_disc) / (2 * a)
      {:two_solutions, x1, x2}
  end
end
```

## Lagrange Interpolation (2023 Day 21)

```elixir
def lagrange_interpolate(points, x) do
  # Given points [(x0, y0), (x1, y1), ...], find y at x
  points
  |> Enum.with_index()
  |> Enum.map(fn {{xi, yi}, i} ->
    # Calculate Lagrange basis polynomial
    basis = points
    |> Enum.with_index()
    |> Enum.filter(fn {_, j} -> j != i end)
    |> Enum.reduce(1, fn {{xj, _}, _}, acc ->
      acc * (x - xj) / (xi - xj)
    end)
    
    yi * basis
  end)
  |> Enum.sum()
end

# For three points (common in AoC)
def lagrange_3_points({x0, y0}, {x1, y1}, {x2, y2}, x) do
  t0 = div((x - x1) * (x - x2), (x0 - x1) * (x0 - x2)) * y0
  t1 = div((x - x0) * (x - x2), (x1 - x0) * (x1 - x2)) * y1
  t2 = div((x - x0) * (x - x1), (x2 - x0) * (x2 - x1)) * y2
  
  t0 + t1 + t2
end
```

## Number Theory - Factorization

```elixir
def prime_factors(n) when n <= 1, do: []
def prime_factors(n) do
  find_factor(n, 2, [])
end

defp find_factor(1, _, factors), do: Enum.reverse(factors)
defp find_factor(n, candidate, factors) when candidate * candidate > n do
  Enum.reverse([n | factors])
end
defp find_factor(n, candidate, factors) do
  if rem(n, candidate) == 0 do
    find_factor(div(n, candidate), candidate, [candidate | factors])
  else
    find_factor(n, candidate + 1, factors)
  end
end

def divisors(n) do
  1..div(n, 2)
  |> Enum.filter(fn d -> rem(n, d) == 0 end)
  |> Kernel.++([n])
end
```

## Range Operations (2023 Day 5)

```elixir
# Check if ranges overlap
def ranges_overlap?({a1, a2}, {b1, b2}) do
  a1 <= b2 and b1 <= a2
end

# Merge overlapping ranges
def merge_ranges(ranges) do
  ranges
  |> Enum.sort()
  |> Enum.reduce([], fn {start, stop} = range, acc ->
    case acc do
      [] -> [range]
      [{prev_start, prev_stop} | rest] ->
        if start <= prev_stop + 1 do
          [{prev_start, max(stop, prev_stop)} | rest]
        else
          [range | acc]
        end
    end
  end)
  |> Enum.reverse()
end

# Range intersection
def range_intersection({a1, a2}, {b1, b2}) do
  start = max(a1, b1)
  stop = min(a2, b2)
  
  if start <= stop do
    {:ok, {start, stop}}
  else
    :no_intersection
  end
end
```

## Chinese Remainder Theorem

```elixir
def chinese_remainder_theorem(remainders, moduli) do
  # Solves system: x ≡ a1 (mod m1), x ≡ a2 (mod m2), ...
  product = Enum.product(moduli)
  
  remainders
  |> Enum.zip(moduli)
  |> Enum.map(fn {remainder, modulus} ->
    p = div(product, modulus)
    remainder * mod_inverse(p, modulus) * p
  end)
  |> Enum.sum()
  |> rem(product)
end

# Extended Euclidean algorithm for modular inverse
defp mod_inverse(a, m) do
  {g, x, _} = extended_gcd(a, m)
  if g != 1, do: raise("Inverse doesn't exist")
  rem(x + m, m)
end

defp extended_gcd(a, 0), do: {a, 1, 0}
defp extended_gcd(a, b) do
  {g, x1, y1} = extended_gcd(b, rem(a, b))
  {g, y1, x1 - div(a, b) * y1}
end
```

## Key Points
- **Choose Math Over Simulation**: If problem has pattern, find formula
- **Integer Arithmetic**: Be careful with division, use `div` not `/`
- **Overflow**: Elixir handles big integers automatically
- **Modular Arithmetic**: Keep numbers manageable in long simulations
- **Geometry**: Know shoelace, Pick's theorem for area problems
- **LCM/GCD**: Common for cycle synchronization
- **Combinatorics**: Calculate, don't generate when possible

## When to Use Math Instead of Simulation
- Pattern detection (arithmetic/geometric sequences)
- Very large iteration counts
- Optimization problems with constraints
- Geometric problems (area, distance)
- Cycle detection and prediction
