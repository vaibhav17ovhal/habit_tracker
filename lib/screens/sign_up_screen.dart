import 'package:Demo/screens/privacy_policy_screen.dart';
import 'package:Demo/screens/sign_in_screen.dart';
import 'package:Demo/screens/terms_and_condition_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/custom_colors.dart';
import '../custom_widgets/custom_font_family.dart';
import '../custom_widgets/custom_scaffold.dart';
import '../custom_widgets/custom_text_field.dart';
import '../providers/sign_up_provider.dart';
import '../utility/helper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignUpProvider>(context);
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
                  "Get Started",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: FontFamily.sfProBold,
                    color: MyColors.darkNavyBlue,
                  ),
                ),
                SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child:  CustomTextField.customTextFieldEmail(
                          controller: provider.firstNameController,
                          focusNode: firstNameFocusNode,
                          textInputType: TextInputType.name,
                          textInputAction: TextInputAction.done,
                          hintText: "Enter First Name",
                          isBorder: true,
                          prefixIcon: null,
                          onTap: () {},
                          validator: provider.validateFirstName,
                          labelText: "First Name",
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField.customTextFieldEmail(
                          controller: provider.lastNameController,
                          focusNode: lastNameFocusNode,
                          textInputType: TextInputType.name,
                          textInputAction: TextInputAction.done,
                          hintText: "Enter Last Name",
                          isBorder: true,
                          prefixIcon: null,
                          onTap: () {},
                          validator: provider.validateLastName,
                          labelText: "Last Name",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomTextField.customTextFieldEmail(
                    controller: provider.signUpEmailController,
                    focusNode: emailFocusNode,
                    textInputType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    hintText: "Enter Email Address",
                    isBorder: true,
                    prefixIcon: null,
                    onTap: () {},
                    validator: provider.validateEmail,
                    labelText: "Email Address",
                  ),
                ),
                SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomTextField.customTextFieldPassword(
                    controller: provider.signUpPasswordController,
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
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomTextField.customTextFieldPassword(
                    controller: provider.confirmPasswordController,
                    focusNode: confirmPasswordFocusNode,
                    textInputAction: TextInputAction.done,
                    hintText: "Enter Confirm Password",
                    labelText: "Confirm Password",
                    isBorder: true,
                    isPasswordVisible: provider.isConfirmPasswordVisible,
                    onToggleVisibility:
                    provider.toggleConfirmPasswordVisibility,
                    validator: provider.validateConfirmPassword,
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomButton.button(
                    buttonText: "Create Account",
                    buttonColor: MyColors.cAppThemeTealGreen,
                    borderRadius: 60,
                    onTap: () {
                      FocusScope.of(context).unfocus();

                      if (_formKey.currentState!.validate()) {
                        debugPrint("Registered Successfully");
                        Helper.customToast("Registered Successfully");
                        provider.clearSignUpFields(context: context);

                        // Navigator.pushAndRemoveUntil(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => HowDoYouDiscoverUsScreen(),
                        //   ),
                        //   (route) => false,
                        // );
                      } else {
                        Scrollable.ensureVisible(
                          _formKey.currentContext!,
                          duration: Duration(milliseconds: 300),
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
                        text: "Already have an account ?",
                        style: TextStyle(
                          color: MyColors.darkNavyBlue,
                          fontSize: 14,
                          fontFamily: FontFamily.sfProMedium,
                        ),
                      ),
                      TextSpan(
                        text: " Sign In",
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
                                builder: (context) => SignInScreen(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "By clicking Continue, I have read and agree with the ",
                          style: TextStyle(
                            color: MyColors.darkNavyBlue,
                            fontSize: 14,
                            fontFamily: FontFamily.sfProMedium,
                          ),
                        ),
                        TextSpan(
                          text: "Terms and Condition, ",
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
                                  builder:
                                      (context) =>
                                      TermsAndConditionScreen(),
                                ),
                              );
                            },
                        ),
                        TextSpan(
                          text: "Privacy Policy",
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
                                  builder:
                                      (context) =>
                                      PrivacyPolicyScreen(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
