import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppStateSnapshot initial = await PersistenceStore.load();
  runApp(NailTimerApp(initial: initial));
}

// ─────────────────────────────────────────────────────────────────────────
// Theme
// ─────────────────────────────────────────────────────────────────────────

// Light-mode static constants. Kept for AppTheme.light() construction and
// any const widget that can't access BuildContext.
class AppPalette {
  static const Color cream = Color(0xFFFAF6F2);
  static const Color creamWarm = Color(0xFFF3EBE3);
  static const Color mauve = Color(0xFFB0436B);
  static const Color mauveDeep = Color(0xFF8B3553);
  static const Color blush = Color(0xFFF5DCE2);
  static const Color blushSoft = Color(0xFFFBEEF1);
  static const Color charcoal = Color(0xFF2F1D27);
  static const Color charcoalSoft = Color(0xFF5C434E);
  static const Color border = Color(0xFFEADBDF);
  static const Color borderSoft = Color(0xFFF2E6E9);
  static const Color muted = Color(0xFF8E737C);
  static const Color gold = Color(0xFFC9A87C);
}

// Dark-mode static constants — a moody spa.
class AppPaletteDark {
  static const Color cream = Color(0xFF1A1115); // deep aubergine background
  static const Color creamWarm = Color(0xFF2A1B22); // card surface
  static const Color mauve = Color(0xFFE07A9C); // brighter accent on dark
  static const Color mauveDeep = Color(0xFFC95778);
  static const Color blush = Color(0xFF5A3744);
  static const Color blushSoft = Color(0xFF35222B); // tinted card
  static const Color charcoal = Color(0xFFF5EBEE); // primary text = pale rose
  static const Color charcoalSoft = Color(0xFFD3BCC4);
  static const Color border = Color(0xFF4A3540);
  static const Color borderSoft = Color(0xFF32212A);
  static const Color muted = Color(0xFFB498A2); // bumped for readability
  static const Color gold = Color(0xFFE0C49A);
}

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.cream,
    required this.creamWarm,
    required this.mauve,
    required this.mauveDeep,
    required this.blush,
    required this.blushSoft,
    required this.charcoal,
    required this.charcoalSoft,
    required this.border,
    required this.borderSoft,
    required this.muted,
    required this.gold,
  });

  final Color cream;
  final Color creamWarm;
  final Color mauve;
  final Color mauveDeep;
  final Color blush;
  final Color blushSoft;
  final Color charcoal;
  final Color charcoalSoft;
  final Color border;
  final Color borderSoft;
  final Color muted;
  final Color gold;

  static const AppColors light = AppColors(
    cream: AppPalette.cream,
    creamWarm: AppPalette.creamWarm,
    mauve: AppPalette.mauve,
    mauveDeep: AppPalette.mauveDeep,
    blush: AppPalette.blush,
    blushSoft: AppPalette.blushSoft,
    charcoal: AppPalette.charcoal,
    charcoalSoft: AppPalette.charcoalSoft,
    border: AppPalette.border,
    borderSoft: AppPalette.borderSoft,
    muted: AppPalette.muted,
    gold: AppPalette.gold,
  );

  static const AppColors dark = AppColors(
    cream: AppPaletteDark.cream,
    creamWarm: AppPaletteDark.creamWarm,
    mauve: AppPaletteDark.mauve,
    mauveDeep: AppPaletteDark.mauveDeep,
    blush: AppPaletteDark.blush,
    blushSoft: AppPaletteDark.blushSoft,
    charcoal: AppPaletteDark.charcoal,
    charcoalSoft: AppPaletteDark.charcoalSoft,
    border: AppPaletteDark.border,
    borderSoft: AppPaletteDark.borderSoft,
    muted: AppPaletteDark.muted,
    gold: AppPaletteDark.gold,
  );

  @override
  AppColors copyWith({
    Color? cream,
    Color? creamWarm,
    Color? mauve,
    Color? mauveDeep,
    Color? blush,
    Color? blushSoft,
    Color? charcoal,
    Color? charcoalSoft,
    Color? border,
    Color? borderSoft,
    Color? muted,
    Color? gold,
  }) {
    return AppColors(
      cream: cream ?? this.cream,
      creamWarm: creamWarm ?? this.creamWarm,
      mauve: mauve ?? this.mauve,
      mauveDeep: mauveDeep ?? this.mauveDeep,
      blush: blush ?? this.blush,
      blushSoft: blushSoft ?? this.blushSoft,
      charcoal: charcoal ?? this.charcoal,
      charcoalSoft: charcoalSoft ?? this.charcoalSoft,
      border: border ?? this.border,
      borderSoft: borderSoft ?? this.borderSoft,
      muted: muted ?? this.muted,
      gold: gold ?? this.gold,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      cream: Color.lerp(cream, other.cream, t)!,
      creamWarm: Color.lerp(creamWarm, other.creamWarm, t)!,
      mauve: Color.lerp(mauve, other.mauve, t)!,
      mauveDeep: Color.lerp(mauveDeep, other.mauveDeep, t)!,
      blush: Color.lerp(blush, other.blush, t)!,
      blushSoft: Color.lerp(blushSoft, other.blushSoft, t)!,
      charcoal: Color.lerp(charcoal, other.charcoal, t)!,
      charcoalSoft: Color.lerp(charcoalSoft, other.charcoalSoft, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSoft: Color.lerp(borderSoft, other.borderSoft, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}

class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final TextTheme base = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    final TextTheme body = GoogleFonts.interTextTheme(base).apply(
      bodyColor: c.charcoal,
      displayColor: c.charcoal,
    );

    final TextTheme textTheme = body.copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 44,
        fontWeight: FontWeight.w500,
        color: c.charcoal,
        height: 1.1,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 34,
        fontWeight: FontWeight.w500,
        color: c.charcoal,
        height: 1.15,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: c.charcoal,
        height: 1.2,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 30,
        fontWeight: FontWeight.w500,
        color: c.charcoal,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: c.charcoal,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: c.charcoal,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: c.charcoal,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: c.charcoal,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: c.charcoalSoft,
        letterSpacing: 1.4,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        color: c.charcoal,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: c.charcoal,
        height: 1.45,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        color: c.muted,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: c.charcoal,
        letterSpacing: 0.2,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: c.charcoalSoft,
        letterSpacing: 0.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: c.muted,
        letterSpacing: 0.6,
      ),
    );

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: c.mauve,
      brightness: brightness,
      primary: c.mauve,
      onPrimary: Colors.white,
      secondary: c.gold,
      onSecondary: Colors.white,
      surface: c.cream,
      onSurface: c.charcoal,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.cream,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: c.charcoal),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: c.charcoal,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: c.creamWarm,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: c.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.mauve,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.charcoal,
          side: BorderSide(color: c.border),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.mauve,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: c.charcoal),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.creamWarm,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: GoogleFonts.inter(color: c.muted),
        labelStyle: GoogleFonts.inter(
          color: c.charcoalSoft,
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.mauve, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.creamWarm,
        selectedColor: c.mauve,
        side: BorderSide(color: c.border),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: c.charcoal,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
        trackColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return c.mauve;
          }
          return c.border;
        }),
        trackOutlineColor: const WidgetStatePropertyAll<Color>(
          Colors.transparent,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: c.borderSoft,
        space: 32,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.cream,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: c.mauve.withValues(alpha: 0.5),
        dragHandleSize: const Size(48, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.cream,
        surfaceTintColor: Colors.transparent,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.selected)) {
              return c.charcoal;
            }
            return c.creamWarm;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.selected)) {
              return c.cream;
            }
            return c.charcoal;
          }),
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: c.border),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle>(
            GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────

const List<String> kNailNames = <String>[
  'Thumb',
  'Index',
  'Middle',
  'Ring',
  'Pinky',
];

enum BuildMode { allSame, perNail }

enum NailDesign {
  solid,
  catEye,
  matteGlossContrast,
  frenchTip,
  chromePowder,
  glitter,
  ombre,
  marble,
  polkaDots,
  stripes,
  glazed,
}

enum DesignDifficulty { beginner, intermediate, advanced }

enum ChromeStyle { regular, isolated, reverse }

enum ProductCategory { base, topCoat, color, catEye, chrome, misc }

const Map<NailDesign, String> kDesignLabels = <NailDesign, String>{
  NailDesign.solid: 'Solid Base',
  NailDesign.catEye: 'Cat Eye',
  NailDesign.matteGlossContrast: 'Matte & Gloss',
  NailDesign.frenchTip: 'French Tip',
  NailDesign.chromePowder: 'Chrome Powder',
  NailDesign.glitter: 'Glitter',
  NailDesign.ombre: 'Ombré Fade',
  NailDesign.marble: 'Marble Swirl',
  NailDesign.polkaDots: 'Polka Dots',
  NailDesign.stripes: 'Stripes',
  NailDesign.glazed: 'Glazed Donut',
};

const Map<NailDesign, String> kDesignBlurbs = <NailDesign, String>{
  NailDesign.solid: 'Clean single-tone finish.',
  NailDesign.catEye: 'Magnetic shimmer through the center.',
  NailDesign.matteGlossContrast: 'Half matte, half gloss contrast.',
  NailDesign.frenchTip: 'Classic white crescent at the tip.',
  NailDesign.chromePowder: 'Mirror-finish chrome shimmer.',
  NailDesign.glitter: 'Sparkling flake overlay across the nail.',
  NailDesign.ombre: 'Soft fade from base color to white tip.',
  NailDesign.marble: 'Veined swirl pattern with two tones.',
  NailDesign.polkaDots: 'Evenly spaced contrast dots.',
  NailDesign.stripes: 'Diagonal contrast stripes.',
  NailDesign.glazed: 'Pearlescent rainbow sheen, Hailey-style.',
};

const Map<NailDesign, DesignDifficulty> kDesignDifficulty =
    <NailDesign, DesignDifficulty>{
      NailDesign.solid: DesignDifficulty.beginner,
      NailDesign.catEye: DesignDifficulty.beginner,
      NailDesign.matteGlossContrast: DesignDifficulty.intermediate,
      NailDesign.frenchTip: DesignDifficulty.intermediate,
      NailDesign.chromePowder: DesignDifficulty.advanced,
      NailDesign.glitter: DesignDifficulty.beginner,
      NailDesign.ombre: DesignDifficulty.intermediate,
      NailDesign.marble: DesignDifficulty.advanced,
      NailDesign.polkaDots: DesignDifficulty.beginner,
      NailDesign.stripes: DesignDifficulty.intermediate,
      NailDesign.glazed: DesignDifficulty.advanced,
    };

const Map<DesignDifficulty, String> kDifficultyLabels =
    <DesignDifficulty, String>{
      DesignDifficulty.beginner: 'Beginner',
      DesignDifficulty.intermediate: 'Intermediate',
      DesignDifficulty.advanced: 'Advanced',
    };

class NailHoroscope {
  const NailHoroscope({required this.title, required this.body});
  final String title;
  final String body;
}

const List<NailHoroscope> kHoroscopes = <NailHoroscope>[
  NailHoroscope(
    title: 'Today calls for chrome',
    body: 'Lean into something with a little shine.',
  ),
  NailHoroscope(
    title: 'Quiet luxury',
    body: 'A milky base feels like silk against the skin.',
  ),
  NailHoroscope(
    title: 'Bold strokes',
    body: 'You\'ve been playing it safe. Try a statement design.',
  ),
  NailHoroscope(
    title: 'Detail energy',
    body: 'Slow down — tonight is for the intricate stuff.',
  ),
  NailHoroscope(
    title: 'Soft palette day',
    body: 'Reach for a nude, a blush, or a sage.',
  ),
  NailHoroscope(
    title: 'Inner glow',
    body: 'A subtle shimmer changes the whole vibe.',
  ),
  NailHoroscope(
    title: 'Maximalist mood',
    body: 'Pile on the layers. Restraint is for tomorrow.',
  ),
  NailHoroscope(
    title: 'Classic comfort',
    body: 'There\'s nothing wrong with your signature look.',
  ),
  NailHoroscope(
    title: 'Edgy undertones',
    body: 'A darker base sharpens any design.',
  ),
  NailHoroscope(
    title: 'Playful spark',
    body: 'Add a single accent finger that surprises you.',
  ),
  NailHoroscope(
    title: 'Slow + steady',
    body: 'A perfect set isn\'t rushed.',
  ),
  NailHoroscope(
    title: 'Try something new',
    body: 'Test a design you\'ve been bookmarking.',
  ),
  NailHoroscope(
    title: 'Cozy palette',
    body: 'Warm tones today — burgundy, gold, deep nude.',
  ),
  NailHoroscope(
    title: 'Cool palette',
    body: 'Lean blue, lavender, milky — keep it crisp.',
  ),
  NailHoroscope(
    title: 'Glassy finish',
    body: 'Lots of top coat. Lots of shine.',
  ),
  NailHoroscope(
    title: 'Matte mindset',
    body: 'Try the matte top coat you keep forgetting.',
  ),
  NailHoroscope(
    title: 'Less is more',
    body: 'A simple solid color, done perfectly.',
  ),
  NailHoroscope(
    title: 'French revival',
    body: 'The french tip never went away. Try a fresh tone.',
  ),
  NailHoroscope(
    title: 'Texture day',
    body: 'Glitter, marble, or chrome — pick something tactile.',
  ),
  NailHoroscope(
    title: 'Self-care first',
    body: 'Take this hour for yourself. The set is the bonus.',
  ),
];

String encodePresetQrPayload(DesignPreset preset) {
  final Map<String, dynamic> payload = <String, dynamic>{
    'v': 1,
    'app': 'nailtimer',
    'preset': preset.toJson(),
  };
  final String json = jsonEncode(payload);
  return base64Url.encode(utf8.encode(json));
}

DesignPreset? decodePresetQrPayload(String raw) {
  try {
    final String json = utf8.decode(base64Url.decode(raw));
    final dynamic decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    if (decoded['app'] != 'nailtimer') {
      return null;
    }
    final dynamic body = decoded['preset'];
    if (body is! Map<String, dynamic>) {
      return null;
    }
    return DesignPreset.fromJson(body);
  } catch (_) {
    return null;
  }
}

NailHoroscope horoscopeForToday() {
  final DateTime now = DateTime.now();
  final int dayOfYear =
      now.difference(DateTime(now.year)).inDays;
  return kHoroscopes[dayOfYear % kHoroscopes.length];
}

enum MoodVibe { soft, glam, fierce, minimal, bold, playful }

class MoodPreset {
  const MoodPreset({
    required this.vibe,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.baseColor,
    required this.design,
  });

  final MoodVibe vibe;
  final String label;
  final String subtitle;
  final IconData icon;
  final String baseColor;
  final NailDesign design;
}

const List<MoodPreset> kMoodPresets = <MoodPreset>[
  MoodPreset(
    vibe: MoodVibe.soft,
    label: 'Soft',
    subtitle: 'Romantic, quiet luxury',
    icon: Icons.spa_outlined,
    baseColor: 'Soft Pink',
    design: NailDesign.ombre,
  ),
  MoodPreset(
    vibe: MoodVibe.glam,
    label: 'Glam',
    subtitle: 'Shine, chrome, statement',
    icon: Icons.auto_awesome,
    baseColor: 'Gold',
    design: NailDesign.chromePowder,
  ),
  MoodPreset(
    vibe: MoodVibe.fierce,
    label: 'Fierce',
    subtitle: 'Dark, sharp, confident',
    icon: Icons.local_fire_department_outlined,
    baseColor: 'Burgundy',
    design: NailDesign.matteGlossContrast,
  ),
  MoodPreset(
    vibe: MoodVibe.minimal,
    label: 'Minimal',
    subtitle: 'Clean, milky, restrained',
    icon: Icons.water_drop_outlined,
    baseColor: 'Milky White',
    design: NailDesign.solid,
  ),
  MoodPreset(
    vibe: MoodVibe.bold,
    label: 'Bold',
    subtitle: 'Drama, color, attitude',
    icon: Icons.bolt_outlined,
    baseColor: 'Black',
    design: NailDesign.catEye,
  ),
  MoodPreset(
    vibe: MoodVibe.playful,
    label: 'Playful',
    subtitle: 'Pastels, dots, fun',
    icon: Icons.celebration_outlined,
    baseColor: 'Lavender',
    design: NailDesign.polkaDots,
  ),
];

String difficultyLabel(DesignDifficulty d) {
  return kDifficultyLabels[d] ?? 'Any';
}

DesignDifficulty designDifficulty(NailDesign d) {
  return kDesignDifficulty[d] ?? DesignDifficulty.beginner;
}

const Map<ProductCategory, String> kProductCategoryLabels =
    <ProductCategory, String>{
      ProductCategory.base: 'Base',
      ProductCategory.topCoat: 'Top Coat',
      ProductCategory.color: 'Color',
      ProductCategory.catEye: 'Cat Eye',
      ProductCategory.chrome: 'Chrome',
      ProductCategory.misc: 'Misc',
    };

const Map<ChromeStyle, String> kChromeStyleLabels = <ChromeStyle, String>{
  ChromeStyle.regular: 'Regular',
  ChromeStyle.isolated: 'Isolated',
  ChromeStyle.reverse: 'Reverse',
};

String designLabel(NailDesign design) {
  return kDesignLabels[design] ?? 'Unknown';
}

String designBlurb(NailDesign design) {
  return kDesignBlurbs[design] ?? '';
}

String productCategoryLabel(ProductCategory category) {
  return kProductCategoryLabels[category] ?? 'Other';
}

String chromeStyleLabel(ChromeStyle style) {
  return kChromeStyleLabels[style] ?? 'Chrome';
}

const Map<String, Color> kDefaultPalette = <String, Color>{
  'Nude': Color(0xFFD5B29F),
  'Soft Pink': Color(0xFFE8B7C8),
  'Milky White': Color(0xFFF5F4EF),
  'Clear': Color(0xFFE9EDF2),
  'Black': Color(0xFF2D2D2D),
  'Gold': Color(0xFFD4AF37),
  'Blue': Color(0xFF6EA8FE),
  'Burgundy': Color(0xFF6E1F2C),
  'Sage': Color(0xFFB8C9A6),
  'Lavender': Color(0xFFC8B6E2),
};

Color baseColorValue(String baseColor, [List<CustomColor>? customColors]) {
  if (customColors != null) {
    for (final CustomColor cc in customColors) {
      if (cc.name == baseColor) {
        return cc.color;
      }
    }
  }
  return kDefaultPalette[baseColor] ?? const Color(0xFFD5B29F);
}

Color chromeShadeColor(String chromeShade) {
  switch (chromeShade) {
    case 'White Silver':
      return const Color(0xFFD9DEE7);
    case 'Gold':
      return const Color(0xFFD4AF37);
    case 'White/Blue':
      return const Color(0xFFBED7FF);
  }
  return const Color(0xFFD4AF37);
}

String formatClock(int seconds) {
  final int minutes = seconds ~/ 60;
  final int remainder = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
}

String colorHex(Color c) {
  final int r = (c.r * 255).round();
  final int g = (c.g * 255).round();
  final int b = (c.b * 255).round();
  String two(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();
  return '#${two(r)}${two(g)}${two(b)}';
}

String formatSessionDate(DateTime d) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime dayDate = DateTime(d.year, d.month, d.day);
  if (dayDate == today) return 'Today';
  if (dayDate == today.subtract(const Duration(days: 1))) return 'Yesterday';
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

String formatSessionTime(DateTime d) {
  final int hour12 = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
  final String ampm = d.hour >= 12 ? 'PM' : 'AM';
  return '$hour12:${d.minute.toString().padLeft(2, '0')} $ampm';
}

String formatRelativeDate(DateTime d) {
  final DateTime now = DateTime.now();
  final Duration diff = now.difference(d);
  if (diff.isNegative) return formatSessionDate(d);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) {
    final int h = diff.inHours;
    return h == 1 ? '1 hour ago' : '$h hours ago';
  }
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  if (diff.inDays < 30) {
    final int w = (diff.inDays / 7).floor();
    return w == 1 ? '1 week ago' : '$w weeks ago';
  }
  if (diff.inDays < 365) {
    final int m = (diff.inDays / 30).floor();
    return m == 1 ? '1 month ago' : '$m months ago';
  }
  final int y = (diff.inDays / 365).floor();
  return y == 1 ? '1 year ago' : '$y years ago';
}

NailDesign designForStepThumbnail(String stepId) {
  if (stepId.startsWith('cat-eye')) return NailDesign.catEye;
  if (stepId.startsWith('matte-gloss')) return NailDesign.matteGlossContrast;
  if (stepId.startsWith('french-tip')) return NailDesign.frenchTip;
  if (stepId.startsWith('chrome')) return NailDesign.chromePowder;
  if (stepId.startsWith('glitter')) return NailDesign.glitter;
  if (stepId.startsWith('ombre')) return NailDesign.ombre;
  if (stepId.startsWith('marble')) return NailDesign.marble;
  if (stepId.startsWith('polka-dots')) return NailDesign.polkaDots;
  if (stepId.startsWith('stripes')) return NailDesign.stripes;
  if (stepId.startsWith('glazed')) return NailDesign.glazed;
  return NailDesign.solid;
}

class StepProduct {
  const StepProduct({
    this.name = '',
    this.code = '',
    this.category = ProductCategory.misc,
  });

  final String name;
  final String code;
  final ProductCategory category;

  bool get isEmpty {
    return name.trim().isEmpty && code.trim().isEmpty;
  }

  String get normalizedKey {
    return '${name.trim().toLowerCase()}|${code.trim().toLowerCase()}|${category.name}';
  }

  String get label {
    final String cleanName = name.trim().isEmpty ? 'Unnamed' : name.trim();
    final String cleanCode = code.trim().isEmpty ? '' : ' · #${code.trim()}';
    return '$cleanName$cleanCode';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'code': code,
    'category': category.name,
  };

  static StepProduct fromJson(Map<String, dynamic> json) {
    final String catName = json['category'] as String? ?? 'misc';
    final ProductCategory category = ProductCategory.values.firstWhere(
      (ProductCategory c) => c.name == catName,
      orElse: () => ProductCategory.misc,
    );
    return StepProduct(
      name: (json['name'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      category: category,
    );
  }
}

class CustomColor {
  const CustomColor({required this.name, required this.color});

  final String name;
  final Color color;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'argb': (color.a * 255).round() << 24 |
        (color.r * 255).round() << 16 |
        (color.g * 255).round() << 8 |
        (color.b * 255).round(),
  };

  static CustomColor fromJson(Map<String, dynamic> json) {
    return CustomColor(
      name: (json['name'] as String?) ?? 'Untitled',
      color: Color((json['argb'] as int?) ?? 0xFFD5B29F),
    );
  }
}

class AppSettings {
  const AppSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.defaultStepSeconds = 60,
    this.defaultBaseColor = 'Nude',
    this.keepScreenAwake = true,
    this.themeMode = ThemeMode.system,
    this.oneHandedMode = false,
    this.recentColors = const <String>[],
    this.shareWatermark = true,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final int defaultStepSeconds;
  final String defaultBaseColor;
  final bool keepScreenAwake;
  final ThemeMode themeMode;
  final bool oneHandedMode;
  final List<String> recentColors;
  final bool shareWatermark;

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    int? defaultStepSeconds,
    String? defaultBaseColor,
    bool? keepScreenAwake,
    ThemeMode? themeMode,
    bool? oneHandedMode,
    List<String>? recentColors,
    bool? shareWatermark,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      defaultStepSeconds: defaultStepSeconds ?? this.defaultStepSeconds,
      defaultBaseColor: defaultBaseColor ?? this.defaultBaseColor,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      themeMode: themeMode ?? this.themeMode,
      oneHandedMode: oneHandedMode ?? this.oneHandedMode,
      recentColors: recentColors ?? this.recentColors,
      shareWatermark: shareWatermark ?? this.shareWatermark,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'soundEnabled': soundEnabled,
    'hapticsEnabled': hapticsEnabled,
    'defaultStepSeconds': defaultStepSeconds,
    'defaultBaseColor': defaultBaseColor,
    'keepScreenAwake': keepScreenAwake,
    'themeMode': themeMode.name,
    'oneHandedMode': oneHandedMode,
    'recentColors': recentColors,
    'shareWatermark': shareWatermark,
  };

  static AppSettings fromJson(Map<String, dynamic> json) {
    final String mode = (json['themeMode'] as String?) ?? 'system';
    final ThemeMode parsed = ThemeMode.values.firstWhere(
      (ThemeMode m) => m.name == mode,
      orElse: () => ThemeMode.system,
    );
    final List<String> recent =
        (json['recentColors'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            <String>[];
    return AppSettings(
      soundEnabled: (json['soundEnabled'] as bool?) ?? true,
      hapticsEnabled: (json['hapticsEnabled'] as bool?) ?? true,
      defaultStepSeconds: (json['defaultStepSeconds'] as int?) ?? 60,
      defaultBaseColor: (json['defaultBaseColor'] as String?) ?? 'Nude',
      keepScreenAwake: (json['keepScreenAwake'] as bool?) ?? true,
      themeMode: parsed,
      oneHandedMode: (json['oneHandedMode'] as bool?) ?? false,
      recentColors: recent,
      shareWatermark: (json['shareWatermark'] as bool?) ?? true,
    );
  }
}

class LookBookEntry {
  const LookBookEntry({
    required this.id,
    required this.photoPath,
    required this.savedAt,
    this.note,
    this.tags = const <String>[],
  });

  final String id;
  final String photoPath;
  final DateTime savedAt;
  final String? note;
  final List<String> tags;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'photoPath': photoPath,
    'savedAt': savedAt.toIso8601String(),
    'note': note,
    'tags': tags,
  };

  static LookBookEntry fromJson(Map<String, dynamic> json) {
    DateTime parsed;
    try {
      parsed = DateTime.parse(json['savedAt'] as String);
    } catch (_) {
      parsed = DateTime.now();
    }
    final List<String> tags =
        (json['tags'] as List<dynamic>?)?.whereType<String>().toList() ??
            <String>[];
    return LookBookEntry(
      id: (json['id'] as String?) ??
          parsed.millisecondsSinceEpoch.toString(),
      photoPath: (json['photoPath'] as String?) ?? '',
      savedAt: parsed,
      note: json['note'] as String?,
      tags: tags,
    );
  }
}

class SessionRecord {
  const SessionRecord({
    required this.id,
    required this.completedAt,
    required this.durationSeconds,
    required this.baseColorName,
    required this.baseColorArgb,
    required this.chromeShade,
    required this.mode,
    required this.allNailsDesign,
    required this.perNailDesigns,
    this.photoPath,
    this.notes,
    this.perNailColorArgbs,
  });

  final String id;
  final DateTime completedAt;
  final int durationSeconds;
  final String baseColorName;
  final int baseColorArgb;
  final String chromeShade;
  final BuildMode mode;
  final NailDesign allNailsDesign;
  final List<NailDesign> perNailDesigns;
  final String? photoPath;
  final String? notes;
  final List<int>? perNailColorArgbs;

  Color get baseColor => Color(baseColorArgb);

  String get designSummary {
    if (mode == BuildMode.allSame) {
      return designLabel(allNailsDesign);
    }
    final Set<NailDesign> unique = perNailDesigns.toSet();
    if (unique.length == 1) {
      return designLabel(unique.first);
    }
    return 'Mixed (${unique.length} designs)';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'completedAt': completedAt.toIso8601String(),
    'durationSeconds': durationSeconds,
    'baseColorName': baseColorName,
    'baseColorArgb': baseColorArgb,
    'chromeShade': chromeShade,
    'mode': mode.name,
    'allNailsDesign': allNailsDesign.name,
    'perNailDesigns':
        perNailDesigns.map((NailDesign d) => d.name).toList(),
    'perNailColorArgbs': perNailColorArgbs,
    'photoPath': photoPath,
    'notes': notes,
  };

  static SessionRecord fromJson(Map<String, dynamic> json) {
    final BuildMode mode = BuildMode.values.firstWhere(
      (BuildMode m) => m.name == (json['mode'] as String? ?? 'allSame'),
      orElse: () => BuildMode.allSame,
    );
    final NailDesign allNails = NailDesign.values.firstWhere(
      (NailDesign d) =>
          d.name == (json['allNailsDesign'] as String? ?? 'solid'),
      orElse: () => NailDesign.solid,
    );
    final List<NailDesign> perNail =
        (json['perNailDesigns'] as List<dynamic>?)?.map((dynamic raw) {
              return NailDesign.values.firstWhere(
                (NailDesign d) => d.name == raw,
                orElse: () => NailDesign.solid,
              );
            }).toList() ??
            List<NailDesign>.filled(
              kNailNames.length,
              NailDesign.solid,
              growable: true,
            );

    DateTime parsed;
    try {
      parsed = DateTime.parse(json['completedAt'] as String);
    } catch (_) {
      parsed = DateTime.now();
    }

    final List<int>? perNailColorArgbs =
        (json['perNailColorArgbs'] as List<dynamic>?)
            ?.whereType<int>()
            .toList();

    return SessionRecord(
      id: (json['id'] as String?) ?? parsed.millisecondsSinceEpoch.toString(),
      completedAt: parsed,
      durationSeconds: (json['durationSeconds'] as int?) ?? 0,
      baseColorName: (json['baseColorName'] as String?) ?? 'Nude',
      baseColorArgb: (json['baseColorArgb'] as int?) ?? 0xFFD5B29F,
      chromeShade: (json['chromeShade'] as String?) ?? 'Gold',
      mode: mode,
      allNailsDesign: allNails,
      perNailDesigns: perNail,
      perNailColorArgbs: perNailColorArgbs,
      photoPath: json['photoPath'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

class RoutineStep {
  const RoutineStep({
    required this.id,
    required this.title,
    required this.seconds,
    this.categoryHint,
    this.isCustom = false,
  });

  final String id;
  final String title;
  final int seconds;
  final ProductCategory? categoryHint;
  final bool isCustom;

  RoutineStep copyWith({int? seconds, String? title}) {
    return RoutineStep(
      id: id,
      title: title ?? this.title,
      seconds: seconds ?? this.seconds,
      categoryHint: categoryHint,
      isCustom: isCustom,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'seconds': seconds,
    'categoryHint': categoryHint?.name,
    'isCustom': isCustom,
  };

  static RoutineStep fromJson(Map<String, dynamic> json) {
    ProductCategory? cat;
    final String? catName = json['categoryHint'] as String?;
    if (catName != null) {
      cat = ProductCategory.values.firstWhere(
        (ProductCategory c) => c.name == catName,
        orElse: () => ProductCategory.misc,
      );
    }
    return RoutineStep(
      id: (json['id'] as String?) ?? 'step',
      title: (json['title'] as String?) ?? 'Step',
      seconds: (json['seconds'] as int?) ?? 60,
      categoryHint: cat,
      isCustom: (json['isCustom'] as bool?) ?? false,
    );
  }
}

class DesignPreset {
  const DesignPreset({
    required this.name,
    required this.mode,
    required this.baseColor,
    required this.chromeShade,
    required this.chromeStyle,
    required this.allNailsDesign,
    required this.perNailDesigns,
    required this.includeAlcoholWipe,
    required this.includeFinalTopCoat,
    required this.customSeconds,
    required this.stepProducts,
    this.customSteps = const <RoutineStep>[],
    this.routineOrder,
    this.perNailColors,
  });

  final String name;
  final BuildMode mode;
  final String baseColor;
  final String chromeShade;
  final ChromeStyle chromeStyle;
  final NailDesign allNailsDesign;
  final List<NailDesign> perNailDesigns;
  final bool includeAlcoholWipe;
  final bool includeFinalTopCoat;
  final Map<String, int> customSeconds;
  final Map<String, StepProduct> stepProducts;
  final List<RoutineStep> customSteps;
  final List<String>? routineOrder;
  final List<String>? perNailColors;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'mode': mode.name,
    'baseColor': baseColor,
    'chromeShade': chromeShade,
    'chromeStyle': chromeStyle.name,
    'allNailsDesign': allNailsDesign.name,
    'perNailDesigns':
        perNailDesigns.map((NailDesign d) => d.name).toList(),
    'perNailColors': perNailColors,
    'includeAlcoholWipe': includeAlcoholWipe,
    'includeFinalTopCoat': includeFinalTopCoat,
    'customSeconds': customSeconds,
    'stepProducts': stepProducts.map(
      (String k, StepProduct v) =>
          MapEntry<String, dynamic>(k, v.toJson()),
    ),
    'customSteps':
        customSteps.map((RoutineStep s) => s.toJson()).toList(),
    'routineOrder': routineOrder,
  };

  static DesignPreset fromJson(Map<String, dynamic> json) {
    final BuildMode mode = BuildMode.values.firstWhere(
      (BuildMode m) => m.name == (json['mode'] as String? ?? 'allSame'),
      orElse: () => BuildMode.allSame,
    );
    final ChromeStyle chromeStyle = ChromeStyle.values.firstWhere(
      (ChromeStyle s) =>
          s.name == (json['chromeStyle'] as String? ?? 'regular'),
      orElse: () => ChromeStyle.regular,
    );
    final NailDesign allNails = NailDesign.values.firstWhere(
      (NailDesign d) =>
          d.name == (json['allNailsDesign'] as String? ?? 'solid'),
      orElse: () => NailDesign.solid,
    );
    final List<NailDesign> perNail =
        (json['perNailDesigns'] as List<dynamic>?)?.map((dynamic raw) {
          return NailDesign.values.firstWhere(
            (NailDesign d) => d.name == raw,
            orElse: () => NailDesign.solid,
          );
        }).toList() ??
        List<NailDesign>.filled(kNailNames.length, NailDesign.solid);

    final Map<String, int> customSeconds = <String, int>{};
    (json['customSeconds'] as Map<String, dynamic>?)?.forEach((
      String k,
      dynamic v,
    ) {
      if (v is int) customSeconds[k] = v;
    });

    final Map<String, StepProduct> stepProducts = <String, StepProduct>{};
    (json['stepProducts'] as Map<String, dynamic>?)?.forEach((
      String k,
      dynamic v,
    ) {
      if (v is Map<String, dynamic>) {
        stepProducts[k] = StepProduct.fromJson(v);
      }
    });

    final List<RoutineStep> customSteps =
        (json['customSteps'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map(RoutineStep.fromJson)
                .toList() ??
            <RoutineStep>[];

    List<String>? routineOrder;
    final dynamic rawOrder = json['routineOrder'];
    if (rawOrder is List) {
      routineOrder = rawOrder.whereType<String>().toList();
    }

    List<String>? perNailColors;
    final dynamic rawColors = json['perNailColors'];
    if (rawColors is List) {
      perNailColors = rawColors.whereType<String>().toList();
    }

    return DesignPreset(
      name: (json['name'] as String?) ?? 'Preset',
      mode: mode,
      baseColor: (json['baseColor'] as String?) ?? 'Nude',
      chromeShade: (json['chromeShade'] as String?) ?? 'Gold',
      chromeStyle: chromeStyle,
      allNailsDesign: allNails,
      perNailDesigns: perNail,
      perNailColors: perNailColors,
      includeAlcoholWipe: (json['includeAlcoholWipe'] as bool?) ?? true,
      includeFinalTopCoat: (json['includeFinalTopCoat'] as bool?) ?? true,
      customSeconds: customSeconds,
      stepProducts: stepProducts,
      customSteps: customSteps,
      routineOrder: routineOrder,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Persistence
// ─────────────────────────────────────────────────────────────────────────

class AppStateSnapshot {
  const AppStateSnapshot({
    required this.presets,
    required this.products,
    required this.customColors,
    required this.sessions,
    required this.onboardingComplete,
    required this.settings,
    this.lastState,
  });

  final List<DesignPreset> presets;
  final List<StepProduct> products;
  final List<CustomColor> customColors;
  final List<SessionRecord> sessions;
  final bool onboardingComplete;
  final AppSettings settings;
  final DesignPreset? lastState;

  static AppStateSnapshot empty() {
    return const AppStateSnapshot(
      presets: <DesignPreset>[],
      products: <StepProduct>[],
      customColors: <CustomColor>[],
      sessions: <SessionRecord>[],
      onboardingComplete: false,
      settings: AppSettings(),
    );
  }
}

class PersistenceStore {
  static const String _kPresets = 'nt.presets.v1';
  static const String _kProducts = 'nt.products.v1';
  static const String _kCustomColors = 'nt.customColors.v1';
  static const String _kLastState = 'nt.lastState.v1';
  static const String _kSessions = 'nt.sessions.v1';
  static const String _kOnboarding = 'nt.onboardingComplete.v1';
  static const String _kSettings = 'nt.settings.v1';
  static const String _kLookBook = 'nt.lookBook.v1';

  static Future<AppStateSnapshot> load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      DesignPreset? lastState;
      final String? rawLast = prefs.getString(_kLastState);
      if (rawLast != null && rawLast.isNotEmpty) {
        try {
          final dynamic decoded = jsonDecode(rawLast);
          if (decoded is Map<String, dynamic>) {
            lastState = DesignPreset.fromJson(decoded);
          }
        } catch (_) {}
      }
      AppSettings settings = const AppSettings();
      final String? rawSettings = prefs.getString(_kSettings);
      if (rawSettings != null && rawSettings.isNotEmpty) {
        try {
          final dynamic decoded = jsonDecode(rawSettings);
          if (decoded is Map<String, dynamic>) {
            settings = AppSettings.fromJson(decoded);
          }
        } catch (_) {}
      }
      return AppStateSnapshot(
        presets: _decodeList<DesignPreset>(
          prefs.getString(_kPresets),
          DesignPreset.fromJson,
        ),
        products: _decodeList<StepProduct>(
          prefs.getString(_kProducts),
          StepProduct.fromJson,
        ),
        customColors: _decodeList<CustomColor>(
          prefs.getString(_kCustomColors),
          CustomColor.fromJson,
        ),
        sessions: _decodeList<SessionRecord>(
          prefs.getString(_kSessions),
          SessionRecord.fromJson,
        ),
        onboardingComplete: prefs.getBool(_kOnboarding) ?? false,
        settings: settings,
        lastState: lastState,
      );
    } catch (_) {
      return AppStateSnapshot.empty();
    }
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSettings, jsonEncode(settings.toJson()));
  }

  static Future<void> saveSessions(List<SessionRecord> sessions) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kSessions,
      jsonEncode(sessions.map((SessionRecord s) => s.toJson()).toList()),
    );
  }

  static Future<List<SessionRecord>> loadSessions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return _decodeList<SessionRecord>(
      prefs.getString(_kSessions),
      SessionRecord.fromJson,
    );
  }

  static Future<void> markOnboardingComplete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarding, true);
  }

  static Future<void> saveLookBook(List<LookBookEntry> entries) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kLookBook,
      jsonEncode(entries.map((LookBookEntry e) => e.toJson()).toList()),
    );
  }

  static Future<List<LookBookEntry>> loadLookBook() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return _decodeList<LookBookEntry>(
      prefs.getString(_kLookBook),
      LookBookEntry.fromJson,
    );
  }

  static Future<void> savePresets(List<DesignPreset> presets) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kPresets,
      jsonEncode(presets.map((DesignPreset p) => p.toJson()).toList()),
    );
  }

  static Future<void> saveProducts(List<StepProduct> products) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kProducts,
      jsonEncode(products.map((StepProduct p) => p.toJson()).toList()),
    );
  }

  static Future<void> saveCustomColors(List<CustomColor> colors) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kCustomColors,
      jsonEncode(colors.map((CustomColor c) => c.toJson()).toList()),
    );
  }

  static Future<void> saveLastState(DesignPreset state) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastState, jsonEncode(state.toJson()));
  }

  static List<T> _decodeList<T>(
    String? raw,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (raw == null || raw.isEmpty) {
      return <T>[];
    }
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <T>[];
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map<T>(parser)
          .toList();
    } catch (_) {
      return <T>[];
    }
  }
}

