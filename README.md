# InterioBee mobile

One Flutter application carrying two audiences: the customer and the
professional. Admin stays on the web, where it is.

The plan is `MOBILE.md` in the **web repository** (`D:\Interior`), and the design
language is `warm_architectural_minimalism/DESIGN.md` there. This repository is
deliberately separate from that one: the mobile client shares no code with the
web frontends, cannot import their TypeScript, and has its own release cadence.

## Where this is

**M8 through M13 complete.** What exists:

| | |
| --- | --- |
| `packages/design` | Tokens, theme, shared widgets, the OTP field |
| `packages/core_api` | 194 generated models, three typed clients, the dio interceptors |
| `packages/core_auth` | Bearer session in Keychain, OTP sign-in, role resolution, biometric resume |
| `packages/core_push` | Device registration behind a driver, and the notification deep-link table |
| `packages/core_upload` | Compress, ticket, PUT, and a queue that survives the app closing |
| `packages/feature_vendor` | Onboarding gate, dashboard, leads, quote builder, visits, stage proof |
| `packages/feature_customer` | Requirement flow, quote comparison, agreements and signing, progress |
| `app` | Flavours, the router and its gates, sign-in, the component gallery |

The code is done. **`RELEASE.md` is what remains**, and almost none of it is
code: developer accounts, DLT registration, an R2 bucket, a Firebase project,
screenshots, and the store forms.

**Bundle the fonts first.** Newsreader and Manrope are named throughout
`typography.dart` but the files are not in the repository, so every screen
renders in Roboto and the app does not look like the design at all. Screenshots
and the golden baselines are both blocked behind them, and they are an
afternoon's work.

### What M12 left short, deliberately

**Deep links reach the right tab, not the right record.** The shells are
`IndexedStack`s with their own `Navigator`, not nested `go_router` routes, so a
"new lead" push opens the vendor's Leads tab rather than lead `ld-42`. That is
short of MOBILE.md §9's bar — *"Every push in 7.2 lands on the right screen"* —
and closing it means moving both shells onto nested routes so every record has a
URL. Recorded here rather than half-done: a deep link that silently drops its id
is worse than one that admits it only reaches the list.

**Push has no Firebase project, so `NoPushTokens` is the default.** Everything
downstream of the token is built and tested; the Firebase implementation is one
class conforming to `PushTokenSource`. Adding `firebase_messaging` now would
mean the app could not build until a project existed. Nothing is lost meanwhile:
the notification row is still written inside the transaction that caused it and
still goes out by SMS. Push only adds the buzz.

**No golden tests.** Still blocked on the fonts, below. What a golden would have
caught about layout at `textScale` 1.3 is asserted without pixels in
`packages/design/test/accessibility_test.dart`.

**The Hindi decision is unmade.** MOBILE.md open question 1, and it is the
client's: bundling Devanagari fallbacks now, or shipping English-only at v1 and
recording that as a decision rather than discovering it in a translation sprint.

### One thing deliberately not built

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

### Running it

**From `app/`, not from the root.** The root is the melos workspace and has no
`lib/`, so `flutter run` there fails with `Target file "lib\main.dart" not
found` — which reads like a missing file rather than a wrong directory.

```bash
cd app
flutter run
```

`.vscode/launch.json` carries the same three configurations, so the IDE's run
button works from anywhere in the repository.

The app talks to `http://10.0.2.2:4000` by default, which is the host machine as
seen from the Android emulator. Start the API first — `npm run dev` in the web
repository's `apps/api` — or every screen shows "No connection", correctly.

To look at the component gallery, navigate to `/_gallery` in any non-production
build.

### Signing in

There is no "Sign up" button anywhere, and that is deliberate: an unrecognised
number creates a customer account, so signing up and signing in are one action.
Nothing asks for a name until a code has verified for a number the server has
not seen.

**Google sign-in asks for a city, not a phone number.** It used to do the
opposite: an unlinked Google account came back with a link token, the state
moved to the phone stage, and somebody who had just authenticated was shown a
number field with no way past it — because the server's `users.mobile` was NOT
NULL. Both that column and `users.city_id` are nullable now, so
`profile_required` goes to `SignInStage.welcome`, which asks for a name and a
city and has a skip button beside Continue that is the same size.

The number is asked for *after* the account exists, through `/me/mobile/request`
and `/me/mobile/confirm` — deliberately not the sign-in pair. Those ask "who is
this", and an unknown number becomes an account; these ask "is this number
yours" on behalf of a session, so a code can never create or switch one.
`AuthController.setupIncomplete` is what a screen reads to decide whether to
offer either question again; it is an invitation, never a gate.

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
cd app
flutter run --dart-define=INTERIOBEE_ENV=staging
flutter run --dart-define=INTERIOBEE_API_URL=http://192.168.1.20:4000   # a laptop on the same wifi
```

A device on the same wifi also needs that machine's address added to
`app/android/app/src/debug/res/xml/network_security_config.xml`, which permits
cleartext to two hosts rather than to everything.

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
screen reads `Theme.of(context).colorScheme` and `InterioBeePalette`, never a
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
