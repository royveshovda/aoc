import AOC

aoc 2023, 15 do
  @moduledoc """
  https://adventofcode.com/2023/day/15
  """

  @doc """
      iex> p1(example_string())
      1320

      iex> p1(input_string())
      505379
  """
  def p1(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  @doc """
      iex> p2(example_string())
      145

      iex> p2(input_string())
      263211
  """
  def p2(input) do
    boxes = for i <- 0..255, into: %{}, do: {i, []}
    
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.reduce(boxes, &process_step/2)
    |> Enum.map(&focusing_power/1)
    |> Enum.sum()
  end

  defp hash(str) do
    str
    |> String.to_charlist()
    |> Enum.reduce(0, fn char, acc ->
      rem((acc + char) * 17, 256)
    end)
  end

  defp process_step(step, boxes) do
    cond do
      String.contains?(step, "=") ->
        [label, focal] = String.split(step, "=")
        focal = String.to_integer(focal)
        box_num = hash(label)
        box = boxes[box_num]
        
        new_box = case Enum.find_index(box, fn {l, _} -> l == label end) do
          nil -> box ++ [{label, focal}]
          idx -> List.replace_at(box, idx, {label, focal})
        end
        
        Map.put(boxes, box_num, new_box)
        
      String.contains?(step, "-") ->
        label = String.trim_trailing(step, "-")
        box_num = hash(label)
        box = boxes[box_num]
        new_box = Enum.reject(box, fn {l, _} -> l == label end)
        Map.put(boxes, box_num, new_box)
    end
  end

  defp focusing_power({box_num, lenses}) do
    lenses
    |> Enum.with_index(1)
    |> Enum.map(fn {{_label, focal}, slot} ->
      (box_num + 1) * slot * focal
    end)
    |> Enum.sum()
  end
end
