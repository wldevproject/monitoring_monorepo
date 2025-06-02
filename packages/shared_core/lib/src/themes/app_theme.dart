import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryVariant, // Dulu primaryVariant
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryVariant, // Dulu secondaryVariant
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onSurface: AppColors.textOnSurface,
        onBackground: AppColors.textOnBackground,
        onError: AppColors.textOnError,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.headline1, // Dulu headline1
        bodyLarge: AppTextStyles.bodyText1, // Dulu bodyText1
        // Map style lainnya ke TextTheme yang sesuai
      ),
      appBarTheme: const AppBarTheme(
        color: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.textOnPrimary),
        titleTextStyle: TextStyle(
            color: AppColors.textOnPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w500),
      ),
      // Definisikan komponen tema lainnya
    );
  }

  // Anda bisa menambahkan darkTheme juga jika perlu
}
