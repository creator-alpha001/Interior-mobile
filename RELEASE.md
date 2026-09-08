# Release

What a submission needs, and what is still missing. Written to be worked
through rather than read.

Most of M13 is not code. The code parts — the forced upgrade, account deletion
and the privacy manifest — are done and tested; everything below them needs an
account, a device, or a decision.

---

## Blocking, and none of it is code

| | Why it blocks | Rough lead time |
| --- | --- | --- |
| **Newsreader and Manrope** | The app does not currently look like the design. Both are open-licence, but the `.ttf` files are not in the repository, so every screen renders in Roboto — and no screenshot is worth taking until they land | An afternoon |
| **Noto Serif / Sans Devanagari** | The app ships Hindi. Without these it renders in whatever Devanagari the platform happens to have, so it looks like different software in the two languages. `AanganFonts.serifFallback` already names them; only the files are missing | The same afternoon |
| **A Firebase project** | Push is inert without one. Not release-blocking on its own: notifications still go out by SMS | Days |
| **An R2 bucket** | Photographs work against the API's local driver, which production refuses. Stage proof is the vendor's core action | Days |
| **DLT registration** | Nobody can sign in without SMS. The longest lead time of the three | Days to weeks |
| **Apple and Google developer accounts** | Nothing can be submitted | Days, plus Apple's verification |

Fonts first. Everything visual is blocked behind them, including the screenshots
the listings need and the golden tests M12 could not write. All four are
open-licence and none needs a decision — they need somebody to download them
into `app/fonts/` and add the `flutter: fonts:` block. Nothing in the code
changes: the families are already named, and Flutter falls through to the
platform until the files exist.

---

## Review demo accounts

MOBILE.md §7.8: *"two audiences in one binary needs a demo account for each in
the review notes, or review will bounce it for hidden functionality."*

A reviewer opening this app sees a sign-in screen and, with one number, a
customer. Nothing on that path reveals the vendor half exists — which is exactly
what "hidden functionality" means to a reviewer.

Provide both, from the seed:

| Role | Number | What the reviewer sees |
| --- | --- | --- |
| Customer | `9839012477` | Three requirements, quotes to compare, an agreement to sign, a live project |
| Professional | `9810000000` | Verified and signed: leads, the quote builder, visits, stage proof |
| Professional, unsigned | `9810081474` | The onboarding gate. Worth mentioning so the gate does not read as a bug |

**The OTP is the problem.** Review happens outside India and cannot receive an
Indian SMS. Options, in order of preference:

1. A review-only build pointed at a staging API with `OTP_DEV_ECHO=true`, so the
   code comes back in the response. Staging holds seed data and no real
   customers.
2. A fixed code for the three demo numbers on staging only, refused in
   production by config.

Whichever, say so in the review notes. A reviewer stuck at an OTP screen rejects.

---

## Store listing

Copy below is a starting point in the product's own voice. Not written to
please a search index.

### Name

`Aangan` — 6 characters, no subtitle needed.

### Subtitle (iOS, 30 characters)

`Interior work, coordinated`

### Short description (Play, 80 characters)

`Interior design, furniture, fabrication and painting — with one person who answers.`

### Full description

> Aangan connects you to verified professionals for interior design, furniture
> work, fabrication and painting — and stays between you for the whole job.
>
> **Tell us once.** Describe what you need, add a few photographs, and we take
> it from there. You do not need an account to start; your number sets one up
> at the end.
>
> **Three quotes, compared properly.** We call professionals ourselves before
> offering them your job. You see their price, their timeline, and their rating
> *in that specific trade* — because a good carpenter is not automatically a
> good painter.
>
> **One person who answers.** You talk to us, not to four tradespeople. We carry
> questions across and bring answers back, so a question asked once reaches
> everybody quoting.
>
> **Work checked, not claimed.** Professionals submit photographs at each stage.
> Our team checks them before the stage counts as done — so progress means
> somebody looked, not somebody said so.
>
> Payments are arranged directly with your professional. Aangan does not handle
> money.

That last line is not a disclaimer to bury. Payments are off-platform, and a
listing that implied otherwise would be the most damaging sentence we could
write.

### Keywords (iOS, 100 characters)

`interior,carpenter,furniture,painting,fabrication,renovation,contractor,designer,home,quotes`

### Category

Primary **Lifestyle**, secondary **House & Home**. Not Business: the buyer is a
homeowner.

---

## Languages

The app ships **English and Hindi**, and follows the device unless somebody
chooses otherwise — `Account → Language`, or the vendor's `More` tab. Every
string in both shells is translated; `app/test/l10n_test.dart` fails the build
on one that is not, and on a translation no screen asks for any more.

Two things stay English on purpose and should not read as gaps:

- **Anything the server wrote.** Error messages, the onboarding step labels and
  `blockedReason` come from the API as prose. Translating them client-side would
  mean keeping a shadow copy of every sentence the API can produce, and getting
  it out of step would show somebody a *different* reason than the one that
  applied. It is a server change when it happens.
