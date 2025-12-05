import AOC

aoc 2018, 13 do
  @moduledoc """
  https://adventofcode.com/2018/day/13
  """

  @doc """
  Find location of first crash.

      iex> test_input = "/->-\\\\\\n|   |  /----\\\\\\n| /-+--+-\\\\  |\\n| | |  | v  |\\n\\\\-+-/  \\\\-+--/\\n  \\\\------/"
      iex> p1(test_input)
      "7,3"
  """
  def p1(input) do
    {tracks, carts} = parse(input)

    {x, y} = simulate_until_crash(tracks, carts)
    "#{x},#{y}"
  end

  @doc """
  Find location of last remaining cart after all collisions.
  Part 2 will be implemented after submitting part 1.
  """
  def p2(input) do
    {tracks, carts} = parse(input)

    {x, y} = simulate_until_one_cart(tracks, carts)
    "#{x},#{y}"
  end

  defp parse(input) do
    lines = String.split(input, "\n")

    {tracks, carts} = lines
    |> Enum.with_index()
    |> Enum.reduce({%{}, []}, fn {line, y}, {tracks, carts} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce({tracks, carts}, fn {char, x}, {tr, ca} ->
        case char do
          "^" -> {Map.put(tr, {x, y}, "|"), [{x, y, :up, 0} | ca]}
          "v" -> {Map.put(tr, {x, y}, "|"), [{x, y, :down, 0} | ca]}
          "<" -> {Map.put(tr, {x, y}, "-"), [{x, y, :left, 0} | ca]}
          ">" -> {Map.put(tr, {x, y}, "-"), [{x, y, :right, 0} | ca]}
          " " -> {tr, ca}
          _ -> {Map.put(tr, {x, y}, char), ca}
        end
      end)
    end)

    {tracks, Enum.reverse(carts)}
  end

  defp simulate_until_crash(tracks, carts) do
    # Sort carts by position (top to bottom, left to right)
    sorted_carts = Enum.sort_by(carts, fn {x, y, _, _} -> {y, x} end)

    case tick(tracks, sorted_carts, []) do
      {:crash, x, y} -> {x, y}
      {:ok, new_carts} -> simulate_until_crash(tracks, new_carts)
    end
  end

  defp tick(_tracks, [], processed) do
    {:ok, Enum.reverse(processed)}
  end

  defp tick(tracks, [cart | remaining], processed) do
    {x, y, dir, turn_count} = cart
    {new_x, new_y} = move(x, y, dir)

    # Check for collision with remaining carts or processed carts
    collision_remaining = Enum.any?(remaining, fn {cx, cy, _, _} -> cx == new_x and cy == new_y end)
    collision_processed = Enum.any?(processed, fn {cx, cy, _, _} -> cx == new_x and cy == new_y end)

    if collision_remaining or collision_processed do
      {:crash, new_x, new_y}
    else
      track = Map.get(tracks, {new_x, new_y})
      {new_dir, new_turn_count} = update_direction(dir, track, turn_count)
      new_cart = {new_x, new_y, new_dir, new_turn_count}
      tick(tracks, remaining, [new_cart | processed])
    end
  end

  defp move(x, y, :up), do: {x, y - 1}
  defp move(x, y, :down), do: {x, y + 1}
  defp move(x, y, :left), do: {x - 1, y}
  defp move(x, y, :right), do: {x + 1, y}

  defp update_direction(dir, track, turn_count) do
    case track do
      "|" -> {dir, turn_count}
      "-" -> {dir, turn_count}
      "/" ->
        new_dir = case dir do
          :up -> :right
          :down -> :left
          :left -> :down
          :right -> :up
        end
        {new_dir, turn_count}
      "\\" ->
        new_dir = case dir do
          :up -> :left
          :down -> :right
          :left -> :up
          :right -> :down
        end
        {new_dir, turn_count}
      "+" ->
        new_dir = case rem(turn_count, 3) do
          0 -> turn_left(dir)
          1 -> dir
          2 -> turn_right(dir)
        end
        {new_dir, turn_count + 1}
    end
  end

  defp turn_left(:up), do: :left
  defp turn_left(:down), do: :right
  defp turn_left(:left), do: :down
  defp turn_left(:right), do: :up

  defp turn_right(:up), do: :right
  defp turn_right(:down), do: :left
  defp turn_right(:left), do: :up
  defp turn_right(:right), do: :down

  # Part 2: Remove crashed carts and continue
  defp simulate_until_one_cart(tracks, carts) do
    case length(carts) do
      1 ->
        [{x, y, _, _}] = carts
        {x, y}
      _ ->
        sorted_carts = Enum.sort_by(carts, fn {x, y, _, _} -> {y, x} end)
        new_carts = tick_remove_crashed(tracks, sorted_carts, [])
        simulate_until_one_cart(tracks, new_carts)
    end
  end

  defp tick_remove_crashed(_tracks, [], processed) do
    Enum.reverse(processed)
  end

  defp tick_remove_crashed(tracks, [cart | remaining], processed) do
    {x, y, dir, turn_count} = cart
    {new_x, new_y} = move(x, y, dir)

    # Check for collision
    collision_remaining_idx = Enum.find_index(remaining, fn {cx, cy, _, _} ->
      cx == new_x and cy == new_y
    end)
    collision_processed_idx = Enum.find_index(processed, fn {cx, cy, _, _} ->
      cx == new_x and cy == new_y
    end)

    cond do
      collision_remaining_idx != nil ->
        # Remove both carts: current one and the one it collided with
        new_remaining = List.delete_at(remaining, collision_remaining_idx)
        tick_remove_crashed(tracks, new_remaining, processed)

      collision_processed_idx != nil ->
        # Remove both: don't add current cart, remove from processed
        new_processed = List.delete_at(processed, collision_processed_idx)
        tick_remove_crashed(tracks, remaining, new_processed)

      true ->
        # No collision, move cart
        track = Map.get(tracks, {new_x, new_y})
        {new_dir, new_turn_count} = update_direction(dir, track, turn_count)
        new_cart = {new_x, new_y, new_dir, new_turn_count}
        tick_remove_crashed(tracks, remaining, [new_cart | processed])
    end
  end
end
