from pathlib import Path

from common import avatar, badge, chip, icon, page, teacher

OUT = Path('/Users/macbook/Desktop/NextGenerationClass/docs/00-brand/ui/mockups/r1')

HOUR_PX = 64
START_H = 8
DAYS = [('Lun', 5), ('Mar', 6), ('Mer', 7), ('Jeu', 8), ('Ven', 9), ('Sam', 10)]
COLORS = {'7A': ('#2B3990', '#EEF0FA'), '9B': ('#12A39A', '#E3F6F4'), 'BM': ('#FFB020', '#FFF4DC'),
          'CP': ('#7048E8', '#F1ECFD')}
# day index, start, end, group, title, sub, state
SESSIONS = [
    (0, 17, 18.5, '9B', 'Math · 9ème B', 'En ligne', 'done'),
    (1, 10, 11.5, '7A', 'Math · 7ème A', 'Salle 2', 'done'),
    (1, 14, 15.5, 'CP', 'Physique · Sara Ben Amor', 'En ligne', 'next'),
    (1, 17, 18.5, 'BM', 'Math · Bac Math', 'Salle 1', 'planned'),
    (2, 15, 16, 'CP', 'Physique · Sara Ben Amor', 'En ligne', 'cancelled'),
    (3, 10, 11.5, '7A', 'Math · 7ème A', 'Salle 2', 'planned'),
    (3, 16, 17.5, 'CP', 'Math · Youssef Ayari', 'Salle 1', 'planned'),
    (4, 17, 18.5, '9B', 'Math · 9ème B', 'En ligne', 'planned'),
    (5, 9, 11, 'BM', 'Math · Bac Math', 'Salle 1', 'planned'),
]


def week_view():
    hours = ''.join(f'<div style="height:{HOUR_PX}px;font-size:12px;font-weight:700;color:#6B7090;text-align:end;padding-inline-end:10px;transform:translateY(-8px)">{h:02d}:00</div>' for h in range(START_H, 20))
    cols = ''
    for i, (d, n) in enumerate(DAYS):
        today = i == 1
        head = (f'<div style="height:64px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;border-bottom:1px solid #E6E8F0">'
                f'<span class="cap" style="color:{"#2B3990" if today else "#6B7090"}">{d.upper()}</span>'
                f'<span style="width:34px;height:34px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:18px;font-weight:800;'
                f'{"background:#2B3990;color:#fff" if today else ""}">{n}</span></div>')
        lines = ''.join(f'<div style="height:{HOUR_PX}px;border-bottom:1px solid #F0F1F6"></div>' for _ in range(START_H, 20))
        blocks = ''
        for di, s, e, g, t, sub, state in SESSIONS:
            if di != i:
                continue
            strong, soft = COLORS[g]
            top = (s - START_H) * HOUR_PX + 2
            h = (e - s) * HOUR_PX - 4
            hh = lambda x: f'{int(x):02d}:{int(round((x % 1) * 60)):02d}'
            style = f'background:{soft};border-inline-start:4px solid {strong};'
            extra = ''
            title_style = ''
            if state == 'done':
                style += 'opacity:.55;'
            if state == 'cancelled':
                style = 'background:repeating-linear-gradient(135deg,#F6F7FB 0 6px,#EEF0F5 6px 12px);border-inline-start:4px solid #ADB1C6;'
                title_style = 'text-decoration:line-through;color:#6B7090'
                extra = f'<div style="margin-top:4px">{chip("Annulée", "grey")}</div>'
            if state == 'next':
                style += 'box-shadow:0 0 0 2px #2B3990;'
                extra = ''
            ic = icon('video', 13) if sub == 'En ligne' else icon('pin', 13)
            blocks += (f'<div style="position:absolute;top:{top}px;inset-inline:4px;height:{h}px;border-radius:12px;padding:8px 10px;overflow:hidden;{style}">'
                       f'<div style="font-size:12px;font-weight:800;color:{strong if state != "cancelled" else "#6B7090"}">{hh(s)} à {hh(e)}{" · Prochaine" if state == "next" else ""}</div>'
                       f'<div style="font-size:13px;font-weight:700;line-height:1.3;{title_style}">{t}</div>'
                       f'<div class="s13" style="display:flex;align-items:center;gap:4px;font-size:12px">{ic}{sub}</div>{extra}</div>')
        now = f'<div style="position:absolute;top:{(12.6 - START_H) * HOUR_PX}px;inset-inline:0;height:2px;background:#FFB020"><span style="position:absolute;inset-inline-start:-5px;top:-4px;width:10px;height:10px;border-radius:5px;background:#FFB020"></span></div>' if today else ''
        slot = (f'<div style="position:absolute;top:{(12 - START_H) * HOUR_PX + 2}px;inset-inline:4px;height:{HOUR_PX * 1.5 - 4}px;border-radius:12px;border:1.5px dashed #2B3990;background:rgba(238,240,250,.6);display:flex;align-items:center;justify-content:center;gap:6px;font-size:13px;font-weight:700;color:#2B3990">{icon("plus", 16)}Séance</div>'
                if i == 2 else '')
        cols += (f'<div style="flex:1;min-width:0;border-inline-start:1px solid #F0F1F6;{"background:#FBFBFE;" if today else ""}">{head}'
                 f'<div style="position:relative">{lines}{blocks}{slot}{now}</div></div>')
    content = f'''<main class="page" style="max-width:none">
  <div style="display:flex;align-items:flex-end;gap:16px;flex-wrap:wrap">
    <div style="flex:1;display:flex;flex-direction:column;gap:6px"><div style="font-size:13px;font-weight:700;color:#6B7090">Octobre 2026</div><h1 class="ptitle">Planning</h1></div>
    <div class="tabs"><span>Jour</span><span class="on">Semaine</span></div>
    <div style="display:flex;gap:6px;align-items:center"><span class="btn secondary" style="width:44px;padding:0;justify-content:center">{icon('chevleft', 18)}</span><span class="btn secondary">Aujourd'hui</span><span class="btn secondary" style="width:44px;padding:0;justify-content:center">{icon('chevright', 18)}</span></div>
    <span class="btn secondary" style="color:#4A4F72">{icon('filter', 16)}Tous les groupes{icon('chevdown', 16)}</span>
    <span class="btn primary">{icon('plus', 18, 2.4)}Nouvelle séance</span>
  </div>
  <section class="card" style="padding:0;overflow:hidden;display:flex">
    <div style="width:64px;flex-shrink:0;padding-top:64px">{hours}</div>
    {cols}
  </section>
  <div style="display:flex;gap:16px;flex-wrap:wrap;align-items:center" class="s13">
    {''.join(f'<span style="display:inline-flex;gap:8px;align-items:center"><span class="sq" style="width:14px;height:14px;border-radius:4px;background:{COLORS[g][0]}"></span>{n}</span>' for g, n in [('7A', '7ème A · Math'), ('9B', '9ème B · Math'), ('BM', 'Bac Math'), ('CP', 'Cours particuliers')])}
    <span style="flex:1"></span><span>Atténuée : terminée · Barrée : annulée · Cliquez sur un créneau vide pour ajouter une séance</span>
  </div>
</main>'''
    return teacher('Planning', 'Planning', content, height=1120)


