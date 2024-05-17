import 'package:meta/meta.dart';

/// User username type.
typedef Username = String;

/// {@template user}
/// The user entry model.
/// {@endtemplate}
@immutable
sealed class User with _UserPatternMatching, _UserShortcuts {
  /// {@macro user}
  const User._();

  /// {@macro user}
  @literal
  const factory User.unauthenticated() = UnauthenticatedUser;

  /// {@macro user}
  const factory User.authenticated({
    required Username username,
  }) = AuthenticatedUser;

  /// {@macro user}
  factory User.fromJson(Map<String, Object?> json) => switch (json['username']) {
        Username username => AuthenticatedUser(username: username),
        _ => const UnauthenticatedUser(),
      };

  /// The user's username.
  abstract final Username? username;

  Map<String, Object?> toJson();
}

/// {@macro user}
///
/// Unauthenticated user.
class UnauthenticatedUser extends User {
  /// {@macro user}
  const UnauthenticatedUser() : super._();

  /// {@macro user}
  // ignore: avoid_unused_constructor_parameters
  factory UnauthenticatedUser.fromJson(Map<String, Object?> json) => const UnauthenticatedUser();

  @override
  Username? get username => null;

  @override
  bool get isAuthenticated => false;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'user',
        'status': 'unauthenticated',
        'authenticated': false,
        'username': null,
      };

  @override
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  }) =>
      unauthenticated(this);

  @override
  User copyWith({
    Username? username,
  }) =>
      username != null ? AuthenticatedUser(username: username) : const UnauthenticatedUser();

  @override
  int get hashCode => -1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UnauthenticatedUser && username == other.username;

  @override
  String toString() => 'UnauthenticatedUser{}';
}

/// {@macro user}
final class AuthenticatedUser extends User {
  /// {@macro user}
  const AuthenticatedUser({
    required this.username,
  }) : super._();

  /// {@macro user}
  factory AuthenticatedUser.fromJson(Map<String, Object?> json) {
    if (json.isEmpty) throw FormatException('Json is empty', json);
    if (json
        case <String, Object?>{
          'username': Username username,
        }) return AuthenticatedUser(username: username);
    throw FormatException('Invalid json format', json);
  }

  @override
  @nonVirtual
  final Username username;

  @override
  @nonVirtual
  bool get isAuthenticated => true;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'user',
        'status': 'authenticated',
        'authenticated': true,
        'username': username,
      };

  @override
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  }) =>
      authenticated(this);

  @override
  AuthenticatedUser copyWith({
    Username? username,
  }) =>
      AuthenticatedUser(
        username: username ?? this.username,
      );

  @override
  int get hashCode => username.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AuthenticatedUser && username == other.username;

  @override
  String toString() => 'AuthenticatedUser{username: $username}';
}

mixin _UserPatternMatching {
  /// Pattern matching on [User] subclasses.
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  });

  /// Pattern matching on [User] subclasses.
  T maybeMap<T>({
    required T Function() orElse,
    T Function(UnauthenticatedUser user)? unauthenticated,
    T Function(AuthenticatedUser user)? authenticated,
  }) =>
      map<T>(
        unauthenticated: (user) => unauthenticated?.call(user) ?? orElse(),
        authenticated: (user) => authenticated?.call(user) ?? orElse(),
      );

  /// Pattern matching on [User] subclasses.
  T? mapOrNull<T>({
    T Function(UnauthenticatedUser user)? unauthenticated,
    T Function(AuthenticatedUser user)? authenticated,
  }) =>
      map<T?>(
        unauthenticated: (user) => unauthenticated?.call(user),
        authenticated: (user) => authenticated?.call(user),
      );
}

mixin _UserShortcuts on _UserPatternMatching {
  /// User is authenticated.
  bool get isAuthenticated;

  /// User is not authenticated.
  bool get isNotAuthenticated => !isAuthenticated;

  /// Copy with new values.
  User copyWith({
    Username? username,
  });
}
