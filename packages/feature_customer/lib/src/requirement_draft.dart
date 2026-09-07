/// The requirement being filled in, and where it lives between steps.
///
/// MOBILE.md §6.3 sets the order and it is not arbitrary — it is what the web
/// learned:
///
///   1  Which trades?          multi-select; each becomes a lead_domain
///   2  What, roughly          per trade: material source, description
///   3  Photographs            anonymous upload, purpose=requirement_photo
///   4  Where                  city, locality
///   5  When and how much      urgency, budget ceiling
///   6  Verify this number     OTP → account + requirement in one action
///
/// **Verification is last, and everything before it stays on the device.**
/// Asking for an account first is how a form loses the people who opened it.
/// The API supports this deliberately: `/uploads/tickets` accepts an anonymous
/// caller for `requirement_photo` and rate-limits by address.
///
/// Which makes step 6 the risky moment, and this class the answer to it. The
/// draft is persisted after every step, so if `POST /me/requirements` fails
/// once the code has verified, the person is signed in with an unsaved form —
/// and the app can retry against what was saved rather than losing it.
library;

import 'dart:convert';

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the person is in the six steps.
enum RequirementStep {
  trades,
  detail,
  photographs,
  where,
  budget,
  verify;

  String get title => switch (this) {
        RequirementStep.trades => 'What do you need?',
        RequirementStep.detail => 'Tell us roughly',
        RequirementStep.photographs => 'Show us the space',
        RequirementStep.where => 'Where is it?',
        RequirementStep.budget => 'When, and how much?',
        RequirementStep.verify => 'Verify your number',
      };
}

@immutable
class RequirementDraft {
  const RequirementDraft({
    this.step = RequirementStep.trades,
    this.domainIds = const [],
    this.materialSource = const {},
    this.description = '',
    this.photoAssetIds = const [],
    this.cityId,
    this.locality = '',
    this.urgency,
    this.budgetMax,
    this.siteTags = const [],
  });

  final RequirementStep step;

  /// Each becomes a `lead_domain` — its own assignment, quoting and execution
  /// track. "Just a dining table" and "2BHK + painting + a steel gate" run
  /// through identical code paths because of this.
  final List<String> domainIds;

  /// Asked once per selected trade: a client can supply their own wood but not
  /// their own paint.
  final Map<String, MaterialSource> materialSource;

  final String description;
  final List<String> photoAssetIds;
  final String? cityId;
  final String locality;
  final Urgency? urgency;
  final int? budgetMax;
  final List<SiteAccessibilityTag> siteTags;

  RequirementDraft copyWith({
    RequirementStep? step,
    List<String>? domainIds,
    Map<String, MaterialSource>? materialSource,
    String? description,
    List<String>? photoAssetIds,
    String? cityId,
    String? locality,
    Urgency? urgency,
    int? budgetMax,
    List<SiteAccessibilityTag>? siteTags,
    bool clearBudget = false,
  }) {
    return RequirementDraft(
      step: step ?? this.step,
      domainIds: domainIds ?? this.domainIds,
      materialSource: materialSource ?? this.materialSource,
      description: description ?? this.description,
      photoAssetIds: photoAssetIds ?? this.photoAssetIds,
      cityId: cityId ?? this.cityId,
      locality: locality ?? this.locality,
      urgency: urgency ?? this.urgency,
      budgetMax: clearBudget ? null : (budgetMax ?? this.budgetMax),
      siteTags: siteTags ?? this.siteTags,
    );
  }

  /// Whether the current step has enough to move on.
  bool get canAdvance => switch (step) {
        RequirementStep.trades => domainIds.isNotEmpty,
        RequirementStep.detail => description.trim().length >= 10,
        // Photographs help enormously and are not required. Blocking on them
        // is how a form loses somebody standing in an unlit room.
        RequirementStep.photographs => true,
        RequirementStep.where => cityId != null && locality.trim().isNotEmpty,
        RequirementStep.budget => urgency != null,
        RequirementStep.verify => false,
      };

  /// Everything needed to submit. Checked before the OTP, not after.
  bool get isComplete =>
      domainIds.isNotEmpty &&
      description.trim().length >= 10 &&
      cityId != null &&
      urgency != null;

  CreateRequirementBody toBody() => CreateRequirementBody(
        cityId: cityId!,
        domainIds: domainIds,
        description: description.trim(),
        urgency: urgency!,
        materialSource: materialSource,
        siteAccessibilityTags: siteTags.isEmpty ? null : siteTags,
        budgetMax: budgetMax,
        photoIds: photoAssetIds.isEmpty ? null : photoAssetIds,
      );

  Map<String, Object?> toJson() => {
        'step': step.name,
        'domainIds': domainIds,
        'materialSource': materialSource.map((k, v) => MapEntry(k, v.name)),
        'description': description,
        'photoAssetIds': photoAssetIds,
        'cityId': cityId,
        'locality': locality,
        'urgency': urgency?.name,
        'budgetMax': budgetMax,
        'siteTags': siteTags.map((t) => t.name).toList(),
      };

  factory RequirementDraft.fromJson(Map<String, Object?> json) {
    T? byName<T extends Enum>(List<T> values, Object? name) {
      if (name is! String) return null;
      for (final value in values) {
        if (value.name == name) return value;
      }
      return null;
    }

    return RequirementDraft(
      step: byName(RequirementStep.values, json['step']) ?? RequirementStep.trades,
      domainIds: (json['domainIds'] as List<dynamic>? ?? []).cast<String>(),
      materialSource: {
        for (final entry in (json['materialSource'] as Map<String, dynamic>? ?? {}).entries)
          entry.key:
              byName(MaterialSource.values, entry.value) ?? MaterialSource.undecided,
      },
      description: json['description'] as String? ?? '',
      photoAssetIds: (json['photoAssetIds'] as List<dynamic>? ?? []).cast<String>(),
      cityId: json['cityId'] as String?,
      locality: json['locality'] as String? ?? '',
      urgency: byName(Urgency.values, json['urgency']),
      budgetMax: (json['budgetMax'] as num?)?.toInt(),
      siteTags: [
        for (final tag in (json['siteTags'] as List<dynamic>? ?? []))
          ?byName(SiteAccessibilityTag.values, tag),
      ],
    );
  }
}

/// Keeps the draft on the device between steps, and across launches.
///
/// `shared_preferences`, not secure storage: none of this is a secret, and it
/// is written after every keystroke-batch. The session token is the only thing
/// that goes in Keychain.
class RequirementDraftStore {
  RequirementDraftStore([this._preferences]);

  SharedPreferences? _preferences;
  static const _key = 'aangan.requirement.draft';

  Future<RequirementDraft?> load() async {
    _preferences ??= await SharedPreferences.getInstance();
    final raw = _preferences!.getString(_key);
    if (raw == null) return null;

    try {
      return RequirementDraft.fromJson(
        jsonDecode(raw) as Map<String, Object?>,
      );
    } on Object catch (error) {
      // A draft written by an older build. Losing it is bad; crashing on
      // launch because of it is worse.
      debugPrint('requirement draft unreadable, discarding: $error');
      await clear();
      return null;
    }
  }

  Future<void> save(RequirementDraft draft) async {
    _preferences ??= await SharedPreferences.getInstance();
    await _preferences!.setString(_key, jsonEncode(draft.toJson()));
  }

  /// Called only once the server has the requirement.
  ///
  /// Deliberately not called when submission fails — that is precisely when the
  /// draft is the only copy.
  Future<void> clear() async {
    _preferences ??= await SharedPreferences.getInstance();
    await _preferences!.remove(_key);
  }
}
