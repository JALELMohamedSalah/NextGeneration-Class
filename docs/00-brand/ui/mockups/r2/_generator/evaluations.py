"""Release 2, step 5: paper evaluations (spec 06 "Évaluations", spec 07 grades)."""
from pathlib import Path

from contents import phone_header, square  # also puts the R1 generator on the path

import common  # noqa: E402
from common import avatar, badge, chip, icon, page, teacher  # noqa: E402
from planning import phone  # noqa: E402
from scan import frame  # noqa: E402

OUT = Path(__file__).resolve().parents[1]

common.ICONS.update({
    'clipcheck': '<rect x="8" y="2" width="8" height="4" rx="1"/><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><path d="m9 14 2 2 4-4"/>',
    'keyboard': '<rect x="2" y="4" width="20" height="16" rx="2"/><path d="M6 8h.01M10 8h.01M14 8h.01M18 8h.01M6 12h.01M10 12h.01M14 12h.01M18 12h.01M7 16h10"/>',
    'calclock': '<path d="M21 7.5V6a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h3.5M16 2v4M8 2v4M3 10h5"/><circle cx="16" cy="16" r="6"/><path d="M16 14v2l1 1"/>',
})

PUPILS = [  # initials, accent, name, score, absent, comment
    ('AG', 'indigo', 'Adam Gharbi', '15', False, 'Très bien, continue.'),
    ('AK', 'amber', 'Amine Kefi', '11,5', False, ''),
    ('OS', 'turquoise', 'Omar Saidi', '', False, ''),
    ('RM', 'violet', 'Rayen Mansour', '', True, 'Malade, à rattraper.'),
    ('SB', 'blue', 'Sami Ben Salah', '17', False, ''),
    ('YT', 'orange', 'Yasmine Trabelsi', '21', False, ''),
]


def tabs(on):
    items = [('À corriger', 2), ('En cours', 3), ('Terminés', 4), ('Évaluations', 2)]
    return '<div class="tabs">' + ''.join(
        f'<span class="{"on" if label == on else ""}">{label}<span class="count" style="background:{"#fff" if label == on else "#F1F3F5"};color:#4A4F72">{n}</span></span>'
        for label, n in items) + '</div>'


def list_page():
    def row(title, group, date, done, total, avg, todo=False, first=False):
        status = chip('Notes à saisir', 'amber') if todo else chip('Notes saisies', 'green')
        return f'''<div class="row" style="padding:14px 0;{"border-top:none" if first else ""}">
  {badge('clipcheck', 'violet', 40, 12, 19)}
  <div style="flex:1;min-width:0"><div style="font-size:15px;font-weight:700">{title}</div>
    <div class="s13" style="display:flex;align-items:center;gap:6px;margin-top:2px">{square(group, 18)}<span>{'4ème année · Maths' if group == '4A' else '4ème année · Lecture'}</span><span>·</span><span>{date}</span></div></div>
  <div style="width:150px" class="s13"><span style="font-size:15px;font-weight:800;color:#1A1D3A">{done}</span> notes sur {total}</div>
  <div style="width:150px">{f'<span style="font-size:15px;font-weight:800">{avg}</span><span class="s13"> / 20</span>' if avg else '<span class="s13">—</span>'}</div>
  <div style="width:150px">{status}</div>
  {icon('chevright', 18, color='#6B7090')}
</div>'''

    rows = (row('Évaluation : la multiplication', '4A', 'mercredi 7 octobre', 4, 6, '', todo=True, first=True)
            + row('Dictée n° 2', '4L', 'lundi 5 octobre', 5, 5, '13,90'))
    return f'''<main class="page" style="max-width:1176px">
  <div style="display:flex;align-items:flex-end;gap:14px">
    <div style="flex:1"><h1 class="ptitle">Devoirs</h1><div style="font-size:15px;color:#4A4F72;margin-top:6px">Les devoirs donnés, les copies à corriger et les évaluations sur papier.</div></div>
    <span class="btn secondary">{icon('clipcheck', 17)}Nouvelle évaluation</span>
    <span class="btn primary">{icon('plus', 17, 2.4)}Nouveau devoir</span>
  </div>
  {tabs('Évaluations')}
  <section class="card" style="padding:8px 24px">{rows}</section>
</main>'''


