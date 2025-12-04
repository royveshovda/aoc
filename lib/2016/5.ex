import AOC

aoc 2016, 5 do
  @moduledoc """
  https://adventofcode.com/2016/day/5
  Day 5: MD5 password cracking
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    door_id = String.trim(input)
    find_password_simple(door_id, 0, [])
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    door_id = String.trim(input)
    find_password_complex(door_id, 0, %{})
  end

  defp find_password_simple(_door_id, _index, acc) when length(acc) == 8 do
    acc |> Enum.reverse() |> Enum.join()
  end

  defp find_password_simple(door_id, index, acc) do
    hash = :crypto.hash(:md5, door_id <> Integer.to_string(index)) |> Base.encode16(case: :lower)

    if String.starts_with?(hash, "00000") do
      char = String.at(hash, 5)
      find_password_simple(door_id, index + 1, [char | acc])
    else
      find_password_simple(door_id, index + 1, acc)
    end
  end

  defp find_password_complex(_door_id, _index, acc) when map_size(acc) == 8 do
    0..7 |> Enum.map(fn i -> acc[i] end) |> Enum.join()
  end

  defp find_password_complex(door_id, index, acc) do
    hash = :crypto.hash(:md5, door_id <> Integer.to_string(index)) |> Base.encode16(case: :lower)

    if String.starts_with?(hash, "00000") do
      pos_char = String.at(hash, 5)
      value_char = String.at(hash, 6)

      case Integer.parse(pos_char) do
        {pos, ""} when pos in 0..7 and not is_map_key(acc, pos) ->
          find_password_complex(door_id, index + 1, Map.put(acc, pos, value_char))
        _ ->
          find_password_complex(door_id, index + 1, acc)
      end
    else
      find_password_complex(door_id, index + 1, acc)
    end
  end
end
