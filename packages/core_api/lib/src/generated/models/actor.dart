// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'actor_admin_role.dart';
import 'actor_client_role.dart';
import 'actor_professional_role.dart';
import 'actor_sales_agent_role.dart';

part 'actor.freezed.dart';
part 'actor.g.dart';

@Freezed(unionKey: 'role')
sealed class Actor with _$Actor {
  @FreezedUnionValue('client')
  const factory Actor.client({
    required ActorClientRole role,
    required String userId,
    required String clientId,
  }) = ActorClient;

  @FreezedUnionValue('professional')
  const factory Actor.professional({
    required ActorProfessionalRole role,
    required String userId,
    required String professionalId,
  }) = ActorProfessional;

  @FreezedUnionValue('sales_agent')
  const factory Actor.salesAgent({
    required ActorSalesAgentRole role,
    required String userId,
    required String salesAgentId,
  }) = ActorSalesAgent;

  @FreezedUnionValue('admin')
  const factory Actor.admin({
    required ActorAdminRole role,
    required String userId,
  }) = ActorAdmin;

  
  factory Actor.fromJson(Map<String, Object?> json) => _$ActorFromJson(json);
}
