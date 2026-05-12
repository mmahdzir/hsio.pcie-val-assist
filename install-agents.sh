#!/bin/bash

set -e

# ─────────────────────────────────────────────────────────────────────────────
# HSIO PCIe Validation Assistant — Copilot CLI Agent Installer
#
# Installs agents, skills, and testplan data for PCH HSIO PCIe test development.
# ─────────────────────────────────────────────────────────────────────────────

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── Print helpers ────────────────────────────────────────────────────────────

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${CYAN}[OK]${NC} $1"
}

# ── Extract YAML frontmatter field from a markdown file ──────────────────────

extract_frontmatter() {
    local file="$1"
    local field="$2"

    awk -v field="$field" '
        /^---$/ { in_front++; next }
        in_front == 1 && $1 == field":" {
            sub(/^[^:]+:[[:space:]]*/, "")
            gsub(/^["\047]|["\047]$/, "")
            val = $0
            # Handle folded block scalars (>- with indented continuation lines)
            if (val == ">-" || val == ">") {
                val = ""
                while ((getline line) > 0) {
                    if (line ~ /^[[:space:]]/) {
                        gsub(/^[[:space:]]+/, "", line)
                        gsub(/[[:space:]]+$/, "", line)
                        if (line == "") continue
                        if (val != "") val = val " "
                        val = val line
                    } else {
                        break
                    }
                }
            }
            # Truncate at Triggers: section for cleaner display
            idx = index(val, "Triggers:")
            if (idx > 0) val = substr(val, 1, idx - 1)
            # Trim trailing whitespace
            gsub(/[[:space:]]+$/, "", val)
            # Truncate long descriptions for display
            if (length(val) > 80) val = substr(val, 1, 77) "..."
            print val
            exit
        }
    ' "$file"
}

# ── Usage / help ─────────────────────────────────────────────────────────────

