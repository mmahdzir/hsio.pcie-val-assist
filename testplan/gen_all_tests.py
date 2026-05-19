#!/usr/bin/env python3
"""Generate all_tests.json for all owners from the PCIe testplan XML.

Usage:
    python3 gen_all_tests.py TTLPCDH.TTL_PCD_H_PCIe_Testplan.xml

Outputs all_tests.json in the same directory unless --out is provided.
"""

import argparse
import json
from collections import defaultdict
from pathlib import Path
import xml.etree.ElementTree as ET


def clean_braces(text: str) -> str:
    text = (text or '').strip()
    if text.startswith('{') and text.endswith('}'):
        text = text[1:-1]
    return text.strip()


def parse_wordml_table(tbl, ns: str):
    fields = {}
    for tr in tbl.iter(f'{{{ns}}}tr'):
        cells = [''.join(t.text or '' for t in tc.iter(f'{{{ns}}}t')).strip() for tc in tr.findall(f'{{{ns}}}tc')]
        if len(cells) == 2 and cells[0] and cells[0] not in fields:
            fields[cells[0].strip()] = cells[1].strip()
    return fields


def extract_all_tests(xml_path: Path):
    tree = ET.parse(xml_path)
    root = tree.getroot()
    ns = root.tag[1:root.tag.index('}')] if '{' in root.tag else 'http://schemas.microsoft.com/office/word/2003/wordml'
    by_owner = defaultdict(list)
    all_tests = []
    for tbl in root.iter(f'{{{ns}}}tbl'):
        fields = parse_wordml_table(tbl, ns)
        test_name = fields.get('Test_Name', fields.get('TestName', '')).strip()
        if not test_name.startswith('pch_'):
            continue
        row = {
            'test_name': test_name,
            'owner': fields.get('Owner', '').strip(),
            'soc_milestone': clean_braces(fields.get('SOCMilestone', '')) or 'UNSPECIFIED',
            'model': clean_braces(fields.get('Model', '')),
            'section': fields.get('SectionHeading', '').strip() or fields.get('SectionNumber', '').strip(),
        }
        all_tests.append(row)
        by_owner[row['owner']].append({'test_name': row['test_name'], 'soc_milestone': row['soc_milestone'], 'model': row['model'], 'section': row['section']})
    all_tests.sort(key=lambda item: (item['owner'], item['soc_milestone'], item['test_name']))
    return {'metadata': {'generated': 'WW-17', 'source': str(xml_path), 'total_tests': len(all_tests)}, 'by_owner': {owner: sorted(tests, key=lambda item: item['test_name']) for owner, tests in sorted(by_owner.items())}, 'all_tests': all_tests}


def parse_args():
    parser = argparse.ArgumentParser(description='Generate all_tests.json for all owners from PCIe testplan XML.')
    parser.add_argument('xml', help='Path to TTLPCDH.TTL_PCD_H_PCIe_Testplan.xml')
    parser.add_argument('--out', help='Optional output JSON path. Defaults to all_tests.json beside the XML file.')
    return parser.parse_args()


def main():
    args = parse_args()
    xml_path = Path(args.xml).expanduser().resolve()
    if not xml_path.is_file():
        raise SystemExit(f'ERROR: Testplan XML not found: {xml_path}')
    out_path = Path(args.out).expanduser().resolve() if args.out else xml_path.with_name('all_tests.json')
    payload = extract_all_tests(xml_path)
    out_path.write_text(json.dumps(payload, indent=2))
    print(f'[gen_all_tests] XML    : {xml_path}')
    print(f'[gen_all_tests] Output : {out_path}')
    print(f'[gen_all_tests] Tests  : {payload["metadata"]["total_tests"]}')


if __name__ == '__main__':
    main()
