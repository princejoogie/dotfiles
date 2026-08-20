---
name: HTML
description: Explicit /html workflow for self-contained HTML artifacts. Routes to internal design, wireframe, prototype, plan, and diagram guidance; never invoke automatically.
slash: true
metadata:
  opencode/autoinvoke: false
---

# HTML

Build one self-contained HTML file that makes the subject clearer, easier to use, or easier to understand. The standard is consistent care, not a consistent look. Do not reproduce a house palette, typography stack, card system, or layout from prior runs.

## Route the request first

Use the narrowest internal reference that owns the main review question. Read
the selected reference before building:

- Read and compose [`design-artifact`](references/design-artifact.md) with the
  chosen workflow when palette, type, composition, theming, or overall visual
  register remain open. It provides creative direction; it does not replace the
  specialist that owns fidelity, structure, or behavior.
- Read and follow [`html-wireframe`](references/html-wireframe.md) when structure, information hierarchy, navigation, or task flow is still unsettled. It should remain visibly low fidelity and may compare two or three layout directions.
- Read and follow [`html-prototype`](references/html-prototype.md) when the user needs a polished mockup or a working interactive flow. A mockup is the static fidelity mode inside that reference.
- Read and follow [`html-plan`](references/html-plan.md) when the artifact is primarily a plan, roadmap, implementation sequence, or rollout document whose source commitments must remain easy to verify.
- Read and follow [`html-diagram`](references/html-diagram.md) when relationships, sequence, topology, state, hierarchy, or system behavior are the main content.
- Continue with `html` for reports, explainers, presentations, landing pages, data stories, tools, and mixed artifacts that do not have a clearer owner.

These references are private to this skill. Do not invoke or advertise them as
separate skills, and do not ask the user to install anything else.

## Read the room before designing

Inspect the user's request and any material they supplied. When working in a repository, look for its design language in `AGENTS.md`, `CLAUDE.md`, design-system documentation, tokens, existing components, and nearby artifacts.

Authority runs in this order:

1. The user's explicit visual and functional instructions.
2. The project's established design system and conventions.
3. The subject matter, audience, and purpose of this artifact.
4. Your own design judgment.

Before coding, settle five things in working notes:

- **Audience and job:** who will use this, and what should they understand or do?
- **Form:** document, presentation, interface, diagram, or data visualization.
- **Register:** quiet and workmanlike, polished and editorial, or intentionally expressive.
- **Fidelity:** whether to preserve the user's structure and wording or synthesize more freely.
- **Interaction:** what benefits from exploration, sequencing, filtering, or motion, if anything.

If the project already answers the visual questions, follow it. Otherwise read
and compose [`design-artifact`](references/design-artifact.md). Use
[`references/creative-direction.md`](references/creative-direction.md) only as
lighter fallback guidance when the full design reference is unnecessary.

## Load only the guidance the artifact needs

- For reports, briefs, plans, explainers, and decks, read [`references/documents-and-presentations.md`](references/documents-and-presentations.md).
- For interfaces, calculators, and other tools that remain in this broad skill, read [`references/interfaces.md`](references/interfaces.md).
- For architecture, process, sequence, state, hierarchy, or concept diagrams, read [`references/diagrams.md`](references/diagrams.md).
- For quantitative charts, tables, metrics, or data stories, read [`references/charts-and-data.md`](references/charts-and-data.md).

Requests can span forms. Read every reference that materially applies, then give the artifact one coherent direction.

## Write human copy

Invoke the sibling [`unslop`](../unslop/SKILL.md) skill before drafting any
visible copy. Apply it to headings, labels, controls, body text, empty states,
errors, and sample data. Run its self-audit again after the artifact is built
and rewrite any copy that still reads as generic, promotional, mechanical, or
AI-generated.

Never use numbered section labels such as `01`, `02`, and `03`, or arrange the
page as a numbered procession of cards. Use descriptive headings and the
composition itself to establish structure. Numbers belong in source data and
genuinely ordered instructions, not in section decoration.

## Build contract

- Produce one `.html` file with its essential CSS and JavaScript inline. It should work when opened directly, without a build step. Do not require a network connection unless the user permits external dependencies.
- Use real content. Do not fill prominent space with placeholder copy, decorative statistics, or controls that do nothing.
- Let content determine structure. A sequence should read in order; a comparison should make differences easy to scan; an interface should expose state and actions; a diagram should make relationships legible.
- Use semantic HTML, responsive layout, accessible contrast, visible keyboard focus, and reduced-motion handling. Make interactive elements work with a keyboard.
- Keep the page body free of accidental horizontal overflow. Put intentionally broad content in a contained scrolling or pannable region.
- Define a small set of CSS tokens for the chosen direction and use them consistently. Tokens are an implementation tool, not a predetermined palette.
- Treat motion as explanation or feedback. If removing an animation loses no meaning or useful feedback, remove it.
- Follow the user's or project's theme policy. When none exists, give durable utility artifacts considered light and dark themes if that improves their use. A deliberate single-theme concept is valid.

## Finish the work

Write the file to the requested location, or choose a clear filename in the current workspace. When browser tooling is available, open it and inspect a wide and narrow viewport. Exercise its controls, check the console, and fix clipping, overlap, illegible text, broken states, and accidental overflow.

Before delivery, run one originality check: if the subject were swapped for a neighboring topic, would the same visual concept still make just as much sense? If yes, the direction is too generic; revise the composition, type, color, imagery, or interaction so it belongs to this subject.

Return the absolute path and a short description of the artifact's visual and interaction choices.