- **`Aangan`, `OTP`, `GST`, `DELETE`.** The product's name, three loanwords
  nobody translates in speech, and one typed confirmation matched against a
  literal in the contract.

Screenshots are needed in both languages once the fonts land — Devanagari sits
taller than Latin, and the display sizes want an optical check rather than a
check that the glyphs appear at all.

---

## Screenshots

Six per platform, in the design language. None can be taken until the fonts
land.

1. Home — the editorial hero and four trades
2. The requirement flow, step 1
3. Quote comparison — the strongest screen in the app
4. An agreement ready to sign
5. Progress, with a stage approved and one being checked
6. The vendor's leads — establishes the second audience for a reviewer

Real device frames, `textScale` at 1.0, and the seed data rather than lorem.
Rupee figures must show Indian grouping: `₹4,50,000`.

---

## Data Safety (Play) and App Privacy (iOS)

`app/ios/Runner/PrivacyInfo.xcprivacy` is written and is the source of truth.
The Play form asks the same questions in a different order:

| Data | Collected | Shared | Why |
| --- | --- | --- | --- |
| Phone number | Yes | No | It is the account. OTP sign-in, no password |
| Name | Yes | No | So a coordinator and a professional know who they are working for |
| Address | Yes | With the assigned professional only | Released per service, and only once a visit is confirmed |
| Photographs | Yes | With professionals quoting that job | Room photographs, and stage proof |
| Messages | Yes | No | Every thread is with Aangan, never between customer and professional |
| Crash data | Yes, when a DSN is set | With Sentry | No user record attached |

**Answer "no" to advertising or tracking, honestly.** There is no advertising
SDK, no attribution SDK, and no third-party analytics. The only network
destinations are the Aangan API and its object storage.

**Account deletion:** `Account → Close your account`, in-app, no email required.
Both stores check this. It clears personal detail and frees the number;
agreements, invoices and reviews are retained because they are commercial
records with a second party, and the screen says so before anybody acts.

---

## Permissions, and when they are asked

MOBILE.md §7.8: request each in context, at the moment of use, with a sentence
of why. Never on first launch — it costs a conversion and a review question.

| Permission | Asked when | Not asked |
| --- | --- | --- |
| Camera | The person taps Camera on a photograph step | On launch |
| Photos | They tap Gallery | On launch |
| Notifications | After the first requirement or the first lead, when there is something worth being told about | On launch |
| Location | **Never.** No "near me" filter is built, so asking would cost a review question for nothing | |

---

## Forced upgrade

`GET /app/version` returns `minBuild`, and `MOBILE_MIN_BUILD` on the API is the
lever. Once a bad build is on somebody's phone it is the only one there is.

- Builds are stamped by `--dart-define=AANGAN_BUILD=<n>`, the same number given
  to the store.
- A build below the floor sees one screen with no way past it.
- **A build that cannot reach the server is never blocked.** An upgrade gate
  that locks people out because the API is down is a worse outage than the bug
  it guards against.
- A development build (`AANGAN_BUILD` unset) is not gated, and does not even ask.

Raising the floor is an environment variable and a restart. Use it for
data-losing bugs, not for nagging.

**Still to wire:** the store button on the blocked screen needs the real
listing URLs, which do not exist yet. It currently tells the person to search
for "Aangan", which is honest rather than a dead button.

---

## Staged rollout

- **Play:** 5% → 20% → 50% → 100%, a day at each step, watching crash-free
  sessions. Halt on any regression rather than pressing on.
- **iOS:** phased release over 7 days, which is the default and correct here.
- Do not raise `MOBILE_MIN_BUILD` during a rollout. Forcing people onto a build
  that is still rolling out asks them to install something they cannot get.

---

## Sentry

Not wired yet. The API already carries `X-Request-Id` end to end and reports to
Sentry when a DSN is set, so the pieces are there for one incident to have both
halves — a screenshot and a server log telling the same story.

When it is added:

- Tag the release as `aangan-mobile@<version>+<build>`, matching the store build.
- Attach `X-Request-Id` from the response, which the client already reads.
- Strip bodies, headers and any user record on the way out, matching the API's
  configuration.
- Off unless a DSN is set, so a developer build reports nothing.

---

## The checklist

Ordered by what unblocks the most.

- [ ] Bundle Newsreader, Manrope and the two Noto Devanagari faces, then take
      the golden baselines M12 could not — in both languages
- [ ] Apple and Google developer accounts
- [ ] DLT registration for MSG91
- [ ] R2 bucket, and `STORAGE_DRIVER=r2`
- [ ] Firebase project, then `PushTokenSource` on `firebase_messaging`
- [ ] Bundle identifiers, signing certificates, provisioning profiles
- [ ] Staging API for review, with the demo accounts reachable
- [ ] Screenshots, six per platform
- [ ] Data Safety form and App Privacy answers, from the table above
- [ ] Sentry DSN and release tagging
- [ ] Set `MOBILE_MIN_BUILD=0` for the first release, and leave it there
- [ ] Submit, and expect one rejection — two audiences in one binary usually
      draws a question the first time
