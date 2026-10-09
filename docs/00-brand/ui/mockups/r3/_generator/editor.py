"""Release 3 (user decisions 2026-10-09): a Word-like page to write series and lessons, and the quiz builder (5 types)."""
from pathlib import Path

from builders import KATEX, screen  # noqa: F401  (puts the R1 and R2 generators on the path)

import common  # noqa: E402
from common import ACCENTS, avatar, badge, chip, icon, page  # noqa: E402
from scan import frame  # noqa: E402

OUT = Path(__file__).resolve().parents[1]

common.ICONS.update({
    'undo': '<path d="M3 7v6h6"/><path d="M21 17a9 9 0 0 0-9-9 9 9 0 0 0-6 2.3L3 13"/>',
    'redo': '<path d="M21 7v6h-6"/><path d="M3 17a9 9 0 0 1 9-9 9 9 0 0 1 6 2.3l3 2.7"/>',
    'bold': '<path d="M6 12h9a4 4 0 0 1 0 8H7a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1h7a4 4 0 0 1 0 8"/>',
    'italic': '<path d="M19 4h-9M14 20H5M15 4 9 20"/>',
    'underline': '<path d="M6 4v6a6 6 0 0 0 12 0V4M4 20h16"/>',
    'highlight': '<path d="m9 11-6 6v3h9l3-3"/><path d="m22 12-4.6 4.6a2 2 0 0 1-2.8 0l-5.2-5.2a2 2 0 0 1 0-2.8L14 4"/>',
    'alignstart': '<path d="M21 6H3M15 12H3M17 18H3"/>',
    'aligncenter': '<path d="M21 6H3M17 12H7M19 18H5"/>',
    'alignend': '<path d="M21 6H3M21 12H9M21 18H7"/>',
    'list': '<path d="M3 12h.01M3 18h.01M3 6h.01M8 12h13M8 18h13M8 6h13"/>',
    'listnum': '<path d="M10 12h11M10 18h11M10 6h11M4 10h2M4 6h1v4M6 18H4c0-1 2-2 2-3s-1-1.5-2-1"/>',
    'table': '<rect width="18" height="18" x="3" y="3" rx="2"/><path d="M3 9h18M3 15h18M9 3v18M15 3v18"/>',
    'lines': '<path d="M4 8h16M4 12h16M4 16h16"/><path d="M4 20h10" stroke-dasharray="2 2"/>',
    'minus': '<path d="M5 12h14"/>',
    'timer': '<path d="M10 2h4M12 14l3-3"/><circle cx="12" cy="14" r="8"/>',
    'listchecks': '<path d="m3 17 2 2 4-4M3 7l2 2 4-4M13 6h8M13 12h8M13 18h8"/>',
    'toggle': '<rect width="20" height="12" x="2" y="6" rx="6"/><circle cx="16" cy="12" r="2"/>',
    'textcursor': '<path d="M17 22h-1a4 4 0 0 1-4-4V6a4 4 0 0 1 4-4h1M7 22h1a4 4 0 0 0 4-4v-1M7 2h1a4 4 0 0 1 4 4v1"/>',
    'brackets': '<path d="M16 3h3v18h-3M8 21H5V3h3"/>',
    'message': '<path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"/>',
    'checkcircle': '<path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><path d="m9 11 3 3L22 4"/>',
    'xcircle': '<circle cx="12" cy="12" r="10"/><path d="m15 9-6 6M9 9l6 6"/>',
    'zap': '<path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"/>',
    'image': '<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="9" cy="9" r="2"/><path d="m21 15-3.09-3.09a2 2 0 0 0-2.82 0L6 21"/>',
    'eye': '<path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/>',
    'check2': '<path d="M20 6 9 17l-5-5"/>',
    'layers': '<path d="m12.83 2.18a2 2 0 0 0-1.66 0L2.6 6.08a1 1 0 0 0 0 1.83l8.58 3.91a2 2 0 0 0 1.66 0l8.58-3.9a1 1 0 0 0 0-1.83Z"/><path d="m22 17.65-9.17 4.16a2 2 0 0 1-1.66 0L2 17.65M22 12.65l-9.17 4.16a2 2 0 0 1-1.66 0L2 12.65"/>',
    'grip': '<circle cx="9" cy="6" r="1"/><circle cx="9" cy="12" r="1"/><circle cx="9" cy="18" r="1"/><circle cx="15" cy="6" r="1"/><circle cx="15" cy="12" r="1"/><circle cx="15" cy="18" r="1"/>',
    'more': '<circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/>',
    'copy': '<rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/>',
})


def tool(content, on=False, wide=False):
    style = 'background:#EEF0FA;color:#2B3990;' if on else 'color:#1A1D3A;'
    return (f'<span style="min-width:{58 if wide else 34}px;height:34px;padding:0 6px;border-radius:9px;{style}display:flex;align-items:center;justify-content:center;gap:4px;font-size:13px;font-weight:700">{content}</span>')


