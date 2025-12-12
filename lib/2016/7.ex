import AOC

aoc 2016, 7 do
  @moduledoc """
  https://adventofcode.com/2016/day/7
  Day 7: IPv7 TLS and SSL support
  """

  def p1(input) do
    input
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.count(&supports_tls?/1)
  end

  def p2(input) do
    input
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.count(&supports_ssl?/1)
  end

  defp supports_tls?(ip) do
    {supernet, hypernet} = parse_ip(ip)

    Enum.any?(supernet, &has_abba?/1) and not Enum.any?(hypernet, &has_abba?/1)
  end

  defp supports_ssl?(ip) do
    {supernet, hypernet} = parse_ip(ip)

    abas = supernet |> Enum.flat_map(&find_abas/1) |> MapSet.new()
    babs = hypernet |> Enum.flat_map(&find_abas/1) |> MapSet.new()

    Enum.any?(abas, fn aba -> corresponding_bab(aba) in babs end)
  end

  defp parse_ip(ip) do
    parts = Regex.split(~r/[\[\]]/, ip)
    supernet = parts |> Enum.take_every(2)
    hypernet = parts |> Enum.drop(1) |> Enum.take_every(2)
    {supernet, hypernet}
  end

  defp has_abba?(str) do
    str
    |> String.graphemes()
    |> Enum.chunk_every(4, 1, :discard)
    |> Enum.any?(fn [a, b, c, d] -> a == d and b == c and a != b end)
  end

  defp find_abas(str) do
    str
    |> String.graphemes()
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.filter(fn [a, b, c] -> a == c and a != b end)
    |> Enum.map(&Enum.join/1)
  end

  defp corresponding_bab(<<a, b, _>>), do: <<b, a, b>>
end
