"""Student space polish (R1): what a young pupil, often with a parent, needs to read at a glance."""
from pathlib import Path

from common import ACCENTS, avatar, chip, icon, page
from planning import phone as _phone

OUT = Path('/Users/macbook/Desktop/NextGenerationClass/docs/00-brand/ui/mockups/r1')

NAV = {'fr': [('house', 'Accueil'), ('calendar', 'Planning')], 'ar': [('house', 'الرئيسية'), ('calendar', 'الجدول')]}

T = {
    'fr': dict(
        hello='Bonjour Adam', summary='Cette semaine, tu as 2 séances.', news='Du nouveau', all='Tout voir',
        cancelled='Séance annulée', cancelled_line='Jeudi 8 octobre · 10:00 · 4ème année · Maths', reason='Motif : sortie scolaire',
        next='Prochaine séance', when='Demain, mercredi', until="jusqu'à 15:30", group='4ème année · Lecture',
        place='En classe · Salle 2', week='Ma semaine', planning='Voir le planning',
        later='La semaine prochaine : 3 séances.', legend_session='Séance', legend_cancelled='Annulée', sat='Samedi 10 octobre', title='Planning', this_week='Cette semaine', next_week='Semaine prochaine',
        tomorrow='Demain, mercredi 7 octobre', thu='Jeudi 8 octobre', tue='Mardi 13 octobre', wed='Mercredi 14 octobre',
        cancel_chip='Annulée', moved_chip='Nouvel horaire', before='Avant : lundi 12 octobre à 10:00',
        online='En ligne', join_hint='Le bouton Rejoindre apparaît 15 min avant.', maths='4ème année · Maths',
        days=[('LUN', 5), ('MAR', 6), ('MER', 7), ('JEU', 8), ('VEN', 9), ('SAM', 10)],
    ),
    'ar': dict(
        hello='مرحبًا آدم', summary='عندك حصتان هذا الأسبوع.', news='جديد', all='عرض الكل',
        cancelled='ألغيت الحصة', cancelled_line='الخميس 8 أكتوبر · 10:00 · <bdi style="white-space:nowrap">4ème année · Maths</bdi>', reason='السبب: خرجة مدرسية',
        next='الحصة القادمة', when='غدًا، الأربعاء', until='إلى 15:30', group='<bdi style="white-space:nowrap">4ème année · Lecture</bdi>',
        place='في القسم · <bdi style="white-space:nowrap">Salle 2</bdi>', week='أسبوعي', planning='عرض الجدول',
        later='الأسبوع القادم: 3 حصص.', legend_session='حصة', legend_cancelled='ألغيت', sat='السبت 10 أكتوبر', title='الجدول', this_week='هذا الأسبوع', next_week='الأسبوع القادم',
        tomorrow='غدًا، الأربعاء 7 أكتوبر', thu='الخميس 8 أكتوبر', tue='الثلاثاء 13 أكتوبر', wed='الأربعاء 14 أكتوبر',
        cancel_chip='ألغيت', moved_chip='موعد جديد', before='قبل: الاثنين 12 أكتوبر على 10:00',
        online='عن بعد', join_hint='يظهر زر الانضمام قبل 15 دقيقة.', maths='<bdi style="white-space:nowrap">4ème année · Maths</bdi>',
        days=[('الاثنين', 5), ('الثلاثاء', 6), ('الأربعاء', 7), ('الخميس', 8), ('الجمعة', 9), ('السبت', 10)],
    ),
}

LECTURE = '#12A39A'


def phone(body, nav, lang, active, height=900):
    """The R1 phone frame, taller: these pages scroll and the whole page is shown."""
    return _phone(body, nav, lang, active).replace('height:844px', f'height:{height}px').replace('height:772px', f'height:{height - 72}px')
MATHS = '#2B3990'


def header(badge=1):
    """Phone header: short wordmark, bell with its count, avatar."""
    count = (f'<span style="position:absolute;top:-6px;inset-inline-end:-6px;min-width:18px;height:18px;padding:0 5px;border-radius:9px;'
             f'background:#FFB020;border:2px solid #fff;color:#1A1D3A;font-size:10px;font-weight:800;display:flex;align-items:center;justify-content:center">{badge}</span>')
    return f'''<div style="display:flex;align-items:center;gap:10px">
  <img src="../ng-symbol.png" style="height:26px" alt=""><span style="flex:1;font-family:'Plus Jakarta Sans';font-size:15px;font-weight:700;color:#2B3990">NG Class</span>
  <span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center;position:relative;color:#4A4F72">{icon('bell', 20)}{count}</span>
  {avatar('AG', 'indigo', 40, True)}
</div>'''


