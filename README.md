# ayo-plugins-ticket

Durable project planning plugin for [ayo](https://github.com/alexcabrera/ayo) using file-based tickets. Enables multi-session agent workflows where project state persists across context handoffs.

## Credits

This plugin bundles and installs [ticket](https://github.com/wedow/ticket) (`tk`), a minimal ticket system with dependency tracking designed for AI agents. The `tk` CLI is vendored in this plugin and automatically symlinked to `~/.local/bin/` during installation.

## Installation

```bash
ayo plugins install https://github.com/alexcabrera/ayo-plugins-ticket
```

This will:
1. Install the plugin to `~/.local/share/ayo/plugins/ticket/`
2. Install the `tk` CLI to `~/.local/bin/` (via symlink)
3. Add the `ticket-planning` skill to all agents

## Usage

The plugin provides the `ticket-planning` skill which teaches agents how to use `tk` via bash for durable project planning. Agents use `tk` directly through the bash tool - no special tool wrapper needed.

### How Agents Use tk

Agents with bash access can use tk commands directly:

```bash
# Create tickets
tk create "Implement user auth" -t epic -d "Add authentication system"

# Break into sub-tasks
tk create "Design auth flow" --parent <epic-id>
tk create "Implement JWT handling" --parent <epic-id>

# Set dependencies
tk dep <child-id> <parent-id>

# Track progress
tk start <id>
tk add-note <id> "Using RS256 signing"
tk close <id>

# Check status
tk ls           # List open tickets
tk ready        # Show unblocked tickets
tk blocked      # Show blocked tickets
```

### The Two-Tier Planning System

This plugin works alongside ayo's built-in `todo` tool:

| Tool | Scope | Storage | Purpose |
|------|-------|---------|---------|
| `todo` | Session | SQLite | Track immediate execution steps |
| `tk` | Project | Files | Track work across sessions |

**Use both together**: Tickets define *what* to accomplish; todos track *how* you're doing it right now.

## Autonomous Multi-Hour Execution

The `ticket-planning` skill teaches agents to:

1. **Orient** - Check `tk ready` and `tk ls` at session start
2. **Plan** - Break epics into tickets with dependencies
3. **Execute** - Work on one ticket at a time, using todos for micro-steps
4. **Document** - Add notes with `tk add-note` for context handoff
5. **Complete** - Close tickets and move to next ready work

See the skill documentation for detailed patterns.

## Ticket File Format

Tickets are stored as markdown in `.tickets/`:

```markdown
---
id: proj-a1b2
title: Implement JWT tokens
status: in_progress
type: task
depends_on:
  - proj-design
---

## Description

Implement JWT token generation and validation.

## Notes

### 2025-01-31T14:30:00Z
Using RS256 signing. Keys in env vars.
```

## Requirements

- ayo >= 0.2.0
- bash
- `~/.local/bin` in PATH (for tk access)

## License

MIT

The bundled `tk` CLI is from [ticket](https://github.com/wedow/ticket).
