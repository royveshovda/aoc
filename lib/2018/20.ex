import AOC

aoc 2018, 20 do
  @moduledoc """
  https://adventofcode.com/2018/day/20

  Parse regex-like directions to build a map of rooms and doors,
  then find the furthest room via BFS.
  """

  @doc """
      iex> p1("^WNE$")
      3

      iex> p1("^ENWWW(NEEE|SSE(EE|N))$")
      10

      iex> p1("^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$")
      18

      iex> p1("^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$")
      23

      iex> p1("^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$")
      31
  """
  def p1(input) do
    regex = String.trim(input)
    doors = build_door_map(regex)
    distances = bfs_distances({0, 0}, doors)

    distances
    |> Map.values()
    |> Enum.max()
  end

  @doc """
  Part 2: Count rooms with shortest path >= 1000 doors
  """
  def p2(input) do
    regex = String.trim(input)
    doors = build_door_map(regex)
    distances = bfs_distances({0, 0}, doors)

    distances
    |> Map.values()
    |> Enum.count(&(&1 >= 1000))
  end

  # Build a map of all doors by following the regex
  defp build_door_map(regex) do
    # Strip ^ and $
    path = regex |> String.slice(1..-2//1)

    # Track all positions and doors as we parse
    {doors, _final_positions} = parse_path(path, [{0, 0}], MapSet.new())
    doors
  end

  # Parse the path regex and return {doors, positions}
  # positions is a list of all positions we could be at after this segment
  defp parse_path("", positions, doors), do: {doors, positions}

  defp parse_path(path, positions, doors) do
    case String.next_grapheme(path) do
      {char, rest} when char in ["N", "S", "E", "W"] ->
        # Move in direction from all current positions
        {new_positions, new_doors} =
          Enum.reduce(positions, {[], doors}, fn pos, {new_pos, acc_doors} ->
            next_pos = move(pos, char)
            door = door_between(pos, next_pos)
            {[next_pos | new_pos], MapSet.put(acc_doors, door)}
          end)

        parse_path(rest, Enum.uniq(new_positions), new_doors)

      {"(", rest} ->
        # Branch: find all alternatives separated by |, end at matching )
        {alternatives, after_branch} = extract_branches(rest)

        # For each alternative, parse starting from current positions
        {all_positions, branch_doors} =
          Enum.reduce(alternatives, {[], doors}, fn alt, {pos_acc, door_acc} ->
            {alt_doors, alt_positions} = parse_path(alt, positions, door_acc)
            {alt_positions ++ pos_acc, alt_doors}
          end)

        # Continue from all possible end positions
        parse_path(after_branch, Enum.uniq(all_positions), branch_doors)

      _ ->
        {doors, positions}
    end
  end

  # Extract all branch alternatives between ( and matching )
  # Returns {list_of_alternatives, remaining_string}
  defp extract_branches(str) do
    {branches, rest} = extract_until_close(str, 0, "", [])
    {branches, rest}
  end

  defp extract_until_close("", _depth, current, acc) do
    {Enum.reverse([current | acc]), ""}
  end

  defp extract_until_close(<<char::utf8, rest::binary>>, depth, current, acc) do
    case <<char::utf8>> do
      "(" ->
        extract_until_close(rest, depth + 1, current <> "(", acc)
      ")" when depth == 0 ->
        {Enum.reverse([current | acc]), rest}
      ")" ->
        extract_until_close(rest, depth - 1, current <> ")", acc)
      "|" when depth == 0 ->
        extract_until_close(rest, depth, "", [current | acc])
      c ->
        extract_until_close(rest, depth, current <> c, acc)
    end
  end

  # Move in a direction
  defp move({x, y}, "N"), do: {x, y - 1}
  defp move({x, y}, "S"), do: {x, y + 1}
  defp move({x, y}, "E"), do: {x + 1, y}
  defp move({x, y}, "W"), do: {x - 1, y}

  # Get the door coordinate between two adjacent rooms
  # Doors are at half coordinates between rooms
  defp door_between({x1, y1}, {x2, y2}) do
    {(x1 + x2) / 2, (y1 + y2) / 2}
  end

  # BFS to find shortest distance to all reachable rooms
  defp bfs_distances(start, doors) do
    queue = :queue.from_list([{start, 0}])
    bfs_loop(queue, %{start => 0}, doors)
  end

  defp bfs_loop(queue, distances, doors) do
    case :queue.out(queue) do
      {:empty, _} ->
        distances

      {{:value, {pos, dist}}, rest} ->
        # Try all 4 directions
        neighbors = [
          move(pos, "N"),
          move(pos, "S"),
          move(pos, "E"),
          move(pos, "W")
        ]

        # Only visit neighbors we have doors to and haven't visited
        {new_queue, new_distances} =
          Enum.reduce(neighbors, {rest, distances}, fn next_pos, {q, d} ->
            door = door_between(pos, next_pos)

            if MapSet.member?(doors, door) and not Map.has_key?(d, next_pos) do
              {:queue.in({next_pos, dist + 1}, q), Map.put(d, next_pos, dist + 1)}
            else
              {q, d}
            end
          end)

        bfs_loop(new_queue, new_distances, doors)
    end
  end
end
