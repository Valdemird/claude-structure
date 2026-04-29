---
name: architecture
description: Run a thorough architecture review of the codebase or a specific module. Evaluates structure, separation of concerns, scalability, coupling, and alignment with best practices.
allowed-tools: Read, Glob, Grep, Bash(find:*), Bash(tree:*), Bash(wc:*)
argument-hint: "[file, directory, or leave blank for full project]"
---

# Architecture Review

## Target

$ARGUMENTS

## Context Gathering

Start by building a structural picture of the project:

- Run: !`find . -maxdepth 1 -type f | sort`
- Run: !`find . -maxdepth 3 -type d | grep -v node_modules | grep -v ".git" | grep -v "__pycache__" | sort | head -60`
- Run: !`find . -maxdepth 2 -name "package.json" -o -name "pom.xml" -o -name "build.gradle" -o -name "requirements.txt" -o -name "go.mod" -o -name "Cargo.toml" -o -name "*.csproj" 2>/dev/null | head -10`
- Run: !`find . -maxdepth 2 -name "docker-compose*" -o -name "Dockerfile" -o -name "*.tf" -o -name "*.yaml" -o -name "*.yml" 2>/dev/null | grep -v node_modules | head -15`

If `$ARGUMENTS` is provided, scope the review to that path/module. Otherwise, analyze the full project.

---

## Architecture Review Checklist

Analyze ALL categories below. For each finding, provide:

- 📍 **Location**: file(s) or layer(s) involved
- 🔴 **Severity**: Critical / High / Medium / Low
- 💡 **Recommendation**: concrete refactor approach or pattern to apply

---

### 1. 📁 Project Structure & Organization

- Does the folder structure reflect clear layers or domain boundaries?
- Are there mixed concerns in the same directory (e.g., routes + business logic + DB calls in one file)?
- Is there a consistent naming convention across files and modules?
- Are configuration files, environment handling, and secrets managed properly?
- Is the entry point (main/index/app) clean and minimal?

---

### 2. 🔗 Coupling & Cohesion

- Identify tight coupling: classes/modules that import too many others, or that know too much about internal details of other modules
- Find violations of the Law of Demeter (long chains: `a.b.c.d.method()`)
- Check if modules have high cohesion (each does ONE thing well)
- Spot circular dependencies
- Look for "God objects" or "God files" doing too much

---

### 3. 🏛️ Layered Architecture & Separation of Concerns

- Verify separation between: Presentation / API → Business Logic → Data Access
- Check that business rules are NOT in controllers/routes/handlers
- Check that data access logic is NOT scattered across the business layer
- Ensure there's no direct DB access from UI components (frontend projects)
- Look for missing service/repository/use-case layers

---

### 4. 🔄 SOLID Principles

- **S** – Single Responsibility: do classes/functions do only one thing?
- **O** – Open/Closed: are new behaviors added via extension, not modification?
- **L** – Liskov Substitution: do subclasses/implementations honor contracts?
- **I** – Interface Segregation: are interfaces lean and role-specific?
- **D** – Dependency Inversion: do high-level modules depend on abstractions, not concretions?

---

### 5. 🧩 Design Patterns Usage

- Identify where a known pattern would reduce complexity (Factory, Strategy, Observer, Repository, Command, etc.)
- Find anti-patterns: Singleton overuse, Magic Numbers, Hardcoded Config, Deep Inheritance chains, Anemic Domain Model
- Check if dependency injection is used (vs. hardcoded instantiation)

---

### 6. 📡 API & Contract Design (if applicable)

- Are API endpoints RESTful and consistent in naming and versioning?
- Is request/response validation enforced at the boundary?
- Are DTOs used to prevent leaking internal models to the API layer?
- Check for missing error handling and proper HTTP status codes
- Is API documentation present (OpenAPI/Swagger, etc.)?

---

### 7. ⚠️ Error Handling & Resilience

- Find bare `catch` blocks that swallow errors silently
- Check for missing error boundaries (React) or global error handlers
- Identify missing retry/fallback strategies for external dependencies
- Spot lack of circuit breakers or timeout handling for external services
- Check if errors are properly logged with context

---

### 8. 🔐 Security Architecture

- Is authentication/authorization centralized or scattered?
- Are secrets/credentials handled via env vars or a secrets manager (not hardcoded)?
- Is input validation enforced at entry points?
- Check for missing HTTPS enforcement, CORS misconfiguration, or missing rate limiting
- Is PII data isolated and protected (at rest and in transit)?

---

### 9. 🧪 Testability

- Is the code structured to be unit-testable (dependencies injected, pure functions, no hidden globals)?
- Is there a clear separation between test-heavy business logic and hard-to-test I/O?
- Check for missing or inconsistent test coverage on critical paths
- Are integration and end-to-end tests present?

---

### 10. 📈 Scalability & Maintainability

- Is the architecture ready for horizontal scaling? (stateless services, externalized session/cache)
- Are there obvious single points of failure?
- Is the codebase modular enough to allow teams to work independently?
- Check for missing observability: logging, metrics, tracing
- Are there README files, ADRs (Architecture Decision Records), or inline docs?

---

## Output Format

Produce the report in this exact structure:

```
## 🏛️ Architecture Review Report
**Target:** [file/module/project]
**Date:** [today]
**Stack detected:** [detected tech stack]
**Architecture pattern detected:** [MVC / Layered / Hexagonal / Microservices / etc.]

---

### Executive Summary
[3–4 sentence assessment of the overall architecture health, major strengths, and top concerns]

---

### Strengths ✅
[Bullet list of what is well-designed]

---

### 🔴 Critical Issues ([count])
[List each with location, description, and recommended refactor]

### 🟠 High Priority ([count])
[List each with location, description, and recommended refactor]

### 🟡 Medium Priority ([count])
[List each with location, description, and recommended refactor]

### 🟢 Low / Nice-to-Have ([count])
[List each with location, description, and recommended improvement]

---

### Architecture Diagram (ASCII)
[Draw a simplified diagram of the detected layers and key components]

---

### Recommended Target Architecture
[If significant refactoring is needed, describe the ideal target architecture in 1–3 paragraphs, with a diagram if helpful]

---

### Prioritized Refactoring Roadmap
1. [Most critical, smallest scope]
2. [Next step]
3. [Longer-term improvement]

---

### References
[List relevant patterns, books, or docs that apply to this codebase's stack]
```
