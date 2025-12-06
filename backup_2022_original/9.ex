import AOC

aoc 2022, 9 do
  def p1(input) do
    solve(input, 1)
  end

  def p2(input) do
    solve(input, 9)
  end

  def solve(i, idx) do
    i
    |> String.split("\n", trim: true)
    |> Enum.map(fn s -> String.split(s, " ") end)
    |> Enum.map(&read/1)
    |> Enum.flat_map(fn {dir, count} -> List.duplicate(dir, count) end)
    |> Enum.scan({0, 0}, &move_head/2)
    |> Stream.iterate(fn prev -> Enum.scan(prev, {0, 0}, &move_tail/2) end)
    |> Enum.at(idx)
    |> Enum.uniq()
    |> Enum.count()
  end

  def read(["R", steps]), do: {:right, String.to_integer(steps)}
  def read(["U", steps]), do: {:up, String.to_integer(steps)}
  def read(["L", steps]), do: {:left, String.to_integer(steps)}
  def read(["D", steps]), do: {:down, String.to_integer(steps)}

  def move_head(:right, {x, y}), do: {x + 1, y}
  def move_head(:left, {x, y}), do: {x - 1, y}
  def move_head(:up, {x, y}), do: {x, y + 1}
  def move_head(:down, {x, y}), do: {x, y - 1}

  def move_tail(h, t), do: if(adjacent?(h, t), do: t, else: do_move_tail(h, t))
  def adjacent?({hx, hy}, {tx, ty}), do: tx in (hx - 1)..(hx + 1) and ty in (hy - 1)..(hy + 1)

  def do_move_tail({hx, hy} = h, {tx, ty} = t) do
    if hx == tx or hy == ty do
      h |> vert_horiz_moves() |> Enum.find(&adjacent?(t, &1))
    else
      t |> diag_moves() |> Enum.find(&adjacent?(h, &1))
    end
  end

  def vert_horiz_moves({x, y}), do: [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
  def diag_moves({x, y}), do: [{x - 1, y + 1}, {x + 1, y + 1}, {x - 1, y - 1}, {x + 1, y - 1}]
end
