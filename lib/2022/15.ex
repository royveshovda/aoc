import AOC

aoc 2022, 15 do
  def p1(input) do
    line_to_count = 2000000

    sensors =
      input
      |> String.split("\n")
      |> Enum.map(fn s -> String.split(s, ":", trim: true) end)
      |> Enum.map(fn [s1, s2] -> {String.trim_leading(s1, "Sensor at ") |> String.split(",", trim: true), String.trim_leading(s2, " closest beacon is at ") |> String.split(",", trim: true)} end)
      |> Enum.map(fn {[sx, sy], [bx, by]} ->
          {
            {String.trim_leading(sx, "x=") |> String.to_integer(), String.trim_leading(sy, " y=") |> String.to_integer()},
            {String.trim_leading(bx, "x=") |> String.to_integer(), String.trim_leading(by, " y=") |> String.to_integer()}
          } end)

    beacons =
      sensors
      |> Enum.map(fn {_s, b} -> b end)
      |> Enum.uniq()

    sensors
    |> Enum.flat_map(fn {s, b} -> expand({s, b}) end)
    |> Enum.uniq()
    |> Enum.filter(fn {_x,y} -> y == line_to_count end)
    |> Enum.filter(fn s -> not Enum.any?(beacons, fn pos -> pos == s end) end)
    |> Enum.count()

    #expand({{9, 16}, {10, 16}})
  end

  def expand({s = {sx,sy}, b}) do
    d = man(s,b)

    candidates = for x <- sx-d..sx+d, y <- sy-d..sy+d, do: {x,y}

    candidates
    |> Enum.filter(fn {x,y} -> man(s, {x,y}) <= d end)
  end

  def man({sx,sy}, {bx, by}) do
    abs(bx - sx) + abs(by - sy)
  end

  def p2(input) do
    input
  end
end
