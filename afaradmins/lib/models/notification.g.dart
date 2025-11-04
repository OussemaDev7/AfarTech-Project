// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  receiverId: (json['receiverId'] as num?)?.toInt(),
  type: json['type'] as String,
  sentAt: Notification._dateTimeFromJson(json['sentAt'] as String),
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'receiverId': instance.receiverId,
      'type': instance.type,
      'sentAt': Notification._dateTimeToJson(instance.sentAt),
    };
