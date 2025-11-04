import 'package:json_annotation/json_annotation.dart';
import 'notification.dart';

part 'admin.g.dart';

@JsonSerializable(explicitToJson: true)
class Admin {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final String? role;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson, includeIfNull: false)
  final DateTime? createdAt;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson, includeIfNull: false)
  final DateTime? updatedAt;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson, includeIfNull: false)
  final DateTime? lastLogin;
  final String? image;
  final List<Notification>? notifications;

  Admin({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
    this.image,
    this.notifications,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => _$AdminFromJson(json);

  Map<String, dynamic> toJson() => _$AdminToJson(this);

  static String? _dateTimeToJson(DateTime? date) => date?.toIso8601String();

  static DateTime? _dateTimeFromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) {
      return DateTime.tryParse(json);
    }
    throw ArgumentError('Invalid date format: $json');
  }
}