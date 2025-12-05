# Interpreter & VM Patterns

## Overview
Building simple interpreters, virtual machines, and instruction execution engines for AoC problems.

## 1. Assembly Language Interpreter

**Problem:** Execute a sequence of low-level instructions with registers and jumps.

**When to Use:**
- Assembly/bytecode simulation (2015 Days 7, 23)
- Virtual machine problems
- Instruction sequence execution

### Basic Interpreter Pattern

```elixir
defp execute(instructions, registers, pc \\ 0) do
  case Map.get(instructions, pc) do
    nil ->
      # Program terminated - return result
      Map.get(registers, :result_register)
    
    instruction ->
      {new_registers, new_pc} = execute_instruction(instruction, registers, pc)
      execute(instructions, new_registers, new_pc)
  end
end

defp execute_instruction({:inc, reg}, registers, pc) do
  new_registers = Map.update!(registers, reg, &(&1 + 1))
  {new_registers, pc + 1}
end

defp execute_instruction({:jmp, offset}, registers, pc) do
  {registers, pc + offset}
end

defp execute_instruction({:jie, reg, offset}, registers, pc) do
  value = Map.get(registers, reg)
  new_pc = if rem(value, 2) == 0, do: pc + offset, else: pc + 1
  {registers, new_pc}
end
```

### Parsing Instructions

```elixir
defp parse_instructions(input) do
  input
  |> String.split("\n", trim: true)
  |> Enum.map(&parse_instruction/1)
  |> Enum.with_index()
  |> Map.new(fn {inst, idx} -> {idx, inst} end)
end

defp parse_instruction(line) do
  case String.split(line, [" ", ", "], trim: true) do
    ["inc", reg] -> {:inc, String.to_atom(reg)}
    ["jmp", offset] -> {:jmp, String.to_integer(offset)}
    ["jie", reg, offset] -> {:jie, String.to_atom(reg), String.to_integer(offset)}
    ["jio", reg, offset] -> {:jio, String.to_atom(reg), String.to_integer(offset)}
    # ... more patterns
  end
end
```

**Key Features:**
- Store instructions in map indexed by position
- Use pattern matching for instruction dispatch
- Tail recursion for interpreter loop
- Return final register state when PC goes out of bounds

## 2. Circuit/Wire Evaluation with Memoization

**Problem:** Evaluate interconnected values with dependencies (like wires in a circuit).

**When to Use:**
- Circuit simulation (2015 Day 7)
- Dependency graphs with computed values
- Lazy evaluation with caching

```elixir
defp evaluate(circuit, wire, cache) do
  # Check cache first
  if Map.has_key?(cache, wire) do
    {Map.get(cache, wire), cache}
  else
    # Compute value and cache it
    {value, new_cache} = compute_value(circuit, wire, cache)
    {value, Map.put(new_cache, wire, value)}
  end
end

defp compute_value(circuit, wire, cache) do
  case Map.get(circuit, wire) do
    {:value, num} ->
      {num, cache}
    
    {:and, left, right} ->
      {left_val, cache1} = get_operand(circuit, left, cache)
      {right_val, cache2} = get_operand(circuit, right, cache1)
      {Bitwise.band(left_val, right_val), cache2}
    
    {:or, left, right} ->
      {left_val, cache1} = get_operand(circuit, left, cache)
      {right_val, cache2} = get_operand(circuit, right, cache1)
      {Bitwise.bor(left_val, right_val), cache2}
    
    {:not, operand} ->
      {val, new_cache} = get_operand(circuit, operand, cache)
      {Bitwise.bnot(val) &&& 0xFFFF, new_cache}  # Mask to 16 bits
    
    {:lshift, operand, shift} ->
      {val, new_cache} = get_operand(circuit, operand, cache)
      {Bitwise.bsl(val, shift) &&& 0xFFFF, new_cache}
    
    {:rshift, operand, shift} ->
      {val, new_cache} = get_operand(circuit, operand, cache)
      {Bitwise.bsr(val, shift), new_cache}
  end
end

defp get_operand(circuit, operand, cache) when is_integer(operand) do
  {operand, cache}
end

defp get_operand(circuit, operand, cache) do
  evaluate(circuit, operand, cache)
end
```

**Key Insight:** Memoization prevents exponential complexity in dependency graphs. Each wire is computed exactly once.

## 3. Game State Machine