show_usage() {
    cat << 'EOF'
HSIO PCIe Validation Assistant — Agent Installer

Usage: install-agents.sh [OPTIONS]

OPTIONS:
    --user          Install to user-level location (default)
                      Agents  → ~/.copilot/agents/
                      Skills  → ~/.copilot/skills/

    --project       Install to project-level location (current repo)
                      Agents  → .github/copilot/agents/
                      Skills  → .github/copilot/skills/

    --help, -h      Show this help message

EXAMPLES:
    # Install to user location (default)
    ./install-agents.sh
    ./install-agents.sh --user

    # Install to current project repository
    ./install-agents.sh --project

ABOUT:
    Installs GitHub Copilot custom agents, skills, and testplan data for
    PCH HSIO PCIe validation work. The agent assists with test development,
    sequence creation, debugging, and regression analysis.

EOF

    # Dynamically list agents from the agents directory
    if [ -d "$AGENTS_SOURCE_DIR" ]; then
        echo "AGENTS INCLUDED:"
        for agent_file in "$AGENTS_SOURCE_DIR"/*.agent.md; do
            if [ -f "$agent_file" ]; then
                local agent_name
                agent_name=$(basename "$agent_file" .agent.md)
                local agent_desc
                agent_desc=$(extract_frontmatter "$agent_file" "description")
                if [ -n "$agent_desc" ]; then
                    printf "    - %-25s : %s\n" "$agent_name" "$agent_desc"
                else
                    printf "    - %-25s : (no description available)\n" "$agent_name"
                fi
            fi
        done
        echo ""
    fi
}

# ── Detect script location ──────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SOURCE_DIR="$SCRIPT_DIR/agents"
SKILLS_SOURCE_DIR="$SCRIPT_DIR/skills"
TESTPLAN_SOURCE_DIR="$SCRIPT_DIR/testplan"

# ── Default settings ────────────────────────────────────────────────────────

INSTALL_MODE="user"
AGENTS_TARGET_DIR=""
SKILLS_TARGET_DIR=""

# ── Parse command line arguments ─────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case $1 in
        --user)
            INSTALL_MODE="user"
            shift
            ;;
        --project)
            INSTALL_MODE="project"
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# ── Set target directories based on install mode ────────────────────────────

if [ "$INSTALL_MODE" = "user" ]; then
    AGENTS_TARGET_DIR="$HOME/.copilot/agents"
    SKILLS_TARGET_DIR="$HOME/.copilot/skills"
    print_info "Installing to user-level location"
elif [ "$INSTALL_MODE" = "project" ]; then
    AGENTS_TARGET_DIR=".github/copilot/agents"
    SKILLS_TARGET_DIR=".github/copilot/skills"
    print_info "Installing to project-level location (current repo)"
fi

print_info "  Agents → $AGENTS_TARGET_DIR"
print_info "  Skills → $SKILLS_TARGET_DIR"
echo ""

# ── Step 1: Create target directories ───────────────────────────────────────

print_info "Creating target directories..."
mkdir -p "$AGENTS_TARGET_DIR" "$SKILLS_TARGET_DIR"

# ── Step 2: Check source directories ────────────────────────────────────────

if [ ! -d "$AGENTS_SOURCE_DIR" ]; then
    print_error "Agents source directory not found: $AGENTS_SOURCE_DIR"
    print_error "Are you running this script from the repository root?"
    exit 1
fi

# ── Step 3: Copy agents ─────────────────────────────────────────────────────

print_info "Installing agents..."
AGENTS_MANIFEST="$AGENTS_TARGET_DIR/.fc-pcie-val-assist.agents.manifest"

# Clean up previously installed agents that no longer exist in source
if [ -f "$AGENTS_MANIFEST" ]; then
    REMOVED_COUNT=0
    while IFS= read -r agent_name; do
        [ -z "$agent_name" ] && continue
        installed_agent="$AGENTS_TARGET_DIR/$agent_name"
        source_agent="$AGENTS_SOURCE_DIR/$agent_name"
        if [ -f "$installed_agent" ] && [ ! -f "$source_agent" ]; then
            print_info "  🗑️  Removing deleted agent: $agent_name"
            rm -f "$installed_agent"
            REMOVED_COUNT=$((REMOVED_COUNT + 1))
        fi
    done < "$AGENTS_MANIFEST"
    if [ "$REMOVED_COUNT" -gt 0 ]; then
        print_info "Cleaned up $REMOVED_COUNT removed agent(s)"
    fi
fi

AGENT_COUNT=0
: > "$AGENTS_MANIFEST"

for agent_file in "$AGENTS_SOURCE_DIR"/*.agent.md; do
    if [ -f "$agent_file" ]; then
        agent_name=$(basename "$agent_file")
        cp "$agent_file" "$AGENTS_TARGET_DIR/$agent_name"
        echo "$agent_name" >> "$AGENTS_MANIFEST"
        print_info "  ✓ Installed: $agent_name"
        AGENT_COUNT=$((AGENT_COUNT + 1))
    fi
done

if [ "$AGENT_COUNT" -eq 0 ]; then
    print_warning "No .agent.md files found in $AGENTS_SOURCE_DIR"
fi

# ── Step 4: Copy skills ─────────────────────────────────────────────────────

SKILL_COUNT=0

if [ -d "$SKILLS_SOURCE_DIR" ]; then
    SKILL_DIRS=$(find "$SKILLS_SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)

    if [ "$SKILL_DIRS" -gt 0 ]; then
        print_info "Installing skills..."
        SKILLS_MANIFEST="$SKILLS_TARGET_DIR/.fc-pcie-val-assist.skills.manifest"

        # Clean up previously installed skills that no longer exist in source
        if [ -f "$SKILLS_MANIFEST" ]; then
            SKILLS_REMOVED_COUNT=0
            while IFS= read -r skill_name; do
                [ -z "$skill_name" ] && continue
                installed_skill="$SKILLS_TARGET_DIR/$skill_name"
                source_skill="$SKILLS_SOURCE_DIR/$skill_name"
                if [ -d "$installed_skill" ] && [ ! -d "$source_skill" ]; then
                    print_info "  🗑️  Removing deleted skill: $skill_name"
                    rm -rf "$installed_skill"
                    SKILLS_REMOVED_COUNT=$((SKILLS_REMOVED_COUNT + 1))
                fi
            done < "$SKILLS_MANIFEST"
            if [ "$SKILLS_REMOVED_COUNT" -gt 0 ]; then
                print_info "Cleaned up $SKILLS_REMOVED_COUNT removed skill(s)"
            fi
        fi

        : > "$SKILLS_MANIFEST"

        for skill_dir in "$SKILLS_SOURCE_DIR"/*/; do
            if [ -d "$skill_dir" ]; then
                skill_name=$(basename "$skill_dir")
                target_skill_dir="$SKILLS_TARGET_DIR/$skill_name"
                # Remove existing to avoid nested copy; suppress NFS silly-rename errors
                if [ -d "$target_skill_dir" ]; then
                    rm -rf "$target_skill_dir" 2>/dev/null || true
                fi
                cp -rTf "$skill_dir" "$target_skill_dir" 2>/dev/null || cp -rf "$skill_dir" "$target_skill_dir"
                echo "$skill_name" >> "$SKILLS_MANIFEST"
                print_info "  ✓ Installed skill: $skill_name"
                SKILL_COUNT=$((SKILL_COUNT + 1))
            fi
        done
    else
        print_info "No skill directories found in $SKILLS_SOURCE_DIR (skipping)"
    fi
else
    print_info "No skills directory found (skipping skill installation)"
fi

# ── Step 5: Copy testplan data ───────────────────────────────────────────────

TESTPLAN_INSTALLED=false
TESTPLAN_TARGET_DIR="$SKILLS_TARGET_DIR/pcie-testplan"

if [ -d "$TESTPLAN_SOURCE_DIR" ]; then
    TESTPLAN_FILE_COUNT=$(find "$TESTPLAN_SOURCE_DIR" -type f 2>/dev/null | wc -l)

    if [ "$TESTPLAN_FILE_COUNT" -gt 0 ]; then
        print_info "Installing testplan data ($TESTPLAN_FILE_COUNT file(s))..."
        mkdir -p "$TESTPLAN_TARGET_DIR"
        # Remove existing to get a clean copy
        if [ -d "$TESTPLAN_TARGET_DIR" ]; then
            rm -rf "$TESTPLAN_TARGET_DIR" 2>/dev/null || true
            mkdir -p "$TESTPLAN_TARGET_DIR"
        fi
        cp -rf "$TESTPLAN_SOURCE_DIR"/. "$TESTPLAN_TARGET_DIR"/
        print_info "  ✓ Installed testplan data to: $TESTPLAN_TARGET_DIR"
        TESTPLAN_INSTALLED=true
    else
        print_warning "Testplan directory is empty: $TESTPLAN_SOURCE_DIR"
    fi
else
    print_warning "Testplan directory not found: $TESTPLAN_SOURCE_DIR"
    print_info "  The agent needs testplan XML to generate sequences and regression reports."
    print_info "  Add testplan files to $SCRIPT_DIR/testplan/ and re-run this installer."
fi

# ── Step 6: Install MCP config (if present) ─────────────────────────────────

MCP_CONFIG_SOURCE="$SCRIPT_DIR/config/mcp-config.json"
MCP_CONFIG_INSTALLED=false

if [ -f "$MCP_CONFIG_SOURCE" ]; then
    MCP_CONFIG_TARGET="$HOME/.copilot/mcp-config.json"
    if [ -f "$MCP_CONFIG_TARGET" ]; then
        print_warning "MCP config already exists at: $MCP_CONFIG_TARGET"
        print_info "  Please merge $MCP_CONFIG_SOURCE manually if needed."
    else
        mkdir -p "$(dirname "$MCP_CONFIG_TARGET")"
        cp "$MCP_CONFIG_SOURCE" "$MCP_CONFIG_TARGET"
        print_info "  ✓ Installed MCP config to: $MCP_CONFIG_TARGET"
        MCP_CONFIG_INSTALLED=true
    fi
else
    print_info "No MCP config found at $MCP_CONFIG_SOURCE (skipping)"
    print_info "  Configure MCP servers manually if needed: ~/.copilot/mcp-config.json"
fi

# ── Environment checks ──────────────────────────────────────────────────────

echo ""
print_info "Running environment checks..."

# Check WORKAREA
if [ -z "$WORKAREA" ]; then
    print_warning "WORKAREA environment variable is not set"
    print_info "  Some agent features require WORKAREA. Set it with:"
    print_info "    export WORKAREA=/path/to/your/workarea"
    print_info "    # Or add it to your shell profile (~/.bashrc, ~/.tcshrc, etc.)"
else
    if [ -d "$WORKAREA" ]; then
        print_success "WORKAREA is set: $WORKAREA"
    else
        print_warning "WORKAREA is set but directory does not exist: $WORKAREA"
    fi
fi

# Check gh CLI
if command -v gh &>/dev/null; then
    print_success "gh CLI found: $(gh --version 2>/dev/null | head -1)"
else
    print_warning "gh CLI not found"
    print_info "  Some agent features require the GitHub CLI."
    print_info "  Install: https://cli.github.com/"
fi

# Check python3
if command -v python3 &>/dev/null; then
    print_success "python3 found: $(python3 --version 2>/dev/null)"
else
    print_warning "python3 not found"
    print_info "  Some agent features require Python 3."
fi

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_info "Installation complete!"
echo ""
print_info "  ✅ Installed $AGENT_COUNT agent(s) to: $AGENTS_TARGET_DIR"
if [ "$SKILL_COUNT" -gt 0 ]; then
    print_info "  ✅ Installed $SKILL_COUNT skill(s) to: $SKILLS_TARGET_DIR"
fi
if [ "$TESTPLAN_INSTALLED" = true ]; then
    print_info "  ✅ Installed testplan data to: $TESTPLAN_TARGET_DIR"
fi
if [ "$MCP_CONFIG_INSTALLED" = true ]; then
    print_info "  ✅ Installed MCP config to: ~/.copilot/mcp-config.json"
fi
echo ""

# List installed agents with names and descriptions
echo "  Available agents:"
for agent_file in "$AGENTS_TARGET_DIR"/*.agent.md; do
    if [ -f "$agent_file" ]; then
        agent_name=$(basename "$agent_file" .agent.md)
        agent_display_name=$(extract_frontmatter "$agent_file" "name")
        agent_desc=$(extract_frontmatter "$agent_file" "description")

        # Use filename if name not in frontmatter
        if [ -z "$agent_display_name" ]; then
            agent_display_name="$agent_name"
        fi

        if [ -n "$agent_desc" ]; then
            printf "    - %-25s : %s\n" "$agent_display_name" "$agent_desc"
        else
            printf "    - %-25s\n" "$agent_display_name"
        fi
    fi
done
echo ""

# List installed skills if any
if [ "$SKILL_COUNT" -gt 0 ]; then
    echo "  Available skills:"
    for skill_dir in "$SKILLS_TARGET_DIR"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            # Skip internal directories
            [[ "$skill_name" == pcie-testplan ]] && continue
            skill_file="$skill_dir/SKILL.md"
            if [ -f "$skill_file" ]; then
                skill_display_name=$(extract_frontmatter "$skill_file" "name")
                skill_desc=$(extract_frontmatter "$skill_file" "description")
                if [ -n "$skill_display_name" ] && [ -n "$skill_desc" ]; then
                    printf "    - %-25s : %s\n" "$skill_display_name" "$skill_desc"
                else
                    printf "    - %-25s\n" "$skill_name"
                fi
            else
                printf "    - %-25s\n" "$skill_name"
            fi
        fi
    done
    echo ""
fi

echo "  Usage:"
echo "    copilot --agent=hsio_val_assist"
echo ""

if [ "$INSTALL_MODE" = "project" ]; then
    print_info "Project-level agents and skills are available when working within this repository."
elif [ "$INSTALL_MODE" = "user" ]; then
    print_info "User-level agents and skills are available globally across all projects."
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 0
