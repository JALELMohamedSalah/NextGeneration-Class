from pathlib import Path

from common import avatar, badge, chip, icon, page, teacher

OUT = Path('/Users/macbook/Desktop/NextGenerationClass/docs/00-brand/ui/mockups/r1')

STUDENTS = [
    ('AK', 'Amine Kefi', '7ème', ['7A'], 'Mère · Sonia Kefi', 94, 'turquoise', None),
    ('LB', 'Lina Bouzid', '9ème', ['9B'], 'Père · Karim Bouzid', 88, 'green', None),
    ('MJ', 'Malek Jaziri', '9ème', ['9B'], 'Mère · Rim Jaziri', 71, 'red', ('2 absences', 'red')),
    ('NH', 'Nour Hammami', 'Bac Math', ['BM'], 'Mère · Hela Hammami', 96, 'amber', None),
    ('RM', 'Rayen Mansour', '7ème', ['7A'], 'Père · Sami Mansour', 90, 'orange', None),
    ('SB', 'Sara Ben Amor', 'Bac Sciences', ['CP'], 'Mère · Leila Ben Amor', 100, 'violet', None),
    ('YT', 'Yasmine Trabelsi', 'Bac Math', ['BM'], 'Père · Nabil Trabelsi', 92, 'blue', None),
]
GROUP_STYLE = {'7A': ('#2B3990', '#fff', '7ème A · Math'), '9B': ('#12A39A', '#fff', '9ème B · Math'),
               'BM': ('#FFB020', '#1A1D3A', 'Bac Math'), 'CP': ('#7048E8', '#fff', 'Physique · cours particulier')}


def group_tag(code):
    bg, fg, name = GROUP_STYLE[code]
    return (f'<span style="display:inline-flex;align-items:center;gap:8px;font-size:13px;font-weight:600">'
            f'<span class="sq" style="background:{bg};color:{fg};width:20px;height:20px;border-radius:6px;font-size:10px">{code}</span>{name}</span>')


def students_list():
    rows = ''
    for ini, name, level, groups, parent, att, acc, warn in STUDENTS:
        att_color = '#237A35' if att >= 85 else ('#B5440A' if att >= 75 else '#B42525')
        rows += f'''<div class="row" style="padding:14px 0">
  {avatar(ini, acc)}
  <div style="flex:2;min-width:0"><div class="t15">{name}</div><div class="s13">{level}</div></div>
  <div style="flex:2;display:flex;flex-wrap:wrap;gap:8px">{''.join(group_tag(g) for g in groups)}</div>
  <div style="flex:2" class="s13">{icon('phone', 14, style='vertical-align:-2px;margin-inline-end:6px')}{parent}</div>
  <div style="width:110px;display:flex;flex-direction:column;gap:6px">
    <div style="font-size:13px;font-weight:800;color:{att_color}">{att} %</div>
    <div style="height:6px;border-radius:3px;background:#F0F1F6"><div style="width:{att}%;height:6px;border-radius:3px;background:{att_color}"></div></div>
  </div>
  <div style="width:130px;display:flex;justify-content:flex-end">{chip(*warn) if warn else ''}</div>
  {icon('chevright', 18, color='#6B7090')}
</div>'''
    content = f'''<main class="page">
  <div style="display:flex;align-items:flex-end;gap:20px;flex-wrap:wrap">
    <div style="flex:1;display:flex;flex-direction:column;gap:6px">
      <h1 class="ptitle">Élèves</h1>
      <div style="font-size:15px;color:#4A4F72">22 élèves, 4 groupes et 3 cours particuliers cette année.</div>
    </div>
    <span class="btn secondary">{icon('upload', 18)}Importer</span>
    <span class="btn secondary">{icon('users', 18)}Nouveau groupe</span>
    <span class="btn primary">{icon('plus', 18, 2.4)}Nouvel élève</span>
  </div>
  <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap">
    <div class="tabs"><span class="on">Élèves <span class="count" style="background:#fff;color:#2B3990">22</span></span><span>Groupes <span class="count" style="background:#F6F7FB">4</span></span><span>Cours particuliers <span class="count" style="background:#F6F7FB">3</span></span><span>Archivés</span></div>
    <div style="flex:1"></div>
    <div class="search" style="width:280px;background:#fff">{icon('search', 18)}Nom, identifiant, téléphone</div>
    <span class="btn secondary" style="color:#4A4F72">{icon('filter', 16)}Niveau : tous{icon('chevdown', 16)}</span>
  </div>
  <section class="card" style="padding:8px 24px 10px">
    <div style="display:flex;gap:14px;padding:12px 0" class="cap">
      <span style="width:40px"></span><span style="flex:2">ÉLÈVE</span><span style="flex:2">GROUPES</span><span style="flex:2">PARENT</span><span style="width:110px">PRÉSENCE</span><span style="width:130px"></span><span style="width:18px"></span>
    </div>
    {rows}
  </section>
</main>'''
    return teacher('Élèves', 'Élèves', content)


