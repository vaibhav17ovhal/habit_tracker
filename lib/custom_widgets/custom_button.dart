import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomButton {

  /// Normal Button
  static Widget button({
    required String buttonText,
    required Color buttonColor,
    double? height,
    required double borderRadius,
    required GestureTapCallback onTap,
    required TextStyle textStyle,
  })
  {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              )
          ),
          onPressed: onTap,
          child: Text(buttonText, textAlign: TextAlign.center, style: textStyle, maxLines: 1,)
      ),
    );
  }

  /// Button with Prefix icon
  static Widget buttonWithIconLeft({
    required String buttonText,
    required Color buttonColor,
    required double elevation,
    double? height,
    required double borderRadius,
    required GestureTapCallback onTap,
    required TextStyle textStyle,
    required String icon,
    required double spaceBetween,
  })
  {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              elevation: elevation,
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              )
          ),
          onPressed: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(icon),
              SizedBox(
                width: spaceBetween,
              ),
              Flexible(
                child: Text(
                  textAlign: TextAlign.start,
                  buttonText, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis,),
              ),
            ],
          )
      ),
    );
  }

  /// Button with Suffix icon
  static Widget buttonWithIconRight({
    required String buttonText,
    required Color buttonColor,
    required double elevation,
    double? height,
    required double borderRadius,
    required GestureTapCallback onTap,
    required TextStyle textStyle,
    required String icon,
    required double spaceBetween,
  })
  {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              elevation: elevation,
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              )
          ),
          onPressed: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  textAlign: TextAlign.start,
                  buttonText, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis,),
              ),
              SizedBox(
                width: spaceBetween,
              ),
              SvgPicture.asset(icon),
            ],
          )
      ),
    );
  }

  static Widget buttonWithIconRightWithIconNear({
    required String buttonText,
    required Color buttonColor,
    required double elevation,
    double? height,
    required double borderRadius,
    required GestureTapCallback onTap,
    required TextStyle textStyle,
    required String icon,
    required double spaceBetween,
  })
  {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              elevation: elevation,
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              )
          ),
          onPressed: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  textAlign: TextAlign.start,
                  buttonText, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis,),
              ),
              SizedBox(
                width: spaceBetween,
              ),
              SvgPicture.asset(icon),
            ],
          )
      ),
    );
  }
}