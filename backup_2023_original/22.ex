import AOC

aoc 2023, 22 do
  @moduledoc """
  https://adventofcode.com/2023/day/22

  Using: https://www.reddit.com/r/adventofcode/comments/18o7014/comment/keh27wj/?utm_source=share&utm_medium=web2x&context=3
  """

  @doc """
      iex> p1(example_string())
      5

      iex> p1(input_string())
      437
  """
  def p1(input) do
    puzzle_bricks = parse(input)  # puzzle input is just split by lines
    {_, puzzle_bricks_fallen} = puzzle_bricks |> fall()

    total_fallen_bricks =
      puzzle_bricks_fallen
      |> Enum.map(fn brick ->
        List.delete(puzzle_bricks_fallen, brick) |> fall() |> elem(0)
      end)

    total_fallen_bricks |> Enum.count(& &1 == 0)
    # %{
    #   part1: total_fallen_bricks |> Enum.count(& &1 == 0),
    #   part2: total_fallen_bricks |> Enum.sum()
    # }
  end

  @doc """
      iex> p2(example_string())
      7

      iex> p2(input_string())
      42561
  """
  def p2(input) do
    puzzle_bricks = parse(input)  # puzzle input is just split by lines
    {_, puzzle_bricks_fallen} = puzzle_bricks |> fall()

    total_fallen_bricks =
      puzzle_bricks_fallen
      |> Enum.map(fn brick ->
        List.delete(puzzle_bricks_fallen, brick) |> fall() |> elem(0)
      end)

    total_fallen_bricks |> Enum.sum()
  end

  def parse_input(input) do
    input
    |> String.split("\n")
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Stream.map(&get_brick/1)
    |> sort_by_z
  end

  def get_brick(position) do
    [xs, ys, zs, xe, ye, ze] =
      Regex.run(~r/(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)/, position, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    Enum.zip([xs, ys, zs], [xe, ye, ze])
    |> Enum.map(fn {start, stop} -> min(start, stop)..max(start, stop) |> Range.to_list() end)
    |> then(fn [xx, yy, zz] ->
      for x <- xx, y <- yy, z <- zz, do: {x, y, z}
    end)
  end

  def sort_by_z(bricks),
    do:
      bricks
      |> Enum.sort_by(
        fn brick ->
          brick |> Stream.map(&elem(&1, 2)) |> Enum.min()
        end,
        :asc
      )

  def z_span(brick), do: brick |> Stream.map(&elem(&1, 2)) |> Enum.min_max()

  def bottom(brick),
    do: Enum.filter(brick, fn {_, _, z} -> z == z_span(brick) |> elem(0) end)

  def fall(bricks, z_levels \\ %{}, fallen \\ [], num_fallen \\ 0)

  def fall([], _, fallen, num_fallen), do: {num_fallen, fallen |> sort_by_z()}

  def fall([brick | bricks], z_levels, fallen, num_fallen) do
    fall_distance =
      brick
      |> bottom
      |> Enum.map(fn
        {x, y, z} ->
          z - Map.get(z_levels, {x, y}, 0) - 1
      end)
      |> Enum.min()

    one_more_brick = if fall_distance > 0, do: 1, else: 0

    brick_fell = Enum.map(brick, fn {x, y, z} -> {x, y, z - fall_distance} end)

    z_levels =
      brick_fell
      |> Enum.reduce(z_levels, fn
        {x, y, z}, levels -> Map.put(levels, {x, y}, z)
      end)

    fall(bricks, z_levels, [brick_fell | fallen], num_fallen + one_more_brick)
  end
end