def news(t):
    """Unread changes on the home page: children rarely open the bell."""
    return f'''<section style="background:#F4F5FC;border:1px solid #DCE0F5;border-radius:20px;padding:14px;display:flex;flex-direction:column;gap:10px">
  <div style="display:flex;align-items:center;gap:8px"><span style="flex:1;font-size:12px;font-weight:800;letter-spacing:1px;color:#2B3990">{t['news'].upper() if t is T['fr'] else t['news']}</span><a style="font-size:13px;font-weight:700">{t['all']}</a></div>
  <div style="display:flex;gap:12px;align-items:flex-start">
    <span class="badge" style="width:40px;height:40px;border-radius:12px;background:{ACCENTS['red'][1]};color:{ACCENTS['red'][2]}">{icon('ban', 19)}</span>
    <div style="flex:1;display:flex;flex-direction:column;gap:3px">
      <div style="font-size:16px;font-weight:800">{t['cancelled']}</div>
      <div style="font-size:14px;color:#4A4F72;font-weight:500">{t['cancelled_line']}</div>
      <div style="font-size:14px;color:#B42525;font-weight:600">{t['reason']}</div>
    </div>
    <span style="width:9px;height:9px;border-radius:5px;background:#2B3990;margin-top:8px"></span>
  </div>
</section>'''


def hero(t, lang):
    align = 'right' if lang == 'ar' else 'left'
    return f'''<section style="flex-shrink:0;position:relative;overflow:hidden;background:#0B7C75;border-radius:24px;padding:20px;color:#fff;display:flex;flex-direction:column;gap:8px">
  <svg width="170" height="170" viewBox="0 0 300 300" fill="none" style="position:absolute;inset-inline-end:-40px;bottom:-50px"><path d="M40 250 150 140 260 250" stroke="#fff" stroke-opacity=".09" stroke-width="34" stroke-linecap="round" stroke-linejoin="round"/><path d="M70 170 150 90 230 170" stroke="#fff" stroke-opacity=".12" stroke-width="30" stroke-linecap="round" stroke-linejoin="round"/><circle cx="232" cy="38" r="14" fill="#FFB020"/></svg>
  <div style="display:flex;align-items:center;gap:8px"><span style="padding:4px 10px;border-radius:999px;background:rgba(255,255,255,.16);font-size:12px;font-weight:700">{t['next'].upper() if lang == 'fr' else t['next']}</span><span style="font-size:15px;font-weight:800;color:#FFE2A3">{t['when']}</span></div>
  <div style="display:flex;align-items:baseline;gap:10px;direction:ltr;justify-content:{'flex-end' if lang == 'ar' else 'flex-start'}"><span style="font-size:52px;line-height:1;font-weight:800;text-align:{align}">14:00</span></div>
  <div style="font-size:14px;font-weight:700;color:rgba(255,255,255,.8)">{t['until']}</div>
  <div style="font-size:19px;font-weight:800;margin-top:2px">{t['group']}</div>
  <div style="display:flex;align-items:center;gap:6px;font-size:14px;font-weight:600;color:rgba(255,255,255,.9)">{icon('pin', 16)}{t['place']}</div>
</section>'''


