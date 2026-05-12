# 📊 WW17 Regression Report — mmahdzir (PCIe)

> **Generated**: 2026-04-28 08:05  
> **Testplan**: TTLPCDH.TTL_PCD_H_PCIe_Testplan_ww18.xml  
> **Owner**: mmahdzir | **Total Tests**: 39

## 📡 Regression Sources

| Model | Path | WW |
|-------|------|----|
| SoC (fc_rtl) | `pcd-ttl-h-main-26ww17g` | 26ww17g |
| g5s3 x4 | `pcieg5s3_hsphyX4-ssnip_rtl_zsc16-26ww17a` | 26ww17a |
| g5s3 x8 | `pcieg5s3_hsphyX8-ssnip_rtl_zsc16-26ww17a` | 26ww17a |

## 📈 Executive Summary

| Status | Count |
|--------|-------|
| ✅ All Pass | **27** |
| ❌ Failing | **2** |
| ⚠️ Partial | **0** |
| 🔍 Absent | **10** |
| **Total** | **39** |

**Pass Rate**: 93% (27/29 tested)

## 🏁 Milestone Breakdown

### VAL0P5 (25 tests)
- ✅ Pass: 25 | ❌ Fail: 0 | ⚠️ Partial: 0 | 🔍 Absent: 0

### VAL0P8 (14 tests)
- ✅ Pass: 2 | ❌ Fail: 2 | ⚠️ Partial: 0 | 🔍 Absent: 10

## 📋 Quick View — All Tests

| # | Test Name | Milestone | SoC | g5s3 x4 | g5s3 x8 | Overall |
|---|-----------|-----------|-----|---------|---------|---------|
| 1 | `pch_pcie_fusestrap_connectivity_test` | VAL0P5 | ✅ PASS (8) | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 2 | `pch_hsphy_ldo_connectivity_test` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 3 | `pch_hsphy_register_access_test` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 4 | `pch_hsphy_register_access_test +HSPHY_LDO_OFF` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 5 | `pch_hsphy_register_access_test +HSPHY_LDO_OFF +PMA_F...` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 6 | `pch_pcie_genMax_eq` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 7 | `pch_pcieg5s3_ptm` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 8 | `pch_pcie_L1_STD` | VAL0P5 | ✅ PASS (8) | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 9 | `pch_pcie_L1_Low` | VAL0P5 | ✅ PASS (8) | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 10 | `pch_pcie_L1_Snooz` | VAL0P5 | ✅ PASS (8) | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 11 | `pch_pcie_L1_Snooz +HSPHY_LDO_SURV` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 12 | `pch_pcie_L1_Snooz_genMax` | VAL0P5 | ✅ PASS (2) | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 13 | `pch_pcie_L1_Off +HSPHY_LDO_SURV` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 14 | `pch_pcie_L1_Off_genMax` | VAL0P5 | ✅ PASS (2) | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 15 | `pch_pcie_L1_Off_L1SS_exit_flow` | VAL0P5 | ✅ PASS (8) | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 16 | `pch_pcieg5s3_L1SS_RTD3_LDO_state_check` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 17 | `pch_pcieg5s3_global_reset` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 18 | `pch_pcieg5s3_cold_reset_genMax` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 19 | `pch_pcieg5s3_global_reset_genMax` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 20 | `pch_pcie_PM_state_entry_exit_hpr +PXPX +GenMax +Cold...` | VAL0P8 | 🔍 ABSENT | - | - | 🔍 ABSENT |
| 21 | `pch_pcie_PM_state_entry_exit_hpr +PXPX +GenMax +Warm...` | VAL0P8 | 🔍 ABSENT | - | - | 🔍 ABSENT |
| 22 | `pch_pcie_PM_state_entry_exit_s3_cm3 +PXPX +GenMax +DPC` | VAL0P8 | 🔍 ABSENT | - | - | 🔍 ABSENT |
| 23 | `pch_pcie_PM_state_entry_exit_globalrst +PXPX +GenMax...` | VAL0P8 | 🔍 ABSENT | - | - | 🔍 ABSENT |
| 24 | `pch_s0i2p2_L1p2_pcie +PG_MODE_EN=0` | VAL0P8 | 🔍 ABSENT | - | - | 🔍 ABSENT |
| 25 | `pch_s0i2p2_L1p2_pcie_zero_restore` | VAL0P8 | ⚠️ 4P/4F | - | - | ❌ FAIL |
| 26 | `pch_s3i2p2_L1p2_pcie / pch_pcieg5s3_s3i2p2_L1p2` | VAL0P8 | ⚠️ 5P/5F | ✅ PASS (2) | ✅ PASS (1) | ❌ FAIL |
| 27 | `pch_s0i2p1_L1p1_dpc_pcie` | VAL0P8 | 🔍 ABSENT | - | - | 🔍 ABSENT |
| 28 | `pch_s3i2p0_dpc_pcie` | VAL0P8 | 🔍 ABSENT | - | - | 🔍 ABSENT |
| 29 | `pch_pcieg5s3_coldreset_coldreset` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 30 | `pch_pcieg5s3_coldreset_s0i2p2` | VAL0P8 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 31 | `pch_pcieg5s3_coldreset_s3` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 32 | `pch_pcieg5s3_coldreset_warmreset` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 33 | `pch_pcieg5s3_warmreset_coldreset` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 34 | `pch_pcieg5s3_warmreset_s0i2p2` | VAL0P8 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 35 | `pch_pcieg5s3_warmreset_s3` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 36 | `pch_pcieg5s3_warmreset_warmreset` | VAL0P5 | - | ✅ PASS (2) | ✅ PASS (1) | ✅ ALL PASS |
| 37 | `pch_pcie_dpc_edpc_up_tlp_trig` | VAL0P8 | 🔍 ABSENT | - | - | 🔍 ABSENT |
| 38 | `pch_pcie_dpc_edpc_rppio_err_trig` | VAL0P8 | 🔍 ABSENT | - | - | 🔍 ABSENT |
| 39 | `pch_pcie_dpc_edpc` | VAL0P8 | 🔍 ABSENT | - | - | 🔍 ABSENT |