def sep():
    return '<span style="width:1px;height:22px;background:#E6E8F0;margin:0 4px"></span>'


def toolbar(compact=False):
    frame_style = 'padding:4px;background:#F6F7FB;border-radius:12px' if compact else 'padding:8px 10px;background:#fff;border:1px solid #E6E8F0;border-radius:16px;box-shadow:0 4px 14px rgba(28,37,102,.06)'
    color_a = tool("<span style='border-bottom:3px solid #2B3990;line-height:1'>A</span>")
    parts = []
    if not compact:
        parts += [tool(icon('undo', 17)), tool(icon('redo', 17)), sep(),
                  tool('Titre 2 ' + icon('chevdown', 14), wide=True), tool('16 ' + icon('chevdown', 14), wide=True), sep()]
    parts += [tool(icon('bold', 17), on=True), tool(icon('italic', 17)), tool(icon('underline', 17)), color_a, tool(icon('highlight', 17)), sep()]
    if not compact:
        parts += [tool(icon('alignstart', 17), on=True), tool(icon('aligncenter', 17)), tool(icon('alignend', 17)), sep()]
    parts += [tool(icon('list', 17)), tool(icon('listnum', 17)), sep(), tool(icon('table', 17)), tool(icon('image', 17))]
    if not compact:
        parts.append(tool(icon('lines', 17)))
    parts.append('<span style="margin-inline-start:6px;height:34px;padding:0 12px;border-radius:9px;background:#2B3990;color:#fff;display:flex;'
                 'align-items:center;gap:6px;font-size:13px;font-weight:800"><i style="font-family:serif">ƒx</i> Formule</span>')
    return f'<div style="display:flex;align-items:center;gap:2px;flex-wrap:wrap;{frame_style}">{"".join(parts)}</div>'


def answer_lines(n=1):
    if n == 1:
        return '<span style="display:inline-block;width:180px;border-bottom:1.5px dotted #ADB1C6;vertical-align:-4px"></span>'
    return ''.join('<div style="height:26px;border-bottom:1.5px dotted #ADB1C6"></div>' for _ in range(n))


def a4_page(selected=True):
    formula_pop = '''<div style="position:absolute;top:118px;inset-inline-start:410px;width:330px;background:#fff;border:1px solid #E6E8F0;border-radius:16px;box-shadow:0 18px 40px rgba(28,37,102,.18);padding:14px;display:flex;flex-direction:column;gap:10px;z-index:3">
      <div style="display:flex;align-items:center;gap:8px"><i style="font-family:serif;font-weight:800;color:#2B3990">ƒx</i><b style="font-size:14px">Formule</b><span style="flex:1"></span><span class="s13">Échap pour fermer</span></div>
      <div class="input focus src" style="min-height:42px">3/4 + 1/2<span style="display:inline-block;width:1.5px;height:17px;background:#2B3990;vertical-align:middle"></span></div>
      <div style="display:flex;gap:4px;flex-wrap:wrap">''' + ''.join(
        f'<span style="min-width:32px;height:30px;border:1px solid #E6E8F0;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:12px">{t}</span>'
        for t in ['$\\frac{a}{b}$', '$x^n$', '$\\sqrt{x}$', '$\\times$', '$\\div$', '$\\le$', '$\\ge$', '$\\ne$', '$\\pi$', '$^\\circ$']) + '''</div>
      <div style="padding:8px 10px;border-radius:10px;background:#F6F7FB;font-size:16px;text-align:center">$\\dfrac{3}{4} + \\dfrac{1}{2}$</div>
      <div style="display:flex;justify-content:flex-end;gap:8px"><span class="btn ghost sm">Annuler</span><span class="btn primary sm">Insérer</span></div>
    </div>''' if selected else ''
    table = '''<table style="border-collapse:collapse;margin:6px 0 4px;font-size:14px">
      <tr>''' + ''.join(f'<th style="border:1px solid #B8BCD3;padding:6px 14px;background:#F1F3FA">{h}</th>' for h in ['Fraction', '$\\dfrac{3}{5}$', '$\\dfrac{4}{7}$', '$\\dfrac{2}{3}$']) + '''</tr>
      <tr>''' + ''.join(f'<td style="border:1px solid #B8BCD3;padding:10px 14px;text-align:center;color:#ADB1C6">{c}</td>' for c in ['Plus grande que $\\frac{1}{2}$ ?', '', '', '']) + '''</tr></table>'''
    return f'''<div style="position:relative;width:640px;margin:0 auto;background:#fff;box-shadow:0 10px 30px rgba(28,37,102,.14);border-radius:4px;padding:44px 52px 60px;font-size:15px;line-height:1.7">
  <div style="display:flex;align-items:center;gap:10px;border-bottom:2px solid #2B3990;padding-bottom:8px;margin-bottom:6px"><img src="../ng-symbol.png" style="height:20px" alt="">
    <div style="flex:1;text-align:center;font-size:19px;font-weight:800">Série 3 : les fractions</div><span class="s13">4ème année</span></div>
  <div class="s13" style="margin-bottom:14px">Nom et prénom : ................................................................</div>
  <div style="font-weight:800;color:#2B3990;font-size:16px">Exercice 1 <span style="color:#6B7090;font-weight:600;font-size:13px">(4 points)</span></div>
  <div>Calcule et simplifie :</div>
  <ol type="a" style="margin:4px 0;padding-inline-start:22px">
    <li><span style="background:#EEF0FA;outline:1.5px solid #2B3990;border-radius:5px;padding:4px 6px">$\\dfrac{{3}}{{4}} + \\dfrac{{1}}{{2}}$</span> = {answer_lines()}</li>
    <li>$\\dfrac{{5}}{{6}} - \\dfrac{{1}}{{3}}$ = {answer_lines()}</li>
  </ol>
  <div style="font-weight:800;color:#2B3990;font-size:16px;margin-top:8px">Exercice 2 <span style="color:#6B7090;font-weight:600;font-size:13px">(4 points)</span></div>
  <div>Complète le tableau par <b>oui</b> ou <b>non</b>.</div>
  {table}
  <div style="font-weight:800;color:#2B3990;font-size:16px;margin-top:8px">Exercice 3 <span style="color:#6B7090;font-weight:600;font-size:13px">(4 points)</span></div>
  <div style="display:flex;gap:16px;align-items:flex-start"><div style="flex:1">Ahmed a mangé $\\dfrac{{2}}{{8}}$ de la pizza et Lina $\\dfrac{{3}}{{8}}$. <span style="background:#FFF4DC">Quelle fraction reste-t-il ?</span>{answer_lines(2)}</div>
    <div style="width:120px;height:120px;border-radius:60px;background:conic-gradient(#FFB020 0 25%,#E8590C 25% 62.5%,#F6F7FB 62.5%);border:3px solid #E6E8F0"></div></div>
  {formula_pop}
</div>'''


