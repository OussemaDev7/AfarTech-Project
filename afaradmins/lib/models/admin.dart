import 'package:json_annotation/json_annotation.dart';
import 'notification.dart';  

part 'admin.g.dart';  

@JsonSerializable()
class Admin {
  final int? id;  
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
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
}