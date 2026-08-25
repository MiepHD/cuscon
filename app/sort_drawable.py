#!/usr/bin/env python3
"""Sort items inside categories in a drawable XML file alphabetically.

Behavior:
- For each <category> ... following <item> siblings are treated as that category's items.
- Items are sorted by the `name` attribute when present, otherwise by `drawable`.
- Sorting is case-insensitive.

Usage:
  python sort_drawable.py
"""
from __future__ import annotations
import sys
import xml.etree.ElementTree as ET
from xml.dom import minidom


def sort_key(item: ET.Element) -> str:
    return (item.get('name') or item.get('drawable') or '').lower()


def sort_drawable_file(infile: str) -> None:
    tree = ET.parse(infile)
    root = tree.getroot()

    children = list(root)
    new_children: list[ET.Element] = []
    i = 0
    while i < len(children):
        child = children[i]
        if child.tag == 'category':
            # keep the category element
            new_children.append(child)
            # collect subsequent <item> siblings
            j = i + 1
            items: list[ET.Element] = []
            while j < len(children) and children[j].tag == 'item':
                items.append(children[j])
                j += 1
            # sort items by name or drawable
            items.sort(key=sort_key)
            new_children.extend(items)
            i = j
        else:
            # keep other nodes (version, comments if parsed as elements)
            new_children.append(child)
            i += 1

    # clear and re-append in new order
    for c in list(root):
        root.remove(c)
    for c in new_children:
        root.append(c)

    # pretty-print and write
    raw = ET.tostring(root, encoding='utf-8')
    pretty = minidom.parseString(raw).toprettyxml(indent='    ', encoding='utf-8')

    # Remove lines that contain only whitespace (tabs/spaces/newlines)
    if isinstance(pretty, (bytes, bytearray)):
        text = pretty.decode('utf-8')
    else:
        text = pretty
    filtered_lines = [line for line in text.splitlines() if line.strip() != '']
    pretty_bytes = ('\n'.join(filtered_lines) + '\n').encode('utf-8')

    with open(infile, 'wb') as f:
        f.write(pretty_bytes)

def main() -> None:
    try:
        sort_drawable_file("src/main/res/xml/drawable.xml")
    except Exception as e:
        print('Error:', e, file=sys.stderr)
        sys.exit(2)


if __name__ == '__main__':
    main()
