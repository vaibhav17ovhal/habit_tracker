import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'custom_colors.dart';
import 'custom_font_family.dart';

class CustomTextField {
  /// Example Code

  /// Prefix Icon
  static Widget prefixIconSet(String icon, bool isBorder) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
      child: SvgPicture.asset(icon, height: 20),
    );
  }

  static Widget customTextFieldEmail({
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextInputType textInputType,
    required TextInputAction textInputAction,
    required String hintText,
    required bool isBorder,
    Widget? prefixIcon,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    String? labelText,
  })
  {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: textInputType,
      textInputAction: textInputAction,
      validator: validator,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelText: labelText,
        labelStyle: TextStyle(
          fontFamily: FontFamily.sfProSemiBold,
          fontSize: 18,
          color: MyColors.darkNavyBlue,
        ),

        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontFamily: FontFamily.sfProRegular,
          fontSize: 17,
        ),

        prefixIcon: prefixIcon,

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: MyColors.lightGrey,
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: MyColors.cAppThemeTealGreen,
            width: 2,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: MyColors.lightGrey,
            width: 1.2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),

        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }

  /// Simple Text Field
  static Widget customTextFieldSimple({
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextInputType textInputType,
    required TextInputAction textInputAction,
    required String hintText,
    required bool isBorder,
    Widget? prefixIcon,
    Widget? suffixIcon,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    String? labelText,
  })
  {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: textInputType,
      textInputAction: textInputAction,
      validator: validator,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        filled: false,
        fillColor: MyColors.kWhiteColor,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: labelText,
        labelStyle: TextStyle(
          fontFamily: FontFamily.sfProSemiBold,
          fontSize: 12,
          color: MyColors.kAppThemeColor,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: MyColors.kDescriptionColor,
          fontSize: 17,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
          isBorder
              ? BorderSide(width: 1, color: Colors.grey)
              : BorderSide(width: 0, color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
          isBorder
              ? BorderSide(width: 1, color: Colors.grey)
              : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
          isBorder
              ? BorderSide(width: 1, color: Colors.grey)
              : BorderSide.none,
        ),
      ),
    );
  }

  static Widget customSearchField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextInputAction textInputAction,
    required String hintText,
    bool isBorder = true,
    VoidCallback? onTap,
    Function(String)? onChanged,
    VoidCallback? onClear,
    String? labelText,
  })
  {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, TextEditingValue value, child) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onTap: onTap,
          onTapOutside:
              (event) => FocusManager.instance.primaryFocus?.unfocus(),

          decoration: InputDecoration(
            filled: true,
            fillColor:
            isBorder
                ? MyColors.kWhiteColor
                : MyColors.kTextFieldBorderColor,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelText: labelText,
            labelStyle: TextStyle(
              fontFamily: FontFamily.sfProSemiBold,
              fontSize: 18,
              color: MyColors.kAppThemeColor,
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: MyColors.kDescriptionColor,
              fontSize: 17,
              fontFamily: FontFamily.sfProMedium,
            ),

            prefixIcon: Icon(
              Icons.search,
              color: MyColors.kDescriptionColor,
            ),

            suffixIcon:
            value.text.isNotEmpty
                ? GestureDetector(
              onTap: () {
                controller.clear();
                onClear?.call();
              },
              child: Icon(
                Icons.close,
                color: MyColors.kDescriptionColor,
              ),
            )
                : null,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide:
              isBorder
                  ? BorderSide(color: Color(0XFFDBDAE3), width: 1)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide:
              isBorder
                  ? BorderSide(color: Color(0XFFDBDAE3), width: 1)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide:
              isBorder
                  ? BorderSide(color: Color(0XFFDBDAE3), width: 1)
                  : BorderSide.none,
            ),
          ),
        );
      },
    );
  }

  /// Password
  static Widget customTextFieldPassword({
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextInputAction textInputAction,
    required String hintText,
    required bool isBorder,
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
    String? labelText,
  })
  {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: !isPasswordVisible,
      textInputAction: textInputAction,
      validator: validator,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: labelText,
        labelStyle: TextStyle(
          fontFamily: FontFamily.sfProSemiBold,
          fontSize: 18,
          color: MyColors.darkNavyBlue,
        ),

        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontFamily: FontFamily.sfProRegular,
          fontSize: 17,
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: onToggleVisibility,
            child: SvgPicture.asset(
              isPasswordVisible
                  ? "assets/icons/password_show_icon.svg"
                  : "assets/icons/password_hide_icon.svg",
            ),
          ),
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: MyColors.lightGrey,
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: MyColors.cAppThemeTealGreen,
            width: 2,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: MyColors.lightGrey,
            width: 1.2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  /// DropDown with Radio
  static Widget customDropdownField({
    required String hintText,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
    String? labelText,
    bool? filled,
    Color? color,
    bool? isBorder,
  })
  {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,

      decoration: InputDecoration(
        labelText: labelText,
        filled: filled,
        fillColor: color,
        labelStyle: TextStyle(
          fontFamily: FontFamily.sfProSemiBold,
          fontSize: 18,
          color: MyColors.kAppThemeColor,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
          isBorder == false
              ? BorderSide(color: MyColors.kAppThemeColor, width: 1)
              : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
          isBorder == false
              ? BorderSide(color: MyColors.kTextFieldBorderColor, width: 1)
              : BorderSide.none,
        ),
      ),

      hint: Text(
        hintText,
        style: TextStyle(
          color: MyColors.kDescriptionColor,
          fontSize: 17,
          fontFamily: FontFamily.sfProRegular,
        ),
      ),

      icon: Icon(
        Icons.keyboard_arrow_down_outlined,
        color: MyColors.kDescriptionColor,
      ),
      items:
      items.map((e) {
        return DropdownMenuItem<String>(
          value: e,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<String>(
                activeColor: MyColors.kAppThemeColor,
                value: e,
                groupValue: value,
                onChanged: (val) {
                  onChanged(val);
                },
              ),
              SizedBox(width: 8),
              Text(e),
            ],
          ),
        );
      }).toList(),

      selectedItemBuilder: (context) {
        return items.map((e) {
          return Text(e, style: TextStyle(color: MyColors.kAppThemeColor));
        }).toList();
      },

      onChanged: onChanged,
    );
  }

  /// DOB
  static Widget customDobField({
    required String hintText,
    required TextEditingController controller,
    required VoidCallback onTap,
    String? Function(String?)? validator,
    String? labelText,
  })
  {
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontFamily: FontFamily.sfProSemiBold,
          fontSize: 18,
          color: MyColors.kAppThemeColor,
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: MyColors.kDescriptionColor, fontFamily: FontFamily.sfProRegular, fontSize: 17),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset("assets/icons/calendar_icon.svg"),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: MyColors.kAppThemeColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: MyColors.kTextFieldBorderColor,
            width: 1,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  /// Multi Line TextField
  static Widget customMultilineTextField({
    required String hintText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    String? labelText,
    int minLines = 2,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines ?? null,
      keyboardType: TextInputType.multiline,

      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontFamily: FontFamily.sfProSemiBold,
          fontSize: 18,
          color: MyColors.kAppThemeColor,
        ),
        hintText: hintText,
        filled: true,
        fillColor: MyColors.kWhiteColor,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: EdgeInsets.all(10),

        hintStyle: TextStyle(
          color: MyColors.kVioletColor,
          fontFamily: FontFamily.sfProMedium,
          fontSize: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Multi Line TextField with label text
  static Widget customMultilineTextFieldWithLabelText({
    required String hintText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    String? labelText,
    int minLines = 2,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines ?? null,
      keyboardType: TextInputType.multiline,

      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontFamily: FontFamily.sfProSemiBold,
          fontSize: 18,
          color: MyColors.kAppThemeColor,
        ),
        hintText: hintText,
        filled: true,
        fillColor: MyColors.kWhiteColor,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: EdgeInsets.all(10),

        hintStyle: TextStyle(
          color: MyColors.kDescriptionColor,
          fontSize: 17,
          fontFamily: FontFamily.sfProRegular,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 1,
            color: MyColors.kTextFieldBorderColor,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 1,
            color: MyColors.kTextFieldBorderColor,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 1,
            color: MyColors.kTextFieldBorderColor,
          ),
        ),
      ),
    );
  }
}