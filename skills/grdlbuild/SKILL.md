---
name: grdlbuild
description: Reference guide for Intel's grdlbuild build system (PESG Cheetah FE wrapper on Gradle). This skill should be used when users ask about grdlbuild commands, CLI options, build.gradle.kts syntax, task types (BuildTask, NbFileTask, ProjectConfigTask, ConditionalTask), gradle.properties configuration, resources.ini setup, Netbatch scheduling, labels, run modes, DUT filtering, conditionals, gcache, or any grdlbuild-related workflow. Triggers include grdlbuild, gradle, build task, NbFileTask, build recipe, grdlbuild command, grdlbuild syntax.
---

# grdlbuild — Commands & Syntax Reference

## Overview

grdlbuild is Intel PESG's build system wrapper on top of Gradle, used for FE build flows across Intel design projects. It provides task-based build orchestration with local and Netbatch execution, dependency management, DUT/label/runMode filtering, conditionals, caching, and Gatekeeper integration.

## Command Syntax

```
grdlbuild -p <project_or_dir> <options> <scope> <-P{property}>
```

- `<options>`: CLI flags like `-nb`, `-dut`, `-label`, `-run_modes`, etc.
- `<scope>`: `all`, specific project(s), or task(s) to run
- `-P{property}=<value>`: set or override properties from gradle.properties

## Quick Reference — CLI Flags

| Flag | Description |
|------|-------------|
| `-h` | Print help |
| `-p <dir>` | Specify project directory |
| `all` | Run all configured tasks |
| `-nb` | Run tasks in Netbatch |
| `-local` | Run tasks locally (default) |
| `-nb_gen` | Generate NB task file without executing |
| `-block` | Wait for tasks to finish |
| `-noblock` | Exit after loading task file to feeder |
| `-dut <dut>` | Filter by DUT |
| `-run_modes <mode>` | Filter by run mode (turnin, release, etc.) |
| `-label <label>[=val]` | Filter by label |
| `-xlabel <label>` | Exclude tasks with label |
| `-show_tasks` | Print task graph without running |
| `-show_tasks_deps` | Print tasks + dependencies without running |
| `-show_tasks_full` | Print tasks with full descriptions |
| `-print_task_tree` | Tree view of dependency relations |
| `-ignore_deps` | Run only specified tasks, skip dependencies |
| `-run_deps` | Run only dependencies, not the task itself |
| `-start_from_task` | Run from specified task onward |
| `--continue` | Continue after task failure |
| `-conditionalsOn` | Enable conditionals |
| `-nb_type <section>` | Select NB resource section |
| `-Pwcx=<regex>` | Exclude tasks by regex |
| `-Pwcp=<regex>` | Include tasks by regex |
| `-Padd_args*` | Append args to a task's command line |

## Task Types

### BuildTask
Basic building block. Defines a command to execute with dependencies.

```kotlin
task<BuildTask>("gen_filelist") {
    commandLine("cd ${WORKAREA} && make gen_filelist DUT=d2d")
    dependsOn(":codegen:all_codegen")
    useNBResource("NB_1G_1C_SLES15")
    gating(true)
    runModes("turnin", "release")
    label("compile")
    dut("someDUT")
    timeout("30m")
    environment("KEY", "VALUE")
    environmentFile("/path/to/source.sh")
    taskOwner("username")
    postRun("cleanup_cmd")
    cleanupCmd("rm -rf temp/")
    gcache("true", "configName")
    strace()  // v23.42+
}
```

**Key options:** `commandLine`, `runDir`, `useNBResource`, `dependsOn`, `dependsOnComplete`, `environment`, `environmentFile`, `timeout`, `label`, `dut`, `runModes`, `gating`, `taskOwner`, `hof` (label), `attempts`, `retryExitCode`, `retryExpression`, `addNBArgs`, `postRun`, `cleanupCmd`, `gcache`, `strace`, `disablePrediction`, `predictionCoresLimit`, `predictionMemoryLimit`, `predictionDiskLimit`.

### NbFileTask
For tools that generate their own NB task files (e.g., simregress).

```kotlin
task<NbFileTask>("level0") {
    commandLine("simregress -l core_gating.list -dut core -net -no_run")
    nbTaskFile("${WORKAREA}/regression/core/core_gating.list.latest/core_gating.nbtask_conf")
    passRate = 90
    dependsOn(":sim:vcssim")
    useNBResource("regress")
    runModes("turnin", "release")
}
```

**Additional options:** `passRate` (default 100), `nbTaskFile`, `triggeredBy`.

### ProjectConfigTask
Defines inherited configuration for all tasks in a subproject.

```kotlin
task<ProjectConfigTask>("projConfig") {
    dut("$dut")
    environment("MODEL_ROOT", WORKAREA)
    environmentFile("$WORKAREA/envs/env.sh")
    label("my_label")
    runModes("turnin")
    runDir("$WORKAREA/regress/")
    taskOwner("bob")
    timeout("1H")
}
```

**Supported options:** `environment`, `environmentFile`, `taskOwner`, `label`, `runDir`, `nbArgs`, `timeout`. Environment and label are accumulative; others can be overridden at task level.

### ConditionalTask
Skip tasks based on script exit codes (exit 0 = condition met = skip).

```kotlin
task<ConditionalTask>("conditionals") {
    dutConditional("/path/to/script", dut = "exe")
    labelConditional("/usr/bin/echo true", "lint")
    labelConditional("/path/to/check", "fev_core_type=rtl2rtl")
}
```

Requires `conditionalsOn=true` in gradle.properties or `-conditionalsOn` CLI flag.

## File Structure

