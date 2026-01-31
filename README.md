# ayo-plugins-ticket

Durable project planning plugin for [ayo](https://github.com/alexcabrera/ayo) using file-based tickets. Enables multi-session agent workflows where project state persists across context handoffs.

## Installation

```bash
ayo plugins install https://github.com/alexcabrera/ayo-plugins-ticket
```

This will:
1. Install the plugin to `~/.local/share/ayo/plugins/ticket/`
2. Create a symlink for `tk` in `~/.local/bin/`
3. Prompt to set `ticket` as the default for the `plan` tool category

## Usage

### Configure as Default Plan Tool

After installation, add to `~/.config/ayo/ayo.json`:

```json
{
  "default_tools": {
    "plan": "ticket"
  }
}
```

### Agent Configuration

Agents that need durable planning should include `plan` in their allowed tools:

```json
{
  "allowed_tools": ["bash", "plan"]
}
```

## How It Works

The plugin provides the `ticket` tool which wraps the `tk` CLI. Tickets are stored as markdown files with YAML frontmatter in a `.tickets/` directory at your project root.

### Todo vs Ticket

| Aspect | Todo | Ticket |
|--------|------|--------|
| Scope | Session | Project |
| Storage | SQLite (ephemeral) | Files (durable) |
| Survives context handoff | No | Yes |
| Dependencies | No | Yes |
| Use case | Immediate micro-tasks | Project planning |

### Workflow Example

```bash
# Agent creates tickets for a feature
tk create "User authentication" -t epic --tags auth

# Break into dependent tasks
tk create "Design auth flow" --parent auth-123
tk create "Implement JWT" --parent auth-123
tk create "Add OAuth" --parent auth-123 -d "Depends on JWT"
tk dep oauth-id jwt-id

# Track progress
tk start jwt-id
tk add-note jwt-id "Using RS256 for signing"
tk close jwt-id

# See what's unblocked
tk ready  # OAuth now appears
```

### Commands

| Command | Description |
|---------|-------------|
| `tk create [title]` | Create a ticket |
| `tk start <id>` | Set status to in_progress |
| `tk close <id>` | Set status to closed |
| `tk ls` | List open/in-progress tickets |
| `tk ready` | List tickets with resolved deps |
| `tk blocked` | List tickets with unresolved deps |
| `tk show <id>` | Display ticket details |
| `tk dep <id> <dep-id>` | Add dependency |
| `tk add-note <id> [text]` | Append timestamped note |

See `tk --help` for full command reference.

## Requirements

- ayo >= 0.2.0
- bash

## License

MIT
