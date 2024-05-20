import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:poc/src/feature/account/widget/profile_screen.dart';
import 'package:poc/src/feature/authentication/widget/signin_screen.dart';
import 'package:poc/src/feature/developer/widget/developer_screen.dart';
import 'package:poc/src/feature/home/widget/home_screen.dart';
import 'package:poc/src/feature/media_stream/widget/media_stream_screen.dart';
import 'package:poc/src/feature/settings/widget/settings_screen.dart';
import 'package:poc/src/feature/web_speech/widget/web_speech_screen.dart';
import 'package:poc/src/feature/webrtc/widget/webrtc_screen.dart';

enum Routes with OctopusRoute {
  signin('signin', title: 'Sign-In'),
  home('home', title: 'Home'),
  webSpeech('web-speech', title: 'Web Speech API'),
  mediaStream('media-stream', title: 'Media Stream'),
  webRTC('web-rtc', title: 'Web RTC API'),
  profile('profile', title: 'Profile'),
  developer('developer', title: 'Developer'),
  //settingsDialog('settings-dialog', title: 'Settings'),
  settings('settings', title: 'Settings');

  const Routes(this.name, {this.title});

  @override
  final String name;

  @override
  final String? title;

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) => switch (this) {
        Routes.signin => const SignInScreen(),
        Routes.home => const HomeScreen(),
        Routes.webSpeech => const WebSpeechScreen(),
        Routes.mediaStream => const MediaStreamScreen(),
        Routes.webRTC => const WebRTCScreen(),
        Routes.profile => const ProfileScreen(),
        Routes.developer => const DeveloperScreen(),
        Routes.settings => const SettingsScreen(),
      };
}
