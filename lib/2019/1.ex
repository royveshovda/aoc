import AOC

aoc 2019, 1 do
  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&fuel/1)
    |> Enum.sum()
  end

  def fuel(mass) do
    mass
    |> div(3)
    |> fn x -> x - 2 end.()
  end

  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&fuel2/1)
    |> Enum.sum()
  end

  def fuel2(mass) do
    fuel = fuel(mass)
    if fuel <= 0 do
      0
    else
      fuel + fuel2(fuel)
    end
  end
end
