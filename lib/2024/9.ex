import AOC

aoc 2024, 9 do
  @moduledoc """
  https://adventofcode.com/2024/day/9
  """

  def p1(input) do
    {start, _next_file_id, disk_raw} =
      input
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.zip(Stream.cycle([:file, :free]))
      |> Enum.reduce({0, 0, []}, fn {x_len, type}, {current_index, file_id, all} ->
         {current_index + x_len, get_next_file_id_step(type, file_id), all ++ expand(current_index, x_len, type, file_id)}
       end)

      disk = disk_raw |> Enum.map(fn {index, type, file_id} -> {index, {type, file_id}} end) |> Enum.into(%{})

      new_disk = compact_disk(disk, start - 1)
      checksum(new_disk)
  end

  def expand(_current_index, 0, _type, _file_id) do
    []
  end

  def expand(current_index, x_len, type, file_id) do
    (for i <- current_index..(current_index + x_len - 1), do: get_file_index_step(i, type, file_id))
  end

  def get_next_file_id_step(type, file_id) do
    case type do
      :file -> file_id + 1
      :free -> file_id
    end
  end

  def get_file_index_step(index, type, file_id) do
    case type do
      :file -> {index, :file, file_id}
      :free -> {index, :free, -1}
    end
  end


  def checksum(disk) do
    disk
    |> Enum.filter(fn {_, {type, _}} -> type == :file end)
    |> Enum.sort(fn {index_a, _}, {index_b, _} -> index_a < index_b end)
    |> Enum.map(fn {index, {_type, file_id}} -> index * file_id end)
    |> Enum.sum()
  end

  def compact_disk(disk, current_index_to_move) do
    free_index = get_first_free(disk)
    case free_index >= current_index_to_move do
      true -> disk
      false -> compact_disk(swap_positions(disk, free_index, current_index_to_move), current_index_to_move - 1)
    end
  end

  def swap_positions(disk, a, b) do
    a_val = disk[a]
    b_val = disk[b]
    Map.replace(disk, a, b_val) |> Map.replace(b, a_val)
  end

  def get_first_free(disk) do
    # find smallest index in disk map where value is :free
    disk
    |> Enum.filter(fn {_, {type, _id}} -> type == :free end)
    |> Enum.map(fn {index, _} -> index end)
    |> Enum.min()
  end

  def p2(input) do
    {_start, next_file_id, disk_raw} =
      input
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.zip(Stream.cycle([:file, :free]))
      |> Enum.reduce({0, 0, []}, fn {x_len, type}, {current_index, file_id, all} ->
         {current_index + x_len, get_next_file_id_step(type, file_id), all ++ expand(current_index, x_len, type, file_id)}
       end)

    disk = disk_raw |> Enum.map(fn {index, type, file_id} -> {index, {type, file_id}} end) |> Enum.into(%{})

    start_file_id = next_file_id - 1

    file_ids = start_file_id..0//-1 |> Enum.to_list()
    new_disk = Enum.reduce(file_ids, disk, fn file_id, acc -> process_file_by_id(acc, file_id) end)

    checksum(new_disk)
  end

  def process_file_by_id(disk, file_id) do
    file = get_file_by_id(disk, file_id)
    free_space = get_first_free_of_size(disk, file |> Enum.count())
    case should_move_file(file, free_space) do
      true ->
        swap_file_to_index(disk, file, free_space)
      false -> disk
    end
  end

  def should_move_file(_file, nil), do: false

  def should_move_file(file, free_space_index) do
    first_file_index = file |> Enum.map(fn {index, _} -> index end) |> Enum.min()
    first_file_index > free_space_index
  end

  def swap_file_to_index(disk, [], _to_index) do
    disk
  end

  def swap_file_to_index(disk, [{segment_index, _segment} | rest_of_file], to_index) do
    new_disk = swap_positions(disk, segment_index, to_index)
    swap_file_to_index(new_disk, rest_of_file, to_index + 1)
  end

  def get_file_by_id(disk, file_id) do
    disk
    |> Enum.filter(fn {_, {type, id}} -> type == :file and id == file_id end)
    #|> Enum.map(fn {index, _} -> index end)
  end

  def get_first_free_of_size(disk, size) do
    space =
      disk
      |> Enum.filter(fn {_, {type, _id}} -> type == :free end)
      |> Enum.map(fn {index, _} -> index end)
      |> Enum.sort()
      |> Enum.chunk_every(size, 1, :discard)
      |> Enum.find(fn chunk -> Enum.chunk_every(chunk, 2, 1, :discard) |> Enum.all?(fn [a, b] -> b == a + 1 end) end)
    case space do
      nil -> nil
      _ -> Enum.min(space)
    end
  end
end
