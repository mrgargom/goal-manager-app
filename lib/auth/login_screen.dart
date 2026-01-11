import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'signup_screen.dart';
import '../widgets/custom_button.dart';

// هذا الملف يمثل شاشة تسجيل الدخول في التطبيق
// يسمح للمستخدمين بتسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// فئة الحالة لشاشة تسجيل الدخول التي تدير التفاعل والبيانات
class _LoginScreenState extends State<LoginScreen> {
  // مفتاح فريد لنموذج تسجيل الدخول، يُستخدم للتحقق من صحة المدخلات
  final _formKey = GlobalKey<FormState>();

  // وحدة تحكم لحقل إدخال البريد الإلكتروني
  final _emailController = TextEditingController();

  // وحدة تحكم لحقل إدخال كلمة المرور
  final _passwordController = TextEditingController();

  // متغير لتتبع حالة التحميل (لإظهار مؤشر الانتظار أثناء عملية تسجيل الدخول)
  bool _isLoading = false;

  // هذه الدالة تُستدعى عند التخلص من الشاشة (إغلاقها)
  @override
  void dispose() {
    // يجب التخلص من وحدات التحكم لتحرير الموارد
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // دالة التعامل مع عملية تسجيل الدخول
  Future<void> _login() async {
    // التحقق أولاً من أن جميع الحقول صالحة (غير فارغة ومطابقة للشروط)
    if (_formKey.currentState!.validate()) {
      // بدء حالة التحميل
      setState(() => _isLoading = true);
      try {
        // استدعاء دالة تسجيل الدخول من مزود المصادقة (AuthProvider)
        // نستخدم listen: false لأننا هنا نقوم بإجراء ولا نستمع لتغييرات
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).signIn(_emailController.text.trim(), _passwordController.text.trim());

        // ملاحظة: لا نحتاج للانتقال يدوياً هنا، لأن main.dart يراقب حالة المصادقة
        // وسيقوم بتحويل المستخدم تلقائياً عند نجاح التسجيل
      } catch (e) {
        // في حالة حدوث خطأ، نعرض رسالة خطأ في أسفل الشاشة
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Failed: ${e.toString()}')),
          );
        }
      } finally {
        // إيقاف حالة التحميل سواء نجحت العملية أو فشلت
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // بناء واجهة المستخدم للشاشة
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // شريط التطبيق العلوي
      appBar: AppBar(title: const Text('Login')),
      // استخدام Padding لإبعاد المحتوى عن الحواف
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // ربط النموذج بالمفتاح الذي أنشأناه
          key: _formKey,
          child: Column(
            // محاذاة العناصر في وسط الشاشة عمودياً
            mainAxisAlignment: MainAxisAlignment.center,
            // تمديد العناصر لتملأ العرض أفقياً
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // حقل إدخال البريد الإلكتروني
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                // دالة التحقق من صحة الإدخال
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // حقل إدخال كلمة المرور
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true, // إخفاء النص ليكون سرياً
                // دالة التحقق من صحة الإدخال
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // زر تسجيل الدخول (نستخدم الويدجت المخصص CustomButton)
              CustomButton(
                text: 'Login',
                onPressed: _login,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              // زر نصي للانتقال إلى شاشة إنشاء حساب جديد
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
                child: const Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
