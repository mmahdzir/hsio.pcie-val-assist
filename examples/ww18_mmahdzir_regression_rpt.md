# WW18 PCIe Regression Report — mmahdzir

> **Generated:** 2026-05-04 · **World Week:** 26ww18a · **Owner:** mmahdzir

---

## 📁 Regression Sources

| Model | Regression Path | Test Dirs |
|-------|----------------|-----------|
| **SoC** (fc_rtl) | `pcd-ttl-h-main-26ww18a` | 291 |
| **g5s3 x4** | `pcieg5s3_hsphyX4-ssnip_rtl_zsc16-26ww18a` | 157 |
| **g5s3 x8** | `pcieg5s3_hsphyX8-ssnip_rtl_zsc16-26ww18a` | 97 |

## 📊 Executive Summary

| Status | Count |
|--------|-------|
| ✅ PASS (all instances pass) | **38** |
| ⚠️ PARTIAL (some pass, some fail) | **1** |
| ❌ FAIL (all instances fail) | **0** |
| ⬜ ABSENT (not found in regression) | **36** |
| 🔄 RUNNING | **0** |
| **Total test-model entries** | **75** |

## 🎯 By SOC Milestone

### VAL0P5 (25 tests)
- Tests with at least one PASS: **16**
- Tests with FAIL or PARTIAL: **1**
- Tests ABSENT from regression: **9**

### VAL0P8 (14 tests)
- Tests with at least one PASS: **0**
- Tests with FAIL or PARTIAL: **0**
- Tests ABSENT from regression: **14**

## 📋 Test Status Table

