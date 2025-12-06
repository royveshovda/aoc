import AOC

aoc 2021, 20 do
  @moduledoc """
  Day 20: Trench Map

  Image enhancement algorithm using 3x3 neighborhoods as index into 512-char lookup.
  Gotcha: If index 0 maps to #, infinite space flickers!
  """

  @doc """
  Part 1: Apply enhancement twice, count lit pixels.
  """
  def p1(input) do
    {algorithm, image} = parse(input)

    image
    |> enhance(algorithm, 2)
    |> count_lit()
  end

  @doc """
  Part 2: Apply enhancement 50 times, count lit pixels.
  """
  def p2(input) do
    {algorithm, image} = parse(input)

    image
    |> enhance(algorithm, 50)
    |> count_lit()
  end

  defp enhance(image, algorithm, times) do
    # Initial infinite space is dark (0)
    Enum.reduce(1..times, {image, 0}, fn _, {img, default} ->
      {enhance_step(img, algorithm, default), next_default(algorithm, default)}
    end)
    |> elem(0)
  end

  defp enhance_step(image, algorithm, default) do
    # Expand bounds by 1 in each direction
    {min_x, max_x} = image |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    {min_y, max_y} = image |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.min_max()

    for x <- (min_x - 1)..(max_x + 1),
        y <- (min_y - 1)..(max_y + 1),
        into: %{} do
      index = neighborhood_index(image, x, y, default)
      value = String.at(algorithm, index)
      {{x, y}, if(value == "#", do: 1, else: 0)}
    end
  end

  defp neighborhood_index(image, x, y, default) do
    bits =
      for dy <- -1..1, dx <- -1..1 do
        Map.get(image, {x + dx, y + dy}, default)
      end

    bits |> Integer.undigits(2)
  end

  defp next_default(algorithm, current_default) do
    # If current default is 0, look at index 0 of algorithm
    # If current default is 1, look at index 511 (all 1s) of algorithm
    index = if current_default == 0, do: 0, else: 511
    if String.at(algorithm, index) == "#", do: 1, else: 0
  end

  defp count_lit(image) do
    image |> Map.values() |> Enum.sum()
  end

  defp parse(input) do
    [algorithm_line, image_section] = String.split(input, "\n\n", trim: true)

    algorithm = String.replace(algorithm_line, "\n", "")

    image =
      image_section
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {char, x} ->
          {{x, y}, if(char == "#", do: 1, else: 0)}
        end)
      end)
      |> Map.new()

    {algorithm, image}
  end
end
