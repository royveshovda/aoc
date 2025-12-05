#!/bin/bash
# Compare NEW vs ORIGINAL 2023 implementations
# This script swaps files and runs each implementation

cd /Users/royveshovda/src/royveshovda/aoc

echo "========================================================================"
echo "2023 Advent of Code - NEW vs ORIGINAL Benchmark"
echo "========================================================================"
echo ""

# Create temp dir for new implementations
mkdir -p temp_new_2023

# Days to test (Day 1 original is incomplete)
DAYS="2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25"

echo "Testing NEW implementations first..."
echo ""

# Time NEW implementations
NEW_TIMES=""
for day in $DAYS; do
    start=$(gdate +%s%N 2>/dev/null || date +%s%N 2>/dev/null || python3 -c "import time; print(int(time.time()*1000000000))")
    
    if [ "$day" = "21" ]; then
        result=$(mix run -e "input = File.read!(\"input/2023_${day}.txt\"); IO.puts(Y2023.D${day}.p1(input, 64)); IO.puts(Y2023.D${day}.p2(input))" 2>/dev/null)
    elif [ "$day" = "24" ]; then
        result=$(mix run -e "input = File.read!(\"input/2023_${day}.txt\"); IO.puts(Y2023.D${day}.p1(input, 200_000_000_000_000, 400_000_000_000_000)); IO.puts(Y2023.D${day}.p2(input))" 2>/dev/null)
    else
        result=$(mix run -e "input = File.read!(\"input/2023_${day}.txt\"); IO.puts(Y2023.D${day}.p1(input)); IO.puts(Y2023.D${day}.p2(input))" 2>/dev/null)
    fi
    
    end=$(gdate +%s%N 2>/dev/null || date +%s%N 2>/dev/null || python3 -c "import time; print(int(time.time()*1000000000))")
    elapsed=$(( (end - start) / 1000000 ))
    
    echo "Day $day (NEW): ${elapsed}ms"
    NEW_TIMES="$NEW_TIMES $day:$elapsed"
done

echo ""
echo "Swapping to ORIGINAL implementations..."

# Save NEW and swap ORIGINAL
for day in $DAYS; do
    cp lib/2023/${day}.ex temp_new_2023/${day}.ex
    cp backup_2023_original/${day}.ex lib/2023/${day}.ex
done

# Recompile
mix compile --force >/dev/null 2>&1

echo "Testing ORIGINAL implementations..."
echo ""

# Time ORIGINAL implementations
ORIG_TIMES=""
for day in $DAYS; do
    start=$(gdate +%s%N 2>/dev/null || date +%s%N 2>/dev/null || python3 -c "import time; print(int(time.time()*1000000000))")
    
    if [ "$day" = "21" ]; then
        result=$(mix run -e "input = File.read!(\"input/2023_${day}.txt\"); IO.puts(Y2023.D${day}.p1(input, 64)); IO.puts(Y2023.D${day}.p2(input))" 2>/dev/null)
    elif [ "$day" = "24" ]; then
        result=$(mix run -e "input = File.read!(\"input/2023_${day}.txt\"); IO.puts(Y2023.D${day}.p1(input, 200_000_000_000_000, 400_000_000_000_000)); IO.puts(Y2023.D${day}.p2(input))" 2>/dev/null)
    else
        result=$(mix run -e "input = File.read!(\"input/2023_${day}.txt\"); IO.puts(Y2023.D${day}.p1(input)); IO.puts(Y2023.D${day}.p2(input))" 2>/dev/null)
    fi
    
    end=$(gdate +%s%N 2>/dev/null || date +%s%N 2>/dev/null || python3 -c "import time; print(int(time.time()*1000000000))")
    elapsed=$(( (end - start) / 1000000 ))
    
    echo "Day $day (ORIG): ${elapsed}ms"
    ORIG_TIMES="$ORIG_TIMES $day:$elapsed"
done

echo ""
echo "Restoring NEW implementations..."

# Restore NEW
for day in $DAYS; do
    cp temp_new_2023/${day}.ex lib/2023/${day}.ex
done

# Recompile
mix compile --force >/dev/null 2>&1

# Cleanup
rm -rf temp_new_2023

echo ""
echo "========================================================================"
echo "SUMMARY"
echo "========================================================================"
echo ""
echo "| Day | NEW (ms) | ORIG (ms) | Winner | Speedup |"
echo "|-----|----------|-----------|--------|---------|"

new_total=0
orig_total=0
new_wins=0
orig_wins=0
ties=0

for day in $DAYS; do
    new_ms=$(echo $NEW_TIMES | tr ' ' '\n' | grep "^$day:" | cut -d: -f2)
    orig_ms=$(echo $ORIG_TIMES | tr ' ' '\n' | grep "^$day:" | cut -d: -f2)
    
    new_total=$((new_total + new_ms))
    orig_total=$((orig_total + orig_ms))
    
    if [ $((new_ms * 100)) -lt $((orig_ms * 90)) ]; then
        winner="NEW"
        new_wins=$((new_wins + 1))
    elif [ $((orig_ms * 100)) -lt $((new_ms * 90)) ]; then
        winner="ORIG"
        orig_wins=$((orig_wins + 1))
    else
        winner="TIE"
        ties=$((ties + 1))
    fi
    
    if [ $new_ms -gt 0 ]; then
        speedup=$(echo "scale=2; $orig_ms / $new_ms" | bc)
    else
        speedup="∞"
    fi
    
    printf "| %3d | %8d | %9d | %6s | %7sx |\n" $day $new_ms $orig_ms $winner $speedup
done

echo ""
echo "Totals: NEW=${new_total}ms, ORIG=${orig_total}ms"
echo "Wins: NEW=$new_wins, ORIG=$orig_wins, TIE=$ties"

if [ $new_total -gt 0 ]; then
    overall=$(echo "scale=2; $orig_total / $new_total" | bc)
    echo "Overall speedup: ${overall}x"
fi
