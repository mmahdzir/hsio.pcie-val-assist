#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# update_agent.sh — Contribute feedback and learnings back to the shared agent
#
# Usage:
#   ./update_agent.sh --feedback          # Report a bug or suggestion (GitHub Issue)
#   ./update_agent.sh --learn             # Submit a knowledge snippet (GitHub PR)
#   ./update_agent.sh --sync              # Pull latest agent from GitHub to ~/.copilot
#   ./update_agent.sh --status            # Show open feedback issues in the repo
#   ./update_agent.sh --help              # Show this help
#
# Requires: gh CLI (https://cli.github.com/), authenticated with your GitHub account
# ─────────────────────────────────────────────────────────────────────────────

set -e

REPO="mmahdzir/hsio.pcie-val-assist"
AGENT_FILE="agents/hsio_val_assist.agent.md"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
success() { echo -e "${CYAN}[OK]${NC} $1"; }
header()  { echo -e "\n${BOLD}$1${NC}"; echo "$(echo "$1" | tr '[:print:]' '─')"; }

# ── Dependency check ─────────────────────────────────────────────────────────
check_deps() {
    if ! command -v gh &>/dev/null; then
        echo -e "${RED}[ERROR]${NC} GitHub CLI (gh) is required."
        echo "  Install: https://cli.github.com/"
        exit 1
    fi
    if ! gh auth status &>/dev/null; then
        echo -e "${RED}[ERROR]${NC} gh is not authenticated."
        echo "  Run: gh auth login"
        exit 1
    fi
}

# ── Prompt helper (read with default) ────────────────────────────────────────
prompt() {
    local var_name="$1"
    local prompt_text="$2"
    local default="$3"

    if [ -n "$default" ]; then
        echo -ne "${CYAN}?${NC} ${prompt_text} [${default}]: "
    else
        echo -ne "${CYAN}?${NC} ${prompt_text}: "
    fi
    read -r input
    if [ -z "$input" ] && [ -n "$default" ]; then
        eval "$var_name='$default'"
    else
        eval "$var_name='$input'"
    fi
}

# ── Multi-line editor helper ─────────────────────────────────────────────────
collect_multiline() {
    local prompt_text="$1"
    echo -e "${CYAN}?${NC} ${prompt_text}"
    echo "  (Type your text. Enter a line with just '.' to finish)"
    local result=""
    while IFS= read -r line; do
        [ "$line" = "." ] && break
        if [ -z "$result" ]; then
            result="$line"
        else
            result="$result
$line"
        fi
    done
    echo "$result"
}

# ─────────────────────────────────────────────────────────────────────────────
# MODE: --feedback  →  Create a GitHub Issue
# ─────────────────────────────────────────────────────────────────────────────
mode_feedback() {
    header "Submit Agent Feedback"
    echo "This will create a GitHub Issue in ${BOLD}$REPO${NC} to report a problem"
    echo "or suggest an improvement to the hsio_val_assist agent."
    echo ""

    # Feedback type
    echo -e "${CYAN}?${NC} Feedback type:"
    echo "  1) Bug — agent gave wrong/incomplete information"
    echo "  2) Missing knowledge — agent doesn't know something it should"
    echo "  3) New test pattern — discovered a pattern worth documenting"
    echo "  4) Build/compile issue — wrong command or missing step"
    echo "  5) Regression report issue — wrong test matching or output"
    echo "  6) Other improvement"
    echo -ne "  Choose [1-6]: "
    read -r fb_type_num
    case "$fb_type_num" in
        1) fb_type="bug" ;          fb_label="agent-bug" ;;
        2) fb_type="missing-knowledge" ; fb_label="knowledge-gap" ;;
        3) fb_type="new-pattern" ;  fb_label="knowledge-update" ;;
        4) fb_type="build-issue" ;  fb_label="build-workflow" ;;
        5) fb_type="regression-report" ; fb_label="regression-report" ;;
        *) fb_type="improvement" ;  fb_label="enhancement" ;;
    esac

    # Context
    echo ""
    prompt "model"    "Model (g5s3-x4 / g5s3-x8 / SoC / all)" "all"
    prompt "ww"       "Work week (e.g. 26ww18a, or leave blank)" ""
    prompt "testname" "Test name (if relevant, or leave blank)" ""

    # Title
    echo ""
    prompt "issue_title" "Short title for this feedback" ""
    if [ -z "$issue_title" ]; then
        warn "Title is required."
        exit 1
    fi

    # Description
    echo ""
    description=$(collect_multiline "Describe what happened or what you expected:")

    # Proposed fix
    echo ""
    proposed=$(collect_multiline "Proposed fix or what the agent SHOULD say/do (optional — press '.' to skip):")

    # Build the issue body
    CURRENT_USER="$(whoami)"
    TIMESTAMP="$(date '+%Y-%m-%d %H:%M')"

    body="## Feedback Type