## 🔍 Needs Attention

### 33.1. pch_pcie_PM_state_entry_exit_hpr +PXPX +GenMax +ColdReset +DPC
- **Milestone**: VAL0P8 | **Priority**: High | **Testplan Status**: Open
- **Overall**: 🔍 ABSENT
- **Target Models**: soc
- **SoC**: 🔍 ABSENT — no matching results found

### 33.2. pch_pcie_PM_state_entry_exit_hpr +PXPX +GenMax +WarmReset +DPC
- **Milestone**: VAL0P8 | **Priority**: High | **Testplan Status**: Open
- **Overall**: 🔍 ABSENT
- **Target Models**: soc
- **SoC**: 🔍 ABSENT — no matching results found

### 33.3. pch_pcie_PM_state_entry_exit_s3_cm3 +PXPX +GenMax +DPC
- **Milestone**: VAL0P8 | **Priority**: High | **Testplan Status**: Open
- **Overall**: 🔍 ABSENT
- **Target Models**: soc
- **SoC**: 🔍 ABSENT — no matching results found

### 33.4. pch_pcie_PM_state_entry_exit_globalrst +PXPX +GenMax +DPC
- **Milestone**: VAL0P8 | **Priority**: High | **Testplan Status**: Open
- **Overall**: 🔍 ABSENT
- **Target Models**: soc
- **SoC**: 🔍 ABSENT — no matching results found

### 34.8. pch_s0i2p2_L1p2_pcie +PG_MODE_EN=0
- **Milestone**: VAL0P8 | **Priority**: High | **Testplan Status**: Open
- **Overall**: 🔍 ABSENT
- **Target Models**: soc
- **SoC**: 🔍 ABSENT — no matching results found

### 34.10. pch_s0i2p2_L1p2_pcie_zero_restore
- **Milestone**: VAL0P8 | **Priority**: High | **Testplan Status**: Open
- **Overall**: ❌ FAIL
- **Target Models**: soc
- **SoC**: ⚠️ 4P/4F
  - ✅ `pch_s0i2p2_L1p2_pcie_zero_restore_PLATFORM_CFG_90_SOC_PXPA` (pcie_sx_s0ix_testlist.list)
  - ✅ `pch_s0i2p2_L1p2_pcie_zero_restore_PLATFORM_CFG_91_SOC_PXPB` (pcie_sx_s0ix_testlist.list)
  - ✅ `pch_s0i2p2_L1p2_pcie_zero_restore_PLATFORM_CFG_92_SOC_PXPC` (pcie_sx_s0ix_testlist.list)
  - ✅ `pch_s0i2p2_L1p2_pcie_zero_restore_PLATFORM_CFG_93_SOC_PXPD` (pcie_sx_s0ix_testlist.list)
  - ❌ `pch_s0i2p2_L1p2_pcie_zero_restore_PLATFORM_CFG_90_SOC_PXPA` (pcie_sx_s0ix_testlist.list.1)
  - ❌ `pch_s0i2p2_L1p2_pcie_zero_restore_PLATFORM_CFG_91_SOC_PXPB` (pcie_sx_s0ix_testlist.list.1)
  - ❌ `pch_s0i2p2_L1p2_pcie_zero_restore_PLATFORM_CFG_92_SOC_PXPC` (pcie_sx_s0ix_testlist.list.1)
  - ❌ `pch_s0i2p2_L1p2_pcie_zero_restore_PLATFORM_CFG_93_SOC_PXPD` (pcie_sx_s0ix_testlist.list.1)