def editor_page():
    tabs = '<div class="tabs"><span class="on">Série</span><span>Corrigé <i class="s13" style="font-style:normal;font-weight:600">· visible par vous seule</i></span></div>'
    return f'''<main class="page" style="max-width:1240px;gap:16px">
  <div class="s13" style="color:#2B3990;font-weight:700;display:flex;align-items:center;gap:6px">{icon('arrowleft', 16)}Contenus</div>
  <div style="display:flex;align-items:center;gap:14px;flex-wrap:wrap">
    {badge('layers', 'turquoise', 48, 14, 22)}
    <div style="flex:1;min-width:280px"><div style="font-size:28px;font-weight:800;letter-spacing:-.5px">Série 3 : les fractions</div>
      <div style="display:flex;gap:8px;align-items:center;margin-top:4px">{chip('Brouillon', 'grey')}<span class="s13">Mathématiques · 4ème année · Les fractions · Série · enregistré à l'instant</span></div></div>
    <span class="btn secondary">{icon('eye', 17)}Aperçu élève</span>
    <span class="btn primary">{icon('check2', 17)}Publier</span>
  </div>
  <div style="display:flex;align-items:center;gap:12px">{tabs}<span style="flex:1"></span><span class="s13">3 pages · A4</span></div>
  <div style="position:sticky;top:0;z-index:4">{toolbar()}</div>
  <div style="background:#E9EBF3;border-radius:20px;padding:26px 0">{a4_page()}</div>
</main>'''


# ── The quiz builder ──

TYPES = {'qcm': ('listchecks', 'indigo', 'Choix multiple'), 'vf': ('toggle', 'turquoise', 'Vrai / Faux'), 'short': ('textcursor', 'amber', 'Réponse courte'),
         'gaps': ('brackets', 'violet', 'Texte à trous'), 'open': ('message', 'orange', 'Question ouverte')}


def qhead(n, kind, points):
    ic, acc, label = TYPES[kind]
    return (f'<div style="display:flex;align-items:center;gap:10px"><span style="color:#ADB1C6">{icon("grip", 18)}</span>'
            f'<span style="width:28px;height:28px;border-radius:9px;background:#EEF0FA;color:#2B3990;font-weight:800;font-size:13px;display:flex;align-items:center;justify-content:center">{n}</span>'
            f'{badge(ic, acc, 28, 8, 15)}<b style="font-size:14px">{label}</b><span style="flex:1"></span>'
            f'<span class="chip" style="background:#F1F3F5;color:#4A4F72">{points} pt{"s" if points > 1 else ""}</span>{icon("more", 18, color="#6B7090")}</div>')