def new_panel():
    seg = lambda items, on: '<div class="seg">' + ''.join(f'<span class="{"on" if i == on else ""}">{t}</span>' for i, t in enumerate(items)) + '</div>'  # noqa: E731
    return f'''<div class="scrim"></div>
<div class="panel">
  <div class="panel-h">{badge('clipcheck', 'violet', 44, 14, 20)}<div style="flex:1"><div style="font-size:20px;font-weight:800">Nouvelle évaluation</div>
    <div class="s13">Un contrôle fait en classe, sur papier : vous saisissez les notes du groupe ensuite.</div></div>{icon('x', 22, color='#6B7090')}</div>
  <div class="panel-b" style="gap:16px">
    <div class="field"><label>Groupe</label>
      <div class="input" style="justify-content:space-between"><span style="display:flex;align-items:center;gap:10px">{square('4A')}4ème année · Maths · 6 élèves</span>{icon('chevdown', 18, color='#6B7090')}</div></div>
    <div class="field"><label>Titre</label><div class="input focus">Évaluation : la multiplication</div><div class="hint">Les élèves et les parents voient ce titre avec la note.</div></div>
    <div style="display:flex;gap:12px">
      <div class="field" style="flex:1"><label>Date</label><div class="input" style="justify-content:space-between">Mer. 7 oct. 2026{icon('calendar', 18, color='#6B7090')}</div></div>
      <div class="field" style="flex:1"><label>Noté sur</label>{seg(['10', '20', 'Autre'], 1)}</div>
    </div>
    <div class="field"><label>Chapitre <span class="s13" style="font-weight:500">· facultatif</span></label>
      <div class="input" style="justify-content:space-between">La multiplication{icon('chevdown', 18, color='#6B7090')}</div></div>
    <div class="note">{icon('info', 16, color='#2B3990', style='margin-top:2px')}<span>La note compte dans la moyenne de la matière comme celle d'un devoir. Une note sur 10 est ramenée sur 20 dans la moyenne.</span></div>
  </div>
  <div class="panel-f"><span class="btn ghost">Annuler</span><span class="btn primary">{icon('keyboard', 17)}Créer et saisir les notes</span></div>
</div>'''