**Problem:** Simulate turn-based games with state transitions.

**When to Use:**
- Turn-based game simulation (2015 Days 21, 22)
- State machines with complex rules
- Combat/battle simulations

```elixir
defp simulate_turn(state) do
  # Apply start-of-turn effects
  state = apply_effects(state)
  
  # Check win/loss conditions
  cond do
    state.boss_hp <= 0 -> {:win, state}
    state.player_hp <= 0 -> {:lose, state}
    true -> continue_turn(state)
  end
end

defp continue_turn(state) do
  if state.player_turn do
    # Player chooses action
    possible_actions = get_valid_actions(state)
    
    if Enum.empty?(possible_actions) do
      {:lose, state}
    else
      # Return all possible next states
      next_states = Enum.map(possible_actions, &apply_action(state, &1))
      {:continue, next_states}
    end
  else
    # Boss turn (deterministic)
    new_state = apply_boss_action(state)
    {:continue, [new_state]}
  end
end
```

## 4. Instruction Set Design Patterns

### Register-Based VM

```elixir
# Registers: %{a: 0, b: 0, pc: 0}
defp register_vm(instructions, regs) do
  case Enum.at(instructions, regs.pc) do
    nil -> regs
    inst ->
      new_regs = execute_register_instruction(inst, regs)
      register_vm(instructions, new_regs)
  end
end
```

### Stack-Based VM

```elixir
defp stack_vm(instructions, stack, pc) do
  case Enum.at(instructions, pc) do
    nil -> stack
    {:push, val} -> stack_vm(instructions, [val | stack], pc + 1)
    {:add} ->
      [a, b | rest] = stack
      stack_vm(instructions, [a + b | rest], pc + 1)
    {:dup} ->
      [top | _] = stack
      stack_vm(instructions, [top | stack], pc + 1)
  end
end
```

## 5. Bitwise Operations

**Common in circuit/VM problems:**

```elixir
import Bitwise

# 16-bit operations (mask results)
defp and16(a, b), do: band(a, b) &&& 0xFFFF
defp or16(a, b), do: bor(a, b) &&& 0xFFFF
defp not16(a), do: bnot(a) &&& 0xFFFF
defp lshift16(a, n), do: bsl(a, n) &&& 0xFFFF
defp rshift16(a, n), do: bsr(a, n)

# Check specific bits
defp bit_set?(num, pos), do: band(num, bsl(1, pos)) != 0

# Set/clear bits
defp set_bit(num, pos), do: bor(num, bsl(1, pos))
defp clear_bit(num, pos), do: band(num, bnot(bsl(1, pos)))
```

## 6. Optimizing Interpreters

### Instruction Frequency Analysis
```elixir
# Profile which instructions are most common
defp profile_instructions(instructions) do
  instructions
  |> Enum.map(&elem(&1, 0))
  |> Enum.frequencies()
  |> Enum.sort_by(&elem(&1, 1), :desc)
end
```

### Jump Target Optimization
```elixir
# Pre-compute jump targets
defp build_jump_table(instructions) do
  instructions
  |> Enum.with_index()
  |> Enum.filter(fn {{type, _}, _} -> type in [:jmp, :jie, :jio] end)
  |> Map.new(fn {{_type, target}, idx} -> {idx, target} end)
end
```

## 7. Debugging Interpreters

```elixir
defp debug_execute(instructions, registers, pc, trace \\ []) do
  if pc >= map_size(instructions) do
    {:halt, registers, trace}
  else
    instruction = Map.get(instructions, pc)
    
    # Add to trace
    new_trace = [{pc, instruction, registers} | trace]
    
    {new_registers, new_pc} = execute_instruction(instruction, registers, pc)
    debug_execute(instructions, new_registers, new_pc, new_trace)
  end
end

# Print execution trace
defp print_trace(trace) do
  trace
  |> Enum.reverse()
  |> Enum.each(fn {pc, inst, regs} ->
    IO.puts("PC=#{pc}: #{inspect(inst)} | Regs=#{inspect(regs)}")
  end)
end
```

## 5. Concurrent Programs with Message Passing

**Problem:** Two programs run concurrently, sending and receiving messages.

**When to Use:**
- Multi-program simulation (2017 Day 18)
- Concurrent processes with communication
- Producer-consumer patterns

**Used In**: 2017 Day 18 (Duet)

