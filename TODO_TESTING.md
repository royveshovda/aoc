# AoC Testing TODO

This document tracks test failures and their root causes.

## 🔄 PROGRESS TRACKING

**Last Updated:** December 6, 2025

### Test Suite Status

| Metric | Count |
|--------|-------|
| Total test files | 256 |
| Total tests | ~560 |
| Total doctests | ~452 |
| Tests skipped (@tag :skip) | 38 |
| Failures (excluding skipped) | ~47 |

**All input tests pass when run individually.** Failures are due to:
1. Missing example input files (doctests)
2. Timeouts during parallel execution
3. Minor code bugs in example parsing

---

## 🔴 ROOT CAUSE: Missing Example Input Files (Doctests)

These doctests reference `example_string()` but the example input files don't exist.
**Fix:** Create the missing input files or remove the doctests.

### 2016 (11 missing files)
| Day | Missing File |
|-----|--------------|
| D1 | `input/2016_1_example_0.txt` |
| D3 | `input/2016_3_example_0.txt` |
| D4 | `input/2016_4_example_0.txt` |
| D5 | `input/2016_5_example_0.txt` |
| D7 | `input/2016_7_example_0.txt` |
| D9 | `input/2016_9_example_0.txt` |
| D14 | `input/2016_14_example_0.txt` |
| D16 | `input/2016_16_example_0.txt` |
| D21 | `input/2016_21_example_0.txt` |
| D22 | `input/2016_22_example_0.txt` |
| D25 | `input/2016_25_example_0.txt` |

### 2017 (6 missing files)
| Day | Missing File |
|-----|--------------|
| D16 | `input/2017_16_example_0.txt` |
| D17 | `input/2017_17_example_0.txt` |
| D18 | `input/2017_18_example_0.txt` |
| D19 | `input/2017_19_example_0.txt` |
| D20 | `input/2017_20_example_0.txt` |
| D23 | `input/2017_23_example_0.txt` |

---

## 🟡 ROOT CAUSE: Slow Tests (Timeout in Parallel Execution)

These tests pass individually but timeout when run in parallel with other tests.
All use 60s timeout. Tests marked with ⏭️ are already @tag :skip.

### Timeouts During Full Suite (pass individually)
| Year | Day | Part | Individual Time | Status |
|------|-----|------|-----------------|--------|
| 2015 | D6 | p2 | ~36s | Times out in parallel |
| 2015 | D10 | p2 | ~8s | Times out in parallel |
| 2015 | D20 | p1 | ~23s | Times out in parallel |
| 2016 | D5 | p2 | ~15s | Times out in parallel |
| 2016 | D14 | p2 | ~23s | Times out in parallel |
| 2017 | D14 | p2 | ~26s | Times out in parallel |
| 2018 | D14 | p2 | ~27s | Times out in parallel |
| 2019 | D19 | p2 | ~17s | Times out in parallel |
| 2020 | D15 | p2 | ~20s | Times out in parallel |
| 2020 | D23 | p2 | ~30s | Times out in parallel |
| 2023 | D10 | p2 | ~43s | Times out in parallel |
| 2023 | D12 | p1 | ~15s | Times out in parallel |
| 2023 | D16 | p2 | ~64s | Times out in parallel |

### Already Skipped (> 2 minutes)
| Year | Day | Part | Reason |
|------|-----|------|--------|
| 2016 | D16 | p2 | ⏭️ @tag :skip - >2 min |
| 2016 | D18 | p2 | ⏭️ @tag :skip - >2 min |
| 2017 | D21 | p2 | ⏭️ @tag :skip - >2 min |
| 2023 | D21 | p1, p2 | ⏭️ @tag :skip - >2 min |
| 2023 | D23 | p2 | ⏭️ @tag :skip - >2 min |

---

## 🟠 ROOT CAUSE: Code Bugs (Doctest Parse Errors)

These doctests have bugs in the solution code (not missing files).

| Year | Day | Error | Issue |
|------|-----|-------|-------|
| 2017 | D21 | MatchError | `parse/1` function has bug with example input |

---

## 🟢 ROOT CAUSE: Unimplemented Solutions

Solutions that just return the input (no implementation).
All marked with @tag :skip.

### 2018 (Days 2-10)
| Day | Status |
|-----|--------|
| D2 | ⏭️ @tag :skip - unimplemented |
| D3 | ⏭️ @tag :skip - unimplemented |
| D4 | ⏭️ @tag :skip - unimplemented |
| D5 | ⏭️ @tag :skip - unimplemented |
| D6 | ⏭️ @tag :skip - unimplemented |
| D7 | ⏭️ @tag :skip - unimplemented |
| D8 | ⏭️ @tag :skip - unimplemented |
| D9 | ⏭️ @tag :skip - unimplemented |
| D10 | ⏭️ @tag :skip - unimplemented |

### 2021 (Days 19-25)
| Day | Status |
|-----|--------|
| D19 | ⏭️ @tag :skip - unimplemented |
| D20 | ⏭️ @tag :skip - unimplemented |
| D21 | ⏭️ @tag :skip - unimplemented |
| D22 | ⏭️ @tag :skip - unimplemented |
| D23 | ⏭️ @tag :skip - unimplemented |
| D24 | ⏭️ @tag :skip - unimplemented |
| D25 | ⏭️ @tag :skip - unimplemented |

---

## 🔵 Visual Output Tests

These solutions return ASCII art instead of numeric answers.
Tests check for grid structure, not specific text.

| Year | Day | Part | Expected Answer |
|------|-----|------|-----------------|
| 2016 | D8 | p2 | UPOJFLBCEZ (ASCII art) |
| 2018 | D10 | p1 | AHFGRKEE (ASCII art) |
| 2019 | D8 | p2 | LHCPH (ASCII art) |
| 2019 | D11 | p2 | JKZLZJBH (ASCII art) |
| 2022 | D10 | p2 | PAPJCBHP (ASCII art) |

---

## 📋 Summary of Actions Needed

### Quick Wins (Fix immediately)
1. None - all critical tests pass

### Medium Priority (Create example files)
1. Create 17 missing example input files (2016: 11, 2017: 6)
2. Or remove/update doctests that reference them

### Low Priority (Optimization needed)
1. Optimize slow solutions (>30s) to reduce timeout failures
2. 2016/D16, 2016/D18, 2017/D21, 2023/D21, 2023/D23 need algorithm improvements

### Backlog (Implement solutions)
1. 2018 Days 2-10 (9 days)
2. 2021 Days 19-25 (7 days)

---

## ✅ Test Commands

```bash
# Run all tests (excluding skipped)
mix test --exclude skip

# Run with longer timeout
mix test --timeout 120000 --exclude skip

# Run specific year
mix test test/2024/*.exs

# Run specific day
mix test test/2024/1_test.exs
```
