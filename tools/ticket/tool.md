# Ticket Tool

Durable project planning with file-based tickets stored in `.tickets/` directory. Tickets persist across sessions and agent context handoffs, making them ideal for long-running projects and multi-session workflows.

## When to Use

Use the **ticket** tool for:
- Project-level planning that survives session boundaries
- Tasks that span multiple work sessions
- Tracking dependencies between work items
- Epics and features with sub-tasks
- Work that may be handed off between agents or sessions

Use the **todo** tool instead for:
- Immediate execution tracking within current session
- Micro-tasks that will be completed in this conversation
- Ephemeral checklists that don't need persistence

## Commands Reference

### Creating Tickets

```bash
# Create a task with title
tk create "Implement user authentication"

# Create with options
tk create "Add OAuth support" -d "Support Google and GitHub OAuth" -t feature -p 1 --tags auth,security

# Create a bug
tk create "Login fails on Safari" -t bug -p 0
```

**Create options:**
- `-d, --description` - Description text
- `--design` - Design notes
- `--acceptance` - Acceptance criteria
- `-t, --type` - Type: bug, feature, task, epic, chore (default: task)
- `-p, --priority` - Priority 0-4, 0=highest (default: 2)
- `-a, --assignee` - Assignee
- `--external-ref` - External reference (e.g., gh-123, JIRA-456)
- `--parent` - Parent ticket ID
- `--tags` - Comma-separated tags (e.g., --tags ui,backend,urgent)

### Managing Status

```bash
tk start <id>              # Set to in_progress
tk close <id>              # Set to closed
tk reopen <id>             # Set to open
tk status <id> <status>    # Set any status: open, in_progress, closed
```

### Listing Tickets

```bash
tk ls                      # List all open/in-progress tickets
tk ls --status=open        # Filter by status
tk ls -a username          # Filter by assignee
tk ls -T feature           # Filter by type
tk ready                   # Open tickets with all deps resolved
tk blocked                 # Tickets with unresolved dependencies
tk closed                  # Recently closed tickets
tk closed --limit=50       # More closed tickets
```

### Viewing and Editing

```bash
tk show <id>               # Display full ticket
tk edit <id>               # Open in $EDITOR
tk add-note <id> "note"    # Append timestamped note
echo "note" | tk add-note <id>  # Note from stdin
```

### Dependencies

```bash
tk dep <id> <dep-id>       # id depends on dep-id
tk undep <id> <dep-id>     # Remove dependency
tk dep tree <id>           # Show dependency tree
tk dep tree --full <id>    # Full tree (no dedup)
tk dep cycle               # Find dependency cycles
```

### Links (Symmetric Relationships)

```bash
tk link <id1> <id2>        # Link tickets together
tk link <id1> <id2> <id3>  # Link multiple
tk unlink <id1> <id2>      # Remove link
```

### Query (JSON Output)

```bash
tk query                   # All tickets as JSON
tk query '.[] | select(.status == "open")'  # jq filter
```

## Ticket File Format

Tickets are stored as markdown files with YAML frontmatter in `.tickets/`:

```markdown
---
id: proj-a1b2
title: Implement user authentication
status: open
type: feature
priority: 1
created: 2025-01-30T10:00:00Z
updated: 2025-01-30T10:00:00Z
tags:
  - auth
  - security
depends_on: []
links: []
---

## Description

Support email/password and OAuth login.

## Notes

### 2025-01-30T10:30:00Z
Started research on OAuth providers.
```

## Workflow Example

```bash
# Plan a feature
tk create "User authentication system" -t epic --tags auth

# Break into tasks
tk create "Design auth flow" --parent ep-1234 -t task
tk create "Implement JWT tokens" --parent ep-1234 -t task
tk create "Add OAuth support" --parent ep-1234 -t task

# Set dependencies
tk dep oauth-id jwt-id     # OAuth depends on JWT being done first

# Start work
tk start jwt-id
tk add-note jwt-id "Using RS256 signing"

# Complete
tk close jwt-id

# Check what's ready
tk ready                   # OAuth is now unblocked
```

## ID Matching

Ticket IDs support partial matching:
- Full ID: `proj-a1b2`
- Partial: `a1b2` or `a1` (if unique)
