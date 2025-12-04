# Number Theory & Combinatorics

## Overview
Number theory problems involve divisors, primes, modular arithmetic, and combinatorial patterns.

## 1. Sieve Algorithms

### Sieve of Eratosthenes (Prime Finding)
```elixir
defp sieve_of_eratosthenes(limit) do
  sieve = Enum.to_list(2..limit)
  sieve_helper(sieve, [], limit)
end

defp sieve_helper([], primes, _), do: Enum.reverse(primes)
defp sieve_helper([prime | rest], primes, limit) do
  # Remove all multiples of prime
  filtered = Enum.reject(rest, fn n -> rem(n, prime) == 0 end)
  sieve_helper(filtered, [prime | primes], limit)
end
```

### Divisor Sieve (2015 Day 20)

**Problem:** For each number 1..N, compute sum of divisors efficiently.

```elixir
defp divisor_sieve(limit, multiplier \\ 1, max_visits \\ :infinity) do
  # Use ETS for mutable state in hot loop
  table = :ets.new(:divisors, [:set, :private])
  
  try do
    # Each number n marks all its multiples
    1..limit
    |> Enum.each(fn n ->
      mark_multiples(table, n, limit, multiplier, max_visits)
    end)
    
    # Read results
    1..limit
    |> Enum.map(fn n ->
      case :ets.lookup(table, n) do
        [{^n, sum}] -> {n, sum}
        [] -> {n, 0}
      end
    end)
    |> Map.new()
  after
    :ets.delete(table)
  end
end

defp mark_multiples(table, n, limit, multiplier, max_visits) do
  visits = if max_visits == :infinity, do: div(limit, n), else: min(max_visits, div(limit, n))
  
  1..visits
  |> Enum.each(fn visit_num ->
    multiple = n * visit_num
    if multiple <= limit do
      :ets.update_counter(table, multiple, n * multiplier, {multiple, 0})
    end
  end)
end
```

**Key Insight:** Instead of computing divisors for each number, let each number mark all its multiples. This is O(N log N) instead of O(N√N).

**When to Use:**
- Sum of divisors problems
- "Each X affects multiples of X" problems
- Factorization-related bulk computation

## 2. Modular Arithmetic

### Modular Exponentiation
```elixir
defp mod_exp(base, exp, mod) do
  Integer.pow(base, exp) |> rem(mod)
end

# For very large exponents, use binary exponentiation
defp fast_mod_exp(_, 0, _), do: 1
defp fast_mod_exp(base, exp, mod) when rem(exp, 2) == 0 do
  half = fast_mod_exp(base, div(exp, 2), mod)
  rem(half * half, mod)
end
defp fast_mod_exp(base, exp, mod) do
  rem(base * fast_mod_exp(base, exp - 1, mod), mod)
end
```

### Modular Sequences (2015 Day 25)
```elixir
defp generate_modular_sequence(start, multiplier, modulus, count) do
  1..count
  |> Enum.reduce(start, fn _, current ->
    rem(current * multiplier, modulus)
  end)
end

# Example: Code generation
# next = (prev * 252533) % 33554393
defp generate_code(position, start \\ 20151125) do
  1..(position - 1)
  |> Enum.reduce(start, fn _, code ->
    rem(code * 252533, 33554393)
  end)
end
```

### Modular Inverse
```elixir
# Extended Euclidean Algorithm
defp extended_gcd(a, 0), do: {a, 1, 0}
defp extended_gcd(a, b) do
  {gcd, x1, y1} = extended_gcd(b, rem(a, b))
  {gcd, y1, x1 - div(a, b) * y1}
end

defp mod_inverse(a, m) do
  {gcd, x, _} = extended_gcd(a, m)
  if gcd != 1, do: nil, else: rem(rem(x, m) + m, m)
end
```

## 3. Triangular Numbers & Diagonal Traversal

**Problem:** Access 2D grid filled diagonally (2015 Day 25).

```elixir
# Grid filled: (1,1), (2,1), (1,2), (3,1), (2,2), (1,3), ...
# Diagonal pattern follows triangular numbers

defp position_at(row, col) do
  # Which diagonal? diagonal = row + col - 1
  diagonal = row + col - 1
  
  # Elements before this diagonal: sum(1..diagonal-1) = n*(n-1)/2
  before_diagonal = div((diagonal - 1) * diagonal, 2)
  
  # Position within diagonal (from top)
  before_diagonal + col
end

# Nth triangular number
defp triangular(n), do: div(n * (n + 1), 2)

# Find which diagonal contains position N
defp find_diagonal(position) do
  # Solve: n*(n+1)/2 >= position
  # n ≈ sqrt(2*position)
  n = :math.sqrt(2 * position) |> ceil()
  
  # Refine
  Stream.iterate(n, &(&1 + 1))
  |> Enum.find(fn d -> triangular(d) >= position end)
end
```

## 4. Combinatorics - Generating Combinations

### All Combinations of Size K
```elixir
defp combinations(_, 0), do: [[]]
defp combinations([], _), do: []
defp combinations([h | t], k) do
  # Include h
  with_h = combinations(t, k - 1) |> Enum.map(&[h | &1])
  # Exclude h
  without_h = combinations(t, k)
  
  with_h ++ without_h
end
```

### Incremental Combination Search (2015 Days 17, 24)

**Problem:** Find minimum-size combination satisfying a condition.

