---
name: ticket-planning
description: >
  Durable project planning with file-based tickets. Use when you need to track
  multi-session work, manage dependencies between tasks, or plan projects that
  span multiple conversations. Tickets persist in .tickets/ and survive context
  handoffs.
metadata:
  author: ayo
  version: "1.0"
---

# Ticket-Based Project Planning

This skill teaches you how to use the `ticket` tool for durable project planning in conjunction with the `todo` tool for immediate task tracking. Together, these tools enable **multi-hour autonomous execution** without human intervention.

## The Two-Tier Planning System

Ayo provides two complementary planning tools:

| Tool | Scope | Storage | Purpose |
|------|-------|---------|---------|
| `todo` | Session | SQLite (ephemeral) | Track immediate execution steps |
| `ticket` | Project | Files (durable) | Track work across sessions |

**Critical insight**: Use both tools together. Tickets define *what* to accomplish; todos track *how* you're accomplishing it right now.

## Autonomous Multi-Hour Execution Pattern

When executing long-running projects without human intervention:

### Phase 1: Project Setup

1. **Create tickets for all major work items**:
   ```bash
   ticket create "Implement user authentication" -t epic --tags auth
   ticket create "Design auth flow" --parent <epic-id> -t task
   ticket create "Implement JWT handling" --parent <epic-id> -t task
   ticket create "Add OAuth support" --parent <epic-id> -t task
   ticket create "Write auth tests" --parent <epic-id> -t task
   ```

2. **Set dependencies to define execution order**:
   ```bash
   ticket dep <oauth-id> <jwt-id>      # OAuth depends on JWT
   ticket dep <tests-id> <jwt-id>      # Tests depend on JWT
   ticket dep <tests-id> <oauth-id>    # Tests depend on OAuth
   ```

3. **Query ready work**:
   ```bash
   ticket ready    # Shows tickets with all deps resolved
   ```

### Phase 2: Execution Loop

For each work session, follow this loop:

```
1. Check ticket state     → ticket ready / ticket ls
2. Pick a ticket          → ticket start <id>
3. Break into todos       → todo tool with micro-tasks
4. Execute todos          → Complete each todo
5. Document progress      → ticket add-note <id> "..."
6. Close ticket           → ticket close <id>
7. Repeat                 → Back to step 1
```

### Phase 3: Context Handoff

When approaching context limits or session end:

1. **Update current ticket with state**:
   ```bash
   ticket add-note <id> "Progress: JWT signing complete, validation in progress. Next: implement refresh token logic."
   ```

2. **Ensure remaining work is ticketed**:
   ```bash
   ticket create "Implement refresh token rotation" -d "Discovered during JWT work"
   ticket dep <new-id> <current-id>
   ```

