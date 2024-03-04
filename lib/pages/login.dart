import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marriage_app/config/config.dart';
import 'package:marriage_app/data_layer/post_data.dart';
import 'package:marriage_app/functions/build_small_button.dart';
import 'package:marriage_app/functions/snack_bar_method.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  static const Color mainBlue = Configuration.mainBlue;
  static const Color mainOrange = Configuration.primaryAppColor;
  static const Color mainRed = Configuration.mainRed;
  static const Color mainGrey = Configuration.mainGrey;

  @override
  State<Login> createState() => _LoginState();
}

enum ButtonState { init, loading, done }

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String username = '', password = '';
  bool passwordVisibility = true;
  bool _isAnimating = true;
  ButtonState _state = ButtonState.init;

  @override
  void initState() {
    super.initState();
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double snackBarWidth = screenSize.width * 0.75;
    final double formHeight = screenSize.height * 0.525;
    bool isLoading = _isAnimating || _state == ButtonState.init;
    bool isDone = _state == ButtonState.done;
    var appColorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Configuration.primaryAppColor,
      body: Center(
        child: Stack(
          children: [
            Container(
              width: screenSize.width * 0.9,
              height: formHeight,
              decoration: BoxDecoration(
                color: appColorScheme.background,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .fontSize, //screenSize.width * 0.1,
                                fontWeight: FontWeight.bold,
                                color: appColorScheme.onBackground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 2,
                        height: 60,
                      ),
                      const SizedBox(height: 20),
                      Row(children: [
                        Icon(
                          Icons.person,
                          color: appColorScheme.onSurface,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username in order to login';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              username = newValue!;
                            },
                            style: TextStyle(color: appColorScheme.onSurface),
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.username],
                            decoration: InputDecoration(
                              hintText: 'Username',
                              hintStyle:
                                  TextStyle(color: appColorScheme.outline),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: appColorScheme.outline),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Configuration.primaryAppColor),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: appColorScheme.error),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: appColorScheme.error),
                              ),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.lock,
                            color: appColorScheme.onSurface,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password in order to login';
                                }
                                if (!RegExp(r"^.{6,}$").hasMatch(value)) {
                                  return 'Please enter a strong password';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                password = newValue!;
                              },
                              style: TextStyle(color: appColorScheme.onSurface),
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: passwordVisibility,
                              autofillHints: const [AutofillHints.password],
                              textInputAction: TextInputAction.go,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle:
                                    TextStyle(color: appColorScheme.outline),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() =>
                                      passwordVisibility = !passwordVisibility),
                                  icon: Icon(
                                    !passwordVisibility
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    color: appColorScheme.outline,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: appColorScheme.outline),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Configuration.primaryAppColor),
                                ),
                                errorBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: appColorScheme.error),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.transparent),
                              elevation: MaterialStateProperty.all(0),
                            ),
                            onPressed: (() =>
                                Navigator.pushNamed(context, '/')),
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                decorationColor:
                                    Theme.of(context).colorScheme.error,
                                decoration: TextDecoration.underline,
                                decorationThickness: 2,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ignore: sized_box_for_whitespace
            Container(
              height: formHeight + 27.5,
              width: screenSize.width * 0.9,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeIn,
                alignment: Alignment.bottomCenter,
                height: formHeight * 1.01,
                width: _state != ButtonState.init
                    ? screenSize.width * 0.09
                    : screenSize.width * 0.9,
                onEnd: () => setState(() => _isAnimating = !_isAnimating),
                child: isLoading
                    ? _buildButton(context, snackBarWidth)
                    : buildSmallButton(isDone),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildButton(BuildContext context, double snackBarWidth) {
    return ElevatedButton(
      onPressed: () => _submitForm(snackBarWidth),
      style: ElevatedButton.styleFrom(
        backgroundColor: Login.mainBlue,
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 18),
        minimumSize: const Size(80, 60),
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 30,
        color: Theme.of(context).colorScheme.background,
      ),
    );
  }

  void _submitForm(double snackBarWidth) async {
    // Unfocused keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() => _state = ButtonState.loading);
    await Future.delayed(const Duration(milliseconds: 750));
    PostData send = await PostData.submitData(
        relativePath: 'login', username: username, password: password);
    Map<String, dynamic> response = send.data;
    if (response['error'] != null || response['status'] != 200) {
      setState(() => _state = ButtonState.init);
      // ignore: use_build_context_synchronously
      snackBarMethod(
        context: context,
        message: response['error'] ?? response['message'],
        width: snackBarWidth,
      );
      return;
    }
    TextInput.finishAutofillContext();
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('auth_token', response['token']);
    preferences.setBool('isAdmin', response['isAdmin']);
    preferences.setInt('admin_id', response['admin_id'] ?? -1);
    setState(() => _state = ButtonState.done);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (response['isAdmin']) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/admin', arguments: {
        'admin_id': response['admin_id'] ?? 0,
      });
      return;
    }
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/home');
  }
}
