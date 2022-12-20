import AOC

aoc 2022, 20 do
  def p1(input) do
    start =
      input
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.map(fn {v, i} -> %{current: i, orig: i, value: v} end)

    l = length(start) - 1

    i = 0


    #move(start, i, l)
    new_grid =
      Enum.reduce(0..l, start, fn x, acc ->
      #Enum.reduce(0..2, start, fn x, acc ->
        move(acc, x, l)
      end)
      |> Enum.sort_by(& &1.current)
      |> Enum.map(& &1.value)
  end

  def move(list, position, length) do
    IO.puts("Position: #{position} -- #{length} -- List: #{inspect(list)}")
    current = Enum.find(list, fn x -> x.orig == position end)

    current_index = current.current
    new_index = Integer.mod(current_index + current.value, length)
    IO.puts("Current: #{current_index}, New: #{new_index}")

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
          if x.orig != position and x.current <= current_index and x.current > new_index do
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
    |> IO.inspect(label: "New List")

  end

  def p2(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end
end