def groups_tab():
    cards = ''
    data = [
        ('7A', '7ème A · Math', 'Mathématiques · 7ème', 'Mardi et jeudi · 10:00 à 11:30', 'Salle 2', 8, ['AK', 'RM', 'OS', 'EB', 'SG'], None),
        ('9B', '9ème B · Math', 'Mathématiques · 9ème', 'Lundi · 17:00 à 18:30', 'En ligne · Meet', 6, ['LB', 'MJ', 'AM', 'IS'], None),
        ('BM', 'Bac Math', 'Mathématiques · Bac Math', 'Samedi · 09:00 à 11:00', 'Salle 1', 5, ['NH', 'YT', 'KD'], None),
        ('PH', 'Physique · Bac Sciences', 'Physique · Bac Sciences', 'Aucun horaire habituel', '', 0, [], 'Ajoutez des élèves'),
    ]
    colors = {'7A': ('#2B3990', '#fff'), '9B': ('#12A39A', '#fff'), 'BM': ('#FFB020', '#1A1D3A'), 'PH': ('#3B5BDB', '#fff')}
    accs = ['indigo', 'turquoise', 'amber', 'violet', 'blue']
    for code, name, sub, sched, place, n, members, empty in data:
        bg, fg = colors[code]
        stack = ''.join(f'<span style="margin-inline-start:{0 if i == 0 else -10}px;border:3px solid #fff;border-radius:50%">{avatar(m, accs[i % 5], 32)}</span>' for i, m in enumerate(members[:4]))
        if n > 4:
            stack += f'<span class="av" style="margin-inline-start:-10px;width:38px;height:38px;border:3px solid #fff;background:#1A1D3A;color:#fff;font-size:12px">+{n - 4}</span>'
        foot = (f'<div style="display:flex;align-items:center">{stack}</div><span class="s13" style="margin-inline-start:auto">{n} élèves</span>'
                if n else f'<span class="s13">{empty}</span><span class="btn tonal sm" style="margin-inline-start:auto">{icon("plus", 16)}Ajouter</span>')
        cards += f'''<section class="card" style="flex:1 1 360px;display:flex;flex-direction:column;gap:16px">
  <div style="display:flex;align-items:center;gap:12px"><span class="sq" style="background:{bg};color:{fg};width:40px;height:40px;border-radius:12px;font-size:14px">{code}</span>
    <div style="flex:1"><div style="font-size:17px;font-weight:800">{name}</div><div class="s13">{sub}</div></div>{icon('chevright', 18, color='#6B7090')}</div>
  <div style="display:flex;flex-direction:column;gap:8px" class="s13">
    <div style="display:flex;gap:8px;align-items:center">{icon('repeat', 16, color='#2B3990')}<span style="color:#1A1D3A;font-weight:600">{sched}</span></div>
    {f'<div style="display:flex;gap:8px;align-items:center">{icon("video" if "Meet" in place else "pin", 16, color="#2B3990")}{place}</div>' if place else ''}
  </div>
  <div style="display:flex;align-items:center;gap:12px;padding-top:14px;border-top:1px solid #F0F1F6">{foot}</div>
</section>'''
    content = f'''<main class="page">
  <div style="display:flex;align-items:flex-end;gap:20px"><div style="flex:1"><h1 class="ptitle">Élèves</h1></div>
    <span class="btn secondary">{icon('upload', 18)}Importer</span><span class="btn secondary">{icon('plus', 18)}Nouvel élève</span><span class="btn primary">{icon('plus', 18, 2.4)}Nouveau groupe</span></div>
  <div style="display:flex"><div class="tabs"><span>Élèves <span class="count" style="background:#F6F7FB">22</span></span><span class="on">Groupes <span class="count" style="background:#fff;color:#2B3990">4</span></span><span>Cours particuliers <span class="count" style="background:#F6F7FB">3</span></span><span>Archivés</span></div></div>
  <div style="display:flex;flex-wrap:wrap;gap:24px">{cards}</div>
</main>'''
    return teacher('Groupes', 'Élèves', content)