def scores_page():
    def tile(label, value, accent, suffix=''):
        strong = common.ACCENTS[accent][0]
        return (f'<div style="flex:1;padding:16px 18px;border-radius:20px;background:#fff;border:1px solid #E6E8F0;display:flex;align-items:center;gap:14px">'
                f'<span style="width:12px;height:40px;border-radius:6px;background:{strong}"></span>'
                f'<div><div style="font-size:28px;font-weight:800;line-height:1">{value}<span style="font-size:15px;color:#6B7090;font-weight:700">{suffix}</span></div><div class="s13" style="margin-top:4px">{label}</div></div></div>')

    def row(initials, accent, name, score, absent, comment, focus=False, first=False):
        invalid = score == '21'
        if absent:
            field = '<div class="input" style="width:96px;height:44px;justify-content:center;background:#F1F3F5;color:#868E96;font-weight:700">Absent</div>'
        else:
            border = 'border:1.5px solid #E03131;' if invalid else ('border:1.5px solid #2B3990;box-shadow:0 0 0 4px #EEF0FA;' if focus else '')
            field = (f'<div class="input" style="width:96px;height:44px;justify-content:center;font-size:17px;font-weight:800;background:#fff;{border}">{score or ""}'
                     f'{"<span style=\"width:2px;height:20px;background:#2B3990;margin-inline-start:2px\"></span>" if focus else ""}</div>')
        error = '<div style="font-size:12px;color:#B42525;font-weight:600;margin-top:4px">Au plus 20.</div>' if invalid else ''
        box = (f'<span style="color:#2B3990;display:flex">{icon("checksquare", 22)}</span>' if absent
               else '<span style="width:20px;height:20px;border-radius:6px;border:1.5px solid #ADB1C6;display:inline-block"></span>')
        com = (f'<div class="input" style="height:44px;font-size:14px;background:#fff">{comment}</div>' if comment
               else '<div class="input" style="height:44px;font-size:14px;color:#ADB1C6;background:#fff">Un mot pour l\'élève (facultatif)</div>')
        return f'''<div class="row" style="padding:10px 0;align-items:flex-start;{"border-top:none" if first else ""}{"background:#FAFBFF;" if focus else ""}">
  <div style="padding-top:2px">{avatar(initials, accent)}</div><div style="width:220px;font-size:15px;font-weight:700;padding-top:11px">{name}</div>
  <div style="width:150px;display:flex;flex-direction:column"><div style="display:flex;align-items:center;gap:8px">{field}<span class="s13" style="font-weight:700">/ 20</span></div>{error}</div>
  <div style="width:90px;display:flex;justify-content:center;padding-top:11px">{box}</div>
  <div style="flex:1">{com}</div>
</div>'''

    rows = ''.join(row(*p, focus=(p[2] == 'Omar Saidi'), first=(i == 0)) for i, p in enumerate(PUPILS))
    return f'''<main class="page" style="max-width:1176px">
  <div style="display:flex;align-items:center;gap:8px" class="s13"><span>Devoirs</span>{icon('chevright', 14)}<span>Évaluations</span></div>
  <div style="display:flex;align-items:flex-start;gap:14px">
    {badge('clipcheck', 'violet', 52, 16, 24)}
    <div style="flex:1"><h1 class="ptitle" style="font-size:30px">Évaluation : la multiplication</h1>
      <div style="display:flex;align-items:center;gap:8px;margin-top:8px;font-size:14px;color:#4A4F72">{square('4A', 22)}<span>4ème année · Maths</span><span>·</span>{icon('calendar', 16)}<span>Mercredi 7 octobre</span><span>·</span><span>Sur 20</span><span>·</span><span>La multiplication</span></div></div>
    <span class="btn secondary">{icon('pencil', 16)}Modifier</span>
    <span class="btn primary">{icon('check', 17, 2.4)}Enregistrer les notes</span>
  </div>
  <div style="display:flex;gap:12px">{tile('Notes saisies', '4', 'violet', ' sur 6')}{tile('Moyenne du groupe', '14,50', 'green', ' / 20')}{tile('Absent', '1', 'grey')}{tile('À saisir', '1', 'amber')}</div>
  <section class="card" style="padding:8px 24px">
    <div style="display:flex;gap:14px;padding:14px 0 10px;border-bottom:1px solid #F0F1F6" class="cap">
      <span style="width:40px"></span><span style="width:220px">ÉLÈVE</span><span style="width:150px">NOTE</span><span style="width:90px;text-align:center">ABSENT</span><span style="flex:1">COMMENTAIRE</span>
    </div>
    {rows}
  </section>
  <div style="display:flex;gap:12px">
    <div class="note" style="flex:1">{icon('keyboard', 16, color='#2B3990', style='margin-top:2px')}<span><b>Tab</b> passe à l'élève suivant, <b>Maj + Tab</b> revient, <b>Entrée</b> enregistre. Les demi-points s'écrivent 11,5.</span></div>
    <div class="note" style="flex:1">{icon('info', 16, color='#2B3990', style='margin-top:2px')}<span>« Absent » ne compte jamais comme 0. À l'enregistrement, les élèves et leurs parents voient leur note et le commentaire.</span></div>
  </div>
</main>'''


# ── Phones ──

PUPIL_NAV = [('house', 'Accueil'), ('book', 'Cours'), ('clipboard', 'Devoirs'), ('calendar', 'Planning'), ('chart', 'Résultats')]


def teacher_phone():
    def card(initials, accent, name, score, absent, focus=False):
        field = ('<div class="input" style="width:84px;height:48px;justify-content:center;background:#F1F3F5;color:#868E96;font-weight:700;font-size:14px">Absent</div>' if absent else
                 f'<div class="input" style="width:84px;height:48px;justify-content:center;font-size:20px;font-weight:800;background:#fff;{"border:1.5px solid #2B3990;box-shadow:0 0 0 4px #EEF0FA" if focus else ""}">{score}</div>')
        toggle = (f'<span class="chip" style="background:#1A1D3A;color:#fff">Absent</span>' if absent
                  else '<span class="chip" style="background:#fff;border:1px solid #E6E8F0;color:#4A4F72">Absent</span>')
        return (f'<div style="display:flex;align-items:center;gap:10px;padding:12px;background:#fff;border:1px solid {"#2B3990" if focus else "#E6E8F0"};border-radius:18px">'
                f'{avatar(initials, accent, 36)}<div style="flex:1;min-width:0"><div style="font-size:15px;font-weight:700">{name}</div><div style="margin-top:6px">{toggle}</div></div>'
                f'{field}<span class="s13" style="font-weight:700">/20</span></div>')

    body = f'''
  <div style="display:flex;align-items:center;gap:12px;padding:16px 18px;background:#fff;border-bottom:1px solid #E6E8F0">
    <span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center">{icon('arrowleft', 20)}</span>
    <div style="flex:1;min-width:0"><div style="font-size:16px;font-weight:800">Évaluation : la multiplication</div><div class="s13">4 notes sur 6 · sur 20</div></div>
  </div>
  <div style="flex:1;overflow:hidden;padding:14px 16px;display:flex;flex-direction:column;gap:10px">
    {card('AG', 'indigo', 'Adam Gharbi', '15', False)}
    {card('AK', 'amber', 'Amine Kefi', '11,5', False)}
    {card('OS', 'turquoise', 'Omar Saidi', '', False, focus=True)}
    {card('RM', 'violet', 'Rayen Mansour', '', True)}
    {card('SB', 'blue', 'Sami Ben Salah', '17', False)}
  </div>
  <div style="display:flex;gap:6px;padding:8px 10px;background:#D1D5DB">{''.join(f'<span style="flex:1;height:40px;border-radius:8px;background:#fff;display:flex;align-items:center;justify-content:center;font-size:18px;font-weight:600">{k}</span>' for k in ['1', '2', '3', ',', 'Suivant'])}</div>
  <div style="padding:12px 18px 18px;background:#fff;border-top:1px solid #E6E8F0"><span class="btn primary" style="height:52px;justify-content:center;width:100%">{icon('check', 17, 2.4)}Enregistrer les notes</span></div>'''
    return frame(body)