```elixir
def run_concurrent_programs(instructions) do
  state0 = %{regs: %{"p" => 0}, pc: 0, queue: [], waiting: false}
  state1 = %{regs: %{"p" => 1}, pc: 0, queue: [], waiting: false}
  execute_concurrent(instructions, state0, state1, 0)
end

defp execute_concurrent(instructions, state0, state1, send_count) do
  # Run program 0 until it blocks
  {new_state0, msgs0, blocked0} = run_until_block(instructions, state0)
  
  # Deliver messages to program 1
  new_state1 = %{state1 | queue: state1.queue ++ msgs0, waiting: false}
  
  # Run program 1 until it blocks
  {final_state1, msgs1, blocked1} = run_until_block(instructions, new_state1)
  
  # Deliver messages to program 0
  final_state0 = %{new_state0 | queue: new_state0.queue ++ msgs1, waiting: false}
  
  new_send_count = send_count + length(msgs1)
  
  # Deadlock detection: both blocked with no messages exchanged
  if blocked0 and blocked1 and Enum.empty?(msgs0) and Enum.empty?(msgs1) do
    new_send_count
  else
    execute_concurrent(instructions, final_state0, final_state1, new_send_count)
  end
end

defp run_until_block(instructions, state, sent \\ []) do
  case Map.get(instructions, state.pc) do
    nil -> {state, sent, true}
    
    {:snd, x} ->
      # Send: continue running
      val = get_val(state.regs, x)
      run_until_block(instructions, %{state | pc: state.pc + 1}, sent ++ [val])
    
    {:rcv, x} ->
      # Receive: block if queue empty, consume if available
      case state.queue do
        [] -> {%{state | waiting: true}, sent, true}
        [val | rest] ->
          new_regs = Map.put(state.regs, x, val)
          run_until_block(instructions, %{state | regs: new_regs, pc: state.pc + 1, queue: rest}, sent)
      end
    
    other ->
      # Regular instructions
      {new_regs, new_pc} = execute_instruction(other, state.regs, state.pc)
      run_until_block(instructions, %{state | regs: new_regs, pc: new_pc}, sent)
  end
end
```

**Key Pattern**: Each program runs until it blocks (waiting for input or terminated), then the other program runs. Deadlock occurs when both are blocked with no messages in flight.

## Performance Considerations

1. **Tail Call Optimization:** Ensure interpreter loop is tail-recursive
2. **Instruction Storage:** Use Map for O(1) lookup by PC
3. **Memoization:** Cache computed values to avoid recomputation
4. **Pattern Matching:** Most efficient dispatch mechanism in Elixir
5. **Avoid String Operations:** Use atoms for opcodes and registers

## Common Pitfalls

- **Infinite Loops:** Always have termination condition (PC out of bounds)
- **Register Names:** Use atoms not strings for efficiency
- **Overflow:** Mask results for fixed-width arithmetic
- **Jump Offsets:** Remember relative vs. absolute addressing
- **Memoization Threading:** Pass cache through entire call chain

## Related Patterns
- [Dynamic Programming](dynamic_programming.md) - Memoization techniques
- [Simulation](simulation.md) - State management patterns
- [Mathematical Algorithms](mathematical_algorithms.md) - Bitwise operations

---

## 8. Intcode VM (2019)

The 2019 Advent of Code is "The Year of Intcode" - a virtual machine that gets incrementally built and reused throughout the month. Many problems after Day 9 assume you have a working Intcode interpreter.

### Opcodes Reference

| Opcode | Name | Parameters | Description |
|--------|------|------------|-------------|
| 1 | ADD | 3 | p3 = p1 + p2 |
| 2 | MUL | 3 | p3 = p1 × p2 |
| 3 | INPUT | 1 | p1 = input |
| 4 | OUTPUT | 1 | output p1 |
| 5 | JNZ | 2 | if p1 ≠ 0, ip = p2 |
| 6 | JZ | 2 | if p1 = 0, ip = p2 |
| 7 | LT | 3 | p3 = p1 < p2 ? 1 : 0 |
| 8 | EQ | 3 | p3 = p1 = p2 ? 1 : 0 |
| 9 | REL | 1 | relative_base += p1 |
| 99 | HALT | 0 | stop |

### Parameter Modes

| Mode | Name | Meaning |
|------|------|---------|
| 0 | Position | Value at address |
| 1 | Immediate | Value directly |
| 2 | Relative | Value at (relative_base + value) |