def new_student():
    overlay = f'''<div class="scrim"></div>
<aside class="panel">
  <div class="panel-h">{badge('user', 'indigo')}<div style="flex:1"><div style="font-size:20px;font-weight:800">Nouvel élève</div><div class="s13">Ses identifiants s'affichent après l'enregistrement.</div></div>{icon('x', 22, color='#6B7090')}</div>
  <div class="panel-b">
    <div style="display:flex;gap:12px"><div class="field" style="flex:1"><label>Prénom</label><div class="input focus">Omar</div></div><div class="field" style="flex:1"><label>Nom</label><div class="input">Saidi</div></div></div>
    <div style="display:flex;gap:12px"><div class="field" style="flex:1"><label>Niveau</label><div class="input" style="justify-content:space-between">7ème{icon('chevdown', 18, color='#6B7090')}</div></div>
      <div class="field" style="flex:1"><label>Téléphone <span class="s13" style="font-weight:500">(facultatif)</span></label><div class="input" style="color:#6B7090">8 chiffres</div></div></div>
    <div class="field"><label>Identifiant</label><div class="input" style="justify-content:space-between"><span>omar.saidi</span>{chip('Disponible', 'green')}</div><div class="hint">Créé à partir du prénom et du nom. Vous pouvez le changer.</div></div>
    <div class="field"><label>Groupes</label><div class="input" style="flex-wrap:wrap;padding:8px 10px;gap:8px">
      <span class="chip" style="background:#fff;border:1px solid #E6E8F0;color:#1A1D3A;padding:4px 6px 4px 4px"><span class="sq" style="background:#2B3990;width:20px;height:20px;border-radius:6px;font-size:10px">7A</span>7ème A · Math {icon('x', 14, color='#6B7090')}</span>
      <span class="s13">Ajouter un groupe…</span></div></div>
    <div style="display:flex;flex-direction:column;gap:12px;padding:16px;border:1px solid #E6E8F0;border-radius:16px">
      <div style="display:flex;align-items:center;gap:10px"><div style="flex:1;font-size:15px;font-weight:800">Parents</div><span class="s13">1 sur 2</span></div>
      <div style="display:flex;align-items:center;gap:12px;padding:12px;background:#F6F7FB;border-radius:14px">{avatar('NS', 'amber', 36)}<div style="flex:1"><div style="font-size:14px;font-weight:700">Nadia Saidi · mère</div><div class="s13">Nouveau compte · 22 345 678</div></div>{icon('pencil', 16, color='#6B7090')}</div>
      <div style="display:flex;gap:10px"><span class="btn secondary sm">{icon('search', 16)}Parent existant</span><span class="btn secondary sm">{icon('plus', 16)}Nouveau parent</span></div>
    </div>
  </div>
  <div class="panel-f"><span class="btn ghost">Annuler</span><span class="btn primary">Enregistrer</span></div>
</aside>'''
    return teacher('Nouvel élève', 'Élèves', students_list_content(), overlay)


def students_list_content():
    html = students_list()
    return html[html.index('<main class="page">'):html.index('</main>') + 7]


