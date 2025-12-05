import AOC

aoc 2024, 9 do
  @moduledoc """
  https://adventofcode.com/2024/day/9

  Disk Fragmenter - Compact disk by moving blocks or whole files.
  """

  def p1(input) do
    disk = parse(input)
    compact_blocks(disk)
    |> checksum()
  end

  def p2(input) do
    {files, spaces} = parse_segments(input)
    compact_files(files, spaces)
    |> checksum()
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.flat_map(fn {len, idx} ->
      if rem(idx, 2) == 0 do
        List.duplicate(div(idx, 2), len)
      else
        List.duplicate(nil, len)
      end
    end)
    |> :array.from_list()
  end

  defp compact_blocks(disk) do
    size = :array.size(disk)
    compact_blocks(disk, 0, size - 1)
  end

  defp compact_blocks(disk, left, right) when left >= right, do: disk
  defp compact_blocks(disk, left, right) do
    left_val = :array.get(left, disk)
    right_val = :array.get(right, disk)

    cond do
      left_val != nil -> compact_blocks(disk, left + 1, right)
      right_val == nil -> compact_blocks(disk, left, right - 1)
      true ->
        disk = :array.set(left, right_val, disk)
        disk = :array.set(right, nil, disk)
        compact_blocks(disk, left + 1, right - 1)
    end
  end

  defp parse_segments(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce({[], [], 0}, fn {len, idx}, {files, spaces, pos} ->
      if rem(idx, 2) == 0 do
        file_id = div(idx, 2)
        {[{file_id, pos, len} | files], spaces, pos + len}
      else
        {files, [{pos, len} | spaces], pos + len}
      end
    end)
    |> then(fn {files, spaces, _} -> {Enum.reverse(files), Enum.reverse(spaces)} end)
  end

  defp compact_files(files, spaces) do
    # Process files from highest ID to lowest
    files_sorted = Enum.sort_by(files, fn {id, _, _} -> -id end)

    {moved_files, _} =
      Enum.reduce(files_sorted, {[], spaces}, fn {id, pos, len}, {acc, sp} ->
        case find_space(sp, len, pos) do
          nil -> {[{id, pos, len} | acc], sp}
          {space_pos, space_idx} ->
            new_spaces = update_spaces(sp, space_idx, len)
            {[{id, space_pos, len} | acc], new_spaces}
        end
      end)

    # Convert to array
    max_pos = Enum.max(Enum.map(moved_files, fn {_, p, l} -> p + l end))
    disk = :array.new(max_pos, default: nil)

    Enum.reduce(moved_files, disk, fn {id, pos, len}, d ->
      Enum.reduce(0..(len-1), d, fn i, d2 -> :array.set(pos + i, id, d2) end)
    end)
  end

  defp find_space(spaces, needed_len, max_pos) do
    spaces
    |> Enum.with_index()
    |> Enum.find_value(fn {{pos, len}, idx} ->
      if len >= needed_len and pos < max_pos, do: {pos, idx}
    end)
  end

  defp update_spaces(spaces, idx, used_len) do
    {pos, len} = Enum.at(spaces, idx)
    if len == used_len do
      List.delete_at(spaces, idx)
    else
      List.replace_at(spaces, idx, {pos + used_len, len - used_len})
    end
  end

  defp checksum(disk) do
    0..(:array.size(disk) - 1)
    |> Enum.reduce(0, fn i, sum ->
      case :array.get(i, disk) do
        nil -> sum
        id -> sum + i * id
      end
    end)
  end
end
