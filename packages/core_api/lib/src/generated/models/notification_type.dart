// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum NotificationType {
  @JsonValue('professional_assigned')
  professionalAssigned('professional_assigned'),
  @JsonValue('meeting_confirmed')
  meetingConfirmed('meeting_confirmed'),
  @JsonValue('quote_uploaded')
  quoteUploaded('quote_uploaded'),
  @JsonValue('agreement_ready')
  agreementReady('agreement_ready'),
  @JsonValue('agreement_signed')
  agreementSigned('agreement_signed'),
  @JsonValue('project_started')
  projectStarted('project_started'),
  @JsonValue('project_completed')
  projectCompleted('project_completed'),
  @JsonValue('new_lead')
  newLead('new_lead'),
  @JsonValue('commission_due')
  commissionDue('commission_due'),
  @JsonValue('message_received')
  messageReceived('message_received'),
  @JsonValue('review_received')
  reviewReceived('review_received'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const NotificationType(this.json);

  factory NotificationType.fromJson(String json) => values.firstWhere(
        (e) => e.json == json,
        orElse: () => $unknown,
      );

  final String? json;
  String toJson() {
    final value = json;
    if (value == null) {
      throw StateError('Cannot convert enum value with null JSON representation to String. '
          'This usually happens for \$unknown or @JsonValue(null) entries.');
    }
    return value as String;
  }

  @override
  String toString() => json?.toString() ?? super.toString();
  /// Returns all defined enum values excluding the $unknown value.
  static List<NotificationType> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