def credentials():
    acc = lambda who, ini, a, user, pwd, note: f'''<div style="display:flex;flex-direction:column;gap:12px;padding:18px;border:1px solid #E6E8F0;border-radius:18px">
  <div style="display:flex;align-items:center;gap:12px">{avatar(ini, a, 40)}<div style="flex:1"><div class="t15">{who}</div><div class="s13">{note}</div></div>{chip('Nouveau compte', 'blue')}</div>
  <div style="display:flex;gap:12px">
    <div style="flex:1;padding:12px 14px;background:#F6F7FB;border-radius:14px"><div class="cap">IDENTIFIANT</div><div style="font-size:17px;font-weight:800;margin-top:4px;direction:ltr">{user}</div></div>
    <div style="flex:1;padding:12px 14px;background:#F6F7FB;border-radius:14px"><div class="cap">MOT DE PASSE TEMPORAIRE</div><div style="font-size:17px;font-weight:800;margin-top:4px;font-family:ui-monospace,Menlo,monospace;letter-spacing:1px">{pwd}</div></div>
  </div>
  <div style="display:flex;gap:10px"><span class="btn secondary sm">{icon('copy', 16)}Copier</span><span class="btn tonal sm">{icon('message', 16)}Copier le message</span></div>
</div>'''
    modal = f'''<div class="scrim"></div>
<div style="position:absolute;top:110px;left:50%;transform:translateX(-50%);width:600px;background:#fff;border-radius:28px;box-shadow:0 30px 80px rgba(28,37,102,.25);padding:28px;display:flex;flex-direction:column;gap:18px">
  <div style="display:flex;align-items:center;gap:14px">{badge('key', 'turquoise', 48, 14, 22)}<div style="flex:1"><div style="font-size:22px;font-weight:800">Identifiants créés</div><div class="s13">Envoyez-les maintenant : les mots de passe ne seront plus affichés.</div></div></div>
  {acc('Omar Saidi', 'OS', 'red', 'omar.saidi', 'kprate4827', 'Élève · 7ème A · Math')}
  {acc('Nadia Saidi', 'NS', 'amber', '22345678', 'mhwens5932', 'Parent · se connecte avec son téléphone')}
  <div class="note">{icon('lock', 16, color='#2B3990', style='margin-top:2px')}<span>Chacun choisira son propre mot de passe à la première connexion. En cas d'oubli : Fiche élève, Réinitialiser le mot de passe.</span></div>
  <div style="display:flex;justify-content:flex-end"><span class="btn primary">J'ai envoyé les identifiants</span></div>
</div>'''
    return teacher('Identifiants', 'Élèves', students_list_content(), modal)