class TimerLaunchConfig {
  const TimerLaunchConfig({
    required this.mode,
    required this.baseColor,
    required this.chromeShade,
    required this.allNailsDesign,
    required this.perNailDesigns,
    required this.perNailColors,
    required this.routine,
    required this.stepProducts,
    required this.productLibrary,
    required this.customColors,
    required this.settings,
  });

  final BuildMode mode;
  final String baseColor;
  final String chromeShade;
  final NailDesign allNailsDesign;
  final List<NailDesign> perNailDesigns;
  final List<String> perNailColors;
  final List<RoutineStep> routine;
  final Map<String, StepProduct> stepProducts;
  final List<StepProduct> productLibrary;
  final List<CustomColor> customColors;
  final AppSettings settings;
}

// ─────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(eyebrow.toUpperCase(), style: t.titleSmall),
        const SizedBox(height: 8),
        Text(title, style: t.displaySmall),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: t.bodyMedium?.copyWith(color: context.colors.charcoalSoft),
          ),
        ],
      ],
    );
  }
}

class _HistoryStat extends StatelessWidget {
  const _HistoryStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: t.titleSmall?.copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Text(
              value,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: context.colors.charcoal,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: t.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class HomeTitle extends StatelessWidget {
  const HomeTitle({super.key, this.subtitle, this.onTap});

  final String? subtitle;
  final VoidCallback? onTap;

  void _defaultTap(BuildContext context) {
    HapticFeedback.selectionClick();
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSubtitle = subtitle != null && subtitle!.isNotEmpty;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap ?? () => _defaultTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Manicure Masterpiece',
              style: GoogleFonts.playfairDisplay(
                fontSize: hasSubtitle ? 17 : 22,
                fontWeight: FontWeight.w500,
                color: context.colors.charcoal,
                height: 1.05,
              ),
            ),
            if (hasSubtitle) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: context.colors.muted,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child, this.scale = 0.96});