def results(lang='fr'):
    fr = lang == 'fr'
    T = lambda f, a: f if fr else a  # noqa: E731

    def grade_row(title, kind, date, mark, first=False):
        tag = chip(kind, 'violet' if kind in ('Évaluation', 'تقييم') else 'blue', dot=False)
        right = (f'<div style="direction:ltr;white-space:nowrap"><span style="font-size:17px;font-weight:800">{mark}</span><span class="s13"> /20</span></div>'
                 if mark else f'<span class="chip" style="background:#F1F3F5;color:#868E96">{T("Absent", "غائب")}</span>')
        return (f'<div style="display:flex;gap:12px;align-items:center;padding:12px 0;{"" if first else "border-top:1px solid #F0F1F6"}">'
                f'<div style="flex:1;min-width:0"><div style="font-size:15px;font-weight:700"><bdi>{title}</bdi></div>'
                f'<div style="display:flex;align-items:center;gap:8px;margin-top:4px">{tag}<span class="s13">{date}</span></div></div>{right}</div>')

    card = f'''<div style="padding:16px;background:#fff;border:1px solid #E6E8F0;border-radius:20px">
    <div style="display:flex;align-items:center;gap:8px"><span style="width:10px;height:10px;border-radius:3px;background:#2B3990"></span><span class="cap" style="flex:1;letter-spacing:1px;color:#4A4F72">{T('MATHÉMATIQUES', 'الرياضيات')}</span>{chip(T('En progrès', 'في تحسّن'), 'green', dot=False)}</div>
    <div style="display:flex;align-items:baseline;gap:6px;margin-top:10px;direction:ltr;justify-content:{'flex-start' if fr else 'flex-end'}"><span style="font-size:40px;font-weight:800;letter-spacing:-1px">15,10</span><span style="font-size:16px;font-weight:700;color:#6B7090">/20</span></div>
    <div class="s13">{T('Moyenne de 5 notes', 'المعدّل من 5 أعداد')}</div>
    <div class="cap" style="margin-top:14px;font-size:11px;letter-spacing:1px">{T('NOTES', 'الأعداد')}</div>
    {grade_row('Évaluation : la multiplication', T('Évaluation', 'تقييم'), T('mercredi 7 octobre', 'الأربعاء 7 أكتوبر'), '15', True)}
    {grade_row('Série 1 : les fractions', T('Devoir', 'واجب'), T('vendredi 3 octobre', 'الجمعة 3 أكتوبر'), '14')}
    {grade_row('Dictée n° 1', T('Évaluation', 'تقييم'), T('lundi 29 septembre', 'الاثنين 29 سبتمبر'), '')}
  </div>'''
    if fr:
        return phone(f'''
    {phone_header('AG')}
    <div><div style="font-size:26px;font-weight:800;letter-spacing:-.5px">Mes résultats</div><div style="font-size:15px;color:#4A4F72;margin-top:4px">Tes notes et ton travail, matière par matière.</div></div>
    {card}''', PUPIL_NAV, 'fr', 4)
    top = f'''<div style="display:flex;align-items:center;gap:12px">
      <span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center;transform:scaleX(-1)">{icon('arrowleft', 20)}</span>
      <div style="flex:1"><div style="font-size:24px;font-weight:800">نتائج <bdi>Adam</bdi></div><div style="font-size:14px;color:#4A4F72;margin-top:2px">أعداده وعمله، مادّة بمادّة.</div></div></div>'''
    return phone(f'{top}{card}',
                 [('dashboard', 'نظرة عامة'), ('book', 'الدروس'), ('clipboard', 'الواجبات'), ('calendar', 'الجدول'), ('bell', 'الإشعارات')], 'ar', 0)