def profile():
    sessions = ''.join(f'''<div class="row"><div style="width:52px;text-align:center"><div class="cap">{d}</div><div style="font-size:20px;font-weight:800">{n}</div></div>
  <div style="width:4px;align-self:stretch;border-radius:2px;background:#2B3990"></div>
  <div style="flex:1"><div class="t15">{t}</div><div class="s13">{s}</div></div>{chip(*c)}</div>''' for d, n, t, s, c in [
        ('MAR', '6', 'Math · 7ème A', '10:00 à 11:30 · Salle 2', ('Prévue', 'blue')),
        ('JEU', '8', 'Math · 7ème A', '10:00 à 11:30 · Salle 2', ('Prévue', 'blue')),
        ('MAR', '13', 'Math · 7ème A', '10:00 à 11:30 · Salle 2', ('Prévue', 'blue'))])
    att = ''.join(f'<span title="{t}" style="width:26px;height:26px;border-radius:8px;background:{b};border:1.5px solid {c}"></span>' for t, b, c in
                  [('p', '#F3FBF5', '#CDEBD3')] * 3 + [('a', '#FEF5F5', '#F6C9C9')] + [('p', '#F3FBF5', '#CDEBD3')] * 2 + [('l', '#FEF7F2', '#F7D3BE')] + [('p', '#F3FBF5', '#CDEBD3')] * 3)
    content = f'''<main class="page">
  <a style="display:flex;align-items:center;gap:8px;font-size:14px;font-weight:700">{icon('arrowleft', 18)}Élèves</a>
  <section class="card" style="display:flex;gap:20px;align-items:center;flex-wrap:wrap">
    {avatar('AK', 'turquoise', 72)}
    <div style="flex:1;display:flex;flex-direction:column;gap:8px;min-width:280px">
      <div style="display:flex;align-items:center;gap:12px"><h1 style="margin:0;font-size:30px;font-weight:800;letter-spacing:-.6px">Amine Kefi</h1>{chip('Actif', 'green')}</div>
      <div class="s13" style="font-size:14px">7ème · identifiant <b style="color:#1A1D3A;direction:ltr">amine.kefi</b> · dernière connexion hier</div>
      <div style="display:flex;gap:16px;flex-wrap:wrap;margin-top:4px">
        <span style="display:inline-flex;align-items:center;gap:8px;font-size:13px;font-weight:600"><span class="sq" style="background:#2B3990;width:20px;height:20px;border-radius:6px;font-size:10px">7A</span>7ème A · Math</span>
        <span style="display:inline-flex;align-items:center;gap:8px;font-size:13px;color:#4A4F72">{icon('phone', 15, color='#2B3990')}Mère · Sonia Kefi · 98 123 456</span>
      </div>
    </div>
    <div style="display:flex;gap:10px"><span class="btn secondary">{icon('key', 17)}Réinitialiser le mot de passe</span><span class="btn secondary">{icon('pencil', 17)}Modifier</span><span class="btn danger" style="width:44px;padding:0;justify-content:center">{icon('archive', 18)}</span></div>
  </section>
  <div style="display:flex;gap:16px;flex-wrap:wrap">
    {''.join(f"""<div class="card" style="flex:1 1 200px;padding:20px;border-radius:20px;display:flex;flex-direction:column;gap:14px"><div style="display:flex;align-items:center">{badge(i, a)}<span class="cap" style="margin-inline-start:auto;color:{cc}">{c}</span></div><div style="font-size:34px;font-weight:800;letter-spacing:-1px">{v}</div><div style="font-size:14px;font-weight:600;color:#6B7090;margin-top:-10px">{l}</div></div>""" for i, a, v, l, c, cc in [
        ('circlecheck', 'green', '94 %', 'Présence cette année', '1 absence', '#237A35'),
        ('clock', 'orange', '1', 'Retard', 'ce trimestre', '#6B7090'),
        ('calendar', 'indigo', '24', 'Séances suivies', 'depuis septembre', '#6B7090'),
        ('chart', 'grey', '—', 'Moyenne', 'avec la version 2', '#6B7090')])}
  </div>
  <div style="display:flex;gap:24px;flex-wrap:wrap">
    <div style="flex:7 1 460px;display:flex;flex-direction:column;gap:24px">
      <section class="card"><div class="ch"><h2>Prochaines séances</h2><a style="font-size:13px;font-weight:700">Planning</a></div>{sessions}</section>
      <section class="card"><div class="ch"><h2>Présences</h2><span class="s13">10 dernières séances</span></div>
        <div style="display:flex;gap:8px;flex-wrap:wrap">{att}</div>
        <div style="display:flex;gap:10px;margin-top:16px">{chip('8 présents', 'green')}{chip('1 absent', 'red')}{chip('1 en retard', 'orange')}</div></section>
    </div>
    <div style="flex:5 1 340px;display:flex;flex-direction:column;gap:24px">
      <section class="card"><div class="ch"><h2>Commentaires</h2><span class="btn tonal sm">{icon('plus', 16)}Ajouter</span></div>
        <div class="note" style="flex-direction:column;gap:4px"><span class="cap">HIER · VISIBLE PAR L'ÉLÈVE ET SES PARENTS</span><span style="font-size:14px;color:#1A1D3A">Amine participe bien. Il doit revoir la simplification des fractions avant vendredi.</span></div></section>
      <section class="card" style="background:#FFF8E8;border-color:#F8E3B3"><div class="ch"><h2 style="display:flex;align-items:center;gap:8px">{icon('lock', 18, color='#9A6300')}Notes privées</h2><span class="btn secondary sm">{icon('plus', 16)}Ajouter</span></div>
        <div class="cap" style="color:#9A6300;margin-bottom:12px">VISIBLE PAR VOUS UNIQUEMENT</div>
        <div style="display:flex;flex-direction:column;gap:10px">
          <div style="padding:12px 14px;background:#fff;border-radius:14px;border:1px solid #F8E3B3"><div class="cap">2 OCTOBRE</div><div style="font-size:14px;margin-top:4px">Plus à l'aise à l'oral. Proposer des exercices courts.</div></div>
          <div style="padding:12px 14px;background:#fff;border-radius:14px;border:1px solid #F8E3B3"><div class="cap">18 SEPTEMBRE</div><div style="font-size:14px;margin-top:4px">La mère souhaite un point mensuel.</div></div>
        </div></section>
    </div>
  </div>
</main>'''
    return teacher('Fiche élève', 'Élèves', content, height=1180)


