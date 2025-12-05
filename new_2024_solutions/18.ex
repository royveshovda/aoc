import AOC

aoc 2024, 18 do
  @moduledoc """
  https://adventofcode.com/2024/day/18

  RAM Run - grid with falling corrupted bytes.
  P1: BFS shortest path after N bytes fall.
  P2: Binary search to find first byte that blocks the path.
  """

  def p1({input, num_bytes, size}) do
    bytes = parse(input)
    blocked = bytes |> Enum.take(num_bytes) |> MapSet.new()
    bfs({0, 0}, {size, size}, blocked, size)
  end

  def p2({input, num_bytes, size}) do
    bytes = parse(input)

    # Binary search for first blocking byte
    idx = binary_search(bytes, num_bytes, length(bytes), size)
    {x, y} = Enum.at(bytes, idx)
    "#{x},#{y}"
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x, y] = String.split(line, ",") |> Enum.map(&String.to_integer/1)
      {x, y}
    end)
  end

  defp bfs(start, goal, blocked, size) do
    queue = :queue.from_list([{start, 0}])
    visited = MapSet.new([start])
    do_bfs(queue, goal, blocked, size, visited)
  end

  defp do_bfs(queue, goal, blocked, size, visited) do
    case :queue.out(queue) do
      {:empty, _} ->
        nil

      {{:value, {pos, dist}}, queue} ->
        if pos == goal do
          dist
        else
          {x, y} = pos
          neighbors = [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]

          {queue, visited} =
            Enum.reduce(neighbors, {queue, visited}, fn next, {q, v} ->
              {nx, ny} = next

              if nx >= 0 and nx <= size and ny >= 0 and ny <= size and
                   not MapSet.member?(blocked, next) and not MapSet.member?(v, next) do
                {:queue.in({next, dist + 1}, q), MapSet.put(v, next)}
              else
                {q, v}
              end
            end)

          do_bfs(queue, goal, blocked, size, visited)
        end
    end
  end

  defp binary_search(bytes, low, high, size) when low < high do
    mid = div(low + high, 2)
    blocked = bytes |> Enum.take(mid + 1) |> MapSet.new()

    if bfs({0, 0}, {size, size}, blocked, size) == nil do
      # Path blocked, try fewer bytes
      binary_search(bytes, low, mid, size)
    else
      # Path exists, try more bytes
      binary_search(bytes, mid + 1, high, size)
    end
  end

  defp binary_search(_bytes, low, _high, _size), do: low
end
