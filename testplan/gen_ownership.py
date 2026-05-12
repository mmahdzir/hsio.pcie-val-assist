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


def extract_tests(xml_path, username):
    """Parse testplan XML and return list of test dicts owned by username."""
    if not os.path.isfile(xml_path):
        print(f"ERROR: Testplan XML not found: {xml_path}", file=sys.stderr)
        sys.exit(1)

    tree = ET.parse(xml_path)
    root = tree.getroot()

    # Support both namespaced and non-namespaced XML
    ns = {}
    tag = root.tag
    if "{" in tag:
        ns_uri = tag[1:tag.index("}")]
        ns = {"ns": ns_uri}
        row_tag = "ns:Row"
    else:
        row_tag = "Row"

    owned_tests = []
    total_rows = 0

    for row in root.iter(row_tag if ns else "Row"):
        total_rows += 1
        cells = {}
        for cell in row:
            local = cell.tag.split("}")[-1] if "}" in cell.tag else cell.tag
            cells[local] = (cell.text or "").strip()

        owner = cells.get("Owner", "")
        if owner.lower() != username.lower():
            continue

        owned_tests.append({
            "TestName": cells.get("TestName", cells.get("Test_Name", "")),
            "Owner": owner,
            "SOCMilestone": cells.get("SOCMilestone", cells.get("Milestone", "")),
            "Model": cells.get("Model", ""),
            "Model_Other": cells.get("Model_Other", ""),
            "Status": cells.get("Status", ""),
            "Description": cells.get("Description", cells.get("Scenario", "")),
        })

    return owned_tests, total_rows


def main():
    args = parse_args()
    script_dir = os.path.dirname(os.path.realpath(__file__))

    if not args.out:
        args.out = os.path.join(script_dir, f"{args.user}_tests.json")

    print(f"[gen_ownership] User    : {args.user}")
    print(f"[gen_ownership] XML     : {args.xml}")
    print(f"[gen_ownership] Output  : {args.out}")

    owned_tests, total_rows = extract_tests(args.xml, args.user)

    output = {
        "user": args.user,
        "testplan_xml": os.path.basename(args.xml),
        "total_tests_in_plan": total_rows,
        "owned_count": len(owned_tests),
        "tests": owned_tests,
    }

    with open(args.out, "w") as f:
        json.dump(output, f, indent=2)

    print(f"[gen_ownership] Found   : {len(owned_tests)} tests owned by '{args.user}' "
          f"(out of {total_rows} total)")
    print(f"[gen_ownership] Written : {args.out}")


if __name__ == "__main__":
    main()
