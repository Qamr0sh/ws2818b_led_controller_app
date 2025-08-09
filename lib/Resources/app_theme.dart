import 'package:flutter/material.dart';
import '../../Resources/app_colors.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppColors.primaryBackgroundColor, // Background color for screens
  dialogBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: AppColors.primaryColor,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontFamily: 'Poppins',
      color: AppColors.white,
      fontSize: 18,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Poppins',
      color: AppColors.white,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Poppins',
      color: AppColors.white,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Poppins',
      color: AppColors.white,
      fontSize: 10,
      fontWeight: FontWeight.w700,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Poppins',
      color: AppColors.white,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Poppins',
      color: AppColors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Poppins',
      color: AppColors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Poppins',
      color: AppColors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),

    // Define other text styles as needed
  ),
  iconTheme: const IconThemeData(
    color: AppColors.darkGrey,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    hintStyle: TextStyle(
      fontFamily: 'Poppins',
      color: AppColors.lightGrey,
      fontSize: 18,
      fontWeight: FontWeight.w400,
    ),
    errorStyle: TextStyle(
      fontFamily: 'Poppins',
      color: AppColors.red,
      fontSize: 15,
      fontWeight: FontWeight.w400,
    ),
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.textFieldBorder),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.textFieldBorder),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.primaryColor),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(AppColors.primaryColor),
      foregroundColor: WidgetStateProperty.all(AppColors.white),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    ),
  ),
  extensions: const <ThemeExtension<dynamic>>[
    CustomTextStyleExtension(
      boldDarkGreyLarge: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: AppColors.darkGrey,
      ),
    ),
  ],
);

@immutable
class CustomTextStyleExtension extends ThemeExtension<CustomTextStyleExtension> {
  final TextStyle? boldDarkGreyLarge;

  const CustomTextStyleExtension({this.boldDarkGreyLarge});

  @override
  CustomTextStyleExtension copyWith({TextStyle? boldDarkGreyLarge}) {
    return CustomTextStyleExtension(
      boldDarkGreyLarge: boldDarkGreyLarge ?? this.boldDarkGreyLarge,
    );
  }

  @override
  CustomTextStyleExtension lerp(ThemeExtension<CustomTextStyleExtension>? other, double t) {
    if (other is! CustomTextStyleExtension) return this;
    return CustomTextStyleExtension(
      boldDarkGreyLarge: TextStyle.lerp(boldDarkGreyLarge, other.boldDarkGreyLarge, t),
    );
  }
}
