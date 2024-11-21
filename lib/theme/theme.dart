import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4285812870),
      surfaceTint: Color(4285812870),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4294367743),
      onPrimaryContainer: Color(4281076542),
      secondary: Color(4285028717),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4293975284),
      onSecondaryContainer: Color(4280489768),
      tertiary: Color(4286665298),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294957785),
      onTertiaryContainer: Color(4281536786),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294965244),
      onSurface: Color(4280162847),
      onSurfaceVariant: Color(4283122765),
      outline: Color(4286411902),
      outlineVariant: Color(4291740622),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281610036),
      inversePrimary: Color(4293048308),
      primaryFixed: Color(4294367743),
      onPrimaryFixed: Color(4281076542),
      primaryFixedDim: Color(4293048308),
      onPrimaryFixedVariant: Color(4284168556),
      secondaryFixed: Color(4293975284),
      onSecondaryFixed: Color(4280489768),
      secondaryFixedDim: Color(4292067544),
      onSecondaryFixedVariant: Color(4283449941),
      tertiaryFixed: Color(4294957785),
      onTertiaryFixed: Color(4281536786),
      tertiaryFixedDim: Color(4294293431),
      onTertiaryFixedVariant: Color(4284889915),
      surfaceDim: Color(4292925407),
      surfaceBright: Color(4294965244),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294701560),
      surfaceContainer: Color(4294306803),
      surfaceContainerHigh: Color(4293912045),
      surfaceContainerHighest: Color(4293517543),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4283905384),
      surfaceTint: Color(4285812870),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4287391390),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4283186769),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4286541700),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4284626743),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4288309095),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      surface: Color(4294965244),
      onSurface: Color(4280162847),
      onSurfaceVariant: Color(4282859849),
      outline: Color(4284767589),
      outlineVariant: Color(4286675073),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281610036),
      inversePrimary: Color(4293048308),
      primaryFixed: Color(4287391390),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4285681283),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4286541700),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4284897131),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4288309095),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4286467919),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292925407),
      surfaceBright: Color(4294965244),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294701560),
      surfaceContainer: Color(4294306803),
      surfaceContainerHigh: Color(4293912045),
      surfaceContainerHighest: Color(4293517543),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4281602885),
      surfaceTint: Color(4285812870),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4283905384),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4280950319),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4283186769),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4282062616),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4284626743),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      surface: Color(4294965244),
      onSurface: Color(4278190080),
      onSurfaceVariant: Color(4280820266),
      outline: Color(4282859849),
      outlineVariant: Color(4282859849),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281610036),
      inversePrimary: Color(4294698495),
      primaryFixed: Color(4283905384),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4282326608),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4283186769),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4281673786),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4284626743),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4282917154),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292925407),
      surfaceBright: Color(4294965244),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294701560),
      surfaceContainer: Color(4294306803),
      surfaceContainerHigh: Color(4293912045),
      surfaceContainerHighest: Color(4293517543),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4293048308),
      surfaceTint: Color(4293048308),
      onPrimary: Color(4282589780),
      primaryContainer: Color(4284168556),
      onPrimaryContainer: Color(4294367743),
      secondary: Color(4292067544),
      onSecondary: Color(4281936958),
      secondaryContainer: Color(4283449941),
      onSecondaryContainer: Color(4293975284),
      tertiary: Color(4294293431),
      onTertiary: Color(4283180326),
      tertiaryContainer: Color(4284889915),
      onTertiaryContainer: Color(4294957785),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279636503),
      onSurface: Color(4293517543),
      onSurfaceVariant: Color(4291740622),
      outline: Color(4288122520),
      outlineVariant: Color(4283122765),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293517543),
      inversePrimary: Color(4285812870),
      primaryFixed: Color(4294367743),
      onPrimaryFixed: Color(4281076542),
      primaryFixedDim: Color(4293048308),
      onPrimaryFixedVariant: Color(4284168556),
      secondaryFixed: Color(4293975284),
      onSecondaryFixed: Color(4280489768),
      secondaryFixedDim: Color(4292067544),
      onSecondaryFixedVariant: Color(4283449941),
      tertiaryFixed: Color(4294957785),
      onTertiaryFixed: Color(4281536786),
      tertiaryFixedDim: Color(4294293431),
      onTertiaryFixedVariant: Color(4284889915),
      surfaceDim: Color(4279636503),
      surfaceBright: Color(4282202173),
      surfaceContainerLowest: Color(4279307538),
      surfaceContainerLow: Color(4280162847),
      surfaceContainer: Color(4280426020),
      surfaceContainerHigh: Color(4281149486),
      surfaceContainerHighest: Color(4281873209),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4293377017),
      surfaceTint: Color(4293048308),
      onPrimary: Color(4280747320),
      primaryContainer: Color(4289364667),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4292396252),
      onSecondary: Color(4280095267),
      secondaryContainer: Color(4288449441),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294556603),
      onTertiary: Color(4281076493),
      tertiaryContainer: Color(4290413442),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      surface: Color(4279636503),
      onSurface: Color(4294965755),
      onSurfaceVariant: Color(4292003794),
      outline: Color(4289372330),
      outlineVariant: Color(4287201418),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293517543),
      inversePrimary: Color(4284234350),
      primaryFixed: Color(4294367743),
      onPrimaryFixed: Color(4280352819),
      primaryFixedDim: Color(4293048308),
      onPrimaryFixedVariant: Color(4282984539),
      secondaryFixed: Color(4293975284),
      onSecondaryFixed: Color(4279766301),
      secondaryFixedDim: Color(4292067544),
      onSecondaryFixedVariant: Color(4282331716),
      tertiaryFixed: Color(4294957785),
      onTertiaryFixed: Color(4280616712),
      tertiaryFixedDim: Color(4294293431),
      onTertiaryFixedVariant: Color(4283640363),
      surfaceDim: Color(4279636503),
      surfaceBright: Color(4282202173),
      surfaceContainerLowest: Color(4279307538),
      surfaceContainerLow: Color(4280162847),
      surfaceContainer: Color(4280426020),
      surfaceContainerHigh: Color(4281149486),
      surfaceContainerHighest: Color(4281873209),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4294965755),
      surfaceTint: Color(4293048308),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4293377017),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294965755),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4292396252),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294965753),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4294556603),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      surface: Color(4279636503),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4294965755),
      outline: Color(4292003794),
      outlineVariant: Color(4292003794),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293517543),
      inversePrimary: Color(4282129229),
      primaryFixed: Color(4294500095),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4293377017),
      onPrimaryFixedVariant: Color(4280747320),
      secondaryFixed: Color(4294303993),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4292396252),
      onSecondaryFixedVariant: Color(4280095267),
      tertiaryFixed: Color(4294959327),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4294556603),
      onTertiaryFixedVariant: Color(4281076493),
      surfaceDim: Color(4279636503),
      surfaceBright: Color(4282202173),
      surfaceContainerLowest: Color(4279307538),
      surfaceContainerLow: Color(4280162847),
      surfaceContainer: Color(4280426020),
      surfaceContainerHigh: Color(4281149486),
      surfaceContainerHighest: Color(4281873209),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}