def week(t, lang):
    def tile(label, n, state):
        styles = {
            'today': ('background:#fff;border:2px solid #2B3990', '#2B3990'),
            'normal': ('background:#fff;border:1px solid #E6E8F0', '#1A1D3A'),
        }
        box, color = styles['today' if state == 'today' else 'normal']
        dot = {'lecture': f'<span style="width:8px;height:8px;border-radius:4px;background:{LECTURE}"></span>',
               'maths': f'<span style="width:8px;height:8px;border-radius:4px;background:{MATHS}"></span>',
               'cancelled': f'<span style="color:#E03131;display:flex">{icon("x", 12, 3)}</span>'}.get(state, '<span style="height:8px"></span>')
        size = 11 if lang == 'fr' else 10
        return (f'<div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:3px;padding:8px 2px;border-radius:14px;{box}">'
                f'<span style="font-size:{size}px;font-weight:700;color:#6B7090">{label}</span>'
                f'<span style="font-size:18px;font-weight:800;color:{color}">{n}</span>{dot}</div>')

    states = {6: 'today', 7: 'lecture', 8: 'cancelled', 10: 'maths'}
    tiles = ''.join(tile(label, n, states.get(n, 'normal')) for label, n in t['days'])

    legend = (f'<div style="display:flex;gap:16px;font-size:13px;color:#6B7090;font-weight:600">'
              f'<span style="display:flex;align-items:center;gap:6px"><span style="width:8px;height:8px;border-radius:4px;background:{LECTURE}"></span>{t["legend_session"]}</span>'
              f'<span style="display:flex;align-items:center;gap:6px;color:#B42525">{icon("x", 12, 3)}{t["legend_cancelled"]}</span></div>')
    return f'''<section style="background:#fff;border:1px solid #E6E8F0;border-radius:20px;padding:16px;display:flex;flex-direction:column;gap:12px">
  <div style="display:flex;align-items:center"><h2 style="margin:0;flex:1;font-size:17px;font-weight:800">{t['week']}</h2><a style="font-size:13px;font-weight:700">{t['planning']}</a></div>
  <div style="display:flex;gap:6px">{tiles}</div>
  {legend}
  <div style="font-size:14px;color:#4A4F72;font-weight:600;padding-top:10px;border-top:1px solid #F0F1F6">{t['later']}</div>
</section>'''


def home(lang):
    t = T[lang]
    return phone(f'''
    {header()}
    <div><div style="font-size:26px;font-weight:800;letter-spacing:-.5px">{t['hello']}</div><div style="font-size:15px;color:#4A4F72;margin-top:2px">{t['summary']}</div></div>
    {news(t)}
    {hero(t, lang)}
    {week(t, lang)}
    ''', NAV[lang], lang, 0)


def card(start, end, group, place, color, extra='', strike=False, sub_color='#6B7090'):
    title_style = 'text-decoration:line-through;color:#6B7090' if strike else ''
    return (f'<div style="display:flex;gap:12px;padding:16px;background:#fff;border:1px solid #E6E8F0;border-radius:18px">'
            f'<div style="width:52px;text-align:end;direction:ltr"><div style="font-size:17px;font-weight:800">{start}</div><div style="font-size:13px;color:#6B7090;font-weight:500">{end}</div></div>'
            f'<div style="width:4px;border-radius:2px;background:{color}"></div>'
            f'<div style="flex:1;display:flex;flex-direction:column;gap:4px"><div style="font-size:16px;font-weight:700;{title_style}">{group}</div>'
            f'<div style="font-size:14px;color:{sub_color};font-weight:500">{place}</div>{extra}</div></div>')


def day(label, content):
    return f'<div style="display:flex;flex-direction:column;gap:8px"><div style="font-size:14px;font-weight:800">{label}</div>{content}</div>'


def overline(label, lang):
    text = label.upper() if lang == 'fr' else label
    return f'<div style="font-size:12px;font-weight:800;letter-spacing:{1 if lang == "fr" else 0}px;color:#2B3990;margin-top:2px">{text}</div>'


def planning(lang):
    t = T[lang]
    moved = (f'<div style="display:flex;flex-direction:column;gap:4px;margin-top:4px;align-items:flex-start">{chip(t["moved_chip"], "blue")}'
             f'<span style="font-size:13px;color:#6B7090;text-decoration:line-through">{t["before"]}</span></div>')
    cancelled = (f'<div style="display:flex;flex-direction:column;gap:4px;margin-top:4px;align-items:flex-start">{chip(t["cancel_chip"], "red")}'
                 f'<span style="font-size:14px;color:#B42525;font-weight:600">{t["reason"]}</span></div>')
    online = f'<span style="font-size:13px;color:#6B7090">{t["join_hint"]}</span>'
    return phone(f'''
    {header()}
    <div style="font-size:26px;font-weight:800;letter-spacing:-.5px">{t['title']}</div>
    {overline(t['this_week'], lang)}
    {day(t['tomorrow'], card('14:00', '15:30', t['group'], t['place'], LECTURE))}
    {day(t['thu'], card('10:00', '11:30', t['maths'], '', '#ADB1C6', cancelled, strike=True).replace('<div style="font-size:14px;color:#6B7090;font-weight:500"></div>', ''))}
    {day(t['sat'], card('09:00', '10:30', t['maths'], t['place'], MATHS))}
    {overline(t['next_week'], lang)}
    {day(t['tue'], card('15:00', '16:30', t['maths'], t['place'], MATHS, moved))}
    {day(t['wed'], card('14:00', '15:30', t['group'], f'<span style="display:inline-flex;align-items:center;gap:6px">{icon("video", 15)}{t["online"]}</span>', LECTURE, online))}
    ''', NAV[lang], lang, 1, height=990)


