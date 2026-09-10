/// Hindi.
///
/// Split by surface rather than kept as one table, because that is how it gets
/// reviewed: somebody checking the vendor's wording is checking a trade
/// vocabulary — नाप, ठेका, किस्त — that has nothing to do with the customer's.
///
/// Register matters more than literalness throughout. This is not formal
/// Hindi and not Hinglish. It is the register a coordinator in Lucknow would
/// actually use on the phone, which means loanwords stay where a translation
/// would be understood but never said: `कोटेशन`, not `मूल्य-प्रस्ताव`.
///
/// Words held in English on purpose, because translating them would be worse:
///
///   - **InterioBee** — the product's name.
///   - **OTP** — universally said in English, in every register.
///   - **GST**, **PIN**, **SMS** — the same.
///   - Trade names as they come from the API, which are data rather than copy.
library;

import 'hi_about.dart';
import 'hi_account.dart';
import 'hi_apply.dart';
import 'hi_app.dart';
import 'hi_catalogue.dart';
import 'hi_common.dart';
import 'hi_customer.dart';
import 'hi_guides.dart';
import 'hi_vendor.dart';

export 'hi_about.dart';
export 'hi_account.dart';
export 'hi_apply.dart';
export 'hi_app.dart';
export 'hi_catalogue.dart';
export 'hi_common.dart';
export 'hi_customer.dart';
export 'hi_guides.dart';
export 'hi_vendor.dart';

/// The whole table, merged.
///
/// Later spreads win on a duplicate key, so the sections must not overlap —
/// which `l10n_test.dart` checks, because a silently-shadowed entry would be
/// the hardest kind of translation bug to see.
const hindi = <String, String>{
  ...hiCommon,
  ...hiAbout,
  ...hiAccount,
  ...hiApply,
  ...hiApp,
  ...hiCatalogue,
  ...hiCustomer,
  ...hiGuides,
  ...hiVendor,
};
