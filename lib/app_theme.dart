import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// هذا الملف يحدد "سمة التطبيق" (Theme).
// ---------------------------------------------------------------------------
// السمة هي مجموعة من الألوان والخطوط والأشكال التي تحدد المظهر العام للتطبيق.
// هنا نقوم بتعريف نمطين:
// 1. الوضع الفاتح (Light Theme): للاستخدام النهاري أو العادي.
// 2. الوضع الداكن (Dark Theme): للاستخدام الليلي لراحة العين.
// ---------------------------------------------------------------------------

class AppTheme {
  // ---------------------------------------------------------------------------
  // دالة لاسترجاع إعدادات "الوضع الفاتح"
  // static: تعني أنه يمكننا استدعاء هذه الدالة مباشرة دون إنشاء نسخة من الكلاس
  // get: تعني أننا نستدعيها كخاصية (AppTheme.lightTheme)
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true, // تفعيل تصميم Material 3 الحديث من جوجل
      // تحديد نظام الألوان
      // fromSeed: طريقة ذكية تولد نظام ألوان متكامل ومتناسق من لون واحد أساسي
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue, // اللون الأساسي (الأزرق)
        brightness: Brightness.light, // تحديد السطوع كفاتح
      ),

      // تخصيص الخطوط
      // نستخدم مكتبة Google Fonts لتطبيق خط "Poppins" على جميع نصوص التطبيق
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),

      // تخصيص شريط التطبيق العلوي (AppBar)
      appBarTheme: const AppBarTheme(
        centerTitle: true, // توسيط العنوان
        elevation: 0, // إزالة الظل أسفل الشريط لمظهر مسطح ونظيف
      ),

      // تخصيص شكل البطاقات (Cards)
      cardTheme: CardThemeData(
        elevation: 2, // ارتفاع الظل (عمق البطاقة)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            12,
          ), // تدوير حواف البطاقة بمقدار 12
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // دالة لاسترجاع إعدادات "الوضع الداكن"
  // تحتوي على نفس التخصيصات ولكن مع ألوان داكنة
  // ---------------------------------------------------------------------------
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true, // تفعيل Material 3
      // نظام ألوان داكن
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue, // نفس اللون الأساسي (الأزرق)
        brightness: Brightness.dark, // تحديد السطوع كداكن (للوضع الليلي)
      ),

      // نفس نوع الخط المستخدم في الوضع الفاتح
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),

      // تخصيص شريط التطبيق
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),

      // تخصيص البطاقات
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
