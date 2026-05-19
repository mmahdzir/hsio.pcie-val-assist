# 🔌 HSIO PCIe Validation Assistant

> AI-powered PCIe validation assistant for PCH HSIO full-chip test development.
> Creates UVM tests, debugs failures, ports tests across models, generates regression reports.

[![GitHub Copilot CLI](https://img.shields.io/badge/GitHub%20Copilot-CLI%20Agent-blue?logo=github)](https://github.com/mmahdzir/hsio.pcie-val-assist)
[![Platform](https://img.shields.io/badge/platform-PCH%20HSIO%20PCIe-green)]()
[![License](https://img.shields.io/badge/license-Intel%20Internal-red)]()

---

## What It Does

- **Create UVM tests** from test scenario documents (`.txt`) — generates complete sequence (`.svh`) + test class + include updates
- **Debug simulation failures** — analyzes `postmortem.log`, `jestr.log`, trackers, waveforms
- **Port tests between models** — g5s3 x4 ↔ x8 ↔ SoC (`fc_rtl_with_upf`)
- **Generate regression reports** — weekly status of test ownership across all models
- **Register analysis** — looks up CRIF XML for access types (RW/RO/RW1C), generates correct macro calls
- **Build flow guidance** — `grdlbuild` compile/elab commands, touch file management, simv reuse

---

## Supported Models

| Model | Controller(s) | Build Target | Sim Time |
|-------|---------------|--------------|----------|
| g5s3 x4 | PXPC | `elab_s3_with_upf` | ~30–45 min |
| g5s3 x8 | PXPD | `elab_s3_with_upf` | ~60–80 min |
| SoC (fc_rtl) | PXPA / B / C / D | `elab_fc_rtl_with_upf` | ~20–25 h (TOM) |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User Prompt                               │
│  "Create a DPC test for upstream poisoned TLP trigger"       │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              hsio_val_assist Agent                            │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  │
│  │ Testplan  │  │ Register │  │ Build    │  │ Debug      │  │
│  │ Parser   │  │ Analyzer │  │ Manager  │  │ Analyzer   │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬───────┘  │
│       │             │             │              │           │
│       ▼             ▼             ▼              ▼           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  │
│  │ XML      │  │ CRIF     │  │grdlbuild │  │ jestr.log  │  │
│  │ Testplan │  │ XML      │  │ commands │  │ postmortem │  │
│  └──────────┘  └──────────┘  └──────────┘  └────────────┘  │
└─────────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    Output                                     │
│  • Generated .svh sequence + test class                      │
│  • Updated include files                                     │
│  • Compile + elab commands                                   │
│  • Test run command with correct plusargs                     │
│  • Debug analysis with root cause                            │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Setup

```bash
# 1. Clone the repo
git clone https://github.com/mmahdzir/hsio.pcie-val-assist.git
cd hsio.pcie-val-assist

# 2. Run the installer
./install-agents.sh

# 3. Start using
copilot --agent=hsio_val_assist
```

> **Note:** For `intel-sandbox`, the repo will be transferred to `intel-sandbox/hsio.pcie-val-assist` once permissions are granted.

---

## Usage Examples

### Example 1: Create a New Test

```
User: Create a DPC test for upstream poisoned TLP trigger based on test_scenario.txt
```

The agent will:
1. Parse the scenario document for test intent, stimulus, and expected behavior
2. Look up DPC/eDPC registers in CRIF XML (access types, reset values)
3. Generate a complete `.svh` sequence with correct register macros
4. Generate a matching test class
5. Update include files to reference the new sequence
6. Provide `grdlbuild` compile and `simv` run commands with correct plusargs

### Example 2: Debug a Failure

```
User: Debug pch_pcie_dpc_edpc_up_tlp_trig — it's hanging after DPC trigger
```

The agent will:
1. Check `postmortem.log` for timeout or UVM error signatures
2. Analyze `jestr.log` for the last completed phase and stuck point
3. Identify the BFM blocked on a disabled link (DPC disables the link on trigger)
4. Suggest a `fork`-`join_any` timeout fix to avoid the hang
5. Provide the corrected code snippet and recompile instructions

### Example 3: Port Test to SoC

```
User: Port pch_pcie_dpc_edpc tests from g5s3 x4 to SoC model
```

The agent will:
1. Copy sequences from x4 directory to the SoC test area
2. Apply SoC-specific fixes (`PIBAItems` → `GetTxs`, fork timeout patterns)
3. Update controller references from PXPC to the appropriate SoC controller
4. Compile with `elab_fc_rtl_with_upf` build target
5. Generate run command with TOM-compatible plusargs

### Example 4: Generate Regression Report

```
User: Generate ww18 regression report
```

The agent will:
1. Scan regression directories for the target workweek
2. Match tests to models (x4, x8, SoC)
3. Check pass/fail status for each test
4. Generate a structured markdown report with ownership, status, and notes
5. example https://github.com/mmahdzir/hsio.pcie-val-assist/blob/main/examples/ww17_regression_report.html

---

## Repository Structure

```
hsio.pcie-val-assist/
├── README.md                                    # This file
├── install-agents.sh                            # One-click installer (auto-generates per-user ownership JSON)
├── update_agent.sh                              # Feedback / contribution / sync script
├── agents/
│   └── hsio_val_assist.agent.md                 # Main agent definition
├── skills/
│   └── grdlbuild/
│       └── SKILL.md                             # grdlbuild build system reference
├── testplan/
│   ├── TTLPCDH.TTL_PCD_H_PCIe_Testplan.xml     # Shared PCIe testplan (all owners)
│   └── gen_ownership.py                         # Script: generate <user>_tests.json from XML
├── examples/
│   ├── ww17_mmahdzir_regression_rpt.md          # Example regression report
│   └── ww18_mmahdzir_regression_rpt.md          # Example regression report
├── .github/
│   ├── ISSUE_TEMPLATE/agent_feedback.md         # Structured feedback template
│   └── PULL_REQUEST_TEMPLATE/                   # Knowledge contribution PR template
└── config/
    └── README.md                                # MCP configuration guide
```

> **Note:** `<username>_tests.json` is generated **automatically at install time** by
> `install-agents.sh` for the installing user. It is not committed to the repo because
> it is user-specific data.

---

## Skills Included

| Skill | Description |
|-------|-------------|
| `grdlbuild` | Intel's build system — compile, elab, touch files, dependency chains |

---

## Requirements

- **GitHub Copilot CLI** installed and authenticated
- **PCH workarea** accessible (`WORKAREA` environment variable set)
- **Python 3.6+** for testplan XML parsing
- **Access to Intel NFS paths** for regression data and CRIF XML sources

---

## Contributing Back — Improve the Agent

Every debug session is a learning opportunity. Use `update_agent.sh` to contribute findings back to the shared agent so **everyone benefits**.

```bash
# Report a bug or incorrect agent behavior
./update_agent.sh --feedback

# Submit a new knowledge snippet (debug pattern, build fix, register trick)
./update_agent.sh --learn

# Pull the latest agent after a contribution was merged
./update_agent.sh --sync

# See open issues and pending PRs
./update_agent.sh --status
```

### Contribution Flow

```
Your debug session discovers something new
          │
          ▼
  update_agent.sh --feedback     →  GitHub Issue (quick report)
  update_agent.sh --learn        →  GitHub PR (structured snippet)
          │
          ▼
  Maintainer reviews + merges
          │
          ▼
  All users: ./update_agent.sh --sync  →  get updated agent
```

> **Tip:** Run `--sync` at the start of each work week to stay current.

---

## How to Extend

### Adding New Test Patterns

Add new test scenario documents to your workarea and reference them when prompting the agent. The agent learns from the structure of existing sequences in the repository to generate consistent output.

### Adding New Skills

Create a new directory under `skills/` with a `SKILL.md` file describing the skill's knowledge base. Run `./install-agents.sh` again to register the updated configuration.

### Contributing Back

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-improvement`)
3. Commit your changes with clear descriptions
4. Open a pull request against `main`

---

## Transferring to intel-sandbox

Once permissions are granted, transfer the repository to the `intel-sandbox` organization:

**Via GitHub UI:**
1. Go to **Settings** → **General** → **Danger Zone**
2. Click **Transfer ownership**
3. Enter `intel-sandbox` as the new owner
4. Confirm the transfer

**Via CLI:**
```bash
gh api repos/mmahdzir/hsio.pcie-val-assist/transfer -f new_owner=intel-sandbox
```

After transfer, update your local remote:
```bash
git remote set-url origin https://github.com/intel-sandbox/hsio.pcie-val-assist.git
```

---

## License

```
Intel Internal Use Only
```

## 📊 Workflow Diagrams

Visual workflow structure diagrams for all objectives are available in [`docs/hsio_val_agent_diagrams.html`](docs/hsio_val_agent_diagrams.html).

Open in a browser for interactive, tabbed views of:
- **Create New Test** — full swimlane from scenario to validated test
- **Debug a Failure** — structured log analysis and root cause workflow
- **Generate Regression Report** — all-owner report generation with charts