  final Widget child;
  final double scale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onPointerUp: (_) {
        setState(() {
          _pressed = false;
        });
      },
      onPointerCancel: (_) {
        setState(() {
          _pressed = false;
        });
      },
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _HoroscopeCard extends StatelessWidget {
  const _HoroscopeCard({required this.horoscope});

  final NailHoroscope horoscope;

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            context.colors.blushSoft,
            context.colors.creamWarm,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.colors.blush),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.colors.cream,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.blush),
            ),
            child: Icon(
              Icons.nightlight_outlined,
              size: 20,
              color: context.colors.mauveDeep,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'TODAY\'S NAIL VIBE',
                  style: t.titleSmall?.copyWith(
                    color: context.colors.mauveDeep,
                  ),
                ),
                const SizedBox(height: 4),
                Text(horoscope.title, style: t.titleMedium),
                const SizedBox(height: 2),
                Text(
                  horoscope.body,
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.cta,
    this.verticalPadding = 40,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? cta;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.colors.blushSoft,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.blush),
            ),
            child: Icon(icon, size: 32, color: context.colors.mauveDeep),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: t.titleMedium,
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: t.bodySmall,
            ),
          ],
          if (cta != null) ...<Widget>[
            const SizedBox(height: 16),
            cta!,
          ],
        ],
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.borderColor,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? context.colors.creamWarm) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor ?? context.colors.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppPalette.charcoal.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ColorSwatchTile extends StatelessWidget {
  const ColorSwatchTile({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color:
                selected ? context.colors.blushSoft : context.colors.creamWarm,
            border: Border.all(
              color: selected ? context.colors.mauve : context.colors.border,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.35, -0.4),
                    radius: 0.95,
                    colors: <Color>[
                      Color.lerp(color, Colors.white, 0.45) ?? color,
                      color,
                    ],
                    stops: const <double>[0.0, 0.75],
                  ),
                  border: Border.all(
                    color: AppPalette.charcoal.withValues(alpha: 0.10),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? context.colors.mauveDeep : context.colors.charcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddColorChip extends StatelessWidget {
  const _AddColorChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.colors.creamWarm,
          border: Border.all(
            color: context.colors.mauve.withValues(alpha: 0.4),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colors.mauve.withValues(alpha: 0.5),
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.add,
                size: 14,
                color: context.colors.mauve,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Custom',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: context.colors.mauveDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DesignChoiceTile extends StatelessWidget {
  const DesignChoiceTile({
    super.key,
    required this.design,
    required this.baseColor,
    required this.chromeShade,
    required this.selected,
    required this.onTap,
  });

  final NailDesign design;
  final Color baseColor;
  final String chromeShade;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              selected ? context.colors.blushSoft : context.colors.creamWarm,
          border: Border.all(
            color: selected ? context.colors.mauve : context.colors.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: <Widget>[
            NailVisual(
              design: design,
              baseColor: baseColor,
              chromeShade: chromeShade,
              width: 48,
              height: 70,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(designLabel(design), style: t.titleMedium),
                  const SizedBox(height: 2),
                  Text(designBlurb(design), style: t.bodySmall),
                ],
              ),
            ),
            AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: selected ? 1 : 0,
              child: Icon(
                Icons.check_circle,
                color: context.colors.mauve,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Nail visualization
// ─────────────────────────────────────────────────────────────────────────

class NailVisual extends StatelessWidget {
  const NailVisual({
    super.key,
    required this.design,
    required this.baseColor,
    required this.chromeShade,
    this.width = 64,
    this.height = 96,
  });

  final NailDesign design;
  final Color baseColor;
  final String chromeShade;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: CustomPaint(
          key: ValueKey<int>(
            Object.hash(design, baseColor, chromeShade),
          ),
          size: Size(width, height),
          painter: _NailPainter(
            design: design,
            baseColor: baseColor,
            chromeColor: chromeShadeColor(chromeShade),
          ),
        ),
      ),
    );
  }
}

class _NailPainter extends CustomPainter {
  _NailPainter({
    required this.design,
    required this.baseColor,
    required this.chromeColor,
  });

  final NailDesign design;
  final Color baseColor;
  final Color chromeColor;

  Path _nailPath(Size size) {
    final double w = size.width;
    final double h = size.height;
    return Path()
      ..moveTo(w * 0.5, 0)
      ..cubicTo(w * 0.92, 0, w, h * 0.18, w, h * 0.42)
      ..lineTo(w, h * 0.86)
      ..cubicTo(w, h * 0.96, w * 0.86, h, w * 0.5, h)
      ..cubicTo(w * 0.14, h, 0, h * 0.96, 0, h * 0.86)
      ..lineTo(0, h * 0.42)
      ..cubicTo(0, h * 0.18, w * 0.08, 0, w * 0.5, 0)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Path nail = _nailPath(size);

    // Soft drop shadow under nail
    canvas.drawShadow(nail, AppPalette.charcoal.withValues(alpha: 0.5), 4, false);

    // Base fill
    final Paint basePaint = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color.lerp(baseColor, Colors.white, 0.08) ?? baseColor,
          baseColor,
          Color.lerp(baseColor, Colors.black, 0.06) ?? baseColor,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(nail, basePaint);

    // Design overlay clipped to nail
    canvas.save();
    canvas.clipPath(nail);
    switch (design) {
      case NailDesign.solid:
        break;
      case NailDesign.catEye:
        _paintCatEye(canvas, size);
      case NailDesign.matteGlossContrast:
        _paintMatteGloss(canvas, size);
      case NailDesign.frenchTip:
        _paintFrenchTip(canvas, size);
      case NailDesign.chromePowder:
        _paintChromePowder(canvas, size);
      case NailDesign.glitter:
        _paintGlitter(canvas, size);
      case NailDesign.ombre:
        _paintOmbre(canvas, size);
      case NailDesign.marble:
        _paintMarble(canvas, size);
      case NailDesign.polkaDots:
        _paintPolkaDots(canvas, size);
      case NailDesign.stripes:
        _paintStripes(canvas, size);
      case NailDesign.glazed:
        _paintGlazed(canvas, size);
    }
    canvas.restore();

    // Gloss highlight
    final Path gloss = Path()
      ..moveTo(size.width * 0.22, size.height * 0.12)
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.06,
        size.width * 0.42,
        size.height * 0.22,
      )
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.42,
        size.width * 0.24,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.16,
        size.height * 0.34,
        size.width * 0.22,
        size.height * 0.12,
      )
      ..close();
    canvas.drawPath(
      gloss,
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );

    // Cuticle line
    final Paint cuticle = Paint()
      ..color = AppPalette.charcoal.withValues(alpha: 0.10)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final Path cuticlePath = Path()
      ..moveTo(size.width * 0.10, size.height * 0.96)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.86,
        size.width * 0.90,
        size.height * 0.96,
      );
    canvas.drawPath(cuticlePath, cuticle);
  }

  void _paintCatEye(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint shimmer = Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-0.3, -1),
        end: const Alignment(0.3, 1),
        colors: <Color>[
          Colors.transparent,
          Colors.white.withValues(alpha: 0.55),
          Colors.white.withValues(alpha: 0.85),
          Colors.white.withValues(alpha: 0.30),
          Colors.transparent,
        ],
        stops: const <double>[0.30, 0.42, 0.50, 0.58, 0.72],
      ).createShader(rect);
    canvas.drawRect(rect, shimmer);
  }

  void _paintMatteGloss(Canvas canvas, Size size) {
    final Rect rightHalf = Rect.fromLTWH(
      size.width / 2,
      0,
      size.width / 2,
      size.height,
    );
    canvas.drawRect(
      rightHalf,
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    canvas.drawRect(
      rightHalf,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.20),
            Colors.transparent,
          ],
        ).createShader(rightHalf),
    );
  }

  void _paintFrenchTip(Canvas canvas, Size size) {
    final Path tip = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.68,
        size.width,
        size.height * 0.82,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(tip, Paint()..color = const Color(0xFFFBF9F4));
    canvas.drawPath(
      tip,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size),
    );
  }

  void _paintChromePowder(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            chromeColor.withValues(alpha: 0.85),
            Colors.white.withValues(alpha: 0.85),
            chromeColor.withValues(alpha: 0.55),
            chromeColor,
          ],
          stops: const <double>[0.0, 0.45, 0.7, 1.0],
        ).createShader(rect),
    );
  }

  void _paintGlitter(Canvas canvas, Size size) {
    final math.Random rng = math.Random(42);
    final Paint flake = Paint()..isAntiAlias = true;
    final int count = ((size.width * size.height) / 28).round();
    for (int i = 0; i < count; i++) {
      final double x = rng.nextDouble() * size.width;
      final double y = rng.nextDouble() * size.height;
      final double r = 0.6 + rng.nextDouble() * 1.4;
      final double alpha = 0.35 + rng.nextDouble() * 0.55;
      final List<Color> palette = <Color>[
        Colors.white,
        const Color(0xFFFFE9F2),
        const Color(0xFFFFD27D),
        const Color(0xFFEAD6FF),
      ];
      flake.color = palette[rng.nextInt(palette.length)]
          .withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), r, flake);
    }
  }

  void _paintOmbre(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.80),
            Colors.white.withValues(alpha: 0.35),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.4, 0.9],
        ).createShader(rect),
    );
  }

  void _paintMarble(Canvas canvas, Size size) {
    final Color veinDark = Color.lerp(baseColor, Colors.black, 0.35) ??
        baseColor;
    final Color veinLight = Colors.white.withValues(alpha: 0.6);

    final Paint dark = Paint()
      ..color = veinDark.withValues(alpha: 0.55)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    final Paint light = Paint()
      ..color = veinLight
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final Path p1 = Path()
      ..moveTo(-size.width * 0.1, size.height * 0.2)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.1,
        size.width * 0.4,
        size.height * 0.5,
        size.width * 0.7,
        size.height * 0.3,
      )
      ..cubicTo(
        size.width * 0.9,
        size.height * 0.2,
        size.width * 1.1,
        size.height * 0.6,
        size.width * 1.1,
        size.height * 0.9,
      );
    canvas.drawPath(p1, dark);

    final Path p2 = Path()
      ..moveTo(size.width * 0.1, -size.height * 0.05)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.4,
        size.width * 0.6,
        size.height * 0.55,
        size.width * 0.5,
        size.height * 0.85,
      );
    canvas.drawPath(p2, light);

    final Path p3 = Path()
      ..moveTo(-size.width * 0.05, size.height * 0.7)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.7,
        size.width * 0.45,
        size.height * 0.75,
        size.width * 0.95,
        size.height * 0.55,
      );
    canvas.drawPath(p3, dark);
  }

  void _paintPolkaDots(Canvas canvas, Size size) {
    final bool dark = baseColor.computeLuminance() > 0.6;
    final Paint dot = Paint()
      ..color = (dark ? Colors.black : Colors.white).withValues(alpha: 0.85);
    const double spacingX = 14;
    const double spacingY = 16;
    final double dotR = math.max(1.5, size.width / 28);
    for (double y = spacingY * 0.5; y < size.height; y += spacingY) {
      double offsetX = (y / spacingY).round().isEven ? 0.0 : spacingX / 2;
      for (double x = offsetX + spacingX * 0.5;
          x < size.width;
          x += spacingX) {
        canvas.drawCircle(Offset(x, y), dotR, dot);
      }
    }
  }

  void _paintStripes(Canvas canvas, Size size) {
    final bool dark = baseColor.computeLuminance() > 0.6;
    final Paint stripe = Paint()
      ..color =
          (dark ? Colors.black : Colors.white).withValues(alpha: 0.55)
      ..strokeWidth = math.max(2, size.width / 16)
      ..style = PaintingStyle.stroke;
    final double diagonal = size.width + size.height;
    const double spacing = 14;
    for (double offset = -size.height; offset < diagonal; offset += spacing) {
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset + size.height, size.height),
        stripe,
      );
    }
  }

  void _paintGlazed(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            const Color(0x66FFE0EE),
            const Color(0x66FFE9C8),
            const Color(0x66D6F0FF),
            const Color(0x66E5D5FF),
          ],
        ).createShader(rect),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.08, size.width, size.height * 0.30),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.55),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromLTWH(0, size.height * 0.08, size.width, size.height * 0.30),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _NailPainter old) {
    return old.design != design ||
        old.baseColor != baseColor ||
        old.chromeColor != chromeColor;
  }
}

class NailDisplayCard extends StatelessWidget {
  const NailDisplayCard({
    super.key,
    required this.name,
    required this.design,
    required this.baseColor,
    required this.chromeShade,
    this.selected = false,
    this.onTap,
    this.onLongPress,
    this.compact = false,
  });

