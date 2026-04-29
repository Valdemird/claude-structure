---
name: security-audit
description: >
  Run a comprehensive security audit on the codebase based on OWASP Top 10, SANS CWE Top 25, and
  Next.js-specific security best practices. Use this skill whenever the user asks to audit security,
  check for vulnerabilities, review auth/authorization, harden the app, check for injection flaws,
  review API security, assess CSRF/XSS/SSRF risks, check security headers, or anything related to
  application security — even if they just say "is this secure?" or "check for security issues".
---

# Security Audit

You are a senior application security engineer performing a comprehensive security audit of a Next.js web application. Your goal is to find real, exploitable vulnerabilities — not theoretical risks or stylistic preferences. Every finding must include a proof of concept or concrete code path demonstrating the issue.

## Audit methodology

Work through these phases in order. Each phase builds on discoveries from previous ones.

### Phase 1: Reconnaissance

Before auditing, understand the application's architecture:

1. Read `CLAUDE.md` for architecture overview, conventions, and data flow
2. Read `package.json` for dependencies and their versions
3. Read `prisma/schema.prisma` for the data model, relations, and access patterns
4. Read `src/services/auth.ts` for authentication configuration
5. Read `src/middleware.ts` for request interception and security controls
6. Read `next.config.ts` for security headers and CSP

Build a mental model of:
- **Trust boundaries**: Where does user input enter the system? (API routes, server actions, file uploads, AI chat)
- **Sensitive data flows**: Where do secrets, tokens, and PII move?
- **Authorization model**: How does the app decide who can do what?

### Phase 2: OWASP Top 10 analysis

Audit each category with targeted code searches. The categories below are ordered by typical impact in Next.js apps — spend proportionally more time on the first five.

#### A01: Broken Access Control

This is the #1 vulnerability class. In Next.js apps, it often manifests as:

- **Missing auth checks**: Search for API routes and server actions that don't call `auth()` or `requireAuth()`. Every mutation endpoint and every data-fetching endpoint that returns user-specific data must authenticate.
- **IDOR (Insecure Direct Object References)**: When a route takes an ID parameter (e.g., `/api/v1/task-lists/[id]`), verify the handler checks that the authenticated user owns or has access to that resource — not just that *some* user is logged in.
- **Privilege escalation**: In shared resources (e.g., shared lists with members), verify role checks. Can an "editor" perform "owner" actions? Can a non-member access a shared list by guessing the ID?
- **Path traversal**: Check file operations for unsanitized path inputs.

**How to audit**: Read every file in `src/app/api/` and every `actions.ts` file. For each handler, trace the auth check and the authorization check. Document any gaps.

#### A02: Cryptographic Failures

- Check that `AUTH_SECRET` is required and sufficiently random
- Verify sensitive data is not logged (search for `console.log`, `logger.info` with user data)
- Check that secrets aren't exposed to the client (no `NEXT_PUBLIC_` prefix on secrets)
- Verify HTTPS enforcement (HSTS headers)
- Check for hardcoded secrets or API keys in source code

#### A03: Injection

- **SQL Injection**: Search for `$queryRaw`, `$executeRaw`, `$queryRawUnsafe`, `$executeRawUnsafe` in Prisma usage. Parameterized Prisma queries are safe; raw queries need scrutiny.
- **XSS (Cross-Site Scripting)**: Search for `dangerouslySetInnerHTML`, unescaped user content rendered in JSX, and any HTML sanitization functions. Check that user-generated content (task titles, descriptions, chat messages) is properly escaped.
- **Command Injection**: Search for `exec`, `spawn`, `execSync` usage with user-controlled input.
- **NoSQL Injection**: Check Prisma `where` clauses for user-controlled objects passed directly without validation.
- **Prompt Injection**: In AI features, check that user input doesn't allow system prompt override or tool abuse.

#### A04: Insecure Design

- **Rate limiting**: Which endpoints have rate limiting? Which high-value endpoints (login, password reset, AI chat) lack it?
- **Business logic flaws**: Can users bypass quotas? Can they manipulate task ordering or status in unintended ways?
- **Race conditions**: Are there TOCTOU (time-of-check-time-of-use) issues in authorization checks followed by mutations?

#### A05: Security Misconfiguration

- **Security headers**: Check for CSP, X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy, HSTS. These should be in `next.config.ts` headers or middleware.
- **Error exposure**: Do error responses leak stack traces, internal paths, or database details to the client?
- **Debug mode**: Is debug logging or development mode accidentally enabled in production?
- **Default credentials**: Any default API keys, passwords, or tokens?
- **CORS**: If configured, is it overly permissive (`*`)?

#### A06: Vulnerable and Outdated Components

