import AOC

aoc 2021, 13 do
  @moduledoc """
  Day 13: Transparent Origami

  Fold a transparent paper with dots.
  Part 1: Count dots after first fold
  Part 2: Read the code after all folds
  """

  @doc """
  Part 1: Count visible dots after the first fold.

  ## Examples

      iex> p1("6,10\\n0,14\\n9,10\\n0,3\\n10,4\\n4,11\\n6,0\\n6,12\\n4,1\\n0,13\\n10,12\\n3,4\\n3,0\\n8,4\\n1,10\\n2,14\\n8,10\\n9,0\\n\\nfold along y=7\\nfold along x=5")
      17
  """
  def p1(input) do
    {dots, [first_fold | _]} = parse(input)

    dots
    |> fold(first_fold)
    |> MapSet.size()
  end

  @doc """
  Part 2: Apply all folds and render the result.
  Returns the 8-letter code visible on the paper.
  """
  def p2(input) do
    {dots, folds} = parse(input)

    final_dots = Enum.reduce(folds, dots, &fold(&2, &1))

    render(final_dots)
  end

  defp fold(dots, {:x, line}) do
    dots
    |> Enum.map(fn {x, y} ->
      if x > line do
        {2 * line - x, y}
      else
        {x, y}
      end
    end)
    |> MapSet.new()
  end

  defp fold(dots, {:y, line}) do
    dots
    |> Enum.map(fn {x, y} ->
      if y > line do
        {x, 2 * line - y}
      else
        {x, y}
      end
    end)
    |> MapSet.new()
  end

  defp render(dots) do
    max_x = dots |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = dots |> Enum.map(&elem(&1, 1)) |> Enum.max()

    for y <- 0..max_y do
      for x <- 0..max_x do
        if MapSet.member?(dots, {x, y}), do: "#", else: " "
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
  end

  defp parse(input) do
    [dots_section, folds_section] = String.split(input, "\n\n", trim: true)

    dots =
      dots_section
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [x, y] = String.split(line, ",") |> Enum.map(&String.to_integer/1)
        {x, y}
      end)
      |> MapSet.new()

    folds =
      folds_section
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [_, axis, value] = Regex.run(~r/fold along (x|y)=(\d+)/, line)
        {String.to_atom(axis), String.to_integer(value)}
      end)

    {dots, folds}
  end
end
