import AOC

aoc 2022, 25 do
  @moduledoc """
  Day 25: Full of Hot Air

  SNAFU number system (balanced base-5).
  Digits: 2, 1, 0, - (=-1), = (=-2)
  Convert sum of SNAFU numbers back to SNAFU.
  """

  @doc """
  Part 1: Sum of all SNAFU numbers, result in SNAFU format.

  ## Examples

      iex> example = \"\"\"
      ...> 1=-0-2
      ...> 12111
      ...> 2=0=
      ...> 21
      ...> 2=01
      ...> 111
      ...> 20012
      ...> 112
      ...> 1=-1=
      ...> 1-12
      ...> 12
      ...> 1=
      ...> 122
      ...> \"\"\"
      iex> Y2022.D25.p1(example)
      "2=-1=0"
  """
  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&snafu_to_decimal/1)
    |> Enum.sum()
    |> decimal_to_snafu()
  end

  @doc """
  Part 2: Day 25 has no Part 2 - it's the final day reward.

  ## Examples

      iex> Y2022.D25.p2("")
      :star
  """
  def p2(_input) do
    :star
  end

  @snafu_digits %{?2 => 2, ?1 => 1, ?0 => 0, ?- => -1, ?= => -2}

  defp snafu_to_decimal(str) do
    str
    |> String.to_charlist()
    |> Enum.reduce(0, fn char, acc ->
      acc * 5 + @snafu_digits[char]
    end)
  end

  defp decimal_to_snafu(0), do: "0"

  defp decimal_to_snafu(num) do
    do_decimal_to_snafu(num, [])
  end

  defp do_decimal_to_snafu(0, acc), do: to_string(acc)

  defp do_decimal_to_snafu(num, acc) do
    remainder = rem(num, 5)
    quotient = div(num, 5)

    {digit, carry} =
      case remainder do
        0 -> {?0, 0}
        1 -> {?1, 0}
        2 -> {?2, 0}
        3 -> {?=, 1}
        4 -> {?-, 1}
      end

    do_decimal_to_snafu(quotient + carry, [digit | acc])
  end
end
