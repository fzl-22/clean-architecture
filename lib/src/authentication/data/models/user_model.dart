import 'dart:convert';

import 'package:tdd_tutorial/core/utils/typedef.dart';
import 'package:tdd_tutorial/src/authentication/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.createdAt,
    required super.name,
    required super.avatar,
  });

  const UserModel.empty()
      : this(
          id: "1",
          createdAt: '_empty.createdAt',
          name: '_empty.name',
          avatar: '_empty.avatar',
        );

  User copyWith({
    String? id,
    String? createdAt,
    String? name,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
    );
  }

  DataMap toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'createdAt': createdAt});
    result.addAll({'name': name});
    result.addAll({'avatar': avatar});

    return result;
  }

  factory UserModel.fromMap(DataMap map) {
    return UserModel(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ?? '',
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
