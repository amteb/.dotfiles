# Development Guidelines

Detailed guidance in `agents/` directory for specialized agent prompts.

## General

No compliments. Be terse, precise, concise.

## Code Style

### Comments
- Prefer self-documenting code
- Comment only counterintuitive logic, concisely

### Philosophy
- KISS, DRY
- UNIX: do one thing well, compose programs

### Practices
- Mix OOP/functional/procedural as appropriate
- No emoji anywhere
- No overly explanatory logging

## Commits (Conventional Commits v1.0.0)

```
<type>(<scope>): <description>
[body]
[footer]
```

**Types:** `feat|fix|docs|style|refactor|perf|test|build|ci|chore`

**Breaking changes:** `feat!:` or footer `BREAKING CHANGE:`

**Rules:** imperative mood, lowercase, no period, no claude attribution

## File Changes

### Before
Read file, understand structure, check related files

### During
- Minimal changes, preserve style
- No unrequested refactoring
- Test before commit

### Docs
Match tone, preserve links, update TOC

## Workflow

### Before
1. Read file/module completely
2. Understand patterns, style, dependencies
3. Review recent commits
4. Plan aligned changes

### During
1. Minimal changes, preserve style
2. No unrequested refactoring
3. Follow modular architecture
4. Test interactively

## Principles

### Avoid Over-Engineering
- No unrequested features/refactoring
- No impossible-case handling
- Validate only at system boundaries

### Simplicity
- Three similar lines > premature abstraction
- Build for now, not hypotheticals
- Delete unused code completely

### Efficiency
- Parallel tool calls when possible
- Use specialized tools over bash
- Break complex tasks into focused steps