NOTES = [
    ("Du nouveau sur l'accueil", "Les changements pas encore lus s'affichent en haut de l'accueil. Un enfant regarde rarement la cloche. La carte disparaît une fois lu."),
    ('La prochaine séance en mots simples', '"Aujourd\'hui, dans 2 h", "Demain, mercredi", "Jeudi", avec l\'heure de fin.'),
    ('Ma semaine', 'Les jours de la semaine avec un point pour chaque séance et une croix pour une séance annulée. Elle remplace les cartes vides "À faire" et "Derniers résultats", qui reviennent avec la version 2.'),
    ('Deux onglets', 'Accueil et Planning seulement. Cours, Devoirs et Résultats reviennent quand ils existent (plus de pages "Version 2" pour un enfant).'),
    ('Planning plus calme', '"Cette semaine" et "Semaine prochaine". Plus de pastille "Prévue" sur chaque séance : seulement ce qui change (Annulée, Nouvel horaire avec l\'ancien horaire barré).'),
    ('Plus lisible', 'Textes un cran plus grands (heures 17, titres 16, détails 14). "En classe" au lieu de "Présentiel".'),
    ('"Tu" en français', "L'arabe tutoie déjà l'élève. Les parents gardent le vouvoiement dans leur espace."),
    ('Correction', 'Le motif en français dans une ligne arabe se mélangeait (même correction que les notifications).'),
]


def board():
    def column(label, content):
        return f'<div style="display:flex;flex-direction:column;gap:14px;align-items:center"><div class="cap" style="font-size:13px">{label}</div>{content}</div>'

    notes = ''.join(
        f'<div style="display:flex;gap:12px"><span style="width:26px;height:26px;border-radius:13px;background:#2B3990;color:#fff;font-size:13px;font-weight:800;display:flex;align-items:center;justify-content:center;flex-shrink:0">{i}</span>'
        f'<div><div style="font-size:15px;font-weight:800">{title}</div><div style="font-size:14px;color:#4A4F72;line-height:1.5;margin-top:2px">{text}</div></div></div>'
        for i, (title, text) in enumerate(NOTES, 1))
    body = f'''<div style="padding:48px;display:flex;flex-direction:column;gap:40px;background:#EEF0FA;min-height:2030px">
  <div style="display:flex;gap:40px;justify-content:center;align-items:flex-start">
    {column('ÉLÈVE · ACCUEIL', home('fr'))}
    {column('ÉLÈVE · PLANNING', planning('fr'))}
    <div style="width:420px;background:#fff;border:1px solid #E6E8F0;border-radius:24px;padding:28px;display:flex;flex-direction:column;gap:18px">
      <div style="font-size:22px;font-weight:800">Espace élève, version polie</div>
      <div style="font-size:14px;color:#6B7090;line-height:1.5">Pour un enfant de 6 à 11 ans qui lit souvent avec un parent. Données inventées, mardi 6 octobre.</div>
      {notes}
    </div>
  </div>
  <div style="display:flex;gap:40px;justify-content:center;align-items:flex-start">
    {column('ÉLÈVE · ARABE · الرئيسية', home('ar'))}
    {column('ÉLÈVE · ARABE · الجدول', planning('ar'))}
    <div style="width:420px"></div>
  </div>
</div>'''
    return page('Espace élève', body, width=1440, height=2030)


if __name__ == '__main__':
    (OUT / 'EspaceEleve.html').write_text(board())
    print('EspaceEleve')