def new_session():
    overlay = f'''<div class="scrim"></div>
<aside class="panel">
  <div class="panel-h">{badge('calplus', 'indigo')}<div style="flex:1"><div style="font-size:20px;font-weight:800">Nouvelle séance</div><div class="s13">Mercredi 7 octobre, 12:00</div></div>{icon('x', 22, color='#6B7090')}</div>
  <div class="panel-b">
    <div class="field"><label>Groupe</label><div class="input focus" style="justify-content:space-between"><span style="display:flex;gap:10px;align-items:center"><span class="sq" style="background:#12A39A;width:22px;height:22px;border-radius:6px;font-size:10px">9B</span>9ème B · Math</span>{icon('chevdown', 18, color='#6B7090')}</div></div>
    <div style="display:flex;gap:12px">
      <div class="field" style="flex:1.3"><label>Date</label><div class="input" style="justify-content:space-between">Mer 7 oct. 2026{icon('calendar', 18, color='#6B7090')}</div></div>
      <div class="field" style="flex:1"><label>Début</label><div class="input">12:00</div></div>
      <div class="field" style="flex:1"><label>Fin</label><div class="input">13:30</div></div>
    </div>
    <div class="field"><label>Mode</label><div class="seg"><span>{icon('pin', 16)}Présentiel</span><span class="on">{icon('video', 16)}En ligne</span></div></div>
    <div class="field"><label>Lien visio</label><div class="input" style="font-size:14px">{icon('link', 18, color='#6B7090')}<span style="flex:1;direction:ltr">meet.google.com/abc-defg-hij</span>{chip('Du groupe', 'grey', dot=False)}</div></div>
    <div style="display:flex;flex-direction:column;gap:14px;padding:16px;border:1px solid #E6E8F0;border-radius:16px">
      <div style="display:flex;align-items:center;gap:12px">{badge('repeat', 'turquoise', 36, 10, 17)}<div style="flex:1"><div class="t15">Répéter chaque semaine</div><div class="s13">Chaque mercredi jusqu'à la fin de l'année</div></div>
        <span style="width:44px;height:26px;border-radius:13px;background:#2B3990;position:relative"><span style="position:absolute;top:3px;inset-inline-end:3px;width:20px;height:20px;border-radius:10px;background:#fff"></span></span></div>
      <div style="display:flex;gap:12px"><div class="field" style="flex:1"><label style="font-size:13px">Jusqu'au</label><div class="input" style="min-height:42px;font-size:14px">30 juin 2027</div></div><div class="field" style="flex:1"><label style="font-size:13px">Séances créées</label><div class="input" style="min-height:42px;font-size:14px;background:#fff">35 séances</div></div></div>
    </div>
    <div class="note" style="background:#FFF4DC;color:#9A6300">{icon('clock', 16, color='#9A6300', style='margin-top:2px')}<span>Chevauche une séance : Physique · Sara Ben Amor, 12:00 à 13:00 le 14 octobre. Vous pouvez continuer.</span></div>
    <div class="field"><label>Notes de préparation <span class="s13" style="font-weight:500">· visibles par vous uniquement</span></label><div class="input" style="min-height:70px;align-items:flex-start;padding-top:12px;color:#6B7090">Revoir les équations du premier degré…</div></div>
  </div>
  <div class="panel-f"><span class="btn ghost">Annuler</span><span class="btn primary">Créer 35 séances</span></div>
</aside>'''
    html = week_view()
    content = html[html.index('<main'):html.index('</main>') + 7]
    return teacher('Nouvelle séance', 'Planning', content, overlay, height=1120)


