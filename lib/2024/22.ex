import AOC

aoc 2024, 22 do
  @moduledoc """
  https://adventofcode.com/2024/day/22
  """

  def p1(input) do
    SecretNumbers.run(input)
  end

  def p2(input) do
    SecretNumbersPart2.run(input)
  end
end

defmodule SecretNumbers do

  @mod 16_777_216  # 2^24

  # Given one secret number, compute its "next secret number" by applying
  # the three steps (multiply by 64, divide by 32 (floor), multiply by 2048)
  # with bitwise XOR and modulo pruning.
  def next_secret(secret) do
    # Step 1: multiply by 64, XOR, then prune
    step1_val = secret * 64
    secret = Bitwise.bxor(secret, step1_val)
    secret = rem(secret, @mod)

    # Step 2: integer-divide by 32, XOR, then prune
    step2_val = div(secret, 32)
    secret = Bitwise.bxor(secret, step2_val)
    secret = rem(secret, @mod)

    # Step 3: multiply by 2048, XOR, then prune
    step3_val = secret * 2048
    secret = Bitwise.bxor(secret, step3_val)
    secret = rem(secret, @mod)

    secret
  end

  # Advance the secret number n times. We only need the final result after n steps.
  def advance_secret(secret, n) do
    Enum.reduce(1..n, secret, fn _, s -> next_secret(s) end)
  end

  # Reads initial secret numbers from a file, one per line. For each initial secret,
  # compute the 2000th generated secret and sum them all together.
  def run(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)
    |> Stream.map(fn initial_secret ->
      advance_secret(initial_secret, 2000)
    end)
    |> Enum.sum()
  end
end

defmodule SecretNumbersPart2 do

  @mod 16_777_216  # 2^24

  @doc """
  Given a secret number, returns its 'next secret' by the pseudorandom evolution:
    1) multiply by 64, XOR, prune
    2) divide by 32 (floor), XOR, prune
    3) multiply by 2048, XOR, prune
  """
  def next_secret(secret) do
    # Step 1
    step1_val = secret * 64
    secret = Bitwise.bxor(secret, step1_val)
    secret = rem(secret, @mod)

    # Step 2
    step2_val = div(secret, 32)
    secret = Bitwise.bxor(secret, step2_val)
    secret = rem(secret, @mod)

    # Step 3
    step3_val = secret * 2048
    secret = Bitwise.bxor(secret, step3_val)
    secret = rem(secret, @mod)

    secret
  end

  @doc """
  Generates a list of 2001 secrets for one buyer:
    - the initial secret (index 0)
    - followed by 2000 evolved secrets
  """
  def generate_secrets(initial_secret, count \\ 2000) do
    # We'll do a reduce over 1..count to build up all secrets.
    # Another approach is a simple recursion or an Enum.scan.
    Enum.scan(1..count, initial_secret, fn _, acc -> next_secret(acc) end)
    # This scan only returns the new secrets, so we prepend the initial one:
    |> then(fn tail -> [initial_secret | tail] end)
  end

  @doc """
  From a list of secrets, map them to last-digit prices.
  If secret = 123, price = 3.
  """
  def secrets_to_prices(secrets) do
    Enum.map(secrets, &rem(&1, 10))
  end

  @doc """
  Given a list of prices p[0..n], returns the list of consecutive changes:
    c[i] = p[i+1] - p[i]
  So the result length is (n).
  """
  def price_changes(prices) do
    prices
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
  end

  @doc """
  For a single buyer (defined by its initial secret):
    1) Generate secrets (2001 total).
    2) Convert to prices (p[0..2000]).
    3) Generate changes (c[0..1999]).
    4) For each index i where i+3 < length(c), the 4-change subsequence is c[i..i+3].
       - The *first* time a pattern appears is the only time that matters for that buyer.
       - The selling price is p[i+4].
  Returns a map: pattern_4 -> sell_price_for_first_occurrence
  (If a pattern appears again, we ignore it; only the first occurrence matters.)
  """
  def patterns_for_buyer(initial_secret) do
    secrets = generate_secrets(initial_secret, 2000)
    prices = secrets_to_prices(secrets)
    changes = price_changes(prices)

    buyer_map = %{}

    # We'll iterate over i in [0..(2000 - 4)] inclusive
    # i.e. from 0 to 1996. But we'll just use 0..length(changes)-4
    last_change_index = length(changes) - 4

    Enum.reduce(0..last_change_index, buyer_map, fn i, acc ->
      # Extract the 4-change pattern
      pattern = {
        Enum.at(changes, i),
        Enum.at(changes, i + 1),
        Enum.at(changes, i + 2),
        Enum.at(changes, i + 3)
      }

      # If it's not in acc, store the *first occurrence* sell price
      # The sell price is prices[i+4].
      case Map.has_key?(acc, pattern) do
        true ->
          acc  # already found this pattern, do nothing
        false ->
          sell_price = Enum.at(prices, i + 4)
          Map.put(acc, pattern, sell_price)
      end
    end)
  end

  @doc """
  Merge the buyer-specific pattern->price maps into a global aggregator:
    pattern_4 -> sum_of_first_occurrence_prices_across_all_buyers
  """
  def merge_buyer_patterns(buyer_map, aggregator) do
    # For each pattern in buyer_map, add its price to the aggregator
    Enum.reduce(buyer_map, aggregator, fn {pattern, price}, acc ->
      Map.update(acc, pattern, price, &(&1 + price))
    end)
  end

  @doc """
  Reads initial secrets from file, computes for each buyer all first-occurrence
  4-change patterns. Aggregates them, then finds the pattern with the
  maximum total sell price. Prints the result.
  """
  def run(input) do
    # Read the initial secrets
    initial_secrets =
      input
      |> String.split("\n", trim: true)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&String.to_integer/1)

    # Build a global aggregator from all buyers
    aggregator =
      Enum.reduce(initial_secrets, %{}, fn secret, acc ->
        acc
        |> merge_buyer_patterns(patterns_for_buyer(secret))
      end)

    # The aggregator is now a map from {c1, c2, c3, c4} -> sum_of_prices.
    # We want the maximum sum_of_prices among all patterns.
    {best_pattern, best_sum} =
      aggregator
      |> Enum.max_by(fn {_pattern, sum} -> sum end, fn -> {nil, 0} end)

    IO.puts("Best 4-change pattern is: #{inspect(best_pattern)}")
    IO.puts("Maximum total bananas: #{best_sum}")
    best_sum
  end
end
