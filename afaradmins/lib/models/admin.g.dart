// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Admin _$AdminFromJson(Map<String, dynamic> json) => Admin(
  id: (json['id'] as num?)?.toInt(),
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
  password: json['password'] as String?,
  role: json['role'] as String?,
  createdAt: Admin._dateTimeFromJson(json['createdAt']),
  updatedAt: Admin._dateTimeFromJson(json['updatedAt']),
  lastLogin: Admin._dateTimeFromJson(json['lastLogin']),
  image: json['image'] as String?,
  notifications: (json['notifications'] as List<dynamic>?)
      ?.map((e) => Notification.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AdminToJson(Admin instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'password': instance.password,
  'role': instance.role,
  'createdAt': ?Admin._dateTimeToJson(instance.createdAt),
  'updatedAt': ?Admin._dateTimeToJson(instance.updatedAt),
  'lastLogin': ?Admin._dateTimeToJson(instance.lastLogin),
  'image': instance.image,
  'notifications': instance.notifications?.map((e) => e.toJson()).toList(),
};
