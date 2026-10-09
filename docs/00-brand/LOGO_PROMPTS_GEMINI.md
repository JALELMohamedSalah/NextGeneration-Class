# Logo prompts for Gemini

Use these prompts in the Gemini app (gemini.google.com, ask it to create an image) or in Google AI Studio with an image generation model.

## Before you start

- Write prompts in **English**: image models follow English instructions more precisely.
- Use **one chat per concept**. Then refine inside that chat ("keep everything, only change...").
- AI images often misspell text. Generate the **symbol alone** too (prompt 2), and add the wordmark yourself with Plus Jakarta Sans.
- Gemini returns a raster image (PNG/JPG) on a background. Vectorize the chosen design afterwards (see `BRAND.md`, workflow).
- Ask for the same prompt 3 or 4 times to get variations, then keep the best.

Brand colors used below: Indigo Nuit `#2B3990`, Turquoise Progrès `#12A39A`, Jaune Étincelle `#FFB020`.

---

## Prompt 1: Full logo, recommended concept "NG Rising"

```
Design a professional logo for an education app called "NextGeneration Class".
It is a private platform a teacher uses to organize her lessons, homework,
quizzes and student progress for middle and high school students in Math and
Physics. The audience is students aged 11 to 18 and their parents.

Symbol: a minimal geometric monogram of the letters "N" and "G" drawn with one
continuous stroke of even thickness. The horizontal bar of the "G" extends to
the right and turns into an upward arrow, suggesting progress and moving to the
next level. A small round spark sits at the tip of the arrow, like an idea
lighting up.

Wordmark: the text "NextGeneration Class" to the right of the symbol, in a
clean modern geometric sans-serif similar to Plus Jakarta Sans. "NextGeneration"
in extra bold, "Class" in medium weight. Spell it exactly: NextGeneration Class.

Colors: deep indigo #2B3990 for the letters N and G and for the word
"NextGeneration". Turquoise #12A39A for the arrow and the word "Class". Warm
amber #FFB020 only for the small spark. Flat solid colors.

Style: flat vector logo, geometric, clean, balanced, generous negative space,
modern and trustworthy, friendly but not childish. Thick strokes so the symbol
stays readable as a small app icon.

Output: the logo centered on a plain pure white background, horizontal layout,
square 1:1 image, high resolution, wide margins around the logo.

Avoid: gradients, 3D, shadows, glossy effects, outlines, mockups, photos,
graduation caps, owls, pencils, light bulbs, clip art, extra words, slogans,
watermarks.
```

## Prompt 2: Symbol only, app icon

```
Create a square mobile app icon for an education app called "NextGeneration
Class". No text at all.

Background: solid deep indigo #2B3990 filling the whole square, edge to edge,
no rounded corners and no border (the phone applies its own mask).

Symbol in the center: a minimal geometric monogram of the letters "N" and "G"
drawn with one continuous white stroke of even thickness. The horizontal bar of
the "G" extends to the right and turns into an upward arrow in turquoise
#12A39A. A small round spark in amber #FFB020 sits at the tip of the arrow.

The symbol fills about 55 percent of the icon width, perfectly centered, with
even empty space around it, so it survives circle and rounded-square masks.

Style: flat vector, bold simple shapes, readable at 48 pixels. 1024 x 1024.

Avoid: text, letters other than N and G, gradients, 3D, shadows, glare, extra
decorations, frames, mockups.
```

## Prompt 3: Alternative concept "Rising book"

```
Design a flat vector logo for an education app called "NextGeneration Class".

Symbol: an open book seen from the front. Its right-hand pages are drawn as
three steps rising from left to right, like a staircase, suggesting students
climbing to the next level. A small amber #FFB020 spark above the highest step.

Wordmark to the right: "NextGeneration Class" in a modern geometric
sans-serif, "NextGeneration" extra bold in deep indigo #2B3990, "Class" medium
weight in turquoise #12A39A. Spell it exactly: NextGeneration Class.

Book in deep indigo #2B3990, steps in turquoise #12A39A. Flat solid colors,
clean geometry, thick lines, friendly but serious, readable at small sizes.

Plain pure white background, centered, square 1:1, high resolution, wide margins.

Avoid: gradients, 3D, shadows, realistic paper texture, graduation caps, owls,
pencils, clip art, extra words, watermarks.
```

## Prompt 4: Alternative concept "Three chevrons"

```
Design a minimal flat vector logo for an education app called "NextGeneration
Class".

Symbol: three upward-pointing chevrons stacked vertically and growing in size
from bottom to top, like three generations or three school levels. Bottom
chevron in deep indigo #2B3990, middle in a lighter indigo, top in turquoise
#12A39A, with a small amber #FFB020 dot above the top chevron.

Wordmark to the right: "NextGeneration Class", modern geometric sans-serif,
"NextGeneration" extra bold in deep indigo #2B3990, "Class" medium in turquoise
#12A39A. Spell it exactly: NextGeneration Class.

Flat solid colors, crisp geometry, strong and simple, readable as a favicon.
Plain pure white background, centered, square 1:1, high resolution, wide margins.

Avoid: military insignia look, gradients, 3D, shadows, clip art, extra words,
watermarks.
```

## Prompt 5: Alternative concept "NG badge"

```
Design an app-icon-first logo for an education app called "NextGeneration Class".

Symbol: the letters "NG" as a bold custom geometric monogram, white, inside a
rounded square filled with deep indigo #2B3990. The end of the "G" forms a small
upward arrow in turquoise #12A39A, with a tiny amber #FFB020 spark at its tip.

Wordmark to the right of the badge: "NextGeneration Class" in a modern
geometric sans-serif, "NextGeneration" extra bold in deep indigo, "Class" medium
in turquoise. Spell it exactly: NextGeneration Class.

Flat vector, clean, modern, trustworthy. Plain pure white background, centered,
square 1:1, high resolution, wide margins.

Avoid: gradients, 3D, shadows, glossy effects, extra words, watermarks.
```

---

## Follow-up prompts (paste in the same chat to refine)

Simplify:
```
Keep the same design and colors but simplify the symbol: fewer details,
thicker strokes, so it is still clear at 32 pixels.
```

Fix the text:
```
Keep everything identical but fix the text. It must read exactly
"NextGeneration Class" with no other words and no spelling changes.
```

Stacked version:
```
Same logo, stacked layout: the symbol on top, the text "NextGeneration Class"
centered below it. Same colors, white background.
```

One-color versions:
```
Show the same logo twice side by side: once entirely in deep indigo #2B3990 on
white, once entirely in white on a deep indigo #2B3990 background. No other
colors.
```

Symbol alone from the chosen logo:
```
Keep only the symbol of this logo, without any text, centered on a plain white
background, square, high resolution.
```

Color check:
```
Use only these flat colors and nothing else: #2B3990, #12A39A, #FFB020 and
white. No gradients, no shading.
```

---

## Choosing the final logo

- [ ] Readable at 16 px (favicon) and 48 px (app icon)
- [ ] Works in one color (Indigo only, white only)
- [ ] No hidden letters or unwanted shapes when seen small or upside down
- [ ] Does not look like an existing brand (Google reverse image search)
- [ ] The client likes it on the login screen mockup and as a phone icon
- [ ] Final wordmark set with the real font, not taken from the AI image
