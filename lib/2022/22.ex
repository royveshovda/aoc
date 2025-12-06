import AOC

aoc 2022, 22 do
  @moduledoc """
  Day 22: Monkey Map

  Walk on map following path instructions.
  Part 1: 2D wrap around edges.
  Part 2: Cube folding - wrap to adjacent cube face.
  """

  @right {0, 1}
  @down {1, 0}
  @left {0, -1}
  @up {-1, 0}

  @doc """
  Part 1: Final password with 2D wrapping.

  ## Examples

      iex> example = "        ...#\\n        .#..\\n        #...\\n        ....\\n...#.......#\\n........#...\\n..#....#....\\n..........#.\\n        ...#....\\n        .....#..\\n        .#......\\n        ......#.\\n\\n10R5L5R10L4R5L5"
      iex> Y2022.D22.p1(example)
      6032
  """
  def p1(input) do
    {grid, {max_row, max_col}, moves} = parse(input)
    start_col = Enum.find(1..max_col, fn c -> Map.has_key?(grid, {1, c}) end)

    {{row, col}, face} = traverse(grid, {1, start_col}, @right, moves, max_row, max_col, :flat)
    password(row, col, face)
  end

  @doc """
  Part 2: Final password with cube wrapping.

  ## Examples

      iex> example = "        ...#\\n        .#..\\n        #...\\n        ....\\n...#.......#\\n........#...\\n..#....#....\\n..........#.\\n        ...#....\\n        .....#..\\n        .#......\\n        ......#.\\n\\n10R5L5R10L4R5L5"
      iex> Y2022.D22.p2(example)
      5031
  """
  def p2(input) do
    {grid, {max_row, max_col}, moves} = parse(input)
    start_col = Enum.find(1..max_col, fn c -> Map.has_key?(grid, {1, c}) end)

    # Determine cube size and create wrap map
    wrap = if max_row < 50, do: example_cube_wrap(), else: actual_cube_wrap()

    {{row, col}, face} = traverse_cube(grid, {1, start_col}, @right, moves, wrap)
    password(row, col, face)
  end

  defp parse(input) do
    lines = String.split(input, "\n")
    {grid_lines, [_, path_line | _]} = Enum.split_while(lines, &(&1 != ""))

    grid = parse_grid(grid_lines)
    max_row = Enum.max(Enum.map(Map.keys(grid), &elem(&1, 0)))
    max_col = Enum.max(Enum.map(Map.keys(grid), &elem(&1, 1)))
    moves = parse_moves(path_line)

    {grid, {max_row, max_col}, moves}
  end

  defp parse_grid(lines) do
    lines
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {line, row} ->
      line
      |> String.to_charlist()
      |> Enum.with_index(1)
      |> Enum.reject(fn {char, _} -> char == ?\s end)
      |> Enum.map(fn
        {?., col} -> {{row, col}, :open}
        {?#, col} -> {{row, col}, :wall}
      end)
    end)
    |> Map.new()
  end

  defp parse_moves(path) do
    Regex.split(~r/(L|R|\d+)/, path, include_captures: true, trim: true)
    |> Enum.map(fn
      "L" -> :left
      "R" -> :right
      num -> String.to_integer(num)
    end)
  end

  defp traverse(_grid, pos, face, [], _max_row, _max_col, _mode), do: {pos, face}

  defp traverse(grid, pos, face, [:left | rest], max_row, max_col, mode) do
    traverse(grid, pos, rotate(face, :left), rest, max_row, max_col, mode)
  end

  defp traverse(grid, pos, face, [:right | rest], max_row, max_col, mode) do
    traverse(grid, pos, rotate(face, :right), rest, max_row, max_col, mode)
  end

  defp traverse(grid, pos, face, [num | rest], max_row, max_col, mode) do
    {new_pos, _} = move_steps(grid, pos, face, num, max_row, max_col)
    traverse(grid, new_pos, face, rest, max_row, max_col, mode)
  end

  defp move_steps(_grid, pos, _face, 0, _max_row, _max_col), do: {pos, nil}

  defp move_steps(grid, {row, col}, {dr, dc} = face, steps, max_row, max_col) do
    next = maybe_wrap({row + dr, col + dc}, face, max_row, max_col, grid)

    case Map.get(grid, next) do
      :open -> move_steps(grid, next, face, steps - 1, max_row, max_col)
      :wall -> {{row, col}, nil}
      nil -> {{row, col}, nil}
    end
  end

  defp maybe_wrap(pos, face, max_row, max_col, grid) do
    if Map.has_key?(grid, pos) do
      pos
    else
      {idx, range} =
        case face do
          @down -> {0, 1..max_row}
          @up -> {0, max_row..1}
          @right -> {1, 1..max_col}
          @left -> {1, max_col..1}
        end

      Enum.map(range, fn i -> put_elem(pos, idx, i) end)
      |> Enum.find(fn p -> Map.has_key?(grid, p) end)
    end
  end

  defp traverse_cube(_grid, pos, face, [], _wrap), do: {pos, face}

  defp traverse_cube(grid, pos, face, [:left | rest], wrap) do
    traverse_cube(grid, pos, rotate(face, :left), rest, wrap)
  end

  defp traverse_cube(grid, pos, face, [:right | rest], wrap) do
    traverse_cube(grid, pos, rotate(face, :right), rest, wrap)
  end

  defp traverse_cube(grid, pos, face, [num | rest], wrap) do
    {new_pos, new_face} = move_steps_cube(grid, pos, face, num, wrap)
    traverse_cube(grid, new_pos, new_face, rest, wrap)
  end

  defp move_steps_cube(_grid, pos, face, 0, _wrap), do: {pos, face}

  defp move_steps_cube(grid, {row, col}, {dr, dc} = face, steps, wrap) do
    raw_next = {row + dr, col + dc}

    {next, new_face} =
      if Map.has_key?(grid, raw_next) do
        {raw_next, face}
      else
        case Map.get(wrap, {raw_next, face}) do
          nil -> raise "Could not wrap from #{row},#{col} facing #{inspect(face)}"
          result -> result
        end
      end

    case Map.get(grid, next) do
      :open -> move_steps_cube(grid, next, new_face, steps - 1, wrap)
      :wall -> {{row, col}, face}
    end
  end

  defp rotate({dr, dc}, :left), do: {-dc, dr}
  defp rotate({dr, dc}, :right), do: {dc, -dr}

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

  # Example input cube wrapping (4x4 faces)
  defp example_cube_wrap do
    wraps = %{}

    # Face 1 (top) row 1-4, col 9-12
    # Face 2 (front) row 5-8, col 1-4
    # Face 3 (front) row 5-8, col 5-8
    # Face 4 (front) row 5-8, col 9-12
    # Face 5 (bottom) row 9-12, col 9-12
    # Face 6 (right) row 9-12, col 13-16

    wraps = Enum.reduce(1..4, wraps, fn row, acc ->
      Map.put(acc, {{row, 13}, @right}, {{13 - row, 16}, @left})
    end)

    wraps = Enum.reduce(9..12, wraps, fn col, acc ->
      Map.put(acc, {{0, col}, @up}, {{5, col - 5}, @down})
    end)

    wraps = Enum.reduce(1..4, wraps, fn row, acc ->
      Map.put(acc, {{row, 8}, @left}, {{5, 4 + row}, @down})
    end)

    wraps = Enum.reduce(5..8, wraps, fn row, acc ->
      Map.put(acc, {{row, 0}, @left}, {{12, 6 + row}, @up})
    end)

    wraps = Enum.reduce(1..4, wraps, fn col, acc ->
      Map.put(acc, {{4, col}, @up}, {{1, 13 - col}, @down})
    end)

    wraps = Enum.reduce(1..4, wraps, fn col, acc ->
      Map.put(acc, {{9, col}, @down}, {{12, 13 - col}, @up})
    end)

    wraps = Enum.reduce(5..8, wraps, fn col, acc ->
      Map.put(acc, {{4, col}, @up}, {{col - 4, 9}, @right})
    end)

    wraps = Enum.reduce(5..8, wraps, fn col, acc ->
      Map.put(acc, {{9, col}, @down}, {{12 - col, 9}, @up})
    end)

    wraps = Enum.reduce(5..8, wraps, fn row, acc ->
      Map.put(acc, {{row, 13}, @right}, {{9, 21 - row}, @down})
    end)

    wraps = Enum.reduce(9..12, wraps, fn row, acc ->
      Map.put(acc, {{row, 8}, @left}, {{8, 17 - row}, @up})
    end)

    wraps = Enum.reduce(9..12, wraps, fn col, acc ->
      Map.put(acc, {{13, col}, @down}, {{8, 13 - col}, @up})
    end)

    wraps = Enum.reduce(9..12, wraps, fn row, acc ->
      Map.put(acc, {{row, 17}, @right}, {{13 - row, 12}, @left})
    end)

    wraps = Enum.reduce(13..16, wraps, fn col, acc ->
      Map.put(acc, {{8, col}, @up}, {{21 - col, 12}, @left})
    end)

    wraps = Enum.reduce(13..16, wraps, fn col, acc ->
      Map.put(acc, {{13, col}, @down}, {{21 - col, 1}, @right})
    end)

    wraps
  end

  # Actual input cube wrapping (50x50 faces)
  defp actual_cube_wrap do
    wraps = %{}

    # My input layout:
    #   12
    #   3
    #  45
    #  6
    # Face 1: row 1-50, col 51-100
    # Face 2: row 1-50, col 101-150
    # Face 3: row 51-100, col 51-100
    # Face 4: row 101-150, col 1-50
    # Face 5: row 101-150, col 51-100
    # Face 6: row 151-200, col 1-50

    wraps = Enum.reduce(1..50, wraps, fn row, acc ->
      Map.put(acc, {{row, 151}, @right}, {{151 - row, 100}, @left})
    end)

    wraps = Enum.reduce(101..150, wraps, fn col, acc ->
      Map.put(acc, {{0, col}, @up}, {{200, col - 100}, @up})
    end)

    wraps = Enum.reduce(101..150, wraps, fn col, acc ->
      Map.put(acc, {{51, col}, @down}, {{col - 50, 100}, @left})
    end)

    wraps = Enum.reduce(1..50, wraps, fn row, acc ->
      Map.put(acc, {{row, 50}, @left}, {{151 - row, 1}, @right})
    end)

    wraps = Enum.reduce(51..100, wraps, fn col, acc ->
      Map.put(acc, {{0, col}, @up}, {{100 + col, 1}, @right})
    end)

    wraps = Enum.reduce(51..100, wraps, fn row, acc ->
      Map.put(acc, {{row, 50}, @left}, {{101, row - 50}, @down})
    end)

    wraps = Enum.reduce(51..100, wraps, fn row, acc ->
      Map.put(acc, {{row, 101}, @right}, {{50, 50 + row}, @up})
    end)

    wraps = Enum.reduce(101..150, wraps, fn row, acc ->
      Map.put(acc, {{row, 101}, @right}, {{151 - row, 150}, @left})
    end)

    wraps = Enum.reduce(51..100, wraps, fn col, acc ->
      Map.put(acc, {{151, col}, @down}, {{100 + col, 50}, @left})
    end)

    wraps = Enum.reduce(101..150, wraps, fn row, acc ->
      Map.put(acc, {{row, 0}, @left}, {{151 - row, 51}, @right})
    end)

    wraps = Enum.reduce(1..50, wraps, fn col, acc ->
      Map.put(acc, {{100, col}, @up}, {{50 + col, 51}, @right})
    end)

    wraps = Enum.reduce(151..200, wraps, fn row, acc ->
      Map.put(acc, {{row, 51}, @right}, {{150, row - 100}, @up})
    end)

    wraps = Enum.reduce(1..50, wraps, fn col, acc ->
      Map.put(acc, {{201, col}, @down}, {{1, 100 + col}, @down})
    end)

    wraps = Enum.reduce(151..200, wraps, fn row, acc ->
      Map.put(acc, {{row, 0}, @left}, {{1, row - 100}, @down})
    end)

    wraps
  end
end
