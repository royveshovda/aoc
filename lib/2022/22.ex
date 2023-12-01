# Source: https://github.com/flwyd/adventofcode/blob/main/2022/day22/day22.exs

import AOC

aoc 2022, 22 do

  @right {0, 1}
  @down {1, 0}
  @left {0, -1}
  @up {-1, 0}

  def p1(input) do
    input = String.split(input, "\n", trim: true)
    {grid, {max_row, max_col}, moves} = parse_input(input)
    start_col = Enum.find(1..max_col, fn c -> Map.has_key?(grid, {1, c}) end)
    start_face = @right
    traverse = %{{1, start_col} => start_face}

    {{row, col}, face, _traverse} =
      Enum.reduce(moves, {{1, start_col}, start_face, traverse}, fn
        :left, {pos, face, traverse} ->
          face = rotate(face, :left)
          {pos, face, Map.put(traverse, pos, face)}

        :right, {pos, face, traverse} ->
          face = rotate(face, :right)
          {pos, face, Map.put(traverse, pos, face)}

        num, {pos, {dr, dc} = face, traverse} ->
          {final, traverse} =
            Enum.reduce_while(1..num, {pos, traverse}, fn _, {{row, col} = pos, traverse} ->
              next = maybe_wrap({row + dr, col + dc}, face, {max_row, max_col}, grid)

              case Map.get(grid, next, :nope) do
                :open -> {:cont, {next, Map.put(traverse, next, face)}}
                :wall -> {:halt, {pos, traverse}}
              end
            end)

          {final, face, traverse}
      end)

    password(row, col, face)

  end

  def p2(input) do
    input = String.split(input, "\n", trim: true)
    {grid, {max_row, max_col}, moves} = parse_input(input)

    wrap = if max_row < 20, do: example_cube_wrap(), else: actual_cube_wrap()
    for {{from, ff} = f, {to, tf} = t} <- wrap do
      if !Map.has_key?(grid, to), do: raise("Wrap from #{inspect(f)} to #{inspect(t)} missing")
      if Map.has_key?(grid, {from, ff}), do: raise("Wrap from #{inspect(f)} already in grid")
      rev = rotate(rotate(tf, :left), :left)
      {rev_pos, rev_face} = maybe_wrap_cube(to, rev, grid, wrap)
      maybe_wrap_cube(rev_pos, rev_face, grid, wrap)
    end

    start_col = Enum.find(1..max_col, fn c -> Map.has_key?(grid, {1, c}) end)
    start_face = @right
    traverse = %{{1, start_col} => start_face}

    {{row, col}, face, traverse} =
      Enum.reduce(moves, {{1, start_col}, start_face, traverse}, fn
        :left, {pos, face, traverse} ->
          face = rotate(face, :left)
          {pos, face, Map.put(traverse, pos, face)}

        :right, {pos, face, traverse} ->
          face = rotate(face, :right)
          {pos, face, Map.put(traverse, pos, face)}

        num, {pos, face, traverse} ->
          {final, final_face, traverse} =
            Enum.reduce_while(1..num, {pos, face, traverse}, fn _, {pos, face, traverse} ->
              {next, new_face} = maybe_wrap_cube(pos, face, grid, wrap)

              case Map.get(grid, next, :nope) do
                :open -> {:cont, {next, new_face, Map.put(traverse, next, new_face)}}
                :wall -> {:halt, {pos, face, traverse}}
              end
            end)

          {final, final_face, traverse}
      end)

    if max_row < 100, do: print_traverse(traverse, grid, max_row, max_col)
    password(row, col, face)
  end

  defp parse_input(input, row_max_col \\ {1, 0}, grid \\ %{})

  defp parse_input(["" | rest], {max_row, max_col}, grid),
    do: parse_input(rest, {max_row - 1, max_col}, grid)

  defp parse_input([last], row_max_col, grid) do
    moves =
      Regex.split(~r/(L|R|\d+)/, last, include_captures: true, trim: true)
      |> Enum.map(fn
        "L" -> :left
        "R" -> :right
        num -> String.to_integer(num)
      end)

    {grid, row_max_col, moves}
  end

  defp parse_input([head | rest], {row, max_col}, grid) do
    grid =
      String.to_charlist(head)
      |> Enum.with_index(1)
      |> Enum.reject(fn {char, _i} -> char === ?\s end)
      |> Enum.map(fn
        {?., i} -> {{row, i}, :open}
        {?#, i} -> {{row, i}, :wall}
        {unknown, _i}-> raise "Unknown char #{unknown}"
      end)
      |> Enum.into(grid)

    parse_input(rest, {row + 1, max(max_col, String.length(head) + 1)}, grid)
  end

  defp rotate({drow, dcol}, :left), do: {-1 * dcol, drow}
  defp rotate({drow, dcol}, :right), do: {dcol, -1 * drow}

  defp maybe_wrap(pos, face, {max_row, max_col}, grid) do
    if Map.has_key?(grid, pos) do
      pos
    else
      {idx, range} =
        case face do
          @down -> {0, 1..max_row}
          @up -> {0, max_row..1}
          @right -> {1, 1..max_col}
          @left -> {1, max_row..1}
        end

      Enum.map(range, fn i -> put_elem(pos, idx, i) end)
      |> Enum.find(fn pos -> Map.has_key?(grid, pos) end)
    end
  end

  defp password(row, col, face) do
    face_score =
      case face do
        @right -> 0
        @down -> 1
        @left -> 2
        @up -> 3
      end

    1000 * row + 4 * col + face_score
  end

  defp print_traverse(t, grid, max_row, max_col) do
    for row <- 1..max_row do
      chars =
        for col <- 1..max_col do
          case {Map.get(t, {row, col}), Map.get(grid, {row, col}, :nope)} do
            {nil, :nope} -> ?\s
            {nil, :open} -> ?.
            {nil, :wall} -> ?#
            {face, _} -> face_char(face)
          end
        end

      IO.puts(:stderr, chars)
    end
  end

  defp face_char(@down), do: ?v
  defp face_char(@up), do: ?^
  defp face_char(@right), do: ?>
  defp face_char(@left), do: ?<

  defp maybe_wrap_cube({row, col}, {drow, dcol} = face, grid, wrap) do
    next = {row + drow, col + dcol}

    if Map.has_key?(grid, next) do
      {next, face}
    else
      case Map.get(wrap, {next, face}) do
        nil ->
          raise "Could not wrap from #{row},#{col} facing #{drow},#{dcol}"

        {dest, face} ->
          if Map.has_key?(grid, dest),
            do: {dest, face},
            else: raise("Wrapped from #{row},#{col} to #{inspect({dest, face})} not in grid")
      end
    end
  end

  defp example_cube_wrap() do
    wraps = %{}
    wraps =
      Enum.map(1..4, fn row -> {{{row, 13}, @right}, {{13 - row, 16}, @left}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(9..12, fn col -> {{{0, col}, @up}, {{5, col - 5}, @down}} end) |> Enum.into(wraps)

    wraps =
      Enum.map(1..4, fn row -> {{{row, 8}, @left}, {{5, 4 + row}, @down}} end) |> Enum.into(wraps)

    wraps =
      Enum.map(5..8, fn row -> {{{row, 0}, @left}, {{12, 6 + row}, @up}} end) |> Enum.into(wraps)

     wraps =
      Enum.map(1..4, fn col -> {{{4, col}, @up}, {{1, 13 - col}, @down}} end) |> Enum.into(wraps)

    wraps =
      Enum.map(1..4, fn col -> {{{9, col}, @down}, {{12, 13 - col}, @up}} end) |> Enum.into(wraps)

    wraps =
      Enum.map(5..8, fn col -> {{{4, col}, @up}, {{col - 4, 9}, @right}} end) |> Enum.into(wraps)

    wraps =
      Enum.map(5..8, fn col -> {{{9, col}, @down}, {{12 - col, 9}, @up}} end) |> Enum.into(wraps)

    wraps =
      Enum.map(5..8, fn row -> {{{row, 13}, @right}, {{9, 21 - row}, @down}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(9..12, fn row -> {{{row, 8}, @left}, {{8, 17 - row}, @up}} end) |> Enum.into(wraps)

    wraps =
      Enum.map(9..12, fn col -> {{{13, col}, @down}, {{8, 13 - col}, @up}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(9..12, fn row -> {{{row, 17}, @right}, {{13 - row, 12}, @left}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(13..16, fn col -> {{{8, col}, @up}, {{21 - col, 12}, @left}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(13..16, fn col -> {{{13, col}, @down}, {{21 - col, 1}, @right}} end)
      |> Enum.into(wraps)

    wraps
  end

  defp actual_cube_wrap() do
    wraps = %{}
    wraps =
      Enum.map(1..50, fn row -> {{{row, 151}, @right}, {{151 - row, 100}, @left}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(101..150, fn col -> {{{0, col}, @up}, {{200, col - 100}, @up}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(101..150, fn col -> {{{51, col}, @down}, {{col - 50, 100}, @left}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(1..50, fn row -> {{{row, 50}, @left}, {{151 - row, 1}, @right}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(51..100, fn col -> {{{0, col}, @up}, {{100 + col, 1}, @right}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(51..100, fn row -> {{{row, 50}, @left}, {{101, row - 50}, @down}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(51..100, fn row -> {{{row, 101}, @right}, {{50, 50 + row}, @up}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(101..150, fn row -> {{{row, 101}, @right}, {{151 - row, 150}, @left}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(51..100, fn col -> {{{151, col}, @down}, {{100 + col, 50}, @left}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(101..150, fn row -> {{{row, 0}, @left}, {{151 - row, 51}, @right}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(1..50, fn col -> {{{100, col}, @up}, {{50 + col, 51}, @right}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(151..200, fn row -> {{{row, 51}, @right}, {{150, row - 100}, @up}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(1..50, fn col -> {{{201, col}, @down}, {{1, 100 + col}, @down}} end)
      |> Enum.into(wraps)

    wraps =
      Enum.map(151..200, fn row -> {{{row, 0}, @left}, {{1, row - 100}, @down}} end)
      |> Enum.into(wraps)

    wraps
  end
end
