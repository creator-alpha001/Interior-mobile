# Aangan mobile

One Flutter application carrying two audiences: the customer and the
professional. Admin stays on the web, where it is.

The plan is `MOBILE.md` in the **web repository** (`D:\Interior`), and the design
language is `warm_architectural_minimalism/DESIGN.md` there. This repository is
deliberately separate from that one: the mobile client shares no code with the
web frontends, cannot import their TypeScript, and has its own release cadence.

## Where this is

**M8 through M11 complete.** What exists:

| | |
| --- | --- |
| `packages/design` | Tokens, theme, shared widgets, the OTP field |
| `packages/core_api` | 194 generated models, three typed clients, the dio interceptors |
| `packages/core_auth` | Bearer session in Keychain, OTP sign-in, role resolution, biometric resume |
| `packages/core_upload` | Compress, ticket, PUT, and a queue that survives the app closing |
| `packages/feature_vendor` | Onboarding gate, dashboard, leads, quote builder, visits, stage proof |
| `packages/feature_customer` | Requirement flow, quote comparison, agreements and signing, progress |
| `app` | Flavours, the router and its gates, sign-in, the component gallery |

M12 is next: push end to end, deep links, an offline read cache, the
accessibility pass, and `textScale` 1.3 goldens.

### Two things deliberately not built

**The blog and the estimator.** MOBILE.md open question 3 asks whether the
customer app needs them at all — *"the two largest pieces of M11 with the least
in-app value; a native blog exists mainly for deep links from search."* That is
a question for the client, and building them speculatively would be the
expensive way to find out the answer was no.

**Anything that implies a payment.** Payments are off-platform: terms are
recorded, not enforced. This matters more than it sounds, because the prototype
the whole design language came from was built around an escrow service — a
vault, tranches released by the client, a mediator on call. None of it was
drawn, and `feature_customer/test/boundaries_test.dart` fails the build if words
like "escrow" or "release funds" appear anywhere in the shell.

```bash
dart pub global activate melos    # once
melos bootstrap
melos run check                   # analyze + test, every package
```

To look at the gallery: `cd app && flutter run`, or navigate to `/_gallery` in
any non-production build.

### Signing in

There is no "Sign up" button anywhere, and that is deliberate: an unrecognised
number creates a customer account, so signing up and signing in are one action.
Nothing asks for a name until a code has verified for a number the server has
not seen.

The six-digit field is **one `TextField` with six boxes drawn over it**, never
six fields. SMS autofill and a clipboard paste both deliver all six digits to
whichever field has focus, so six one-character fields keep the first and
silently drop five — no error, and no way for the person to tell what happened.
The web shipped that version. `packages/design/lib/src/otp_field.dart` is the
fix, and four tests hold it in place.

Staff are refused on this path, told why, and pointed at the web panel. Ops and
admin have no mobile surface, and a valid password that appears to do nothing is
how a support ticket starts.

### Flavours

Nothing defaults to production. A build that forgets to say where it is going
talks to localhost and fails loudly on a device, which is the failure you want.

```bash
flutter run --dart-define=AANGAN_ENV=staging
flutter run --dart-define=AANGAN_API_URL=http://192.168.1.20:4000   # a laptop on the same wifi
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
`openapi.json` from its route manifest; `contract/openapi.json` here is this
app's pinned copy of it, and the Dart comes from that.

```bash
# 1. in D:\Interior — regenerate the document from the manifest
npm run openapi

# 2. here — pull it in, then regenerate the client
dart run tool/sync_contract.dart
melos run contract
```

`melos run contract` runs three steps and the order matters:

```
swagger_parser  ->  tool/fix_generated.dart  ->  build_runner
```

The middle step is not optional and is not a patch — it is re-run from scratch
every time. It exists because swagger_parser emits freezed-2 syntax (freezed 3
needs `abstract class`, and freezed 2 is unavailable: retrofit_generator 10
requires freezed 3), because our discriminated unions are necessarily modelled
twice in OpenAPI, and because the **staff client is deleted**. That last one is
deliberate: `openapi.json` documents the whole API including `/ops/*`, but admin
is web-only, and those responses carry commission figures and unmasked customer
phone numbers. With no generated client, a screen in this binary cannot call
them — there is no method to call.

The generated sources are committed, and CI regenerates and fails on a diff. A
generator nobody runs is worse than no generator: the stale output still looks
authoritative. The `.g.dart` and `.freezed.dart` derivatives are *not* committed
— build_runner recreates them deterministically, and they would triple the size
of every contract diff.

### Guarantees that survive code generation

Asserted in `packages/core_api/test/contract_guarantees_test.dart`, because the
generator will not give you any of them:

- **`MaskedClientSummary` has no phone or email field.** The web repository
  checks this three ways already — the schema has no such key, a contract test
  follows every `$ref` through every `/vendor` response, and an integration test
  greps real responses for seed numbers. This is the fourth place it could
  break, and the one closest to a vendor's handset.
- **`Rupees` is an `int`.** Never a `double`. Money in a floating-point type is
  how ₹1 goes missing.
- **The actor union is exhaustive.** `switch` over `Actor` has no default
  branch, so a fifth role added to the contract stops the build. This only works
  because the document describes it as `oneOf` + `discriminator`; a bare `anyOf`
  generated `ActorUnion.variant1`, which is a union you cannot read.
- **No Flutter import in `core_api`**, so the contract layer stays testable
  without a widget tree.
- **No dialer or SMS launcher.** Not for the customer, not "just for the
  coordinator". The check covers `core_api` today; extend it to
  `feature_vendor` when that package exists.
