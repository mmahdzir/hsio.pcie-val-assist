#!/usr/bin/env python3
"""
gen_all_tests.py — Generate an all-user test JSON from the PCIe testplan XML.

Usage:
    python3 gen_all_tests.py [--xml <testplan.xml>] [--out <output.json>]

Defaults:
    --xml   : TTLPCDH.TTL_PCD_H_PCIe_Testplan.xml (same directory as this script)
    --out   : all_tests.json (same directory as this script)

The generated JSON contains ALL test entries grouped by owner. The agent uses
this to answer per-user queries by filtering on $USER at runtime — no need to
regenerate per person.

Example agent usage:
    import json, os
    data = json.load(open('testplan/all_tests.json'))
    user = os.environ.get('USER', '')
    my_tests = data['by_owner'].get(user, [])
    val08 = [t for t in my_tests if 'VAL0P8' in t.get('SOCMilestone', '')]
"""

import argparse
import json
import os
import sys
import datetime
import xml.etree.ElementTree as ET
from collections import defaultdict


def parse_args():
    script_dir = os.path.dirname(os.path.realpath(__file__))
    default_xml = os.path.join(script_dir, "TTLPCDH.TTL_PCD_H_PCIe_Testplan.xml")
    parser = argparse.ArgumentParser(
        description="Generate all-user test JSON from PCIe testplan XML."
    )
    parser.add_argument("--xml", default=default_xml,
                        help="Path to testplan XML (default: TTLPCDH...xml alongside this script)")
    parser.add_argument("--out", default=os.path.join(script_dir, "all_tests.json"),
                        help="Output JSON path (default: all_tests.json alongside this script)")
    return parser.parse_args()


def parse_wordml_table(tbl, W):
    """Parse a single WordML w:tbl into a key-value dict."""
    fields = {}
    for tr in tbl.iter(f"{{{W}}}tr"):
        cells = [
            "".join(t.text or "" for t in tc.iter(f"{{{W}}}t")).strip()
            for tc in tr.findall(f"{{{W}}}tc")
        ]
        if len(cells) == 2 and cells[0]:
            key = cells[0].strip()
            if key not in fields:
                fields[key] = cells[1].strip()
    return fields


def extract_all_tests(xml_path):
    if not os.path.isfile(xml_path):
        print(f"ERROR: XML not found: {xml_path}", file=sys.stderr)
        sys.exit(1)

    tree = ET.parse(xml_path)
    root = tree.getroot()
    root_tag = root.tag
    W = root_tag[1:root_tag.index("}")] if "{" in root_tag \
        else "http://schemas.microsoft.com/office/word/2003/wordml"

    all_tests = []
    for tbl in root.iter(f"{{{W}}}tbl"):
        fields = parse_wordml_table(tbl, W)
        if not fields:
            continue
        test_name = fields.get("Test_Name", fields.get("TestName", "")).strip()
        if not test_name:
            continue
        entry = {
            "Test_Name":          test_name,
            "Owner":              fields.get("Owner", "").strip(),
            "SOCMilestone":       fields.get("SOCMilestone", "").strip(),
            "Model":              fields.get("Model", "").strip(),
            "Model_Other":        fields.get("Model_Other", "").strip(),
            "Priority":           fields.get("Priority", "").strip(),
            "SectionNumber":      fields.get("SectionNumber", "").strip(),
            "SectionHeading":     fields.get("SectionHeading", "").strip(),
            "Regression_Type":    fields.get("Regression_Type", "").strip(),
            "Test_Status":        fields.get("Test_Status", "").strip(),
            "Base_Sequence":      fields.get("Base_Sequence", "").strip(),
            "Simv_args":          fields.get("Simv_args", "").strip(),
            "Plan_to_pass":       fields.get("Plan_to_pass", "").strip(),
            "Owner_team":         fields.get("Owner_team", "").strip(),
        }
        all_tests.append(entry)
    return all_tests, W


def main():
    args = parse_args()
    print(f"[gen_all_tests] XML    : {args.xml}")
    print(f"[gen_all_tests] Output : {args.out}")

    all_tests, _ = extract_all_tests(args.xml)

    # Group by owner
    by_owner = defaultdict(list)
    for t in all_tests:
        owner = t["Owner"] or "unassigned"
        by_owner[owner].append(t)

    # Milestone summary
    from collections import Counter
    milestone_counts = Counter(t["SOCMilestone"] for t in all_tests)
    owner_counts = Counter(t["Owner"] or "unassigned" for t in all_tests)

    output = {
        "metadata": {
            "generated":    datetime.datetime.now().strftime("%Y-%m-%d %H:%M"),
            "source":       os.path.basename(args.xml),
            "total_tests":  len(all_tests),
            "owners":       sorted(by_owner.keys()),
            "milestones":   dict(milestone_counts),
            "owner_counts": dict(owner_counts),
            "usage": (
                "Filter by current user at runtime: "
                "data['by_owner'].get(os.environ.get('USER',''), [])"
            ),
        },
        "by_owner": {k: v for k, v in sorted(by_owner.items())},
        "all_tests": all_tests,
    }

    os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
    with open(args.out, "w") as f:
        json.dump(output, f, indent=2)

    print(f"[gen_all_tests] Total  : {len(all_tests)} tests")
    for owner, tests in sorted(by_owner.items()):
        print(f"  {owner:20s}: {len(tests):3d} tests")
    print(f"[gen_all_tests] Written: {args.out}")


if __name__ == "__main__":
    main()
