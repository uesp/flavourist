// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flavor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Flavor _$FlavorFromJson(Map json) {
  $checkKeys(
    json,
    requiredKeys: const ['applicationID', 'name'],
    disallowNullValues: const [
      'applicationID',
      'name',
      'android',
      'ios',
      'macos'
    ],
  );
  return Flavor(
    applicationID: json['applicationID'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String?,
    platforms: (json['platforms'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        ['android', 'ios', 'macos'],
    android: json['android'] == null
        ? null
        : Android.fromJson(Map<String, dynamic>.from(json['android'] as Map)),
    ios: json['ios'] == null
        ? null
        : Darwin.fromJson(Map<String, dynamic>.from(json['ios'] as Map)),
    macos: json['macos'] == null
        ? null
        : Darwin.fromJson(Map<String, dynamic>.from(json['macos'] as Map)),
  );
}