  final String name;
  final NailDesign design;
  final Color baseColor;
  final String chromeShade;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double w = compact ? 44 : 56;
    final double h = compact ? 66 : 84;
    final TextTheme t = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? context.colors.blushSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? context.colors.mauve : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            NailVisual(
              design: design,
              baseColor: baseColor,
              chromeShade: chromeShade,
              width: w,
              height: h,
            ),
            const SizedBox(height: 8),
            Text(name, style: t.labelMedium),
            if (!compact) ...<Widget>[
              const SizedBox(height: 2),
              SizedBox(
                width: 76,
                child: Text(
                  designLabel(design),
                  textAlign: TextAlign.center,
                  style: t.labelSmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// App
// ─────────────────────────────────────────────────────────────────────────

class NailTimerApp extends StatefulWidget {
  const NailTimerApp({super.key, required this.initial});

  final AppStateSnapshot initial;

  @override
  State<NailTimerApp> createState() => _NailTimerAppState();
}

class _NailTimerAppState extends State<NailTimerApp> {
  late AppSettings _settings;
  late bool _onboarded;

  @override
  void initState() {
    super.initState();
    _settings = widget.initial.settings;
    _onboarded = widget.initial.onboardingComplete;
  }

  void _handleSettingsChanged(AppSettings next) {
    setState(() {
      _settings = next;
    });
    unawaited(PersistenceStore.saveSettings(next));
  }

  void _finishOnboarding() {
    unawaited(PersistenceStore.markOnboardingComplete());
    setState(() {
      _onboarded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manicure Masterpiece',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _settings.themeMode,
      home: !_onboarded
          ? OnboardingPage(onComplete: _finishOnboarding)
          : NailBuilderPage(
              initial: widget.initial,
              settings: _settings,
              onSettingsChanged: _handleSettingsChanged,
            ),
    );
  }
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const List<_OnboardingSlide> _slides = <_OnboardingSlide>[
    _OnboardingSlide(
      eyebrow: 'Step 01',
      title: 'Build your set',
      body:
          'Choose a base color, pick designs for each nail, and add finishing touches. Save palettes you love.',
      icon: Icons.palette_outlined,
    ),
    _OnboardingSlide(
      eyebrow: 'Step 02',
      title: 'Run the timer',
      body:
          'A guided countdown keeps every step on track, with haptic cues so your hands stay free.',
      icon: Icons.timer_outlined,
    ),
    _OnboardingSlide(
      eyebrow: 'Step 03',
      title: 'Save your sessions',
      body:
          'Snap a photo when you finish. Build a personal portfolio of every set you create.',
      icon: Icons.collections_bookmark_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    final bool isLast = _page == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: widget.onComplete,
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (int p) {
                  setState(() {
                    _page = p;
                  });
                },
                itemBuilder: (BuildContext context, int i) {
                  final _OnboardingSlide s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Spacer(),
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colors.blushSoft,
                            border: Border.all(color: context.colors.blush),
                          ),
                          child: Icon(
                            s.icon,
                            size: 44,
                            color: context.colors.mauveDeep,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(s.eyebrow.toUpperCase(), style: t.titleSmall),
                        const SizedBox(height: 8),
                        Text(s.title, style: t.displayMedium),
                        const SizedBox(height: 12),
                        Text(
                          s.body,
                          style: t.bodyLarge?.copyWith(
                            color: context.colors.charcoalSoft,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(_slides.length, (int i) {
                      final bool active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? context.colors.mauve
                              : context.colors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      if (isLast) {
                        widget.onComplete();
                        return;
                      }
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                      );
                    },
                    icon: Icon(
                      isLast ? Icons.check : Icons.arrow_forward,
                      size: 16,
                    ),
                    label: Text(isLast ? 'Get started' : 'Continue'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;
}

// ─────────────────────────────────────────────────────────────────────────
// Settings page
// ─────────────────────────────────────────────────────────────────────────

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.initial,
    required this.baseColorOptions,
    required this.resolveColor,
    required this.onChanged,
  });

  final AppSettings initial;
  final List<String> baseColorOptions;
  final Color Function(String) resolveColor;
  final ValueChanged<AppSettings> onChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initial;
  }

  void _update(AppSettings next) {
    setState(() {
      _settings = next;
    });
    widget.onChanged(next);
  }

  Future<void> _editDefaultSeconds() async {
    final TextEditingController controller = TextEditingController(
      text: _settings.defaultStepSeconds.toString(),
    );
    final int? seconds = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Default step time',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Seconds',
              helperText: 'Used for new custom steps',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final int? parsed = int.tryParse(controller.text.trim());
                if (parsed == null || parsed <= 0) {
                  return;
                }
                Navigator.of(context).pop(parsed);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (seconds == null) return;
    _update(_settings.copyWith(defaultStepSeconds: seconds));
  }

  Future<void> _confirmResetAllData() async {
    final TextEditingController c = TextEditingController();
    bool typedConfirm = false;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(
                'Reset all data?',
                style: Theme.of(dctx).textTheme.headlineSmall,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'This permanently clears every preset, product, custom color, saved session, look book entry, and setting. Photos already saved to your device gallery are not affected.',
                    style: Theme.of(dctx).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Type RESET to confirm:',
                    style: Theme.of(dctx).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: c,
                    autofocus: true,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (String v) {
                      setDialogState(() {
                        typedConfirm = v.trim().toUpperCase() == 'RESET';
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(dctx).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: typedConfirm
                      ? () {
                          Navigator.of(dctx).pop(true);
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFB0436B),
                  ),
                  child: const Text('Reset all'),
                ),
              ],
            );
          },
        );
      },
    );
    c.dispose();
    if (confirmed != true) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext dctx) {
        return AlertDialog(
          title: Text(
            'Data cleared',
            style: Theme.of(dctx).textTheme.headlineSmall,
          ),
          content: const Text(
            'Please close the app and reopen it to start fresh.',
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(dctx).pop();
                SystemNavigator.pop();
              },
              child: const Text('Close app'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDefaultBaseColor() async {
    final String? choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Default base color',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.baseColorOptions.map((String name) {
                    return ColorSwatchTile(
                      label: name,
                      color: widget.resolveColor(name),
                      selected: _settings.defaultBaseColor == name,
                      onTap: () {
                        Navigator.of(sheetContext).pop(name);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (choice == null) return;
    _update(_settings.copyWith(defaultBaseColor: choice));
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const HomeTitle(subtitle: 'SETTINGS')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: <Widget>[
            const SectionHeader(
              eyebrow: 'Preferences',
              title: 'Tune your studio',
              subtitle: 'Adjust feedback, defaults, and behavior.',
            ),
            const SizedBox(height: 22),
            Text('FEEDBACK', style: t.titleSmall),
            const SizedBox(height: 10),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _settings.soundEnabled,
                    title: Text('Sound cues', style: t.titleMedium),
                    subtitle: Text(
                      'Play system chimes at step transitions',
                      style: TextStyle(color: context.colors.muted),
                    ),
                    onChanged: (bool v) {
                      _update(_settings.copyWith(soundEnabled: v));
                    },
                  ),
                  Divider(height: 1, color: context.colors.borderSoft),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _settings.hapticsEnabled,
                    title: Text('Haptics', style: t.titleMedium),
                    subtitle: Text(
                      'Vibrate on transitions and countdown ticks',
                      style: TextStyle(color: context.colors.muted),
                    ),
                    onChanged: (bool v) {
                      _update(_settings.copyWith(hapticsEnabled: v));
                    },
                  ),
                  Divider(height: 1, color: context.colors.borderSoft),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _settings.keepScreenAwake,
                    title: Text('Keep screen awake', style: t.titleMedium),
                    subtitle: Text(
                      'Prevent dimming while the timer runs',
                      style: TextStyle(color: context.colors.muted),
                    ),
                    onChanged: (bool v) {
                      _update(_settings.copyWith(keepScreenAwake: v));
                    },
                  ),
                  Divider(height: 1, color: context.colors.borderSoft),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _settings.oneHandedMode,
                    title: Text('One-handed mode', style: t.titleMedium),
                    subtitle: Text(
                      'Big buttons + swipe-to-advance on the timer',
                      style: TextStyle(color: context.colors.muted),
                    ),
                    onChanged: (bool v) {
                      _update(_settings.copyWith(oneHandedMode: v));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('SHARING', style: t.titleSmall),
            const SizedBox(height: 10),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _settings.shareWatermark,
                title: Text('Share watermark', style: t.titleMedium),
                subtitle: Text(
                  'Add "Made with Manicure Masterpiece" to shared cards',
                  style: TextStyle(color: context.colors.muted),
                ),
                onChanged: (bool v) {
                  _update(_settings.copyWith(shareWatermark: v));
                },
              ),
            ),
            const SizedBox(height: 22),
            Text('DEFAULTS', style: t.titleSmall),
            const SizedBox(height: 10),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Default step time', style: t.titleMedium),
                    subtitle: Text(
                      'Used for new custom steps',
                      style: t.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          formatClock(_settings.defaultStepSeconds),
                          style: t.labelLarge?.copyWith(
                            color: context.colors.mauveDeep,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: context.colors.muted,
                        ),
                      ],
                    ),
                    onTap: _editDefaultSeconds,
                  ),
                  Divider(height: 1, color: context.colors.borderSoft),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Default base color', style: t.titleMedium),
                    subtitle: Text(
                      'Starting color on a fresh design',
                      style: t.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: widget.resolveColor(
                              _settings.defaultBaseColor,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.colors.charcoal.withValues(
                                alpha: 0.10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _settings.defaultBaseColor,
                          style: t.labelLarge,
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: context.colors.muted,
                        ),
                      ],
                    ),
                    onTap: _pickDefaultBaseColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('APPEARANCE', style: t.titleSmall),
            const SizedBox(height: 10),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('Theme', style: t.titleMedium),
                  ),
                  Text(
                    'Choose how the app looks.',
                    style: t.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const <ButtonSegment<ThemeMode>>[
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto, size: 16),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_outlined, size: 16),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_outlined, size: 16),
                      ),
                    ],
                    selected: <ThemeMode>{_settings.themeMode},
                    onSelectionChanged: (Set<ThemeMode> set) {
                      _update(_settings.copyWith(themeMode: set.first));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('ABOUT', style: t.titleSmall),
            const SizedBox(height: 10),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                children: <Widget>[
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(Icons.info_outline),
                    title: Text('About Manicure Masterpiece', style: t.titleMedium),
                    subtitle: Text(
                      'Version, contact, links',
                      style: t.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const AboutPage(),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: context.colors.borderSoft),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text('Privacy policy', style: t.titleMedium),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const PrivacyPage(),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: context.colors.borderSoft),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(Icons.code_outlined),
                    title: Text('Open source licenses', style: t.titleMedium),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final PackageInfo info =
                          await PackageInfo.fromPlatform();
                      if (!context.mounted) return;
                      showLicensePage(
                        context: context,
                        applicationName: 'Manicure Masterpiece',
                        applicationVersion: info.version,
                        applicationLegalese:
                            '© ${DateTime.now().year} Manicure Masterpiece',
                      );
                    },
                  ),
                  Divider(height: 1, color: context.colors.borderSoft),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(Icons.play_circle_outline),
                    title: Text('Show onboarding', style: t.titleMedium),
                    subtitle: Text(
                      'Walk through the wizard intro again',
                      style: t.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => OnboardingPage(
                            onComplete: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: context.colors.borderSoft),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: Icon(
                      Icons.delete_sweep_outlined,
                      color: context.colors.mauveDeep,
                    ),
                    title: Text(
                      'Reset all my data',
                      style: t.titleMedium?.copyWith(
                        color: context.colors.mauveDeep,
                      ),
                    ),
                    subtitle: Text(
                      'Clears presets, products, sessions, look book, settings',
                      style: t.bodySmall,
                    ),
                    onTap: _confirmResetAllData,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Builder wizard
// ─────────────────────────────────────────────────────────────────────────

class NailBuilderPage extends StatefulWidget {
  const NailBuilderPage({
    super.key,
    required this.initial,
    required this.settings,
    required this.onSettingsChanged,
  });

  final AppStateSnapshot initial;
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  @override
  State<NailBuilderPage> createState() => _NailBuilderPageState();
}

class _NailBuilderPageState extends State<NailBuilderPage> {
  static const List<String> _chromeShades = <String>[
    'White Silver',
    'Gold',
    'White/Blue',
  ];

  static const List<String> _stepLabels = <String>[
    'Base',
    'Design',
    'Finishing',
    'Review',
  ];

  static const List<StepProduct> _defaultLibrary = <StepProduct>[
    StepProduct(
      name: 'Nude Builder Gel',
      code: 'NB-017',
      category: ProductCategory.base,
    ),
    StepProduct(
      name: 'Cat Eye Gel',
      code: 'CE-204',
      category: ProductCategory.catEye,
    ),
    StepProduct(
      name: 'Gold Chrome',
      code: 'CR-102',
      category: ProductCategory.chrome,
    ),
  ];

  late final PageController _pageController;
  int _step = 0;

  BuildMode _mode = BuildMode.allSame;
  String _baseColor = kDefaultPalette.keys.first;
  String _chromeShade = _chromeShades[1];
  ChromeStyle _chromeStyle = ChromeStyle.regular;
  NailDesign _allNailsDesign = NailDesign.catEye;
  final List<NailDesign> _perNailDesigns = List<NailDesign>.filled(
    kNailNames.length,
    NailDesign.solid,
    growable: true,
  );
  final List<String> _perNailColors = List<String>.filled(
    kNailNames.length,
    'Nude',
    growable: true,
  );

  bool _includeAlcoholWipe = true;
  bool _includeFinalTopCoat = true;

  late final List<StepProduct> _productLibrary;
  late final List<DesignPreset> _savedPresets;
  late final List<CustomColor> _customColors;
  late AppSettings _settings;
  bool _savedJustNow = false;
  Timer? _savedPillTimer;

  final Map<String, StepProduct> _stepProducts = <String, StepProduct>{};
  final Map<String, int> _customStepSeconds = <String, int>{};
  final List<RoutineStep> _userCustomSteps = <RoutineStep>[];
  List<String>? _routineOrder;

  List<RoutineStep> _routine = const <RoutineStep>[];
  int _selectedStudioNail = 0;

  List<String> get _baseColorNames {
    return <String>[
      ...kDefaultPalette.keys,
      ..._customColors.map((CustomColor c) => c.name),
    ];
  }

  List<String> get _validRecentColors {
    final Set<String> valid = <String>{
      ...kDefaultPalette.keys,
      ..._customColors.map((CustomColor c) => c.name),
    };
    return _settings.recentColors
        .where((String name) => valid.contains(name))
        .toList();
  }

  Color _resolveBaseColor(String name) {
    return baseColorValue(name, _customColors);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _productLibrary = widget.initial.products.isEmpty
        ? List<StepProduct>.from(_defaultLibrary)
        : List<StepProduct>.from(widget.initial.products);
    _savedPresets = List<DesignPreset>.from(widget.initial.presets);
    _customColors = List<CustomColor>.from(widget.initial.customColors);
    _settings = widget.settings;
    if (widget.initial.lastState == null) {
      _baseColor = _settings.defaultBaseColor;
    }
    _applyLastStateIfAny(widget.initial.lastState);
    // Fill per-nail colors with base color if they're still defaults
    for (int i = 0; i < _perNailColors.length; i++) {
      if (_perNailColors[i] == 'Nude' || _perNailColors[i].isEmpty) {
        _perNailColors[i] = _baseColor;
      }
    }
    _rebuildRoutine();
  }

  @override
  void didUpdateWidget(covariant NailBuilderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _settings = widget.settings;
    }
  }

  void _updateSettings(AppSettings next) {
    setState(() {
      _settings = next;
    });
    widget.onSettingsChanged(next);
  }

  void _applyLastStateIfAny(DesignPreset? last) {
    if (last == null) {
      return;
    }
    _mode = last.mode;
    _baseColor = last.baseColor;
    _chromeShade = last.chromeShade;
    _chromeStyle = last.chromeStyle;
    _allNailsDesign = last.allNailsDesign;
    _perNailDesigns
      ..clear()
      ..addAll(last.perNailDesigns);
    if (last.perNailColors != null && last.perNailColors!.isNotEmpty) {
      _perNailColors
        ..clear()
        ..addAll(last.perNailColors!);
      // Pad to expected length if shorter
      while (_perNailColors.length < kNailNames.length) {
        _perNailColors.add(last.baseColor);
      }
    }
    _includeAlcoholWipe = last.includeAlcoholWipe;
    _includeFinalTopCoat = last.includeFinalTopCoat;
    _customStepSeconds
      ..clear()
      ..addAll(last.customSeconds);
    _stepProducts
      ..clear()
      ..addAll(last.stepProducts);
    _userCustomSteps
      ..clear()
      ..addAll(last.customSteps);
    _routineOrder = last.routineOrder == null
        ? null
        : List<String>.from(last.routineOrder!);
  }

  DesignPreset _captureCurrentState() {
    return DesignPreset(
      name: '__last__',
      mode: _mode,
      baseColor: _baseColor,
      chromeShade: _chromeShade,
      chromeStyle: _chromeStyle,
      allNailsDesign: _allNailsDesign,
      perNailDesigns: List<NailDesign>.from(_perNailDesigns),
      perNailColors: List<String>.from(_perNailColors),
      includeAlcoholWipe: _includeAlcoholWipe,
      includeFinalTopCoat: _includeFinalTopCoat,
      customSeconds: Map<String, int>.from(_customStepSeconds),
      stepProducts: Map<String, StepProduct>.from(_stepProducts),
      customSteps: List<RoutineStep>.from(_userCustomSteps),
      routineOrder: _routineOrder == null
          ? null
          : List<String>.from(_routineOrder!),
    );
  }

  void _persistCurrentState() {
    unawaited(PersistenceStore.saveLastState(_captureCurrentState()));
    _flashSavedPill();
  }

  void _flashSavedPill() {
    _savedPillTimer?.cancel();
    if (!_savedJustNow) {
      setState(() {
        _savedJustNow = true;
      });
    }
    _savedPillTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _savedJustNow = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _savedPillTimer?.cancel();
    super.dispose();
  }

  NailDesign _designForNail(int index) {
    if (_mode == BuildMode.allSame) {
      return _allNailsDesign;
    }
    return _perNailDesigns[index];
  }

  String _colorForNail(int index) {
    if (_mode == BuildMode.allSame) {
      return _baseColor;
    }
    return _perNailColors[index];
  }

  Color _resolveColorForNail(int index) {
    return _resolveBaseColor(_colorForNail(index));
  }

  Map<NailDesign, int> get _selectedDesignCounts {
    final Map<NailDesign, int> counts = <NailDesign, int>{};
    if (_mode == BuildMode.allSame) {
      counts[_allNailsDesign] = kNailNames.length;
      return counts;
    }

    for (final NailDesign design in _perNailDesigns) {
      counts[design] = (counts[design] ?? 0) + 1;
    }
    return counts;
  }

  bool get _needsChromeOptions {
    return _selectedDesignCounts.keys.contains(NailDesign.chromePowder);
  }

  int get _totalSeconds {
    return _routine.fold<int>(0, (int sum, RoutineStep s) => sum + s.seconds);
  }

  void _syncSecondaryEffectsWithDesign() {
    final Set<NailDesign> selectedDesigns = _selectedDesignCounts.keys.toSet();
    if (selectedDesigns.length == 1 &&
        selectedDesigns.contains(NailDesign.matteGlossContrast)) {
      _includeFinalTopCoat = false;
    }
  }

  List<RoutineStep> _chromeStyleSteps(String nailSuffix) {
    switch (_chromeStyle) {
      case ChromeStyle.regular:
        return <RoutineStep>[
          RoutineStep(
            id: 'chrome-regular-topcoat$nailSuffix',
            title: 'Top coat$nailSuffix',
            seconds: 60,
            categoryHint: ProductCategory.topCoat,
          ),
          RoutineStep(
            id: 'chrome-regular-uncured$nailSuffix',
            title: 'Chrome (uncured)$nailSuffix',
            seconds: 60,
            categoryHint: ProductCategory.chrome,
          ),
          RoutineStep(
            id: 'chrome-regular-basegel$nailSuffix',
            title: 'Base gel$nailSuffix',
            seconds: 60,
            categoryHint: ProductCategory.base,
          ),
          RoutineStep(
            id: 'chrome-regular-finish$nailSuffix',
            title: 'Top coat finish$nailSuffix',
            seconds: 60,
            categoryHint: ProductCategory.topCoat,
          ),
        ];
      case ChromeStyle.isolated:
        return <RoutineStep>[
          RoutineStep(
            id: 'chrome-isolated-matte$nailSuffix',
            title: 'Matte top coat$nailSuffix',
            seconds: 60,
            categoryHint: ProductCategory.topCoat,
          ),
          RoutineStep(
            id: 'chrome-isolated-3d$nailSuffix',
            title: 'Top coat or 3D gel$nailSuffix',
            seconds: 60,
            categoryHint: ProductCategory.topCoat,
          ),
          RoutineStep(
            id: 'chrome-isolated-uncured$nailSuffix',
            title: 'Chrome (uncured)$nailSuffix',
            seconds: 60,
            categoryHint: ProductCategory.chrome,
          ),
          RoutineStep(
            id: 'chrome-isolated-basegel$nailSuffix',
            title: 'Base gel$nailSuffix',
            seconds: 60,
            categoryHint: ProductCategory.base,
          ),
          RoutineStep(
            id: 'chrome-isolated-finish$nailSuffix',
            title: 'Top coat finish$nailSuffix',
            seconds: 60,
            categoryHint: ProductCategory.topCoat,
          ),
        ];
      case ChromeStyle.reverse:
        return <RoutineStep>[
          RoutineStep(
            id: 'chrome-reverse-topcoat-1$nailSuffix',
            title: 'Top coat (first)$nailSuffix',
            seconds: 60,
            categoryHint: ProductCategory.topCoat,
          ),
          RoutineStep(
            id: 'chrome-reverse-uncured$nailSuffix',
            title: 'Chrome (uncured)$nailSuffix',
            seconds: 60,
            categoryHint: ProductCategory.chrome,
          ),
          RoutineStep(
            id: 'chrome-reverse-topcoat-2$nailSuffix',
            title: 'Top coat (second)$nailSuffix',
            seconds: 60,
            categoryHint: ProductCategory.topCoat,
          ),
          RoutineStep(
            id: 'chrome-reverse-basegel$nailSuffix',
            title: 'Base gel$nailSuffix',
            seconds: 60,
            categoryHint: ProductCategory.base,
          ),
          RoutineStep(
            id: 'chrome-reverse-finish$nailSuffix',
            title: 'Top coat finish$nailSuffix',
            seconds: 60,
            categoryHint: ProductCategory.topCoat,
          ),
        ];
    }
  }

  List<RoutineStep> _buildDefaultSteps() {
    final List<RoutineStep> steps = <RoutineStep>[
      const RoutineStep(
        id: 'base-layer',
        title: 'Base layer',
        seconds: 120,
        categoryHint: ProductCategory.base,
      ),
      RoutineStep(
        id: 'color-base',
        title: '$_baseColor color base',
        seconds: 120,
        categoryHint: ProductCategory.color,
      ),
    ];

    final List<MapEntry<NailDesign, int>> designEntries =
        _selectedDesignCounts.entries.toList()..sort(
          (MapEntry<NailDesign, int> a, MapEntry<NailDesign, int> b) =>
              a.key.index.compareTo(b.key.index),
        );

    for (final MapEntry<NailDesign, int> entry in designEntries) {
      final NailDesign design = entry.key;
      final int nailCount = entry.value;
      if (design == NailDesign.solid) {
        continue;
      }

      final String nailSuffix = _mode == BuildMode.perNail
          ? ' ($nailCount nails)'
          : '';

      switch (design) {
        case NailDesign.solid:
          break;
        case NailDesign.catEye:
          steps.add(
            RoutineStep(
              id: 'cat-eye$nailSuffix',
              title: 'Cat eye layer$nailSuffix',
              seconds: 120,
              categoryHint: ProductCategory.catEye,
            ),
          );
        case NailDesign.matteGlossContrast:
          steps.add(
            RoutineStep(
              id: 'matte-gloss$nailSuffix',
              title: 'Matte/Glossy contrast layer$nailSuffix',
              seconds: 60,
              categoryHint: ProductCategory.topCoat,
            ),
          );
        case NailDesign.frenchTip:
          steps.add(
            RoutineStep(
              id: 'french-tip$nailSuffix',
              title: 'Top coat french tip$nailSuffix',
              seconds: 60,
              categoryHint: ProductCategory.topCoat,
            ),
          );
        case NailDesign.chromePowder:
          steps.addAll(_chromeStyleSteps(nailSuffix));
        case NailDesign.glitter:
          steps.add(
            RoutineStep(
              id: 'glitter-press$nailSuffix',
              title: 'Press glitter into top coat$nailSuffix',
              seconds: 30,
              categoryHint: ProductCategory.misc,
            ),
          );
          steps.add(
            RoutineStep(
              id: 'glitter-seal$nailSuffix',
              title: 'Seal glitter with top coat$nailSuffix',
              seconds: 60,
              categoryHint: ProductCategory.topCoat,
            ),
          );
        case NailDesign.ombre:
          steps.add(
            RoutineStep(
              id: 'ombre-fade$nailSuffix',
              title: 'Sponge ombré fade layer$nailSuffix',
              seconds: 90,
              categoryHint: ProductCategory.color,
            ),
          );
          steps.add(
            RoutineStep(
              id: 'ombre-blend$nailSuffix',
              title: 'Soften blend with top coat$nailSuffix',
              seconds: 60,
              categoryHint: ProductCategory.topCoat,
            ),
          );
        case NailDesign.marble:
          steps.add(
            RoutineStep(
              id: 'marble-veins$nailSuffix',
              title: 'Draw marble veins$nailSuffix',
              seconds: 120,
              categoryHint: ProductCategory.color,
            ),
          );
          steps.add(
            RoutineStep(
              id: 'marble-blur$nailSuffix',
              title: 'Soften veins with thinner$nailSuffix',
              seconds: 60,
              categoryHint: ProductCategory.misc,
            ),
          );
        case NailDesign.polkaDots:
          steps.add(
            RoutineStep(
              id: 'polka-dots$nailSuffix',
              title: 'Dot detail with dotting tool$nailSuffix',
              seconds: 90,
              categoryHint: ProductCategory.color,
            ),
          );
        case NailDesign.stripes:
          steps.add(
            RoutineStep(
              id: 'stripes-line$nailSuffix',
              title: 'Stripe line work with detail brush$nailSuffix',
              seconds: 90,
              categoryHint: ProductCategory.color,
            ),
          );
        case NailDesign.glazed:
          steps.add(
            RoutineStep(
              id: 'glazed-pearl$nailSuffix',
              title: 'Pearl powder rub-in$nailSuffix',
              seconds: 45,
              categoryHint: ProductCategory.chrome,
            ),
          );
          steps.add(
            RoutineStep(
              id: 'glazed-seal$nailSuffix',
              title: 'Seal with glossy top coat$nailSuffix',
              seconds: 60,
              categoryHint: ProductCategory.topCoat,
            ),
          );
      }
    }

    if (_includeAlcoholWipe) {
      steps.add(
        const RoutineStep(
          id: 'alcohol-wipe',
          title: 'Wipe with alcohol',
          seconds: 30,
          categoryHint: ProductCategory.misc,
        ),
      );
    }
    if (_includeFinalTopCoat) {
      steps.add(
        const RoutineStep(
          id: 'secondary-final-topcoat',
          title: 'Last layer top coat',
          seconds: 60,
          categoryHint: ProductCategory.topCoat,
        ),
      );
    }

    return steps;
  }

  void _rebuildRoutine({Map<String, StepProduct>? preferredProducts}) {
    final List<RoutineStep> defaults = _buildDefaultSteps();
    final List<RoutineStep> autoSteps = defaults.map((RoutineStep step) {
      final int seconds = _customStepSeconds[step.id] ?? step.seconds;
      return step.copyWith(seconds: seconds);
    }).toList();

    final List<RoutineStep> customSteps = _userCustomSteps.map((
      RoutineStep step,
    ) {
      final int seconds = _customStepSeconds[step.id] ?? step.seconds;
      return step.copyWith(seconds: seconds);
    }).toList();

    final List<RoutineStep> combined = <RoutineStep>[
      ...autoSteps,
      ...customSteps,
    ];

    List<RoutineStep> finalSteps;
    if (_routineOrder == null) {
      finalSteps = combined;
    } else {
      final Map<String, RoutineStep> byId = <String, RoutineStep>{
        for (final RoutineStep s in combined) s.id: s,
      };
      final List<RoutineStep> ordered = <RoutineStep>[];
      for (final String id in _routineOrder!) {
        final RoutineStep? step = byId.remove(id);
        if (step != null) {
          ordered.add(step);
        }
      }
      ordered.addAll(byId.values);
      finalSteps = ordered;
      _routineOrder = finalSteps.map((RoutineStep s) => s.id).toList();
    }

    final Map<String, StepProduct> sourceProducts =
        preferredProducts ?? Map<String, StepProduct>.from(_stepProducts);

    _stepProducts
      ..clear()
      ..addEntries(
        finalSteps.map((RoutineStep step) {
          return MapEntry<String, StepProduct>(
            step.id,
            sourceProducts[step.id] ?? const StepProduct(),
          );
        }),
      );

    _routine = finalSteps;
  }

  void _onReorderRoutine(int oldIndex, int newIndex) {
    setState(() {
      int targetIndex = newIndex;
      if (targetIndex > oldIndex) {
        targetIndex -= 1;
      }
      final List<String> order = _routine
          .map((RoutineStep s) => s.id)
          .toList();
      final String moved = order.removeAt(oldIndex);
      order.insert(targetIndex, moved);
      _routineOrder = order;
      _rebuildRoutine();
    });
    HapticFeedback.selectionClick();
    _persistCurrentState();
  }

  Future<void> _addCustomStep() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController secondsController = TextEditingController(
      text: _settings.defaultStepSeconds.toString(),
    );
    ProductCategory category = ProductCategory.misc;

    final RoutineStep? created = await showDialog<RoutineStep>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(
                'Add custom step',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Step name',
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: secondsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Seconds',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<ProductCategory>(
                    initialValue: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                    items: ProductCategory.values
                        .map(
                          (ProductCategory item) =>
                              DropdownMenuItem<ProductCategory>(
                                value: item,
                                child: Text(productCategoryLabel(item)),
                              ),
                        )
                        .toList(),
                    onChanged: (ProductCategory? value) {
                      if (value == null) {
                        return;
                      }
                      setDialogState(() {
                        category = value;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final String title = titleController.text.trim();
                    final int? seconds = int.tryParse(
                      secondsController.text.trim(),
                    );
                    if (title.isEmpty || seconds == null || seconds <= 0) {
                      return;
                    }
                    final String id =
                        'custom-${DateTime.now().millisecondsSinceEpoch}';
                    Navigator.of(context).pop(
                      RoutineStep(
                        id: id,
                        title: title,
                        seconds: seconds,
                        categoryHint: category,
                        isCustom: true,
                      ),
                    );
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    secondsController.dispose();

    if (created == null) {
      return;
    }

    setState(() {
      _userCustomSteps.add(created);
      _routineOrder ??= _routine.map((RoutineStep s) => s.id).toList();
      _routineOrder!.add(created.id);
      _rebuildRoutine();
    });
    _persistCurrentState();
  }

  void _removeCustomStep(String stepId) {
    setState(() {
      _userCustomSteps.removeWhere((RoutineStep s) => s.id == stepId);
      _routineOrder?.remove(stepId);
      _customStepSeconds.remove(stepId);
      _stepProducts.remove(stepId);
      _rebuildRoutine();
    });
    _persistCurrentState();
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    String confirmLabel = 'Delete',
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dctx) {
        return AlertDialog(
          title: Text(
            title,
            style: Theme.of(dctx).textTheme.headlineSmall,
          ),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dctx).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dctx).pop(true);
              },
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _resetRoutineToAuto() async {
    if (_userCustomSteps.isEmpty &&
        _routineOrder == null &&
        _customStepSeconds.isEmpty) {
      return;
    }
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dctx) {
        return AlertDialog(
          title: Text(
            'Reset routine?',
            style: Theme.of(dctx).textTheme.headlineSmall,
          ),
          content: const Text(
            'This removes your custom steps, reorderings, and any time overrides.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dctx).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dctx).pop(true);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    setState(() {
      _userCustomSteps.clear();
      _routineOrder = null;
      _customStepSeconds.clear();
      _rebuildRoutine();
    });
    _persistCurrentState();
  }

  void _applyDesignChange(void Function() mutator) {
    final String oldColor = _baseColor;
    final BuildMode oldMode = _mode;
    setState(() {
      mutator();
      // When switching from allSame to perNail, seed each nail's color
      // from the current base color so they start in sync.
      if (oldMode == BuildMode.allSame && _mode == BuildMode.perNail) {
        for (int i = 0; i < _perNailColors.length; i++) {
          _perNailColors[i] = _baseColor;
        }
      }
      _syncSecondaryEffectsWithDesign();
      _rebuildRoutine();
    });
    if (_baseColor != oldColor) {
      _trackRecentColor(_baseColor);
    }
    _persistCurrentState();
  }

  void _trackRecentColor(String name) {
    final List<String> updated = <String>[
      name,
      ..._settings.recentColors.where((String c) => c != name),
    ];
    final List<String> trimmed =
        updated.length > 5 ? updated.sublist(0, 5) : updated;
    _updateSettings(_settings.copyWith(recentColors: trimmed));
  }

  Future<void> _editStepTime(RoutineStep step) async {
    final TextEditingController controller = TextEditingController(
      text: step.seconds.toString(),
    );

    final int? seconds = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit time',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(step.title, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Seconds'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final int? parsed = int.tryParse(controller.text.trim());
                if (parsed == null || parsed <= 0) {
                  return;
                }
                Navigator.of(context).pop(parsed);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (seconds == null) {
      return;
    }

    setState(() {
      _customStepSeconds[step.id] = seconds;
      _rebuildRoutine();
    });
    _persistCurrentState();
  }

  Future<void> _editProductForStep(RoutineStep step) async {
    final StepProduct existing = _stepProducts[step.id] ?? const StepProduct();
    final TextEditingController nameController = TextEditingController(
      text: existing.name,
    );
    final TextEditingController codeController = TextEditingController(
      text: existing.code,
    );
    ProductCategory category = existing.category;

    final StepProduct? updated = await showDialog<StepProduct>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(
                step.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Product #'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<ProductCategory>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: ProductCategory.values
                        .map(
                          (ProductCategory item) =>
                              DropdownMenuItem<ProductCategory>(
                                value: item,
                                child: Text(productCategoryLabel(item)),
                              ),
                        )
                        .toList(),
                    onChanged: (ProductCategory? value) {
                      if (value == null) {
                        return;
                      }
                      setDialogState(() {
                        category = value;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      StepProduct(
                        name: nameController.text.trim(),
                        code: codeController.text.trim(),
                        category: category,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    codeController.dispose();

    if (updated == null) {
      return;
    }

    setState(() {
      _stepProducts[step.id] = updated;
    });
    _persistCurrentState();
  }

  Future<void> _pickDesignFor(int nailIndex) async {
    setState(() {
      _selectedStudioNail = nailIndex;
    });

    final bool perNail = _mode == BuildMode.perNail;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (BuildContext ctx, ScrollController controller) {
            return StatefulBuilder(
              builder: (BuildContext ctx, StateSetter setSheetState) {
                final NailDesign currentDesign = _designForNail(nailIndex);
                final String currentColor = _colorForNail(nailIndex);
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: ListView(
                      controller: controller,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  perNail
                                      ? '${kNailNames[nailIndex]} nail'
                                      : 'Choose a design',
                                  style: Theme.of(
                                    ctx,
                                  ).textTheme.headlineSmall,
                                ),
                              ),
                              if (perNail)
                                TextButton.icon(
                                  onPressed: () {
                                    _applyNailStyleToAll(
                                      currentDesign,
                                      currentColor,
                                    );
                                    setSheetState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.copy_all_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Apply to all'),
                                ),
                            ],
                          ),
                        ),
                        if (perNail) ...<Widget>[
                          Center(
                            child: NailVisual(
                              design: currentDesign,
                              baseColor: _resolveBaseColor(currentColor),
                              chromeShade: _chromeShade,
                              width: 72,
                              height: 108,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'COLOR',
                            style: Theme.of(ctx).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: <Widget>[
                              ..._baseColorNames.map((String color) {
                                return ColorSwatchTile(
                                  label: color,
                                  color: _resolveBaseColor(color),
                                  selected: currentColor == color,
                                  onTap: () {
                                    _applyDesignChange(() {
                                      _perNailColors[nailIndex] = color;
                                    });
                                    setSheetState(() {});
                                  },
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'DESIGN',
                            style: Theme.of(ctx).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 10),
                        ],
                        ...NailDesign.values.map((NailDesign design) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: DesignChoiceTile(
                              design: design,
                              baseColor: _resolveBaseColor(currentColor),
                              chromeShade: _chromeShade,
                              selected: design == currentDesign,
                              onTap: () {
                                _applyDesignChange(() {
                                  if (_mode == BuildMode.allSame) {
                                    _allNailsDesign = design;
                                  } else {
                                    _perNailDesigns[nailIndex] = design;
                                  }
                                });
                                if (perNail) {
                                  setSheetState(() {});
                                } else {
                                  Navigator.of(sheetContext).pop();
                                }
                              },
                            ),
                          );
                        }),
                        if (perNail) ...<Widget>[
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                            },
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                            child: const Text('Done'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _applyNailStyleToAll(NailDesign design, String color) {
    HapticFeedback.lightImpact();
    _applyDesignChange(() {
      for (int i = 0; i < _perNailDesigns.length; i++) {
        _perNailDesigns[i] = design;
        _perNailColors[i] = color;
      }
    });
  }

  Future<void> _openLibraryPage() async {
    final List<StepProduct>? updated = await Navigator.of(context)
        .push<List<StepProduct>>(
          MaterialPageRoute<List<StepProduct>>(
            builder: (_) => ProductLibraryPage(
              products: List<StepProduct>.from(_productLibrary),
            ),
          ),
        );

    if (updated == null) {
      return;
    }

    setState(() {
      _productLibrary
        ..clear()
        ..addAll(updated);
    });
    unawaited(PersistenceStore.saveProducts(_productLibrary));
  }

  Future<void> _openPresetsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (BuildContext context, ScrollController controller) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ListView(
                controller: controller,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Saved presets',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          _scanPresetQr();
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        tooltip: 'Scan to import',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _PresetSaveCard(
                    onSave: (String name) {
                      _saveCurrentPreset(name);
                      Navigator.of(sheetContext).pop();
                    },
                    suggestedName: 'Preset ${_savedPresets.length + 1}',
                  ),
                  const SizedBox(height: 16),
                  if (_savedPresets.isEmpty)
                    const EmptyState(
                      icon: Icons.bookmark_outline,
                      title: 'No saved presets yet',
                      subtitle:
                          'Save your current design to recall the exact look later.',
                      verticalPadding: 24,
                    )
                  else
                    ..._savedPresets.map((DesignPreset preset) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SoftCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      preset.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${preset.baseColor} · ${designLabel(preset.allNailsDesign)}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _loadPreset(preset);
                                  Navigator.of(sheetContext).pop();
                                },
                                child: const Text('Load'),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(sheetContext).pop();
                                  _showPresetQr(preset);
                                },
                                icon: Icon(
                                  Icons.qr_code,
                                  size: 20,
                                  color: context.colors.muted,
                                ),
                                tooltip: 'Share via QR',
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(sheetContext).pop();
                                  sharePresetCard(
                                    context,
                                    preset,
                                    _settings,
                                    _customColors,
                                  );
                                },
                                icon: Icon(
                                  Icons.ios_share,
                                  size: 20,
                                  color: context.colors.muted,
                                ),
                                tooltip: 'Share card',
                              ),
                              IconButton(
                                onPressed: () async {
                                  final bool ok = await _confirm(
                                    title: 'Delete preset?',
                                    body:
                                        'Remove "${preset.name}" from your saved presets.',
                                  );
                                  if (!ok) return;
                                  setState(() {
                                    _savedPresets.remove(preset);
                                  });
                                  unawaited(
                                    PersistenceStore.savePresets(
                                      _savedPresets,
                                    ),
                                  );
                                  if (sheetContext.mounted) {
                                    Navigator.of(sheetContext).pop();
                                  }
                                },
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: context.colors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _saveCurrentPreset(String typedName) {
    final String name = typedName.trim().isEmpty
        ? 'Preset ${_savedPresets.length + 1}'
        : typedName.trim();

    final DesignPreset preset = DesignPreset(
      name: name,
      mode: _mode,
      baseColor: _baseColor,
      chromeShade: _chromeShade,
      chromeStyle: _chromeStyle,
      allNailsDesign: _allNailsDesign,
      perNailDesigns: List<NailDesign>.from(_perNailDesigns),
      includeAlcoholWipe: _includeAlcoholWipe,
      includeFinalTopCoat: _includeFinalTopCoat,
      customSeconds: Map<String, int>.from(_customStepSeconds),
      stepProducts: Map<String, StepProduct>.from(_stepProducts),
    );

    setState(() {
      final int existingIndex = _savedPresets.indexWhere(
        (DesignPreset item) =>
            item.name.trim().toLowerCase() == name.toLowerCase(),
      );
      if (existingIndex >= 0) {
        _savedPresets[existingIndex] = preset;
      } else {
        _savedPresets.add(preset);
      }
    });
    unawaited(PersistenceStore.savePresets(_savedPresets));
  }

  void _loadPreset(DesignPreset preset) {
    setState(() {
      _mode = preset.mode;
      _baseColor = preset.baseColor;
      _chromeShade = preset.chromeShade;
      _chromeStyle = preset.chromeStyle;
      _allNailsDesign = preset.allNailsDesign;
      _perNailDesigns
        ..clear()
        ..addAll(preset.perNailDesigns);
      if (preset.perNailColors != null &&
          preset.perNailColors!.isNotEmpty) {
        _perNailColors
          ..clear()
          ..addAll(preset.perNailColors!);
        while (_perNailColors.length < kNailNames.length) {
          _perNailColors.add(preset.baseColor);
        }
      } else {
        for (int i = 0; i < _perNailColors.length; i++) {
          _perNailColors[i] = preset.baseColor;
        }
      }
      _includeAlcoholWipe = preset.includeAlcoholWipe;
      _includeFinalTopCoat = preset.includeFinalTopCoat;
      _customStepSeconds
        ..clear()
        ..addAll(preset.customSeconds);
      _selectedStudioNail = 0;
      _syncSecondaryEffectsWithDesign();
      _rebuildRoutine(preferredProducts: preset.stepProducts);
    });
    _persistCurrentState();
  }

  Future<void> _openTimerPage() async {
    final TimerLaunchConfig config = TimerLaunchConfig(
      mode: _mode,
      baseColor: _baseColor,
      chromeShade: _chromeShade,
      allNailsDesign: _allNailsDesign,
      perNailDesigns: List<NailDesign>.from(_perNailDesigns),
      perNailColors: List<String>.from(_perNailColors),
      routine: List<RoutineStep>.from(_routine),
      stepProducts: Map<String, StepProduct>.from(_stepProducts),
      productLibrary: List<StepProduct>.from(_productLibrary),
      customColors: List<CustomColor>.from(_customColors),
      settings: _settings,
    );

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => TimerRunPage(config: config)),
    );
    if (!mounted) return;
    _goToStep(0);
  }

  Future<void> _applyDesignToAll(NailDesign design) async {
    HapticFeedback.lightImpact();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Apply to all nails?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Text('Set every nail to ${designLabel(design)}.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    _applyDesignChange(() {
      for (int i = 0; i < _perNailDesigns.length; i++) {
        _perNailDesigns[i] = design;
      }
    });
  }

  void _applyMoodPreset(MoodPreset preset) {
    HapticFeedback.selectionClick();
    _applyDesignChange(() {
      _baseColor = preset.baseColor;
      _allNailsDesign = preset.design;
      _mode = BuildMode.allSame;
      for (int i = 0; i < _perNailDesigns.length; i++) {
        _perNailDesigns[i] = preset.design;
      }
    });
  }

  Future<void> _extractPaletteFromPhoto() async {
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file == null || !mounted) {
      return;
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Extracting colors…'),
        duration: Duration(seconds: 2),
      ),
    );

    final PaletteGenerator palette =
        await PaletteGenerator.fromImageProvider(
          FileImage(File(file.path)),
          maximumColorCount: 8,
        );

    if (!mounted) {
      return;
    }

    final List<Color> extracted = palette.colors.toList();
    if (extracted.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not find colors in that image.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              20 + MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 8),
                    child: Text(
                      'Extracted palette',
                      style: Theme.of(sheetContext).textTheme.headlineSmall,
                    ),
                  ),
                  Text(
                    'Tap any color to save it to your palette.',
                    style: Theme.of(sheetContext).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AspectRatio(
                      aspectRatio: 1.4,
                      child: Image.file(File(file.path), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: extracted.map((Color c) {
                      return InkWell(
                        onTap: () async {
                          Navigator.of(sheetContext).pop();
                          await _saveExtractedColor(c);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: sheetContext.colors.creamWarm,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: sheetContext.colors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: sheetContext.colors.charcoal
                                        .withValues(alpha: 0.12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                colorHex(c),
                                style: Theme.of(sheetContext)
                                    .textTheme
                                    .labelLarge,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveExtractedColor(Color color) async {
    final TextEditingController controller = TextEditingController(
      text: 'From photo',
    );
    final String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Name this color',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colors.charcoal.withValues(alpha: 0.12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(colorHex(color), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Color name'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final String n = controller.text.trim();
                if (n.isEmpty) return;
                Navigator.of(context).pop(n);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (name == null) return;
    final CustomColor cc = CustomColor(name: name, color: color);
    setState(() {
      final int idx = _customColors.indexWhere(
        (CustomColor c) => c.name.toLowerCase() == name.toLowerCase(),
      );
      if (idx >= 0) {
        _customColors[idx] = cc;
      } else {
        _customColors.add(cc);
      }
      _baseColor = name;
    });
    unawaited(PersistenceStore.saveCustomColors(_customColors));
    _persistCurrentState();
  }

  Future<void> _openCustomColorPicker() async {
    final CustomColor? result = await showDialog<CustomColor>(
      context: context,
      builder: (BuildContext context) {
        return const CustomColorPickerDialog();
      },
    );
    if (result == null) {
      return;
    }
    setState(() {
      final int existingIndex = _customColors.indexWhere(
        (CustomColor c) => c.name.toLowerCase() == result.name.toLowerCase(),
      );
      if (existingIndex >= 0) {
        _customColors[existingIndex] = result;
      } else {
        _customColors.add(result);
      }
      _baseColor = result.name;
    });
    unawaited(PersistenceStore.saveCustomColors(_customColors));
    _persistCurrentState();
  }

  Future<void> _openManageCustomColors() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  24 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: Text(
                        'Saved colors',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    if (_customColors.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No saved colors yet.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: context.colors.muted),
                        ),
                      )
                    else
                      ..._customColors.map((CustomColor cc) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SoftCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: cc.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: context.colors.charcoal.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        cc.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      GestureDetector(
                                        onLongPress: () async {
                                          await Clipboard.setData(
                                            ClipboardData(
                                              text: colorHex(cc.color),
                                            ),
                                          );
                                          HapticFeedback.selectionClick();
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Copied ${colorHex(cc.color)}',
                                              ),
                                              duration: const Duration(
                                                seconds: 1,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          colorHex(cc.color),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            fontFeatures:
                                                const <FontFeature>[
                                                  FontFeature.tabularFigures(),
                                                ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final bool ok = await _confirm(
                                      title: 'Delete color?',
                                      body:
                                          'Remove "${cc.name}" from your saved swatches.',
                                    );
                                    if (!ok) return;
                                    setState(() {
                                      _customColors.remove(cc);
                                      if (_baseColor == cc.name) {
                                        _baseColor =
                                            kDefaultPalette.keys.first;
                                        _rebuildRoutine();
                                      }
                                    });
                                    setSheetState(() {});
                                    unawaited(
                                      PersistenceStore.saveCustomColors(
                                        _customColors,
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: context.colors.muted,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        _openCustomColorPicker();
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add new color'),
                    ),
                  ],
                ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openHistoryPage() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => HistoryPage(settings: _settings),
      ),
    );
  }

  Future<void> _openLookBook() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const LookBookPage()),
    );
  }

  Future<void> _showPresetQr(DesignPreset preset) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dctx) {
        final String payload = encodePresetQrPayload(preset);
        return AlertDialog(
          title: Text(
            'Share preset',
            style: Theme.of(dctx).textTheme.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                preset.name,
                style: Theme.of(dctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: QrImageView(
                  data: payload,
                  size: 240,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppPalette.charcoal,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppPalette.charcoal,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Have a friend scan this from the Presets sheet.',
                textAlign: TextAlign.center,
                style: Theme.of(dctx).textTheme.bodySmall,
              ),
            ],
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(dctx).pop();
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _scanPresetQr() async {
    final DesignPreset? scanned =
        await Navigator.of(context).push<DesignPreset>(
      MaterialPageRoute<DesignPreset>(builder: (_) => const QrScanPage()),
    );
    if (scanned == null) {
      return;
    }
    if (!mounted) return;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dctx) {
        return AlertDialog(
          title: Text(
            'Import preset?',
            style: Theme.of(dctx).textTheme.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(scanned.name,
                  style: Theme.of(dctx).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '${scanned.baseColor} · ${designLabel(scanned.allNailsDesign)}',
                style: Theme.of(dctx).textTheme.bodySmall,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dctx).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dctx).pop(true);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    setState(() {
      final int existingIndex = _savedPresets.indexWhere(
        (DesignPreset p) =>
            p.name.trim().toLowerCase() ==
            scanned.name.trim().toLowerCase(),
      );
      final DesignPreset toAdd = existingIndex >= 0
          ? DesignPreset(
              name: '${scanned.name} (imported)',
              mode: scanned.mode,
              baseColor: scanned.baseColor,
              chromeShade: scanned.chromeShade,
              chromeStyle: scanned.chromeStyle,
              allNailsDesign: scanned.allNailsDesign,
              perNailDesigns: scanned.perNailDesigns,
              includeAlcoholWipe: scanned.includeAlcoholWipe,
              includeFinalTopCoat: scanned.includeFinalTopCoat,
              customSeconds: scanned.customSeconds,
              stepProducts: scanned.stepProducts,
              customSteps: scanned.customSteps,
              routineOrder: scanned.routineOrder,
            )
          : scanned;
      _savedPresets.add(toAdd);
    });
    unawaited(PersistenceStore.savePresets(_savedPresets));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported "${scanned.name}"')),
      );
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SettingsPage(
          initial: _settings,
          baseColorOptions: _baseColorNames,
          resolveColor: _resolveBaseColor,
          onChanged: _updateSettings,
        ),
      ),
    );
  }

  Future<void> _openTryOn() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TryOnPage(
          colors: List<Color>.generate(
            kNailNames.length,
            (int i) => _resolveColorForNail(i),
          ),
          chromeShade: _chromeShade,
          designs: List<NailDesign>.generate(
            kNailNames.length,
            (int i) => _designForNail(i),
          ),
        ),
      ),
    );
  }

  Future<void> _openDesignGallery() async {
    final NailDesign? selected = await Navigator.of(context).push<NailDesign>(
      MaterialPageRoute<NailDesign>(
        builder: (_) => DesignGalleryPage(
          baseColor: _resolveBaseColor(_baseColor),
          chromeShade: _chromeShade,
          currentSelection: _mode == BuildMode.allSame
              ? _allNailsDesign
              : _designForNail(_selectedStudioNail),
        ),
      ),
    );
    if (selected == null) {
      return;
    }
    _applyDesignChange(() {
      if (_mode == BuildMode.allSame) {
        _allNailsDesign = selected;
      } else {
        _perNailDesigns[_selectedStudioNail] = selected;
      }
    });
  }

  void _goToStep(int step) {
    setState(() {
      _step = step.clamp(0, _stepLabels.length - 1);
    });
    _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _goNext() {
    if (_step >= _stepLabels.length - 1) {
      _openTimerPage();
      return;
    }
    _goToStep(_step + 1);
  }

  void _goBack() {
    if (_step <= 0) {
      return;
    }
    _goToStep(_step - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: HomeTitle(onTap: () => _goToStep(0)),
        actions: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder:
                (Widget child, Animation<double> animation) =>
                    FadeTransition(opacity: animation, child: child),
            child: _savedJustNow
                ? Padding(
                    key: const ValueKey<String>('savedpill'),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.blushSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.blush),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.check,
                            size: 12,
                            color: context.colors.mauveDeep,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Saved',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: context.colors.mauveDeep,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey<String>('nopill')),
          ),
          IconButton(
            onPressed: _openHistoryPage,
            icon: const Icon(Icons.history),
            tooltip: 'Session history',
          ),
          IconButton(
            onPressed: _openLookBook,
            icon: const Icon(Icons.collections_outlined),
            tooltip: 'Look book',
          ),
          IconButton(
            onPressed: _openDesignGallery,
            icon: const Icon(Icons.grid_view_outlined),
            tooltip: 'Design gallery',
          ),
          IconButton(
            onPressed: _openTryOn,
            icon: const Icon(Icons.face_retouching_natural),
            tooltip: 'Virtual try-on',
          ),
          IconButton(
            onPressed: _openPresetsSheet,
            icon: const Icon(Icons.bookmark_border),
            tooltip: 'Saved presets',
          ),
          IconButton(
            onPressed: _openLibraryPage,
            icon: const Icon(Icons.style_outlined),
            tooltip: 'Product library',
          ),
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _WizardProgress(step: _step, labels: _stepLabels),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int index) {
                  setState(() {
                    _step = index;
                  });
                },
                children: <Widget>[
                  _buildBaseStep(),
                  _buildDesignStep(),
                  _buildFinishingStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
            _WizardFooter(
              step: _step,
              total: _stepLabels.length,
              totalSeconds: _totalSeconds,
              onBack: _goBack,
              onNext: _goNext,
              nextLabel: _step == _stepLabels.length - 1
                  ? 'Start Timer'
                  : 'Continue',
            ),
          ],
        ),
      ),
    );
  }

  // ── Step pages ────────────────────────────────────────────────────────

  Widget _buildBaseStep() {
    final NailHoroscope today = horoscopeForToday();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: <Widget>[
        _HoroscopeCard(horoscope: today),
        const SizedBox(height: 18),
        const SectionHeader(
          eyebrow: 'Step 01',
          title: 'Set the foundation',
          subtitle: 'Choose how you\'ll design your set and pick a base color.',
        ),
        const SizedBox(height: 16),
        Text(
          'QUICK MOOD',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kMoodPresets.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (BuildContext context, int i) {
              final MoodPreset preset = kMoodPresets[i];
              final bool isCurrent =
                  _allNailsDesign == preset.design &&
                  _baseColor == preset.baseColor;
              return PressScale(
                child: InkWell(
                onTap: () {
                  _applyMoodPreset(preset);
                },
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 144,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? context.colors.blushSoft
                        : context.colors.creamWarm,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isCurrent
                          ? context.colors.mauve
                          : context.colors.border,
                      width: isCurrent ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(
                        preset.icon,
                        size: 18,
                        color: context.colors.mauveDeep,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            preset.label,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            preset.subtitle,
                            style: Theme.of(context).textTheme.labelSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: SegmentedButton<BuildMode>(
            segments: const <ButtonSegment<BuildMode>>[
              ButtonSegment<BuildMode>(
                value: BuildMode.allSame,
                label: Text('All the same'),
                icon: Icon(Icons.copy_all_outlined, size: 16),
              ),
              ButtonSegment<BuildMode>(
                value: BuildMode.perNail,
                label: Text('Per nail'),
                icon: Icon(Icons.fingerprint, size: 16),
              ),
            ],
            selected: <BuildMode>{_mode},
            showSelectedIcon: false,
            onSelectionChanged: (Set<BuildMode> newMode) {
              _applyDesignChange(() {
                _mode = newMode.first;
              });
            },
          ),
        ),
        if (_validRecentColors.length >= 2) ...<Widget>[
          const SizedBox(height: 20),
          Text(
            'RECENT',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _validRecentColors.map((String name) {
              return ColorSwatchTile(
                label: name,
                color: _resolveBaseColor(name),
                selected: _baseColor == name,
                onTap: () {
                  _applyDesignChange(() {
                    _baseColor = name;
                  });
                },
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'BASE COLOR',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            ..._baseColorNames.map((String color) {
              return ColorSwatchTile(
                label: color,
                color: _resolveBaseColor(color),
                selected: _baseColor == color,
                onTap: () {
                  _applyDesignChange(() {
                    _baseColor = color;
                  });
                },
              );
            }),
            _AddColorChip(onTap: _openCustomColorPicker),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            TextButton.icon(
              onPressed: _extractPaletteFromPhoto,
              icon: const Icon(Icons.photo_outlined, size: 16),
              label: const Text('Extract from photo'),
            ),
            if (_customColors.isNotEmpty) ...<Widget>[
              const SizedBox(width: 6),
              TextButton.icon(
                onPressed: _openManageCustomColors,
                icon: const Icon(Icons.tune, size: 16),
                label: const Text('Manage saved'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: NailDisplayCard(
            name: 'Preview',
            design: NailDesign.solid,
            baseColor: _resolveBaseColor(_baseColor),
            chromeShade: _chromeShade,
          ),
        ),
      ],
    );
  }

  Widget _buildDesignStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: <Widget>[
        SectionHeader(
          eyebrow: 'Step 02',
          title: 'Choose your design',
          subtitle: _mode == BuildMode.allSame
              ? 'Pick a single design for all five nails.'
              : 'Tap each nail to set its own color and design.',
        ),
        const SizedBox(height: 24),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List<Widget>.generate(kNailNames.length, (int index) {
                  return NailDisplayCard(
                    name: kNailNames[index],
                    design: _designForNail(index),
                    baseColor: _resolveColorForNail(index),
                    chromeShade: _chromeShade,
                    selected: _mode == BuildMode.perNail
                        ? index == _selectedStudioNail
                        : false,
                    onTap: () {
                      _pickDesignFor(index);
                    },
                    onLongPress: _mode == BuildMode.perNail
                        ? () => _applyDesignToAll(_designForNail(index))
                        : null,
                  );
                }),
              ),
              if (_mode == BuildMode.allSame) ...<Widget>[
                const Divider(height: 32),
                Text(
                  'Tap a design',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                ...NailDesign.values.map((NailDesign design) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DesignChoiceTile(
                      design: design,
                      baseColor: _resolveBaseColor(_baseColor),
                      chromeShade: _chromeShade,
                      selected: _allNailsDesign == design,
                      onTap: () {
                        _applyDesignChange(() {
                          _allNailsDesign = design;
                        });
                      },
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        if (_needsChromeOptions) ...<Widget>[
          const SizedBox(height: 20),
          Text(
            'CHROME OPTIONS',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Application style',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ChromeStyle.values.map((ChromeStyle style) {
                    final bool selected = _chromeStyle == style;
                    return ChoiceChip(
                      label: Text(chromeStyleLabel(style)),
                      selected: selected,
                      onSelected: (_) {
                        _applyDesignChange(() {
                          _chromeStyle = style;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Text(
                  'Chrome shade',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _chromeShades.map((String shade) {
                    return ColorSwatchTile(
                      label: shade,
                      color: chromeShadeColor(shade),
                      selected: _chromeShade == shade,
                      onTap: () {
                        _applyDesignChange(() {
                          _chromeShade = shade;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFinishingStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: <Widget>[
        const SectionHeader(
          eyebrow: 'Step 03',
          title: 'Finishing touches',
          subtitle: 'Add the final layers and customize each step\'s time.',
        ),
        const SizedBox(height: 24),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: <Widget>[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _includeAlcoholWipe,
                title: Text(
                  'Alcohol wipe',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Remove tacky residue after curing',
                  style: TextStyle(color: context.colors.muted),
                ),
                onChanged: (bool value) {
                  _applyDesignChange(() {
                    _includeAlcoholWipe = value;
                  });
                },
              ),
              Divider(height: 1, color: context.colors.borderSoft),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _includeFinalTopCoat,
                title: Text(
                  'Final top coat',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Seal the design with a last gloss layer',
                  style: TextStyle(color: context.colors.muted),
                ),
                onChanged: (bool value) {
                  _applyDesignChange(() {
                    _includeFinalTopCoat = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'ROUTINE STEPS',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Text(
              'Total ${formatClock(_totalSeconds)}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Drag the handle to reorder. Tap the time to adjust.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: _routine.length,
          onReorder: _onReorderRoutine,
          itemBuilder: (BuildContext context, int index) {
            final RoutineStep step = _routine[index];
            final StepProduct product =
                _stepProducts[step.id] ?? const StepProduct();
            return Padding(
              key: ValueKey<String>(step.id),
              padding: const EdgeInsets.only(bottom: 10),
              child: SoftCard(
                padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        ReorderableDragStartListener(
                          index: index,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 6,
                            ),
                            child: Icon(
                              Icons.drag_indicator,
                              color: context.colors.muted,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  step.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              if (step.isCustom)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.colors.blushSoft,
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Custom',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall?.copyWith(
                                        color: context.colors.mauveDeep,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _editStepTime(step);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.timer_outlined,
                                  size: 16,
                                  color: context.colors.mauve,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  formatClock(step.seconds),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: context.colors.mauveDeep,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: Text(
                        product.isEmpty ? 'Product not set' : product.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 28),
                      child: Row(
                        children: <Widget>[
                          TextButton.icon(
                            onPressed: () {
                              _editProductForStep(step);
                            },
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('Product'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          ),
                          PopupMenuButton<StepProduct>(
                            tooltip: 'Pick from library',
                            position: PopupMenuPosition.under,
                            onSelected: (StepProduct selected) {
                              setState(() {
                                _stepProducts[step.id] = selected;
                              });
                              _persistCurrentState();
                            },
                            itemBuilder: (BuildContext context) {
                              return _productLibrary.map((StepProduct item) {
                                return PopupMenuItem<StepProduct>(
                                  value: item,
                                  child: Text(
                                    '${productCategoryLabel(item.category)} · ${item.label}',
                                  ),
                                );
                              }).toList();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.menu_book_outlined,
                                    size: 16,
                                    color: context.colors.mauve,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Library',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(color: context.colors.mauve),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (step.isCustom)
                            TextButton.icon(
                              onPressed: () {
                                _removeCustomStep(step.id);
                              },
                              icon: Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: context.colors.muted,
                              ),
                              label: Text(
                                'Remove',
                                style: TextStyle(color: context.colors.muted),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addCustomStep,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add custom step'),
              ),
            ),
            if (_routineOrder != null ||
                _userCustomSteps.isNotEmpty ||
                _customStepSeconds.isNotEmpty) ...<Widget>[
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: _resetRoutineToAuto,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: <Widget>[
        const SectionHeader(
          eyebrow: 'Step 04',
          title: 'Ready when you are',
          subtitle: 'Double-check your set, then begin the guided timer.',
        ),
        const SizedBox(height: 24),
        SoftCard(
          color: context.colors.blushSoft,
          borderColor: context.colors.blush,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List<Widget>.generate(kNailNames.length, (int index) {
                  return NailDisplayCard(
                    name: kNailNames[index],
                    design: _designForNail(index),
                    baseColor: _resolveColorForNail(index),
                    chromeShade: _chromeShade,
                  );
                }),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _ReviewMetric(
                    label: 'Base',
                    value: _baseColor,
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: context.colors.border,
                  ),
                  _ReviewMetric(
                    label: 'Steps',
                    value: _routine.length.toString(),
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: context.colors.border,
                  ),
                  _ReviewMetric(
                    label: 'Total',
                    value: formatClock(_totalSeconds),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'ROUTINE',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            children: List<Widget>.generate(_routine.length, (int index) {
              final RoutineStep step = _routine[index];
              final StepProduct product =
                  _stepProducts[step.id] ?? const StepProduct();
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.colors.cream,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context.colors.charcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    NailVisual(
                      design: designForStepThumbnail(step.id),
                      baseColor: _resolveBaseColor(_baseColor),
                      chromeShade: _chromeShade,
                      width: 28,
                      height: 42,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            step.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (!product.isEmpty)
                            Text(
                              product.label,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    Text(
                      formatClock(step.seconds),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: _openPresetsSheet,
            icon: const Icon(Icons.bookmark_add_outlined, size: 18),
            label: const Text('Save this as a preset'),
          ),
        ),
      ],
    );
  }
}

class _WizardProgress extends StatelessWidget {
  const _WizardProgress({required this.step, required this.labels});

  final int step;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: List<Widget>.generate(labels.length * 2 - 1, (int idx) {
          if (idx.isOdd) {
            return Container(
              width: 18,
              height: 1,
              color: context.colors.border,
            );
          }
          final int i = idx ~/ 2;
          final bool isActive = i == step;
          final bool isDone = i < step;
          return Expanded(
            child: Column(
              children: <Widget>[
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive
                        ? context.colors.mauve
                        : isDone
                        ? context.colors.charcoal
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive || isDone
                          ? Colors.transparent
                          : context.colors.border,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          '${i + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : context.colors.charcoal,
                          ),
                        ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isActive
                        ? context.colors.charcoal
                        : context.colors.muted,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _WizardFooter extends StatelessWidget {
  const _WizardFooter({
    required this.step,
    required this.total,
    required this.totalSeconds,
    required this.onBack,
    required this.onNext,
    required this.nextLabel,
  });

  final int step;
  final int total;
  final int totalSeconds;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = step > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: BoxDecoration(
        color: context.colors.cream,
        border: Border(top: BorderSide(color: context.colors.borderSoft)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: context.colors.muted,
                ),
                const SizedBox(width: 6),
                Text(
                  'Total ${formatClock(totalSeconds)}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              if (canGoBack)
                OutlinedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Back'),
                ),
              if (canGoBack) const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onNext,
                  icon: Icon(
                    step == total - 1
                        ? Icons.play_arrow
                        : Icons.arrow_forward,
                    size: 16,
                  ),
                  label: Text(nextLabel),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewMetric extends StatelessWidget {
  const _ReviewMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _PresetSaveCard extends StatefulWidget {
  const _PresetSaveCard({required this.onSave, required this.suggestedName});

  final void Function(String name) onSave;
  final String suggestedName;

  @override
  State<_PresetSaveCard> createState() => _PresetSaveCardState();
}

class _PresetSaveCardState extends State<_PresetSaveCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.suggestedName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Preset name'),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: () {
              widget.onSave(_controller.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class CustomColorPickerDialog extends StatefulWidget {
  const CustomColorPickerDialog({super.key});

  @override
  State<CustomColorPickerDialog> createState() =>
      _CustomColorPickerDialogState();
}

class _CustomColorPickerDialogState extends State<CustomColorPickerDialog> {
  Color _selected = const Color(0xFFB0436B);
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'My color');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      title: Text(
        'Custom color',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ColorPicker(
              pickerColor: _selected,
              onColorChanged: (Color color) {
                setState(() {
                  _selected = color;
                });
              },
              enableAlpha: false,
              labelTypes: const <ColorLabelType>[ColorLabelType.hex],
              pickerAreaHeightPercent: 0.6,
              pickerAreaBorderRadius: BorderRadius.circular(14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Color name'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final String name = _nameController.text.trim();
            if (name.isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              CustomColor(name: name, color: _selected),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Timer page
// ─────────────────────────────────────────────────────────────────────────

class TimerRunPage extends StatefulWidget {
  const TimerRunPage({super.key, required this.config});

  final TimerLaunchConfig config;

  @override
  State<TimerRunPage> createState() => _TimerRunPageState();
}

class _TimerRunPageState extends State<TimerRunPage> {
  Timer? _ticker;
  late final List<RoutineStep> _routine;
  late final List<StepProduct> _productLibrary;
  late final Map<String, StepProduct> _stepProducts;
  final Set<String> _confirmedStepIds = <String>{};

  int _currentStepIndex = 0;
  int _secondsLeft = 0;
  bool _isRunning = false;
  bool _isComplete = false;
  bool _sessionSaved = false;
  late bool _oneHandedMode;

  @override
  void initState() {
    super.initState();
    _routine = List<RoutineStep>.from(widget.config.routine);
    _productLibrary = List<StepProduct>.from(widget.config.productLibrary);
    _stepProducts = Map<String, StepProduct>.from(widget.config.stepProducts);
    _secondsLeft = _routine.isEmpty ? 0 : _routine.first.seconds;
    _oneHandedMode = widget.config.settings.oneHandedMode;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _hapticTransition() {
    if (widget.config.settings.hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (widget.config.settings.soundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  void _hapticTick() {
    if (widget.config.settings.hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    if (widget.config.settings.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void _hapticComplete() {
    if (widget.config.settings.hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    if (widget.config.settings.soundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (widget.config.settings.hapticsEnabled) {
        HapticFeedback.heavyImpact();
      }
    });
  }

  Future<void> _openSaveSession() async {
    final ImagePicker picker = ImagePicker();
    String? photoPath;
    String notes = '';
    final TextEditingController notesController = TextEditingController();

    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  20 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 14),
                        child: Text(
                          'Save this session',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      if (photoPath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.file(
                              File(photoPath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: context.colors.blushSoft,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: context.colors.border),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 36,
                              color: context.colors.muted,
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final XFile? f = await picker.pickImage(
                                  source: ImageSource.camera,
                                  maxWidth: 1600,
                                  imageQuality: 85,
                                );
                                if (f != null) {
                                  setSheetState(() {
                                    photoPath = f.path;
                                  });
                                }
                              },
                              icon: const Icon(
                                Icons.photo_camera_outlined,
                                size: 16,
                              ),
                              label: const Text('Camera'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final XFile? f = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1600,
                                  imageQuality: 85,
                                );
                                if (f != null) {
                                  setSheetState(() {
                                    photoPath = f.path;
                                  });
                                }
                              },
                              icon: const Icon(
                                Icons.photo_library_outlined,
                                size: 16,
                              ),
                              label: const Text('Gallery'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          hintText: 'How did it turn out?',
                        ),
                        onChanged: (String value) {
                          notes = value;
                        },
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop(true);
                        },
                        icon: const Icon(Icons.bookmark_added_outlined),
                        label: const Text('Save to history'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop(false);
                        },
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    notesController.dispose();

    if (saved != true) {
      return;
    }

    final int total = widget.config.routine.fold<int>(
      0,
      (int sum, RoutineStep s) => sum + s.seconds,
    );
    final Color baseColor = baseColorValue(
      widget.config.baseColor,
      widget.config.customColors,
    );
    final int argb = (baseColor.a * 255).round() << 24 |
        (baseColor.r * 255).round() << 16 |
        (baseColor.g * 255).round() << 8 |
        (baseColor.b * 255).round();

    final List<int> perNailArgbs = widget.config.perNailColors.map(
      (String name) {
        final Color c = baseColorValue(name, widget.config.customColors);
        return (c.a * 255).round() << 24 |
            (c.r * 255).round() << 16 |
            (c.g * 255).round() << 8 |
            (c.b * 255).round();
      },
    ).toList();

    final SessionRecord record = SessionRecord(
      id: 's-${DateTime.now().millisecondsSinceEpoch}',
      completedAt: DateTime.now(),
      durationSeconds: total,
      baseColorName: widget.config.baseColor,
      baseColorArgb: argb,
      chromeShade: widget.config.chromeShade,
      mode: widget.config.mode,
      allNailsDesign: widget.config.allNailsDesign,
      perNailDesigns:
          List<NailDesign>.from(widget.config.perNailDesigns),
      perNailColorArgbs: perNailArgbs,
      photoPath: photoPath,
      notes: notes.trim().isEmpty ? null : notes.trim(),
    );

    final List<SessionRecord> existing =
        await PersistenceStore.loadSessions();
    final List<SessionRecord> updated = <SessionRecord>[record, ...existing];
    await PersistenceStore.saveSessions(updated);

    if (mounted) {
      setState(() {
        _sessionSaved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session saved to history'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  NailDesign _designForNail(int index) {
    if (widget.config.mode == BuildMode.allSame) {
      return widget.config.allNailsDesign;
    }
    return widget.config.perNailDesigns[index];
  }

  int get _totalRoutineSeconds {
    return _routine.fold<int>(0, (int sum, RoutineStep s) => sum + s.seconds);
  }

  int get _elapsedSeconds {
    int elapsed = 0;
    for (int i = 0; i < _currentStepIndex && i < _routine.length; i++) {
      elapsed += _routine[i].seconds;
    }
    if (_isComplete) {
      return _totalRoutineSeconds;
    }
    if (_currentStepIndex < _routine.length) {
      elapsed += _routine[_currentStepIndex].seconds - _secondsLeft;
    }
    return elapsed;
  }

  Future<void> _editStepTime(RoutineStep step) async {
    if (_routine.isEmpty) {
      return;
    }

    final bool wasRunning = _isRunning;
    if (_isRunning) {
      _pause();
    }

    final TextEditingController controller = TextEditingController(
      text: step.seconds.toString(),
    );

    final int? seconds = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit time',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(step.title, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Seconds'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final int? parsed = int.tryParse(controller.text.trim());
                if (parsed == null || parsed <= 0) {
                  return;
                }
                Navigator.of(context).pop(parsed);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (seconds == null) {
      if (wasRunning && mounted) {
        _start();
      }
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      final int index = _routine.indexWhere(
        (RoutineStep item) => item.id == step.id,
      );
      if (index >= 0) {
        _routine[index] = _routine[index].copyWith(seconds: seconds);
      }

      if (_currentStepIndex == index) {
        _secondsLeft = _secondsLeft > seconds ? seconds : _secondsLeft;
        if (_secondsLeft == 0) {
          _secondsLeft = seconds;
        }
      }
    });

    if (wasRunning && mounted) {
      _start();
    }
  }

  void _toggleConfirmedStep(int index, bool isChecked) {
    final RoutineStep step = _routine[index];

    setState(() {
      if (isChecked) {
        _confirmedStepIds.add(step.id);
      } else {
        _confirmedStepIds.remove(step.id);
      }

      if (!isChecked) {
        return;
      }

      if (index == _currentStepIndex && !_isComplete) {
        if (_currentStepIndex < _routine.length - 1) {
          _currentStepIndex++;
          _secondsLeft = _routine[_currentStepIndex].seconds;
        } else {
          _isComplete = true;
          _isRunning = false;
          _secondsLeft = 0;
          _ticker?.cancel();
        }
      }
    });
  }

  void _start() {
    if (_isRunning || _routine.isEmpty) {
      return;
    }

    if (_isComplete) {
      _reset();
    }

    setState(() {
      _isRunning = true;
    });
    if (widget.config.settings.keepScreenAwake) {
      WakelockPlus.enable();
    }

    _ticker = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
          if (_secondsLeft <= 3 && _secondsLeft > 0) {
            _hapticTick();
          }
          return;
        }

        if (_currentStepIndex < _routine.length - 1) {
          _currentStepIndex++;
          _secondsLeft = _routine[_currentStepIndex].seconds;
          _hapticTransition();
          return;
        }

        _isRunning = false;
        _isComplete = true;
        _secondsLeft = 0;
        timer.cancel();
        WakelockPlus.disable();
        _hapticComplete();
      });
    });
  }

  void _pause() {
    _ticker?.cancel();
    WakelockPlus.disable();
    setState(() {
      _isRunning = false;
    });
  }

  void _reset() {
    _ticker?.cancel();
    WakelockPlus.disable();
    setState(() {
      _isRunning = false;
      _isComplete = false;
      _sessionSaved = false;
      _currentStepIndex = 0;
      _confirmedStepIds.clear();
      _secondsLeft = _routine.isEmpty ? 0 : _routine.first.seconds;
    });
  }

  void _skipForward() {
    if (_routine.isEmpty || _isComplete) {
      return;
    }
    setState(() {
      if (_currentStepIndex < _routine.length - 1) {
        _currentStepIndex++;
        _secondsLeft = _routine[_currentStepIndex].seconds;
        _hapticTransition();
      } else {
        _isComplete = true;
        _isRunning = false;
        _secondsLeft = 0;
        _ticker?.cancel();
        WakelockPlus.disable();
        _hapticComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_routine.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const HomeTitle(subtitle: 'TIMER SESSION')),
        body: const Center(child: Text('No steps to run.')),
      );
    }

    final RoutineStep currentStep = _routine[_currentStepIndex];
    final StepProduct currentProduct =
        _stepProducts[currentStep.id] ?? const StepProduct();
    final int currentStepDuration = currentStep.seconds;
    final double stepProgress = currentStepDuration == 0
        ? 0
        : (currentStepDuration - _secondsLeft) / currentStepDuration;
    final double overallProgress = _totalRoutineSeconds == 0
        ? 0
        : _elapsedSeconds / _totalRoutineSeconds;

    final TextTheme t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const HomeTitle(subtitle: 'TIMER SESSION'),
        actions: <Widget>[
          IconButton(
            tooltip: _oneHandedMode
                ? 'Switch to two-handed mode'
                : 'Switch to one-handed mode',
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _oneHandedMode = !_oneHandedMode;
              });
            },
            icon: Icon(
              _oneHandedMode ? Icons.front_hand : Icons.back_hand_outlined,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (DragEndDetails details) {
            if (!_oneHandedMode) return;
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity! > 200) {
              // swipe right → next
              _skipForward();
            }
          },
          behavior: HitTestBehavior.translucent,
          child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: <Widget>[
            SoftCard(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              borderColor: AppPalette.charcoal,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFF40272F),
                  AppPalette.charcoal,
                  Color(0xFF1F1218),
                ],
                stops: <double>[0.0, 0.55, 1.0],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        _isComplete
                            ? 'COMPLETE'
                            : 'STEP ${_currentStepIndex + 1} OF ${_routine.length}',
                        style: t.labelSmall?.copyWith(color: context.colors.blush),
                      ),
                      Text(
                        formatClock(_totalRoutineSeconds - _elapsedSeconds),
                        style: t.labelMedium?.copyWith(
                          color: context.colors.blush.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _isComplete ? 'Routine complete' : currentStep.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: _CountdownDial(
                      progress: _isComplete ? 1 : stepProgress.clamp(0.0, 1.0),
                      text: _isComplete ? 'Done' : formatClock(_secondsLeft),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!currentProduct.isEmpty || !_isComplete)
                    Center(
                      child: Text(
                        currentProduct.isEmpty
                            ? 'No product assigned'
                            : currentProduct.label,
                        style: t.bodyMedium?.copyWith(
                          color: context.colors.blush.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: overallProgress.clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.blush,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isComplete && !_sessionSaved)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FilledButton.icon(
                  onPressed: _openSaveSession,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Save to history'),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.charcoal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isComplete
                        ? _reset
                        : _isRunning
                        ? _pause
                        : _start,
                    icon: Icon(
                      _isComplete
                          ? Icons.replay
                          : _isRunning
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    label: Text(
                      _isComplete
                          ? 'Reset'
                          : _isRunning
                          ? 'Pause'
                          : 'Start',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _skipForward,
                  icon: const Icon(Icons.skip_next, size: 16),
                  label: const Text('Skip'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('YOUR SET', style: t.titleSmall),
            const SizedBox(height: 12),
            SoftCard(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
              color: context.colors.blushSoft,
              borderColor: context.colors.blush,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List<Widget>.generate(kNailNames.length, (int index) {
                  final String colorName =
                      widget.config.mode == BuildMode.allSame
                          ? widget.config.baseColor
                          : (index < widget.config.perNailColors.length
                              ? widget.config.perNailColors[index]
                              : widget.config.baseColor);
                  return NailDisplayCard(
                    name: kNailNames[index],
                    design: _designForNail(index),
                    baseColor: baseColorValue(
                      colorName,
                      widget.config.customColors,
                    ),
                    chromeShade: widget.config.chromeShade,
                    compact: true,
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            Text('ROUTINE', style: t.titleSmall),
            const SizedBox(height: 12),
            ...List<Widget>.generate(_routine.length, (int index) {
              final RoutineStep step = _routine[index];
              final StepProduct product =
                  _stepProducts[step.id] ?? const StepProduct();
              final bool isDoneByTimer =
                  _isComplete || index < _currentStepIndex;
              final bool isDoneByCheck = _confirmedStepIds.contains(step.id);
              final bool isDone = isDoneByTimer || isDoneByCheck;
              final bool isCurrent =
                  !_isComplete && index == _currentStepIndex;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  borderColor: isCurrent ? context.colors.mauve : null,
                  color: isCurrent ? context.colors.blushSoft : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          _StepStatusIcon(isDone: isDone, isCurrent: isCurrent),
                          const SizedBox(width: 10),
                          Opacity(
                            opacity: isDone ? 0.5 : 1.0,
                            child: NailVisual(
                              design: designForStepThumbnail(step.id),
                              baseColor: baseColorValue(
                                widget.config.baseColor,
                                widget.config.customColors,
                              ),
                              chromeShade: widget.config.chromeShade,
                              width: 28,
                              height: 42,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  step.title,
                                  style: t.titleMedium?.copyWith(
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: isDone
                                        ? context.colors.muted
                                        : context.colors.charcoal,
                                  ),
                                ),
                                if (!product.isEmpty)
                                  Text(
                                    product.label,
                                    style: t.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            formatClock(step.seconds),
                            style: t.labelLarge?.copyWith(
                              color: isCurrent
                                  ? context.colors.mauveDeep
                                  : context.colors.charcoalSoft,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          FilterChip(
                            label: Text(isDone ? 'Done' : 'Mark done'),
                            selected: isDone,
                            showCheckmark: false,
                            onSelected: (bool value) {
                              _toggleConfirmedStep(index, value);
                            },
                          ),
                          TextButton.icon(
                            onPressed: () {
                              _editStepTime(step);
                            },
                            icon: const Icon(Icons.timer_outlined, size: 16),
                            label: const Text('Edit time'),
                          ),
                          PopupMenuButton<StepProduct>(
                            tooltip: 'Pick product',
                            position: PopupMenuPosition.under,
                            onSelected: (StepProduct selected) {
                              setState(() {
                                _stepProducts[step.id] = selected;
                              });
                            },
                            itemBuilder: (BuildContext context) {
                              return _productLibrary.map((StepProduct item) {
                                return PopupMenuItem<StepProduct>(
                                  value: item,
                                  child: Text(
                                    '${productCategoryLabel(item.category)} · ${item.label}',
                                  ),
                                );
                              }).toList();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.menu_book_outlined,
                                    size: 16,
                                    color: context.colors.mauve,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Library',
                                    style: t.labelLarge?.copyWith(
                                      color: context.colors.mauve,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
        ),
      ),
      floatingActionButton: _oneHandedMode && _routine.isNotEmpty
          ? _buildOneHandedFab()
          : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildOneHandedFab() {
    final String label;
    final IconData icon;
    final VoidCallback onTap;
    if (_isComplete) {
      label = _sessionSaved ? 'Reset' : 'Save';
      icon = _sessionSaved ? Icons.replay : Icons.bookmark_add_outlined;
      onTap = _sessionSaved ? _reset : _openSaveSession;
    } else if (_isRunning) {
      label = 'Skip';
      icon = Icons.skip_next;
      onTap = _skipForward;
    } else {
      label = 'Start';
      icon = Icons.play_arrow;
      onTap = _start;
    }
    return FloatingActionButton.extended(
      onPressed: onTap,
      icon: Icon(icon, size: 28),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
      extendedPadding: const EdgeInsets.symmetric(
        horizontal: 36,
        vertical: 12,
      ),
    );
  }
}

class _CountdownDial extends StatelessWidget {
  const _CountdownDial({required this.progress, required this.text});

  final double progress;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomPaint(
            size: const Size.square(200),
            painter: _DialPainter(progress: progress),
          ),
          Text(
            text,
            style: GoogleFonts.playfairDisplay(
              fontSize: 48,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = math.min(size.width, size.height) / 2 - 6;

    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = Colors.white.withValues(alpha: 0.10);
    canvas.drawCircle(center, radius, trackPaint);

    final Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: const <Color>[AppPalette.blush, AppPalette.mauve],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.progress != progress;
}

class _StepStatusIcon extends StatelessWidget {
  const _StepStatusIcon({required this.isDone, required this.isCurrent});

  final bool isDone;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: context.colors.mauve,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isCurrent ? context.colors.mauve : context.colors.creamWarm,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCurrent ? context.colors.mauve : context.colors.border,
          width: 1.5,
        ),
      ),
      child: isCurrent
          ? const Icon(Icons.play_arrow, size: 12, color: Colors.white)
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Product library page
// ─────────────────────────────────────────────────────────────────────────

class ProductLibraryPage extends StatefulWidget {
  const ProductLibraryPage({super.key, required this.products});

  final List<StepProduct> products;

  @override
  State<ProductLibraryPage> createState() => _ProductLibraryPageState();
}

class _ProductLibraryPageState extends State<ProductLibraryPage> {
  late final List<StepProduct> _products;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  ProductCategory _newCategory = ProductCategory.misc;
  ProductCategory? _filter;

  @override
  void initState() {
    super.initState();
    _products = List<StepProduct>.from(widget.products);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final String? scanned = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const BarcodeScanPage()),
    );
    if (scanned == null || !mounted) return;
    setState(() {
      _codeController.text = scanned;
    });
  }

  void _addProduct() {
    final StepProduct next = StepProduct(
      name: _nameController.text.trim(),
      code: _codeController.text.trim(),
      category: _newCategory,
    );

    if (next.isEmpty) {
      return;
    }

    final bool exists = _products.any(
      (StepProduct item) => item.normalizedKey == next.normalizedKey,
    );
    if (exists) {
      return;
    }

    setState(() {
      _products.add(next);
      _nameController.clear();
      _codeController.clear();
      _newCategory = ProductCategory.misc;
    });
  }

  Future<void> _editProduct(int index) async {
    final StepProduct existing = _products[index];
    final TextEditingController nameController = TextEditingController(
      text: existing.name,
    );
    final TextEditingController codeController = TextEditingController(
      text: existing.code,
    );
    ProductCategory category = existing.category;

    final StepProduct? updated = await showDialog<StepProduct>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(
                'Edit product',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Product #'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<ProductCategory>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: ProductCategory.values
                        .map(
                          (ProductCategory item) =>
                              DropdownMenuItem<ProductCategory>(
                                value: item,
                                child: Text(productCategoryLabel(item)),
                              ),
                        )
                        .toList(),
                    onChanged: (ProductCategory? value) {
                      if (value == null) {
                        return;
                      }
                      setDialogState(() {
                        category = value;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      StepProduct(
                        name: nameController.text.trim(),
                        code: codeController.text.trim(),
                        category: category,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    codeController.dispose();

    if (updated == null) {
      return;
    }

    setState(() {
      _products[index] = updated;
    });
  }

  List<StepProduct> get _visibleProducts {
    if (_filter == null) {
      return _products;
    }
    return _products
        .where((StepProduct item) => item.category == _filter)
        .toList();
  }

  Color _categoryColor(ProductCategory c) {
    switch (c) {
      case ProductCategory.base:
        return const Color(0xFFD5B29F);
      case ProductCategory.topCoat:
        return const Color(0xFFE9EDF2);
      case ProductCategory.color:
        return const Color(0xFFE8B7C8);
      case ProductCategory.catEye:
        return const Color(0xFF6EA8FE);
      case ProductCategory.chrome:
        return const Color(0xFFD4AF37);
      case ProductCategory.misc:
        return context.colors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    final List<StepProduct> visible = _visibleProducts;

    return Scaffold(
      appBar: AppBar(
        title: const HomeTitle(subtitle: 'PRODUCT LIBRARY'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pop(_products);
            },
            icon: const Icon(Icons.check),
            tooltip: 'Done',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: <Widget>[
            const SectionHeader(
              eyebrow: 'Library',
              title: 'Your products',
              subtitle:
                  'Save your most-used gels and powders, then assign them to steps in the builder.',
            ),
            const SizedBox(height: 24),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('ADD PRODUCT', style: t.titleSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          decoration: InputDecoration(
                            labelText: 'Product #',
                            suffixIcon: IconButton(
                              onPressed: _scanBarcode,
                              icon: const Icon(
                                Icons.qr_code_scanner,
                                size: 18,
                              ),
                              tooltip: 'Scan barcode',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<ProductCategory>(
                          initialValue: _newCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items: ProductCategory.values
                              .map(
                                (ProductCategory item) =>
                                    DropdownMenuItem<ProductCategory>(
                                      value: item,
                                      child: Text(productCategoryLabel(item)),
                                    ),
                              )
                              .toList(),
                          onChanged: (ProductCategory? value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _newCategory = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: _addProduct,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(child: Text('FILTER', style: t.titleSmall)),
                if (_filter != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filter = null;
                      });
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) {
                      setState(() {
                        _filter = null;
                      });
                    },
                  ),
                  ...ProductCategory.values.map((ProductCategory cat) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(productCategoryLabel(cat)),
                        selected: _filter == cat,
                        onSelected: (_) {
                          setState(() {
                            _filter = cat;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (visible.isEmpty)
              EmptyState(
                icon: _filter == null
                    ? Icons.spa_outlined
                    : Icons.filter_alt_off_outlined,
                title: _filter == null
                    ? 'Build your library'
                    : 'No products in this category',
                subtitle: _filter == null
                    ? 'Add your gels, powders, and chromes so you can assign them to routine steps.'
                    : 'Try a different filter or add a product to this category.',
              )
            else
              ...List<Widget>.generate(visible.length, (int index) {
                final StepProduct product = visible[index];
                final int realIndex = _products.indexOf(product);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SoftCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _categoryColor(product.category),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.colors.charcoal.withValues(
                                alpha: 0.08,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                product.name.isEmpty
                                    ? 'Unnamed product'
                                    : product.name,
                                style: t.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${productCategoryLabel(product.category)}${product.code.isEmpty ? '' : ' · #${product.code}'}',
                                style: t.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _editProduct(realIndex);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          color: context.colors.muted,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _products.removeAt(realIndex);
                            });
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          color: context.colors.muted,
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// History page
// ─────────────────────────────────────────────────────────────────────────

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, this.settings});

  final AppSettings? settings;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<SessionRecord>? _sessions;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<SessionRecord> loaded = await PersistenceStore.loadSessions();
    loaded.sort(
      (SessionRecord a, SessionRecord b) =>
          b.completedAt.compareTo(a.completedAt),
    );
    if (mounted) {
      setState(() {
        _sessions = loaded;
      });
    }
  }

  Future<void> _delete(SessionRecord record) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete session?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: const Text(
            'This will remove the session from your history. The photo file will remain on the device.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || _sessions == null) {
      return;
    }
    final int idx = _sessions!.indexOf(record);
    final List<SessionRecord> updated =
        List<SessionRecord>.from(_sessions!)..removeAt(idx);
    await PersistenceStore.saveSessions(updated);
    if (mounted) {
      setState(() {
        _sessions = updated;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Session deleted'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              final List<SessionRecord> reverted =
                  List<SessionRecord>.from(_sessions ?? <SessionRecord>[])
                    ..insert(idx.clamp(0, (_sessions?.length ?? 0)), record);
              await PersistenceStore.saveSessions(reverted);
              if (mounted) {
                setState(() {
                  _sessions = reverted;
                });
              }
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    final List<SessionRecord>? sessions = _sessions;

    return Scaffold(
      appBar: AppBar(title: const HomeTitle(subtitle: 'HISTORY')),
      body: SafeArea(
        child: sessions == null
            ? const Center(child: CircularProgressIndicator())
            : sessions.isEmpty
            ? const Center(
                child: EmptyState(
                  icon: Icons.bookmark_outline,
                  title: 'No sessions yet',
                  subtitle:
                      'Finish a routine and tap "Save to history" to start building your portfolio.',
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: sessions.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    final DateTime now = DateTime.now();
                    final DateTime monthStart =
                        DateTime(now.year, now.month);
                    final List<SessionRecord> thisMonth = sessions
                        .where(
                          (SessionRecord s) =>
                              s.completedAt.isAfter(monthStart),
                        )
                        .toList();
                    final int totalSeconds = sessions.fold<int>(
                      0,
                      (int sum, SessionRecord s) =>
                          sum + s.durationSeconds,
                    );
                    final double hours = totalSeconds / 3600;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SectionHeader(
                            eyebrow: 'History',
                            title:
                                '${sessions.length} session${sessions.length == 1 ? '' : 's'}',
                            subtitle:
                                'Your past nail routines, oldest at the bottom.',
                          ),
                          const SizedBox(height: 14),
                          SoftCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            color: context.colors.blushSoft,
                            borderColor: context.colors.blush,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: _HistoryStat(
                                    label: 'THIS MONTH',
                                    value: '${thisMonth.length}',
                                    unit: thisMonth.length == 1
                                        ? 'session'
                                        : 'sessions',
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 36,
                                  color: context.colors.border,
                                ),
                                Expanded(
                                  child: _HistoryStat(
                                    label: 'INVESTED',
                                    value: hours >= 10
                                        ? hours.toStringAsFixed(0)
                                        : hours.toStringAsFixed(1),
                                    unit: hours == 1.0 ? 'hour' : 'hours',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final SessionRecord s = sessions[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SoftCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  width: 72,
                                  height: 96,
                                  child: s.photoPath != null &&
                                          File(s.photoPath!).existsSync()
                                      ? Image.file(
                                          File(s.photoPath!),
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: context.colors.blushSoft,
                                          alignment: Alignment.center,
                                          child: NailVisual(
                                            design: s.allNailsDesign,
                                            baseColor: s.baseColor,
                                            chromeShade: s.chromeShade,
                                            width: 44,
                                            height: 66,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            s.designSummary,
                                            style: t.titleMedium,
                                          ),
                                        ),
                                        IconButton(
                                          padding: const EdgeInsets.all(8),
                                          constraints: const BoxConstraints(
                                            minWidth: 44,
                                            minHeight: 44,
                                          ),
                                          onPressed: () {
                                            shareSessionRecord(
                                              context,
                                              s,
                                              widget.settings ??
                                                  const AppSettings(),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.ios_share,
                                            color: context.colors.muted,
                                            size: 18,
                                          ),
                                          tooltip: 'Share',
                                        ),
                                        IconButton(
                                          padding: const EdgeInsets.all(8),
                                          constraints: const BoxConstraints(
                                            minWidth: 44,
                                            minHeight: 44,
                                          ),
                                          onPressed: () {
                                            _delete(s);
                                          },
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: context.colors.muted,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${s.baseColorName} · ${formatClock(s.durationSeconds)}',
                                      style: t.bodySmall,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${formatRelativeDate(s.completedAt)} · ${formatSessionTime(s.completedAt)}',
                                      style: t.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (s.notes != null) ...<Widget>[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: context.colors.cream,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.colors.borderSoft,
                                ),
                              ),
                              child: Text(s.notes!, style: t.bodyMedium),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Design gallery page
// ─────────────────────────────────────────────────────────────────────────

class DesignGalleryPage extends StatefulWidget {
  const DesignGalleryPage({
    super.key,
    required this.baseColor,
    required this.chromeShade,
    required this.currentSelection,
  });

  final Color baseColor;
  final String chromeShade;
  final NailDesign currentSelection;

  @override
  State<DesignGalleryPage> createState() => _DesignGalleryPageState();
}

class _DesignGalleryPageState extends State<DesignGalleryPage> {
  DesignDifficulty? _filter;

  Color _difficultyColor(DesignDifficulty d) {
    switch (d) {
      case DesignDifficulty.beginner:
        return const Color(0xFF7BA17B);
      case DesignDifficulty.intermediate:
        return const Color(0xFFC9A87C);
      case DesignDifficulty.advanced:
        return const Color(0xFFB0436B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    final List<NailDesign> designs = NailDesign.values.where((NailDesign d) {
      if (_filter == null) return true;
      return designDifficulty(d) == _filter;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const HomeTitle(subtitle: 'DESIGN GALLERY')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: <Widget>[
            const SectionHeader(
              eyebrow: 'Gallery',
              title: 'Browse all designs',
              subtitle:
                  'Tap any design to apply it to your current selection.',
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) {
                      setState(() {
                        _filter = null;
                      });
                    },
                  ),
                  ...DesignDifficulty.values.map((DesignDifficulty d) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(difficultyLabel(d)),
                        selected: _filter == d,
                        onSelected: (_) {
                          setState(() {
                            _filter = d;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: designs.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (BuildContext context, int index) {
                final NailDesign design = designs[index];
                final bool isCurrent = design == widget.currentSelection;
                final DesignDifficulty difficulty = designDifficulty(design);
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop(design);
                  },
                  borderRadius: BorderRadius.circular(22),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? context.colors.blushSoft
                          : context.colors.creamWarm,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isCurrent
                            ? context.colors.mauve
                            : context.colors.border,
                        width: isCurrent ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: NailVisual(
                            design: design,
                            baseColor: widget.baseColor,
                            chromeShade: widget.chromeShade,
                            width: 64,
                            height: 96,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(designLabel(design), style: t.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          designBlurb(design),
                          style: t.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _difficultyColor(difficulty)
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            difficultyLabel(difficulty),
                            style: t.labelSmall?.copyWith(
                              color: _difficultyColor(difficulty),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Look book page
// ─────────────────────────────────────────────────────────────────────────

class LookBookPage extends StatefulWidget {
  const LookBookPage({super.key});

  @override
  State<LookBookPage> createState() => _LookBookPageState();
}

class _LookBookPageState extends State<LookBookPage> {
  List<LookBookEntry>? _entries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<LookBookEntry> loaded = await PersistenceStore.loadLookBook();
    loaded.sort(
      (LookBookEntry a, LookBookEntry b) =>
          b.savedAt.compareTo(a.savedAt),
    );
    if (mounted) {
      setState(() {
        _entries = loaded;
      });
    }
  }

  Future<void> _addEntry() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 14),
                  child: Text(
                    'Add inspo',
                    style: Theme.of(sheetContext).textTheme.headlineSmall,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.of(sheetContext).pop(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('From gallery'),
                  onTap: () {
                    Navigator.of(sheetContext).pop(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    if (source == null) return;
    final XFile? picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    if (!mounted) return;
    final ({String? note, List<String> tags})? meta =
        await _editEntryDialog(initialNote: '', initialTags: const <String>[]);
    if (meta == null) return;
    final LookBookEntry entry = LookBookEntry(
      id: 'l-${DateTime.now().millisecondsSinceEpoch}',
      photoPath: picked.path,
      savedAt: DateTime.now(),
      note: meta.note,
      tags: meta.tags,
    );
    final List<LookBookEntry> updated = <LookBookEntry>[
      entry,
      ...(_entries ?? <LookBookEntry>[]),
    ];
    await PersistenceStore.saveLookBook(updated);
    if (mounted) {
      setState(() {
        _entries = updated;
      });
    }
  }

  Future<({String? note, List<String> tags})?> _editEntryDialog({
    required String initialNote,
    required List<String> initialTags,
  }) async {
    final TextEditingController noteController = TextEditingController(
      text: initialNote,
    );
    final TextEditingController tagController = TextEditingController(
      text: initialTags.join(', '),
    );
    final ({String? note, List<String> tags})? result =
        await showDialog<({String? note, List<String> tags})>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Notes & tags',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'What do you love about this?',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: tagController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'fall, glam, chrome',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final String noteRaw = noteController.text.trim();
                final List<String> tags = tagController.text
                    .split(',')
                    .map((String s) => s.trim())
                    .where((String s) => s.isNotEmpty)
                    .toList();
                Navigator.of(context).pop((
                  note: noteRaw.isEmpty ? null : noteRaw,
                  tags: tags,
                ));
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    noteController.dispose();
    tagController.dispose();
    return result;
  }

  Future<void> _delete(LookBookEntry entry) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Remove from look book?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: const Text('This won\'t delete the photo from your device.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || _entries == null) return;
    final int idx = _entries!.indexOf(entry);
    final List<LookBookEntry> updated =
        List<LookBookEntry>.from(_entries!)..removeAt(idx);
    await PersistenceStore.saveLookBook(updated);
    if (mounted) {
      setState(() {
        _entries = updated;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Look book entry removed'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              final List<LookBookEntry> reverted =
                  List<LookBookEntry>.from(_entries ?? <LookBookEntry>[])
                    ..insert(idx.clamp(0, (_entries?.length ?? 0)), entry);
              await PersistenceStore.saveLookBook(reverted);
              if (mounted) {
                setState(() {
                  _entries = reverted;
                });
              }
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _edit(LookBookEntry entry) async {
    final ({String? note, List<String> tags})? meta = await _editEntryDialog(
      initialNote: entry.note ?? '',
      initialTags: entry.tags,
    );
    if (meta == null || _entries == null) return;
    final LookBookEntry updated = LookBookEntry(
      id: entry.id,
      photoPath: entry.photoPath,
      savedAt: entry.savedAt,
      note: meta.note,
      tags: meta.tags,
    );
    final List<LookBookEntry> next = _entries!
        .map((LookBookEntry e) => e.id == entry.id ? updated : e)
        .toList();
    await PersistenceStore.saveLookBook(next);
    if (mounted) {
      setState(() {
        _entries = next;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    final List<LookBookEntry>? entries = _entries;

    return Scaffold(
      appBar: AppBar(
        title: const HomeTitle(subtitle: 'LOOK BOOK'),
        actions: <Widget>[
          IconButton(
            onPressed: _addEntry,
            icon: const Icon(Icons.add),
            tooltip: 'Add inspo',
          ),
        ],
      ),
      body: SafeArea(
        child: entries == null
            ? const Center(child: CircularProgressIndicator())
            : entries.isEmpty
                ? Center(
                    child: EmptyState(
                      icon: Icons.collections_outlined,
                      title: 'Build your look book',
                      subtitle:
                          'Save photos of looks you love so you can come back to them when you\'re planning your next set.',
                      cta: FilledButton.icon(
                        onPressed: _addEntry,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add inspo'),
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: entries.length,
                    itemBuilder: (BuildContext context, int i) {
                      final LookBookEntry e = entries[i];
                      return InkWell(
                        onTap: () {
                          _edit(e);
                        },
                        onLongPress: () {
                          _delete(e);
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.colors.creamWarm,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: context.colors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(17),
                                  ),
                                  child: e.photoPath.isNotEmpty &&
                                          File(e.photoPath).existsSync()
                                      ? Image.file(
                                          File(e.photoPath),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        )
                                      : Container(
                                          color: context.colors.blushSoft,
                                          child: Center(
                                            child: Icon(
                                              Icons.image_outlined,
                                              color: context.colors.muted,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    if (e.note != null && e.note!.isNotEmpty)
                                      Text(
                                        e.note!,
                                        style: t.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    else
                                      Text(
                                        'No notes',
                                        style: t.labelSmall,
                                      ),
                                    if (e.tags.isNotEmpty) ...<Widget>[
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: e.tags.take(3).map(
                                          (String tag) {
                                            return Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: context.colors
                                                    .blushSoft,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                tag,
                                                style: t.labelSmall?.copyWith(
                                                  color: context.colors
                                                      .mauveDeep,
                                                ),
                                              ),
                                            );
                                          },
                                        ).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// QR scan page
// ─────────────────────────────────────────────────────────────────────────

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final Barcode b in capture.barcodes) {
      final String? raw = b.rawValue;
      if (raw == null) continue;
      final DesignPreset? preset = decodePresetQrPayload(raw);
      if (preset != null) {
        _handled = true;
        Navigator.of(context).pop(preset);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const HomeTitle(subtitle: 'SCAN PRESET QR')),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppPalette.charcoal.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Point your camera at a Manicure Masterpiece preset QR code',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Barcode scanner page (for product library)
// ─────────────────────────────────────────────────────────────────────────

class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  State<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final Barcode b in capture.barcodes) {
      final String? raw = b.rawValue;
      if (raw == null || raw.isEmpty) continue;
      _handled = true;
      HapticFeedback.lightImpact();
      Navigator.of(context).pop(raw);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const HomeTitle(subtitle: 'SCAN BARCODE')),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppPalette.charcoal.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Point your camera at the product barcode',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Photo try-on page
// ─────────────────────────────────────────────────────────────────────────

class TryOnPage extends StatefulWidget {
  const TryOnPage({
    super.key,
    required this.colors,
    required this.chromeShade,
    required this.designs,
  });

  final List<Color> colors;
  final String chromeShade;
  final List<NailDesign> designs;

  @override
  State<TryOnPage> createState() => _TryOnPageState();
}

class _PlacementGuidePainter extends CustomPainter {
  _PlacementGuidePainter({required this.start, required this.end});

  final Offset start;
  final Offset end;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = AppPalette.mauve.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    // Dashed line between start and end
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    final double dist = math.sqrt(dx * dx + dy * dy);
    if (dist < 4) return;
    const double dashLen = 6;
    const double gapLen = 4;
    final double step = dashLen + gapLen;
    final double ux = dx / dist;
    final double uy = dy / dist;
    for (double i = 0; i < dist; i += step) {
      final double e = math.min(i + dashLen, dist);
      canvas.drawLine(
        Offset(start.dx + ux * i, start.dy + uy * i),
        Offset(start.dx + ux * e, start.dy + uy * e),
        stroke,
      );
    }
    // Marker at start (fingertip)
    canvas.drawCircle(start, 6, Paint()..color = AppPalette.mauve);
    canvas.drawCircle(
      start,
      6,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _PlacementGuidePainter old) {
    return old.start != start || old.end != end;
  }
}

class _NailTransform {
  _NailTransform({
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.flipped = false,
  }) : visible = true;

  Offset position;
  double scale;
  double rotation;
  bool flipped;
  bool visible;
}

class _GestureBaseline {
  const _GestureBaseline({
    required this.focalStart,
    required this.position,
    required this.scale,
    required this.rotation,
  });
  final Offset focalStart;
  final Offset position;
  final double scale;
  final double rotation;
}

class _TryOnPageState extends State<TryOnPage> {
  static const double _baseNailWidth = 56;
  static const double _baseNailHeight = 84;

  final GlobalKey _boundaryKey = GlobalKey();
  String? _photoPath;
  List<_NailTransform> _transforms = <_NailTransform>[];
  int? _selectedIndex;
  _GestureBaseline? _baseline;
  Size _canvasSize = Size.zero;
  bool _saving = false;
  bool _placementMode = false;
  int _placementIndex = 0;
  Offset? _placementDragStart;
  Offset? _placementDragCurrent;

  Future<void> _pick(ImageSource source) async {
    final XFile? f = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 88,
    );
    if (f == null || !mounted) return;
    setState(() {
      _photoPath = f.path;
      _transforms = <_NailTransform>[];
      _selectedIndex = null;
    });
  }

  void _ensureLayout(Size canvas) {
    _canvasSize = canvas;
    if (_transforms.isNotEmpty) return;
    _applyHandPreset(rightHand: true);
  }

  void _applyHandPreset({required bool rightHand}) {
    final double cw = _canvasSize.width;
    final double ch = _canvasSize.height;
    if (cw <= 0 || ch <= 0) return;

    // Default fan layout — thumb on bottom side, four fingers arching up.
    // Positions are anchor (top-left corner of nail bounding box).
    final double midY = ch * 0.42;
    final double thumbY = ch * 0.72;
    final double spacing = cw / 6;

    // Fingers angles fan slightly outward (in radians).
    // Mirrored for left hand.
    final List<double> angles = <double>[
      0.5, // thumb tilted strongly inward
      -0.18, // index
      -0.05, // middle
      0.06, // ring
      0.20, // pinky
    ];
    final List<double> scales = <double>[1.15, 1.05, 1.10, 1.0, 0.85];

    _transforms = List<_NailTransform>.generate(widget.designs.length, (int i) {
      final double scale = scales[i];
      final double w = _baseNailWidth * scale;
      final double h = _baseNailHeight * scale;
      double x;
      double y;
      if (i == 0) {
        // thumb on the outer side
        x = rightHand ? cw * 0.18 - w / 2 : cw * 0.82 - w / 2;
        y = thumbY - h / 2;
      } else {
        final int fingerIndex = i; // 1..4
        x = spacing * (fingerIndex + 0.6) - w / 2;
        // Fan arc: middle finger slightly higher
        final double arc =
            -(0.5 - (fingerIndex - 2.5).abs() / 5) * (ch * 0.05);
        y = midY + arc - h / 2;
      }
      double rot = angles[i];
      if (!rightHand) rot = -rot;
      return _NailTransform(
        position: Offset(x, y),
        scale: scale,
        rotation: rot,
        flipped: !rightHand,
      );
    });
    _selectedIndex = null;
  }

  void _onScaleStart(int i, ScaleStartDetails d) {
    setState(() {
      _selectedIndex = i;
      _baseline = _GestureBaseline(
        focalStart: d.focalPoint,
        position: _transforms[i].position,
        scale: _transforms[i].scale,
        rotation: _transforms[i].rotation,
      );
    });
  }

  void _onScaleUpdate(int i, ScaleUpdateDetails d) {
    final _GestureBaseline? base = _baseline;
    if (base == null) return;
    setState(() {
      _transforms[i].position = base.position + (d.focalPoint - base.focalStart);
      _transforms[i].scale = (base.scale * d.scale).clamp(0.3, 4.0);
      _transforms[i].rotation = base.rotation + d.rotation;
    });
  }

  void _onScaleEnd(int i, ScaleEndDetails d) {
    _baseline = null;
  }

  void _flipSelected() {
    final int? i = _selectedIndex;
    if (i == null) return;
    setState(() {
      _transforms[i].flipped = !_transforms[i].flipped;
    });
  }

  void _toggleSelectedVisible() {
    final int? i = _selectedIndex;
    if (i == null) return;
    setState(() {
      _transforms[i].visible = !_transforms[i].visible;
    });
  }

  void _deselect() {
    if (_selectedIndex == null) return;
    setState(() {
      _selectedIndex = null;
    });
  }

  void _startPlacement() {
    HapticFeedback.selectionClick();
    setState(() {
      _placementMode = true;
      _placementIndex = 0;
      _selectedIndex = null;
      // Make sure transforms exist with sensible defaults
      if (_transforms.length != widget.designs.length) {
        _applyHandPreset(rightHand: true);
      }
      for (final _NailTransform t in _transforms) {
        t.visible = true;
      }
    });
  }

  void _cancelPlacement() {
    setState(() {
      _placementMode = false;
      _placementIndex = 0;
    });
  }

  void _placementPanStart(DragStartDetails d) {
    if (!_placementMode) return;
    if (_placementIndex >= _transforms.length) return;
    final _NailTransform t = _transforms[_placementIndex];
    setState(() {
      _placementDragStart = d.localPosition;
      _placementDragCurrent = d.localPosition;
      // Top-center of unrotated nail at tap point: position.y = tip.y, position.x = tip.x - w/2
      final double w = _baseNailWidth * t.scale;
      t.position = Offset(d.localPosition.dx - w / 2, d.localPosition.dy);
      t.rotation = 0;
    });
  }

  void _placementPanUpdate(DragUpdateDetails d) {
    if (!_placementMode) return;
    if (_placementIndex >= _transforms.length) return;
    final Offset? start = _placementDragStart;
    if (start == null) return;
    final _NailTransform t = _transforms[_placementIndex];
    final Offset current = d.localPosition;
    final double dx = current.dx - start.dx;
    final double dy = current.dy - start.dy;
    final double distance = math.sqrt(dx * dx + dy * dy);

    setState(() {
      _placementDragCurrent = current;
      // Auto-scale based on drag distance (only if user dragged enough)
      if (distance > 16) {
        t.scale = (distance / _baseNailHeight).clamp(0.4, 3.5);
        // Rotation so the nail's base points along the drag direction.
        // Unrotated base is +y; we want it to point along (dx, dy).
        // Required rotation: atan2(dy, dx) - π/2.
        t.rotation = math.atan2(dy, dx) - math.pi / 2;
      }
      // Position top-center stays at the start point regardless of size.
      final double w = _baseNailWidth * t.scale;
      t.position = Offset(start.dx - w / 2, start.dy);
    });
  }

  void _placementPanEnd(DragEndDetails d) {
    if (!_placementMode) return;
    HapticFeedback.lightImpact();
    setState(() {
      _placementDragStart = null;
      _placementDragCurrent = null;
      _placementIndex++;
      if (_placementIndex >= _transforms.length) {
        _placementMode = false;
      }
    });
  }

  Future<void> _saveComposite() async {
    final int? previousSelection = _selectedIndex;
    setState(() {
      _selectedIndex = null;
      _saving = true;
    });
    // Wait a frame so the selection outline clears before capture.
    await Future<void>.delayed(const Duration(milliseconds: 40));
    try {
      final RenderRepaintBoundary boundary = _boundaryKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final ByteData? bytes =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        throw Exception('Could not encode image');
      }
      final Directory tmp = await Directory.systemTemp.createTemp('tryon');
      final String path =
          '${tmp.path}/tryon-${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File(path);
      await file.writeAsBytes(bytes.buffer.asUint8List());

      final List<LookBookEntry> existing =
          await PersistenceStore.loadLookBook();
      final LookBookEntry entry = LookBookEntry(
        id: 'tryon-${DateTime.now().millisecondsSinceEpoch}',
        photoPath: path,
        savedAt: DateTime.now(),
        note: 'Virtual try-on',
        tags: const <String>['try-on'],
      );
      final List<LookBookEntry> updated = <LookBookEntry>[entry, ...existing];
      await PersistenceStore.saveLookBook(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved try-on to look book')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          _selectedIndex = previousSelection;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const HomeTitle(subtitle: 'VIRTUAL TRY-ON'),
        actions: <Widget>[
          if (_photoPath != null)
            IconButton(
              onPressed: _saving ? null : _saveComposite,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.bookmark_add_outlined),
              tooltip: 'Save to look book',
            ),
        ],
      ),
      body: SafeArea(
        child: _photoPath == null ? _buildPicker() : _buildEditor(),
      ),
    );
  }

  Widget _buildPicker() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          const SectionHeader(
            eyebrow: 'Try on',
            title: 'Pick a photo of your hand',
            subtitle:
                'Capture or upload a photo, then position each nail. Pinch to resize, rotate with two fingers, tap to select.',
          ),
          const SizedBox(height: 28),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Take a photo'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choose from gallery'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.black,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints box) {
                _ensureLayout(Size(box.maxWidth, box.maxHeight));
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _placementMode ? null : _deselect,
                  onPanStart: _placementMode ? _placementPanStart : null,
                  onPanUpdate: _placementMode ? _placementPanUpdate : null,
                  onPanEnd: _placementMode ? _placementPanEnd : null,
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Image.file(
                            File(_photoPath!),
                            fit: BoxFit.contain,
                          ),
                        ),
                        for (int i = 0; i < widget.designs.length; i++)
                          if (_transforms.length > i &&
                              _transforms[i].visible &&
                              !(_placementMode &&
                                  i > _placementIndex))
                            _buildNailOverlay(i),
                        if (_placementMode &&
                            _placementDragStart != null &&
                            _placementDragCurrent != null)
                          IgnorePointer(
                            child: CustomPaint(
                              size: Size.infinite,
                              painter: _PlacementGuidePainter(
                                start: _placementDragStart!,
                                end: _placementDragCurrent!,
                              ),
                            ),
                          ),
                        if (_placementMode) _buildPlacementOverlay(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: 248,
          child: _buildToolbar(),
        ),
      ],
    );
  }

  Widget _buildPlacementOverlay() {
    final bool done = _placementIndex >= _transforms.length;
    final String currentName = done
        ? 'All set'
        : kNailNames[_placementIndex];
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppPalette.charcoal.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppPalette.mauve,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${_placementIndex + (done ? 0 : 1)}/${_transforms.length}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Tap your $currentName tip',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    done
                        ? 'Use the toolbar below to fine-tune.'
                        : 'Drag from the tip toward the nail base.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _cancelPlacement,
              icon: const Icon(Icons.close, color: Colors.white),
              tooltip: 'Cancel',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNailOverlay(int i) {
    final _NailTransform t = _transforms[i];
    final Color color = i < widget.colors.length
        ? widget.colors[i]
        : widget.colors.isNotEmpty
            ? widget.colors.first
            : const Color(0xFFD5B29F);
    final bool selected = _selectedIndex == i;
    final double w = _baseNailWidth * t.scale;
    final double h = _baseNailHeight * t.scale;
    return Positioned(
      left: t.position.dx,
      top: t.position.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedIndex = i;
          });
        },
        onScaleStart: (ScaleStartDetails d) => _onScaleStart(i, d),
        onScaleUpdate: (ScaleUpdateDetails d) => _onScaleUpdate(i, d),
        onScaleEnd: (ScaleEndDetails d) => _onScaleEnd(i, d),
        child: Transform.rotate(
          angle: t.rotation,
          alignment: Alignment.topCenter,
          child: Transform.scale(
            scaleX: t.flipped ? -1.0 : 1.0,
            scaleY: 1.0,
            alignment: Alignment.topCenter,
            child: Container(
              decoration: selected
                  ? BoxDecoration(
                      border: Border.all(
                        color: AppPalette.mauve,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppPalette.mauve.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    )
                  : null,
              padding: const EdgeInsets.all(2),
              child: NailVisual(
                design: widget.designs[i],
                baseColor: color,
                chromeShade: widget.chromeShade,
                width: w,
                height: h,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    final int? selectedIdx = _selectedIndex;
    final _NailTransform? selectedT =
        selectedIdx == null ? null : _transforms[selectedIdx];

    return Container(
      decoration: BoxDecoration(
        color: context.colors.cream,
        border: Border(top: BorderSide(color: context.colors.borderSoft)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: selectedT == null
                ? _buildIdleToolbar()
                : _buildSelectionToolbar(selectedIdx!, selectedT),
          ),
        ),
      ),
    );
  }

  Widget _buildIdleToolbar() {
    return Column(
      key: const ValueKey<String>('idle'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FilledButton.icon(
          onPressed: _placementMode ? null : _startPlacement,
          icon: const Icon(Icons.touch_app),
          label: const Text('Map my hand — tap each fingertip'),
          style: FilledButton.styleFrom(
            backgroundColor: context.colors.mauve,
            minimumSize: const Size.fromHeight(46),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              _toolbarButton(
                icon: Icons.back_hand_outlined,
                label: 'Left hand',
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _applyHandPreset(rightHand: false);
                  });
                },
              ),
              const SizedBox(width: 8),
              _toolbarButton(
                icon: Icons.front_hand_outlined,
                label: 'Right hand',
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _applyHandPreset(rightHand: true);
                  });
                },
              ),
              const SizedBox(width: 8),
              _toolbarButton(
                icon: Icons.refresh,
                label: 'Reset',
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _transforms = <_NailTransform>[];
                    _ensureLayout(_canvasSize);
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.touch_app_outlined,
                size: 16,
                color: context.colors.muted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Tap a nail to select. Use sliders to fine-tune.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionToolbar(int idx, _NailTransform t) {
    final TextTheme tt = Theme.of(context).textTheme;
    return Column(
      key: const ValueKey<String>('selected'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: context.colors.blushSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                kNailNames[idx],
                style: tt.labelLarge?.copyWith(
                  color: context.colors.mauveDeep,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _flipSelected,
              icon: const Icon(Icons.flip),
              tooltip: 'Flip',
            ),
            IconButton(
              onPressed: _toggleSelectedVisible,
              icon: Icon(
                t.visible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              tooltip: t.visible ? 'Hide' : 'Show',
            ),
            IconButton(
              onPressed: _deselect,
              icon: const Icon(Icons.check),
              tooltip: 'Done',
              color: context.colors.mauve,
            ),
          ],
        ),
        const SizedBox(height: 4),
        // SIZE slider
        Row(
          children: <Widget>[
            Icon(
              Icons.photo_size_select_small,
              size: 16,
              color: context.colors.muted,
            ),
            Expanded(
              child: Slider(
                min: 0.3,
                max: 3.5,
                divisions: 32,
                value: t.scale.clamp(0.3, 3.5),
                label: '${(t.scale * 100).round()}%',
                onChanged: (double v) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _transforms[idx].scale = v;
                  });
                },
              ),
            ),
            Icon(
              Icons.photo_size_select_large,
              size: 18,
              color: context.colors.muted,
            ),
            SizedBox(
              width: 44,
              child: Text(
                '${(t.scale * 100).round()}%',
                textAlign: TextAlign.right,
                style: tt.labelSmall,
              ),
            ),
          ],
        ),
        // ROTATION row — buttons + slider
        Row(
          children: <Widget>[
            IconButton(
              onPressed: () {
                setState(() {
                  _transforms[idx].rotation -= math.pi / 36; // -5°
                });
                HapticFeedback.selectionClick();
              },
              icon: const Icon(Icons.rotate_left),
              tooltip: 'Rotate −5°',
            ),
            Expanded(
              child: Slider(
                min: -math.pi,
                max: math.pi,
                divisions: 72,
                value: t.rotation.clamp(-math.pi, math.pi),
                label: '${(t.rotation * 180 / math.pi).round()}°',
                onChanged: (double v) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _transforms[idx].rotation = v;
                  });
                },
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _transforms[idx].rotation += math.pi / 36; // +5°
                });
                HapticFeedback.selectionClick();
              },
              icon: const Icon(Icons.rotate_right),
              tooltip: 'Rotate +5°',
            ),
            SizedBox(
              width: 44,
              child: Text(
                '${(t.rotation * 180 / math.pi).round()}°',
                textAlign: TextAlign.right,
                style: tt.labelSmall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _toolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Social / share card
// ─────────────────────────────────────────────────────────────────────────

class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.designs,
    required this.colors,
    required this.chromeShade,
    this.metaLeft,
    this.metaRight,
    this.photoPath,
    this.watermark = true,
  });

  final String title;
  final String subtitle;
  final List<NailDesign> designs;
  final List<Color> colors;
  final String chromeShade;
  final String? metaLeft;
  final String? metaRight;
  final String? photoPath;
  final bool watermark;

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = photoPath != null && File(photoPath!).existsSync();
    final List<Color> uniqueColors = <Color>{...colors}.take(5).toList();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 360,
        height: 360,
        color: AppPalette.creamWarm,
        child: Column(
          children: <Widget>[
            // ── VISUAL ZONE (60%) ────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Container(
                decoration: hasPhoto
                    ? const BoxDecoration(color: Colors.black)
                    : const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            AppPalette.blushSoft,
                            AppPalette.blush,
                            AppPalette.creamWarm,
                          ],
                          stops: <double>[0.0, 0.6, 1.0],
                        ),
                      ),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    if (hasPhoto)
                      Positioned.fill(
                        child: Image.file(
                          File(photoPath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List<Widget>.generate(designs.length,
                                (int i) {
                              final Color c = i < colors.length
                                  ? colors[i]
                                  : (colors.isNotEmpty
                                        ? colors.first
                                        : const Color(0xFFD5B29F));
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: NailVisual(
                                  design: designs[i],
                                  baseColor: c,
                                  chromeShade: chromeShade,
                                  width: 48,
                                  height: 72,
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    // Brand badge top-left
                    Positioned(
                      top: 14,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppPalette.creamWarm.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          'NAILTIMER STUDIO',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.mauveDeep,
                          ),
                        ),
                      ),
                    ),
                    // Bottom fade so the visual blends into the info zone
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: IgnorePointer(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Color(0x00000000),
                                AppPalette.creamWarm,
                              ],
                              stops: <double>[0.0, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── INFO ZONE (40%) ──────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 14),
                color: AppPalette.creamWarm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            color: AppPalette.charcoal,
                            height: 1.0,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppPalette.charcoalSoft,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Palette dots
                    Row(
                      children: uniqueColors
                          .map(
                            (Color c) => Padding(
                              padding: const EdgeInsets.only(right: 7),
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    center: const Alignment(-0.35, -0.4),
                                    radius: 0.95,
                                    colors: <Color>[
                                      Color.lerp(c, Colors.white, 0.4) ?? c,
                                      c,
                                    ],
                                    stops: const <double>[0.0, 0.75],
                                  ),
                                  border: Border.all(
                                    color: AppPalette.charcoal.withValues(
                                      alpha: 0.18,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    // Meta row + watermark
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 1,
                          color: AppPalette.border.withValues(alpha: 0.7),
                          margin: const EdgeInsets.only(bottom: 8),
                        ),
                        Row(
                          children: <Widget>[
                            if (metaLeft != null && metaLeft!.isNotEmpty)
                              Text(
                                metaLeft!,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.w700,
                                  color: AppPalette.charcoal,
                                ),
                              ),
                            if (metaLeft != null &&
                                metaRight != null &&
                                metaRight!.isNotEmpty) ...<Widget>[
                              const SizedBox(width: 10),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: AppPalette.muted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            if (metaRight != null && metaRight!.isNotEmpty)
                              Text(
                                metaRight!,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.w600,
                                  color: AppPalette.charcoalSoft,
                                ),
                              ),
                            const Spacer(),
                            if (watermark)
                              Text(
                                'Manicure Masterpiece',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppPalette.mauveDeep,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> renderShareCardToPng(
  BuildContext context,
  ShareCard card,
) async {
  final GlobalKey key = GlobalKey();
  final OverlayState overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (BuildContext ctx) => Positioned(
      left: -100000,
      top: 0,
      child: RepaintBoundary(key: key, child: card),
    ),
  );
  overlay.insert(entry);
  // Let the widget mount + paint
  await Future<void>.delayed(const Duration(milliseconds: 120));

  try {
    final RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? bytes =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      throw Exception('Could not encode share card');
    }
    final Directory tmp = await Directory.systemTemp.createTemp('share');
    final String path =
        '${tmp.path}/share-${DateTime.now().millisecondsSinceEpoch}.png';
    await File(path).writeAsBytes(bytes.buffer.asUint8List());
    return path;
  } finally {
    entry.remove();
  }
}

Future<void> shareSessionRecord(
  BuildContext context,
  SessionRecord session,
  AppSettings settings,
) async {
  final List<Color> nailColors = List<Color>.generate(
    kNailNames.length,
    (int i) {
      if (session.perNailColorArgbs != null &&
          i < session.perNailColorArgbs!.length) {
        return Color(session.perNailColorArgbs![i]);
      }
      return session.baseColor;
    },
  );
  final List<NailDesign> nailDesigns = session.mode == BuildMode.allSame
      ? List<NailDesign>.filled(
          kNailNames.length,
          session.allNailsDesign,
          growable: true,
        )
      : List<NailDesign>.from(session.perNailDesigns);

  final String path = await renderShareCardToPng(
    context,
    ShareCard(
      title: session.designSummary,
      subtitle:
          '${session.baseColorName} · ${formatClock(session.durationSeconds)}',
      designs: nailDesigns,
      colors: nailColors,
      chromeShade: session.chromeShade,
      metaLeft: formatSessionDate(session.completedAt).toUpperCase(),
      metaRight: session.mode == BuildMode.allSame ? 'ALL SAME' : 'PER NAIL',
      photoPath: session.photoPath,
      watermark: settings.shareWatermark,
    ),
  );

  await Share.shareXFiles(
    <XFile>[XFile(path)],
    text: 'Made with Manicure Masterpiece',
  );
}

Future<void> sharePresetCard(
  BuildContext context,
  DesignPreset preset,
  AppSettings settings,
  List<CustomColor> customColors,
) async {
  final List<Color> nailColors = List<Color>.generate(
    kNailNames.length,
    (int i) {
      if (preset.perNailColors != null &&
          i < preset.perNailColors!.length) {
        return baseColorValue(preset.perNailColors![i], customColors);
      }
      return baseColorValue(preset.baseColor, customColors);
    },
  );
  final List<NailDesign> nailDesigns = preset.mode == BuildMode.allSame
      ? List<NailDesign>.filled(
          kNailNames.length,
          preset.allNailsDesign,
          growable: true,
        )
      : List<NailDesign>.from(preset.perNailDesigns);

  final String path = await renderShareCardToPng(
    context,
    ShareCard(
      title: preset.name,
      subtitle:
          '${preset.baseColor} · ${designLabel(preset.allNailsDesign)}',
      designs: nailDesigns,
      colors: nailColors,
      chromeShade: preset.chromeShade,
      metaLeft: 'PRESET',
      metaRight: preset.mode == BuildMode.allSame ? 'ALL SAME' : 'PER NAIL',
      watermark: settings.shareWatermark,
    ),
  );

  await Share.shareXFiles(
    <XFile>[XFile(path)],
    text: 'My Manicure Masterpiece preset: ${preset.name}',
  );
}

// ─────────────────────────────────────────────────────────────────────────
// About + Privacy pages
// ─────────────────────────────────────────────────────────────────────────

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _info = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    final PackageInfo? info = _info;
    return Scaffold(
      appBar: AppBar(title: const HomeTitle(subtitle: 'ABOUT')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: <Widget>[
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      context.colors.mauve,
                      context.colors.mauveDeep,
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'NT',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 44,
                    fontWeight: FontWeight.w500,
                    color: context.colors.cream,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Manicure Masterpiece',
                style: t.displaySmall,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'A guided routine timer for at-home nail techs.',
                textAlign: TextAlign.center,
                style: t.bodyMedium?.copyWith(color: context.colors.muted),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                info == null
                    ? 'Loading…'
                    : 'Version ${info.version} (${info.buildNumber})',
                style: t.labelSmall,
              ),
            ),
            const SizedBox(height: 28),
            Text('CRAFT', style: t.titleSmall),
            const SizedBox(height: 10),
            SoftCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Built for nail enthusiasts who do their own (and their friends\') nails at home.',
                    style: t.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No accounts. No cloud. Your designs and photos stay on your device.',
                    style: t.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('LINKS', style: t.titleSmall),
            const SizedBox(height: 10),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text('Privacy policy', style: t.titleMedium),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const PrivacyPage(),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: context.colors.borderSoft),
                  ListTile(
                    leading: const Icon(Icons.code_outlined),
                    title:
                        Text('Open source licenses', style: t.titleMedium),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'Manicure Masterpiece',
                        applicationVersion: info?.version ?? '',
                        applicationLegalese:
                            '© ${DateTime.now().year} Manicure Masterpiece',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Made with care · ${DateTime.now().year}',
                style: t.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  static const String _policy = '''
Manicure Masterpiece is designed to respect your privacy. This policy explains what data the app handles and how.

WHAT DATA THE APP STORES
• Your saved presets, routines, custom colors, product library, session history, and look book entries are all saved locally on your device using SharedPreferences.
• Photos you capture or pick (for sessions, look book, virtual try-on, and the share card) are stored in your device's local storage.
• Your settings (sound, haptics, theme, default colors) are stored locally.

WHAT THE APP DOES NOT DO
• No data is uploaded to any server.
• No analytics, crash reporting, or tracking is collected.
• No account is required. The app does not know who you are.
• Your photos and routines are never shared automatically. Sharing only happens when you explicitly tap a share button and pick a destination yourself.

PERMISSIONS THE APP USES
• Camera — to take photos for sessions, look book, and barcode/QR scanning. Only used when you tap a button that requires it.
• Photos / Media — to pick images from your gallery for sessions, look book, virtual try-on, and color extraction.
• Vibrate — for haptic feedback during the timer.
• Wake lock — to keep the screen awake during a timer session if you have that setting enabled.

DELETING YOUR DATA
You can delete your data at any time by uninstalling the app, or by clearing the app's storage from your device's system settings. Individual presets, sessions, look book entries, and saved colors can also be deleted in-app.

THIRD-PARTY CODE
The app uses open-source packages for things like the color picker, QR scanner, image picker, and palette extraction. None of these packages send data over the network in the way the app uses them. You can review them under About → Open source licenses.

CONTACT
For questions or feedback, please reach out via your platform's app store listing.

This policy may be updated. The current version is shown in About.
''';

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const HomeTitle(subtitle: 'PRIVACY POLICY')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: <Widget>[
            const SectionHeader(
              eyebrow: 'Privacy',
              title: 'Your data stays with you',
              subtitle:
                  'Everything is stored locally on your device. No accounts, no analytics, no cloud sync.',
            ),
            const SizedBox(height: 18),
            SoftCard(
              padding: const EdgeInsets.all(18),
              child: Text(
                _policy.trim(),
                style: t.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