def group_detail():
    members = ''.join(f'''<div class="row">{avatar(i, a)}<div style="flex:1"><div class="t15">{n}</div><div class="s13">{p}</div></div><span style="font-size:13px;font-weight:800;color:{c}">{v} %</span>{icon('more', 18, color='#6B7090')}</div>'''
                      for i, a, n, p, v, c in [('AK', 'turquoise', 'Amine Kefi', 'amine.kefi', 94, '#237A35'), ('EB', 'amber', 'Eya Ben Salah', 'eya.bensalah', 100, '#237A35'),
                                               ('OS', 'red', 'Omar Saidi', 'omar.saidi', 78, '#B5440A'), ('RM', 'orange', 'Rayen Mansour', 'rayen.mansour', 90, '#237A35'),
                                               ('SG', 'violet', 'Skander Gharbi', 'skander.gharbi', 86, '#237A35')])
    content = f'''<main class="page">
  <a style="display:flex;align-items:center;gap:8px;font-size:14px;font-weight:700">{icon('arrowleft', 18)}Groupes</a>
  <section style="position:relative;overflow:hidden;background:#2B3990;border-radius:28px;padding:30px 32px;color:#fff;display:flex;gap:24px;align-items:center;box-shadow:0 18px 40px rgba(28,37,102,.22)">
    <svg width="300" height="300" viewBox="0 0 300 300" fill="none" style="position:absolute;inset-inline-end:-40px;bottom:-110px"><path d="M40 250 150 140 260 250" stroke="#fff" stroke-opacity=".07" stroke-width="34" stroke-linecap="round" stroke-linejoin="round"/><path d="M70 170 150 90 230 170" stroke="#fff" stroke-opacity=".09" stroke-width="30" stroke-linecap="round" stroke-linejoin="round"/><path d="M100 95 150 45 200 95" stroke="#12A39A" stroke-opacity=".55" stroke-width="26" stroke-linecap="round" stroke-linejoin="round"/><circle cx="232" cy="38" r="14" fill="#FFB020"/></svg>
    <span class="sq" style="width:64px;height:64px;border-radius:18px;background:#fff;color:#2B3990;font-size:22px;position:relative">7A</span>
    <div style="flex:1;position:relative;display:flex;flex-direction:column;gap:8px">
      <div style="font-size:30px;font-weight:800;letter-spacing:-.6px">7ème A · Math</div>
      <div style="display:flex;gap:8px;flex-wrap:wrap;font-size:13px;font-weight:600">
        <span class="chip" style="background:rgba(255,255,255,.12)">{icon('repeat', 15)}Mardi et jeudi · 10:00 à 11:30</span>
        <span class="chip" style="background:rgba(255,255,255,.12)">{icon('pin', 15)}Salle 2</span>
        <span class="chip" style="background:rgba(255,255,255,.12)">8 élèves</span></div>
    </div>
    <div style="display:flex;gap:10px;position:relative"><span class="btn" style="height:50px;border-radius:14px;background:#fff;color:#2B3990;font-weight:800">{icon('calplus', 18)}Planifier une séance</span><span class="btn" style="height:50px;border-radius:14px;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.3);color:#fff">{icon('pencil', 17)}Modifier</span></div>
  </section>
  <div style="display:flex;gap:24px;flex-wrap:wrap">
    <section class="card" style="flex:7 1 460px"><div class="ch"><h2 style="flex:none">Élèves</h2><span class="count" style="background:#EEF0FA;color:#2B3990">8</span><span style="flex:1"></span><span class="btn tonal sm">{icon('plus', 16)}Ajouter des élèves</span></div>{members}<div style="padding-top:12px;border-top:1px solid #F0F1F6"><a style="font-size:13px;font-weight:700">Voir les 8 élèves</a></div></section>
    <div style="flex:5 1 340px;display:flex;flex-direction:column;gap:24px">
      <section class="card"><div class="ch"><h2>Horaire habituel</h2><a style="font-size:13px;font-weight:700">Modifier</a></div>
        {''.join(f'<div class="row" style="border:none;padding:6px 0">{badge("repeat", "indigo", 36, 10, 17)}<div style="flex:1"><div class="t15">{d}</div><div class="s13">{h}</div></div></div>' for d, h in [('Chaque mardi', '10:00 à 11:30 · Présentiel · Salle 2'), ('Chaque jeudi', '10:00 à 11:30 · Présentiel · Salle 2')])}
        <div class="note" style="margin-top:12px">{icon('calendar', 16, color='#2B3990', style='margin-top:2px')}<span>Séances créées jusqu'au 30 juin 2027. Une séance se modifie seule ou avec les suivantes.</span></div></section>
      <section class="card"><div class="ch"><h2>Lien Meet par défaut</h2></div>
        <div class="input" style="font-size:14px">{icon('link', 18, color='#6B7090')}<span style="flex:1;direction:ltr;color:#6B7090">Aucun lien. Les séances sont en présentiel.</span></div></section>
    </div>
  </div>
</main>'''
    return teacher('Groupe', 'Élèves', content, height=1000)


if __name__ == '__main__':
    for name, html in [('Eleves', students_list()), ('Groupes', groups_tab()), ('NouvelEleve', new_student()),
                       ('Identifiants', credentials()), ('FicheEleve', profile()), ('Groupe', group_detail())]:
        (OUT / f'{name}.html').write_text(html)
        print(name)
