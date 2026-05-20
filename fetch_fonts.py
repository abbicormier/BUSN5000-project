#!/usr/bin/env python3
"""
fetch_fonts.py — Download Merriweather Sans + Raleway .woff2 files from Google
Fonts and save them locally to assets/fonts/, so the Quarto book doesn't depend
on Google Fonts CDN at page-load time.

Run once after cloning or whenever you want to refresh:

    cd BUSN5000-project
    python fetch_fonts.py

After running, commit the contents of assets/fonts/ to the repo.
Subsequent renders use the local fonts (no external CDN call).

Requires Python 3. No third-party packages needed.
"""

import urllib.request
import re
import os
import sys

# Modern Chrome User-Agent so Google Fonts returns woff2 URLs (not older TTF/EOT)
UA = (
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
    'AppleWebKit/537.36 (KHTML, like Gecko) '
    'Chrome/120.0.0.0 Safari/537.36'
)

CSS_URL = (
    'https://fonts.googleapis.com/css2'
    '?family=Merriweather+Sans:wght@400;600;700'
    '&family=Raleway:wght@400;600;700'
    '&display=swap'
)

FONTS_DIR = 'assets/fonts'


def main() -> None:
    print(f"Fetching CSS from Google Fonts: {CSS_URL}")
    req = urllib.request.Request(CSS_URL, headers={'User-Agent': UA})
    try:
        css = urllib.request.urlopen(req).read().decode('utf-8')
    except Exception as e:
        print(f"ERROR: could not fetch CSS: {e}")
        sys.exit(1)

    # Each @font-face block has a family, a weight, and a src: url(...woff2)
    blocks = re.findall(r'@font-face\s*\{[^}]+\}', css, re.DOTALL)
    print(f"Found {len(blocks)} @font-face blocks. Filtering to Latin subset...")

    targets = []  # (family, weight, url, local_filename)
    for block in blocks:
        # Keep only the latin subset block (it has the broad U+0000 range).
        if 'U+0000-00FF' not in block and 'U+0000' not in block:
            continue
        family_m = re.search(r"font-family:\s*'([^']+)'", block)
        weight_m = re.search(r'font-weight:\s*(\d+)', block)
        src_m = re.search(r'url\((https://[^)]+\.woff2)\)', block)
        if not (family_m and weight_m and src_m):
            continue
        family = family_m.group(1).replace(' ', '_')
        weight = weight_m.group(1)
        targets.append((family, weight, src_m.group(1), f'{family}-{weight}.woff2'))

    if not targets:
        print("ERROR: no font URLs matched. Did Google Fonts change their CSS format?")
        sys.exit(1)

    os.makedirs(FONTS_DIR, exist_ok=True)
    print(f"\nDownloading {len(targets)} woff2 files into {FONTS_DIR}/:")
    for family, weight, url, fname in targets:
        out_path = os.path.join(FONTS_DIR, fname)
        req = urllib.request.Request(url, headers={'User-Agent': UA})
        try:
            data = urllib.request.urlopen(req).read()
        except Exception as e:
            print(f"  FAIL {fname}: {e}")
            continue
        with open(out_path, 'wb') as f:
            f.write(data)
        print(f"  OK   {fname}: {len(data)/1024:.1f} KB")

    print("\nDone. Commit the contents of assets/fonts/ to the repo, then push.")


if __name__ == '__main__':
    main()
