// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'darwin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Darwin _$DarwinFromJson(Map json) {
  $checkKeys(
    json,
    requiredKeys: const ['bundleId'],
    disallowNullValues: const ['icon', 'bundleId', 'variables'],
  );
  return Darwin(
    bundleId: json['bundleId'] as String,
    variables: (json['variables'] as Map?)?.map(
          (k, e) => MapEntry(k as String,
              Variable.fromJson(Map<String, dynamic>.from(e as Map))),
        ) ??
        {},
    buildSettings: (json['buildSettings'] as Map?)?.map(
          (k, e) => MapEntry(k as String, e),
        ) ??
        {},
    generateDummyAssets: json['generateDummyAssets'] as bool? ?? true,
    icon: json['icon'] as String?,
  );
}
