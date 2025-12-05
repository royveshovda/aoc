import AOC

aoc 2019, 8 do
  @moduledoc """
  https://adventofcode.com/2019/day/8
  """

  @width 25
  @height 6

  def p1(input) do
    layers = parse(input)

    layer = Enum.min_by(layers, fn layer ->
      Enum.count(layer, & &1 == 0)
    end)

    ones = Enum.count(layer, & &1 == 1)
    twos = Enum.count(layer, & &1 == 2)
    ones * twos
  end

  def p2(input) do
    layers = parse(input)

    # Composite all layers
    image =
      0..(@width * @height - 1)
      |> Enum.map(fn pos ->
        layers
        |> Enum.map(fn layer -> Enum.at(layer, pos) end)
        |> Enum.find(fn pixel -> pixel != 2 end)
      end)

    # Render image
    image
    |> Enum.chunk_every(@width)
    |> Enum.map(fn row ->
      row
      |> Enum.map(fn
        0 -> " "
        1 -> "#"
      end)
      |> Enum.join()
    end)
    |> Enum.join("\n")
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(@width * @height)
  end
end