def session_detail():
    modal = f'''<div class="scrim"></div>
<aside class="panel" style="width:480px">
  <div class="panel-h" style="background:#F1ECFD;border:none"><span class="sq" style="width:40px;height:40px;border-radius:12px;background:#7048E8;font-size:14px">CP</span><div style="flex:1"><div style="font-size:20px;font-weight:800">Physique · Sara Ben Amor</div><div class="s13">Cours particulier · Bac Sciences</div></div>{icon('x', 22, color='#6B7090')}</div>
  <div class="panel-b" style="gap:16px">
    <div style="display:flex;gap:12px;align-items:center">{chip('Prochaine', 'indigo', solid=True)}<span style="font-size:14px;font-weight:700;color:#9A6300">dans 1 h 20</span></div>
    <div style="display:flex;flex-direction:column;gap:12px;font-size:14px">
      <div style="display:flex;gap:12px;align-items:center">{icon('calendar', 18, color='#2B3990')}<b>Mardi 6 octobre</b> · 14:00 à 15:30</div>
      <div style="display:flex;gap:12px;align-items:center">{icon('repeat', 18, color='#2B3990')}Chaque mardi, jusqu'au 30 juin 2027</div>
      <div style="display:flex;gap:12px;align-items:center">{icon('video', 18, color='#2B3990')}En ligne · <span style="direction:ltr;color:#2B3990;font-weight:700">meet.google.com/abc-defg-hij</span></div>
    </div>
    <div style="display:flex;gap:10px"><span class="btn primary" style="flex:1;justify-content:center;height:48px">{icon('play', 16)}Démarrer la séance</span><span class="btn secondary" style="height:48px">{icon('video', 18)}Ouvrir Meet</span></div>
    <div class="note" style="flex-direction:column;gap:4px;background:#FFF8E8"><span class="cap" style="color:#9A6300">NOTES DE PRÉPARATION</span><span style="font-size:14px;color:#1A1D3A">Finir l'électricité, chapitre 3. Exercice 4 de la série.</span></div>
    <div style="display:flex;gap:10px;padding-top:6px;border-top:1px solid #F0F1F6"><span class="btn secondary sm">{icon('pencil', 16)}Modifier</span><span class="btn danger sm">{icon('ban', 16)}Annuler la séance</span></div>
  </div>
</aside>
<div style="position:absolute;top:240px;left:330px;width:440px;background:#fff;border-radius:24px;box-shadow:0 30px 80px rgba(28,37,102,.3);padding:24px;display:flex;flex-direction:column;gap:16px">
  <div style="display:flex;gap:12px;align-items:center">{badge('ban', 'red', 44, 14, 20)}<div><div style="font-size:19px;font-weight:800">Annuler la séance</div><div class="s13">Cette séance fait partie d'une série.</div></div></div>
  <div style="display:flex;flex-direction:column;gap:10px">
    <div style="display:flex;gap:12px;align-items:center;padding:14px;border:1.5px solid #2B3990;border-radius:14px;background:#EEF0FA"><span style="width:20px;height:20px;border-radius:10px;border:6px solid #2B3990;background:#fff"></span><div><div class="t15">Cette séance uniquement</div><div class="s13">Mardi 6 octobre</div></div></div>
    <div style="display:flex;gap:12px;align-items:center;padding:14px;border:1px solid #E6E8F0;border-radius:14px"><span style="width:20px;height:20px;border-radius:10px;border:2px solid #ADB1C6"></span><div><div class="t15">Cette séance et les suivantes</div><div class="s13">38 séances jusqu'au 30 juin 2027</div></div></div>
  </div>
  <div class="field"><label>Motif <span class="s13" style="font-weight:500">· affiché à l'élève et à ses parents</span></label><div class="input" style="color:#6B7090">Ex. : examen au lycée</div></div>
  <div class="note">{icon('bell', 16, color='#2B3990', style='margin-top:2px')}<span>L'élève et ses parents sont prévenus tout de suite.</span></div>
  <div style="display:flex;gap:10px;justify-content:flex-end"><span class="btn ghost">Retour</span><span class="btn" style="background:#E03131;color:#fff">Annuler la séance</span></div>
</div>'''
    html = week_view()
    content = html[html.index('<main'):html.index('</main>') + 7]
    return teacher('Séance', 'Planning', content, modal, height=1120)


