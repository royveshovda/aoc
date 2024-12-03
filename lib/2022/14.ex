import AOC

aoc 2022, 14 do
  def p1(input) do
    state =
      input
      |> String.split("\n")
      |> Enum.reduce(%{}, &add_lines/2)

    run_it(state, 0)
  end

  def add_lines(line, state) do
    line |> String.split("->") |> Enum.chunk_every(2, 1) |> Enum.reduce(state, &add_segment/2)
  end

  def add_segment([start, dest], state) do
    [sx, sy] = start |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    [dx, dy] = dest|> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)

    if sx == dx do
      Enum.reduce(sy..dy, state, &Map.put(&2, {sx, &1}, "#"))
    else
      Enum.reduce(sx..dx, state, &Map.put(&2, {&1, sy}, "#"))
    end
  end

  def add_segment(_, state) do
    state
  end

  def run_it(state, count) do
    case place_sand(state) do
      # Part 2 end condition: we reached the source
      {true, %{{500, 0} => _}} -> count + 1

      # Placed sand
      {true, state} -> run_it(state, count + 1)

      # Part 1 end condition: this sand reached the end of the abyss
      {false, _state} -> count
    end
  end

  def place_sand(state, pos \\ {500, 0}) do
    case dest(pos, state) do
      {_, 1000} -> {false, state}
      nil -> {true, Map.put(state, pos, "o")}
      dest -> place_sand(state, dest)
    end
  end

  def dest({x, y}, state) do
    [{x, y + 1}, {x - 1, y + 1}, {x + 1, y + 1}]
      |> Enum.reject(&Map.has_key?state, &1)
      |> List.first()
  end

  def p2(input) do
    state =
      input
      |> String.split("\n")
      |> Enum.reduce(%{}, &add_lines/2)



    lowest = 2 + (state |> Map.keys |> Enum.map(&elem(&1,1)) |> Enum.max())
    state = Enum.reduce(499 - lowest..501 + lowest, state, &Map.put(&2, {&1, lowest}, "="))

    run_it(state, 0)
  end
end
