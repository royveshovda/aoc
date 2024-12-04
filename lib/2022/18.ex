import AOC

aoc 2022, 18 do
  def p1(input) do
    pieces =
      input
      |> String.split("\n")
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(fn l -> Enum.map(l, fn i -> String.to_integer(i) end) end)
      |> Enum.map(fn [x, y, z] -> {x, y, z} end)
      |> MapSet.new()

    pieces
    |> Enum.map(fn p -> free_sides(p, pieces) end)
    |> Enum.sum()
  end

  def free_sides({x, y, z}, pieces) do
    [
      {x - 1, y, z},
      {x + 1, y, z},
      {x, y - 1, z},
      {x , y + 1, z},
      {x, y, z - 1},
      {x, y, z + 1}
    ]
    |> Enum.reject(fn p -> Enum.any?(pieces, fn v -> v == p end) end)
    |> Enum.count()
  end

  def p2(input) do
    pieces =
      input
      |> String.split("\n")
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(fn l -> Enum.map(l, fn i -> String.to_integer(i) end) end)
      |> Enum.map(fn [x, y, z] -> {x, y, z} end)
      |> MapSet.new()

    # Set search space just outside the pieces
    {x_min, x_max} = Enum.map(pieces, fn {x, _y, _z} -> x end) |> Enum.min_max()
    x_min = x_min - 1
    x_max = x_max + 1
    {y_min, y_max} = Enum.map(pieces, fn {_x,  y , _z} -> y end) |> Enum.min_max()
    y_min = y_min - 1
    y_max = y_max + 1
    {z_min, z_max} = Enum.map(pieces, fn {_x, _y, z} -> z end) |> Enum.min_max()
    z_min = z_min - 1
    z_max = z_max + 1

    start = {x_min, y_min, z_min}

    outside = bfs(MapSet.new([start]), :queue.in(start, :queue.new()), pieces, x_min..x_max, y_min..y_max, z_min..z_max)

    pieces
    |> Enum.map(fn point -> Enum.count(next(point, &MapSet.member?(outside, &1))) end)
    |> Enum.sum()
  end

  def bfs(found, queue, lava, xbounds, ybounds, zbounds) do
    case :queue.out(queue) do
      {{:value, point}, queue} ->
        newfound = next(point, &(not MapSet.member?(lava, &1) and not MapSet.member?(found, &1) and in_bounds(&1, xbounds, ybounds, zbounds)))
        queue = Enum.reduce(newfound, queue, &:queue.in/2)
        found = Enum.reduce(newfound, found, &MapSet.put(&2, &1))
        bfs(found, queue, lava, xbounds, ybounds, zbounds)

      {:empty, _queue} -> found
    end
  end

  def next({x, y, z}, pieces) do
    [
      {x - 1, y, z},
      {x + 1, y, z},
      {x, y - 1, z},
      {x, y + 1, z},
      {x, y, z - 1},
      {x, y, z + 1}
    ]
    |> Enum.filter(pieces)
  end

  def in_bounds({x, y, z}, xbounds, ybounds, zbounds) do
    x in xbounds and y in ybounds and z in zbounds
  end
end
