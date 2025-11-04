import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class Notification {
  final int id;
  final String title;
  final String description;
  final int? receiverId;
  final String type;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime sentAt;

  Notification({
    required this.id,
    required this.title,
    required this.description,
    this.receiverId,
    required this.type,
    required this.sentAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  static DateTime _dateTimeFromJson(String json) => DateTime.parse(json);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();
}