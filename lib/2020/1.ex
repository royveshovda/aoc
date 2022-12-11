import AOC

aoc 2020, 1 do
  def p1(input) do
    values =
      input
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)

    for i <- values, j <- values, i + j == 2020 do
      i * j
    end
    |> Enum.take(1)
    |> List.first()
  end

  def p2(input) do
    values =
      input
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)

    for i <- values, j <- values, k <- values, i + j + k == 2020 do
      i * j * k
    end
    |> Enum.take(1)
    |> List.first()
  end
end