NOTES = [
    ('Où', 'Un quatrième onglet de Devoirs, « Évaluations », et « Nouvelle évaluation » à côté de « Nouveau devoir ». Aussi depuis la page d\'un groupe et le menu « Créer ».'),
    ('Créer', 'Groupe, titre, date, noté sur 10, 20 ou autre (20 par défaut), chapitre si vous voulez. « Créer et saisir les notes » ouvre le tableau.'),
    ('Saisir au clavier', 'Un tableau des élèves du groupe : la note, Tab pour le suivant, « Absent », un commentaire si vous voulez. 8 élèves en moins d\'une minute. Une note plus grande que le barème est refusée sur place.'),
    ('Sur le téléphone', 'Une carte par élève avec un grand champ de note et « Absent » ; le clavier chiffré a « Suivant ».'),
    ('Enregistrer', 'Les notes saisies sont visibles tout de suite par l\'élève et ses parents (notification « Nouvelle note »). Vous pouvez enregistrer à moitié et finir plus tard : « Notes à saisir » reste affiché.'),
    ('Dans les moyennes', 'Une évaluation compte comme un devoir dans la moyenne de la matière ; une note sur 10 est ramenée sur 20. « Absent » ne compte jamais comme 0, comme un devoir sans note.'),
    ('Résultats', 'Chaque note dit d\'où elle vient : « Évaluation » ou « Devoir ». Un absent lit « Absent », pas 0.'),
    ('Arabe', 'Même écran de droite à gauche ; la note et « /20 » restent de gauche à droite.'),
]


def phone_board():
    def column(label, content):
        return f'<div style="display:flex;flex-direction:column;gap:14px;align-items:center"><div class="cap" style="font-size:13px">{label}</div>{content}</div>'

    notes = ''.join(
        f'<div style="display:flex;gap:12px"><span style="width:26px;height:26px;border-radius:13px;background:#2B3990;color:#fff;font-size:13px;font-weight:800;display:flex;align-items:center;justify-content:center;flex-shrink:0">{i}</span>'
        f'<div><div style="font-size:15px;font-weight:800">{title}</div><div style="font-size:14px;color:#4A4F72;line-height:1.5;margin-top:2px">{text}</div></div></div>'
        for i, (title, text) in enumerate(NOTES, 1))
    body = f'''<div style="padding:48px;display:flex;flex-direction:column;gap:40px;background:#EEF0FA">
  <div style="display:flex;gap:40px;justify-content:center;align-items:flex-start">
    {column('ENSEIGNANTE · SAISIR LES NOTES', teacher_phone())}
    {column('ÉLÈVE · RÉSULTATS', results('fr'))}
    {column('PARENT · ARABE · النتائج', results('ar'))}
  </div>
  <div style="display:flex;justify-content:center">
    <div style="width:1300px;background:#fff;border:1px solid #E6E8F0;border-radius:24px;padding:26px;display:grid;grid-template-columns:1fr 1fr;gap:16px 32px">
      <div style="grid-column:1 / -1"><div style="font-size:22px;font-weight:800">Évaluations sur papier, étape 5</div>
      <div style="font-size:14px;color:#6B7090;line-height:1.5;margin-top:4px">Spec 06 « Évaluations » et 07 (notes). Données inventées, mercredi 7 octobre.</div></div>
      {notes}
    </div>
  </div>
</div>'''
    return page('Évaluations sur téléphone', body, width=1440, height=1600)


if __name__ == '__main__':
    (OUT / 'NouvelleEvaluation.html').write_text(teacher('Nouvelle évaluation', 'Devoirs', list_page(), overlay=new_panel()))
    (OUT / 'Evaluation.html').write_text(teacher('Évaluation', 'Devoirs', scores_page(), height=1000))
    (OUT / 'EvaluationPhone.html').write_text(phone_board())
    print('NouvelleEvaluation, Evaluation, EvaluationPhone')
