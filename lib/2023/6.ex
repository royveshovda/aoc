import AOC

aoc 2023, 6 do
  @moduledoc """
  https://adventofcode.com/2023/day/6
  """

  @doc """
      iex> p1(example_string())
      288

      iex> p1(input_string())
      4568778
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(fn %{time: time, distance: distance} ->

      run_game(time, distance)
    end)
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  @doc """
      iex> p2(example_string())
      71503

      iex> p2(input_string())
      28973936
  """
  def p2(input) do
    {time, distance} = parse_p2(input)
    run_game(time, distance)
  end

  def run_game(time, distance) do
    1..time
    |> Enum.map(fn t ->
      run_time(t, time)
    end)
    |> Enum.filter(fn d-> d > distance end)
    |> Enum.count()
  end

  def run_time(time_pressed, max_time) do
    speed = time_pressed
    race_time = max_time - time_pressed
    race_time * speed
  end

  def parse(input) do
    [times_r, distances_r] = String.split(input, "\n", trim: true)
    [_, times_s] = String.split(times_r, ":", trim: true)
    times = String.split(times_s, " ", trim: true) |> Enum.map(&String.to_integer/1)

    [_, distances_s] = String.split(distances_r, ":", trim: true)
    distances = String.split(distances_s, " ", trim: true) |> Enum.map(&String.to_integer/1)

    Enum.zip(times, distances)
    |> Enum.map(fn {time, distance} ->
      %{time: time, distance: distance}
    end)
  end

  def parse_p2(input) do
    [times_r, distances_r] = String.split(input, "\n", trim: true)
    [times_r, distances_r]
    [_, times_s] = String.split(times_r, ":", trim: true)
    time = String.replace(times_s, " ", "") |> String.to_integer()

    [_, distances_s] = String.split(distances_r, ":", trim: true)
    distance = String.replace(distances_s, " ", "") |> String.to_integer()

    {time, distance}
  end
end