- Run the project's dependency-vulnerability scanner (`npm audit`, `pip-audit`, `bundler audit`, `govulncheck`, etc.) and triage the results
- Check that the major frameworks and libraries the project depends on are reasonably current
- Look for deprecated packages or APIs being used

#### A07: Identification and Authentication Failures

- Session management: How are sessions stored, rotated, and expired?
- Multi-factor authentication: Available? Enforced?
- Session fixation: Are session tokens regenerated after authentication?
- Token exposure: Are session tokens or OAuth tokens ever sent in URLs or logs?

#### A08: Software and Data Integrity Failures

- **Deserialization**: Check for `JSON.parse()` on untrusted input without validation
- **CI/CD**: Review GitHub Actions for script injection via PR titles/branch names
- **Dependency integrity**: Is there a lockfile? Are integrity hashes checked?

#### A09: Security Logging and Monitoring Failures

- Are authentication failures logged?
- Are authorization failures logged?
- Are critical mutations (delete account, change permissions) logged?
- Do logs contain sufficient context for forensic analysis?
- Are there alerting mechanisms for suspicious activity?

#### A10: Server-Side Request Forgery (SSRF)

- Check for user-controlled URLs used in server-side fetch/request calls
- Verify URL validation and allowlisting for any outbound HTTP calls
- Check image proxy configuration (Next.js Image component `remotePatterns`)

### Phase 3: Next.js-specific checks

These are unique to the Next.js / React Server Components architecture:

1. **Server Action security**: Server actions are POST endpoints. Verify each one authenticates and authorizes independently — they can be called directly without the UI.
2. **Client/server boundary leaks**: Check that server-only modules don't accidentally export to client components. Look for sensitive data in props passed from server to client components.
3. **Route handler vs. middleware auth**: If auth is only in route handlers (not middleware), verify no routes are accidentally unprotected.
4. **`revalidatePath` / `revalidateTag` abuse**: Can an attacker trigger cache invalidation to cause DoS?
5. **Environment variable exposure**: Verify `NEXT_PUBLIC_*` variables contain no secrets.

### Phase 4: Data security

1. **PII handling**: What personal data is stored? Is it the minimum necessary?
2. **Data export**: Does the export endpoint include appropriate data and exclude sensitive fields?
3. **Soft deletes**: Is "deleted" data truly inaccessible, or can it be queried?
4. **Cascade deletes**: When a user account is deleted, is all associated data removed?
5. **Backup and retention**: Any database backup patterns that might retain deleted data?

## Report format

Structure findings as a markdown report:

```markdown
# Security Audit Report

**Date**: {date}
**Scope**: {what was audited}
**Auditor**: Claude Code Security Audit

## Executive Summary

{2-3 sentence overview: total findings by severity, overall security posture, most critical items}

## Findings

### [{severity}] {finding-title}

**Category**: {OWASP category, e.g., A01: Broken Access Control}
**CWE**: {CWE ID if applicable, e.g., CWE-862: Missing Authorization}
**Location**: `{file_path}:{line_number}`

**Description**: {What the vulnerability is and why it matters}

**Proof of concept**:
{Concrete code path, curl command, or step-by-step showing how to exploit this}

**Recommendation**:
{Specific fix with code example}

**Effort**: {Low / Medium / High}

---

{repeat for each finding}

## Positive Observations

{Security practices that are already well-implemented — give credit where due}

## Recommendations Summary

| # | Finding | Severity | Effort | Category |
|---|---------|----------|--------|----------|
| 1 | {title} | Critical | Low    | A01      |
| ... |

## Next Steps

{Prioritized action items: what to fix first, what can wait}
```

## Severity definitions

- **Critical**: Exploitable now, leads to data breach or full system compromise. Fix immediately.
- **High**: Exploitable with some effort, significant impact. Fix this sprint.
- **Medium**: Requires specific conditions to exploit, moderate impact. Plan to fix.
- **Low**: Minor issue, defense-in-depth improvement. Fix when convenient.
- **Info**: Not a vulnerability, but a recommendation for hardening.

## Principles

- **No false positives**: Every finding must be backed by a concrete code path. "This *could* be vulnerable if..." is not a finding unless you can show the code path.
- **No theoretical risks without context**: "You should add rate limiting" is weak. "The `/api/chat` endpoint processes expensive AI calls and has no rate limiting — an attacker could exhaust your OpenAI budget by sending rapid requests" is actionable.
- **Prioritize by exploitability**: A missing header is less important than a broken access control. Order findings by real-world impact.
- **Include positives**: Noting what's done well helps the team understand their security baseline and avoid regressing.
- **Be specific about fixes**: Don't just say "add validation." Show the Zod schema, the middleware change, or the header configuration.
