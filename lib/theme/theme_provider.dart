import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// هذا الملف مسؤول عن إدارة سمة التطبيق (Theme)
// يتيح للمستخدم التبديل بين الوضع الليلي والنهاري وحفظ اختياره
class ThemeProvider extends ChangeNotifier {
  // متغير خاص لتخزين وضع السمة الحالي (افتراضياً يتبع النظام)
  ThemeMode _themeMode = ThemeMode.system;

  // مفتاح ثابت نستخدمه لحفظ واسترجاع السمة من الذاكرة المحلية
  static const String _themeKey = 'theme_mode';

  // المُشيد (Constructor): يتم استدعاؤه عند إنشاء نسخة من هذا المزود
  // يقوم بتحميل السمة المحفوظة سابقاً
  ThemeProvider() {
    _loadTheme();
  }

  // دالة للحصول على وضع السمة الحالي من خارج الكلاس
  ThemeMode get themeMode => _themeMode;

  // خاصية لمعرفة ما إذا كان الوضع الحالي داكناً أم لا
  // مفيدة لتغيير أيقونات واجهة المستخدم بناءً على السمة
  bool get isDarkMode {
    // إذا كان الوضع مضبوطاً على "النظام"، نتحقق من إعدادات الجهاز الحالية
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    // وإلا نتحقق مباشرة من المتغير
    return _themeMode == ThemeMode.dark;
  }

  // دالة لتحميل السمة المحفوظة من الذاكرة المحلية (SharedPreferences)
  Future<void> _loadTheme() async {
    // الحصول على نسخة من SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // قراءة القيمة المحفوظة
    final savedTheme = prefs.getString(_themeKey);

    // إذا كانت هناك قيمة محفوظة، نقوم بتحديث السمة بناءً عليها
    if (savedTheme != null) {
      if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
      // إعلام المستمعين (الويدجتس) بحدوث تغيير لإعادة بناء الواجهة
      notifyListeners();
    }
  }

  // دالة لتبديل السمة بين الفاتح والداكن يدوياً
  Future<void> toggleTheme(bool isDark) async {
    // تحديث المتغير الداخلي
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    // حفظ الاختيار الجديد في الذاكرة المحلية
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, isDark ? 'dark' : 'light');

    // إعلام التطبيق بالتغيير لتحديث الألوان فوراً
    notifyListeners();
  }

  // دالة لإعادة السمة لاتباع إعدادات النظام
  Future<void> setSystemTheme() async {
    _themeMode = ThemeMode.system;

    // حذف القيمة المحفوظة ليعود للتلقائي
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);

    notifyListeners();
  }
}
