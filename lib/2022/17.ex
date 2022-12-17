# Source: https://github.com/flwyd/adventofcode/blob/main/2022/day17/day17.exs

import AOC

aoc 2022, 17 do

  defmodule Jetstream do
    defstruct line: "", index: 0

    def new(line), do: %Jetstream{line: line}

    @left {-1, 0}
    @right {1, 0}
    def next_move(%Jetstream{line: l, index: i} = jets) do
      move =
        case String.at(l, i) do
          "<" -> @left
          ">" -> @right
        end

      {struct!(jets, index: rem(i + 1, String.length(l))), move}
    end
  end

  @rock_shapes [
    # horizontal line: _
    [{2, -4}, {3, -4}, {4, -4}, {5, -4}],
    # plus: +
    [{3, -4}, {2, -5}, {3, -5}, {4, -5}, {3, -6}],
    # corner: J
    [{2, -4}, {3, -4}, {4, -4}, {4, -5}, {4, -6}],
    # vertical line: |
    [{2, -4}, {2, -5}, {2, -6}, {2, -7}],
    # square: #
    [{2, -4}, {3, -4}, {2, -5}, {3, -5}]
  ]
  @num_rocks Enum.count(@rock_shapes)

  @small_num 2022

  def p1(input) do
    rocks = Enum.take(Stream.cycle(@rock_shapes), @small_num)

    {height, stack, _jets} =
      Enum.reduce(rocks, {0, [], Jetstream.new(input)}, fn rock, {height, stack, jets} ->
        drop_rock(rock, height, stack, jets)
      end)

    IO.puts(:stderr, "top 25 of stack are ")
    print_stack(Enum.take(stack, 25))
    height
  end


  @look_depth 8
  @big_num 1_000_000_000_000
  @doc "Compute the stack height after one trillion iterations"
  def p2(input) do
    rocks = Stream.cycle(@rock_shapes)
    jets = Jetstream.new(input)
    cache = :ets.new(:cache, [:set])

    {height, stack, _jets, _i} =
      Enum.reduce_while(rocks, {0, [], jets, 0}, fn rock, {height, stack, jets, i} ->
        if i == @big_num do
          {:halt, {height, stack, jets, i}}
        else
          key = {rem(i, @num_rocks), jets.index, Enum.take(stack, @look_depth)}

          {full_height, iter} =
            if @big_num - i <= String.length(jets.line) do
              {height, i}
            else
              case :ets.lookup(cache, key) do
                [] ->
                  true = :ets.insert_new(cache, {key, {i, height}})
                  {height, i}

                [{_, {prev_i, prev_height}}] ->
                  with gap <- i - prev_i, chunk_height = height - prev_height do
                    factor = div(@big_num - i, gap)
                    new_i = i + gap * factor
                    new_height = height + chunk_height * factor
                    {new_height, new_i}
                  end
              end
            end

          {:cont, Tuple.append(drop_rock(rock, full_height, stack, jets), iter + 1)}
        end
      end)

    IO.puts(:stderr, "top 25 of stack are ")
    print_stack(Enum.take(stack, 25))
    :ets.delete(cache)
    height
  end

  @down {0, 1}
  defp drop_rock(rock, height, stack, jets) do
    {moved, jets} =
      Enum.reduce_while(Stream.cycle([nil]), {rock, jets}, fn nil, {rock, jets} ->
        {jets, move} = Jetstream.next_move(jets)
        shifted = move(rock, move)
        r = if allowed?(shifted, height, stack), do: shifted, else: rock
        down = move(r, @down)
        if allowed?(down, height, stack), do: {:cont, {down, jets}}, else: {:halt, {r, jets}}
      end)

    {height, stack} = place_rock(moved, height, stack)
    {height, stack, jets}
  end

  defp move(rock, {dx, dy}), do: Enum.map(rock, fn {x, y} -> {x + dx, y + dy} end)

  defp allowed?(rock, height, stack) do
    !Enum.any?(rock, fn {x, y} -> x < 0 || x >= 7 || y >= height end) &&
      Enum.all?(rock, fn {x, y} -> y < 0 || Enum.at(stack, y) |> Enum.at(x) == :clear end)
  end

  defp place_rock(rock, height, stack) do
    get_y = &elem(&1, 1)
    min_y = Enum.map(rock, get_y) |> Enum.min()
    min_y_or_zero = min(min_y, 0)
    new_rows = List.duplicate(List.duplicate(:clear, 7), -1 * min_y_or_zero)

    new_stack =
      Enum.reduce(rock, new_rows ++ stack, fn {x, y}, st ->
        List.update_at(st, y - min_y_or_zero, fn list -> List.replace_at(list, x, :blocked) end)
      end)

    {height - min_y_or_zero, new_stack}
  end

  @pixels %{clear: '.', blocked: '#'}
  def print_stack(stack) do
    Enum.map(stack, fn line -> IO.puts(:stderr, '|' ++ Enum.map(line, &@pixels[&1]) ++ '|') end)
    IO.puts(:stderr, "+-------+")
  end
end