### Complete Intcode Implementation (Day 9+)

```elixir
defmodule Intcode do
  @moduledoc """
  Complete Intcode VM supporting all opcodes and parameter modes.
  """

  def parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new(fn {v, i} -> {i, v} end)
  end

  def run(mem, inputs), do: run(mem, 0, 0, inputs, [])

  defp run(mem, ip, rb, inputs, outputs) do
    instruction = Map.get(mem, ip, 0)
    opcode = rem(instruction, 100)

    case opcode do
      1 -> # ADD
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        run(Map.put(mem, c, a + b), ip + 4, rb, inputs, outputs)

      2 -> # MUL
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        run(Map.put(mem, c, a * b), ip + 4, rb, inputs, outputs)

      3 -> # INPUT
        [input | rest] = inputs
        addr = get_addr(mem, ip, rb, 1)
        run(Map.put(mem, addr, input), ip + 2, rb, rest, outputs)

      4 -> # OUTPUT
        val = get_param(mem, ip, rb, 1)
        run(mem, ip + 2, rb, inputs, outputs ++ [val])

      5 -> # JUMP-IF-TRUE
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        new_ip = if a != 0, do: b, else: ip + 3
        run(mem, new_ip, rb, inputs, outputs)

      6 -> # JUMP-IF-FALSE
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        new_ip = if a == 0, do: b, else: ip + 3
        run(mem, new_ip, rb, inputs, outputs)

      7 -> # LESS-THAN
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        val = if a < b, do: 1, else: 0
        run(Map.put(mem, c, val), ip + 4, rb, inputs, outputs)

      8 -> # EQUALS
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        val = if a == b, do: 1, else: 0
        run(Map.put(mem, c, val), ip + 4, rb, inputs, outputs)

      9 -> # ADJUST RELATIVE BASE
        val = get_param(mem, ip, rb, 1)
        run(mem, ip + 2, rb + val, inputs, outputs)

      99 -> # HALT
        {mem, outputs}
    end
  end

  defp get_mode(mem, ip, offset) do
    instruction = Map.get(mem, ip, 0)
    div(instruction, round(:math.pow(10, offset + 1))) |> rem(10)
  end

  defp get_param(mem, ip, rb, offset) do
    mode = get_mode(mem, ip, offset)
    param = Map.get(mem, ip + offset, 0)

    case mode do
      0 -> Map.get(mem, param, 0)         # position mode
      1 -> param                           # immediate mode
      2 -> Map.get(mem, rb + param, 0)    # relative mode
    end
  end

  defp get_addr(mem, ip, rb, offset) do
    mode = get_mode(mem, ip, offset)
    param = Map.get(mem, ip + offset, 0)

    case mode do
      0 -> param          # position mode
      2 -> rb + param     # relative mode
      # Note: Mode 1 (immediate) never valid for write addresses
    end
  end
end
```

### Suspendable/Resumable VM (Day 7, 11, 13, 15+)

For problems requiring feedback loops or interactive I/O:

