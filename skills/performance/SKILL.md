---
name: performance
description: Run a thorough performance review on the codebase or a specific file/module. Identifies bottlenecks, inefficient patterns, and optimization opportunities.
allowed-tools: Read, Glob, Grep, Bash(find:*), Bash(wc:*)
argument-hint: "[file, directory, or leave blank for full project]"
---

# Performance Review

## Target

$ARGUMENTS

## Context Gathering

Before starting, scan the project to understand its tech stack and entry points:

- Run: !`find . -maxdepth 2 -name "package.json" -o -name "pom.xml" -o -name "build.gradle" -o -name "requirements.txt" -o -name "go.mod" -o -name "Cargo.toml" 2>/dev/null | head -10`
- Run: !`find . -maxdepth 3 -name "*.config.*" -o -name "*.conf" 2>/dev/null | grep -v node_modules | head -10`

If `$ARGUMENTS` is provided, focus only on that path. Otherwise, analyze the full project.

---

## Performance Review Checklist

Perform a deep analysis covering ALL of the following categories. For each finding, include:

- 📍 **Location**: file + line number(s)
- 🔴 **Severity**: Critical / High / Medium / Low
- 💡 **Recommendation**: concrete fix with code example when possible

---

### 1. 🔁 Algorithm & Complexity

- Identify O(n²) or worse loops (nested iterations over large collections)
- Find linear scans that could use maps/sets/indexes
- Spot redundant or repeated computations inside loops
- Check recursive functions for missing memoization or infinite-loop risk

---

### 2. 🗄️ Database & I/O

- Look for N+1 query patterns (queries inside loops)
- Find missing pagination on large result sets
- Check for missing indexes (look at WHERE/JOIN/ORDER BY clauses in raw queries or ORM calls)
- Detect synchronous I/O blocking the main thread (Node.js, Python async, etc.)
- Identify missing connection pooling or connection leaks
- Spot unnecessary SELECT * when only specific fields are needed

---

### 3. 💾 Memory Management

- Find memory leaks: event listeners added but never removed, unclosed streams, growing caches without eviction
- Detect large objects or arrays being kept in memory longer than needed
- Identify cloning/copying of large data structures unnecessarily
- Check for string concatenation in loops (should use builders/join)

---

### 4. ⚡ Caching Opportunities

- Find repeated identical computations or DB/API calls with the same input
- Check if HTTP responses set proper cache headers
- Spot missing memoization on pure/expensive functions
- Identify opportunities for Redis/in-memory cache on hot paths

---

### 5. 🌐 Network & API

- Detect sequential await chains that could be parallelized (Promise.all, goroutines, asyncio.gather, etc.)
- Find uncompressed API payloads (missing gzip/brotli)
- Identify missing HTTP/2 or keep-alive usage
- Spot excessive or redundant external API calls
- Check for missing request timeouts and retry strategies

---

### 6. 🖼️ Frontend Performance (if applicable)

- Check for render-blocking resources (undeferred scripts/styles)
- Find large unoptimized images (missing lazy loading, wrong formats)
- Detect unnecessary re-renders (missing React.memo, useMemo, useCallback)
- Spot large bundle sizes (imports of entire libraries when only a piece is needed)
- Identify layout thrashing (forced synchronous layouts in JS)

---

### 7. 🏗️ Infrastructure & Build

- Find unminified or uncompressed production assets
- Detect missing CDN usage for static assets
- Identify missing code splitting or lazy loading
- Check for disabled HTTP cache headers in production configs

---

## Output Format

Produce the report in this exact structure:

```
## 🚀 Performance Review Report
**Target:** [file/module/project]
**Date:** [today]
**Stack detected:** [detected tech stack]

---

### Executive Summary
[2–3 sentence overview of overall performance health]

---

### 🔴 Critical Issues ([count])
[List each with location, description, and recommended fix]

### 🟠 High Priority ([count])
[List each with location, description, and recommended fix]

### 🟡 Medium Priority ([count])
[List each with location, description, and recommended fix]

### 🟢 Low / Nice-to-Have ([count])
[List each with location, description, and recommended fix]

---

### Quick Wins (can be fixed in < 30 min)
[Bullet list of the fastest, lowest-risk improvements]

### Estimated Impact
[For the top 3 findings, estimate the expected improvement in latency / throughput / memory]

---

### Next Steps
1. [Prioritized action item]
2. [Prioritized action item]
3. [Prioritized action item]
```