| # | Test Name | Milestone | SoC | g5s3 x4 | g5s3 x8 |
|---|-----------|-----------|-----|---------|---------|
| 4.1. | `pch_pcie_fusestrap_connectivity_test` | VAL0P5 | ⚠️ PARTIAL (3✅/1❌/4) | ✅ PASS (2/2) | ✅ PASS (1/1) |
| 4.2. | `pch_hsphy_ldo_connectivity_test` | VAL0P5 | — | ✅ PASS (1/1) | ✅ PASS (1/1) |
| 5.2. | `pch_hsphy_register_access_test` | VAL0P5 | — | ✅ PASS (2/2) | ✅ PASS (1/1) |
| 5.3. | `pch_hsphy_register_access_test +HSPHY_LDO_OFF` | VAL0P5 | — | ✅ PASS (2/2) | ✅ PASS (1/1) |
| 5.4. | `pch_hsphy_register_access_test +HSPHY_LDO_OFF +PMA_FORCE_ON_LDO` | VAL0P5 | — | ✅ PASS (2/2) | ✅ PASS (1/1) |
| 6.9. | `pch_pcie_genMax_eq` | VAL0P5 | — | ✅ PASS (2/2) | ✅ PASS (1/1) |
| 22.1. | `pch_pcieg5s3_ptm` | VAL0P5 | — | ✅ PASS (2/2) | ✅ PASS (1/1) |
| 28.2. | `pch_pcie_L1_STD` | VAL0P5 | ✅ PASS (4/4) | ✅ PASS (2/2) | ✅ PASS (1/1) |
| 28.3. | `pch_pcie_L1_Low` | VAL0P5 | ✅ PASS (4/4) | ✅ PASS (2/2) | ✅ PASS (1/1) |
| 28.4. | `pch_pcie_L1_Snooz` | VAL0P5 | ✅ PASS (4/4) | ✅ PASS (2/2) | ✅ PASS (1/1) |
| 28.5. | `pch_pcie_L1_Snooz +HSPHY_LDO_SURV` | VAL0P5 | — | ✅ PASS (2/2) | ✅ PASS (1/1) |
| 28.6. | `pch_pcie_L1_Snooz_genMax` | VAL0P5 | ✅ PASS (1/1) | ✅ PASS (2/2) | ✅ PASS (1/1) |
| 28.8. | `pch_pcie_L1_Off +HSPHY_LDO_SURV` | VAL0P5 | — | ✅ PASS (2/2) | ✅ PASS (1/1) |
| 28.10. | `pch_pcie_L1_Off_genMax` | VAL0P5 | ✅ PASS (1/1) | ✅ PASS (2/2) | ✅ PASS (1/1) |
| 28.11. | `pch_pcie_L1_Off_L1SS_exit_flow` | VAL0P5 | ✅ PASS (4/4) | ✅ PASS (2/2) | ✅ PASS (1/1) |
| 30.1. | `pch_pcieg5s3_L1SS_RTD3_LDO_state_check` | VAL0P5 | — | ✅ PASS (2/2) | ✅ PASS (1/1) |
| 31.17. | `pch_pcieg5s3_global_reset` | VAL0P5 | — | ⬜ ABSENT | ⬜ ABSENT |
| 31.18. | `pch_pcieg5s3_cold_reset_genMax` | VAL0P5 | — | ⬜ ABSENT | ⬜ ABSENT |
| 31.19. | `pch_pcieg5s3_global_reset_genMax` | VAL0P5 | — | ⬜ ABSENT | ⬜ ABSENT |
| 33.1. | `pch_pcie_PM_state_entry_exit_hpr +PXPX +GenMax +ColdReset +DPC` | VAL0P8 | ⬜ ABSENT | — | — |
| 33.2. | `pch_pcie_PM_state_entry_exit_hpr +PXPX +GenMax +WarmReset +DPC` | VAL0P8 | ⬜ ABSENT | — | — |
| 33.3. | `pch_pcie_PM_state_entry_exit_s3_cm3 +PXPX +GenMax +DPC` | VAL0P8 | ⬜ ABSENT | — | — |
| 33.4. | `pch_pcie_PM_state_entry_exit_globalrst +PXPX +GenMax +DPC` | VAL0P8 | ⬜ ABSENT | — | — |
| 34.8. | `pch_s0i2p2_L1p2_pcie +PG_MODE_EN=0` | VAL0P8 | ⬜ ABSENT | — | — |
| 34.10. | `pch_s0i2p2_L1p2_pcie_zero_restore` | VAL0P8 | ⬜ ABSENT | — | — |
| 34.18. | `pch_s3i2p2_L1p2_pcie / pch_pcieg5s3_s3i2p2_L1p2` | VAL0P8 | ⬜ ABSENT | ⬜ ABSENT | ⬜ ABSENT |
| 35.1. | `pch_s0i2p1_L1p1_dpc_pcie` | VAL0P8 | ⬜ ABSENT | — | — |
| 35.2. | `pch_s3i2p0_dpc_pcie` | VAL0P8 | ⬜ ABSENT | — | — |
| 36.1. | `pch_pcieg5s3_coldreset_coldreset` | VAL0P5 | — | ⬜ ABSENT | ⬜ ABSENT |
| 36.2. | `pch_pcieg5s3_coldreset_s0i2p2` | VAL0P8 | — | ⬜ ABSENT | ⬜ ABSENT |
| 36.3. | `pch_pcieg5s3_coldreset_s3` | VAL0P5 | — | ⬜ ABSENT | ⬜ ABSENT |
| 36.4. | `pch_pcieg5s3_coldreset_warmreset` | VAL0P5 | — | ⬜ ABSENT | ⬜ ABSENT |
| 36.14. | `pch_pcieg5s3_warmreset_coldreset` | VAL0P5 | — | ⬜ ABSENT | ⬜ ABSENT |
| 36.15. | `pch_pcieg5s3_warmreset_s0i2p2` | VAL0P8 | — | ⬜ ABSENT | ⬜ ABSENT |
| 36.16. | `pch_pcieg5s3_warmreset_s3` | VAL0P5 | — | ⬜ ABSENT | ⬜ ABSENT |
| 36.17. | `pch_pcieg5s3_warmreset_warmreset` | VAL0P5 | — | ⬜ ABSENT | ⬜ ABSENT |
| 38.2. | `pch_pcie_dpc_edpc_up_tlp_trig` | VAL0P8 | ⬜ ABSENT | — | — |
| 38.3. | `pch_pcie_dpc_edpc_rppio_err_trig` | VAL0P8 | ⬜ ABSENT | — | — |
| 38.4. | `pch_pcie_dpc_edpc` | VAL0P8 | ⬜ ABSENT | — | — |

## 🚨 Action Items

### ❌ Failing Tests

- **`pch_pcie_fusestrap_connectivity_test`** (VAL0P5)
  - SoC: ⚠️ PARTIAL (3✅/1❌/4) — failing: `pch_pcie_fusestrap_connectivity_test_PXPB`

### ⬜ Absent Tests (not found in ww18a regression)

