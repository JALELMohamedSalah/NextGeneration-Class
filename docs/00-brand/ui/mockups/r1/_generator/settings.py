from pathlib import Path

import common
from common import badge, chip, icon, teacher

OUT = Path('/Users/macbook/Desktop/NextGenerationClass/docs/00-brand/ui/mockups/r1')
common.GROUPS[:] = [('4A', '4ème année · Maths', '#2B3990', '#fff', 6), ('5L', '5ème année · Lecture', '#12A39A', '#fff', 5),
                    ('6E', '6ème année · Éveil', '#FFB020', '#1A1D3A', 4), ('SB', 'Sara Ben Amor · Lecture', '#7048E8', '#fff', 1)]

SUBJECTS = [('#2B3990', 'Mathématiques', 'الرياضيات', 2), ('#12A39A', 'Lecture', 'القراءة', 2),
            ('#FFB020', 'Éveil scientifique', 'الإيقاظ العلمي', 1), ('#7048E8', 'Français', '', 0)]


def settings():
    rows = ''
    for i, (color, fr, ar, used) in enumerate(SUBJECTS):
        ar_text = f'<span style="font-family:\'IBM Plex Sans Arabic\';direction:rtl">{ar}</span>' if ar else '<span class="s13">Pas de nom arabe : le nom français est affiché</span>'
        used_chip = chip(f'{used} groupe{"s" if used > 1 else ""}', 'indigo', dot=False) if used else chip('Aucun groupe', 'grey', dot=False)
        rows += f'''<div class="row" style="padding:16px 0;{"border-top:none" if i == 0 else ""}">
  <span style="width:40px;height:40px;border-radius:12px;background:{color};flex-shrink:0"></span>
  <div style="flex:1"><div class="t15">{fr}</div><div style="font-size:14px;color:#4A4F72">{ar_text}</div></div>
  {used_chip}
  <span class="btn secondary sm">{icon('pencil', 16)}Modifier</span>
  <span class="btn {"danger" if not used else "secondary"} sm" style="width:38px;padding:0;justify-content:center;{"" if not used else "opacity:.4"}">{icon('x', 16)}</span>
</div>'''
    levels = ''.join(f'<span class="chip" style="background:#F6F7FB;color:#1A1D3A;padding:8px 12px;font-size:13px">{n}</span>' for n in
                     ['1ère année', '2ème année', '3ème année', '4ème année', '5ème année', '6ème année'])
    content = f'''<main class="page">
  <div style="display:flex;align-items:flex-end;gap:16px"><div style="flex:1"><h1 class="ptitle">Paramètres</h1>
    <div style="font-size:15px;color:#4A4F72;margin-top:6px">Les matières que vous enseignez, vos niveaux et l'année scolaire.</div></div></div>
  <div style="display:flex"><div class="tabs"><span class="on">Matières <span class="count" style="background:#fff;color:#2B3990">4</span></span><span>Niveaux</span><span>Année scolaire</span></div></div>
  <div style="display:flex;gap:24px;flex-wrap:wrap;align-items:flex-start">
    <section class="card" style="flex:7 1 520px">
      <div class="ch"><h2>Vos matières</h2><span class="btn primary sm">{icon('plus', 16, 2.4)}Nouvelle matière</span></div>
      {rows}
      <div class="note" style="margin-top:12px">{icon('info', 16, color='#2B3990', style='margin-top:2px') if 'info' in common.ICONS else ''}<span>Une matière utilisée par un groupe ne peut pas être supprimée : changez d'abord la matière du groupe.</span></div>
    </section>
    <div style="flex:5 1 340px;display:flex;flex-direction:column;gap:24px">
      <section class="card"><div class="ch"><h2>Niveaux</h2>{chip('Primaire', 'turquoise', dot=False)}</div>
        <div style="display:flex;flex-wrap:wrap;gap:8px">{levels}</div>
        <div class="note" style="margin-top:14px">Les six années du primaire tunisien, en français et en arabe.</div></section>
      <section class="card"><div class="ch"><h2>Année scolaire</h2></div>
        <div style="display:flex;align-items:center;gap:12px">{badge('calendar', 'indigo')}<div><div class="t15">2026-2027</div><div class="s13">du 1er septembre 2026 au 30 juin 2027</div></div></div></section>
    </div>
  </div>
</main>'''
    dialog = f'''<div class="scrim"></div>
<div style="position:absolute;top:150px;left:50%;transform:translateX(-50%);width:520px;background:#fff;border-radius:28px;box-shadow:0 30px 80px rgba(28,37,102,.25);padding:26px;display:flex;flex-direction:column;gap:18px">
  <div style="display:flex;align-items:center;gap:14px">{badge('book', 'indigo', 46, 14, 21)}<div style="font-size:20px;font-weight:800">Nouvelle matière</div></div>
  <div class="field"><label>Nom en français</label><div class="input focus">Éveil scientifique</div></div>
  <div class="field"><label>Nom en arabe <span class="s13" style="font-weight:500">· facultatif</span></label><div class="input" style="direction:rtl;font-family:'IBM Plex Sans Arabic'">الإيقاظ العلمي</div><div class="hint">S'il est vide, le nom français est affiché.</div></div>
  <div class="field"><label>Couleur</label><div style="display:flex;gap:10px">{''.join(f'<span style="width:36px;height:36px;border-radius:10px;background:{c};{"border:2.5px solid #1A1D3A" if c == "#FFB020" else ""}"></span>' for c in ['#2B3990', '#12A39A', '#FFB020', '#7048E8', '#3B5BDB', '#E8590C'])}</div></div>
  <div style="display:flex;gap:10px;justify-content:flex-end"><span class="btn ghost">Annuler</span><span class="btn primary">Enregistrer</span></div>
</div>'''
    return teacher('Paramètres', 'Paramètres', content), teacher('Nouvelle matière', 'Paramètres', content, dialog)


if __name__ == '__main__':
    list_html, dialog_html = settings()
    (OUT / 'Parametres.html').write_text(list_html)
    (OUT / 'NouvelleMatiere.html').write_text(dialog_html)
    print('ok')
