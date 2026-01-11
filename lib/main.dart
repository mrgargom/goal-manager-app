// استيراد مكتبة واجهة المستخدم الخاصة بـ Flutter
import 'package:flutter/material.dart';
// استيراد مكتبة Firebase الأساسية
import 'package:firebase_core/firebase_core.dart';
// استيراد مكتبة إدارة الحالة Provider
import 'package:provider/provider.dart';
// استيراد إعدادات Firebase
import 'firebase_options.dart';
// استيراد مزود حالة الأهداف
import 'providers/goal_provider.dart';
// استيراد مزود حالة المصادقة
import 'auth/auth_provider.dart';
// استيراد مزود حالة السمة (Theme)
import 'theme/theme_provider.dart';
// استيراد شاشة قائمة الأهداف
import 'screens/goal_list_screen.dart';
// استيراد شاشة تسجيل الدخول
import 'auth/login_screen.dart';
// استيراد سمة التطبيق
import 'app_theme.dart';

// الدالة الرئيسية التي يبدأ منها تنفيذ التطبيق
void main() async {
  // التأكد من تهيئة ارتباطات Flutter قبل تنفيذ أي كود غير متزامن
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة Firebase باستخدام الخيارات المناسبة للمنصة الحالية
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // تشغيل التطبيق
  runApp(const MyApp());
}

// الويدجت الجذرية للتطبيق
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام MultiProvider لتوفير عدة مزودات حالة للتطبيق
    return MultiProvider(
      providers: [
        // توفير مزود المصادقة
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // توفير مزود السمة (Theme)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // توفير مزود الأهداف الذي يعتمد على مزود المصادقة
        ChangeNotifierProxyProvider<AuthProvider, GoalProvider>(
          create: (_) => GoalProvider(),
          // تحديث مزود الأهداف عند تغير حالة المصادقة (تغير المستخدم)
          update: (_, auth, previous) => previous!..update(auth.user?.uid),
        ),
      ],
      // استخدام Consumer للاستماع لتغييرات السمة
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            // إخفاء شريط التصحيح (Debug Banner)
            debugShowCheckedModeBanner: false,
            // عنوان التطبيق
            title: 'Goal Manager',
            // تعيين السمة الفاتحة
            theme: AppTheme.lightTheme,
            // تعيين السمة الداكنة
            darkTheme: AppTheme.darkTheme,
            // تحديد وضع السمة بناءً على اختيار المستخدم
            themeMode: themeProvider.themeMode,
            // تحديد الشاشة الرئيسية بناءً على حالة المصادقة
            home: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                // إذا كان المستخدم مسجلاً للدخول، اعرض شاشة الأهداف، وإلا اعرض شاشة تسجيل الدخول
                return auth.isAuthenticated
                    ? const GoalListScreen()
                    : const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
