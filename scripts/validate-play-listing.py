#!/usr/bin/env python3
"""Validate Google Play listing copy under android/play-assets/metadata/android.

Checks every locale folder for Play's limits (title 30, short 80, full 4000),
the house rules (no em dashes, no prices, no Apple wording, no promo words in
the title) and the required closing lines. Exit 1 on any failure.

Usage: scripts/validate-play-listing.py [--root PATH]
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "android/play-assets/metadata/android"
LIMITS = {"title.txt": 30, "short_description.txt": 80, "full_description.txt": 4000}
# The same 50 Play locales as Sober, including legacy Play codes.
PLAY_LANGS = set("en-US en-GB en-AU en-CA en-IN de-DE fr-FR fr-CA es-ES es-419 es-US pt-BR pt-PT it-IT nl-NL sv-SE no-NO da-DK fi-FI pl-PL cs-CZ sk sl hr hu-HU ro el-GR tr-TR ru-RU uk ar iw-IL hi-IN bn-BD mr-IN ta-IN te-IN kn-IN ml-IN id ms ms-MY th vi ja-JP ko-KR zh-CN zh-TW zh-HK ca".split())
# Require an explicit sentence, not just an incidental mention of English.
LANGUAGE_NOTICES = {
    "de-DE": "Die App selbst ist nur auf Englisch verfügbar.",
    "fr-FR": "L’application est uniquement en anglais.",
    "fr-CA": "L’application est uniquement en anglais.",
    "es-ES": "La aplicación solo está disponible en inglés.",
    "es-419": "La aplicación solo está disponible en inglés.",
    "es-US": "La aplicación solo está disponible en inglés.",
    "pt-BR": "O aplicativo está disponível apenas em inglês.",
    "pt-PT": "A aplicação está disponível apenas em inglês.",
    "it-IT": "L’app è disponibile solo in inglese.",
    "nl-NL": "De app is alleen beschikbaar in het Engels.",
    "sv-SE": "Appen finns endast på engelska.",
    "no-NO": "Appen er kun tilgjengelig på engelsk.",
    "da-DK": "Appen er kun tilgængelig på engelsk.",
    "fi-FI": "Sovellus on saatavilla vain englanniksi.",
    "pl-PL": "Aplikacja jest dostępna tylko w języku angielskim.",
    "cs-CZ": "Aplikace je dostupná pouze v angličtině.",
    "sk": "Aplikácia je dostupná iba v angličtine.",
    "sl": "Aplikacija je na voljo samo v angleščini.",
    "hr": "Aplikacija je dostupna samo na engleskom jeziku.",
    "hu-HU": "Az alkalmazás csak angol nyelven érhető el.",
    "ro": "Aplicația este disponibilă doar în limba engleză.",
    "el-GR": "Η εφαρμογή είναι διαθέσιμη μόνο στα αγγλικά.",
    "tr-TR": "Uygulama yalnızca İngilizce olarak sunulmaktadır.",
    "ru-RU": "Приложение доступно только на английском языке.",
    "uk": "Застосунок доступний лише англійською мовою.",
    "ar": "التطبيق متاح باللغة الإنجليزية فقط.",
    "iw-IL": "האפליקציה זמינה באנגלית בלבד.",
    "hi-IN": "ऐप केवल अंग्रेज़ी में उपलब्ध है।",
    "bn-BD": "অ্যাপটি শুধু ইংরেজিতে পাওয়া যায়।",
    "mr-IN": "अॅप फक्त इंग्रजीत उपलब्ध आहे.",
    "ta-IN": "செயலி ஆங்கிலத்தில் மட்டுமே கிடைக்கிறது.",
    "te-IN": "యాప్ ఆంగ్లంలో మాత్రమే అందుబాటులో ఉంది.",
    "kn-IN": "ಆ್ಯಪ್ ಇಂಗ್ಲಿಷ್‌ನಲ್ಲಿ ಮಾತ್ರ ಲಭ್ಯವಿದೆ.",
    "ml-IN": "ആപ്പ് ഇംഗ്ലീഷിൽ മാത്രമേ ലഭ്യമാകൂ.",
    "id": "Aplikasi ini hanya tersedia dalam bahasa Inggris.",
    "ms": "Aplikasi ini hanya tersedia dalam bahasa Inggeris.",
    "ms-MY": "Aplikasi ini hanya tersedia dalam bahasa Inggeris.",
    "th": "แอปนี้มีให้ใช้งานเป็นภาษาอังกฤษเท่านั้น",
    "vi": "Ứng dụng chỉ có tiếng Anh.",
    "ja-JP": "アプリ本体は英語のみ対応しています。",
    "ko-KR": "앱은 영어로만 제공됩니다.",
    "zh-CN": "应用本身仅提供英语界面。",
    "zh-TW": "應用程式本身僅提供英文介面。",
    "zh-HK": "應用程式本身只提供英文介面。",
    "ca": "L’aplicació només està disponible en anglès."
}
TITLE_BANNED = re.compile(r"\b(free|best|top|new|sale)\b|#1", re.I)
PRICE = re.compile(r"[$€£¥₹]\s?\d|\d[.,]\d\d\s?(?:€|zł|kr|lei|Kč|₺|₽|₴)")
APPLE = re.compile(r"Apple|App Store|iPhone|iCloud|Apple Watch", re.I)
URL_OK = re.compile(r"https://jackwallner\.github\.io/\S+")


def check(locale_dir: Path) -> list[str]:
    errs: list[str] = []
    loc = locale_dir.name
    if loc not in PLAY_LANGS:
        errs.append(f"unknown Play language code {loc}")
    for name, limit in LIMITS.items():
        p = locale_dir / name
        if not p.exists():
            errs.append(f"missing {name}")
            continue
        text = p.read_text(encoding="utf-8").strip()
        n = len(text)
        if n == 0 or n > limit:
            errs.append(f"{name} {n}/{limit}")
        if "\u2014" in text:
            errs.append(f"{name} has an em dash")
        if re.search("[\u00ad\u200b\ufeff]", text):
            errs.append(f"{name} has an invisible character")
        if PRICE.search(text):
            errs.append(f"{name} looks like it has a price: {PRICE.search(text).group(0)!r}")
        if APPLE.search(URL_OK.sub("", text)):
            errs.append(f"{name} mentions Apple wording: {APPLE.search(text).group(0)!r}")
        if name != "full_description.txt" and "\n" in text:
            errs.append(f"{name} spans lines")
    title = (locale_dir / "title.txt").read_text(encoding="utf-8") if (locale_dir / "title.txt").exists() else ""
    if TITLE_BANNED.search(title):
        errs.append(f"title has a promo word: {title.strip()!r}")
    full = (locale_dir / "full_description.txt").read_text(encoding="utf-8") if (locale_dir / "full_description.txt").exists() else ""
    if "Google Play" not in full:
        errs.append("full description lacks the Google Play billing paragraph")
    if not title.startswith("Cribbage Trainer:"):
        errs.append("title must retain the Cribbage Trainer brand")
    if loc in LANGUAGE_NOTICES and LANGUAGE_NOTICES[loc] not in full:
        errs.append("full description lacks its localized English-only notice")
    for page in ("android-privacy.html", "android-terms.html"):
        if f"https://jackwallner.github.io/cribbage/{page}" not in full:
            errs.append(f"missing {page} link")
    if re.search(r"\b(treat|cure|diagnose)(?:s|d|ing)?\b", full, re.I):
        errs.append("description contains medical claim wording")
    return errs


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", type=Path, default=ROOT)
    args = ap.parse_args()
    bad = 0
    if not args.root.is_dir():
        print(f"Missing metadata root: {args.root}")
        return 1
    dirs = sorted(d for d in args.root.iterdir() if d.is_dir())
    missing = PLAY_LANGS - {d.name for d in dirs}
    if missing:
        print("Missing locales: " + ", ".join(sorted(missing)))
        bad += len(missing)
    for d in dirs:
        errs = check(d)
        t = (d / "title.txt").read_text(encoding="utf-8").strip() if (d / "title.txt").exists() else ""
        s = (d / "short_description.txt").read_text(encoding="utf-8").strip() if (d / "short_description.txt").exists() else ""
        f = (d / "full_description.txt").read_text(encoding="utf-8").strip() if (d / "full_description.txt").exists() else ""
        status = "OK " if not errs else "BAD"
        print(f"{status} {d.name:7} t{len(t):>3} s{len(s):>3} f{len(f):>5}  {t}")
        for e in errs:
            print(f"      - {e}")
        bad += bool(errs)
    # The source snapshot is intentionally untracked and optional on other Macs.
    snapshot = Path(__file__).resolve().parent.parent / ".play-live-listing.json"
    if snapshot.exists():
        for listing in json.loads(snapshot.read_text(encoding="utf-8"))["listings"]:
            for name, key in (("title", "title"), ("short_description", "shortDescription"), ("full_description", "fullDescription")):
                path = args.root / listing["language"] / (name + ".txt")
                if not path.exists() or path.read_text(encoding="utf-8") != listing[key]:
                    print(f"Live listing differs: {listing['language']}/{name}.txt")
                    bad += 1
    print(f"\n{len(dirs)} locales, {bad} with problems")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