def choice(text, correct):
    mark = (f'<span style="width:22px;height:22px;border-radius:11px;background:#2F9E44;color:#fff;display:flex;align-items:center;justify-content:center">{icon("check2", 14, 3)}</span>'
            if correct else '<span style="width:22px;height:22px;border-radius:11px;border:2px solid #CDD0DE"></span>')
    bg = 'background:#E7F6EA;border-color:#C7E9CF;' if correct else ''
    return f'<div style="display:flex;align-items:center;gap:10px;padding:8px 12px;border:1px solid #E6E8F0;border-radius:12px;{bg}">{mark}<span style="font-size:15px">{text}</span></div>'


def question_card(body, active=False):
    border = 'border:1.5px solid #2B3990;box-shadow:0 6px 18px rgba(43,57,144,.10);' if active else 'border:1px solid #E6E8F0;'
    return f'<div style="background:#fff;{border}border-radius:18px;padding:14px 16px;display:flex;flex-direction:column;gap:10px">{body}</div>'


def quiz_page():
    seg = lambda items, on: '<div class="seg">' + ''.join(f'<span class="{"on" if i == on else ""}" style="font-size:13px">{t}</span>' for i, t in enumerate(items)) + '</div>'  # noqa: E731
    settings = f'''<section class="card" style="display:flex;flex-direction:column;gap:14px">
    <div style="font-size:17px;font-weight:800">Réglages</div>
    <div class="field"><label>Chapitre</label><div class="input" style="justify-content:space-between">Maths · 4ème année · Les fractions{icon('chevdown', 18, color='#6B7090')}</div></div>
    <div class="field"><label>Durée</label>{seg(['Sans limite', '15 min', 'Autre'], 1)}</div>
    <div style="display:flex;gap:10px"><div class="field" style="flex:1"><label>Tentatives</label><div class="input">1</div></div>
      <div class="field" style="flex:1.4"><label>Note retenue</label><div class="input" style="justify-content:space-between;color:#ADB1C6">La meilleure{icon('chevdown', 16, color='#CDD0DE')}</div></div></div>
    <div class="field"><label>Montrer les réponses</label>{seg(['Après la date', 'Tout de suite', 'Jamais'], 0)}</div>
    <div style="display:flex;align-items:center;gap:10px"><span style="width:42px;height:24px;border-radius:12px;background:#CDD0DE;position:relative;flex-shrink:0"><span style="position:absolute;top:3px;inset-inline-start:3px;width:18px;height:18px;border-radius:9px;background:#fff"></span></span><span style="font-size:14px;font-weight:600">Questions dans le désordre</span></div>
    <div style="display:flex;gap:10px;padding:12px;border-radius:14px;background:#F6F7FB"><div style="flex:1"><div style="font-size:22px;font-weight:800">5</div><div class="s13">questions</div></div><div style="flex:1"><div style="font-size:22px;font-weight:800">10</div><div class="s13">points</div></div><div style="flex:1.4"><div style="font-size:22px;font-weight:800">4</div><div class="s13">corrigées seules</div></div></div>
  </section>'''
    q1 = question_card(qhead(1, 'qcm', 2) + toolbar(compact=True) + '''<div style="font-size:16px">Quelle fraction est égale à $\\dfrac{1}{2}$ ?</div>''' +
                       choice('$\\dfrac{2}{4}$', True) + choice('$\\dfrac{2}{3}$', False) + choice('$\\dfrac{3}{4}$', False) +
                       '<div class="s13" style="display:flex;gap:14px"><span style="color:#2B3990;font-weight:700">+ Ajouter un choix</span><span>Cliquez le rond de la bonne réponse.</span></div>', active=True)
    q2 = question_card(qhead(2, 'vf', 1) + '<div style="font-size:16px;display:flex;align-items:center;gap:14px"><span style="flex:1">$\\dfrac{3}{5} > \\dfrac{4}{7}$</span>'
                       + chip('Vrai', 'green', dot=False) + '<span class="chip" style="background:#fff;border:1px solid #E6E8F0;color:#6B7090">Faux</span></div>')
    q3 = question_card(qhead(3, 'short', 2) + '<div style="font-size:16px">Calcule $\\dfrac{3}{4} + \\dfrac{1}{4}$.</div>'
                       + '<div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap"><span class="s13">Réponses acceptées :</span>'
                       + ''.join(f'<span class="chip" style="background:#E7F6EA;color:#237A35">{a}</span>' for a in ['1', '4/4', '1,0']) + '<span class="s13" style="color:#2B3990;font-weight:700">+ une autre</span></div>')
    q4 = question_card(qhead(4, 'gaps', 2) + '<div style="font-size:16px;line-height:1.9">Dans la fraction $\\dfrac{3}{4}$, 3 est le '
                       '<span style="background:#F1ECFD;color:#5B34D6;border-radius:6px;padding:2px 8px;font-weight:700">numérateur</span> et 4 le '
                       '<span style="background:#F1ECFD;color:#5B34D6;border-radius:6px;padding:2px 8px;font-weight:700">dénominateur</span>.</div>'
                       '<div class="s13">Sélectionnez un mot puis « Trou » : les élèves le tapent. 1 point par trou.</div>')
    q5 = question_card(qhead(5, 'open', 3) + '<div style="font-size:16px">Explique comment tu compares deux fractions.</div>'
                       + '<div class="s13" style="display:flex;align-items:center;gap:6px">' + icon('message', 15) + 'Vous la corrigez dans « À corriger » ; le reste est corrigé tout seul.</div>')
    add = ('<div style="display:flex;gap:8px;flex-wrap:wrap;padding:12px;border:1.5px dashed #C9CEEC;border-radius:16px;background:#FBFBFE">'
           + ''.join(f'<span class="btn secondary sm">{badge(ic, acc, 22, 6, 13)}{label}</span>' for ic, acc, label in TYPES.values()) + '</div>')
    return f'''<main class="page" style="max-width:1240px;gap:16px">
  <div class="s13" style="color:#2B3990;font-weight:700;display:flex;align-items:center;gap:6px">{icon('arrowleft', 16)}Contenus</div>
  <div style="display:flex;align-items:center;gap:14px;flex-wrap:wrap">
    {badge('listchecks', 'violet', 48, 14, 22)}
    <div style="flex:1;min-width:280px"><div style="font-size:28px;font-weight:800;letter-spacing:-.5px">Quiz : les fractions</div>
      <div style="display:flex;gap:8px;align-items:center;margin-top:4px">{chip('Brouillon', 'grey')}<span class="s13">enregistré à l'instant</span></div></div>
    <span class="btn secondary">{icon('zap', 17)}Saisie rapide QCM</span>
    <span class="btn secondary">{icon('eye', 17)}Aperçu élève</span>
    <span class="btn primary">{icon('check2', 17)}Publier</span>
  </div>
  <div style="display:flex;gap:24px;align-items:flex-start">
    <div style="flex:4">{settings}</div>
    <div style="flex:8;display:flex;flex-direction:column;gap:12px">{q1}{q2}{q3}{q4}{q5}{add}</div>
  </div>
</main>'''