3. **Clear todos** (they don't persist):
   The next session starts fresh with todos based on the current ticket.

## Detailed Workflow

### Starting a Session

Every autonomous session should begin with orientation:

```bash
# 1. What's currently in progress?
ticket ls --status=in_progress

# 2. If nothing in progress, what's ready?
ticket ready

# 3. Pick and start a ticket
ticket start <id>

# 4. Read context from the ticket
ticket show <id>
```

### Working a Ticket

Once you've started a ticket, use todos for immediate execution:

```bash
# The ticket defines the goal
ticket show abc-123
# Output: "Implement JWT token handling"

# Break the ticket into todos for this session
# (Use the todo tool - it tracks your immediate steps)
```

**Todo tool usage**:
```json
{
  "todos": [
    {"content": "Create JWT signing function", "status": "in_progress", "active_form": "Creating JWT signing function"},
    {"content": "Create JWT validation function", "status": "pending", "active_form": "Creating JWT validation function"},
    {"content": "Add token expiration handling", "status": "pending", "active_form": "Adding token expiration handling"},
    {"content": "Write unit tests", "status": "pending", "active_form": "Writing unit tests"}
  ]
}
```

As you complete each todo:
1. Mark it complete in the todo tool
2. Move to next todo
3. Add notes to the ticket for significant progress

### Completing a Ticket

When all todos for a ticket are done:

```bash
# Add final notes
ticket add-note <id> "Implementation complete. JWT signing uses RS256, tokens expire in 1 hour, refresh tokens in 7 days."

# Close the ticket
ticket close <id>

# Check what's now unblocked
ticket ready
```

### Handling Blockers

If you encounter a blocker during execution:

```bash
# Create a ticket for the blocker
ticket create "Fix database connection timeout" -t bug -p 0

# Add dependency if it blocks current work
ticket dep <current-id> <blocker-id>

# Add note explaining the block
ticket add-note <current-id> "Blocked by database timeout issue. Created <blocker-id> to track."

# Switch to the blocker (it's now highest priority)
ticket start <blocker-id>
```

## Command Reference

### Ticket Commands

| Command | Description |
|---------|-------------|
| `ticket create "title" [opts]` | Create a ticket |
| `ticket start <id>` | Begin work (in_progress) |
| `ticket close <id>` | Complete work (closed) |
| `ticket reopen <id>` | Reopen if needed |
| `ticket ls` | List open/in-progress |
| `ticket ready` | Show tickets with resolved deps |
| `ticket blocked` | Show tickets with unresolved deps |
| `ticket show <id>` | Display full ticket |
| `ticket dep <id> <dep-id>` | Add dependency |
| `ticket undep <id> <dep-id>` | Remove dependency |
| `ticket add-note <id> "text"` | Add timestamped note |
| `ticket dep tree <id>` | Show dependency tree |
| `ticket dep cycle` | Find dependency cycles |

### Create Options

| Option | Description |
|--------|-------------|
| `-d, --description` | Detailed description |
| `-t, --type` | bug, feature, task, epic, chore |
| `-p, --priority` | 0-4 (0 = highest) |
| `--parent` | Parent ticket ID |
| `--tags` | Comma-separated tags |
| `-a, --assignee` | Assignee |

### Todo Tool

The todo tool is always available. Use it for session-scoped micro-tasks:

```json
{
  "todos": [
    {
      "content": "What needs to be done (imperative)",
      "active_form": "Present continuous form shown during execution",
      "status": "pending | in_progress | completed"
    }
  ]
}
```

**Rules**:
- One todo `in_progress` at a time
- Mark complete immediately when done
- Todos reset each session (use tickets for persistence)

## Autonomous Execution Best Practices

### 1. Always Have Tickets Before Starting

Never begin work without tickets. Create them first:

```bash
# Good: Tickets exist before execution
ticket ready
# → Shows: abc-123 [open] - Implement JWT handling

# Bad: Starting without tickets
# You'll lose track of work across sessions
```

### 2. Use Todos for Every Ticket

Break every ticket into todos before executing:

```bash
ticket start abc-123
# Then immediately create todos for this ticket's work
```

This provides:
- Clear execution path
- Progress visibility
- Resume point if interrupted

### 3. Document Decisions in Ticket Notes

Tickets are your persistent memory:

```bash
ticket add-note abc-123 "Chose bcrypt over argon2 - wider library support"
ticket add-note abc-123 "Token expiry: 1 hour access, 7 day refresh"
```

The next session can read these to understand context.

### 4. Keep Tickets Granular

Good ticket granularity:
- Completable in 1-2 hours
- Single clear objective
- Testable completion criteria

Bad:
- "Build the app" (too large)
- "Fix the bug" (too vague)

### 5. Use Dependencies Liberally

Dependencies prevent starting work before prerequisites are done:

```bash
# Explicit ordering
ticket dep test-id impl-id
ticket dep deploy-id test-id

# Now 'ticket ready' shows correct order
```

### 6. Check State Frequently

During long execution, periodically verify state:

```bash
# Every few operations
ticket ls --status=in_progress  # Should be 1 ticket
ticket ready                     # See what's next
```

### 7. Prepare for Handoff Early

Don't wait until context is exhausted. When ~50% through context:

```bash
# Update current ticket
ticket add-note <id> "Status: 3/5 functions complete. Next: implement validateToken()"

# Ensure remaining work is captured
ticket ls  # Verify all work is tracked
```

## Example: Multi-Hour Project Execution

**Project**: Add user authentication to an API

### Session 1: Planning

```bash
# Create the epic
ticket create "User Authentication System" -t epic -d "Add complete auth with JWT and OAuth"
# Returns: api-a1b2

# Break into tasks
ticket create "Design auth database schema" --parent api-a1b2
ticket create "Implement user registration" --parent api-a1b2
ticket create "Implement login endpoint" --parent api-a1b2
ticket create "Add JWT token generation" --parent api-a1b2
ticket create "Add JWT token validation middleware" --parent api-a1b2
ticket create "Implement password reset flow" --parent api-a1b2
ticket create "Add OAuth Google provider" --parent api-a1b2
ticket create "Add OAuth GitHub provider" --parent api-a1b2
ticket create "Write authentication tests" --parent api-a1b2

# Set dependencies
ticket dep <registration-id> <schema-id>
ticket dep <login-id> <registration-id>
ticket dep <jwt-gen-id> <login-id>
ticket dep <jwt-validation-id> <jwt-gen-id>
ticket dep <oauth-google-id> <jwt-validation-id>
ticket dep <oauth-github-id> <jwt-validation-id>
ticket dep <tests-id> <oauth-google-id>
ticket dep <tests-id> <oauth-github-id>

# Verify
ticket dep tree api-a1b2
```

### Session 2: Execute Schema Task

```bash
# Orient
ticket ready
# → api-schema [open] - Design auth database schema

# Start
ticket start api-schema

# Create todos for this ticket
# (via todo tool)
# - Create users table migration
# - Create sessions table migration  
# - Create oauth_accounts table migration
# - Run migrations and verify

# Execute each todo...
# (use bash to create migrations, run them, etc.)

# Document
ticket add-note api-schema "Schema complete. Tables: users, sessions, oauth_accounts. Using UUID primary keys."

# Close
ticket close api-schema

# What's next?
ticket ready
# → api-registration [open] - Implement user registration
```

### Session 3: Continue

```bash
# Orient (first thing every session)
ticket ready
# → api-registration [open] - Implement user registration

ticket start api-registration

# Read any context
ticket show api-registration

# Create todos and execute...
```

This pattern continues until all tickets are closed.

## Integration with Ayo Ecosystem

### Using with @ayo Agent

The default `@ayo` agent has access to both `todo` and `ticket` (via the `plan` category). Simply ask:

```
"Create tickets to track implementing a REST API for user management"
"Start the next ready ticket and break it into todos"
"Show me the dependency tree for the current project"
```

### Using with Delegated Agents

If using agent delegation, the orchestrating agent can:
1. Use tickets to track high-level work
2. Delegate specific tickets to specialized agents
3. Track completion via ticket status

### Memory Integration

Ayo's memory system complements tickets:
- **Memory**: Stores preferences, corrections, facts (cross-project)
- **Tickets**: Stores project-specific work items (single project)

Use memory for "always use bcrypt for passwords" and tickets for "implement password hashing in this project".

## Ticket File Format

Tickets are stored as markdown in `.tickets/`:

```markdown
---
id: api-a1b2
title: Implement JWT token generation
status: in_progress
type: task
priority: 1
parent: api-epic
depends_on:
  - api-login
created: 2025-01-30T10:00:00Z
updated: 2025-01-31T14:30:00Z
tags:
  - auth
  - jwt
---

## Description

Generate JWT tokens on successful login.

## Notes

### 2025-01-31T14:30:00Z
Using RS256 signing. Keys stored in environment variables.

### 2025-01-31T10:00:00Z
Started implementation. Evaluating jwt-go vs golang-jwt.
```

## ID Matching

Ticket IDs support partial matching:

```bash
ticket show a1b2      # Matches api-a1b2 if unique
ticket start 3c       # Matches any ID containing "3c"
```

If ambiguous, be more specific.
