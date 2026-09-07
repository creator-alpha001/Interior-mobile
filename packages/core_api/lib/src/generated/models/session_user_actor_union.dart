// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'actor_admin_role.dart';
import 'actor_client_role.dart';
import 'actor_professional_role.dart';
import 'actor_sales_agent_role.dart';

part 'session_user_actor_union.freezed.dart';
part 'session_user_actor_union.g.dart';

@Freezed()
sealed class SessionUserActorUnion with _$SessionUserActorUnion {
  @JsonSerializable()
  const factory SessionUserActorUnion.actorClient({
    required ActorClientRole role,
    required String userId,
    required String clientId,
  }) = SessionUserActorUnionActorClient;
  
  @JsonSerializable()
  const factory SessionUserActorUnion.actorProfessional({
    required ActorProfessionalRole role,
    required String userId,
    required String professionalId,
  }) = SessionUserActorUnionActorProfessional;
  
  @JsonSerializable()
  const factory SessionUserActorUnion.actorSalesAgent({
    required ActorSalesAgentRole role,
    required String userId,
    required String salesAgentId,
  }) = SessionUserActorUnionActorSalesAgent;
  
  @JsonSerializable()
  const factory SessionUserActorUnion.actorAdmin({
    required ActorAdminRole role,
    required String userId,
  }) = SessionUserActorUnionActorAdmin;
  

  factory SessionUserActorUnion.fromJson(Map<String, Object?> json) =>
      // TODO: No discriminator in OpenAPI spec - you must implement this manually.
      //
      // Inspect the JSON and return the matching variant. Each variant has a fromJson:
      //   SessionUserActorUnionVariantName.fromJson(json)
      //
      // Example pattern (check for unique fields):
      //   json.containsKey('uniqueFieldA') ? SessionUserActorUnionTypeA.fromJson(json) :
      //   json.containsKey('uniqueFieldB') ? SessionUserActorUnionTypeB.fromJson(json) :
      //   SessionUserActorUnionDefault.fromJson(json);
      //
      // IMPORTANT: Keep the => arrow syntax. Converting to a { } body will cause
      // freezed to skip generating toJson/fromJson for this class.
      throw UnimplementedError();

}
