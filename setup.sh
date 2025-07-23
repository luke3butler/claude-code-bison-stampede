#!/bin/bash

# Claude Code - Bison Stampede Setup/Configuration
# Just run ./setup.sh and follow the prompts!

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration paths - define once, use everywhere
CLAUDE_DIR="$HOME/.claude"
CLAUDE_CODE_BISON_DIR="$HOME/.claude-code-bison-stampede"
CLAUDE_MD_FILE="CLAUDE.md"
CLAUDE_PROJECT_MD_FILE="CLAUDE_PROJECT.md"
CONFIG_DIR="config"
MCP_CONFIG_FILE="mcp.json"

# Repository configuration - customize for your fork
REPO_URL="https://github.com/luke3butler/claude-code-bison-stampede"

# Disable strict mode for this script to handle errors gracefully
set +u
set +e

echo -e "${BLUE}🚀 Claude Code - Bison Stampede Setup${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Parse command line arguments
SKIP_PROMPTS=false
AUTO_INSTALL=false
for arg in "$@"; do
    case $arg in
        --yes|-y)
            SKIP_PROMPTS=true
            AUTO_INSTALL=true
            ;;
        --help|-h)
            echo "Usage: ./setup.sh [options]"
            echo ""
            echo "Options:"
            echo "  --yes, -y     Auto-confirm all prompts (install everything)"
            echo "  --help, -h    Show this help message"
            echo ""
            echo "Just run ./setup.sh without options for interactive setup!"
            exit 0
            ;;
    esac
done

# Set up directories
SCRIPTS_INSTALL_DIR="$CLAUDE_DIR/scripts"
COMMANDS_INSTALL_DIR="$CLAUDE_DIR/commands"

# DISABLED: Clone or update the repo in ~/.claude-code-bison-stampede - Bison Stampede v1 simplification
# Focus on core Claude Code CLI + MCP setup without git dependency
echo -e "${BLUE}📂 Skipping repository management (v1 focuses on standalone setup)${NC}"
echo ""

# if [ ! -d "$CLAUDE_CODE_BISON_DIR" ]; then
#     echo -e "${YELLOW}📥 Cloning Bison Stampede setup to $CLAUDE_CODE_BISON_DIR...${NC}"
#     if git clone "$REPO_URL" "$CLAUDE_CODE_BISON_DIR" 2>/dev/null; then
#         echo -e "${GREEN}✅ Repository cloned successfully${NC}"
#     else
#         echo -e "${RED}❌ Failed to clone repository${NC}"
#         echo "Please check your internet connection and repository URL."
#         exit 1
#     fi
# else
#     echo -e "${YELLOW}📥 Updating existing repository at $CLAUDE_CODE_BISON_DIR...${NC}"
#     if cd "$CLAUDE_CODE_BISON_DIR" && git pull 2>/dev/null; then
#         echo -e "${GREEN}✅ Repository updated successfully${NC}"
#     else
#         echo -e "${YELLOW}⚠️  Failed to update repository (continuing with existing version)${NC}"
#     fi
# fi

# DISABLED: Set the helpers directory to our maintained repo
# CLAUDE_HELPERS_DIR="$CLAUDE_CODE_BISON_DIR"

# Detect OS and package manager
detect_platform() {
    local os=""
    local pkg_manager=""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        os="macOS"
        if command -v brew &> /dev/null; then
            pkg_manager="brew"
        else
            pkg_manager="none"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os="Linux"
        if command -v apt &> /dev/null; then
            pkg_manager="apt"
        elif command -v yum &> /dev/null; then
            pkg_manager="yum"
        elif command -v dnf &> /dev/null; then
            pkg_manager="dnf"
        elif command -v pacman &> /dev/null; then
            pkg_manager="pacman"
        else
            pkg_manager="unknown"
        fi
    else
        os="Unknown OS"
        pkg_manager="unknown"
    fi
    
    echo -e "${BLUE}🖥️  System:${NC} $os"
    echo -e "${BLUE}📦 Package Manager:${NC} ${pkg_manager:-Not found}"
    echo ""
    
    OS="$os"
    PKG_MANAGER="$pkg_manager"
}

