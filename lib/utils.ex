defmodule Utils do
  @moduledoc false
  defmodule Grid do
    @moduledoc false
    def bounds(grid) do
      coords = Map.keys(grid)
      {min_x, max_x} = coords |> Enum.map(fn {x, _} -> x end) |> Enum.min_max()
      {min_y, max_y} = coords |> Enum.map(fn {_, y} -> y end) |> Enum.min_max()
      {min_x..max_x, min_y..max_y}
    end

    def input_to_map(input, parse_el \\ &Function.identity/1) do
      input
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {el, x} -> {{x, y}, parse_el.(el)} end)
      end)
      |> Map.new()
    end

    def input_to_map_with_bounds(input, parse_el \\ &Function.identity/1) do
      grid = input_to_map(input, parse_el)
      {grid, bounds(grid)}
    end

    def input_to_map_with_limits(input, parse_el \\ &Function.identity/1) do
      grid = input_to_map(input, parse_el)
      {min_x..max_x//1, min_y..max_y//1} = bounds(grid)
      {grid, {min_x, max_x, min_y, max_y}}
    end
  end
end
