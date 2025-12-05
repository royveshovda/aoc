import AOC

aoc 2019, 22 do
  @moduledoc """
  https://adventofcode.com/2019/day/22

  Slam Shuffle - Card shuffling techniques as linear functions.

  Each technique is a linear function: f(x) = a*x + b (mod n)
  - deal into new stack: -x - 1 (mod n) → a=-1, b=-1
  - cut N: x - N (mod n) → a=1, b=-N
  - deal with increment N: x * N (mod n) → a=N, b=0

  Combining: f(g(x)) = a1*(a2*x + b2) + b1 = (a1*a2)*x + (a1*b2 + b1)
  """

  @deck_size 10007

  def p1(input) do
    instructions = parse(input)

    # Track where card 2019 ends up
    # Each instruction transforms position: new_pos = a * old_pos + b (mod n)
    {a, b} = combine_instructions(instructions, @deck_size)

    # Apply to position 2019
    mod(a * 2019 + b, @deck_size)
  end

  @deck_size_p2 119_315_717_514_047
  @shuffle_count 101_741_582_076_661

  def p2(input) do
    instructions = parse(input)
    n = @deck_size_p2
    times = @shuffle_count

    # Combine all instructions into single linear function
    {a, b} = combine_instructions(instructions, n)

    # Apply shuffle 'times' times: need to compute f^times(x)
    # f(x) = ax + b
    # f^2(x) = a(ax + b) + b = a²x + ab + b
    # f^k(x) = a^k * x + b * (a^(k-1) + a^(k-2) + ... + 1)
    #        = a^k * x + b * (a^k - 1) / (a - 1)

    a_k = mod_pow(a, times, n)

    # b_sum = b * (a^k - 1) / (a - 1) mod n
    # Need modular inverse of (a - 1)
    b_sum = mod(b * mod(a_k - 1, n) * mod_inv(a - 1, n), n)

    # Now we have combined function: f^k(x) = a_k * x + b_sum
    # Part 2 asks: what card is at position 2020?
    # We need to find x such that a_k * x + b_sum ≡ 2020 (mod n)
    # x ≡ (2020 - b_sum) * a_k^(-1) (mod n)

    mod((2020 - b_sum) * mod_inv(a_k, n), n)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction/1)
  end

  defp parse_instruction("deal into new stack"), do: {:new_stack}
  defp parse_instruction("cut " <> n), do: {:cut, String.to_integer(n)}
  defp parse_instruction("deal with increment " <> n), do: {:increment, String.to_integer(n)}

  # Combine instructions into single linear function (a, b) where f(x) = ax + b
  defp combine_instructions(instructions, n) do
    Enum.reduce(instructions, {1, 0}, fn instr, {a, b} ->
      {a2, b2} = instruction_to_linear(instr, n)
      # Compose: (a2 * x + b2) applied after (a * x + b)
      # = a2 * (a * x + b) + b2 = (a2 * a) * x + (a2 * b + b2)
      {mod(a2 * a, n), mod(a2 * b + b2, n)}
    end)
  end

  # Convert instruction to linear coefficients (a, b)
  defp instruction_to_linear({:new_stack}, n), do: {mod(-1, n), mod(-1, n)}
  defp instruction_to_linear({:cut, k}, n), do: {1, mod(-k, n)}
  defp instruction_to_linear({:increment, k}, _n), do: {k, 0}

  # Modular arithmetic helpers
  defp mod(x, n) when x >= 0, do: rem(x, n)
  defp mod(x, n), do: rem(rem(x, n) + n, n)

  # Modular exponentiation: a^k mod n
  defp mod_pow(_a, 0, _n), do: 1
  defp mod_pow(a, k, n) when rem(k, 2) == 0 do
    half = mod_pow(a, div(k, 2), n)
    mod(half * half, n)
  end
  defp mod_pow(a, k, n) do
    mod(a * mod_pow(a, k - 1, n), n)
  end

  # Modular inverse using extended Euclidean algorithm
  # a * a^(-1) ≡ 1 (mod n)
  defp mod_inv(a, n) do
    {g, x, _} = extended_gcd(mod(a, n), n)
    if g != 1, do: raise("No inverse exists")
    mod(x, n)
  end

  defp extended_gcd(0, b), do: {b, 0, 1}
  defp extended_gcd(a, b) do
    {g, x, y} = extended_gcd(rem(b, a), a)
    {g, y - div(b, a) * x, x}
  end
end