- **`pch_pcieg5s3_global_reset`** (VAL0P5) — absent from: x4, x8
- **`pch_pcieg5s3_cold_reset_genMax`** (VAL0P5) — absent from: x4, x8
- **`pch_pcieg5s3_global_reset_genMax`** (VAL0P5) — absent from: x4, x8
- **`pch_pcie_PM_state_entry_exit_hpr +PXPX +GenMax +ColdReset +DPC`** (VAL0P8) — absent from: SoC
- **`pch_pcie_PM_state_entry_exit_hpr +PXPX +GenMax +WarmReset +DPC`** (VAL0P8) — absent from: SoC
- **`pch_pcie_PM_state_entry_exit_s3_cm3 +PXPX +GenMax +DPC`** (VAL0P8) — absent from: SoC
- **`pch_pcie_PM_state_entry_exit_globalrst +PXPX +GenMax +DPC`** (VAL0P8) — absent from: SoC
- **`pch_s0i2p2_L1p2_pcie +PG_MODE_EN=0`** (VAL0P8) — absent from: SoC
- **`pch_s0i2p2_L1p2_pcie_zero_restore`** (VAL0P8) — absent from: SoC
- **`pch_s3i2p2_L1p2_pcie / pch_pcieg5s3_s3i2p2_L1p2`** (VAL0P8) — absent from: SoC, x4, x8
- **`pch_s0i2p1_L1p1_dpc_pcie`** (VAL0P8) — absent from: SoC
- **`pch_s3i2p0_dpc_pcie`** (VAL0P8) — absent from: SoC
- **`pch_pcieg5s3_coldreset_coldreset`** (VAL0P5) — absent from: x4, x8
- **`pch_pcieg5s3_coldreset_s0i2p2`** (VAL0P8) — absent from: x4, x8
- **`pch_pcieg5s3_coldreset_s3`** (VAL0P5) — absent from: x4, x8
- **`pch_pcieg5s3_coldreset_warmreset`** (VAL0P5) — absent from: x4, x8
- **`pch_pcieg5s3_warmreset_coldreset`** (VAL0P5) — absent from: x4, x8
- **`pch_pcieg5s3_warmreset_s0i2p2`** (VAL0P8) — absent from: x4, x8
- **`pch_pcieg5s3_warmreset_s3`** (VAL0P5) — absent from: x4, x8
- **`pch_pcieg5s3_warmreset_warmreset`** (VAL0P5) — absent from: x4, x8
- **`pch_pcie_dpc_edpc_up_tlp_trig`** (VAL0P8) — absent from: SoC
- **`pch_pcie_dpc_edpc_rppio_err_trig`** (VAL0P8) — absent from: SoC
- **`pch_pcie_dpc_edpc`** (VAL0P8) — absent from: SoC

### ✅ All Passing Tests

- `pch_hsphy_ldo_connectivity_test` (VAL0P5)
- `pch_hsphy_register_access_test` (VAL0P5)
- `pch_hsphy_register_access_test +HSPHY_LDO_OFF` (VAL0P5)
- `pch_hsphy_register_access_test +HSPHY_LDO_OFF +PMA_FORCE_ON_LDO` (VAL0P5)
- `pch_pcie_genMax_eq` (VAL0P5)
- `pch_pcieg5s3_ptm` (VAL0P5)
- `pch_pcie_L1_STD` (VAL0P5)
- `pch_pcie_L1_Low` (VAL0P5)
- `pch_pcie_L1_Snooz` (VAL0P5)
- `pch_pcie_L1_Snooz +HSPHY_LDO_SURV` (VAL0P5)
- `pch_pcie_L1_Snooz_genMax` (VAL0P5)
- `pch_pcie_L1_Off +HSPHY_LDO_SURV` (VAL0P5)
- `pch_pcie_L1_Off_genMax` (VAL0P5)
- `pch_pcie_L1_Off_L1SS_exit_flow` (VAL0P5)
- `pch_pcieg5s3_L1SS_RTD3_LDO_state_check` (VAL0P5)

---

## 📌 Notes

- **DPC tests (38.2–38.4):** These are VAL0P8 tests being validated in custom workarea `/nfs/site/disks/zsc16_mmahdzir_stod001/ttl_dpc_ww18`. Test 1 (`up_tlp_trig`) on SoC PXPB: **✅ PASSED**. Tests 2 (`rppio_err_trig`) and 3 (`dn_poisoned_tlp_trig`) are **currently running** in SoC TOM mode — expected completion ~20-25h.
- **`pch_pcie_fusestrap_connectivity_test` PXPB failure:** SoC PXPB instance failed in official regression. Other 3 controllers (PXPA/PXPC/PXPD) passed.
- **Reset/coldreset/warmreset tests (36.x, 31.17-19):** Not present in ww18a regression lists for x4/x8 models.
- **VAL0P8 PM+DPC tests (33.x, 34.x, 35.x):** Not yet in ww18a SoC regression — planned for future ww.