# Install Homebrew on macOS if not present
install_homebrew() {
    if [[ "$OS" == "macOS" ]] && [[ "$PKG_MANAGER" == "none" ]]; then
        echo -e "${YELLOW}Homebrew is not installed on your Mac.${NC}"
        echo "Homebrew is recommended for installing optional tools."
        echo ""
        
        if [ "$SKIP_PROMPTS" = true ]; then
            response="y"
        else
            echo -n "Would you like to install Homebrew now? [Y/n] "
            read -r response
            response=${response:-y}
        fi
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}📥 Installing Homebrew...${NC}"
            if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
                # Add Homebrew to PATH for this session
                if [[ -d "/opt/homebrew" ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                else
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
                PKG_MANAGER="brew"
                echo -e "${GREEN}✅ Homebrew installed successfully${NC}"
            else
                echo -e "${RED}❌ Failed to install Homebrew${NC}"
                echo "Continuing without package manager..."
            fi
        fi
        echo ""
    fi
}

# Install Node.js and Claude Code CLI
install_nodejs_and_claude() {
    echo -e "${BLUE}📦 Installing Node.js and Claude Code CLI...${NC}"
    
    # Check current Node.js version
    local current_version=""
    local needs_install=true
    
    if command -v node &> /dev/null; then
        current_version=$(node --version 2>/dev/null | sed 's/v//')
        local major_version=$(echo "$current_version" | cut -d. -f1)
        
        if [ "$major_version" -ge 20 ]; then
            echo -e "${GREEN}✅ Node.js v$current_version (>= v20)${NC}"
            needs_install=false
        else
            echo -e "${RED}❌ Node.js v$current_version found, but need v20+${NC}"
        fi
    else
        echo -e "${RED}❌ Node.js not found${NC}"
    fi
    
    # Node.js v20+ is REQUIRED - cannot continue without it
    if [ "$needs_install" = true ]; then
        # On macOS, require Homebrew
        if [[ "$OS" == "macOS" ]]; then
            if [ "$PKG_MANAGER" != "brew" ]; then
                echo -e "${RED}❌ Homebrew is required to install Node.js on macOS${NC}"
                echo "Please install Homebrew first or run this script with --yes to auto-install"
                return 1
            fi
            
            echo -n "Installing Node.js via Homebrew... "
            if brew install node &> /dev/null; then
                echo -e "${GREEN}✅${NC}"
            else
                echo -e "${RED}❌${NC}"
                echo -e "${RED}Failed to install Node.js via Homebrew${NC}"
                return 1
            fi
        else
            # Non-macOS systems
            echo -e "${RED}❌ Node.js v20+ is required but not installed${NC}"
            echo "Please install Node.js v20+ manually from: https://nodejs.org/"
            echo "Then re-run this script."
            return 1
        fi
        
        # Verify installation
        if command -v node &> /dev/null; then
            local new_version=$(node --version 2>/dev/null | sed 's/v//')
            local new_major_version=$(echo "$new_version" | cut -d. -f1)
            
            if [ "$new_major_version" -ge 20 ]; then
                echo -e "${GREEN}✅ Node.js v$new_version installed${NC}"
            else
                echo -e "${RED}❌ Installed Node.js v$new_version is still < v20${NC}"
                return 1
            fi
        else
            echo -e "${RED}❌ Node.js installation failed${NC}"
            return 1
        fi
    fi
    
    # Install Claude Code CLI
    echo -n "Installing Claude Code CLI... "
    if npm install -g @anthropic-ai/claude-code &> /dev/null; then
        echo -e "${GREEN}✅${NC}"
        
        # Verify installation
        if command -v claude &> /dev/null; then
            local claude_version=$(claude --version 2>/dev/null | head -1)
            echo -e "${GREEN}✅ Claude Code CLI installed: $claude_version${NC}"
        else
            echo -e "${YELLOW}⚠️  Claude Code CLI installed but not in PATH${NC}"
            echo -e "${YELLOW}You may need to restart your terminal or add npm global bin to PATH${NC}"
        fi
    else
        echo -e "${RED}❌${NC}"
        echo -e "${RED}Failed to install Claude Code CLI${NC}"
        echo "Try running manually: npm install -g @anthropic-ai/claude-code"
        return 1
    fi
    
    echo ""
    return 0
}

# Check if we need sudo for package installation
check_sudo() {
    if [[ "$PKG_MANAGER" =~ ^(apt|yum|dnf|pacman)$ ]]; then
        if ! sudo -n true 2>/dev/null; then
            echo -e "${YELLOW}⚠️  Some tools require administrator access to install.${NC}"
            echo "You may be prompted for your password."
            echo ""
            sudo true || {
                echo -e "${RED}❌ Cannot get administrator access${NC}"
                echo "Continuing without installing system packages..."
                return 1
            }
        fi
    fi
    return 0
}

# DISABLED: Install core scripts - Bison Stampede v1 customization
# Focus on Claude Code CLI + MCP servers instead of helper scripts
install_core_scripts() {
    echo -e "${BLUE}📂 Skipping scripts installation (v1 focuses on Claude Code + MCP)${NC}"
    
    # Create directories in case other parts need them
    mkdir -p "$CLAUDE_DIR"
    
    echo ""
    return 0
}

# DISABLED: Add aliases to shell config - Bison Stampede v1 customization  
# Aliases disabled since scripts are disabled
setup_shell_aliases() {
    echo -e "${BLUE}🐚 Skipping shell aliases (v1 focuses on Claude Code + MCP)${NC}"
    echo ""
    return 0
}

# Check and install essential Claude Code enhancement tools
check_optional_tools() {
    echo -e "${BLUE}🔍 Checking essential Claude Code enhancement tools...${NC}"
    echo ""
    
    # Check what's installed
    local missing_tools=()
    local found_tools=()
    
    # Check each tool individually (bash 3 compatible)
    # fzf
    if command -v fzf &> /dev/null; then
        echo -e "${GREEN}✅ fzf${NC} - Interactive file/text selection"
        found_tools+=("fzf")
    else
        echo -e "${YELLOW}⚪ fzf${NC} - Interactive file/text selection (not installed)"
        missing_tools+=("fzf")
    fi
    
    # jq
    if command -v jq &> /dev/null; then
        echo -e "${GREEN}✅ jq${NC} - JSON parsing and manipulation"
        found_tools+=("jq")
    else
        echo -e "${YELLOW}⚪ jq${NC} - JSON parsing and manipulation (not installed)"
        missing_tools+=("jq")
    fi
    
    # yq
    if command -v yq &> /dev/null; then
        echo -e "${GREEN}✅ yq${NC} - YAML parsing and manipulation"
        found_tools+=("yq")
    else
        echo -e "${YELLOW}⚪ yq${NC} - YAML parsing and manipulation (not installed)"
        missing_tools+=("yq")
    fi
    
    # OPTIONAL: Additional tools (commented out for Bison Stampede v1)
    # # bat
    # if command -v bat &> /dev/null; then
    #     echo -e "${GREEN}✅ bat${NC} - Syntax-highlighted file viewing"
    #     found_tools+=("bat")
    # else
    #     echo -e "${YELLOW}⚪ bat${NC} - Syntax-highlighted file viewing (not installed)"
    #     missing_tools+=("bat")
    # fi
    # 
    # # gum
    # if command -v gum &> /dev/null; then
    #     echo -e "${GREEN}✅ gum${NC} - Beautiful interactive prompts"
    #     found_tools+=("gum")
    # else
    #     echo -e "${YELLOW}⚪ gum${NC} - Beautiful interactive prompts (not installed)"
    #     missing_tools+=("gum")
    # fi
    # 
    # # delta
    # if command -v delta &> /dev/null; then
    #     echo -e "${GREEN}✅ delta${NC} - Enhanced git diffs"
    #     found_tools+=("delta")
    # else
    #     echo -e "${YELLOW}⚪ delta${NC} - Enhanced git diffs (not installed)"
    #     missing_tools+=("delta")
    # fi
    
    # ripgrep
    if command -v rg &> /dev/null || command -v ripgrep &> /dev/null; then
        echo -e "${GREEN}✅ ripgrep${NC} - Fast file content searching"
        found_tools+=("ripgrep")
    else
        echo -e "${YELLOW}⚪ ripgrep${NC} - Fast file content searching (not installed)"
        missing_tools+=("ripgrep")
    fi
    
    # If tools are missing and we have a package manager
    if [ ${#missing_tools[@]} -gt 0 ] && [ "$PKG_MANAGER" != "none" ] && [ "$PKG_MANAGER" != "unknown" ]; then
        echo ""
        echo -e "${YELLOW}📦 Essential Claude Code enhancement tools missing!${NC}"
        echo "These tools are recommended for Claude Code development:"
        echo "fzf, jq, yq, ripgrep"
        echo ""
        
        if [ "$AUTO_INSTALL" = true ]; then
            response="y"
        else
            echo -n "Would you like to install the missing tools? [Y/n] "
            read -r response
            response=${response:-y}
        fi
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            install_optional_tools "${missing_tools[@]}"
        else
            echo -e "${BLUE}Skipping optional tools.${NC}"
        fi
    elif [ ${#missing_tools[@]} -eq 0 ]; then
        echo ""
        echo -e "${GREEN}🎉 All essential Claude Code enhancement tools are already installed!${NC}"
    fi
    
    echo ""
}

# Install optional tools
install_optional_tools() {
    local tools=("$@")
    
    echo ""
    echo -e "${BLUE}📦 Installing optional tools...${NC}"
    
    # Check sudo if needed
    if [[ "$PKG_MANAGER" =~ ^(apt|yum|dnf|pacman)$ ]]; then
        if ! check_sudo; then
            echo -e "${YELLOW}Skipping tools that require admin access${NC}"
            return
        fi
    fi
    
    for tool in "${tools[@]}"; do
        echo -n "Installing $tool... "
        
        case "$PKG_MANAGER:$tool" in
            # macOS with Homebrew
            brew:*)
                if brew install "$tool" &> /dev/null; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌${NC}"
                fi
                ;;
            
            # Ubuntu/Debian special cases
            apt:ripgrep)
                if sudo apt-get update &> /dev/null && sudo apt-get install -y ripgrep &> /dev/null; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌${NC}"
                fi
                ;;
            apt:bat)
                if sudo apt-get install -y bat &> /dev/null; then
                    # Create symlink for batcat -> bat
                    sudo ln -sf /usr/bin/batcat /usr/local/bin/bat 2>/dev/null
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌${NC}"
                fi
                ;;
            apt:fzf|apt:jq)
                if sudo apt-get install -y "$tool" &> /dev/null; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌${NC}"
                fi
                ;;
            apt:delta|apt:gum)
                echo -e "${YELLOW}⚠️  Manual install needed${NC}"
                case "$tool" in
                    delta) echo "   Visit: https://github.com/dandavison/delta" ;;
                    gum) echo "   Visit: https://github.com/charmbracelet/gum" ;;
                esac
                ;;
            
            # Other package managers
            yum:*|dnf:*)
                if sudo "$PKG_MANAGER" install -y "$tool" &> /dev/null; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌${NC}"
                fi
                ;;
            pacman:*)
                if sudo pacman -S --noconfirm "$tool" &> /dev/null; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌${NC}"
                fi
                ;;
            *)
                echo -e "${YELLOW}⚠️  Cannot auto-install${NC}"
                ;;
        esac
    done
}

