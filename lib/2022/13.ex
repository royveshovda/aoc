import AOC

aoc 2022, 13 do
  def p1(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n"))
    |> Enum.with_index(1)
    |> Enum.map(fn {[part1, part2], i} ->
                            {l1, []} = Code.eval_string(part1)
                            {l2, []} = Code.eval_string(part2)
                            {l1, l2, i} end)
    |> Enum.map(fn {l1, l2, i} -> {compare(l1, l2), i}  end)
    |> Enum.filter(fn {x, _} -> x >= 0 end)
    |> Enum.map(fn {_, i} -> i end)
    |> Enum.sum()
  end

  def p2(input) do
    marker1 = [[2]]
    marker2 = [[6]]

    sorted =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn x ->
                  {l, []} = Code.eval_string(x)
                  l
                end)
      |> Enum.concat([marker1, marker2])
      |> Enum.sort(&(compare(&1, &2) > 0))
      |> Enum.with_index(1)
      |> Map.new()

    sorted[marker1] * sorted[marker2]
  end

  def compare([], []) do
    0
  end

  def compare([], [_ | _]) do
    1
  end

  def compare([_ | _], []) do
    -1
  end

  def compare([xh | xt], [yh | yt]) do
    case compare(xh, yh) do
      0 -> compare(xt, yt)
      other -> other
    end
  end

  def compare(x, y) when is_integer(x) and is_integer(y) do
    y - x
  end

  def compare(x, y) when is_integer(x) and is_list(y) do
    compare([x], y)
  end

  def compare(x, y) when is_integer(y) and is_list(x) do
    compare(x, [y])
  end
end