```elixir
defp find_min_combination(items, target_sum) do
  1..length(items)
  |> Enum.find_value(fn size ->
    combos = combinations(items, size)
    
    valid = Enum.filter(combos, fn combo -> Enum.sum(combo) == target_sum end)
    
    unless Enum.empty?(valid) do
      # Found valid combinations of this size
      valid
      |> Enum.map(&quantum_entanglement/1)
      |> Enum.min()
    end
  end)
end

defp quantum_entanglement(items), do: Enum.reduce(items, 1, &*/2)
```

**Key Insight:** Try smallest sizes first. Once you find valid combinations of size k, no need to check k+1 since we want minimum.

### Permutations
```elixir
defp permutations([]), do: [[]]
defp permutations(list) do
  for elem <- list, rest <- permutations(list -- [elem]) do
    [elem | rest]
  end
end

# More efficient for large lists
defp permutations_efficient(list) do
  permutations_helper(list, length(list))
end

defp permutations_helper(_, 0), do: [[]]
defp permutations_helper(list, n) do
  for {elem, idx} <- Enum.with_index(list),
      rest <- permutations_helper(List.delete_at(list, idx), n - 1) do
    [elem | rest]
  end
end
```

## 5. Partition Problems

**Problem:** Divide items into groups with equal sums.

```elixir
defp can_partition?(items, num_groups) do
  total = Enum.sum(items)
  
  if rem(total, num_groups) != 0 do
    false
  else
    target = div(total, num_groups)
    can_form_group?(items, target)
  end
end

defp can_form_group?(items, target) do
  combinations(items, 1..length(items))
  |> Enum.any?(fn combo -> Enum.sum(combo) == target end)
end

# For optimization problems: find best group among valid ones
defp optimize_partition(items, num_groups, cost_fn) do
  target = div(Enum.sum(items), num_groups)
  
  1..length(items)
  |> Enum.find_value(fn size ->
    valid = combinations(items, size)
    |> Enum.filter(fn combo -> Enum.sum(combo) == target end)
    
    unless Enum.empty?(valid) do
      valid |> Enum.map(cost_fn) |> Enum.min()
    end
  end)
end
```

## 6. GCD, LCM, and Chinese Remainder Theorem

### Basic GCD and LCM
```elixir
defp gcd(a, 0), do: a
defp gcd(a, b), do: gcd(b, rem(a, b))

defp lcm(a, b), do: div(a * b, gcd(a, b))

defp lcm_list(numbers), do: Enum.reduce(numbers, &lcm/2)
```

### Chinese Remainder Theorem
```elixir
defp crt(remainders_and_moduli) do
  # Solve: x ≡ r1 (mod m1), x ≡ r2 (mod m2), ...
  # Returns {x, M} where M = lcm(m1, m2, ...)
  
  [{r, m} | rest] = remainders_and_moduli
  
  Enum.reduce(rest, {r, m}, fn {r2, m2}, {x, m1} ->
    # Find x such that: x ≡ x (mod m1) and x ≡ r2 (mod m2)
    {gcd_val, inv, _} = extended_gcd(m1, m2)
    
    if rem(r2 - x, gcd_val) != 0 do
      :no_solution
    else
      diff = r2 - x
      lcm_val = lcm(m1, m2)
      new_x = rem(x + div(diff, gcd_val) * inv * m1, lcm_val)
      {new_x, lcm_val}
    end
  end)
end
```

## 7. Factorial and Binomial Coefficients

```elixir
defp factorial(0), do: 1
defp factorial(n), do: n * factorial(n - 1)

# With memoization
defp factorial_memo(n, cache \\ %{}) do
  if Map.has_key?(cache, n) do
    {Map.get(cache, n), cache}
  else
    {result, new_cache} = if n == 0 do
      {1, cache}
    else
      {prev, cache1} = factorial_memo(n - 1, cache)
      {n * prev, cache1}
    end
    {result, Map.put(new_cache, n, result)}
  end
end

# Binomial coefficient: C(n, k) = n! / (k! * (n-k)!)
defp binomial(n, k) when k > n, do: 0
defp binomial(n, 0), do: 1
defp binomial(n, n), do: 1
defp binomial(n, k) do
  div(factorial(n), factorial(k) * factorial(n - k))
end

# More efficient (avoids large factorials)
defp binomial_efficient(n, k) when k > n - k, do: binomial_efficient(n, n - k)
defp binomial_efficient(n, k) do
  1..k
  |> Enum.reduce(1, fn i, acc -> div(acc * (n - i + 1), i) end)
end
```

## Performance Considerations

1. **Sieve algorithms** are O(N log N) - much faster than checking each number
2. **ETS for sieves** - mutable state is essential for performance
3. **Early termination** in combination search saves exponential time
4. **Modular arithmetic** prevents integer overflow in sequences
5. **Memoization** crucial for factorial/binomial computations

## Common Pitfalls

- **Integer overflow** in factorial/binomial (though Elixir handles arbitrary precision)
- **Performance** - generating all combinations can be exponential
- **Off-by-one** in triangular number formulas
- **Modular arithmetic** - remember to take mod at each step, not just at end
- **Divisibility checks** - use `rem(a, b) == 0` not `div(a, b) * b == a`

## Related Patterns
- [Mathematical Algorithms](mathematical_algorithms.md) - GCD/LCM applications
- [Dynamic Programming](dynamic_programming.md) - Memoized computations
- [Cycle Detection](cycle_detection.md) - Finding patterns in sequences
