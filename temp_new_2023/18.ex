import AOC

aoc 2023, 18 do
  @moduledoc """
  https://adventofcode.com/2023/day/18

  Dig a trench and calculate total area (Shoelace + Pick's theorem).
  """

  @doc """
      iex> p1(example_string())
      62

      iex> p1(input_string())
      56923
  """
  def p1(input) do
    input
    |> parse_p1()
    |> calculate_area()
  end

  @doc """
      iex> p2(example_string())
      952408144115

      iex> p2(input_string())
      66296566363189
  """
  def p2(input) do
    input
    |> parse_p2()
    |> calculate_area()
  end

  defp parse_p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [dir, dist, _] = String.split(line, " ")
      {parse_dir(dir), String.to_integer(dist)}
    end)
  end

  defp parse_p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, _, hex] = String.split(line, " ")
      # (#70c710) -> distance from first 5 hex digits, direction from last digit
      hex = String.trim(hex, "(#") |> String.trim(")")
      dist = String.slice(hex, 0, 5) |> String.to_integer(16)
      dir = case String.at(hex, 5) do
        "0" -> :R
        "1" -> :D
        "2" -> :L
        "3" -> :U
      end
      {dir, dist}
    end)
  end

  defp parse_dir("R"), do: :R
  defp parse_dir("L"), do: :L
  defp parse_dir("U"), do: :U
  defp parse_dir("D"), do: :D

  defp calculate_area(instructions) do
    # Build polygon vertices
    {vertices, perimeter} = build_polygon(instructions)

    # Shoelace formula for interior area
    interior = shoelace(vertices)

    # Pick's theorem: A = i + b/2 - 1, so i = A - b/2 + 1
    # Total area = interior points + boundary points = i + b
    # = (A - b/2 + 1) + b = A + b/2 + 1
    abs(interior) + div(perimeter, 2) + 1
  end

  defp build_polygon(instructions) do
    {vertices, _, perimeter} =
      Enum.reduce(instructions, {[{0, 0}], {0, 0}, 0}, fn {dir, dist}, {verts, {r, c}, perim} ->
        {dr, dc} = delta(dir)
        new_pos = {r + dr * dist, c + dc * dist}
        {[new_pos | verts], new_pos, perim + dist}
      end)

    {Enum.reverse(vertices), perimeter}
  end

  defp delta(:U), do: {-1, 0}
  defp delta(:D), do: {1, 0}
  defp delta(:L), do: {0, -1}
  defp delta(:R), do: {0, 1}

  defp shoelace(vertices) do
    vertices
    |> Enum.chunk_every(2, 1, Enum.take(vertices, 1))
    |> Enum.reduce(0, fn [{r1, c1}, {r2, c2}], acc ->
      acc + (r1 * c2 - r2 * c1)
    end)
    |> div(2)
  end
end
