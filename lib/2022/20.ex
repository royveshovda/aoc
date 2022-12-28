import AOC

aoc 2022, 20 do
  def p1(input) do
    start =
      input
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.map(fn {v, i} -> %{current: i, orig: i, value: v} end)

    l = length(start)

    new_grid =
      Enum.reduce(0..(l-1), start, fn x, acc ->
        move(acc, x, l)
      end)
      |> Enum.filter(fn x -> x.current in [1000,2000,3000] end)
      #|> Enum.sort_by(& &1.current)
      |> Enum.map(& &1.value)
      #|> Enum.sum()

    # new_grid
    # |> IO.inspect(label: "New Grid")

    #|> Enum.map(& &1.value)
    #|> Enum.sum()

    # Correct: 9687
  end

  def move(list, position, length) do
    #IO.puts("Position: #{position} -- #{length} -- List: #{inspect(list)}")
    IO.puts("Position: #{position}")
    current = Enum.find(list, fn x -> x.orig == position end)

    current_index = current.current
    new_index = Integer.mod(current_index + current.value - 1, (length-1)) + 1
    #curr = (prev + number - 1) % (N - 1) + 1
    #IO.puts("Current: #{current_index}, New: #{new_index}")

    case new_index > current_index do
      true ->
        list
        |> Enum.map(fn x ->
          if x.orig != position and x.current > current_index and x.current <= new_index do
            %{x | current: x.current - 1}
          else
            x
          end
        end)
      false ->
        list
        |> Enum.map(fn x ->
          if x.orig != position and x.current < current_index and x.current >= new_index do
            %{x | current: x.current + 1}
          else
            x
          end
        end)
    end
    |> Enum.map(fn x ->
      if x.orig == position do
        %{x | current: new_index}
      else
        x
      end
    end)
    #|> IO.inspect(label: "New List")

  end

  def p2(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end
end
