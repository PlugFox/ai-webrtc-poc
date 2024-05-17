import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octopus/octopus.dart';
import 'package:poc/src/common/localization/localization.dart';
import 'package:poc/src/common/router/routes.dart';

/// {@template profile_icon_button}
/// ProfileIconButton widget
/// {@endtemplate}
class SettingsIconButton extends StatelessWidget {
  /// {@macro profile_icon_button}
  const SettingsIconButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.person),
        tooltip: Localization.of(context).profileButton,
        onPressed: () {
          Octopus.maybeOf(context)?.setState((state) => state
            ..removeByName(Routes.settings.name)
            ..add(Routes.settings.node()));
          HapticFeedback.mediumImpact().ignore();
        },
      );
}
