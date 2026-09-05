#!/usr/bin/env python3
"""Import every size of the SF Symbols the macOS panels use.

Usage: sfsymbols-import.py <dump directory> [symbol ...]

The dump names a file for the size of its ink in points, with an optional @2x
for the doubled rendering, so `wifi19x14@2x.png` is 38x28 real pixels. Files are
re-filed under assets/sfsymbols/<symbol>/<width>x<height>.png named for what
they actually contain, which is what MSymbol matches against when it picks one
for the size it is drawn at. Naming by pixels also folds the @2x art into the
same ladder instead of making it a separate case.

With no symbol named, every symbol already imported is refreshed.
"""

import json
import os
import re
import shutil
import sys

from PIL import Image

ASSETS = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), 'assets', 'sfsymbols')


def variants(dump, symbol):
    pattern = re.compile(r'^%s(\d+)x(\d+)(@2x)?\.png$' % re.escape(symbol))
    for entry in os.listdir(dump):
        match = pattern.match(entry)
        if not match:
            continue
        scale = 2 if match.group(3) else 1
        yield entry, int(match.group(1)) * scale, int(match.group(2)) * scale


def adopted(symbol, flat, folder):
    """Art the dump has none of, such as the hand-drawn Bluetooth mark: whatever is
    already filed under the symbol, or a single flat file left from an older import."""
    if os.path.isdir(folder):
        for entry in os.listdir(folder):
            path = os.path.join(folder, entry)
            yield (path, *Image.open(path).size)
        return
    if os.path.isfile(flat):
        os.makedirs(folder)
        width, height = Image.open(flat).size
        shutil.move(flat, os.path.join(folder, '%dx%d.png' % (width, height)))
        yield (folder, width, height)


def imported():
    for entry in sorted(os.listdir(ASSETS)):
        path = os.path.join(ASSETS, entry)
        if os.path.isdir(path):
            yield entry
        elif entry.endswith('.png'):
            yield entry[:-len('.png')]


def main():
    if len(sys.argv) < 2:
        print(__doc__, file=sys.stderr)
        return 2

    dump = sys.argv[1]
    named = sys.argv[2:]
    symbols = named or sorted(set(imported()))

    # Naming symbols imports just those, so the entries for everything else have to
    # survive rather than being dropped from the manifest.
    manifest = {}
    if named:
        try:
            with open(os.path.join(ASSETS, 'manifest.json')) as handle:
                manifest = json.load(handle)
        except FileNotFoundError:
            pass
    for symbol in symbols:
        flat = os.path.join(ASSETS, symbol + '.png')
        folder = os.path.join(ASSETS, symbol)

        found = sorted(variants(dump, symbol), key=lambda v: v[1] * v[2])
        if found:
            shutil.rmtree(folder, ignore_errors=True)
            os.makedirs(folder)
            for name, width, height in found:
                shutil.copyfile(os.path.join(dump, name), os.path.join(folder, '%dx%d.png' % (width, height)))
            if os.path.isfile(flat):
                os.remove(flat)
        else:
            found = sorted(adopted(symbol, flat, folder), key=lambda v: v[1] * v[2])

        if not found:
            print('no art for %s' % symbol, file=sys.stderr)
            continue

        sizes = [[width, height] for _, width, height in found]

        widest, tallest = found[-1][1], found[-1][2]
        manifest[symbol] = {'aspect': round(widest / tallest, 4), 'sizes': sizes}

    with open(os.path.join(ASSETS, 'manifest.json'), 'w') as handle:
        json.dump(manifest, handle, indent=1, sort_keys=True)
        handle.write('\n')

    print('%d symbols, %d files' % (len(manifest), sum(len(v['sizes']) for v in manifest.values())))
    return 0


if __name__ == '__main__':
    sys.exit(main())