def phone(body, nav, lang='fr', active=0):
    tabs = ''.join(
        f'<div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:4px"><span style="width:54px;height:30px;border-radius:999px;display:flex;align-items:center;justify-content:center;{"background:#EEF0FA;color:#2B3990" if i == active else "color:#6B7090"}">{icon(ic, 20)}</span>'
        f'<span style="font-size:11px;font-weight:{800 if i == active else 600};color:{"#2B3990" if i == active else "#6B7090"}">{label}</span></div>' for i, (ic, label) in enumerate(nav))
    d = ' dir="rtl"' if lang == 'ar' else ''
    font = "'IBM Plex Sans Arabic',sans-serif" if lang == 'ar' else "'Plus Jakarta Sans',sans-serif"
    return f'''<div{d} style="width:390px;height:844px;background:#F6F7FB;border-radius:36px;overflow:hidden;position:relative;font-family:{font};box-shadow:0 20px 60px rgba(28,37,102,.15);border:1px solid #E6E8F0">
  <div style="height:772px;overflow:hidden;padding:18px;display:flex;flex-direction:column;gap:14px">{body}</div>
  <div style="position:absolute;bottom:0;inset-inline:0;height:72px;background:#fff;border-top:1px solid #E6E8F0;display:flex;align-items:center">{tabs}</div>
</div>'''