def quick_entry():
    """Saisie rapide QCM: type, Enter, next. The first line is the question, each next line a choice."""
    def block(n, question, choices, right, typing=False):
        lines = ''.join(
            f'<div style="display:flex;align-items:center;gap:10px;padding:5px 0">'
            + (f'<span style="width:20px;height:20px;border-radius:10px;background:#2F9E44;color:#fff;display:flex;align-items:center;justify-content:center">{icon("check2", 12, 3)}</span>'
               if i == right else '<span style="width:20px;height:20px;border-radius:10px;border:2px solid #CDD0DE"></span>')
            + f'<span style="font-size:15px">{c}</span></div>' for i, c in enumerate(choices))
        cursor = '<span style="display:inline-block;width:1.5px;height:17px;background:#2B3990;vertical-align:middle"></span>' if typing else ''
        return (f'<div style="padding:12px 14px;border:{"1.5px solid #2B3990" if typing else "1px solid #E6E8F0"};border-radius:16px;background:#fff">'
                f'<div style="display:flex;gap:8px;align-items:baseline"><b style="color:#2B3990">{n}.</b><span style="font-size:15px;font-weight:600">{question}</span></div>'
                f'<div style="padding-inline-start:20px;margin-top:4px">{lines}{cursor}</div></div>')
    return f'''<div class="scrim" style="bottom:auto;height:1000px"></div>
<div class="panel" style="width:560px;bottom:auto;height:1000px">
  <div class="panel-h">{badge('zap', 'indigo', 44, 14, 20)}<div style="flex:1"><div style="font-size:20px;font-weight:800">Saisie rapide QCM</div>
    <div class="s13">Une ligne pour la question, puis une ligne par choix. Entrée deux fois : question suivante.</div></div>{icon('x', 22, color='#6B7090')}</div>
  <div class="panel-b" style="gap:12px">
    {block(6, 'Quel est le plus grand nombre ?', ['$\\dfrac{1}{3}$', '$\\dfrac{1}{2}$', '$\\dfrac{1}{4}$'], 1)}
    {block(7, 'Combien de quarts dans une unité ?', ['2', '3', '4'], 2)}
    {block(8, '$\\dfrac{6}{8}$ est égale à :', ['$\\dfrac{3}{4}$', '$\\dfrac{2}{3}$'], 0, typing=True)}
    <div class="s13" style="display:flex;gap:8px;align-items:center">{icon('info', 15)}Cliquez le rond de la bonne réponse. 3/4 tapé devient une fraction ; après l'ajout, chaque question garde son ruban (ƒx, images).</div>
    <div style="display:flex;gap:10px;padding:12px;border-radius:14px;background:#F6F7FB"><div style="flex:1"><b>3</b> <span class="s13">questions prêtes</span></div><div style="flex:1"><b>1 point</b> <span class="s13">chacune · modifiable</span></div></div>
  </div>
  <div class="panel-f"><span class="btn ghost">Annuler</span><span class="btn primary">{icon('plus', 17)}Ajouter 3 questions</span></div>
</div>'''