```
$WORKAREA/cfg/grdlbuild/
├── gradle.properties         # Output dir, scheduling, NB settings
├── settings.gradle.kts       # Include subprojects
├── resources.ini             # Netbatch pool/qslot/class definitions
├── build.gradle.kts          # Top-level task definitions
└── <project>/                # Subproject directories
    └── build.gradle.kts      # Project-specific tasks
```

## Dependency Syntax

- `:codegen:all_codegen` — task in another subproject
- `my_task` — task in current project (no `:` prefix)
- `:gen_filelist` — task at top-level project
- Use `&&` (not `;`) to chain commands in `commandLine()` for correct exit status

## Common Examples

```bash
# List all targets
grdlbuild -p cfg/grdlbuild

# Run all tasks locally
grdlbuild -p cfg/grdlbuild all

# Run all tasks in Netbatch
grdlbuild -p cfg/grdlbuild all -nb

# Run specific DUT
grdlbuild -p cfg/grdlbuild all -dut pchlp

# Run specific run mode
grdlbuild -p cfg/grdlbuild all -run_modes turnin

# Run specific task
grdlbuild -p cfg/grdlbuild :sim:vcssim

# Preview without running
grdlbuild -p cfg/grdlbuild all -show_tasks

# Override a property
grdlbuild -p cfg/grdlbuild all -Pdut=pchlp -nb
```

## Resources

For the full commands reference, consult `references/commands_reference.md` in this skill. Key topics covered there include gradle.properties options, resources.ini format, NB prediction, gcache caching, delegates, dynamic multi-DUT configuration, and delayed task submission (triggeredBy).

### Wiki References