```elixir
defmodule SuspendableIntcode do
  @moduledoc """
  Intcode VM that can suspend on I/O and resume later.
  Essential for Day 7 (amplifiers), Day 11 (robot), Day 13 (arcade), Day 15 (maze).
  """

  def new(mem), do: %{mem: mem, ip: 0, rb: 0, halted: false}

  # Run until output is produced, then suspend
  def run_until_output(vm, inputs) do
    run_until_output_impl(vm.mem, vm.ip, vm.rb, inputs)
  end

  defp run_until_output_impl(mem, ip, rb, inputs) do
    instruction = Map.get(mem, ip, 0)
    opcode = rem(instruction, 100)

    case opcode do
      1 -> # ADD
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        run_until_output_impl(Map.put(mem, c, a + b), ip + 4, rb, inputs)

      2 -> # MUL
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        run_until_output_impl(Map.put(mem, c, a * b), ip + 4, rb, inputs)

      3 -> # INPUT
        case inputs do
          [] -> {:need_input, %{mem: mem, ip: ip, rb: rb, halted: false}}
          [input | rest] ->
            addr = get_addr(mem, ip, rb, 1)
            run_until_output_impl(Map.put(mem, addr, input), ip + 2, rb, rest)
        end

      4 -> # OUTPUT - suspend and return value
        output = get_param(mem, ip, rb, 1)
        {:output, output, %{mem: mem, ip: ip + 2, rb: rb, halted: false}}

      5 -> # JUMP-IF-TRUE
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        new_ip = if a != 0, do: b, else: ip + 3
        run_until_output_impl(mem, new_ip, rb, inputs)

      6 -> # JUMP-IF-FALSE
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        new_ip = if a == 0, do: b, else: ip + 3
        run_until_output_impl(mem, new_ip, rb, inputs)

      7 -> # LESS-THAN
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        val = if a < b, do: 1, else: 0
        run_until_output_impl(Map.put(mem, c, val), ip + 4, rb, inputs)

      8 -> # EQUALS
        {a, b} = {get_param(mem, ip, rb, 1), get_param(mem, ip, rb, 2)}
        c = get_addr(mem, ip, rb, 3)
        val = if a == b, do: 1, else: 0
        run_until_output_impl(Map.put(mem, c, val), ip + 4, rb, inputs)

      9 -> # ADJUST RELATIVE BASE
        val = get_param(mem, ip, rb, 1)
        run_until_output_impl(mem, ip + 2, rb + val, inputs)

      99 -> # HALT
        {:halt, %{mem: mem, ip: ip, rb: rb, halted: true}}
    end
  end

  # Helper functions (same as above)
  defp get_mode(mem, ip, offset) do
    instruction = Map.get(mem, ip, 0)
    div(instruction, round(:math.pow(10, offset + 1))) |> rem(10)
  end

  defp get_param(mem, ip, rb, offset) do
    mode = get_mode(mem, ip, offset)
    param = Map.get(mem, ip + offset, 0)
    case mode do
      0 -> Map.get(mem, param, 0)
      1 -> param
      2 -> Map.get(mem, rb + param, 0)
    end
  end

  defp get_addr(mem, ip, rb, offset) do
    mode = get_mode(mem, ip, offset)
    param = Map.get(mem, ip + offset, 0)
    case mode do
      0 -> param
      2 -> rb + param
    end
  end
end
```

### Usage Patterns

**Feedback Loop (Day 7 Part 2):**
```elixir
defp run_feedback_loop(mem, phases) do
  # Initialize 5 amplifiers
  amps = Enum.map(phases, fn phase ->
    %{vm: SuspendableIntcode.new(mem), inputs: [phase]}
  end)
  
  feedback_loop(amps, 0, 0)
end

defp feedback_loop(amps, current_amp, signal) do
  amp = Enum.at(amps, current_amp)
  inputs = amp.inputs ++ [signal]
  
  case SuspendableIntcode.run_until_output(amp.vm, inputs) do
    {:output, output, new_vm} ->
      updated_amps = List.replace_at(amps, current_amp, %{vm: new_vm, inputs: []})
      next_amp = rem(current_amp + 1, 5)
      feedback_loop(updated_amps, next_amp, output)
    
    {:halt, _} when current_amp == 4 ->
      signal  # Final output from amp E
    
    {:halt, _} ->
      # This amp halted, continue to next
      next_amp = rem(current_amp + 1, 5)
      feedback_loop(amps, next_amp, signal)
  end
end
```

**Interactive Exploration (Day 15):**
```elixir
defp explore(vm, pos, grid, oxygen_pos) do
  # Try all 4 directions
  Enum.reduce([1, 2, 3, 4], {grid, vm, oxygen_pos}, fn dir, {g, v, oxy} ->
    new_pos = move(pos, dir)
    
    if Map.has_key?(g, new_pos) do
      {g, v, oxy}  # Already explored
    else
      case step(v, dir) do
        {new_vm, 0} ->  # Hit wall
          {Map.put(g, new_pos, :wall), new_vm, oxy}
        
        {new_vm, 1} ->  # Moved to open space
          g2 = Map.put(g, new_pos, :open)
          {g3, v3, oxy2} = explore(new_vm, new_pos, g2, oxy)
          {v4, _} = step(v3, reverse(dir))  # Backtrack
          {g3, v4, oxy2}
        
        {new_vm, 2} ->  # Found oxygen system
          g2 = Map.put(g, new_pos, :open)
          {g3, v3, _} = explore(new_vm, new_pos, g2, new_pos)
          {v4, _} = step(v3, reverse(dir))
          {g3, v4, new_pos}
      end
    end
  end)
end

defp step(vm, direction) do
  case SuspendableIntcode.run_until_output(vm, [direction]) do
    {:output, status, new_vm} -> {new_vm, status}
  end
end
```