# DISABLED: Create or update global CLAUDE.md - Bison Stampede v1 customization
# Focus on Claude Code CLI + MCP servers instead of helper scripts documentation
setup_global_claude_md() {
    echo -e "${BLUE}📝 Skipping global CLAUDE.md setup (v1 focuses on Claude Code + MCP)${NC}"
    echo ""
    return 0
}
}

# Setup MCP servers at user level
setup_mcp_servers() {
    echo -e "${BLUE}🤖 MCP Server Setup${NC}"
    
    # Check if claude command exists (check both command and common install locations)
    local claude_cmd=""
    if command -v claude &> /dev/null; then
        claude_cmd="claude"
    elif [ -x "$CLAUDE_DIR/local/claude" ]; then
        claude_cmd="$CLAUDE_DIR/local/claude"
    else
        echo -e "${YELLOW}⚠️  Claude Code CLI not found${NC}"
        echo "Install Claude Code to use MCP servers: https://docs.anthropic.com/claude-code"
        echo ""
        return
    fi
    
    # Check existing MCP servers
    echo -e "${BLUE}🔍 Checking existing MCP servers...${NC}"
    local has_atlassian=false
    
    if $claude_cmd mcp list 2>/dev/null | grep -q "atlassian"; then
        has_atlassian=true
        echo -e "${GREEN}✅ Atlassian MCP server already configured${NC}"
    fi
    
    # If Atlassian is already installed, we're done
    if [ "$has_atlassian" = true ]; then
        echo -e "${GREEN}✨ Atlassian MCP server is already set up!${NC}"
        echo ""
        return
    fi
    
    # Check if user wants to add missing MCP servers
    if [ "$SKIP_PROMPTS" = true ]; then
        response="y"
    else
        echo ""
        echo "MCP servers enhance Claude Code with:"
        echo "  • Atlassian - Jira and Confluence integration"
        echo ""
        echo -n "Would you like to install the Atlassian MCP server? [Y/n] "
        read -r response
        response=${response:-y}
    fi
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${BLUE}📦 Installing MCP servers...${NC}"
        echo ""
        
        # Install Atlassian MCP server
        echo -n "Installing Atlassian MCP server... "
        if $claude_cmd mcp add --transport sse atlassian -s user https://mcp.atlassian.com/v1/sse &>/dev/null; then
            echo -e "${GREEN}✅${NC}"
        else
            echo -e "${RED}❌ Failed${NC}"
            echo -e "${YELLOW}  Manual command: claude mcp add --transport sse atlassian -s user https://mcp.atlassian.com/v1/sse${NC}"
        fi
        
        echo ""
        echo -e "${GREEN}✨ Atlassian MCP server configured!${NC}"
        echo -e "${BLUE}ℹ️  This server is now available in all your projects${NC}"
        echo -e "${BLUE}ℹ️  Run 'claude mcp list' to see all configured servers${NC}"
        
        # # Copy mcp.json to current directory for project-level option
        # if [ -n "$CLAUDE_HELPERS_DIR" ] && [ -f "$CLAUDE_HELPERS_DIR/$CONFIG_DIR/$MCP_CONFIG_FILE" ] && [ "$PWD" != "$CLAUDE_HELPERS_DIR" ]; then
        #     echo ""
        #     echo -e "${YELLOW}Alternative: Project-level configuration${NC}"
        #     echo "The $MCP_CONFIG_FILE file is available in claude-helpers/$CONFIG_DIR/"
        #     echo "Copy it to any project root for project-specific MCP servers"
        # fi
    else
        echo -e "${BLUE}Skipping MCP server setup${NC}"
    fi
    
    echo ""
}

