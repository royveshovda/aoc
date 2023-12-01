import AOC

aoc 2023, 1 do
  @doc """
      iex> p1(example_input())
      # 142
  """
  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(fn x -> Enum.filter(x, &integer?/1) end)
    |> Enum.map(fn x -> [Enum.at(x,0) , Enum.at(x,-1)] end)
    |> Enum.map(fn x -> Enum.join(x, "") |> String.to_integer() end)
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&convert_to_digits/1)
    |> Enum.map(fn x -> Enum.filter(x, &integer?/1) end)
    |> Enum.map(fn x -> [Enum.at(x,0) , Enum.at(x,-1)] end)
    |> Enum.map(fn x -> Enum.join(x, "") |> String.to_integer() end)
    |> Enum.sum()
  end

  defp integer?(char) do
    case Integer.parse(char) do
      {_number, ""} -> true
      :error -> false
    end
  end

  def convert_to_digits(["o", "n", "e" | rest]), do: ["1" | convert_to_digits(["e" | rest])]
  def convert_to_digits(["t", "w", "o" | rest]), do: ["2" | convert_to_digits(["o" | rest])]
  def convert_to_digits(["t", "h", "r", "e", "e" | rest]), do: ["3" | convert_to_digits(["e" | rest])]
  def convert_to_digits(["f", "o", "u", "r" | rest]), do: ["4" | convert_to_digits(rest)]
  def convert_to_digits(["f", "i", "v", "e" | rest]), do: ["5" | convert_to_digits(["e" | rest])]
  def convert_to_digits(["s", "i", "x" | rest]), do: ["6" | convert_to_digits(rest)]
  def convert_to_digits(["s", "e", "v", "e", "n" | rest]), do: ["7" | convert_to_digits(["n" | rest])]
  def convert_to_digits(["e", "i", "g", "h", "t" | rest]), do: ["8" | convert_to_digits([ "t" | rest])]
  def convert_to_digits(["n", "i", "n", "e" | rest]), do: ["9" | convert_to_digits(["e" | rest])]
  def convert_to_digits([x | rest]), do: [x | convert_to_digits(rest)]
  def convert_to_digits([]), do: []

  def example_input do
    """
    1abc2
    pqr3stu8vwx
    a1b2c3d4e5f
    treb7uchet
    """
  end
end
