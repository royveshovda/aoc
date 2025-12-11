import AOC
import Bitwise

aoc 2025, 11 do
  @moduledoc """
  https://adventofcode.com/2025/day/11
  """

  @doc """
      iex> p1(example_string(0))
      5
  """
  def p1(input) do
    input
    |> parse_input()
    |> count_paths()
  end

  @doc """
      iex> p2(example_string(1))
      2
  """
  def p2(input) do
    graph = parse_input(input)
    {count, _memo} = dfs_require("svr", graph, 0, %{}, MapSet.new())
    count
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Map.new()
  end

  def parse_line(line) do
    [node, rest] = String.split(line, ":", parts: 2)

    neighbors =
      rest
      |> String.trim()
      |> String.split(" ", trim: true)

    {node, neighbors}
  end

  def count_paths(graph) do
    {count, _memo} = dfs("you", graph, %{}, MapSet.new())
    count
  end

  def dfs(node, graph, memo, visiting) do
    case memo do
      %{^node => count} -> {count, memo}

      _ ->
        cond do
          node == "out" ->
            {1, Map.put(memo, node, 1)}

          MapSet.member?(visiting, node) ->
            {0, memo}

          true ->
            neighbors = Map.get(graph, node, [])
            {count, memo_after} =
              Enum.reduce(neighbors, {0, memo}, fn next, {acc, mem} ->
                {c, mem2} = dfs(next, graph, mem, MapSet.put(visiting, node))
                {acc + c, mem2}
              end)

            memo_final = Map.put(memo_after, node, count)
            {count, memo_final}
        end
    end
  end

  # DFS with required nodes (dac, fft)
  # mask bits: 1 = dac visited, 2 = fft visited
  def dfs_require(node, graph, mask, memo, visiting) do
    case memo do
      %{^node => %{^mask => count}} -> {count, memo}
      _ ->
        cond do
          MapSet.member?(visiting, node) -> {0, memo}

          true ->
            mask2 =
              mask
              |> maybe_set(node == "dac", 1)
              |> maybe_set(node == "fft", 2)

            if node == "out" do
              count = if mask2 == 3, do: 1, else: 0
              {count, put_memo(memo, node, mask2, count)}
            else
              neighbors = Map.get(graph, node, [])
              {count, memo_after} =
                Enum.reduce(neighbors, {0, memo}, fn next, {acc, mem} ->
                  {c, mem2} = dfs_require(next, graph, mask2, mem, MapSet.put(visiting, node))
                  {acc + c, mem2}
                end)

              memo_final = put_memo(memo_after, node, mask2, count)
              {count, memo_final}
            end
        end
    end
  end

  def maybe_set(mask, true, bit), do: mask ||| bit
  def maybe_set(mask, false, _bit), do: mask

  def put_memo(memo, node, mask, count) do
    inner = Map.get(memo, node, %{}) |> Map.put(mask, count)
    Map.put(memo, node, inner)
  end
end