# Main setup flow
main() {
    # Step 1: Detect platform
    detect_platform
    
    # Step 2: Install Homebrew on macOS if needed
    if [[ "$OS" == "macOS" ]]; then
        install_homebrew
    fi
    
    # Step 2.5: Install Node.js and Claude Code CLI (REQUIRED)
    if ! install_nodejs_and_claude; then
        echo -e "${RED}❌ Failed to install Node.js and Claude Code CLI${NC}"
        echo -e "${RED}Cannot continue without Node.js v20+ and Claude Code CLI${NC}"
        exit 1
    fi
    
    # Step 3: Setup directories and skip scripts (disabled for v1)
    install_core_scripts
    
    # Step 4: Setup shell aliases
    setup_shell_aliases
    
    # Step 5: Create/update global CLAUDE.md
    setup_global_claude_md
    
    # Step 6: Setup MCP servers
    setup_mcp_servers
    
    # Step 7: Check and offer to install optional tools
    check_optional_tools
    
    # Final instructions
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✨ Setup Complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}📝 Quick Start:${NC}"
    echo "1. Verify Claude Code CLI installation:"
    echo -e "   ${YELLOW}claude --version${NC}"
    echo ""
    echo "2. Check your MCP servers:"
    echo -e "   ${YELLOW}claude mcp list${NC}"
    echo ""
    echo "3. Start using Claude Code in your projects:"
    echo -e "   ${YELLOW}cd your-project && claude${NC}"
    echo ""
    echo -e "${BLUE}Enjoy your enhanced Claude Code development! 🚀${NC}"
    
    # Repository maintained at ~/.claude-code-bison-stampede (no cleanup needed)
}

# Run main setup
main

# Make sure we exit successfully
exit 0