# Aangan mobile

One Flutter application carrying two audiences: the customer and the
professional. Admin stays on the web, where it is.

The plan is `MOBILE.md` in the **web repository** (`D:\Interior`), and the design
language is `warm_architectural_minimalism/DESIGN.md` there. This repository is
deliberately separate from that one: the mobile client shares no code with the
web frontends, cannot import their TypeScript, and has its own release cadence.

## Where this is

**M8 — Foundation, in progress.** What exists:

| | |
| --- | --- |
| `packages/design` | Tokens, theme and the shared widgets. Complete for the components drawn so far |
| `app` | Runs the component gallery. No router, no networking, no screens yet |

What M8 still needs, in order: the generated `core_api`, dio and its
interceptors, a `go_router` skeleton, and CI.

```bash
dart pub global activate melos    # once
melos bootstrap
melos run check                   # analyze + test, every package
```

To look at the gallery:

```bash
cd app && flutter run
```

## The design system is the deliverable of this phase

`packages/design` is not scaffolding for the real work — at M8 it *is* the work.
An untested design system drifts within a month, so the rules in `DESIGN.md` are
asserted in `packages/design/test/` rather than written down and hoped for:
Indian digit grouping, the no-shadow rule across every component that could
reintroduce one, the pill radius being reserved for status chips, 48dp touch
targets, and terracotta rather than ink landing on `primary`.

The gallery in `app/lib/gallery.dart` renders every component in every state. It
is what the golden tests will photograph, and it is the honest check on the
colour rule: every tone a status pill can take is on one screen, so "sage is
never decorative" is something you can look at.

### Two known gaps, both deliberate

**The fonts are not bundled yet.** Newsreader and Manrope are named throughout
`typography.dart`, but the `.ttf` files are not in the repository, so everything
currently renders in the platform default. The design's editorial character
comes almost entirely from Newsreader, so the gallery does not yet look like the
reference renders. This is also why there are **no golden tests yet** — a golden
taken today would bake in Roboto and have to be thrown away the day the fonts
land. Bundle them as assets rather than fetching through `google_fonts`: a
vendor on a site with no signal should not get a fallback-font first paint.

**Light mode only.** Not an oversight — `DESIGN.md` §3.8, on the record. The
palette is warm lime-washed plaster and the argument is daylight on stone; a
mechanical inversion gives a muddy brown-grey app that reads as a bug. Doing it
properly is real design work. Deferring costs exactly one discipline: every
screen reads `Theme.of(context).colorScheme` and `AanganPalette`, never a
literal. One screen reaching for a hex value breaks the promise that dark mode
is later a single file.

## Layout

```
app/                    The runnable app. Entrypoint, DI, router, flavours.
packages/
  design/               Tokens, theme, every shared widget. No business logic.
  core_api/             Generated models + typed client. No UI, no Flutter.   (M8)
  core_auth/            Session, OTP, secure storage, role resolution.        (M9)
  core_upload/          Ticket -> PUT -> assetId, with a resumable queue.     (M10)
  feature_customer/     Customer shell and its screens.                       (M11)
  feature_vendor/       Vendor shell and its screens.                         (M10)
```

`design` depends on Flutter and nothing else. `core_api` will depend on neither
Flutter nor `design` — that is what makes it generatable and testable without a
widget tree. **Neither feature package may import the other.**

## The contract

`core_api` is generated, never hand-written. The web repository emits
`openapi.json` from its route manifest, and the Dart models come from that:

```bash
# in D:\Interior
npm run openapi          # regenerate
npm run openapi:check    # CI: fails if the committed document is stale
```

Two things the generator will not give you and that must be added by hand:

- **`MaskedClientSummary` must have no phone or email field.** It does not today,
  and the web repository has a contract test that fails if a schema grows one —
  following `$ref`s through every `/vendor` response. Do not weaken it here.
- **`Rupees` is an `int`.** Never a `double`. Money in a floating-point type is
  how ₹1 goes missing. `packages/design/lib/src/money.dart` is an extension type
  over `int` for that reason, and a test asserts it.

There is also **no dialer or SMS launcher anywhere in `feature_vendor`**, ever.
Not for the customer, not "just for the coordinator". Add a grep test for `tel:`
and `url_launcher` inside that package when it exists.
