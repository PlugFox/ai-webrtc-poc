import 'dart:math' as math;

import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webrtcaipoc/src/common/constant/config.dart';
import 'package:webrtcaipoc/src/feature/authentication/controller/authentication_controller.dart';
import 'package:webrtcaipoc/src/feature/authentication/controller/authentication_state.dart';
import 'package:webrtcaipoc/src/feature/authentication/model/sign_in_data.dart';
import 'package:webrtcaipoc/src/feature/authentication/widget/authentication_scope.dart';

/// {@template signin_screen}
/// SignInScreen widget.
/// {@endtemplate}
class SignInScreen extends StatefulWidget {
  /// {@macro signin_screen}
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with _UsernamePasswordFormStateMixin {
  final FocusNode _usernameFocusNode = FocusNode();
  late final Listenable _formChangedNotifier = Listenable.merge([_usernameController]);
  final _usernameFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(
      /// Allow only letters and numbers, and some special characters
      RegExp(r'\@|[A-Z]|[a-z]|[0-9]|\.|\-|\_|\+'),
    ),
    const _UsernameTextFormatter(),
  ];
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: math.max(16, (constraints.maxWidth - 620) / 2),
                ),
                child: StateConsumer<AuthenticationController, AuthenticationState>(
                  controller: _authenticationController,
                  buildWhen: (previous, current) => previous != current,
                  builder: (context, state, _) => Column(
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(width: 50),
                            Text(
                              'Sign-In',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(height: 1),
                            ),
                            const SizedBox(width: 2),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                icon: const Icon(Icons.casino),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                  width: 48,
                                  height: 48,
                                ),
                                tooltip: 'Generate username',
                                onPressed: state.isIdling
                                    ? () {
                                        if (_obscurePassword) {
                                          setState(
                                            () => _obscurePassword = false,
                                          );
                                        }
                                        generateUsername();
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        focusNode: _usernameFocusNode,
                        enabled: state.isIdling,
                        maxLines: 1,
                        minLines: 1,
                        controller: _usernameController,
                        autocorrect: false,
                        autofillHints: const <String>[AutofillHints.username, AutofillHints.email],
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: _usernameFormatters,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your username',
                          helperText: '',
                          helperMaxLines: 1,
                          errorText: _usernameError ?? state.error,
                          errorMaxLines: 1,
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 48,
                        child: AnimatedBuilder(
                          animation: _formChangedNotifier,
                          builder: (context, _) {
                            final formFilled = _usernameController.text.trim().length > 3;
                            final signInCallback = state.isIdling && formFilled ? () => signIn(context) : null;
                            final signUpCallback = state.isIdling ? () => signUp(context) : null;
                            final key =
                                ValueKey<int>((signInCallback == null ? 0 : 1 << 1) | (signUpCallback == null ? 0 : 1));
                            return _SignInScreen$Buttons(
                              signIn: signInCallback,
                              signUp: signUpCallback,
                              key: key,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _SignInScreen$Buttons extends StatelessWidget {
  const _SignInScreen$Buttons({
    required this.signIn,
    required this.signUp,
    super.key,
  });

  final void Function()? signIn;
  final void Function()? signUp;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: signIn,
              icon: const Icon(Icons.login),
              label: const Text(
                'Sign-In',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Opacity(
              opacity: .75,
              child: FilledButton.tonalIcon(
                onPressed: null, // signUp,
                icon: const Icon(Icons.person_add),
                label: const Text(
                  'Sign-Up',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      );
}

class _UsernameTextFormatter extends TextInputFormatter {
  const _UsernameTextFormatter();
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) => TextEditingValue(
        text: newValue.text.toLowerCase(),
        selection: newValue.selection,
      );
}

mixin _UsernamePasswordFormStateMixin on State<SignInScreen> {
  static String? _usernameValidator(String username) {
    if (username.isEmpty) return 'Username is required.';
    final length = switch (username.trim().length) {
      0 => 'Username is required.',
      < 3 => 'Must be a minimum of 3 characters.',
      _ => null,
    };
    if (length != null) return length;
    // If username passes all checks, return null
    return null;
  }

  late final AuthenticationController _authenticationController;
  final TextEditingController _usernameController = TextEditingController(text: 'test@gmail.com');
  String? _usernameError;

  bool _validate(String username) {
    final usernameError = _usernameValidator(username);
    if (mounted) {
      setState(() {
        _usernameError = usernameError;
      });
    }
    return usernameError == null;
  }

  /// Signs in the user with the given username and password
  void signIn(BuildContext context) {
    final username = _usernameController.text.trim();
    if (!_validate(username)) return;
    FocusScope.of(context).unfocus();
    _authenticationController.signIn(
      SignInData(
        username: username,
      ),
    );
  }

  /// Generates a random username
  void generateUsername() {
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const chars = lower + upper + numbers;
    final rnd = math.Random();
    final length = rnd.nextInt(Config.passwordMaxLength - Config.passwordMinLength) + Config.passwordMinLength;
    final text = <int>[
      lower.codeUnitAt(rnd.nextInt(lower.length)),
      upper.codeUnitAt(rnd.nextInt(upper.length)),
      numbers.codeUnitAt(rnd.nextInt(numbers.length)),
      for (var i = 0; i < length - 3; i++) chars.codeUnitAt(rnd.nextInt(chars.length)),
    ];
    _usernameController.text = String.fromCharCodes(text..shuffle());
  }

  /// Opens the sign up page in the browser
  void signUp(BuildContext context) {
    FocusScope.of(context).unfocus();
    // url_launcher.launchUrlString('...').ignore();
    // context.octopus.setState((state) => state..add(Routes.signup.node()));
    //context.octopus.push(Routes.signup);
  }

  @override
  void initState() {
    super.initState();
    _authenticationController = AuthenticationScope.controllerOf(context);
    generateUsername();
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
  }
}