- [grdlbuild Commands Reference (Cheetah)](https://wiki.ith.intel.com/spaces/cheetah/pages/1942362511/grdlbuild+-+Commands+Reference)
- [Getting Started with grdlbuild](https://wiki.ith.intel.com/spaces/cheetah/pages/2977311906/Getting+Started+with+grdlbuild)
- [PCH grdlbuild](https://wiki.ith.intel.com/spaces/pch/pages/4378112794/grdlbuild)
- [iflow to grdlbuild Migration (PCH)](https://wiki.ith.intel.com/spaces/pch/pages/4378112801/iflow+to+grdlbuild+Migration+Process)

---

## PCH/PCD Build Flow — Task Dependency Chain

The PCH DUT build (`-Pdut=pchlp`) flows through these key stages in order.
Each task depends on previous tasks as shown. The dependency definitions live
in `cfg/grdlbuild/{basic,codegen,common}/build.gradle.kts`.

### Build Flow Graph (Critical Path)

```
socgen (basic)
  └─► repo_prep (basic) [depends: socgen]
        └─► dfxtapgen, fusegen, gen_tieoff_conn (codegen) [depends: basic]
              └─► fusemerge [depends: fusegen]
              └─► build_defacto_pre [depends: dfxtapgen, fusegen, gen_tieoff_conn]
                    └─► build_defacto [depends: build_defacto_pre]
                          └─► build_defacto_post [depends: build_defacto]
                                └─► partition_seal [depends: build_defacto_post]
                                      └─► pch_gen_filelist_pre_ub [depends: partition_seal]
                                            └─► ultibuild [depends: pch_gen_filelist_pre_ub]
                                                  └─► pch_gen_filelist [depends: partition_seal]  (parallel)
                                                        └─► vcssim_compile (common) [depends: many codegen tasks]
                                                              └─► elab_fc_rtl (common) [depends: vcssim_compile, validate_platform_cfg]
```

### Sub-steps within build_defacto

The `build_defacto` task runs Cheetah-RTL defacto internally with these phases:
1. **genSpec** — Reads CSV/inst_config/partition files, validates (INST_CHK, PART_CHK)
2. **assembleRTL** — Builds the RTL hierarchy, resolves connections, detects missing instances
3. **DRC** — Design Rule Checks on the assembled design

### Touch File Mechanism

Each task creates a touch file on success at:
```
output/grdlbuild/.flowMgr/<dut>.<taskname>.touch
```
- If touch file exists, the task is SKIPPED (considered already done)
- Delete touch file to force re-run: `rm -f output/grdlbuild/.flowMgr/pchlp.<taskname>.touch`
- Set `GRDL_NO_TOUCH` env var to ignore ALL touch files

### Common Commands for PCH Development

```bash
# Full build from scratch to elab
grdlbuild elab_fc_rtl -Pdut=pchlp

# Run everything up to codegen (includes socgen through build_defacto_post)
grdlbuild codegen -Pdut=pchlp

# Run specific stage and its dependencies
grdlbuild build_defacto_post -Pdut=pchlp

# Skip repo_prep (preserve local changes during iteration)
grdlbuild build_defacto_post -Pdut=pchlp -x repo_prep

# Force re-run from socgen through build_defacto
rm -f output/grdlbuild/.flowMgr/pchlp.socgen.touch
rm -f output/grdlbuild/.flowMgr/pchlp.build_defacto*.touch
grdlbuild build_defacto_post -Pdut=pchlp -x repo_prep

# Run only elab, skip all dependencies (if codegen already done)
grdlbuild elab_fc_rtl -Pdut=pchlp -ignore_deps

# Run from a specific task onward
setenv GRDL_NO_TOUCH
grdlbuild -Pdut=pchlp -start_from_task :common:vcssim_compile -end_at_task :common:elab_fc_rtl

# Show task dependency tree without running
grdlbuild -Pdut=pchlp -show_tasks_deps
```

### Iterative Build Tips for IP Removal / Template Changes

1. **Always use `-x repo_prep`** during iterative builds to prevent repo_prep
   from overwriting your local changes.

2. **CRITICAL: csv*.template changes REQUIRE socgen re-run.** Modifying any file
   under `integration/csv/templates/` (or `subsystems/*/templates/`) will NOT
   take effect until socgen regenerates `templates_output/`. Always clean the
   socgen touch file AND templates_output before rebuilding:
   ```bash
   rm -f output/grdlbuild/.flowMgr/pchlp.socgen.touch
   rm -rf integration/csv/templates_output/pchlp/
   rm -rf subsystems/sbr/templates_output/pchlp/
   ```

3. **Clean defacto generated outputs** before rebuilding after defacto-related changes:
   ```bash
   rm -rf output/pchlp/defacto/                       # defacto generated files
   ```

4. **Force socgen re-run** when changing socgen/pchlp.yml or any templates:
   ```bash
   rm -f output/grdlbuild/.flowMgr/pchlp.socgen.touch
   ```

5. **One-liner for full clean rebuild** (socgen through build_defacto_post):
   ```bash
   rm -f output/grdlbuild/.flowMgr/pchlp.socgen.touch output/grdlbuild/.flowMgr/pchlp.build_defacto*.touch && \
   rm -rf integration/csv/templates_output/pchlp/ output/pchlp/defacto/ subsystems/sbr/templates_output/pchlp/ && \
   grdlbuild build_defacto_post -Pdut=pchlp -x repo_prep
   ```

5. **Check build logs** for specific failures:
   ```bash
   # Main build log
   cat output/grdlbuild/logs/codegen.build_defacto.log
   # assembleRTL specific log
   cat output/pchlp/defacto/trial/assembleRTL.log
   # genSpec specific log
   grep -E "FAIL|Error" output/pchlp/defacto/trial/genSpec.log
   ```

6. **Key error patterns in assembleRTL**:
   - `Cannot find instance "/xxx"` — Instance referenced in CONNECTION but not defined (partition removed or INSTANCE guarded)
   - `INST_CHK_04` — Instance defined but its partition doesn't exist
   - `PART_CHK` — Partition hierarchy issues

### Gating Tasks

Tasks marked `gating(true)` will stop the build if they fail. Key gating tasks:
- `socgen` — Template rendering
- `repo_prep` — Repository preparation
- `build_defacto_pre`, `build_defacto`, `build_defacto_post` — Defacto flow
- `vcssim_compile` — VCS compilation
- `elab_fc_rtl` — RTL elaboration

---

## ⚠️ Critical Build Rules for IP Removal

These rules were distilled from a 25-checkpoint PXPA IP removal session. Violating
any of them leads to confusing downstream failures that waste hours of debug time.

### Rule 1: Template Changes ALWAYS Require socgen First

Any change to `*.template` files (CSV templates, RDL templates, JSON templates)
requires running `socgen` before ANY downstream task. `socgen` regenerates
`templates_output/` directories. Without this, downstream tasks use stale files.

```bash
# After template change:
rm -f output/grdlbuild/.flowMgr/pchlp.socgen.touch
rm -rf integration/csv/templates_output/pchlp/
grdlbuild socgen -Pdut=pchlp -x repo_prep
```

### Rule 2: Prefer `grdlbuild codegen` Over Individual Tasks

Running the full codegen chain ensures proper dependency ordering:
```bash
grdlbuild codegen -Pdut=pchlp -x repo_prep
```
This runs: socgen → fusegen → gen_tieoff_conn → build_defacto_pre → build_defacto →
build_defacto_post → partition_seal → dfx_filechanges_check → fusegen_post →
hier_define_generator → osxml_int_check → pch_gen_filelist_pre_ub → ultibuild →
pch_gen_filelist → vcssim_compile

Running individual tasks with `-ignore_deps` skips critical prerequisites and can
cause confusing failures.

### Rule 3: NEVER Delete `output/<dut>/defacto/`

This directory contains intermediate artifacts (`dfxmasterlist`) created by
`config_pchlp_rtl_build_pre` that are needed by `genSpec`. Deleting it breaks the
build_defacto chain. Only `grdlbuild codegen` properly recreates it through the
full dependency chain.

### Rule 4: Always Use `-x repo_prep`

This prevents repo_prep from resetting local changes (reverting socgen/pchlp.yml
comments, overwriting template edits, etc.)

### Rule 5: Freeze RDL Sync After socgen

After running socgen, manually sync the freeze_rdl copy:
```bash
cp register/fusegen/fuse_rdl/templates_output/pchlp/SOCS.rdl \
   register/fusegen/freeze_rdl/pchlp/templates_output/pchlp/SOCS.rdl
```
The freeze_rdl copy is NOT auto-generated. `fusegen_quality_check` mock task
validates they match — it will FAIL if you forget this step.

---

### IP Removal — Build Workflow Recipes

When performing scalable IP removal, the build flow requires careful sequencing.
These recipes document the exact commands and ordering learned from production
IP removals.

#### Golden Rule: socgen Before Everything

**Any change to `integration/csv/templates/*.csv.template` or `socgen/*.yml` requires
socgen re-run BEFORE any downstream task.** The templates_output directory will NOT
reflect your changes until socgen regenerates it.

```bash
# After ANY template or yml change:
grdlbuild socgen -Pdut=pchlp -x repo_prep
# Then proceed with downstream tasks
```

#### Recipe 1: Full IP Removal Build (First Time)

```bash
export PATH=/nfs/site/home/$USER/.local/bin:$PATH
export GRDL_NO_TOUCH=1

# Step 1: socgen (regenerate templates)
grdlbuild socgen -Pdut=pchlp -x repo_prep

# Step 2: fusegen (regenerate fuse definitions)
grdlbuild fusegen -Pdut=pchlp -x repo_prep -ignore_deps

# Step 3: codegen (full codegen chain including build_defacto)
grdlbuild codegen -Pdut=pchlp -x repo_prep

# Step 4: pch_gen_filelist
grdlbuild pch_gen_filelist -Pdut=pchlp -x repo_prep -ignore_deps

# Step 5: vcssim_compile (may need mapfile patches first!)
grdlbuild vcssim_compile -Pdut=pchlp -x repo_prep -ignore_deps

# Step 6: elab_fc_rtl (may need Makefile patches first!)
grdlbuild elab_fc_rtl -Pdut=pchlp -x repo_prep -ignore_deps
```

#### Recipe 2: After Template CSV Changes Only

```bash
# 1. Rerun socgen
grdlbuild socgen -Pdut=pchlp -x repo_prep

# 2. Rerun build_defacto (with -ignore_deps since socgen already done)
grdlbuild build_defacto -Pdut=pchlp -x repo_prep -ignore_deps
```

#### Recipe 3: After Tieoff CSV Changes (soc_pmc_permanent.tieoff.csv)

```bash
# Tieoff CSVs are NON-template files — socgen is still needed to regenerate
# the merged outputs, then build_defacto validates:
grdlbuild socgen -Pdut=pchlp -x repo_prep
grdlbuild build_defacto -Pdut=pchlp -x repo_prep -ignore_deps
```

#### Recipe 4: Rerun Single VCS Library

When only one library fails during vcssim_compile:
```bash
# Delete the library done marker
rm -f output/pchlp/vcssim/lib/<libname>/.<libname>.done

# Set VCS tools in path
export VCS_HOME=/p/hdk/rtl/cad/x86-64_linux44/synopsys/vcsmx/X-2025.06-SP2
export PATH=$VCS_HOME/bin:$PATH

# Rebuild just that library
gmake -f output/pchlp/vcssim/flowgen/Makefile vcssim.lib.<libname> BATCH=1
```

#### Recipe 5: VCS Mapfile Patches (After Every Flowgen Run)

Some libraries may be missing dependency entries in VCS mapfiles.
This is NOT persistent — must re-apply after every flowgen/vcssim_compile run.

```bash
WORKAREA=$(pwd)
for map in vcssim.lib.pchlp_pch_verif.map vcssim.lib.pchlp_pch_dfx_top_verif.map; do
  echo "pcie_ipenv_val : $WORKAREA/output/pchlp/vcssim/lib/pcie_ipenv_val" >> output/pchlp/vcssim/flowgen/mapfiles/$map
  echo "fia_env_val : $WORKAREA/output/pchlp/vcssim/lib/fia_env_val" >> output/pchlp/vcssim/flowgen/mapfiles/$map
done
```

**Symptoms:** "Package not defined" errors during vcssim_compile for pchlp_pch_verif or pchlp_pch_dfx_top_verif.

#### Recipe 6: VCS Elab Makefile Patches (After Every Flowgen Run)

VCS partcomp does NOT read elab opts files for PLI resolution.
The `-P novas.tab pli.a` must be on the VCS command line.

```bash
# Find VERDI_HOME from baseline_tools/dv_tools.cth (vcssim_verdi_path key)
VERDI_HOME=/p/hdk/rtl/cad/x86-64_linux44/synopsys/verdi3/X-2025.06-SP2

# Edit output/pchlp/vcssim/flowgen/Makefile
# Find ELAB_OPTS_STRING and append:
# -debug_access+all -P $VERDI_HOME/share/PLI/VCS/LINUX64/novas.tab $VERDI_HOME/share/PLI/VCS/LINUX64/pli.a
```

**Symptoms:** `$fsdbDumpvars` or `$vcdpluson` errors during elab_fc_rtl.
**Note:** This is typically a pre-existing environment issue, NOT caused by IP removal.

#### Recipe 7: PSF Generation Chain

After RDL or PSF control.json changes:
```bash
export WORKAREA=$(pwd)
export WORKAREA_PSF=$WORKAREA/subip/vip/psf_env
export IP_PSF=$WORKAREA/subsystems/psf
export DUT=pchlp
export PYTHONPATH=$WORKAREA/subip/vip/psf_env
export PSF_CFG=ttlh

# gen_rdl
cat $IP_PSF/gen/$PSF_CFG/gen/psf_pch_psf*_srdl_regs.rdl > subsystems/psf/gen/verif/psf_pch_srdl_regs.rdl

# extract_rdl
python3 subsystems/psf/scripts/extract_rdl.py --rdl subsystems/psf/gen/verif/psf_pch_srdl_regs.rdl --output subsystems/psf/gen/rdl_dict.json

# gen_psf_val → gen_psf_val_rs1rs2 → gen_psf_sigtrk → gen_psf_cov
python3 subsystems/psf/scripts/gen_psf_val.py
```

#### Recipe 8: JEM Tracker Generation

If vcssim_compile fails on `pchlp_pcd_jem_trackers` library:
```bash
cd emu && make jem_gen DUT=pchlp
python3 emu/pchlp/scripts/psf_gen_jem.py
```

#### Recipe 9: Force pch_gen_filelist Regeneration

When verif_opts.f include chains change:
```bash
# Must delete old output to force regeneration
rm -f output/pchlp/genfile_dv/vcssim/pchlp/val/pch_verif_opts.f
rm -f output/pchlp/genfile_dv/vcssim/pchlp/val/pch_verif.f
grdlbuild pch_gen_filelist -Pdut=pchlp -x repo_prep -ignore_deps
```

**IMPORTANT:** `pch_gen_filelist` generates TWO files:
- `pch_verif_opts.f` — all `+define+` flags
- `pch_verif.f` — all source files and incdirs

#### IP Removal Build Debugging Checklist

When a build task fails during IP removal, check in this order:

1. **socgen failure** → Check template syntax (`[% IF ... -%]` / `[% END -%]` balance)
2. **fusegen failure** → Check SOCS.rdl.template (NEVER guard fuse includes/instantiations!)
3. **build_defacto failure** → Check inst_config guards, partition guards (instance-based only!)
4. **pch_gen_filelist failure** → Check filelist includes, verif_opts.f chains
5. **vcssim_compile failure** → Check mapfiles, shared vs IP-specific defines, ifdef guards
6. **elab_fc_rtl failure** → Check cross-module references, XMRE errors, PLI resolution

**Fix tasks in dependency order!** Do NOT skip to vcssim_compile or elab if earlier tasks fail.

---

## PCIe Verification — Compile, Elab, and Test Workflow

This section covers the specific grdlbuild workflow for PCIe sequence/test development,
including when to rebuild, how to validate, and common pitfalls.

### UPF Compile + Elab (for PCIe sequence/test changes — g5s3 models)

**⚠️ PREREQUISITE:** The commands below using `-start_from_task` or `GRDL_NO_TOUCH`
**only work when the base flow (codegen) has already completed** in this workarea.
For first-time builds with no `output/` artifacts, see "SoC Model Workflow" or use the
full command: `grdlbuild elab_<model>_with_upf -Pdut=pchlp` which runs all dependencies.

When modifying **only** verification files (sequences, tests, base_seq), you do NOT need
a full build from socgen/defacto. Use the UPF compile + elab flow:

```bash
cd $WORKAREA
tcsh -c 'setenv WORKAREA <full_workarea_path>; source tool.cth; setenv GRDL_NO_TOUCH; grdlbuild -Pdut=pchlp -start_from_task :common:upf_compile -end_at_task :common:elab_s3_with_upf'
```

**Key points:**
- `GRDL_NO_TOUCH` — Ignores touch files, forces re-run of compile and elab
- Alternatively, manually delete touch files:
  ```bash
  rm -f output/grdlbuild/.flowMgr/pchlp.upf_compile.touch
  rm -f output/grdlbuild/.flowMgr/pchlp.elab_s3_with_upf.touch
  ```
- `WORKAREA` must be set BEFORE `source tool.cth` — build.gradle.kts reads it from env
- If you don't set WORKAREA explicitly, it may pick up a stale value from a previous session

### Build Stage Validation

**Always verify BOTH stages pass before running tests:**

```bash
# 1. Check compile
grep -E "PASS|FAIL" output/grdlbuild/logs/common.upf_compile.log | tail -1
# Expected: "Task common.upf_compile PASSED"

# 2. Check for syntax errors in analysis log
grep "Error-\[" output/pchlp/vcssimmpp/lib/pchlp_pch_verif/analysis.log
# Expected: no output (no errors)

# 3. Check elab
grep -E "PASS|FAIL" output/grdlbuild/logs/common.elab_s3_with_upf.log | tail -1
# Expected: "Task common.elab_s3_with_upf PASSED"
```

**Common compile errors:**
```
Error-[SE] Syntax error — missing include, typo, or undeclared class
Error-[SV-LCM-PD] — class not found in package (need to add include)
```

**Fix workflow:** Fix the .svh file → re-run compile+elab → verify both pass

### Build Times

| Stage | X4 Model | X8 Model |
|-------|----------|----------|
| upf_compile | ~1 min | ~1 min |
| elab_s3_with_upf | ~35 min | ~40 min |

**Never interrupt compile or elab** — it may leave partial outputs that cause issues on next run.

### When to Recompile — Decision Matrix

| What Changed | Compile Needed? | Elab Needed? | Notes |
|-------------|----------------|--------------|-------|
| Sequence .svh file | YES | YES | Any code change requires both |
| Test .svh file | YES | YES | |
| base_seq.svh | YES | YES | Affects ALL tests |
| seqlib.inc | YES | YES | Adding/removing includes |
| tests.inc | YES | YES | Adding/removing tests |
| Only test plusargs | NO | NO | Just rerun the test |
| Only random seed | NO | NO | Just rerun the test |
| RTL files | FULL REBUILD | FULL REBUILD | Start from build_defacto |
| CRIF XML | FULL REBUILD | FULL REBUILD | Start from codegen |

### Running Tests After Successful Build

```bash
cd $WORKAREA
tcsh -c 'setenv WORKAREA <full_path>; source tool.cth; trex $WORKAREA/subsystems/pcie/verif/tests_vegan/<test_name> \
  -simv_args +PCIE_CONFIG +SLA_MAX_RUN_CLOCK=5000000 +vcs +learn +pli -simv_args- \
  -model s3_with_upf -dut pchlp \
  -simv_args +fsdb=dump.fsdb +DASHBOARD_TRK_DISABLE +fsdb+all -simv_args-'
```

### Test Output and Reruns

- First run: `regression/pchlp/trex/<test_name>/`
- Subsequent reruns: `regression/pchlp/trex/<test_name>.1/`, `.2/`, `.3/`, etc.
- **Always check the LATEST numbered directory** for current results
- Each run creates a NEW directory — old results are preserved

### Validating Test Results

```bash
# Quick status check
grep "OVERALL" regression/pchlp/trex/<test_name>[.N]/postmortem.log

# Check for errors
grep "UVM_ERROR\|UVM_FATAL" regression/pchlp/trex/<test_name>[.N]/postmortem.log

# Detailed sequence flow
grep "PCIE_TEST_INFO" regression/pchlp/trex/<test_name>[.N]/jestr.log
```

### Common Pitfalls

1. **Wrong WORKAREA** — Building x4 changes into x8 model or vice versa. Always verify:
   ```bash
   echo $WORKAREA  # Should match your intended model
   ```

2. **Stale touch files** — Build skips compile/elab because touch file exists from previous run.
   Always use `GRDL_NO_TOUCH` or delete touch files.

3. **Running test before elab completes** — The simv binary is incomplete → cryptic failures.
   Wait for "Task common.elab_s3_with_upf PASSED" in the log.

4. **Not killing old test before rerunning** — Multiple tests consume resources.
   Kill the old test process before launching a new one.

5. **Forgetting to update include files** — New sequence/test added but not included in
   `pch_pcie_seqlib.inc` or `pch_pcie_tests.inc` → compile error about unknown class.

6. **Sideband vs Primary access confusion** — Some registers (like AERPR) are in private
   memory space and must use sideband access (`pcie_sideband_access`). Using primary access
   will silently fail or hit the wrong register.

### Multi-Model Workflow (X4 + X8)

When porting tests between models:

```bash
# 1. Make changes in x4
cd /path/to/x4_workarea
# Edit sequences, compile, elab, test

# 2. Copy files to x8
cp subsystems/pcie/verif/common/seqlib_vegan/<seq>.svh /path/to/x8_workarea/subsystems/pcie/verif/common/seqlib_vegan/
# Also copy test dirs, update inc files, update base_seq if needed

# 3. Build x8
cd /path/to/x8_workarea
tcsh -c 'setenv WORKAREA /path/to/x8_workarea; source tool.cth; setenv GRDL_NO_TOUCH; grdlbuild -Pdut=pchlp -start_from_task :common:upf_compile -end_at_task :common:elab_s3_with_upf'

# 4. Run x8 tests
tcsh -c 'setenv WORKAREA /path/to/x8_workarea; source tool.cth; trex ...'
```

**Key x8 differences:**
- X8 can bifurcate to 2x4 (2 active ports) — tests may need `return` after first port
- DSTS.CED may assert during DPC recovery on x8 (correctable errors from multi-lane retrain)
- X8 elab takes ~5 min longer than x4

### SoC Model Workflow (fc_rtl_with_upf)

The SoC model (`fc_rtl_with_upf`) is the full-chip model with 4 PCIe controllers
(PXPA, PXPB, PXPC, PXPD). It is significantly larger and takes much longer to build
than g5s3 models.

#### First-Time SoC Build (No Prior Build Output)

**CRITICAL: For a fresh SoC workarea with no `output/` artifacts, you MUST run
the full dependency chain. You CANNOT use `-start_from_task` or `GRDL_NO_TOUCH`
to skip base tasks (codegen, socgen) if they have never been run.**

```bash
cd $WORKAREA
tcsh -c 'setenv WORKAREA <full_workarea_path>; source tool.cth; grdlbuild elab_fc_rtl_with_upf -Pdut=pchlp'
```

This runs the ENTIRE chain: socgen → repo_prep → codegen → compile → elab.
Expected runtime: **~12 hours** (distributed across Netbatch hosts).

**Using `-x repo_prep`:** Only use this on iterative builds where repo_prep has
already run. For first-time builds, repo_prep is needed to set up IP deliveries
and symlinks. Note: repo_prep does NOT do `git clean` — it runs `moab update`,
OSXML prep, and IP scripts. Your custom verification files (sequences, tests,
includes, base_seq changes) are safe.

#### Iterative SoC Build (Verif-Only Changes)

When modifying **only** verification files (sequences, tests, base_seq) in a workarea
where codegen has already completed:

```bash
cd $WORKAREA
tcsh -c 'setenv WORKAREA <full_workarea_path>; source tool.cth; setenv GRDL_NO_TOUCH; grdlbuild -Pdut=pchlp -start_from_task :common:upf_compile -end_at_task :common:elab_fc_rtl_with_upf'
```

Or manually delete touch files instead of using GRDL_NO_TOUCH:
```bash
rm -f output/grdlbuild/.flowMgr/pchlp.upf_compile.touch
rm -f output/grdlbuild/.flowMgr/pchlp.elab_fc_rtl_with_upf.touch
```

#### SoC Build Times

| Stage | SoC Model | Notes |
|-------|-----------|-------|
| Full chain socgen → elab_fc_rtl | ~5h | Without UPF, 43 partitions |
| upf_compile | ~54 min | UPF file sourcing + strategy |
| elab_fc_rtl_with_upf (elab only) | ~8h 41m | 62 partitions dist compile + stitch |
| Full chain socgen → elab_fc_rtl_with_upf | ~12h 11m | Full dependency chain |

**PARAONS3 is the bottleneck:** Largest partition (5592 modules), ~6h compile+link time.
During the archive→.so linking phase (~1-2h), no log output is produced — this is normal.

#### Running SoC Tests

```bash
cd $WORKAREA
tcsh -c 'setenv WORKAREA <full_path>; source tool.cth; trex $WORKAREA/subsystems/pcie/verif/tests_vegan/<test_name> \
  -simv_args +PCIE_CONFIG +SLA_MAX_RUN_CLOCK=5000000 +vcs +learn +pli -simv_args- \
  -model fc_rtl_with_upf -dut pchlp \
  -simv_args +fsdb=dump.fsdb +DASHBOARD_TRK_DISABLE +fsdb+all -simv_args-'
```

**Key difference from g5s3:** Use `-model fc_rtl_with_upf` instead of `-model s3_with_upf`.

#### SoC vs g5s3 Key Differences

| Feature | g5s3 | SoC (fc_rtl) |
|---------|------|-------------|
| Model name | `s3_with_upf` | `fc_rtl_with_upf` |
| Elab command | `elab_s3_with_upf` | `elab_fc_rtl_with_upf` |
| PCIe controllers | PXPC, PXPD | PXPA, PXPB, PXPC, PXPD |
| Elab time | ~35-40 min | ~8-12h |
| Test run `-model` | `s3_with_upf` | `fc_rtl_with_upf` |
| Regression test suffixes | N/A | `_PXPA`, `_PXPB`, `_PXPC`, `_PXPD` |
| First-time build | Can use `-start_from_task` if codegen exists | Must run full chain from socgen |

#### Monitoring SoC Build Progress

```bash
# Check overall grdlbuild progress
tail -5 output/grdlbuild/build_logs/grdlbuild.log

# Check specific task log
tail -20 output/grdlbuild/logs/<project>.<taskname>.log

# Monitor PARAONS3 (slowest partition during UPF elab)
tail -5 output/pchlp/vcssimmpp/model/fc_rtl_with_upf/partitionlib/PARAONS3_RTL_LIB_paraons3_*/PARAONS3_RTL_LIB_paraons3_*.log

# Check if simv binary is generated (elab complete)
ls -la output/pchlp/vcssimmpp/model/fc_rtl_with_upf/fc_rtl_with_upf.simv
```

#### SoC Build Validation

```bash
# Check compile
grep -E "PASS|FAIL" output/grdlbuild/logs/common.upf_compile.log | tail -1

# Check elab
grep -E "PASS|FAIL" output/grdlbuild/logs/common.elab_fc_rtl_with_upf.log | tail -1
```

---

## GK Mock (Gatekeeper Mock Run)

After local elab passes, run a full GK mock to validate all integration tasks:

### Running Mock

**CRITICAL: Always launch mock with `nohup`:**
```bash
# Backup previous mock output
mv GATEKEEPER GATEKEEPER_mockN_backup 2>/dev/null

# Launch mock (MUST use nohup to survive shell disconnect)
nohup turnin -c pcd_mono -s hml-s-main -mock -no_clone > mock_launch.log 2>&1 &

# Verify mock started
sleep 120 && tail -5 GATEKEEPER/gk-utils.log
```

**Why nohup is required:** The `turnin` process runs for 2-4 hours. Without `nohup`,
closing the terminal or stopping the shell sends SIGPIPE which kills the mock. This
was discovered when `stop_bash` on a shell running mock propagated SIGPIPE and stopped
a 200-task mock run.

**Never:**
- Run `turnin -mock` in a foreground shell you might close
- Use `stop_bash` or Ctrl-C on a shell running mock
- Kill the parent shell process

**Monitoring (from a separate shell):**
```bash
# Progress (live stream)
tail -f GATEKEEPER/gk-utils.log

# Task summary
grep "FAIL\|PASS" GATEKEEPER/gk_report.txt

# Check if mock process is still alive
ps aux | grep gk-utils | grep -v grep

# Quick check if mock has ended (look for exit code line)
tail -5 GATEKEEPER/gk-utils.log | grep "Exit code"

# Full completion summary
grep -E "has completed|Exit code|Encountered|Run time|Created.*Tasks" GATEKEEPER/gk-utils.log
```

**Detecting Mock Completion:**
Mock is done when `gk-utils.log` shows these final lines:
```
gk-utils -I-   mock on <stepping> <repo> has completed.
gk-utils -I-   Task mock.<workarea>.<PID> completed natively, no need to issue stop cmd
gk-utils -I- Encountered <N> errors, <M> warnings
gk-utils -I- GK Utils Created = <N> Tasks
gk-utils -I- Run time was <N> seconds
gk-utils -I- Exit code == <N>       ← THE definitive completion signal
Log file completed at <timestamp>   ← final line
```
- **Exit code == 0** → All tasks PASSED
- **Exit code == 1** → One or more tasks FAILED (check `gk_report.txt`)

**Simple (non-resilient) launch** — only if you will keep the shell open the whole time:
```bash
turnin -c pcd_mono -s hml-s-main -mock -no_clone
```

### Mock Output Structure
```
GATEKEEPER/
├── gk-utils.log          # Progress and completion status (tail -f to monitor)
├── gk_report.txt          # Summary report: all tasks with PASS/FAIL/RUNNING
├── NBFeederLogs/          # Per-task detailed logs
│   ├── NBLOG:socgen_pchlp
│   ├── NBLOG:fusegen_pchlp
│   ├── NBLOG:fusegen_pchbase
│   ├── NBLOG:build_defacto_pchlp
│   ├── NBLOG:ultibuild_pchlp
│   ├── NBLOG:elab_fc_rtl_pchlp
│   └── ...
```

### Analyzing Mock Results
```bash
# Check overall status
grep "FAIL\|PASS" GATEKEEPER/gk_report.txt | head -20

# Check specific task log
cat GATEKEEPER/NBFeederLogs/NBLOG:<taskname>

# Inside the NB log, look for the actual build log path:
grep "LOG\|log\|error\|FAIL" GATEKEEPER/NBFeederLogs/NBLOG:<taskname> | tail -20
```

### Common Mock Tasks for IP Removal
| Task | What it validates | Common failures |
|---|---|---|
| `socgen_<dut>` | Template processing | Guard syntax errors |
| `fusegen_<dut>` | Fuse RDL compilation | Missing fuse files, wrong guards |
| `fusegen_quality_check_<dut>` | fuse_rdl vs freeze_rdl match | Forgot to sync freeze_rdl |
| `build_defacto_<dut>` | Defacto/Collage netlist | Dangling signals, wrong tieoffs |
| `vnn_sr_rom_gen_<dut>` | SRM Dashboard generation | Hardcoded IP entries |
| `ultibuild_<dut>` | UltiBuild partition setup | Stublists reference removed IPs |
| `pch_gen_filelist_<dut>` | Verification filelist | Missing defines |
| `elab_fc_rtl_<dut>` | VCS elaboration | Compile errors, undefined modules |
| `partition_seal_<dut>` | Partition RTL check | Missing partition instances |

### Failures to IGNORE (pre-existing, not IP removal related)
- **IP_downrev** — IP version check
- **GitCleanChk** — untracked file detection
- **build_defacto_cache** — if error is `Dumper.c: loadable library and perl binaries are mismatched`, this is a Perl environment issue

### UltiBuild Pre-Existing Failures

UltiBuild exits with code 1 if ANY partition has INTEGRATION failures (USCG errors).
These are typically pre-existing and NOT caused by IP removal.

**Key check:** Look for DISCOVERY or SETUP failures — those indicate IP removal issues.

- INTEGRATION failures from unrelated partitions (paredp, parusb2phy, parxhciport, etc.)
  are pre-existing USCG errors
- Zero DISCOVERY/SETUP failures for removed IP partitions = your changes are correct
- The `-e` flag in `ultibuildcache_makefile` excludes removed IP partitions
  (e.g., `parpxpacore,parpxpallp,parpxpampphy,parpxpatxrx`)

### Individual Task Validation (Local Pre-Mock Checks)

Before running a full mock, validate specific tasks locally to catch issues early:

```bash
# Validate fusegen for both DUTs:
grdlbuild fusegen -Pdut=pchlp -x repo_prep -ignore_deps
grdlbuild fusegen -Pdut=pchbase -x repo_prep -ignore_deps

# Validate fusegen quality check:
grdlbuild fusegen_quality_check -Pdut=pchlp -x repo_prep -ignore_deps

# Validate vnn_sr_rom_gen:
grdlbuild vnn_sr_rom_gen -Pdut=pchlp -x repo_prep -ignore_deps

# Validate ultibuild:
grdlbuild ultibuild -Pdut=pchlp -x repo_prep -ignore_deps
# Check: zero DISCOVERY/SETUP failures, INTEGRATION failures are pre-existing
```

**Tip:** Run these in dependency order. If fusegen fails, don't bother with downstream
tasks until fusegen is fixed.

---

## UPF Elab Timing & Bottlenecks

### Expected Runtimes (Model 3 / hml_g5s3_stdis baseline)

| Task | Runtime | Notes |
|---|---|---|
| Full chain socgen → elab_fc_rtl | ~5h | 43 partitions dist compile |
| upf_compile | ~54 min | UPF file sourcing + strategy |
| elab_fc_rtl_with_upf (elab only) | ~8h 41m | 62 partitions dist compile + stitch |
| Full chain socgen → elab_fc_rtl_with_upf | ~12h 11m | Full dependency chain |

### UPF Elab Phases

1. **UPF file sourcing** — thousands of .upf files loaded (~700K-900K log lines)
2. **DPI declaration processing** — benign mismatch warnings
3. **Distributed compile** — 62 partitions compiled in parallel across remote hosts
4. **Stitch/link phase** — `vcselab -stitch=nowrapper` links all partition .so files → simv binary
5. **simv generation** — final binary output

### PARAONS3: The Critical Bottleneck

PARAONS3 is consistently the slowest partition in UPF elab:
- **5592 modules** — largest partition by far
- **Compile time:** ~3-4h for module compilation alone
- **Archive size:** ~822MB `.a` file (grows during compilation)
- **Linking time:** ~1-2h to create the 635MB `.so` from the archive
- **Total T56 runtime:** ~6h (19:04 → 01:12 observed)

**Monitoring PARAONS3 progress:**
```bash
# Check module compilation progress:
tail -5 output/<dut>/vcssimmpp/model/fc_rtl_with_upf/partitionlib/PARAONS3_RTL_LIB_paraons3_*/PARAONS3_RTL_LIB_paraons3_*.log

# Check archive growth (linking phase — no log output):
ls -la output/<dut>/vcssimmpp/model/fc_rtl_with_upf/partitionlib/PARAONS3_RTL_LIB_paraons3_*/csrc/archive.0/*.a

# Check .so generation (final linking step):
ls -la output/<dut>/vcssimmpp/model/fc_rtl_with_upf/partitionlib/PARAONS3_RTL_LIB_paraons3_*/libvcspc_*.so

# Check VCS dist_comp master status:
tail -5 output/<dut>/vcssimmpp/model/fc_rtl_with_upf/tmp/VCS_DIST_LOG.*/vcs1/master_app_logdir/*.master_app.log
```

**Common false alarm:** During PARAONS3 linking, the archive file stops growing for 30-60 min while the linker processes the 822MB archive into a .so file. This is normal — check the `.so.daidir/_*_archive_1.so` file for growth instead. The worker process is alive on the remote host even if NFS files appear static.

### Memory Warnings

Memory warnings like `your processes are using at least 3x the requested memory` are common during UPF elab (especially during stitch phase). These are **benign** — the build continues normally. The stitch phase requires significant memory to merge 62 partition libraries.

### Stitch Phase Monitoring

During stitch, `elab.log` stops growing (no log output). To verify progress:
```bash
# Check if comelab process is alive:
ps aux | grep comelab | grep -v grep

# Check elab.log line count (grows during inline pass, not during initial stitch):
wc -l output/<dut>/vcssimmpp/model/fc_rtl_with_upf/elab.log

# Check for simv binary (appears when stitch completes):
ls -la output/<dut>/vcssimmpp/model/fc_rtl_with_upf/fc_rtl_with_upf.simv

# Check grdlbuild.log for completion:
tail -5 output/grdlbuild/build_logs/grdlbuild.log
```
