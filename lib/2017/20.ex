import AOC

aoc 2017, 20 do
  @moduledoc """
  https://adventofcode.com/2017/day/20
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    parse(input) |> Enum.with_index() |> Enum.min_by(fn {{p, v, a}, _idx} ->
      {manhattan(a), manhattan(v), manhattan(p)}
    end) |> elem(1)
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    particles = parse(input) |> Enum.with_index() |> Map.new(fn {pvr, i} -> {i, pvr} end)
    simulate_collisions(particles, 0)
  end

  defp parse(input) do
    input |> String.trim() |> String.split("\n") |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    Regex.scan(~r/<([^>]+)>/, line, capture: :all_but_first)
    |> Enum.map(fn [coords] ->
      coords |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    end)
    |> List.to_tuple()
  end

  defp manhattan({x, y, z}), do: abs(x) + abs(y) + abs(z)

  defp simulate_collisions(particles, tick) when tick > 100, do: map_size(particles)
  defp simulate_collisions(particles, tick) do
    updated = Map.new(particles, fn {id, {{px, py, pz}, {vx, vy, vz}, {ax, ay, az}}} ->
      new_v = {vx + ax, vy + ay, vz + az}
      {nvx, nvy, nvz} = new_v
      {id, {{px + nvx, py + nvy, pz + nvz}, new_v, {ax, ay, az}}}
    end)
    by_position = Enum.group_by(updated, fn {_id, {pos, _v, _a}} -> pos end)
    colliding = by_position |> Enum.filter(fn {_pos, ps} -> length(ps) > 1 end)
    |> Enum.flat_map(fn {_pos, ps} -> Enum.map(ps, &elem(&1, 0)) end) |> MapSet.new()
    remaining = Map.drop(updated, MapSet.to_list(colliding))
    # Increment tick if no collisions, reset if there were collisions
    new_tick = if map_size(remaining) == map_size(particles), do: tick + 1, else: 0
    simulate_collisions(remaining, new_tick)
  end
end
