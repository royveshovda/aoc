import AOC

aoc 2024, 21 do
  @moduledoc """
  https://adventofcode.com/2024/day/21

  Keypad Conundrum - chain of robot keypads.
  Numeric keypad -> N directional keypads -> you.
  Find shortest input sequence length.
  Use memoization for recursive depth.
  """

  # Numeric keypad layout:
  # 7 8 9
  # 4 5 6
  # 1 2 3
  #   0 A
  @num_pad %{
    "7" => {0, 0}, "8" => {1, 0}, "9" => {2, 0},
    "4" => {0, 1}, "5" => {1, 1}, "6" => {2, 1},
    "1" => {0, 2}, "2" => {1, 2}, "3" => {2, 2},
                   "0" => {1, 3}, "A" => {2, 3}
  }
  @num_gap {0, 3}

  # Directional keypad:
  #   ^ A
  # < v >
  @dir_pad %{
                   "^" => {1, 0}, "A" => {2, 0},
    "<" => {0, 1}, "v" => {1, 1}, ">" => {2, 1}
  }
  @dir_gap {0, 0}

  def p1(input) do
    solve(input, 2)
  end

  def p2(input) do
    solve(input, 25)
  end

  defp solve(input, num_robots) do
    codes = String.split(input, "\n", trim: true)

    # Start memoization process
    {:ok, cache} = Agent.start_link(fn -> %{} end)

    result =
      codes
      |> Enum.map(fn code ->
        len = sequence_length(code, num_robots, cache)
        numeric = code |> String.trim_trailing("A") |> String.to_integer()
        len * numeric
      end)
      |> Enum.sum()

    Agent.stop(cache)
    result
  end

  defp sequence_length(code, num_robots, cache) do
    # First, get paths on numeric keypad
    chars = String.graphemes(code)
    from_to_pairs = Enum.zip(["A" | chars], chars)

    from_to_pairs
    |> Enum.map(fn {from, to} ->
      paths = get_paths(@num_pad, @num_gap, from, to)
      # For each path, compute min length through robot chain
      paths
      |> Enum.map(fn path ->
        robot_length(path <> "A", num_robots, cache)
      end)
      |> Enum.min()
    end)
    |> Enum.sum()
  end

  defp robot_length(_path, 0, _cache), do: 0

  defp robot_length(path, depth, cache) do
    key = {path, depth}

    case Agent.get(cache, fn c -> Map.get(c, key) end) do
      nil ->
        result = compute_robot_length(path, depth, cache)
        Agent.update(cache, fn c -> Map.put(c, key, result) end)
        result

      val ->
        val
    end
  end

  defp compute_robot_length(path, depth, cache) do
    chars = String.graphemes(path)
    from_to_pairs = Enum.zip(["A" | chars], chars)

    from_to_pairs
    |> Enum.map(fn {from, to} ->
      paths = get_paths(@dir_pad, @dir_gap, from, to)

      paths
      |> Enum.map(fn p ->
        if depth == 1 do
          String.length(p) + 1  # +1 for the A press
        else
          robot_length(p <> "A", depth - 1, cache)
        end
      end)
      |> Enum.min()
    end)
    |> Enum.sum()
  end

  defp get_paths(pad, gap, from, to) do
    {fx, fy} = Map.get(pad, from)
    {tx, ty} = Map.get(pad, to)
    {gx, gy} = gap

    dx = tx - fx
    dy = ty - fy

    h_char = if dx > 0, do: ">", else: "<"
    v_char = if dy > 0, do: "v", else: "^"
    h_moves = String.duplicate(h_char, abs(dx))
    v_moves = String.duplicate(v_char, abs(dy))

    paths =
      cond do
        dx == 0 and dy == 0 -> [""]
        dx == 0 -> [v_moves]
        dy == 0 -> [h_moves]
        true -> [h_moves <> v_moves, v_moves <> h_moves]
      end

    # Filter out paths that cross the gap
    Enum.filter(paths, fn path ->
      not crosses_gap?(fx, fy, path, gx, gy)
    end)
  end

  defp crosses_gap?(x, y, path, gx, gy) do
    path
    |> String.graphemes()
    |> Enum.reduce_while({x, y}, fn move, {cx, cy} ->
      {nx, ny} =
        case move do
          "^" -> {cx, cy - 1}
          "v" -> {cx, cy + 1}
          "<" -> {cx - 1, cy}
          ">" -> {cx + 1, cy}
        end

      if nx == gx and ny == gy do
        {:halt, :gap}
      else
        {:cont, {nx, ny}}
      end
    end)
    |> then(fn result -> result == :gap end)
  end
end
