import AOC

aoc 2021, 16 do
  @moduledoc """
  Day 16: Packet Decoder

  Decode nested binary packets.
  Part 1: Sum all version numbers
  Part 2: Evaluate the expression
  """

  @doc """
  Part 1: Sum all version numbers in the packet hierarchy.

  ## Examples

      iex> p1("8A004A801A8002F478")
      16

      iex> p1("620080001611562C8802118E34")
      12

      iex> p1("C0015000016115A2E0802F182340")
      23

      iex> p1("A0016C880162017C3686B18A3D4780")
      31
  """
  def p1(input) do
    {packet, _} =
      input
      |> String.trim()
      |> hex_to_binary()
      |> parse_packet()

    sum_versions(packet)
  end

  @doc """
  Part 2: Evaluate the packet expression.

  ## Examples

      iex> p2("C200B40A82")
      3

      iex> p2("04005AC33890")
      54

      iex> p2("880086C3E88112")
      7

      iex> p2("CE00C43D881120")
      9

      iex> p2("D8005AC2A8F0")
      1

      iex> p2("F600BC2D8F")
      0

      iex> p2("9C005AC2F8F0")
      0

      iex> p2("9C0141080250320F1802104A08")
      1
  """
  def p2(input) do
    {packet, _} =
      input
      |> String.trim()
      |> hex_to_binary()
      |> parse_packet()

    evaluate(packet)
  end

  defp hex_to_binary(hex) do
    hex
    |> String.graphemes()
    |> Enum.map(fn char ->
      char
      |> String.to_integer(16)
      |> Integer.to_string(2)
      |> String.pad_leading(4, "0")
    end)
    |> Enum.join()
  end

  defp parse_packet(bits) do
    <<version::binary-size(3), type_id::binary-size(3), rest::binary>> = bits
    version = String.to_integer(version, 2)
    type_id = String.to_integer(type_id, 2)

    case type_id do
      4 ->
        {value, rest} = parse_literal(rest)
        {{:literal, version, value}, rest}

      _ ->
        {sub_packets, rest} = parse_operator(rest)
        {{:operator, version, type_id, sub_packets}, rest}
    end
  end

  defp parse_literal(bits), do: parse_literal(bits, "")

  defp parse_literal(bits, acc) do
    <<flag::binary-size(1), chunk::binary-size(4), rest::binary>> = bits
    acc = acc <> chunk

    if flag == "1" do
      parse_literal(rest, acc)
    else
      {String.to_integer(acc, 2), rest}
    end
  end

  defp parse_operator(bits) do
    <<length_type::binary-size(1), rest::binary>> = bits

    case length_type do
      "0" ->
        # Next 15 bits = total length of sub-packets in bits
        <<length::binary-size(15), rest::binary>> = rest
        length = String.to_integer(length, 2)
        <<sub_bits::binary-size(length), rest::binary>> = rest
        {parse_all_packets(sub_bits), rest}

      "1" ->
        # Next 11 bits = number of sub-packets
        <<count::binary-size(11), rest::binary>> = rest
        count = String.to_integer(count, 2)
        parse_n_packets(rest, count)
    end
  end

  defp parse_all_packets(""), do: []
  defp parse_all_packets(bits) when bit_size(bits) < 8, do: []

  defp parse_all_packets(bits) do
    {packet, rest} = parse_packet(bits)
    [packet | parse_all_packets(rest)]
  end

  defp parse_n_packets(bits, 0), do: {[], bits}

  defp parse_n_packets(bits, n) do
    {packet, rest} = parse_packet(bits)
    {packets, rest} = parse_n_packets(rest, n - 1)
    {[packet | packets], rest}
  end

  defp sum_versions({:literal, version, _}), do: version

  defp sum_versions({:operator, version, _, sub_packets}) do
    version + Enum.sum(Enum.map(sub_packets, &sum_versions/1))
  end

  defp evaluate({:literal, _, value}), do: value

  defp evaluate({:operator, _, type_id, sub_packets}) do
    values = Enum.map(sub_packets, &evaluate/1)

    case type_id do
      0 -> Enum.sum(values)
      1 -> Enum.product(values)
      2 -> Enum.min(values)
      3 -> Enum.max(values)
      5 -> if Enum.at(values, 0) > Enum.at(values, 1), do: 1, else: 0
      6 -> if Enum.at(values, 0) < Enum.at(values, 1), do: 1, else: 0
      7 -> if Enum.at(values, 0) == Enum.at(values, 1), do: 1, else: 0
    end
  end
end
