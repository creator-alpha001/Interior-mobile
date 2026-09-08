// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_session_admin_role.dart';
import 'auth_session_client_role.dart';
import 'auth_session_professional_role.dart';
import 'auth_session_sales_agent_role.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

@Freezed(unionKey: 'role')
sealed class AuthSession with _$AuthSession {
  @FreezedUnionValue('client')
  const factory AuthSession.client({
    required AuthSessionClientRole role,
    required String userId,
    required String clientId,
    String? sessionToken,
    String? expiresAt,
  }) = AuthSessionClient;

  @FreezedUnionValue('professional')
  const factory AuthSession.professional({
    required AuthSessionProfessionalRole role,
    required String userId,
    required String professionalId,
    String? sessionToken,
    String? expiresAt,
  }) = AuthSessionProfessional;

  @FreezedUnionValue('sales_agent')
  const factory AuthSession.salesAgent({
    required AuthSessionSalesAgentRole role,
    required String userId,
    required String salesAgentId,
    String? sessionToken,
    String? expiresAt,
  }) = AuthSessionSalesAgent;

  @FreezedUnionValue('admin')
  const factory AuthSession.admin({
    required AuthSessionAdminRole role,
    required String userId,
    String? sessionToken,
    String? expiresAt,
  }) = AuthSessionAdmin;

  factory AuthSession.fromJson(Map<String, Object?> json) =>
      _$AuthSessionFromJson(json);
}