def phone_planning():
    def day(label, items):
        return f'<div style="display:flex;flex-direction:column;gap:10px"><div class="cap" style="font-size:13px;color:#1A1D3A">{label}</div>{items}</div>'

    def item(t1, t2, title, sub, color, extra='', dim=False, strike=False, reason=None):
        return (f'<div style="display:flex;gap:12px;padding:14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px;{"opacity:.6;" if dim else ""}">'
                f'<div style="width:46px;text-align:end;direction:ltr"><div style="font-size:14px;font-weight:800">{t1}</div><div class="s13" style="font-size:12px">{t2}</div></div>'
                f'<div style="width:4px;border-radius:2px;background:{color}"></div>'
                f'<div style="flex:1;display:flex;flex-direction:column;gap:4px"><div class="t15" style="{"text-decoration:line-through;color:#6B7090" if strike else ""}">{title}</div><div class="s13">{sub}</div>'
                f'{f"<div class=s13 style=color:#B42525>{reason}</div>" if reason else ""}{extra}</div></div>')

    student = phone(f'''
    <div style="display:flex;align-items:center;justify-content:space-between"><div style="font-size:24px;font-weight:700">الجدول</div><span class="btn secondary" style="width:40px;height:40px;padding:0;justify-content:center">{icon('bell', 18)}</span></div>
    <div style="display:flex;gap:8px">{''.join(f'<div style="flex:1;padding:10px 4px;border-radius:16px;text-align:center;{s}"><div style="font-size:12px;font-weight:700;{c1}">{d}</div><div style="font-size:20px;font-weight:700;{c2}">{n}</div></div>' for d, n, s, c1, c2 in [('الاثنين', 5, 'background:#fff;border:1px solid #E6E8F0', 'color:#6B7090', ''), ('الثلاثاء', 6, 'background:#1C2566', 'color:#ffffffb0', 'color:#fff'), ('الأربعاء', 7, 'background:#fff;border:1px solid #E6E8F0', 'color:#6B7090', ''), ('الخميس', 8, 'background:#fff;border:1px solid #E6E8F0', 'color:#6B7090', ''), ('الجمعة', 9, 'background:#fff;border:1px solid #E6E8F0', 'color:#6B7090', '')])}</div>
    {day('اليوم، الثلاثاء 6 أكتوبر', item('10:00', '11:30', 'رياضيات · السابعة أ', 'حضوري · القاعة 2', '#2B3990', f'<div style="margin-top:6px">{chip("انتهت", "green")}</div>', dim=True)
          + item('16:30', '18:00', 'رياضيات · السابعة أ', 'عن بعد · Google Meet', '#2B3990', f'<span class="btn primary sm" style="margin-top:8px;align-self:flex-start;height:40px">{icon("video", 16)}الانضمام إلى الحصة</span>'))}
    {day('الأربعاء 7 أكتوبر', item('15:00', '16:00', 'فيزياء · مراجعة', 'ألغيت', '#ADB1C6', strike=True, reason='السبب: امتحان في المعهد'))}
    {day('الخميس 8 أكتوبر', item('10:00', '11:30', 'رياضيات · السابعة أ', 'حضوري · القاعة 2', '#2B3990'))}
    ''', [('house', 'الرئيسية'), ('book', 'الدروس'), ('clipboard', 'الفروض'), ('calendar', 'الجدول'), ('chart', 'النتائج')], 'ar', 3)

    parent = phone(f'''
    <div style="display:flex;align-items:center;gap:12px"><div style="flex:1"><div class="s13" style="font-weight:600">Planning</div><div style="font-size:22px;font-weight:800">Séances d'Adam</div></div>{avatar('MG', 'turquoise', 40, True)}</div>
    <div style="display:flex;gap:8px"><span class="chip" style="background:#1A1D3A;color:#fff;padding:8px 14px;font-size:13px">Adam · 7ème</span><span class="chip" style="background:#fff;border:1px solid #E6E8F0;color:#1A1D3A;padding:8px 14px;font-size:13px">Lina · 9ème</span></div>
    <div style="display:flex;gap:10px">
      <div style="flex:1;padding:14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px"><div class="cap">PRÉSENCE</div><div style="font-size:22px;font-weight:800;margin-top:4px">95 %</div><div class="s13" style="font-size:12px">1 absence ce mois</div></div>
      <div style="flex:1;padding:14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px"><div class="cap">CETTE SEMAINE</div><div style="font-size:22px;font-weight:800;margin-top:4px">3 séances</div><div class="s13" style="font-size:12px">1 annulée</div></div>
    </div>
    {day("Aujourd'hui, mardi 6 octobre", item('10:00', '11:30', 'Math · 7ème A', 'Présentiel · Salle 2', '#2B3990', f'<div style="margin-top:6px">{chip("Présent", "green")}</div>', dim=False))}
    {day('Mercredi 7 octobre', item('15:00', '16:00', 'Physique · révision', 'Annulée', '#ADB1C6', strike=True, reason='Motif : examen au lycée'))}
    {day('Jeudi 8 octobre', item('10:00', '11:30', 'Math · 7ème A', 'Présentiel · Salle 2', '#2B3990', f'<div style="margin-top:6px">{chip("Prévue", "blue")}</div>'))}
    ''', [('dashboard', 'Aperçu'), ('calendar', 'Planning'), ('bell', 'Notifications')], 'fr', 1)

    body = f'''<div style="padding:48px;display:flex;gap:56px;align-items:flex-start;justify-content:center;min-height:940px;background:#EEF0FA">
  <div style="display:flex;flex-direction:column;gap:14px;align-items:center"><div class="cap" style="font-size:13px">ÉLÈVE · ARABE</div>{student}</div>
  <div style="display:flex;flex-direction:column;gap:14px;align-items:center"><div class="cap" style="font-size:13px">PARENT · FRANÇAIS</div>{parent}</div>
</div>'''
    return page('Planning élève et parent', body, width=1000, height=940)


if __name__ == '__main__':
    for name, html in [('Planning', week_view()), ('NouvelleSeance', new_session()), ('Seance', session_detail()),
                       ('PlanningPhone', phone_planning())]:
        (OUT / f'{name}.html').write_text(html)
        print(name)
