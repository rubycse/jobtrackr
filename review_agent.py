"""
Code Review Agent for JobTrackr
Uses the Claude Agent SDK to review Java/Spring Boot + React/TypeScript code.

Usage:
    python review_agent.py                    # Review entire project
    python review_agent.py src/main/java/     # Review specific path
    python review_agent.py frontend/src/      # Review frontend only
"""

import sys
import anyio
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage, SystemMessage

SYSTEM_PROMPT = """You are a senior full-stack engineer reviewing the JobTrackr codebase.

Stack: Spring Boot 3.x (Java 21), React + TypeScript, MySQL 8, Flyway, MapStruct, Spring Security (JWT).

For each file or module you review, check:

**Java / Spring Boot:**
- Security: user data isolation (every query filters by authenticated user ID), JWT validation, input sanitization
- Spring patterns: proper use of @Service, @Repository, @RestController, @RestControllerAdvice
- JPA: N+1 query risks, missing indexes, lazy vs eager loading
- DTOs: MapStruct mappers used (not manual mapping), request validation (@Valid, @NotBlank)
- Error handling: exceptions routed through @RestControllerAdvice
- Flyway migrations: versioned correctly (V1__, V2__, ...), no destructive changes without caution
- Pagination: all list endpoints return paginated results with metadata

**TypeScript / React:**
- Type safety: no `any`, proper interfaces for API responses
- React Query usage for data fetching (not raw useEffect + fetch)
- JWT interceptor on Axios instance (not per-request)
- Auth state: redirect on 401, token stored in localStorage
- Component structure: separation of concerns, reusable components
- Accessibility: ARIA labels, semantic HTML

**General:**
- No hardcoded secrets or credentials
- Meaningful variable/method names
- Dead code or TODO comments left unresolved
- Test coverage: services have unit tests (JUnit 5 + Mockito), controllers have MockMvc tests

Format your review as:
## [File or Module]
**Issues** (numbered list with severity: 🔴 Critical / 🟡 Warning / 🔵 Suggestion)
**Positives** (what's done well)
**Recommendations** (concrete next steps)

At the end, provide an overall summary with a score out of 10."""

async def main():
    target_path = sys.argv[1] if len(sys.argv) > 1 else "."

    print(f"Starting code review for: {target_path}")
    print("=" * 60)

    async for message in query(
        prompt=f"Review the code in '{target_path}'. Start by listing all source files, then read and analyze each one. Focus on correctness, security, Spring Boot / React best practices, and anything that deviates from the project conventions in CLAUDE.md.",
        options=ClaudeAgentOptions(
            cwd="/Users/lutfun/projects/jobtrackr",
            allowed_tools=["Read", "Glob", "Grep"],
            system_prompt=SYSTEM_PROMPT,
            max_turns=30,
            model="claude-opus-4-6",
        ),
    ):
        if isinstance(message, ResultMessage):
            print(message.result)
        elif isinstance(message, SystemMessage) and message.subtype == "init":
            print(f"Session: {message.session_id}\n")

if __name__ == "__main__":
    anyio.run(main)