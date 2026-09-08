/// Which language the app is in.
///
/// Two things have to be true at once, and they pull in opposite directions.
///
/// **The device's language is the right default.** Somebody whose phone is in
/// Hindi should not have to find a setting to be spoken to in Hindi.
///
/// **And it cannot be the only answer.** A very large number of phones in India
/// are in English because that is what they came set to, or because a shop set
/// them up, not because their owner reads English comfortably. For the vendor
/// half of this app especially — carpenters, painters, fabricators — assuming
/// the device setting reflects a preference would leave people stuck in a
/// language they did not choose and cannot navigate to change.
///
/// So: follow the device until somebody says otherwise, then remember what they
/// said, forever, on that device. `null` means "follow the device" and is a
/// distinct state from having explicitly chosen English — otherwise a person
/// who picks English while travelling could never get back to following their
/// phone.
library;

import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implements `design`'s [LanguageSwitch] so screens in the feature packages
/// can reach the setting through `AanganLanguageScope` without any of them
/// depending on `shared_preferences` — or on this file.
class LanguageController extends ChangeNotifier implements LanguageSwitch {
  LanguageController({SharedPreferences? preferences})
    : _preferences = preferences;

  SharedPreferences? _preferences;

  /// Not in secure storage. A language preference is not a secret, and the
  /// keychain is for the session token — see the note in core_auth's pubspec.
  static const _key = 'aangan.language';

  Locale? _locale;

  /// The chosen language, or `null` to follow the device.
  ///
  /// Handed straight to `MaterialApp.locale`, where `null` is exactly the
  /// "resolve against the device" behaviour we want, rather than a value we
  /// have to reimplement.
  @override
  Locale? get locale => _locale;

  bool get followsDevice => _locale == null;

  Future<void> load() async {
    _preferences ??= await SharedPreferences.getInstance();
    final code = _preferences!.getString(_key);
    _locale = code == null ? null : Locale(code);
    notifyListeners();
  }

  /// [locale] of `null` goes back to following the device.
  @override
  Future<void> set(Locale? locale) async {
    _preferences ??= await SharedPreferences.getInstance();
    if (locale == null) {
      await _preferences!.remove(_key);
    } else {
      await _preferences!.setString(_key, locale.languageCode);
    }
    _locale = locale;
    notifyListeners();
  }
}
