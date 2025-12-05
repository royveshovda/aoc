import AOC

aoc 2019, 23 do
  @moduledoc """
  https://adventofcode.com/2019/day/23

  Category Six - Network of 50 Intcode computers.
  Part 1: First Y sent to address 255
  Part 2: NAT sends to 0 when idle. First Y sent twice in a row.
  """

  def p1(input) do
    mem = parse(input)

    # Initialize 50 computers, each gets its address as first input
    computers =
      for i <- 0..49, into: %{} do
        {i, %{mem: mem, ip: 0, rb: 0, inputs: [i], outputs: []}}
      end

    run_network_p1(computers)
  end

  def p2(input) do
    mem = parse(input)

    computers =
      for i <- 0..49, into: %{} do
        {i, %{mem: mem, ip: 0, rb: 0, inputs: [i], outputs: []}}
      end

    run_network_p2(computers, nil, nil)
  end

  defp run_network_p1(computers) do
    # Run one instruction on each computer, collect packets
    {computers, packets} =
      Enum.reduce(0..49, {computers, []}, fn i, {comps, pkts} ->
        comp = Map.get(comps, i)
        {new_comp, new_pkts} = step_computer(comp)
        {Map.put(comps, i, new_comp), pkts ++ new_pkts}
      end)

    # Check for packet to 255
    case Enum.find(packets, fn {dest, _, _} -> dest == 255 end) do
      {255, _x, y} -> y
      nil ->
        # Deliver packets
        computers = deliver_packets(computers, packets)
        run_network_p1(computers)
    end
  end

  defp run_network_p2(computers, nat_packet, last_nat_y) do
    # Run multiple steps to let network settle
    {computers, packets, idle_count} = run_steps(computers, [], 0, 100)

    # Update NAT with latest 255 packet
    nat_packet =
      packets
      |> Enum.filter(fn {dest, _, _} -> dest == 255 end)
      |> List.last()
      |> case do
        nil -> nat_packet
        {255, x, y} -> {x, y}
      end

    # Deliver non-255 packets
    other_packets = Enum.reject(packets, fn {dest, _, _} -> dest == 255 end)
    computers = deliver_packets(computers, other_packets)

    # Check if network is idle
    all_queues_empty = Enum.all?(computers, fn {_, c} -> c.inputs == [] end)

    if idle_count > 50 and all_queues_empty and nat_packet != nil do
      {x, y} = nat_packet

      if y == last_nat_y do
        y
      else
        # Send NAT packet to computer 0
        comp0 = Map.get(computers, 0)
        comp0 = %{comp0 | inputs: comp0.inputs ++ [x, y]}
        computers = Map.put(computers, 0, comp0)
        run_network_p2(computers, nat_packet, y)
      end
    else
      run_network_p2(computers, nat_packet, last_nat_y)
    end
  end

  defp run_steps(computers, packets, idle_count, 0), do: {computers, packets, idle_count}
  defp run_steps(computers, packets, idle_count, steps) do
    {computers, new_packets, was_idle} =
      Enum.reduce(0..49, {computers, [], true}, fn i, {comps, pkts, idle} ->
        comp = Map.get(comps, i)
        {new_comp, new_pkts} = step_computer(comp)

        # Track if any computer did actual work
        comp_idle = new_pkts == [] and comp.inputs == [] and new_comp.inputs == []

        {Map.put(comps, i, new_comp), pkts ++ new_pkts, idle and comp_idle}
      end)

    new_idle_count = if was_idle, do: idle_count + 1, else: 0

    run_steps(computers, packets ++ new_packets, new_idle_count, steps - 1)
  end

  defp deliver_packets(computers, packets) do
    Enum.reduce(packets, computers, fn {dest, x, y}, comps ->
      if dest >= 0 and dest <= 49 do
        comp = Map.get(comps, dest)
        comp = %{comp | inputs: comp.inputs ++ [x, y]}
        Map.put(comps, dest, comp)
      else
        comps
      end
    end)
  end

  # Run one instruction on a computer, return packets generated
  defp step_computer(comp) do
    %{mem: mem, ip: ip, rb: rb, inputs: inputs, outputs: outputs} = comp

    instruction = Map.get(mem, ip, 0)
    opcode = rem(instruction, 100)
    modes = div(instruction, 100)

    case opcode do
      99 ->
        # Halt - return current state
        {comp, []}

      1 ->
        a = get_param(mem, ip + 1, rem(modes, 10), rb)
        b = get_param(mem, ip + 2, rem(div(modes, 10), 10), rb)
        dest = get_addr(mem, ip + 3, rem(div(modes, 100), 10), rb)
        mem = Map.put(mem, dest, a + b)
        step_computer(%{comp | mem: mem, ip: ip + 4})

      2 ->
        a = get_param(mem, ip + 1, rem(modes, 10), rb)
        b = get_param(mem, ip + 2, rem(div(modes, 10), 10), rb)
        dest = get_addr(mem, ip + 3, rem(div(modes, 100), 10), rb)
        mem = Map.put(mem, dest, a * b)
        step_computer(%{comp | mem: mem, ip: ip + 4})

      3 ->
        # Input - use -1 if queue empty
        {val, new_inputs} =
          case inputs do
            [] -> {-1, []}
            [h | t] -> {h, t}
          end
        dest = get_addr(mem, ip + 1, rem(modes, 10), rb)
        mem = Map.put(mem, dest, val)
        {%{comp | mem: mem, ip: ip + 2, inputs: new_inputs}, []}

      4 ->
        # Output
        val = get_param(mem, ip + 1, rem(modes, 10), rb)
        new_outputs = outputs ++ [val]

        # Check if we have a complete packet (3 values)
        if length(new_outputs) == 3 do
          [dest, x, y] = new_outputs
          {%{comp | ip: ip + 2, outputs: []}, [{dest, x, y}]}
        else
          step_computer(%{comp | ip: ip + 2, outputs: new_outputs})
        end

      5 ->
        a = get_param(mem, ip + 1, rem(modes, 10), rb)
        b = get_param(mem, ip + 2, rem(div(modes, 10), 10), rb)
        new_ip = if a != 0, do: b, else: ip + 3
        step_computer(%{comp | ip: new_ip})

      6 ->
        a = get_param(mem, ip + 1, rem(modes, 10), rb)
        b = get_param(mem, ip + 2, rem(div(modes, 10), 10), rb)
        new_ip = if a == 0, do: b, else: ip + 3
        step_computer(%{comp | ip: new_ip})

      7 ->
        a = get_param(mem, ip + 1, rem(modes, 10), rb)
        b = get_param(mem, ip + 2, rem(div(modes, 10), 10), rb)
        dest = get_addr(mem, ip + 3, rem(div(modes, 100), 10), rb)
        mem = Map.put(mem, dest, if(a < b, do: 1, else: 0))
        step_computer(%{comp | mem: mem, ip: ip + 4})

      8 ->
        a = get_param(mem, ip + 1, rem(modes, 10), rb)
        b = get_param(mem, ip + 2, rem(div(modes, 10), 10), rb)
        dest = get_addr(mem, ip + 3, rem(div(modes, 100), 10), rb)
        mem = Map.put(mem, dest, if(a == b, do: 1, else: 0))
        step_computer(%{comp | mem: mem, ip: ip + 4})

      9 ->
        a = get_param(mem, ip + 1, rem(modes, 10), rb)
        step_computer(%{comp | ip: ip + 2, rb: rb + a})
    end
  end

  defp get_param(mem, addr, mode, rb) do
    val = Map.get(mem, addr, 0)
    case mode do
      0 -> Map.get(mem, val, 0)
      1 -> val
      2 -> Map.get(mem, rb + val, 0)
    end
  end

  defp get_addr(mem, addr, mode, rb) do
    val = Map.get(mem, addr, 0)
    case mode do
      0 -> val
      2 -> rb + val
    end
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.map(fn {v, i} -> {i, v} end)
    |> Map.new()
  end
end
