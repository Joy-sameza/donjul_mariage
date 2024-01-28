import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marriage_app/functional_classes/post_data.dart';
import 'package:marriage_app/functions/snack_bar_method.dart';
import 'package:marriage_app/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final _formKey = GlobalKey<FormState>();
  late int adminId;

  String username = '',
      password = '',
      telephone = '',
      confirmPassword = '',
      actualName = '';
  bool passwordVisibility = false;

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
    var appColorScheme = Theme.of(context).colorScheme;

    final routingData = ModalRoute.of(context)!.settings.arguments as Map?;
    if (routingData != null && routingData.containsKey('adminId')) {
      adminId = routingData['adminId'] as int;
    }

    return Scaffold(
      backgroundColor: Configuration.primaryAppColor,
      body: Center(
        child: Stack(children: [
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        'New user',
                        style: TextStyle(
                          fontSize: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .fontSize, //screenSize.width * 0.1,
                          fontWeight: FontWeight.bold,
                          color: appColorScheme.onBackground,
                        ),
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the user\'s name in order to register';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            actualName = newValue!;
                          },
                          style: TextStyle(color: appColorScheme.onSurface),
                          keyboardType: TextInputType.name,
                          // autofillHints: const [AutofillHints.username],
                          decoration: InputDecoration(
                            hintText: 'Actual Name',
                            hintStyle: TextStyle(color: appColorScheme.outline),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Configuration.mainGrey),
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
                          Icons.phone,
                          color: appColorScheme.onSurface,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your telephone number in order to Configuration';
                              }
                              if (!RegExp(
                                      r"^((\+|00)?237)?([62](2|3|[5-9])[0-9]{7})$")
                                  .hasMatch(value)) {
                                return 'Please enter a valid telephone number';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              telephone = newValue!;
                            },
                            style: TextStyle(color: appColorScheme.onSurface),
                            keyboardType: TextInputType.phone,
                            autofillHints: const [
                              AutofillHints.telephoneNumberLocal
                            ],
                            textInputAction: TextInputAction.go,
                            decoration: InputDecoration(
                              hintText: 'Telephone',
                              hintStyle:
                                  TextStyle(color: appColorScheme.outline),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Configuration.mainGrey),
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            height: formHeight + 27.5,
            width: screenSize.width * 0.9,
            child: ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  // Unfocused keyboard
                  FocusScope.of(context).unfocus();
                  _formKey.currentState!.save();
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  adminId = prefs.getInt('admin_id') ?? 0;
                  PostData send = await PostData.submitData(
                      relativePath: 'register',
                      actualName: actualName,
                      telephone: telephone,
                      adminReference: adminId);
                  Map<String, dynamic> response = send.data;
                  if (await response['error'] != null ||
                      await response['status'] != 201) {
                    // ignore: use_build_context_synchronously
                    await snackBarMethod(
                      context: context,
                      response:
                          await response['message'] ?? await response['error'],
                      duration: 8,
                      width: snackBarWidth,
                    );
                    if (kDebugMode) {
                      print(response);
                    }
                    return;
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.pushReplacementNamed(context, '/admin/user_list');
                },
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(20),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30)),
                  backgroundColor:
                      MaterialStateProperty.all(Configuration.mainBlue),
                  foregroundColor: MaterialStateProperty.all(
                    Colors.white,
                  ),
                  shape: const MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100))),
                  ),
                ),
                child: Icon(Icons.arrow_forward_rounded, size: 30, color: appColorScheme.secondary)),
          ),
        ]),
      ),
    );
  }
}