# ── Phones ──

def pupil_question(lang='fr'):
    fr = lang == 'fr'
    T = lambda f, a: f if fr else a  # noqa: E731
    arrow = f'<span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center;{"" if fr else "transform:scaleX(-1)"}">{icon("x", 20)}</span>'
    dots = ''.join(f'<span style="flex:1;height:6px;border-radius:3px;background:{"#2B3990" if i < 2 else ("#9AA3D9" if i == 2 else "#E6E8F0")}"></span>' for i in range(5))
    big = lambda t, on=False: (f'<div style="display:flex;align-items:center;gap:12px;padding:16px;border-radius:18px;background:#fff;border:{"2px solid #2B3990" if on else "1px solid #E6E8F0"};font-size:20px">'  # noqa: E731
                               f'<span style="width:24px;height:24px;border-radius:12px;{"background:#2B3990;box-shadow:inset 0 0 0 5px #fff;border:2px solid #2B3990" if on else "border:2px solid #CDD0DE"}"></span><span dir="ltr">{t}</span></div>')
    body = f'''
  <div style="display:flex;align-items:center;gap:12px;padding:14px 16px;background:#fff;border-bottom:1px solid #E6E8F0">{arrow}
    <div style="flex:1"><div style="font-size:16px;font-weight:800">{T('Quiz : les fractions', 'اختبار: الكسور')}</div><div class="s13">{T('Question 3 sur 5', 'السؤال 3 من 5')}</div></div>
    <span class="chip" style="background:#FFF4DC;color:#9A6300;font-size:13px">{icon('timer', 14)}<span dir="ltr">11:42</span></span></div>
  <div style="padding:12px 16px 0;display:flex;gap:5px">{dots}</div>
  <div style="flex:1;padding:18px 16px;display:flex;flex-direction:column;gap:12px">
    <div class="cap">{T('CHOIX MULTIPLE · 2 POINTS', 'اختيار من متعدّد · نقطتان')}</div>
    <div style="font-size:20px;font-weight:700;line-height:1.6">{T('Quelle fraction est égale à', 'أيّ كسر يساوي')} <span dir="ltr">$\\dfrac{{1}}{{2}}$</span> {T('?', '؟')}</div>
    {big('$\\dfrac{2}{4}$', True)}{big('$\\dfrac{2}{3}$')}{big('$\\dfrac{3}{4}$')}
    <div class="s13" style="display:flex;align-items:center;gap:6px;margin-top:4px">{icon('check2', 14, color='#237A35')}{T('Réponse enregistrée', 'تمّ حفظ الإجابة')}</div>
  </div>
  <div style="display:flex;gap:10px;padding:12px 16px 16px;background:#fff;border-top:1px solid #E6E8F0">
    <span class="btn secondary" style="height:52px;flex:1;justify-content:center">{T('Précédente', 'السابق')}</span><span class="btn primary" style="height:52px;flex:1.4;justify-content:center">{T('Suivante', 'التالي')}</span></div>'''
    return frame(body.replace('{{', '{').replace('}}', '}'), lang)


def pupil_result():
    def row(n, ok, text, extra=''):
        mark = icon('checkcircle', 20, color='#2F9E44') if ok else icon('xcircle', 20, color='#E03131')
        return (f'<div style="display:flex;gap:10px;padding:12px 0;border-top:1px solid #F0F1F6">{mark}<div style="flex:1"><div style="font-size:15px;line-height:1.6"><b>{n}.</b> {text}</div>{extra}</div></div>')
    body = f'''
  <div style="display:flex;align-items:center;gap:12px;padding:14px 16px;background:#fff;border-bottom:1px solid #E6E8F0"><span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center">{icon('arrowleft', 20)}</span>
    <div style="flex:1"><div style="font-size:16px;font-weight:800">Quiz : les fractions</div><div class="s13">Envoyé jeudi 9 octobre à 10:12</div></div></div>
  <div style="flex:1;overflow:hidden;padding:14px 16px;display:flex;flex-direction:column;gap:12px">
    <div style="display:flex;align-items:center;gap:14px;padding:16px;border-radius:20px;background:#fff;border:1px solid #E6E8F0">
      <div style="width:88px;height:88px;border-radius:22px;background:#F1ECFD;display:flex;flex-direction:column;align-items:center;justify-content:center;direction:ltr"><span style="font-size:32px;font-weight:800;color:#5B34D6;line-height:1">6</span><span style="font-size:13px;font-weight:700;color:#5B34D6">/ 7</span></div>
      <div style="flex:1"><div style="font-size:17px;font-weight:800">Bien joué, Adam !</div><div class="s13">La question 5 attend la correction de l\'enseignante (3 points).</div></div></div>
    <div style="padding:4px 14px;border-radius:18px;background:#fff;border:1px solid #E6E8F0">
      {row(1, True, 'Quelle fraction est égale à $\\dfrac{1}{2}$ ? <b>$\\dfrac{2}{4}$</b>')}
      {row(2, False, '$\\dfrac{3}{5} > \\dfrac{4}{7}$ : tu as répondu <b>Faux</b>.', '<div style="font-size:13px;color:#237A35;font-weight:600">Bonne réponse : Vrai. $\\dfrac{3}{5} = \\dfrac{21}{35}$ et $\\dfrac{4}{7} = \\dfrac{20}{35}$.</div>')}
      {row(3, True, 'Calcule $\\dfrac{3}{4} + \\dfrac{1}{4}$ : <b>1</b>')}
      {row(4, True, 'Dans $\\dfrac{3}{4}$, 3 est le <b>numérateur</b> et 4 le <b>dénominateur</b>.')}
      <div style="display:flex;gap:10px;padding:12px 0;border-top:1px solid #F0F1F6">{icon('clock', 20, color='#9A6300')}<div style="flex:1"><div style="font-size:15px;line-height:1.6"><b>5.</b> Explique comment tu compares deux fractions.</div>
        <div style="font-size:13px;color:#9A6300;font-weight:600">En attente de correction · 3 points</div></div></div>
    </div>
  </div>'''
    return frame(body)


