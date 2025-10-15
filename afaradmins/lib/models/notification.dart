import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';  // For json_serializable

@JsonSerializable()
class Notification {
  final int? id;  // Long in Java -> int in Dart
  final String? title;
  final String? description;
  final String? receiverId;
  final String? type;
  final DateTime? sentAt;

  Notification({
    this.id,
    this.title,
    this.description,
    this.receiverId,
    this.type,
    this.sentAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}