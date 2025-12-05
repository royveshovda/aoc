import AOC

aoc 2024, 22 do
  @moduledoc """
  https://adventofcode.com/2024/day/22
  """

  def p1(input) do
    SecretNumbers.run(input)
  end

  def p2(input) do
    SecretNumbersPart2Optimized.run(input)
  end
end

defmodule SecretNumbers do
  @moduledoc """
  Solution for Part 1 of 2024 Day 22.
  """

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

defmodule SecretNumbersPart2Optimized do
  @moduledoc """
  Solution for Part 2 of 2024 Day 22.
  """

  @mod 16_777_216  # 2^24
  @steps 2000      # Each buyer generates 2000 new secret numbers

  @doc """
  Given a secret number, evolves it into the "next secret" via:
    1) multiply by 64, XOR, prune
    2) integer divide by 32, XOR, prune
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
  Given an initial secret, returns a map of:
    4-change-pattern -> first selling price
  for the first occurrence of each 4-change pattern in the next 2000 steps.

  We do this in a streaming/on-the-fly manner:
    - Keep track of the last price (rem(secret,10))
    - Each new secret yields a new price
    - The difference (new_price - old_price) is a new change
    - Accumulate changes in a 4-change queue
    - When the queue has 4 changes, record the pattern -> current price
      (the "sell price" is the price immediately after those 4 changes)

  We only record the *first* occurrence of any 4-change pattern for this buyer.
  """
  def patterns_for_buyer_on_the_fly(initial_secret, steps \\ @steps) do
    # State structure
    state = %{
      current_secret: initial_secret,    # last generated secret
      last_price: rem(initial_secret, 10),
      changes_queue: [],                 # list of length <= 4
      pattern_map: %{}                  # pattern -> sell_price
    }

    # We'll iterate exactly 'steps' times for new secrets
    final_state =
      Enum.reduce(1..steps, state, fn _, st ->
        new_secret = next_secret(st.current_secret)
        new_price = rem(new_secret, 10)
        change = new_price - st.last_price

        changes_queue = (st.changes_queue ++ [change]) |> Enum.take(-4)

        # If we have exactly 4 changes, build a pattern (4-tuple)
        # and record the "sell price" for the pattern if not seen before.
        updated_pattern_map =
          if length(changes_queue) == 4 do
            pattern = List.to_tuple(changes_queue)

            # The "sell price" is the price *after* these 4 changes,
            # which is the new_price right now.
            Map.update(st.pattern_map, pattern, new_price, & &1)
            # (Map.update won't overwrite an existing key, we want the first occurrence only)
          else
            st.pattern_map
          end

        %{
          st
          | current_secret: new_secret,
            last_price: new_price,
            changes_queue: changes_queue,
            pattern_map: updated_pattern_map
        }
      end)

    final_state.pattern_map
  end

  @doc """
  Merges one buyer's pattern map into the global aggregator:
    aggregator[pattern] += buyer_map[pattern]
  """
  def merge_buyer_patterns(buyer_map, aggregator) do
    Enum.reduce(buyer_map, aggregator, fn {pattern, price}, acc ->
      Map.update(acc, pattern, price, &(&1 + price))
    end)
  end

  @doc """
  Main entry point. Reads initial secrets from file, processes each buyer *concurrently*,
  and merges all pattern maps into a global aggregator. Finds and prints the pattern with
  the highest total selling price.
  """
  def run(input) do
    # 1) Read all initial secrets
    initial_secrets =
      input
      |> String.split("\n", trim: true)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&String.to_integer/1)

    # 2) For each secret, spawn a Task to compute patterns_on_the_fly
    tasks =
      Enum.map(initial_secrets, fn secret ->
        Task.async(fn -> patterns_for_buyer_on_the_fly(secret) end)
      end)

    # 3) Await all tasks, producing a list of buyer maps
    buyer_maps = Enum.map(tasks, &Task.await/1)

    # 4) Merge all buyer maps into one aggregator
    aggregator =
      Enum.reduce(buyer_maps, %{}, fn buyer_map, acc ->
        merge_buyer_patterns(buyer_map, acc)
      end)

    # 5) Find the pattern with the maximum total price
    {_best_pattern, best_sum} =
      aggregator
      |> Enum.max_by(fn {_pattern, sum} -> sum end, fn -> {nil, 0} end)
    best_sum
  end
end
