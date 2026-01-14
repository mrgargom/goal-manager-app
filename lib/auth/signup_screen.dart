import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import '../widgets/custom_button.dart';

// هذا الملف يمثل شاشة إنشاء حساب جديد في التطبيق
// يسمح للمستخدمين الجدد بالتسجيل باستخدام البريد الإلكتروني وكلمة المرور
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

// فئة الحالة لشاشة التسجيل التي تدير التفاعل والبيانات
class _SignUpScreenState extends State<SignUpScreen> {
  // مفتاح فريد لنموذج التسجيل، يُستخدم للتحقق من صحة المدخلات
  final _formKey = GlobalKey<FormState>();

  // وحدة تحكم لحقل إدخال البريد الإلكتروني
  final _emailController = TextEditingController();

  // وحدة تحكم لحقل إدخال كلمة المرور
  final _passwordController = TextEditingController();

  // متغير لتتبع حالة التحميل (لإظهار مؤشر الانتظار أثناء عملية التسجيل)
  bool _isLoading = false;

  // هذه الدالة تُستدعى عند التخلص من الشاشة (إغلاقها)
  @override
  void dispose() {
    // يجب التخلص من وحدات التحكم لتحرير ذاكرة الجهاز
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // دالة التعامل مع عملية إنشاء الحساب
  Future<void> _signUp() async {
    // التحقق أولاً من أن جميع الحقول صالحة (غير فارغة ومطابقة للشروط)
    if (_formKey.currentState!.validate()) {
      // بدء حالة التحميل لتحديث الواجهة
      setState(() => _isLoading = true);
      try {
        // استدعاء دالة التسجيل من مزود المصادقة (AuthProvider)
        // نمرر البريد الإلكتروني وكلمة المرور بعد إزالة المسافات الزائدة (trim)
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).signUp(_emailController.text.trim(), _passwordController.text.trim());

        // التحقق من أن الشاشة لا تزال معروضة قبل استخدام السياق (context)
        if (mounted) {
          // العودة إلى الشاشة السابقة (عادة شاشة تسجيل الدخول)
          // أو سيقوم مستمع حالة المصادقة في main.dart بتحويل المستخدم تلقائياً
          Navigator.pop(context);
        }
      } catch (e) {
        // في حالة حدوث خطأ، نعرض رسالة خطأ في أسفل الشاشة
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign Up Failed: ${e.toString()}')),
          );
        }
      } finally {
        // إيقاف حالة التحميل في النهاية سواء نجحت العملية أو فشلت
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // بناء واجهة المستخدم للشاشة
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // شريط التطبيق العلوي
      appBar: AppBar(title: const Text('Sign Up')),
      // استخدام Padding لترك مسافة حول المحتوى
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // ربط النموذج بالمفتاح الذي أنشأناه للتحقق
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
                // التحقق من صحة البريد الإلكتروني
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
                obscureText: true, // إخفاء النص
                // التحقق من صحة كلمة المرور وقوتها
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // زر إنشاء الحساب (مكون مخصص)
              CustomButton(
                text: 'Sign Up',
                onPressed: _signUp,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}