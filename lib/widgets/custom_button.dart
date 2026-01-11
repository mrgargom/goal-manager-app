import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// هذا الملف يحتوي على عنصر واجهة مخصص: "الزر الموحد" (CustomButton).
// ---------------------------------------------------------------------------
// الهدف من هذا الملف:
// 1. إعادة استخدام تصميم واحد للأزرار في جميع أنحاء التطبيق لضمان التناسق.
// 2. التعامل بذكاء مع حالة "التحميل" (Loading) تلقائياً، بحيث يتحول الزر
//    إلى مؤشر تحميل ويمنع الضغط المتكرر أثناء تنفيذ العمليات.
// ---------------------------------------------------------------------------

class CustomButton extends StatelessWidget {
  // النص الذي سيظهر داخل الزر (مثل: "تسجيل الدخول"، "حفظ")
  final String text;

  // الدالة التي سيتم تنفيذها عند الضغط على الزر (Callback Function)
  final VoidCallback onPressed;

  // متغير لتحديد ما إذا كان الزر في حالة تحميل
  // إذا كانت true، سيظهر مؤشر دوران ولن يكون الزر قابلاً للضغط
  final bool isLoading;

  // المُشيد (Constructor) لاستقبال البيانات عند إنشاء الزر
  const CustomButton({
    super.key,
    required this.text, // النص إجباري
    required this.onPressed, // دالة الضغط إجبارية
    this.isLoading = false, // القيمة الافتراضية للتحميل هي false (زر عادي)
  });

  // دالة بناء الواجهة
  @override
  Widget build(BuildContext context) {
    // نستخدم ElevatedButton كقاعدة للزر الخاص بنا
    return ElevatedButton(
      // التحكم في تفعيل الزر:
      // إذا كان يحمل (isLoading == true) -> نجعل onPressed تساوي null (الزر معطل)
      // وإلا -> نستخدم الدالة الممررة onPressed (الزر فعال)
      onPressed: isLoading ? null : onPressed,

      // تخصيص مظهر الزر
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16), // مسافة داخلية رأسية
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // تدوير الحواف بمقدار 8
        ),
      ),

      // محتوى الزر الداخلي
      // نستخدم معامل شرطي (Ternary Operator) لتحديد ما نعرضه:
      child: isLoading
          // الحالة 1: إذا كان يحمل -> اعرض دائرة تحميل صغيرة
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2), // مؤشر بسماكة 2
            )
          // الحالة 2: الوضع الطبيعي -> اعرض النص
          : Text(text),
    );
  }
}