**ASCII I/O with Grid Building (Day 17):**
```elixir
def solve(input) do
  mem = parse(input)
  {_mem, outputs} = run_intcode(mem, [])
  
  # Convert ASCII outputs to grid
  grid = build_grid(outputs)
  
  # Find intersections or other features
  process_grid(grid)
end

defp build_grid(outputs) do
  outputs
  |> Enum.map(&<<&1::utf8>>)  # Convert ASCII codes to characters
  |> Enum.join()
  |> String.trim()
  |> String.split("\n")
  |> Enum.with_index()
  |> Enum.flat_map(fn {row, y} ->
    row
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {char, x} -> {{x, y}, char} end)
  end)
  |> Map.new()
end
```

**Path Compression for Functions (Day 17 Part 2):**
```elixir
# Compress path into main routine + functions A, B, C
# Each function max 20 chars, main calls A/B/C
defp compress_path(path) do
  segments = String.split(path, ",")
  
  for a_len <- 2..10,
      a_start = Enum.take(segments, a_len),
      a_str = Enum.join(a_start, ","),
      String.length(a_str) <= 20,
      remaining_after_a = remove_prefix_occurrences(segments, a_start),
      remaining_after_a != nil,
      b_len <- 2..10,
      b_start = Enum.take(remaining_after_a, b_len),
      b_str = Enum.join(b_start, ","),
      String.length(b_str) <= 20,
      remaining_after_b = remove_all_occurrences(remaining_after_a, a_start, b_start),
      remaining_after_b != nil,
      c_len <- 2..10,
      c_start = Enum.take(remaining_after_b, c_len),
      c_str = Enum.join(c_start, ","),
      String.length(c_str) <= 20,
      main = build_main(segments, a_start, b_start, c_start),
      main != nil,
      String.length(main) <= 20 do
    {main, a_str, b_str, c_str}
  end
  |> List.first()
end
```

### Key Implementation Tips

1. **Memory as Map:** Store as `%{index => value}` for sparse access
2. **Default to 0:** `Map.get(mem, addr, 0)` for uninitialized memory
3. **Arbitrarily large integers:** Native in Elixir, no special handling
4. **Separate read vs write:** Parameters for writes use `get_addr`, reads use `get_param`
5. **Mode 1 never for writes:** Write destinations are addresses, not values
6. **Relative base:** Only modified by opcode 9, persists across execution
7. **ASCII I/O:** Convert outputs with `<<code::utf8>>`, inputs with `String.to_charlist/1`
8. **Wake robot:** Set `mem[0] = 2` to enable interactive mode (Day 17)

### Network of VMs (Day 23)

For simulating multiple communicating Intcode computers:

```elixir
defp run_network(vms, queues) do
  # Step each VM once, collecting outputs
  {vms, queues, packets} = 
    Enum.reduce(0..49, {vms, queues, []}, fn i, {vs, qs, pkts} ->
      vm = Map.get(vs, i)
      queue = Map.get(qs, i, [])
      
      # Provide input: -1 if queue empty (non-blocking)
      input = if queue == [], do: [-1], else: queue
      
      {new_vm, outputs} = step_vm(vm, input)
      
      # Parse outputs as packets: [dest, x, y, ...]
      new_packets = parse_packets(outputs)
      
      {Map.put(vs, i, new_vm), Map.put(qs, i, []), pkts ++ new_packets}
    end)
  
  # Route packets to queues
  queues = Enum.reduce(packets, queues, fn {dest, x, y}, qs ->
    if dest == 255 do
      # NAT packet - handle specially
      Map.put(qs, :nat, {x, y})
    else
      Map.update(qs, dest, [x, y], &(&1 ++ [x, y]))
    end
  end)
  
  # Check idle state for NAT
  if all_idle?(queues) and Map.has_key?(queues, :nat) do
    {x, y} = queues[:nat]
    queues = Map.put(queues, 0, [x, y])
    # Track Y values for detecting repeats
  end
  
  run_network(vms, queues)
end
```

**Key Patterns:**
- Non-blocking input: return -1 when queue is empty
- Each VM outputs 3 values per packet: `[destination, X, Y]`
- NAT monitors address 255, sends to 0 when idle
- Idle detection: all queues empty AND all VMs waiting for input

