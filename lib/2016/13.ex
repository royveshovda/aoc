import AOC

aoc 2016, 13 do
  @moduledoc """
  https://adventofcode.com/2016/day/13
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    favorite = String.trim(input) |> String.to_integer()
    bfs(favorite, {1, 1}, {31, 39})
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    favorite = String.trim(input) |> String.to_integer()
    count_reachable(favorite, {1, 1}, 50)
  end

  defp is_open?({x, y}, favorite) when x >= 0 and y >= 0 do
    value = x * x + 3 * x + 2 * x * y + y + y * y + favorite
    bits = Integer.digits(value, 2) |> Enum.sum()
    rem(bits, 2) == 0
  end
  defp is_open?(_, _), do: false

  defp neighbors({x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
  end

  defp bfs(favorite, start, goal) do
    queue = :queue.from_list([{start, 0}])
    visited = MapSet.new([start])
    bfs_loop(favorite, queue, visited, goal)
  end

  defp bfs_loop(favorite, queue, visited, goal) do
    case :queue.out(queue) do
      {{:value, {^goal, steps}}, _} -> steps
      {{:value, {pos, steps}}, queue} ->
        new_positions =
          neighbors(pos)
          |> Enum.filter(&is_open?(&1, favorite))
          |> Enum.reject(&MapSet.member?(visited, &1))

        new_queue = Enum.reduce(new_positions, queue, fn p, q -> :queue.in({p, steps + 1}, q) end)
        new_visited = Enum.reduce(new_positions, visited, &MapSet.put(&2, &1))

        bfs_loop(favorite, new_queue, new_visited, goal)
      {:empty, _} -> nil
    end
  end

  defp count_reachable(favorite, start, max_steps) do
    queue = :queue.from_list([{start, 0}])
    visited = MapSet.new([start])
    count_loop(favorite, queue, visited, max_steps)
  end

  defp count_loop(favorite, queue, visited, max_steps) do
    case :queue.out(queue) do
      {{:value, {pos, steps}}, queue} when steps < max_steps ->
        new_positions =
          neighbors(pos)
          |> Enum.filter(&is_open?(&1, favorite))
          |> Enum.reject(&MapSet.member?(visited, &1))

        new_queue = Enum.reduce(new_positions, queue, fn p, q -> :queue.in({p, steps + 1}, q) end)
        new_visited = Enum.reduce(new_positions, visited, &MapSet.put(&2, &1))

        count_loop(favorite, new_queue, new_visited, max_steps)
      {{:value, _}, queue} ->
        count_loop(favorite, queue, visited, max_steps)
      {:empty, _} -> MapSet.size(visited)
    end
  end
end