### 34.18. pch_s3i2p2_L1p2_pcie / pch_pcieg5s3_s3i2p2_L1p2
- **Milestone**: VAL0P8 | **Priority**: High | **Testplan Status**: Open
- **Overall**: ❌ FAIL
- **Target Models**: g5s3_x4, g5s3_x8, soc
- **SoC**: ⚠️ 5P/5F
  - ✅ `pch_s3i2p2_L1p2_pcie_SOC_PXPA` (pcie_sx_s0ix_testlist.list)
  - ✅ `pch_s3i2p2_L1p2_pcie_SOC_PXPB` (pcie_sx_s0ix_testlist.list)
  - ✅ `pch_s3i2p2_L1p2_pcie_SOC_PXPC` (pcie_sx_s0ix_testlist.list)
  - ✅ `pch_s3i2p2_L1p2_pcie_SOC_PXPC_IOE` (pcie_sx_s0ix_testlist.list)
  - ✅ `pch_s3i2p2_L1p2_pcie_SOC_PXPD` (pcie_sx_s0ix_testlist.list)
  - ❌ `pch_s3i2p2_L1p2_pcie_SOC_PXPA` (pcie_sx_s0ix_testlist.list.1)
  - ❌ `pch_s3i2p2_L1p2_pcie_SOC_PXPB` (pcie_sx_s0ix_testlist.list.1)
  - ❌ `pch_s3i2p2_L1p2_pcie_SOC_PXPC` (pcie_sx_s0ix_testlist.list.1)
  - ❌ `pch_s3i2p2_L1p2_pcie_SOC_PXPC_IOE` (pcie_sx_s0ix_testlist.list.1)
  - ❌ `pch_s3i2p2_L1p2_pcie_SOC_PXPD` (pcie_sx_s0ix_testlist.list.1)
- **g5s3 x4**: ✅ PASS (2)
  - ✅ `pch_pcieg5s3_s3i2p2_L1p2_IOE` (g5s3_x4_IOE_pcie_sx_s0ix_testlist.list)
  - ✅ `pch_pcieg5s3_s3i2p2_L1p2` (g5s3_x4_pcie_sx_s0ix_testlist.list)
- **g5s3 x8**: ✅ PASS (1)
  - ✅ `pch_pcieg5s3_s3i2p2_L1p2` (g5s3_x8_pcie_sx_s0ix_testlist.list)

### 35.1. pch_s0i2p1_L1p1_dpc_pcie
- **Milestone**: VAL0P8 | **Priority**: High | **Testplan Status**: Open
- **Overall**: 🔍 ABSENT
- **Target Models**: soc
- **SoC**: 🔍 ABSENT — no matching results found

### 35.2. pch_s3i2p0_dpc_pcie
- **Milestone**: VAL0P8 | **Priority**: High | **Testplan Status**: Open
- **Overall**: 🔍 ABSENT
- **Target Models**: soc
- **SoC**: 🔍 ABSENT — no matching results found

### 38.2. pch_pcie_dpc_edpc_up_tlp_trig
- **Milestone**: VAL0P8 | **Priority**: High | **Testplan Status**: Open
- **Overall**: 🔍 ABSENT
- **Target Models**: soc
- **SoC**: 🔍 ABSENT — no matching results found

### 38.3. pch_pcie_dpc_edpc_rppio_err_trig
- **Milestone**: VAL0P8 | **Priority**: High | **Testplan Status**: Open
- **Overall**: 🔍 ABSENT
- **Target Models**: soc
- **SoC**: 🔍 ABSENT — no matching results found

### 38.4. pch_pcie_dpc_edpc
- **Milestone**: VAL0P8 | **Priority**: High | **Testplan Status**: Open
- **Overall**: 🔍 ABSENT
- **Target Models**: soc
- **SoC**: 🔍 ABSENT — no matching results found

## 🎯 Action Items

### ❌ Failing Tests (2)
- [ ] `pch_s0i2p2_L1p2_pcie_zero_restore` — Debug failure
- [ ] `pch_s3i2p2_L1p2_pcie / pch_pcieg5s3_s3i2p2_L1p2` — Debug failure

### 🔍 Absent from Regression (10)
- [ ] `pch_pcie_PM_state_entry_exit_hpr +PXPX +GenMax +ColdReset +DPC` — Add to regression testlist
- [ ] `pch_pcie_PM_state_entry_exit_hpr +PXPX +GenMax +WarmReset +DPC` — Add to regression testlist
- [ ] `pch_pcie_PM_state_entry_exit_s3_cm3 +PXPX +GenMax +DPC` — Add to regression testlist
- [ ] `pch_pcie_PM_state_entry_exit_globalrst +PXPX +GenMax +DPC` — Add to regression testlist
- [ ] `pch_s0i2p2_L1p2_pcie +PG_MODE_EN=0` — Add to regression testlist
- [ ] `pch_s0i2p1_L1p1_dpc_pcie` — Add to regression testlist
- [ ] `pch_s3i2p0_dpc_pcie` — Add to regression testlist
- [ ] `pch_pcie_dpc_edpc_up_tlp_trig` — Add to regression testlist
- [ ] `pch_pcie_dpc_edpc_rppio_err_trig` — Add to regression testlist
- [ ] `pch_pcie_dpc_edpc` — Add to regression testlist

---
*Report auto-generated by hsio_val_assist agent*