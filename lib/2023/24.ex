import AOC

aoc 2023, 24 do
  @moduledoc """
  https://adventofcode.com/2023/day/24
  """

  @doc """
      iex> p1(example_string(), 7, 27)
      2

      iex> p1(input_string(), 200_000_000_000_000, 400_000_000_000_000)
      20847
  """
  def p1(input, min \\ 7, max \\ 27) do
    particles =
      input
      |> String.split("\n")
      |> Enum.map(&line_to_particle/1)
      |> Enum.map(&trim_to_two_coord/1)

    comb(2, particles)
    |> Enum.map(fn [p1, p2] -> check_if_intersect(p1, p2, min, max) end)
    |> Enum.filter(&(&1))
    |> Enum.count()
  end

  def comb(0, _), do: [[]]
  def comb(_, []), do: []
  def comb(m, [h|t]) do
    (for l <- comb(m-1, t), do: [h|l]) ++ comb(m, t)
  end

  def line_to_particle(line) do
    [position, velocity] = String.split(line, " @ ", trim: true)
    [x,y,z] = position |> String.split(", ", trim: true) |> Enum.map(&String.trim/1) |> Enum.map(&String.to_integer/1)
    [vx,vy,vz] = velocity |> String.split(", ", trim: true) |> Enum.map(&String.trim/1) |> Enum.map(&String.to_integer/1)
    {{x,y,z}, {vx,vy,vz}}
  end

  def trim_to_two_coord({{px, py, _pz}, {vx, vy, _vz}}) do
    {{px, py}, {vx, vy}}
  end

  def check_if_intersect({{apx, apy}, {avx, avy}}, {{bpx, bpy}, {bvx, bvy}}, boundary_min, boundary_max) do
    ma = avy / avx
    mb = bvy / bvx
    ca = apy - (ma * apx)
    cb = bpy - (mb * bpx)
    case ma - mb == 0 do
      true -> false
      false ->
        xpos = (cb - ca) / (ma - mb)
        ypos = ma * xpos + ca

        case (xpos < apx and avx > 0) or (xpos > apx and avx < 0) or (xpos < bpx and bvx > 0) or (xpos > bpx and bvx < 0) do
          true -> false
          false ->
            case (boundary_min <= xpos and xpos <= boundary_max) and (boundary_min <= ypos and ypos <= boundary_max) do
              true -> true
              false -> false
            end
        end
    end
  end

  @doc """
      iex> p2(example_string())
  """
  def p2(input) do
    input
  end


end
