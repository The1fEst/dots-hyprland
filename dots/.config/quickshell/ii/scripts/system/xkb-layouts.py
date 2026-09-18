#!/usr/bin/env python3
"""Print the keyboard layouts and layout options X keyboard extension knows about.

Usage: xkb-layouts.py

The answer is the rules registry every xkb implementation ships, which is what
Hyprland resolves input:kb_layout, input:kb_variant and input:kb_options against.
"""

import json
import os
import sys
import xml.etree.ElementTree as ElementTree

REGISTRIES = [
    '/usr/share/X11/xkb/rules/evdev.xml',
    '/usr/local/share/X11/xkb/rules/evdev.xml',
]


def registry():
    for path in REGISTRIES:
        if os.path.exists(path):
            return ElementTree.parse(path).getroot()
    return None


def item(element):
    config = element.find('configItem')
    if config is None:
        return None
    name = config.find('name')
    description = config.find('description')
    if name is None or name.text is None:
        return None
    return {
        'code': name.text,
        'name': description.text if description is not None and description.text else name.text,
    }


def layouts(root):
    found = []
    for element in root.find('layoutList').findall('layout'):
        layout = item(element)
        if layout is None:
            continue
        variants = element.find('variantList')
        layout['variants'] = [v for v in (item(e) for e in (variants.findall('variant') if variants is not None else [])) if v]
        found.append(layout)
    return found


def option_groups(root):
    groups = []
    group_list = root.find('optionList')
    if group_list is None:
        return groups
    for element in group_list.findall('group'):
        group = item(element)
        if group is None:
            continue
        group['options'] = [o for o in (item(e) for e in element.findall('option')) if o]
        groups.append(group)
    return groups


def main():
    root = registry()
    if root is None:
        print(json.dumps({'layouts': [], 'optionGroups': []}))
        return 0
    print(json.dumps({'layouts': layouts(root), 'optionGroups': option_groups(root)}))
    return 0


if __name__ == '__main__':
    sys.exit(main())
