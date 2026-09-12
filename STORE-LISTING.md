# Play Store listing — every field, filled in

Copy each block into Play Console. Nothing here is a placeholder except the
items marked **[you]**, which need a decision or an account only you have.
Character limits are Play's, and each block is within them.

---

## Store listing

**App name** (30)

```
Decora Shine
```

**Short description** (80)

```
Free quotes from verified interior, furniture, fabrication and painting pros.
```

**Full description** (4000)

```
Homes that feel like you.

Decora Shine brings you three written quotes for any home job — interiors,
furniture, fabrication or painting — from professionals our team has checked
and approved for that specific trade.

HOW IT WORKS

1. Tell us what you need. One short form, in your own words. Pick one trade or
   several; a single dining table and a full home take the same two minutes.
2. We call you. A coordinator takes the detail the form left out, so every
   professional works from the same brief.
3. Three professionals visit and quote. We ring them first, so everyone who
   comes is available and interested. Each measures on site and writes a quote
   with a timeline, a warranty and a materials list.
4. Compare side by side. One table per trade: price, timeline, warranty,
   materials, rating. No sales pressure, and nothing moves until you choose.
5. Sign and move in. A written agreement, then day-by-day progress with
   photographs until handover.

WHY IT IS DIFFERENT

Rated per trade, not on one average. A professional who is excellent at
painting and average at carpentry shows exactly that. Approval is per trade
too, so a fabricator cannot start taking painting jobs without being checked
for it separately.

One person who answers. You talk to us, not to four tradespeople. We carry
messages both ways, and there is one conversation per job.

Your number is never shared with professionals. Your full address is released
to one professional only when you confirm a site visit with them.

Stages checked against photographs. Work counts as done when our team has seen
evidence of it, not when somebody says so.

Free, with nothing owed. Quotes cost nothing and you are not committed to any
of them. Professionals pay us a commission when they win work, which does not
change what you are quoted.

FOR PROFESSIONALS

Leads in your trade and your city, a quote builder, site visits, stage proof
and commission statements — and a public profile you post your own finished
work to, with photographs straight from your phone.

Available in English and Hindi.
```

**Category** — Lifestyle. (House & Home is not a Play category; Lifestyle is
where Houzz, Livspace and Urban Company sit.)

**Tags** — Home improvement, Interior design, Services.

**Contact details**

```
Email:   hello@decorashine.com
Website: https://www.decorashine.com
Phone:   [you]
```

**Privacy policy URL**

```
https://www.decorashine.com/privacy
```

**Account deletion URL** — Play requires this of any app that lets people
create an account, and checks that it is reachable without signing in.

```
https://www.decorashine.com/delete-account
```

**App icon** — 512×512 PNG. Say the word and I will export it from the mark
already in the repository.

**Feature graphic** (1024×500) — **[you]**, or I can build one from the
website's hero photograph and the wordmark.

**Phone screenshots** (2–8, at least 1080px on the short side) — from the
running app: home, quote comparison, a professional's profile, the requirement
form, progress with photographs, and the Hindi home screen.

---

## App content

**Data safety.** These answers match `RELEASE.md` and the privacy page. The
three drifting apart is how a listing gets pulled months later, so they are
written to be checked against each other.

| Question | Answer |
| --- | --- |
| Does your app collect or share user data? | Yes |
| Is all data encrypted in transit? | Yes |
| Do you provide a way to request data deletion? | Yes — in app, Account → Close your account |

Data types to declare:

| Type | Collected | Shared | Required | Purpose |
| --- | --- | --- | --- | --- |
| Name | Yes | No | Yes | App functionality |
| Phone number | Yes | No | Yes | App functionality, account management |
| Email address | Yes, with Google sign-in | No | No | Account management |
| Address | Yes | Yes — the assigned professional only | Yes | App functionality |
| Photos | Yes | Yes — professionals quoting that job | No | App functionality |
| In-app messages | Yes | No | No | App functionality, customer support |
| Crash logs | Yes | Yes — error reporting provider | No | Diagnostics |

Declare **no** advertising or marketing purpose, **no** data brokers and **no**
tracking across apps. All three are true: there is no advertising, attribution
or third-party analytics SDK in the app.

**Content rating** — answer No to every violence, sexuality, language,
controlled substance and gambling question. Expect Everyone / 3+. The app does
carry user content (portfolio photographs), but it is posted by a vendor and
moderated by us rather than shared between users.

**Ads** — No, this app does not contain ads.

**Target audience** — 18 and over. Not appealing to children.

**Government, financial, health, news, COVID-19 declarations** — No to all.

---

## App access — the section reviewers read first

Answer **Yes, some functionality is restricted**, and paste these instructions:

```
Sign-in sends a one-time code to an Indian mobile number, so please use the
review account below rather than a real number.

1. Open the app and tap "Sign in".
2. Enter mobile number: [REVIEW_MOBILE]
3. Tap "Send code".
4. Enter code: [REVIEW_CODE]

This code is fixed for this number and no message is sent to it. Everything
else works normally: designs, packages and professionals can be browsed
without signing in, and a requirement can be submitted end to end.
```

**[you]** — choose the number and code, set `REVIEW_MOBILE` and `REVIEW_CODE`
on the production API, then paste both into the block above. Use a number that
cannot be issued to a person; `9000000001` is a reasonable choice.

---

## Release

**Release name** — `0.1.0 (1)`, matching `app/pubspec.yaml`.

**Release notes** (500)

```
The first release of Decora Shine.

Get three written quotes for interiors, furniture, fabrication and painting
from professionals verified per trade, compare them side by side, and follow
the work stage by stage with photographs. In English and Hindi.
```

**Countries** — India only, to start.

**Testing** — an individual developer account needs 12 testers opted in for 14
continuous days before it can publish publicly. Start this the day the account
opens: it is the longest wait in the whole process. A company account has no
such requirement.

---

## Before you upload

- [ ] Release keystore created, and `app/android/key.properties` filled in
- [ ] `flutter build appbundle --release`, signed with that key
- [ ] `REVIEW_MOBILE` and `REVIEW_CODE` set on the production API
- [ ] An Android OAuth client for the release key's SHA-1, and another for
      Play's own app signing key once the first bundle is uploaded — miss the
      second and Google sign-in works on your phone but fails for everybody
      who installs from the store
- [ ] `MOBILE_MIN_BUILD=0` on the API, and left there
- [ ] Screenshots taken on a real device, in both languages
