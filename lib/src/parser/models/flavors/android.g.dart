// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'android.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Android _$AndroidFromJson(Map json) {
  $checkKeys(
    json,
    requiredKeys: const ['applicationId'],
    disallowNullValues: const [
      'icon',
      'applicationId',
      'customConfig',
      'resValues',
      'buildConfigFields',
      'adaptiveIcon'
    ],
  );
  return Android(
    applicationId: json['applicationId'] as String,
    customConfig: (json['customConfig'] as Map?)?.map(
          (k, e) => MapEntry(k as String, e),
        ) ??
        {},
    resValues: (json['resValues'] as Map?)?.map(
          (k, e) => MapEntry(k as String,
              ResValue.fromJson(Map<String, dynamic>.from(e as Map))),
        ) ??
        {},
    buildConfigFields: (json['buildConfigFields'] as Map?)?.map(
          (k, e) => MapEntry(k as String,
              BuildConfigField.fromJson(Map<String, dynamic>.from(e as Map))),
        ) ??
        {},
    generateDummyAssets: json['generateDummyAssets'] as bool? ?? true,
    icon: json['icon'] as String?,
    adaptiveIcon: json['adaptiveIcon'] == null
        ? null
        : AdaptiveIcon.fromJson(
            Map<String, dynamic>.from(json['adaptiveIcon'] as Map)),
  );
}
