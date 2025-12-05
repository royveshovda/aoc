import AOC

aoc 2019, 16 do
  @moduledoc """
  https://adventofcode.com/2019/day/16
  Flawed Frequency Transmission - FFT signal processing
  """

  @base_pattern [0, 1, 0, -1]

  def p1(input) do
    digits = parse(input)

    1..100
    |> Enum.reduce(digits, fn _, acc -> fft_phase(acc) end)
    |> Enum.take(8)
    |> Enum.join()
  end

  def p2(input) do
    digits = parse(input)
    len = length(digits)

    # The message offset is the first 7 digits
    offset =
      digits
      |> Enum.take(7)
      |> Integer.undigits()

    # Full signal is input repeated 10000 times
    total_len = len * 10000

    # Key insight: The offset is in the second half of the signal
    # For positions >= total_len/2, the pattern is all 1s from that position onward
    # So each digit = sum of all digits from that position to end (mod 10)
    # We can compute this efficiently by cumulative sum from the end

    # We only need digits from offset to end
    needed_len = total_len - offset

    # Build the relevant portion of the repeated signal
    signal =
      Stream.cycle(digits)
      |> Stream.drop(rem(offset, len))
      |> Enum.take(needed_len)

    # Apply 100 phases with the optimized algorithm
    1..100
    |> Enum.reduce(signal, fn _, acc -> fast_phase(acc) end)
    |> Enum.take(8)
    |> Enum.join()
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  # Full FFT phase (for part 1)
  defp fft_phase(digits) do
    len = length(digits)

    0..(len - 1)
    |> Enum.map(fn pos ->
      pattern = build_pattern(pos, len)

      digits
      |> Enum.zip(pattern)
      |> Enum.map(fn {d, p} -> d * p end)
      |> Enum.sum()
      |> abs()
      |> rem(10)
    end)
  end

  defp build_pattern(pos, len) do
    @base_pattern
    |> Enum.flat_map(fn p -> List.duplicate(p, pos + 1) end)
    |> Stream.cycle()
    |> Stream.drop(1)
    |> Enum.take(len)
  end

  # Fast phase for part 2 (when offset is in second half)
  # Each digit[i] = sum(digit[i..end]) mod 10
  # Computed as cumulative sum from the end
  defp fast_phase(digits) do
    digits
    |> Enum.reverse()
    |> Enum.scan(0, fn d, acc -> rem(d + acc, 10) end)
    |> Enum.reverse()
  end
end
