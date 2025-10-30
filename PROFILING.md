# Performance Profiling Guide

## Performance Targets

- **Time-to-Copy (p95)**: ≤ 3 seconds
- **Search per keystroke**: ≤ 50 ms
- **Memory usage**: < 100 MB
- **CPU spikes**: < 10% during search

## Profiling with Instruments

### Time Profiler
```bash
# Build release configuration
xcodebuild -scheme CopyPrompt -configuration Release -derivedDataPath build

# Profile with Time Profiler
open -a Instruments build/Release/CopyPrompt.app
# Select "Time Profiler" template
```

**Focus areas:**
- Search performance during typing
- Panel open/close latency
- JSON load/save operations

### Allocations
```bash
# Use Allocations template in Instruments
# Monitor for:
- Memory growth during search
- Retained objects after panel close
- Leaks in SwiftUI views
```

## Optimization Strategies

### 1. Search Optimization
- Normalize strings once and cache
- Use lazy evaluation for filtered results
- Limit result set to visible items (10 rows)

### 2. SwiftUI Performance
- Use `@StateObject` for view models
- Minimize `@Published` property updates
- Avoid heavy computations in body
- Use `Equatable` for data models

### 3. File I/O
- Atomic writes prevent corruption
- Backup mechanism reduces data loss risk
- Consider debouncing rapid saves

## Current Optimizations

1. **FuzzySearchEngine**:
   - Single-pass algorithm
   - Early termination on non-matches
   - Title-weighted scoring

2. **PromptStore**:
   - Atomic file writes
   - Backup before save
   - Lazy directory creation

3. **SearchView**:
   - LazyVStack for list rendering
   - Section headers pinned efficiently
   - Fixed height rows (44pt)

## Measuring Performance

Enable local metrics in Settings to track:
- Time-to-Copy distribution (p50, p95)
- Average search keystroke duration
- Event counts

Metrics are stored locally at:
```
~/Library/Application Support/CopyPrompt/logs.json
```

## Profiling Workflow

1. **Baseline Measurement**
   - Build Release configuration
   - Create test data (200-500 prompts)
   - Enable local metrics
   - Perform typical user workflows

2. **Profile Hot Paths**
   - Open Instruments Time Profiler
   - Focus on search operations
   - Look for >50ms functions
   - Check memory allocations

3. **Optimize**
   - Cache computed values
   - Reduce allocations
   - Minimize property updates
   - Profile again to verify

4. **Verify Targets**
   - TTC p95 ≤ 3s
   - Search ≤ 50ms
   - Memory < 100MB
   - CPU < 10%

## Common Performance Issues

### Slow Search
- **Cause**: Re-normalizing strings on every keystroke
- **Solution**: Cache normalized values
- **Check**: Time Profiler → `normalize()` calls

### High Memory
- **Cause**: Retained SwiftUI views or large data
- **Solution**: Proper cleanup in `onDisappear`
- **Check**: Allocations → Retained memory after close

### UI Lag
- **Cause**: Heavy work on main thread
- **Solution**: Move to background queue if needed
- **Check**: Time Profiler → Main thread samples

## Monitoring in Production

Users can opt-in to local metrics (no data leaves device):
1. Open Settings
2. Enable "Local metrics (opt-in)"
3. Use app normally
4. Click "View Stats" to see performance data
5. Click "Reset Metrics" to clear

This helps users verify the app meets performance targets on their hardware.
