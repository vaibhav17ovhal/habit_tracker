import 'package:Demo/providers/dashboard_provider.dart';
import 'package:Demo/providers/login_provider.dart';
import 'package:Demo/providers/user_provider.dart';
import 'package:Demo/models/user.dart';
import 'package:Demo/screens/sign_up_screen.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/custom_button.dart';
import '../custom_widgets/custom_colors.dart';
import '../custom_widgets/custom_font_family.dart';
import '../custom_widgets/custom_scaffold.dart';
import '../custom_widgets/custom_text_field.dart';
import 'dashboard_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);
    return CustomScaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 77,
                    right: 77,
                    bottom: 40,
                    top: 15,
                  ),
                  child: Image.asset("assets/images/login_top_logo_img.png"),
                ),

                Text(
                  "Sign In to your account",
                  style: TextStyle(
                    fontSize: 20,
                    color: MyColors.darkNavyBlue,
                    fontFamily: FontFamily.sfProBold,
                  ),
                ),

                SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomTextField.customTextFieldEmail(
                    controller: provider.loginEmailController,
                    focusNode: emailFocusNode,
                    textInputType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    hintText: "Enter Your Email",
                    isBorder: true,
                    prefixIcon: null,
                    onTap: () {},
                    validator: provider.validateEmail,
                    labelText: "Email Address",
                  ),
                ),

                SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomTextField.customTextFieldPassword(
                    controller: provider.passwordController,
                    focusNode: passwordFocusNode,
                    textInputAction: TextInputAction.done,
                    hintText: "Enter Password",
                    labelText: "Password",
                    isBorder: true,
                    isPasswordVisible: provider.isPasswordVisible,
                    onToggleVisibility: provider.togglePasswordVisibility,
                    validator: provider.validatePassword,
                  ),
                ),

                SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ForgotPasswordScreen(),
                    //   ),
                    // );
                  },
                  child: Text(
                    "Forgot Password",
                    style: TextStyle(
                      color: MyColors.darkNavyBlue,
                      fontFamily: FontFamily.sfProSemiBold,
                      fontSize: 14,
                    ),
                  ),
                ),

                SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomButton.button(
                    buttonText: "Continue",
                    buttonColor: MyColors.primaryBlue,
                    borderRadius: 60,
                    onTap: () async {
                      FocusScope.of(context).unfocus();

                      if (_formKey.currentState!.validate()) {
                        final email =
                            provider.loginEmailController.text.trim();
                        final userProvider = context.read<UserProvider>();

                        await userProvider.saveUser(
                          AppUser(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: email.split('@').first,
                            email: email,
                          ),
                        );

                        provider.clearFields();
                        context.read<DashboardProvider>().reset();

                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ),
                        );
                      }
                    },
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: MyColors.kWhiteColor,
                      fontFamily: FontFamily.sfProMedium,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Don't have an account ?",
                        style: TextStyle(
                          color: MyColors.darkNavyBlue,
                          fontSize: 14,
                          fontFamily: FontFamily.sfProMedium,
                        ),
                      ),
                      TextSpan(
                        text: " Get Started",
                        style: TextStyle(
                          color: MyColors.cAppThemeTealGreen,
                          fontSize: 14,
                          fontFamily: FontFamily.sfProSemiBold,
                        ),
                        recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: [
                      Expanded(child: DottedLine()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "or",
                          style: TextStyle(
                            color: MyColors.darkNavyBlue,
                            fontFamily: FontFamily.sfProBold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(child: DottedLine()),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Text(
                //   MyString.useBiometricAccess,
                //   style: TextStyle(
                //     fontFamily: FontFamily.poppinsSemiBold,
                //     color: MyColors.kAppThemeColor,
                //     fontSize: 16,
                //   ),
                // ),
                // SizedBox(height: 15),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     SvgPicture.asset("assets/icons/biometric_icon.svg"),
                //     SizedBox(
                //       width: 15,
                //     ),
                //     SvgPicture.asset("assets/icons/finger_print_icon.svg"),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
