import AOC

aoc 2022, 25 do
  def p1(input) do
    input
    |> String.split("\n")
    |> Enum.map(&to_decimal(String.to_charlist(&1), 0))
    |> Enum.sum()
    |> to_snafu([])
  end

  def p2(input) do
    input
  end

  def to_decimal([], acc) do
    acc
  end

  @conv %{?2 => 2, ?1 => 1, ?0 => 0, ?- => -1, ?= => -2}

  def to_decimal([c | rest], acc) do
    to_decimal(rest, acc * 5 + @conv[c])
  end

  def to_snafu(0, sofar) do
    sofar
  end

  def to_snafu(num, sofar) do
    ones = rem(num, 5)
    rest = div(num, 5)
    case ones do
      0 -> to_snafu(rest, [?0 | sofar])
      1 -> to_snafu(rest, [?1 | sofar])
      2 -> to_snafu(rest, [?2 | sofar])
      3 -> to_snafu(rest + 1, [?= | sofar])
      4 -> to_snafu(rest + 1, [?- | sofar])
    end
  end
end