def teacher_phone_editor():
    body = f'''
  <div style="display:flex;align-items:center;gap:10px;padding:14px 16px;background:#fff;border-bottom:1px solid #E6E8F0"><span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center">{icon('arrowleft', 20)}</span>
    <div style="flex:1;min-width:0"><div style="font-size:16px;font-weight:800">Série 3 : les fractions</div><div class="s13">Brouillon · enregistré</div></div><span class="btn primary sm">Publier</span></div>
  <div style="flex:1;overflow:hidden;padding:12px;background:#E9EBF3">
    <div style="background:#fff;border-radius:6px;padding:18px;font-size:15px;line-height:1.7;box-shadow:0 6px 18px rgba(28,37,102,.10)">
      <div style="font-weight:800;color:#2B3990">Exercice 1 <span class="s13">(4 points)</span></div>Calcule et simplifie :
      <div>a) $\\dfrac{{3}}{{4}} + \\dfrac{{1}}{{2}}$ = ........</div><div>b) $\\dfrac{{5}}{{6}} - \\dfrac{{1}}{{3}}$ = ........</div>
      <div style="font-weight:800;color:#2B3990;margin-top:8px">Exercice 2 <span class="s13">(4 points)</span></div>Complète le tableau par <b>oui</b> ou <b>non</b>.
      <table style="border-collapse:collapse;margin:6px 0;font-size:13px;width:100%"><tr>{''.join(f'<th style="border:1px solid #B8BCD3;padding:4px;background:#F1F3FA">{h}</th>' for h in ['Fraction', '$\\frac{{3}}{{5}}$', '$\\frac{{4}}{{7}}$', '$\\frac{{2}}{{3}}$'])}</tr>
        <tr>{''.join('<td style="border:1px solid #B8BCD3;height:30px"></td>' for _ in range(4))}</tr></table>
      <div style="font-weight:800;color:#2B3990;margin-top:8px">Exercice 3 <span class="s13">(4 points)</span></div>Ahmed a mangé <span style="background:#FFF4DC">$\\dfrac{{2}}{{8}}$ de la pizza</span><span style="display:inline-block;width:1.5px;height:17px;background:#2B3990;vertical-align:middle"></span></div></div>
  <div style="display:flex;gap:4px;padding:8px;background:#fff;border-top:1px solid #E6E8F0;overflow:hidden">{tool(icon("bold", 17), on=True)}{tool(icon("italic", 17))}{tool(icon("underline", 17))}{tool(icon("listnum", 17))}{tool(icon("table", 17))}{tool(icon("image", 17))}
    <span style="height:34px;padding:0 10px;border-radius:9px;background:#2B3990;color:#fff;display:flex;align-items:center;font-size:13px;font-weight:800"><i style="font-family:serif">ƒx</i></span>{tool(icon("more", 17))}</div>
  <div style="height:190px;background:#D1D5DB;display:grid;grid-template-columns:repeat(10,1fr);gap:5px;padding:8px">{''.join(f'<span style="background:#fff;border-radius:5px;display:flex;align-items:center;justify-content:center;font-size:15px">{k}</span>' for k in 'azertyuiopqsdfghjklmwxcvbn,.')}</div>'''
    return frame(body.replace('{{', '{').replace('}}', '}'))


