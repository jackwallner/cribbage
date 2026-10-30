"""Temporary: list catalog keys with Swift's interpolation types (%lld/%@)."""
import json, os, sys
sys.path.insert(0, 'Tools/Localization')
import check

STRINGS = {'release.version', 'Membership.name', 'settings.gameNightDay.displayName', 'weakest.name',
           'AppStoreLinks.feedbackEmail', 'base', 'product.localized', 'text', 'amount', 'prefix', '$0.name',
           'stat.name', 'percent(stat.accuracy)', 'percent(topic.stat.accuracy)', 'recommendedRoom.name',
           'record.accuracy.percentText', 'PracticeTopic.title(weak.id)', 'weak.stat.accuracy.percentText',
           'result.displayDate', 'displayDate', 'card.backTitle', 'card.backBody', 'verdict.pick', 'detail',
           'play.shortLabel', 'question.play.shortLabel', 'result.summary', 'card.spokenName', 'pileText',
           'scenario.situation', 'suit.displayName', 'grid', 'link', 'first', 'last'}

def typed(segs, lit_key):
    out = ''
    for kind, v in segs:
        if kind == 'lit':
            out += v.replace('%', '%%')
        elif v == '$0':
            out += '%@' if 'billed yearly' in lit_key else '%lld'
        else:
            out += '%@' if v in STRINGS else '%lld'
    return out

keys = {}
for d in check.DIRS:
    for dp, _, fs in sorted(os.walk(d)):
        for f in sorted(fs):
            if not f.endswith('.swift'):
                continue
            p = os.path.join(dp, f)
            for line, _, segs in check.scan(p):
                has = any(k == 'interp' for k, _ in segs)
                plain = ''.join((v.replace('%', '%%') if has else v) if k == 'lit' else '%@' for k, v in segs)
                if not plain.strip() or plain in check.IGNORED:
                    continue
                key = typed(segs, plain) if has else plain
                keys.setdefault(key, f'{p}:{line}')
json.dump(keys, open('Tools/Localization/work/keys.json', 'w'), indent=0, ensure_ascii=False)
print(len(keys))
