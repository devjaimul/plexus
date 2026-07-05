import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required int id,
    required String email,
    required String username,
    required UserNameModel name,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  User toEntity() => User(
    id: id,
    username: username,
    email: email,
    firstName: name.firstname,
    lastName: name.lastname,
  );
}

@freezed
abstract class UserNameModel with _$UserNameModel {
  const factory UserNameModel({
    required String firstname,
    required String lastname,
  }) = _UserNameModel;

  factory UserNameModel.fromJson(Map<String, dynamic> json) =>
      _$UserNameModelFromJson(json);
}
