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
