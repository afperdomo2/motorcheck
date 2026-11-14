import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tokens semánticos que no encajan en [ColorScheme] pero que la app
/// necesita: estados y colores de identidad por tipo de vehículo.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.danger,
    required this.onDanger,
    required this.dangerContainer,
    required this.onDangerContainer,
    required this.accentText,
    required this.vehicleCar,
    required this.vehicleMotorcycle,
    required this.vehicleBike,
    required this.vehicleTruck,
    required this.vehicleScooter,
    required this.vehicleOther,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color danger;
  final Color onDanger;
  final Color dangerContainer;
  final Color onDangerContainer;

  /// Ámbar oscuro para texto o iconos sobre contenedores ámbar.
  final Color accentText;

  final Color vehicleCar;
  final Color vehicleMotorcycle;
  final Color vehicleBike;
  final Color vehicleTruck;
  final Color vehicleScooter;
  final Color vehicleOther;

  static AppSemanticColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppSemanticColors>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  Color vehicleColor(String type) {
    return switch (type) {
      'car' => vehicleCar,
      'motorcycle' => vehicleMotorcycle,
      'bike' => vehicleBike,
      'truck' => vehicleTruck,
      'scooter' => vehicleScooter,
      _ => vehicleOther,
    };
  }

  static const light = AppSemanticColors(
    success: AppColors.successLight,
    onSuccess: Colors.white,
    successContainer: AppColors.successContainerLight,
    onSuccessContainer: AppColors.onSuccessContainerLight,
    warning: AppColors.warningLight,
    onWarning: Colors.white,
    warningContainer: AppColors.warningContainerLight,
    onWarningContainer: AppColors.onWarningContainerLight,
    danger: AppColors.dangerLight,
    onDanger: Colors.white,
    dangerContainer: AppColors.dangerContainerLight,
    onDangerContainer: AppColors.onDangerContainerLight,
    accentText: AppColors.amberInk,
    vehicleCar: AppColors.carLight,
    vehicleMotorcycle: AppColors.motorcycleLight,
    vehicleBike: AppColors.bikeLight,
    vehicleTruck: AppColors.truckLight,
    vehicleScooter: AppColors.scooterLight,
    vehicleOther: AppColors.otherLight,
  );

  static const dark = AppSemanticColors(
    success: AppColors.successDark,
    onSuccess: Color(0xFF062B1E),
    successContainer: AppColors.successContainerDark,
    onSuccessContainer: AppColors.onSuccessContainerDark,
    warning: AppColors.warningDark,
    onWarning: Color(0xFF201607),
    warningContainer: AppColors.warningContainerDark,
    onWarningContainer: AppColors.onWarningContainerDark,
    danger: AppColors.dangerDark,
    onDanger: Color(0xFF2A0A0A),
    dangerContainer: AppColors.dangerContainerDark,
    onDangerContainer: AppColors.onDangerContainerDark,
    accentText: AppColors.amberBright,
    vehicleCar: AppColors.carDark,
    vehicleMotorcycle: AppColors.motorcycleDark,
    vehicleBike: AppColors.bikeDark,
    vehicleTruck: AppColors.truckDark,
    vehicleScooter: AppColors.scooterDark,
    vehicleOther: AppColors.otherDark,
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? danger,
    Color? onDanger,
    Color? dangerContainer,
    Color? onDangerContainer,
    Color? accentText,
    Color? vehicleCar,
    Color? vehicleMotorcycle,
    Color? vehicleBike,
    Color? vehicleTruck,
    Color? vehicleScooter,
    Color? vehicleOther,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      onDangerContainer: onDangerContainer ?? this.onDangerContainer,
      accentText: accentText ?? this.accentText,
      vehicleCar: vehicleCar ?? this.vehicleCar,
      vehicleMotorcycle: vehicleMotorcycle ?? this.vehicleMotorcycle,
      vehicleBike: vehicleBike ?? this.vehicleBike,
      vehicleTruck: vehicleTruck ?? this.vehicleTruck,
      vehicleScooter: vehicleScooter ?? this.vehicleScooter,
      vehicleOther: vehicleOther ?? this.vehicleOther,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      onDangerContainer: Color.lerp(
        onDangerContainer,
        other.onDangerContainer,
        t,
      )!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      vehicleCar: Color.lerp(vehicleCar, other.vehicleCar, t)!,
      vehicleMotorcycle: Color.lerp(
        vehicleMotorcycle,
        other.vehicleMotorcycle,
        t,
      )!,
      vehicleBike: Color.lerp(vehicleBike, other.vehicleBike, t)!,
      vehicleTruck: Color.lerp(vehicleTruck, other.vehicleTruck, t)!,
      vehicleScooter: Color.lerp(vehicleScooter, other.vehicleScooter, t)!,
      vehicleOther: Color.lerp(vehicleOther, other.vehicleOther, t)!,
    );
  }
}
