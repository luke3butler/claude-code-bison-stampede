# Claude Code - Bison Stampede Setup

A streamlined setup tool for enhancing your Claude Code CLI experience with MCP servers and essential development tools.

## Quick Install

```bash
curl -sSL https://raw.githubusercontent.com/luke3butler/claude-code-bison-stampede/main/setup.sh | bash
```

Or for automated installation (skip all prompts):

```bash
curl -sSL https://raw.githubusercontent.com/luke3butler/claude-code-bison-stampede/main/setup.sh | bash -s -- --yes
```

## What It Does

This setup tool automatically configures your development environment with:

- **Claude Code CLI** - Installs the official Claude Code CLI (requires Node.js v20+)
- **Atlassian MCP Server** - Enables Jira and Confluence integration in Claude Code
- **Essential Tools** - Installs development tools like `fzf`, `jq`, `yq`, and `ripgrep`
- **Command Templates** - Provides structured workflows for common development tasks

## Features

### 🚀 One-Command Setup
Run a single command to get a fully configured Claude Code development environment.

### 🤖 MCP Server Integration
Pre-configured Atlassian MCP server for seamless Jira and Confluence workflow integration.

### 🛠️ Essential Development Tools
Automatically installs CLI tools that enhance Claude Code's capabilities:
- `fzf` - Interactive file/text selection
- `jq` - JSON parsing and manipulation  
- `yq` - YAML parsing and manipulation
- `ripgrep` - Fast file content searching

### 📋 Workflow Templates
Includes structured command templates for common development tasks (available in the repository).

## Requirements

- **macOS** or **Linux**
- **Internet connection** (for downloads)

Node.js v20+ and package managers (Homebrew on macOS) will be automatically installed if not present.

## Manual Installation

If you prefer to review the script first:

```bash
# Clone the repository
git clone https://github.com/luke3butler/claude-code-bison-stampede.git
cd claude-code-bison-stampede

# Review the setup script
cat setup.sh

# Run setup
./setup.sh
```

## Usage

After installation, verify your setup:

```bash
# Check Claude Code CLI
claude --version

# List configured MCP servers
claude mcp list

# Start using Claude Code in your projects
cd your-project
claude
```

## Command Line Options

```bash
./setup.sh           # Interactive setup with prompts
./setup.sh --yes     # Automated setup (skip all prompts)
./setup.sh --help    # Show help message
```

## Architecture

This is "Bison Stampede v1" - a focused setup tool that prioritizes core Claude Code CLI functionality:
- Claude Code CLI installation and configuration
- User-level MCP server setup
- Essential development tool installation

## Contributing

1. Fork the repository
2. Update `REPO_URL` in `setup.sh` to point to your fork
3. Make your changes
4. Test the setup process
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.