\`${fb_type}\`

## Description
${description}

## Context
| Field | Value |
|-------|-------|
| Reporter | \`${CURRENT_USER}\` |
| Model | ${model} |
| Work Week | ${ww:-N/A} |
| Test Name | ${testname:-N/A} |
| Submitted | ${TIMESTAMP} |

## Proposed Fix / Addition
${proposed:-_No proposal provided — please investigate and suggest improvement._}

---
*Submitted via \`update_agent.sh --feedback\` from \`$(hostname)\`*"

    echo ""
    info "Creating GitHub Issue in $REPO..."
    issue_url=$(gh issue create \
        --repo "$REPO" \
        --title "[feedback] $issue_title" \
        --body "$body" \
        --label "$fb_label" 2>/dev/null || \
      gh issue create \
        --repo "$REPO" \
        --title "[feedback] $issue_title" \
        --body "$body")

    success "Issue created: $issue_url"
    echo ""
    info "The repo maintainer will review and incorporate the feedback."
    info "You can track it at: $issue_url"
}

# ─────────────────────────────────────────────────────────────────────────────
# MODE: --learn  →  Submit a knowledge snippet as a GitHub PR
# ─────────────────────────────────────────────────────────────────────────────
mode_learn() {
    header "Submit Knowledge Contribution (PR)"
    echo "This will propose an addition to the agent's knowledge base."
    echo "A branch + Pull Request will be created in ${BOLD}$REPO${NC}."
    echo ""

    CURRENT_USER="$(whoami)"
    TIMESTAMP="$(date '+%Y%m%d_%H%M')"
    BRANCH="learn/${CURRENT_USER}_${TIMESTAMP}"

    # Section to update
    echo -e "${CYAN}?${NC} Which section does this belong to?"
    echo "  1) DPC / eDPC knowledge"
    echo "  2) Build workflow (grdlbuild / elab)"
    echo "  3) SoC TOM boot flow"
    echo "  4) Regression report workflow"
    echo "  5) Debugging patterns (log analysis, grep patterns)"
    echo "  6) Register access / CRIF XML"
    echo "  7) Test architecture / UVM patterns"
    echo "  8) New section"
    echo -ne "  Choose [1-8]: "
    read -r section_num
    case "$section_num" in
        1) section="DPC (Downstream Port Containment)" ;;
        2) section="Build Commands / grdlbuild workflow" ;;
        3) section="SoC Full-Chip Model — FC_RTL_WITH_UPF" ;;
        4) section="Regression Report Generation Workflow" ;;
        5) section="Debugging Test Failures" ;;
        6) section="Register Access Macros / CRIF XML" ;;
        7) section="Test Architecture (UVM)" ;;
        *) prompt "section" "Section name" "New Knowledge"; ;;
    esac

    # Snippet title
    prompt "snippet_title" "Snippet heading (e.g. 'AERPR sideband write pattern')" ""
    if [ -z "$snippet_title" ]; then
        warn "Snippet title is required."
        exit 1
    fi

    # The actual content
    echo ""
    echo -e "${CYAN}?${NC} Paste the knowledge snippet (Markdown supported)."
    echo "  Include context, code blocks, and examples."
    echo "  Enter '.' on a line by itself to finish."
    snippet_content=$(collect_multiline "")

    if [ -z "$snippet_content" ]; then
        warn "Snippet content is required."
        exit 1
    fi

    # Clone / update the repo
    WORK_DIR="$(mktemp -d)"
    trap "rm -rf $WORK_DIR" EXIT

    info "Cloning $REPO for PR creation..."
    gh repo clone "$REPO" "$WORK_DIR" -- --quiet 2>/dev/null || {
        warn "Clone failed — trying without quiet flag"
        gh repo clone "$REPO" "$WORK_DIR"
    }

    cd "$WORK_DIR"
    git checkout -b "$BRANCH"

    # Append the snippet to the agent file
    AGENT_PATH="$WORK_DIR/$AGENT_FILE"
    {
        echo ""
        echo "### ${snippet_title}"
        echo "<!-- contributed by: ${CURRENT_USER} | $(date '+%Y-%m-%d') -->"
        echo "${snippet_content}"
    } >> "$AGENT_PATH"

    # Commit and push
    git add "$AGENT_FILE"
    git config user.email "${CURRENT_USER}@intel.com" 2>/dev/null || true
    git config user.name "$CURRENT_USER" 2>/dev/null || true
    git commit -m "learn: add '${snippet_title}' to ${section}

Contributed by: ${CURRENT_USER}
Section: ${section}
Date: $(date '+%Y-%m-%d')"

    info "Pushing branch $BRANCH..."
    git push origin "$BRANCH"

    # Create the PR
    PR_BODY="## Knowledge Contribution

### Section
${section}

### Snippet Title
${snippet_title}

### Added Content
\`\`\`
$(head -20 <<< "$snippet_content")
\`\`\`
$([ "$(wc -l <<< "$snippet_content")" -gt 20 ] && echo "_...truncated — see full diff_")

### Contributor
\`${CURRENT_USER}\` — $(date '+%Y-%m-%d')

---
*Submitted via \`update_agent.sh --learn\`*"

    pr_url=$(gh pr create \
        --repo "$REPO" \
        --title "[learn] ${snippet_title}" \
        --body "$PR_BODY" \
        --label "knowledge-update" \
        --base main \
        --head "$BRANCH" 2>/dev/null || \
      gh pr create \
        --repo "$REPO" \
        --title "[learn] ${snippet_title}" \
        --body "$PR_BODY" \
        --base main \
        --head "$BRANCH")

    cd - >/dev/null
    success "PR created: $pr_url"
    echo ""
    info "The repo maintainer will review, edit if needed, and merge."
    info "Once merged, run './update_agent.sh --sync' to get the updated agent."
}

# ─────────────────────────────────────────────────────────────────────────────
# MODE: --sync  →  Pull latest agent from GitHub to ~/.copilot/agents/
# ─────────────────────────────────────────────────────────────────────────────
mode_sync() {
    header "Sync Latest Agent from GitHub"

    AGENTS_DIR="$HOME/.copilot/agents"
    SKILLS_DIR="$HOME/.copilot/skills"

    info "Fetching latest agent from $REPO..."

    # Fetch agent file directly via gh api
    mkdir -p "$AGENTS_DIR"
    gh api "repos/${REPO}/contents/${AGENT_FILE}" \
        --jq '.content' | base64 -d > "$AGENTS_DIR/hsio_val_assist.agent.md"

    success "Agent updated: $AGENTS_DIR/hsio_val_assist.agent.md"

    # Also sync grdlbuild skill
    SKILL_FILE="skills/grdlbuild/SKILL.md"
    mkdir -p "$SKILLS_DIR/grdlbuild"
    gh api "repos/${REPO}/contents/${SKILL_FILE}" \
        --jq '.content' | base64 -d > "$SKILLS_DIR/grdlbuild/SKILL.md" 2>/dev/null && \
        success "Skill updated: $SKILLS_DIR/grdlbuild/SKILL.md" || \
        warn "Could not sync grdlbuild skill (non-fatal)"

    # Show what changed
    echo ""
    info "Latest commit in repo:"
    gh api "repos/${REPO}/commits/main" \
        --jq '"  \(.sha[0:8]) \(.commit.author.date[0:10]) — \(.commit.message | split("\n")[0])"' 2>/dev/null || true

    echo ""
    success "Sync complete. Restart Copilot CLI to pick up the latest agent."
}

# ─────────────────────────────────────────────────────────────────────────────
# MODE: --status  →  Show open feedback issues and pending PRs
# ─────────────────────────────────────────────────────────────────────────────
mode_status() {
    header "Agent Feedback Status — $REPO"

    echo ""
    echo -e "${BOLD}Open Issues (feedback):${NC}"
    gh issue list \
        --repo "$REPO" \
        --state open \
        --limit 20 \
        --json number,title,labels,createdAt,author \
        --jq '.[] | "  #\(.number) [\(.labels | map(.name) | join(","))] \(.title) — @\(.author.login) \(.createdAt[0:10])"' \
        2>/dev/null || echo "  (none or gh API unavailable)"

    echo ""
    echo -e "${BOLD}Open Pull Requests (knowledge contributions):${NC}"
    gh pr list \
        --repo "$REPO" \
        --state open \
        --limit 10 \
        --json number,title,headRefName,author,createdAt \
        --jq '.[] | "  PR #\(.number) \(.title) — @\(.author.login) \(.createdAt[0:10])"' \
        2>/dev/null || echo "  (none or gh API unavailable)"

    echo ""
    echo -e "${BOLD}Recent merges (last 5):${NC}"
    gh pr list \
        --repo "$REPO" \
        --state merged \
        --limit 5 \
        --json number,title,mergedAt,author \
        --jq '.[] | "  ✅ PR #\(.number) \(.title) — merged \(.mergedAt[0:10])"' \
        2>/dev/null || echo "  (none or gh API unavailable)"

    echo ""
    info "View all at: https://github.com/$REPO/issues"
}

# ─────────────────────────────────────────────────────────────────────────────
# Usage / help
# ─────────────────────────────────────────────────────────────────────────────
show_help() {
    cat << 'EOF'

update_agent.sh — Contribute feedback and learnings to the hsio_val_assist agent

USAGE:
  ./update_agent.sh [mode] [options]

MODES:
  --feedback, -f      Report a bug or suggest an improvement (creates GitHub Issue)
  --learn,    -l      Submit a new knowledge snippet (creates Pull Request)
  --sync,     -s      Pull latest agent + skills from GitHub to ~/.copilot/
  --status            Show open issues and pending PRs in the repo
  --help,     -h      Show this help

EXAMPLES:
  # Report that the agent gave wrong register access info
  ./update_agent.sh --feedback

  # Submit a new debug pattern you discovered
  ./update_agent.sh --learn

  # Get the latest version of the agent after a PR was merged
  ./update_agent.sh --sync

  # See what's pending in the repo
  ./update_agent.sh --status

REPO: https://github.com/mmahdzir/hsio.pcie-val-assist

EOF
}

# ─────────────────────────────────────────────────────────────────────────────
# Entry point
# ─────────────────────────────────────────────────────────────────────────────
case "${1:-}" in
    --feedback|-f)
        check_deps
        mode_feedback
        ;;
    --learn|-l)
        check_deps
        mode_learn
        ;;
    --sync|-s)
        check_deps
        mode_sync
        ;;
    --status)
        check_deps
        mode_status
        ;;
    --help|-h|"")
        show_help
        ;;
    *)
        echo -e "${RED}[ERROR]${NC} Unknown option: $1"
        show_help
        exit 1
        ;;
esac
