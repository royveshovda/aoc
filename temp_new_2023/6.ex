import AOC

aoc 2023, 6 do
  @moduledoc """
  https://adventofcode.com/2023/day/6
  """

  @doc """
      iex> p1(example_string())
      288

      iex> p1(input_string())
      4568778
  """
  def p1(input) do
    input
    |> parse_p1()
    |> Enum.map(&ways_to_win/1)
    |> Enum.product()
  end

  @doc """
      iex> p2(example_string())
      71503

      iex> p2(input_string())
      28973936
  """
  def p2(input) do
    input
    |> parse_p2()
    |> ways_to_win()
  end

  defp parse_p1(input) do
    [time_line, dist_line] = String.split(input, "\n", trim: true)
    times = time_line |> String.split() |> tl() |> Enum.map(&String.to_integer/1)
    dists = dist_line |> String.split() |> tl() |> Enum.map(&String.to_integer/1)
    Enum.zip(times, dists)
  end

  defp parse_p2(input) do
    [time_line, dist_line] = String.split(input, "\n", trim: true)
    time = time_line |> String.replace(~r/[^\d]/, "") |> String.to_integer()
    dist = dist_line |> String.replace(~r/[^\d]/, "") |> String.to_integer()
    {time, dist}
  end

  # Using quadratic formula: distance = hold * (time - hold) = -hold^2 + time*hold
  # We want: -hold^2 + time*hold > record
  # => hold^2 - time*hold + record < 0
  # Roots: hold = (time ± sqrt(time^2 - 4*record)) / 2
  defp ways_to_win({time, record}) do
    discriminant = time * time - 4 * record
    sqrt_disc = :math.sqrt(discriminant)
    
    low = (time - sqrt_disc) / 2
    high = (time + sqrt_disc) / 2
    
    # We need strictly greater than record, so adjust for exact matches
    low_int = floor(low + 1)
    high_int = ceil(high - 1)
    
    max(0, high_int - low_int + 1)
  end
end
