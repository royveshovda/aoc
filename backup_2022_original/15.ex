import AOC

require Logger

aoc 2022, 15 do
  def p1(input) do
    #line_to_count = 10
    line_to_count = 2_000_000

    data =
      input
      |> String.split("\n")
      |> Enum.map(fn s -> String.split(s, ":", trim: true) end)
      |> Enum.map(fn [s1, s2] -> {String.trim_leading(s1, "Sensor at ") |> String.split(",", trim: true), String.trim_leading(s2, " closest beacon is at ") |> String.split(",", trim: true)} end)
      |> Enum.map(fn {[sx, sy], [bx, by]} ->
          {
            {String.trim_leading(sx, "x=") |> String.to_integer(), String.trim_leading(sy, " y=") |> String.to_integer()},
            {String.trim_leading(bx, "x=") |> String.to_integer(), String.trim_leading(by, " y=") |> String.to_integer()}
          } end)
      |> Enum.map(fn {{sx, sy}, {bx, by}} -> {{{sx, sy}, abs(bx - sx) + abs(by - sy)}, {bx, by}} end)

    exclusions = Enum.map(data, &elem(&1, 0))

    beacons = MapSet.new(Enum.map(data, &elem(&1, 1)))

    rejected =
      Enum.reduce(exclusions, MapSet.new(), fn {start, distance}, rejected ->
        add_rejects(start, distance, rejected, line_to_count)
      end)

    MapSet.difference(rejected, beacons) |> Enum.count()
  end

  def add_rejects({sx, sy}, distance, rejected, target_y) do
    dy = abs(target_y - sy)
    offset = distance - dy
    Logger.info("#{inspect({sx, sy, distance, offset})}")

    if offset < 0 do
      rejected
    else
      Enum.reduce((sx - offset)..(sx + offset), rejected, &MapSet.put(&2, {&1, target_y}))
    end
  end


  def p2(input) do
    data =
      input
      |> String.split("\n")
      |> Enum.map(fn s -> String.split(s, ":", trim: true) end)
      |> Enum.map(fn [s1, s2] -> {String.trim_leading(s1, "Sensor at ") |> String.split(",", trim: true), String.trim_leading(s2, " closest beacon is at ") |> String.split(",", trim: true)} end)
      |> Enum.map(fn {[sx, sy], [bx, by]} ->
          {
            {String.trim_leading(sx, "x=") |> String.to_integer(), String.trim_leading(sy, " y=") |> String.to_integer()},
            {String.trim_leading(bx, "x=") |> String.to_integer(), String.trim_leading(by, " y=") |> String.to_integer()}
          } end)
      |> Enum.map(fn {{sx, sy}, {bx, by}} -> {{{sx, sy}, abs(bx - sx) + abs(by - sy)}, {bx, by}} end)

    exclusions = Enum.map(data, &elem(&1, 0))

    #max_y = 20
    max_y = 4_000_000

    {x, y} =
      Enum.map(0..max_y, &check(&1, exclusions, max_y))
      |> Enum.reject(&is_nil/1)
      |> List.first()

    x * 4_000_000 + y
  end

  def check(y, exclusions, max_y) do
    ret = Enum.reduce(exclusions, [{0, max_y}], &remove_slice(&2, to_slice(&1, y)))

    if ret != [] do
      [{x, x}] = ret
      {x, y}
    else
      :nil
    end
  end

  def remove_slice(ranges, nil) do
    ranges
  end

  def remove_slice([], _) do
    []
  end

  def remove_slice(ranges, {low, high}) do
    Enum.map(ranges, fn {range_low, range_high} = range ->
      cond do
        low > range_high or high < range_low ->
          [range]

        high >= range_high and low <= range_low ->
          []

        high >= range_high ->
          [{range_low, low - 1}]

        low <= range_low ->
          [{high + 1, range_high}]

        true ->
          [{range_low, low - 1}, {high + 1, range_high}]
      end
    end)
    |> Enum.concat()
  end

  def to_slice({{sx, sy}, distance}, y) do
    dy = abs(y - sy)
    offset = distance - dy

    if offset < 0 do
      nil
    else
      {sx - offset, sx + offset}
    end
  end
end
