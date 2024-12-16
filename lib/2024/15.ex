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
    [map_raw, moves] =
      input
      |> String.split("\n\n", trim: true)

    map =
      map_raw
      |> String.replace("#", "##")
      |> String.replace("O", "[]")
      |> String.replace(".", "..")
      |> String.replace("@", "@.")
      |> Utils.Grid.input_to_map()

    moves =
      moves
      |> String.trim()
      |> String.split("", trim: true)
      |> Enum.map(&String.to_atom/1)
      |> Enum.reject(fn x -> x == :"\n" end)

    {robot, "@"} = Enum.find(map, fn {_pos, val} -> val == "@" end)

    map = Map.replace(map, robot, ".")

    {new_map, _new_robot} = move_robot_p2(map, robot, moves)

    new_map
    |> Map.filter(fn {_pos, val} -> val == "[" end)
    |> Enum.map(fn {{x, y}, _} -> (100 * y) + x end)
    |> Enum.sum()
  end

  def move_robot_p2(map, robot, []) do
    {map, robot}
  end

  def move_robot_p2(map, robot, [move | moves]) do
    {new_map, new_robot} = move_p2(map, robot, move)
    move_robot_p2(new_map, new_robot, moves)
  end

  def move_p2(map, {x, y}, :<) do
    case Map.get(map, {x - 1, y}) do
      "." ->
        {map, {x - 1, y}}
      "#" ->
        {map, {x, y}}
      "]" ->
        case can_move_left_p2(map, {x - 1, y}, []) do
          {true, swap} ->
            old_map = map
            new_map =
              Enum.reduce(swap, map, fn {x, y}, acc ->
                Map.replace(acc, {x - 1, y}, Map.get(old_map, {x, y}))
              end)
              new_map = Map.replace(new_map, {x - 1, y}, ".")
            {new_map, {x - 1, y}}
          {false, _} -> {map, {x, y}}
        end
    end
  end

  def move_p2(map, {x, y}, :>) do
    case Map.get(map, {x + 1, y}) do
      "." ->
        {map, {x + 1, y}}
      "#" ->
        {map, {x, y}}
      "[" ->
        case can_move_right_p2(map, {x + 1, y}, []) do
          {true, swap} ->
            old_map = map
            new_map =
              Enum.reduce(swap, map, fn {x, y}, acc ->
                Map.replace(acc, {x + 1, y}, Map.get(old_map, {x, y}))
              end)
              new_map = Map.replace(new_map, {x + 1, y}, ".")
            {new_map, {x + 1, y}}
          {false, _} -> {map, {x, y}}
        end
    end
  end

  def move_p2(map, {x, y}, :v) do
    case Map.get(map, {x, y + 1}) do
      "." ->
        {map, {x, y + 1}}
      "#" ->
        {map, {x, y}}
      "]" ->
        case can_move_down_p2(map, {x, y + 1}, []) do
          {true, swap} ->
            old_map = map
            cleared_map = Enum.reduce(swap, map, fn {x, y}, acc ->
              Map.replace(acc, {x, y}, ".")
            end)
            new_map =
              Enum.reduce(swap, cleared_map, fn {x, y}, acc ->
                Map.replace(acc, {x, y + 1}, Map.get(old_map, {x, y}))
              end)
              new_map = Map.replace(new_map, {x, y + 1}, ".")
            {new_map, {x, y + 1}}
          {false, _} -> {map, {x, y}}
        end
      "[" ->
        case can_move_down_p2(map, {x, y + 1}, []) do
          {true, swap} ->
            old_map = map
            cleared_map = Enum.reduce(swap, map, fn {x, y}, acc ->
              Map.replace(acc, {x, y}, ".")
            end)
            new_map =
              Enum.reduce(swap, cleared_map, fn {x, y}, acc ->
                Map.replace(acc, {x, y + 1}, Map.get(old_map, {x, y}))
              end)
              new_map = Map.replace(new_map, {x, y + 1}, ".")
            {new_map, {x, y + 1}}
          {false, _} -> {map, {x, y}}
        end
    end
  end

  def move_p2(map, {x, y}, :^) do
    case Map.get(map, {x, y - 1}) do
      "." ->
        {map, {x, y - 1}}
      "#" ->
        {map, {x, y}}
      "]" ->
        case can_move_up_p2(map, {x, y - 1}, []) do
          {true, swap} ->
            old_map = map
            cleared_map = Enum.reduce(swap, map, fn {x, y}, acc ->
              Map.replace(acc, {x, y}, ".")
            end)
            new_map =
              Enum.reduce(swap, cleared_map, fn {x, y}, acc ->
                Map.replace(acc, {x, y - 1}, Map.get(old_map, {x, y}))
              end)
              new_map = Map.replace(new_map, {x, y - 1}, ".")
            {new_map, {x, y - 1}}
          {false, _} -> {map, {x, y}}
        end
      "[" ->
        case can_move_up_p2(map, {x, y - 1}, []) do
          {true, swap} ->
            old_map = map
            cleared_map = Enum.reduce(swap, map, fn {x, y}, acc ->
              Map.replace(acc, {x, y}, ".")
            end)
            new_map =
              Enum.reduce(swap, cleared_map, fn {x, y}, acc ->
                Map.replace(acc, {x, y - 1}, Map.get(old_map, {x, y}))
              end)
              new_map = Map.replace(new_map, {x, y - 1}, ".")
            {new_map, {x, y - 1}}
          {false, _} -> {map, {x, y}}
        end
    end
  end

  def can_move_left_p2(map, {x, y} = check, swap) do
    case Map.get(map, check) do
      "." -> {true, swap}
      "#" -> {false, nil}
      "]" -> can_move_left_p2(map, {x - 2, y}, swap ++ [{x, y}, {x - 1, y}])
    end
  end

  def can_move_right_p2(map, {x, y} = check, swap) do
    case Map.get(map, check) do
      "." -> {true, swap}
      "#" -> {false, nil}
      "[" -> can_move_right_p2(map, {x + 2, y}, swap ++ [{x, y}, {x + 1, y}])
    end
  end

  def can_move_down_p2(map, {x, y} = check, swap) do
    case check in swap do
      true -> {true, swap}
      false ->
        case Map.get(map, check) do
          "." -> {true, swap}
          "#" -> {false, nil}
          "[" ->
            {res1, swap1} = can_move_down_p2(map, {x + 1, y}, swap ++ [{x, y}])
            {res2, swap2} = can_move_down_p2(map, {x, y + 1}, swap ++ [{x, y}])
            {res3, swap3} = can_move_down_p2(map, {x + 1, y + 1}, swap ++ [{x, y}])
            case {res1, res2, res3} do
              {true, true, true} ->
                s = swap1 ++ swap2 ++ swap3 |> Enum.uniq()
                {res1, s}
              {_, _, _} -> {false, nil}
            end
          "]" ->
            {res1, swap1} = can_move_down_p2(map, {x - 1, y}, swap ++ [{x, y}])
            {res2, swap2} = can_move_down_p2(map, {x - 1, y + 1}, swap ++ [{x, y}])
            {res3, swap3} = can_move_down_p2(map, {x, y + 1}, swap ++ [{x, y}])
            case {res1, res2, res3} do
              {true, true, true} ->
                s = swap1 ++ swap2 ++ swap3 |> Enum.uniq()
                {res1, s}
              {_, _, _} -> {false, nil}
            end
        end
    end
  end

  def can_move_up_p2(map, {x, y} = check, swap) do
    case check in swap do
      true -> {true, swap}
      false ->
        case Map.get(map, check) do
          "." -> {true, swap}
          "#" -> {false, nil}
          "[" ->
            {res1, swap1} = can_move_up_p2(map, {x + 1, y}, swap ++ [{x, y}])
            {res2, swap2} = can_move_up_p2(map, {x, y - 1}, swap ++ [{x, y}])
            {res3, swap3} = can_move_up_p2(map, {x + 1, y - 1}, swap ++ [{x, y}])
            case {res1, res2, res3} do
              {true, true, true} ->
                s = swap1 ++ swap2 ++ swap3 |> Enum.uniq()
                {res1, s}
              {_, _, _} -> {false, nil}
            end
          "]" ->
            {res1, swap1} = can_move_up_p2(map, {x - 1, y}, swap ++ [{x, y}])
            {res2, swap2} = can_move_up_p2(map, {x - 1, y - 1}, swap ++ [{x, y}])
            {res3, swap3} = can_move_up_p2(map, {x, y - 1}, swap ++ [{x, y}])
            case {res1, res2, res3} do
              {true, true, true} ->
                s = swap1 ++ swap2 ++ swap3 |> Enum.uniq()
                {res1, s}
              {_, _, _} -> {false, nil}
            end
        end
    end
  end

  # def print_map(map, width, height, robot) do
  #   map = Map.replace(map, robot, "@")
  #   Enum.each(0..height, fn y ->
  #     Enum.each(0..width, fn x ->
  #       IO.write(Map.get(map, {x, y}))
  #     end)
  #     IO.puts("\n")
  #   end)
  # end
end
