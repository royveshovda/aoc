import AOC

aoc 2024, 15 do
  @moduledoc """
  https://adventofcode.com/2024/day/15
  """

  def p1(input) do
    [map_raw, moves] =
      input
      |> String.split("\n\n", trim: true)

    map = Utils.Grid.input_to_map(map_raw)
    moves =
      moves
      |> String.trim()
      |> String.split("", trim: true)
      |> Enum.map(&String.to_atom/1)
      |> Enum.reject(fn x -> x == :"\n" end)

    {robot, "@"} = Enum.find(map, fn {_pos, val} -> val == "@" end)

    map = Map.replace(map, robot, ".")
    {map, _robot} = move_robot(map, robot, moves)

    # print map line by line
    # map_with_robot = Map.replace(map, robot, "@")
    # Enum.each(0..7, fn y ->
    #   Enum.each(0..7, fn x ->
    #     IO.write(Map.get(map_with_robot, {x, y}))
    #   end)
    #   IO.puts("\n")
    # end)

    map
    |> Map.filter(fn {_pos, val} -> val == "O" end)
    |> Enum.map(fn {{x, y}, _} -> (100 * y) + x end)
    |> Enum.sum()
  end

  def move_robot(map, robot, []) do
    {map, robot}
  end

  def move_robot(map, robot, [move | moves]) do
    {new_map, new_robot} = move(map, robot, move)
    move_robot(new_map, new_robot, moves)
  end

  def move(map, {x, y}, :^) do
    case Map.get(map, {x, y - 1}) do
      "." ->
        {map, {x, y - 1}}
      "#" ->
        {map, {x, y}}
      "O" ->
        case can_move_up(map, {x, y - 1}) do
          {true, pos} ->
            new_map =
              map
              |> Map.replace({x, y - 1}, ".")
              |> Map.replace(pos, "O")
            {new_map, {x, y - 1}}
          {false, _} -> {map, {x, y}}
        end
    end
  end

  def move(map, {x, y}, :<) do
    case Map.get(map, {x - 1, y}) do
      "." ->
        {map, {x - 1, y}}
      "#" ->
        {map, {x, y}}
      "O" ->
        case can_move_left(map, {x - 1, y}) do
          {true, pos} ->
            new_map =
              map
              |> Map.replace({x - 1, y}, ".")
              |> Map.replace(pos, "O")
            {new_map, {x - 1, y}}
          {false, _} -> {map, {x, y}}
        end
    end
  end

  def move(map, {x, y}, :>) do
    case Map.get(map, {x + 1, y}) do
      "." ->
        {map, {x + 1, y}}
      "#" ->
        {map, {x, y}}
      "O" ->
        case can_move_right(map, {x + 1, y}) do
          {true, pos} ->
            new_map =
              map
              |> Map.replace({x + 1, y}, ".")
              |> Map.replace(pos, "O")
            {new_map, {x + 1, y}}
          {false, _} -> {map, {x, y}}
        end
    end
  end

  def move(map, {x, y}, :v) do
    case Map.get(map, {x, y + 1}) do
      "." ->
        {map, {x, y + 1}}
      "#" ->
        {map, {x, y}}
      "O" ->
        case can_move_down(map, {x, y + 1}) do
          {true, pos} ->
            new_map =
              map
              |> Map.replace({x, y + 1}, ".")
              |> Map.replace(pos, "O")
            {new_map, {x, y + 1}}
          {false, _} -> {map, {x, y}}
        end
    end
  end

  def can_move_up(map, {x, y} = check) do
    case Map.get(map, check) do
      "." -> {true, check}
      "#" -> {false, nil}
      "O" -> can_move_up(map, {x, y - 1})
    end
  end

  def can_move_down(map, {x, y} = check) do
    case Map.get(map, check) do
      "." -> {true, check}
      "#" -> {false, nil}
      "O" -> can_move_down(map, {x, y + 1})
    end
  end

  def can_move_left(map, {x, y} = check) do
    case Map.get(map, check) do
      "." -> {true, check}
      "#" -> {false, nil}
      "O" -> can_move_left(map, {x - 1, y})
    end
  end

  def can_move_right(map, {x, y} = check) do
    case Map.get(map, check) do
      "." -> {true, check}
      "#" -> {false, nil}
      "O" -> can_move_right(map, {x + 1, y})
    end
  end

  def p2(input) do
    input
  end
end
