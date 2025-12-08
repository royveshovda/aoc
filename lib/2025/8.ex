import AOC

aoc 2025, 8 do
  @moduledoc """
  https://adventofcode.com/2025/day/8
  """

  @doc """
      iex> p1(example_string(0))
      40
  """
  def p1(input) do
    coords = parse(input)
    n = map_size(coords)
    limit = if n < 100, do: 10, else: 1000

    pairs =
      for i <- 0..(n - 2),
          j <- (i + 1)..(n - 1) do
        {dist_sq(coords[i], coords[j]), i, j}
      end

    top_pairs =
      pairs
      |> Enum.sort()
      |> Enum.take(limit)

    # Build graph
    graph =
      Enum.reduce(top_pairs, %{}, fn {_, u, v}, acc ->
        acc
        |> Map.update(u, [v], &[v | &1])
        |> Map.update(v, [u], &[u | &1])
      end)

    # Find components
    {sizes, _} =
      Enum.reduce(0..(n - 1), {[], MapSet.new()}, fn i, {sizes, visited} ->
        if MapSet.member?(visited, i) do
          {sizes, visited}
        else
          {size, visited} = bfs(i, graph, visited)
          {[size | sizes], visited}
        end
      end)

    sizes
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Map.new(fn {line, idx} ->
      [x, y, z] =
        line
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)

      {idx, {x, y, z}}
    end)
  end

  def dist_sq({x1, y1, z1}, {x2, y2, z2}) do
    (x1 - x2) ** 2 + (y1 - y2) ** 2 + (z1 - z2) ** 2
  end

  def bfs(start_node, graph, visited) do
    queue = :queue.from_list([start_node])
    visited = MapSet.put(visited, start_node)
    do_bfs(queue, graph, visited, 1)
  end

  defp do_bfs(queue, graph, visited, count) do
    case :queue.out(queue) do
      {{:value, node}, queue} ->
        neighbors = Map.get(graph, node, [])

        {queue, visited, count} =
          Enum.reduce(neighbors, {queue, visited, count}, fn neighbor, {q, v, c} ->
            if MapSet.member?(v, neighbor) do
              {q, v, c}
            else
              {:queue.in(neighbor, q), MapSet.put(v, neighbor), c + 1}
            end
          end)

        do_bfs(queue, graph, visited, count)

      {:empty, _} ->
        {count, visited}
    end
  end

  @doc """
      iex> p2(example_string(0))
      25272
  """
  def p2(input) do
    coords = parse(input)
    n = map_size(coords)

    pairs =
      for i <- 0..(n - 2),
          j <- (i + 1)..(n - 1) do
        {dist_sq(coords[i], coords[j]), i, j}
      end
      |> Enum.sort()

    parent = Map.new(0..(n - 1), fn i -> {i, i} end)

    Enum.reduce_while(pairs, {parent, n}, fn {_, u, v}, {parent, components} ->
      {root_u, parent} = find(parent, u)
      {root_v, parent} = find(parent, v)

      if root_u != root_v do
        parent = Map.put(parent, root_v, root_u)
        new_components = components - 1

        if new_components == 1 do
          {x1, _, _} = coords[u]
          {x2, _, _} = coords[v]
          {:halt, x1 * x2}
        else
          {:cont, {parent, new_components}}
        end
      else
        {:cont, {parent, components}}
      end
    end)
  end

  def find(parent, i) do
    p = Map.get(parent, i)

    if p == i do
      {i, parent}
    else
      {root, new_parent} = find(parent, p)
      {root, Map.put(new_parent, i, root)}
    end
  end
end
