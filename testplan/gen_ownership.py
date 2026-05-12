#!/usr/bin/env python3
"""
gen_ownership.py — Generate a per-user test ownership JSON from the PCIe testplan XML.

Usage:
    python3 gen_ownership.py [--user <username>] [--xml <testplan.xml>] [--out <output.json>]

Defaults:
    --user  : current Unix user ($USER / whoami)
    --xml   : TTLPCDH.TTL_PCD_H_PCIe_Testplan.xml (same directory as this script)
    --out   : <username>_tests.json  (same directory as this script)

The generated JSON contains all test entries where the Owner field matches the
requested user. This is used by the hsio_val_assist agent to scope regression
reports to the current user's tests.
"""

import argparse
import json
import os
import sys
import xml.etree.ElementTree as ET


def parse_args():
    script_dir = os.path.dirname(os.path.realpath(__file__))
    default_user = os.environ.get("USER") or os.popen("whoami").read().strip()
    default_xml = os.path.join(script_dir, "TTLPCDH.TTL_PCD_H_PCIe_Testplan.xml")

    parser = argparse.ArgumentParser(
        description="Generate per-user test ownership JSON from PCIe testplan XML."
    )
    parser.add_argument(
        "--user", default=default_user,
        help="Unix username to filter tests by (default: current $USER)"
    )
    parser.add_argument(
        "--xml", default=default_xml,
        help="Path to testplan XML file (default: TTLPCDH.TTL_PCD_H_PCIe_Testplan.xml)"
    )
    parser.add_argument(
        "--out", default=None,
        help="Output JSON file path (default: <username>_tests.json alongside this script)"
    )
    return parser.parse_args()


def parse_wordml_table(tbl, W):
    """Parse a single WordML table into a key-value dict (test entry)."""
    fields = {}
    for tr in tbl.iter(f"{{{W}}}tr"):
        cells = [
            "".join(t.text or "" for t in tc.iter(f"{{{W}}}t")).strip()
            for tc in tr.findall(f"{{{W}}}tc")
        ]
        # Only collect exactly 2-cell rows as key-value pairs; skip header/multi-col rows
        if len(cells) == 2 and cells[0]:
            key = cells[0].strip()
            value = cells[1].strip()
            if key not in fields:  # keep first occurrence only
                fields[key] = value
    return fields


def extract_tests(xml_path, username):
    """Parse testplan WordML and return list of test dicts owned by username."""
    if not os.path.isfile(xml_path):
        print(f"ERROR: Testplan XML not found: {xml_path}", file=sys.stderr)
        sys.exit(1)

    tree = ET.parse(xml_path)
    root = tree.getroot()

    # Detect WordML namespace
    root_tag = root.tag
    if "{" in root_tag:
        W = root_tag[1:root_tag.index("}")]
    else:
        W = "http://schemas.microsoft.com/office/word/2003/wordml"

    owned_tests = []
    total_tables = 0

    for tbl in root.iter(f"{{{W}}}tbl"):
        fields = parse_wordml_table(tbl, W)
        if not fields:
            continue
        total_tables += 1

        owner = fields.get("Owner", "").strip()
        if owner.lower() != username.lower():
            continue

        owned_tests.append({
            "SectionNumber": fields.get("SectionNumber", ""),
            "SectionHeading": fields.get("SectionHeading", ""),
            "Test_Name": fields.get("Test_Name", fields.get("TestName", "")),
            "Test_Objective": fields.get("Test_Objective", ""),
            "Base_Sequence": fields.get("Base_Sequence", ""),
            "SOCMilestone": fields.get("SOCMilestone", ""),
            "SOCMilestone_Reason": fields.get("SOCMilestone_Reason", ""),
            "Model": fields.get("Model", ""),
            "Model_Other": fields.get("Model_Other", ""),
            "Priority": fields.get("Priority", ""),
            "Environment": fields.get("Environment", ""),
            "Regression_Type": fields.get("Regression_Type", ""),
            "Test_Status": fields.get("Test_Status", ""),
            "Owner": owner,
            "Owner_team": fields.get("Owner_team", ""),
            "Plan_to_pass": fields.get("Plan_to_pass", ""),
            "Simv_args": fields.get("Simv_args", ""),
            "Release": fields.get("Release", ""),
        })

    return owned_tests, total_tables


def main():
    args = parse_args()
    script_dir = os.path.dirname(os.path.realpath(__file__))

    if not args.out:
        args.out = os.path.join(script_dir, f"{args.user}_tests.json")

    print(f"[gen_ownership] User    : {args.user}")
    print(f"[gen_ownership] XML     : {args.xml}")
    print(f"[gen_ownership] Output  : {args.out}")

    owned_tests, total_tables = extract_tests(args.xml, args.user)

    output = {
        "user": args.user,
        "testplan_xml": os.path.basename(args.xml),
        "total_tables_in_plan": total_tables,
        "owned_count": len(owned_tests),
        "tests": owned_tests,
    }

    with open(args.out, "w") as f:
        json.dump(output, f, indent=2)

    print(f"[gen_ownership] Found   : {len(owned_tests)} tests owned by '{args.user}' "
          f"(out of {total_tables} test tables)")
    print(f"[gen_ownership] Written : {args.out}")


if __name__ == "__main__":
    main()
