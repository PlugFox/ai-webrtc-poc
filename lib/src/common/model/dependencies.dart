import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:poc/src/common/database/database.dart';
import 'package:poc/src/common/model/app_metadata.dart';
import 'package:poc/src/feature/authentication/controller/authentication_controller.dart';
import 'package:poc/src/feature/initialization/widget/inherited_dependencies.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dependencies
class Dependencies {
  Dependencies();

  /// The state from the closest instance of this class.
  factory Dependencies.of(BuildContext context) => InheritedDependencies.of(context);

  /// App metadata
  late final AppMetadata metadata;

  /// Shared preferences
  late final SharedPreferences sharedPreferences;

  /// Database
  late final Database database;

  /// API Client
  late final Dio dio;

  /// Authentication controller
  late final AuthenticationController authenticationController;
}
