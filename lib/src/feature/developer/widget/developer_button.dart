import 'package:flutter/material.dart';
import 'package:poc/src/common/localization/localization.dart';
import 'package:poc/src/common/router/routes.dart';
import 'package:octopus/octopus.dart';

/// {@template developer_button}
/// DeveloperButton widget
/// {@endtemplate}
class DeveloperButton extends StatelessWidget {
  /// {@macro developer_button}
  const DeveloperButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.developer_mode),
        tooltip: Localization.of(context).developer,
        onPressed: () => Octopus.of(context).push(Routes.developer),
      );
}
