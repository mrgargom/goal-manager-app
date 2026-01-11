import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

// هذا الملف مسؤول عن إدارة حالة المصادقة (تسجيل الدخول/الخروج) في التطبيق
// يستخدم هذا الملف مكتبة Provider لإعلام باقي أجزاء التطبيق بتغييرات حالة المستخدم
// ويعتمد على Firebase Auth للتعامل الحقيقي مع خوادم المصادقة
class AuthProvider extends ChangeNotifier {
  // كائن Firebase Auth الذي يوفر وظائف المصادقة الأساسية
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // متغير لتخزين بيانات المستخدم الحالي (User) إذا كان مسجلاً للدخول، أو null إذا لم يكن كذلك
  User? _user;

  // خاصية (Getter) للوصول إلى بيانات المستخدم الحالي من خارج هذا الملف
  User? get user => _user;

  // خاصية (Getter) للتحقق مما إذا كان المستخدم مسجلاً للدخول أم لا (true إذا كان مسجلاً)
  bool get isAuthenticated => _user != null;

  // البناء (Constructor) يتم استدعاؤه عند إنشاء نسخة من هذا المزود
  AuthProvider() {
    // الاستماع إلى تغييرات حالة المصادقة (مثل تسجيل الدخول أو الخروج) بشكل مستمر
    _auth.authStateChanges().listen((User? user) {
      // تحديث المتغير المحلي بالمستخدم الجديد (أو null عند تسجيل الخروج)
      _user = user;
      // إعلام جميع المستمعين (الشاشات) بأن حالة المصادقة قد تغيرت ليعيدوا بناء واجهتهم
      notifyListeners();
    });
  }

  // دالة لتسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<void> signIn(String email, String password) async {
    // انتظار اكتمال عملية تسجيل الدخول عبر Firebase
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // دالة لإنشاء حساب جديد (تسجيل مستخدم جديد)
  Future<void> signUp(String email, String password) async {
    // انتظار اكتمال عملية إنشاء الحساب عبر Firebase
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // دالة لتسجيل الخروج من الحساب الحالي
  Future<void> signOut() async {
    // انتظار اكتمال عملية تسجيل الخروج عبر Firebase
    await _auth.signOut();
  }
}
