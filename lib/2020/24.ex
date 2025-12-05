import AOC

aoc 2020, 24 do
  @moduledoc """
  https://adventofcode.com/2020/day/24

  Lobby Layout - Hexagonal grid tile flipping and Game of Life.
  Using axial coordinates (q, r).

  ## Examples

      iex> example = "sesenwnenenewseeswwswswwnenewsewsw\\nneeenesenwnwwswnenewnwwsewnenwseswesw\\nseswneswswsenwwnwse\\nnwnwneseeswswnenewneswwnewseswneseene\\nswweswneswnenwsewnwneneseenw\\neesenwseswswnenwswnwnwsewwnwsene\\nsewnenenenesenwsewnenwwwse\\nwenwwweseeeweswwwnwwe\\nwsweesenenewnwwnwsenewsenwwsesesenwne\\nneeswseenwwswnwswswnw\\nnenwswwsewswnenenewsenwsenwnesesenew\\nenewnwewneswsewnwswenweswnenwsenwsw\\nsweneswneswneneenwnewenewwneswswnese\\nswwesenesewenwneswnwwneseswwne\\nenesenwswwswneneswsenwnewswseenwsese\\nwnwnesenesenenwwnenwsewesewsesesew\\nnenewswnwewswnenesenwnesewesw\\neneswnwswnwsenenwnwnwwseeswneewsenese\\nneswnwewnwnwseenwseesewsenwsweewe\\nwseweeenwnesenwwwswnew"
      iex> Y2020.D24.p1(example)
      10

      iex> example = "sesenwnenenewseeswwswswwnenewsewsw\\nneeenesenwnwwswnenewnwwsewnenwseswesw\\nseswneswswsenwwnwse\\nnwnwneseeswswnenewneswwnewseswneseene\\nswweswneswnenwsewnwneneseenw\\neesenwseswswnenwswnwnwsewwnwsene\\nsewnenenenesenwsewnenwwwse\\nwenwwweseeeweswwwnwwe\\nwsweesenenewnwwnwsenewsenwwsesesenwne\\nneeswseenwwswnwswswnw\\nnenwswwsewswnenenewsenwsenwnesesenew\\nenewnwewneswsewnwswenweswnenwsenwsw\\nsweneswneswneneenwnewenewwneswswnese\\nswwesenesewenwneswnwwneseswwne\\nenesenwswwswneneswsenwnewswseenwsese\\nwnwnesenesenenwwnenwsewesewsesesew\\nnenewswnwewswnenesenwnesewesw\\neneswnwswnwsenenwnwnwwseeswneewsenese\\nneswnwewnwnwseenwseesewsenwsweewe\\nwseweeenwnesenwwwswnew"
      iex> Y2020.D24.p2(example)
      2208
  """

  # Axial coordinates for hex grid
  @directions %{
    "e" => {1, 0},
    "w" => {-1, 0},
    "se" => {0, 1},
    "nw" => {0, -1},
    "sw" => {-1, 1},
    "ne" => {1, -1}
  }

  def p1(input) do
    input
    |> parse()
    |> initial_black_tiles()
    |> MapSet.size()
  end

  def p2(input) do
    input
    |> parse()
    |> initial_black_tiles()
    |> run_days(100)
    |> MapSet.size()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_path/1)
  end

  defp parse_path(""), do: []

  defp parse_path(<<"se", rest::binary>>), do: ["se" | parse_path(rest)]
  defp parse_path(<<"sw", rest::binary>>), do: ["sw" | parse_path(rest)]
  defp parse_path(<<"ne", rest::binary>>), do: ["ne" | parse_path(rest)]
  defp parse_path(<<"nw", rest::binary>>), do: ["nw" | parse_path(rest)]
  defp parse_path(<<"e", rest::binary>>), do: ["e" | parse_path(rest)]
  defp parse_path(<<"w", rest::binary>>), do: ["w" | parse_path(rest)]

  defp initial_black_tiles(paths) do
    paths
    |> Enum.map(&follow_path/1)
    |> Enum.frequencies()
    |> Enum.filter(fn {_pos, count} -> rem(count, 2) == 1 end)
    |> Enum.map(fn {pos, _} -> pos end)
    |> MapSet.new()
  end

  defp follow_path(directions) do
    Enum.reduce(directions, {0, 0}, fn dir, {q, r} ->
      {dq, dr} = @directions[dir]
      {q + dq, r + dr}
    end)
  end

  defp run_days(black_tiles, 0), do: black_tiles

  defp run_days(black_tiles, days) do
    new_black = step(black_tiles)
    run_days(new_black, days - 1)
  end

  defp step(black_tiles) do
    # Get all candidates (black tiles and their neighbors)
    candidates =
      black_tiles
      |> Enum.flat_map(fn pos -> [pos | neighbors(pos)] end)
      |> MapSet.new()

    candidates
    |> Enum.filter(fn pos ->
      is_black = MapSet.member?(black_tiles, pos)
      neighbor_count = count_black_neighbors(pos, black_tiles)

      cond do
        is_black and (neighbor_count == 0 or neighbor_count > 2) -> false
        not is_black and neighbor_count == 2 -> true
        is_black -> true
        true -> false
      end
    end)
    |> MapSet.new()
  end

  defp neighbors({q, r}) do
    Map.values(@directions)
    |> Enum.map(fn {dq, dr} -> {q + dq, r + dr} end)
  end

  defp count_black_neighbors(pos, black_tiles) do
    neighbors(pos)
    |> Enum.count(&MapSet.member?(black_tiles, &1))
  end
end
