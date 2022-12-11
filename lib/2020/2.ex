import AOC

aoc 2020, 2 do
  def p1(input) do
    input
    |> String.split("\n")
    |> Enum.map(&parse/1)
    |> Enum.filter(&valid?/1)
    |> Enum.count()
  end

  def valid?({min, max, char, password}) do
    count = password |> String.graphemes |> Enum.count(& &1 == char)
    count >= min and count <= max
  end

  def parse(line) do
    [range, char, password] = String.split(line, " ")
    [min, max] = String.split(range, "-")
    char = String.trim_trailing(char, ":")
    {String.to_integer(min), String.to_integer(max), char, password}
  end

  def p2(input) do
    input
    |> String.split("\n")
    |> Enum.map(&parse/1)
    |> Enum.filter(&valid2?/1)
    |> Enum.count()
  end

  def valid2?({pos1, pos2, char, password}) do
    [char1] = password |> String.graphemes |> Enum.slice(pos1 - 1, 1)
    [char2] = password |> String.graphemes |> Enum.slice(pos2 - 1, 1)
    (char1 == char and char2 != char) or (char1 != char and char2 == char)
  end
end