NOTES = [
    ('Écrire comme dans Word', 'Créer › Série (ou Contenus › « Écrire un document ») ouvre une page A4 : titres, gras, italique, souligné, tailles, couleurs, surligner, aligner, listes à puces et numérotées, tableaux, images (fichier ou photo), lignes pour répondre, et ƒx Formule. Enregistré tout seul, en brouillon.'),
    ('Formules', 'ƒx ouvre une petite fenêtre : on tape 3/4 + 1/2 (ou on clique une fraction, une puissance, une racine, ×, ÷, ≤ …) et l\'aperçu montre la vraie formule ; « Insérer » la place dans le texte. Un clic sur une formule la modifie.'),
    ('Corrigé', 'Un deuxième onglet « Corrigé », visible par vous seule : la version avec les réponses. Les fiches PDF (étape suivante) imprimeront l\'une ou l\'autre.'),
    ('Publier', '« Publier » la met dans Contenus comme un document (Série, Cours ou Autre) : partager avec un groupe, donner en devoir, ouvrir dans l\'application pour les élèves et les parents, en français ou en arabe. Les mêmes outils servent aux leçons.'),
    ('Quiz et QCM', 'Créer › QCM ou Quiz : réglages (durée, tentatives, note retenue, montrer les réponses, ordre au hasard) et 5 types de questions : choix multiple, vrai/faux, réponse courte (plusieurs réponses acceptées ; 2,5 = 2.5), texte à trous, question ouverte. Le même ruban (formules, images, gras) dans chaque question. Le total des points se calcule seul.'),
    ('Saisie rapide QCM', 'La question, puis un choix par ligne, un clic sur la bonne réponse, Entrée pour la suivante : 10 questions en moins de 10 minutes.'),
    ('Aperçu, publication, devoir', '« Aperçu élève » le passe comme un élève, rien d\'enregistré. Publié, on le donne à un groupe avec une date limite comme un devoir. Dès qu\'un élève l\'a passé, ses questions sont figées (« Dupliquer » pour une nouvelle version).'),
    ('Les élèves passent le quiz', 'Une question par écran sur téléphone, tout sur une page sur ordinateur ; chaque réponse est enregistrée tout de suite ; le minuteur envoie le quiz à zéro (le serveur le vérifie). La note arrive aussitôt (question ouverte : après votre correction, dans « À corriger »), elle compte dans Résultats comme « Quiz ».'),
]


def phone_board():
    def column(label, content):
        return f'<div style="display:flex;flex-direction:column;gap:14px;align-items:center"><div class="cap" style="font-size:13px">{label}</div>{content}</div>'
    notes = ''.join(
        f'<div style="display:flex;gap:12px"><span style="width:26px;height:26px;border-radius:13px;background:#2B3990;color:#fff;font-size:13px;font-weight:800;display:flex;align-items:center;justify-content:center;flex-shrink:0">{i}</span>'
        f'<div><div style="font-size:15px;font-weight:800">{title}</div><div style="font-size:14px;color:#4A4F72;line-height:1.5;margin-top:2px">{text}</div></div></div>'
        for i, (title, text) in enumerate(NOTES, 1))
    body = f'''{KATEX}<div style="padding:48px;display:flex;flex-direction:column;gap:40px;background:#EEF0FA">
  <div style="display:flex;gap:28px;justify-content:center;align-items:flex-start">
    {column('ENSEIGNANTE · TÉLÉPHONE', teacher_phone_editor())}
    {column('ÉLÈVE · LE QUIZ', pupil_question('fr'))}
    {column('ARABE · الاختبار', pupil_question('ar'))}
  </div>
  <div style="display:flex;gap:40px;justify-content:center;align-items:flex-start">
    {column('ÉLÈVE · LA NOTE', pupil_result())}
    <div style="width:820px;background:#fff;border:1px solid #E6E8F0;border-radius:24px;padding:26px;display:flex;flex-direction:column;gap:16px">
      <div style="font-size:22px;font-weight:800">Version 3 : écrire ses séries et ses quiz dans l'application</div>
      <div style="font-size:14px;color:#6B7090;line-height:1.5">Décisions du 9 octobre : une page comme Word, les 5 types de questions. Remplace les maquettes d'exercices du 8 octobre. Données inventées.</div>
      {notes}
    </div>
  </div>
</div>'''
    return page('Séries et quiz sur téléphone', body, width=1440, height=1900)


if __name__ == '__main__':
    (OUT / 'EditeurDocument.html').write_text(screen('Écrire une série', editor_page(), height=1300))
    (OUT / 'QuizEditeur.html').write_text(screen('Quiz', quiz_page(), height=1500))
    (OUT / 'QuizSaisieRapide.html').write_text(screen('Saisie rapide QCM', quiz_page(), overlay=quick_entry(), height=1500))
    (OUT / 'SeriesQuizPhone.html').write_text(phone_board())
    print('EditeurDocument, QuizEditeur, QuizSaisieRapide, SeriesQuizPhone')
