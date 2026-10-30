"""Temporary: build Shared/Localizable.xcstrings from order.json + de_*.tsv."""
import glob, json, os
W = 'Tools/Localization/work'
order = json.load(open(f'{W}/order.json'))
de = {}
for p in sorted(glob.glob(f'{W}/de_*.tsv')):
    for line in open(p, encoding='utf-8'):
        line = line.rstrip('\n')
        if not line:
            continue
        i, v = line.split('\t', 1)
        de[int(i)] = v.replace('\\n', '\n')
assert sorted(de) == list(range(len(order))), set(range(len(order))) - set(de)

# English singular forms for count keys (index -> one, or (subst one, subst other) for PL2).
EN_ONE = {
    68: '%lld due mistake first, followed by material you have not seen yet.',
    75: '%lld drill done', 76: '%lld question locked in this week',
    99: 'Endless Practice, timed challenges, and %lld more drill across every room',
    101: '%lld card', 102: '%lld question', 103: '%lld hand', 104: '%lld deal',
    207: '%lld more drill in this room', 238: 'Up %lld question this week',
    252: '%lld drill finished', 270: "All %lld card down. It'll stick a little better every pass.",
    552: '%lld point',
}
EN_SUB = {  # index -> (value, name, argNum, one, other)
    67: ('%#@due@ first, then extra work in %2$@.', 'due', 1, '%arg due mistake', '%arg due mistakes'),
    96: ('Locked. %#@drills@, included with %2$@', 'drills', 1, '%arg drill', '%arg drills'),
    97: ('%1$lld of %#@total@ done', 'total', 2, '%arg drill', '%arg drills'),
    245: ('%1$@ right across %#@n@, your lowest so far.', 'n', 2, '%arg question', '%arg questions'),
    572: ('Count everything with the starter: %1$@. That is %#@n@ in all. Count each fifteen, pair and run separately, and remember a flush in the hand needs four matching cards.', 'n', 2, '%arg point', '%arg points'),
}
ARGNUM = {67: 1, 96: 1, 97: 2, 245: 2, 572: 2}

def unit(v):
    return {'stringUnit': {'state': 'translated', 'value': v}}

def plural(one, other):
    return {'variations': {'plural': {'one': unit(one), 'other': unit(other)}}}

def subst(value, name, arg, one, other):
    return {'stringUnit': {'state': 'translated', 'value': value},
            'substitutions': {name: {'argNum': arg, 'formatSpecifier': 'lld',
                                     'variations': {'plural': {'one': unit(one), 'other': unit(other)}}}}}

strings = {}
for i, key in enumerate(order):
    v = de[i]
    locs = {}
    if v.startswith('PL|'):
        _, one, other = v.split('|')
        locs['de'] = plural(one, other)
        if i in EN_ONE:
            locs['en'] = plural(EN_ONE[i], key)
    elif v.startswith('PL2|'):
        _, _, value, name, one, other = v.split('|')
        locs['de'] = subst(value, name, ARGNUM[i], one, other)
        locs['en'] = subst(*EN_SUB[i])
    else:
        locs['de'] = unit(v)
    strings[key] = {'extractionState': 'manual', 'localizations': dict(sorted(locs.items()))}

cat = {'sourceLanguage': 'en', 'strings': dict(sorted(strings.items())), 'version': '1.0'}
with open('Shared/Localizable.xcstrings', 'w', encoding='utf-8') as f:
    json.dump(cat, f, ensure_ascii=False, indent=2, separators=(',', ' : '))
    f.write('\n')
print(len(strings), 'keys')
