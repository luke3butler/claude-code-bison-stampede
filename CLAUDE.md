# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **"Claude Code - Bison Stampede Setup"** project - a macOS development environment setup and configuration tool specifically designed to enhance Claude Code CLI usage. The project focuses on streamlining the installation of Claude Code CLI with MCP (Model Context Protocol) servers and essential development tools.

## Architecture

### Core Components

- **`setup.sh`** - Main bash setup script (600+ lines) that handles:
  - Platform detection (macOS/Linux with various package managers)
  - Node.js v20+ installation (required for Claude Code CLI)
  - Claude Code CLI installation via npm
  - User-level MCP server configuration (Atlassian)
  - Essential development tools (fzf, jq, yq, ripgrep)

- **`commands/`** - Claude Code workflow templates:
  - `dev-diary.md` - Template for reflective developer diary entries
  - `understand-codebase.md` - Deep-dive analysis questions for understanding codebases
  - `update-docs.md` - Systematic documentation update workflow

- **`config/`** - Configuration templates:
  - `mcp.json` - MCP server configuration for Atlassian integration
  - Placeholder files for future project-specific instructions

### Key Design Philosophy

This is "Bison Stampede v1" which deliberately focuses on core Claude Code CLI functionality rather than comprehensive scripting. The setup script intentionally **disables**:
- Helper script installation (lines 261-268)
- Shell aliases setup (lines 273-276) 
- Global CLAUDE.md creation (lines 466-470)

## Development Workflows

### Main Setup Command
```bash
# Interactive setup
./setup.sh

# Automated setup (skip all prompts)
./setup.sh --yes

# Help
./setup.sh --help
```

### Using Command Templates
The `commands/` directory contains structured templates for common Claude Code workflows:

1. **Developer Diary** (`/dev-diary`) - Create reflective entries about development work
2. **Codebase Understanding** (`/understand-codebase`) - Deep analysis of system architecture
3. **Documentation Updates** (`/update-docs`) - Systematic documentation maintenance

These templates provide structured prompts and questions to guide thorough analysis and documentation.

### Setup Process Requirements
- **Node.js v20+** (automatically installed if missing)
- **Git** (for repository cloning/updating)
- **Package manager**: Homebrew (macOS), apt/yum/dnf/pacman (Linux)

### Installation Locations
- Repository: `~/.claude-code-bison-stampede` (self-updating)
- Claude CLI config: `~/.claude/`
- MCP servers: Configured at user level (not project-level)

## MCP Integration

The setup configures the Atlassian MCP server for Jira and Confluence integration:

```json
{
  "mcpServers": {
    "atlassian": {
      "type": "sse", 
      "url": "https://mcp.atlassian.com/v1/sse"
    }
  }
}
```

Verify MCP setup with:
```bash
claude mcp list
```

## Project Structure

```
acc-setup/
├── setup.sh              # Main setup script
├── LICENSE               # MIT License
├── commands/             # Claude Code workflow templates
│   ├── dev-diary.md     # Developer diary template
│   ├── understand-codebase.md  # Codebase analysis template
│   └── update-docs.md   # Documentation update template
└── config/              # Configuration templates
    ├── CLAUDE_PROJECT.md # Project-specific instructions (placeholder)
    ├── CLAUDE_USER.md   # User helper scripts (placeholder)
    └── mcp.json         # MCP server configuration
```

## Maintenance

The setup script is self-updating - it clones/updates itself to `~/.claude-code-bison-stampede` on each run. To customize:

1. Fork the repository
2. Update `REPO_URL` in `setup.sh` (line 22)
3. Modify configuration in `config/` directory
4. Add new command templates to `commands/` directory