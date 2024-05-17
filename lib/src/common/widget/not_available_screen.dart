import 'package:flutter/material.dart';
import 'package:poc/src/common/widget/common_actions.dart';
import 'package:poc/src/common/widget/scaffold_padding.dart';

/// {@template not_available_screen}
/// NotAvailableScreen widget.
/// {@endtemplate}
class NotAvailableScreen extends StatelessWidget {
  /// {@macro not_available_screen}
  const NotAvailableScreen({this.reason, super.key});

  final String? reason;

  @override
  Widget build(BuildContext context) => Scaffold(
          body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            title: const Text('Not Available'),
            actions: CommonActions(),
          ),
          ScaffoldPadding.sliver(
            context,
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(reason ?? 'Not Available'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ));
}
