import AOC

aoc 2016, 17 do
  @moduledoc """
  https://adventofcode.com/2016/day/17
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    passcode = String.trim(input)
    find_shortest_path(passcode)
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    passcode = String.trim(input)
    find_longest_path(passcode)
  end

  defp find_shortest_path(passcode) do
    queue = :queue.from_list([{{0, 0}, ""}])
    bfs_shortest(passcode, queue)
  end

  defp bfs_shortest(passcode, queue) do
    case :queue.out(queue) do
      {{:value, {{3, 3}, path}}, _} -> path
      {{:value, {pos, path}}, queue} ->
        new_states = get_next_states(passcode, pos, path)
        new_queue = Enum.reduce(new_states, queue, fn state, q -> :queue.in(state, q) end)
        bfs_shortest(passcode, new_queue)
      {:empty, _} -> nil
    end
  end

  defp find_longest_path(passcode) do
    queue = :queue.from_list([{{0, 0}, ""}])
    bfs_longest(passcode, queue, 0)
  end

  defp bfs_longest(passcode, queue, max_length) do
    case :queue.out(queue) do
      {{:value, {{3, 3}, path}}, queue} ->
        bfs_longest(passcode, queue, max(max_length, String.length(path)))
      {{:value, {pos, path}}, queue} ->
        new_states = get_next_states(passcode, pos, path)
        new_queue = Enum.reduce(new_states, queue, fn state, q -> :queue.in(state, q) end)
        bfs_longest(passcode, new_queue, max_length)
      {:empty, _} -> max_length
    end
  end

  defp get_next_states(passcode, {x, y}, path) do
    hash = :crypto.hash(:md5, passcode <> path) |> Base.encode16(case: :lower)
    [up, down, left, right] = String.slice(hash, 0, 4) |> String.graphemes()

    moves = [
      {up, {x, y - 1}, "U"},
      {down, {x, y + 1}, "D"},
      {left, {x - 1, y}, "L"},
      {right, {x + 1, y}, "R"}
    ]

    moves
    |> Enum.filter(fn {door, {nx, ny}, _} ->
      door in ["b", "c", "d", "e", "f"] and nx >= 0 and nx <= 3 and ny >= 0 and ny <= 3
    end)
    |> Enum.map(fn {_, pos, dir} -> {pos, path <> dir} end)
  end
end
